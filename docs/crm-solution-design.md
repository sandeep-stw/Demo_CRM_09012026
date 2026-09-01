# Commercial Real Estate CRM Solution Design

## 1. Purpose

This document defines a Phase 1 and Phase 2 implementation for a commercial real estate (CRE) CRM on Microsoft Dataverse and Dynamics 365 Sales. The solution centralizes relationship data, properties, tenant and landlord activity, and deal pipelines while preserving flexible many-to-many CRE relationships.

## 2. Scope and Assumptions

### In scope

- Contact, account, property, suite, and opportunity data management.
- Saved views, searchable fields, dashboards, and reporting datasets.
- Seven business-process flows (BPFs) and stage-level automation.
- Commission and fee capture for opportunities.

### Assumptions

- Dynamics 365 Sales is the primary application and Dataverse is the data platform.
- Standard `Contact`, `Account`, and `Opportunity` tables are extended rather than replaced.
- The organization will define controlled lists for markets, property types, business lines, statuses, and relationship tiers during configuration.
- Commission splits are stored as related records because an opportunity can include multiple brokers, referrals, and adjustments.

## 3. Solution Architecture

A managed Dataverse solution contains tables, columns, relationships, forms, views, BPFs, Power Automate flows, security roles, and model-driven app navigation. It uses standard tables where they provide the business object, with custom tables for CRE-specific structures.

| Layer | Design |
| --- | --- |
| User experience | Model-driven app with Relationship Management, Properties, Deals, and Reporting work areas. |
| Data | Standard Contact, Account, Opportunity, Activity, and User tables; custom Property, Suite, Opportunity Fee, and Account Location tables. |
| Process | One BPF per business line, with stage-gated data and automation through Power Automate. |
| Insights | System views, charts, dashboards, and Power BI semantic model sourced from Dataverse. |
| Governance | Managed solution deployment, environment variables, role-based security, field audit, and duplicate detection. |

## 4. Data Model

### 4.1 Contact

Extend `Contact` with:

| Capability | Implementation |
| --- | --- |
| Relationship classifications | Multi-select choice: Broker, Landlord, Tenant, Investor, Developer, Property Manager, Asset Manager, Lender, Attorney, Architect, Engineer, Vendor, Consultant, Municipality, Economic Development, Franchisee, Franchise Development, Owner/User, General Contractor, Government Agency. |
| Professional designations | Multi-select choice: SIOR, CCIM, ICSC, CRE, CPM, RPA, LEED, NAIOP, ULI, BOMA, MBA, ALC. |
| Relationship profile | Business Line, Assigned Broker (User lookup), Markets Served, Geographic Coverage, Target Markets, Property Preferences, Min SF, Max SF, Lease Expiration Date, Renewal Timeline, Referral Source, Relationship Tier, Last Meaningful Contact, Preferred Communication Method, Social Media Links, and Tags. |

`Last Meaningful Contact` is updated by a flow when a qualifying completed activity is recorded. Tags may use the platform tag control or a governed custom tag table where reporting needs stricter normalization.

### 4.2 Account (Company)

Extend `Account` with a multi-select `Account Classification` choice containing Tenant, Landlord, Developer, REIT, Investment Group, Family Office, Franchise, Brokerage, Municipality, Property Owner, Vendor, Lender, and Contractor. Add Portfolio SF, Markets, Industries, NAICS Code, and a related `Account Location` table for multiple office locations.

Use standard account-contact relationships for linked contacts. Associate accounts to properties using a purpose-based `Property Party` relationship table, which supports ownership entities, managers, and asset managers without limiting a property to one account.

### 4.3 Property and Suite

Create custom `Property` and `Suite` tables.

| Table | Key columns | Relationships |
| --- | --- | --- |
| Property | Address, County, Market, Submarket, Property Type, Ownership Summary, Broker Assignment, Status, Building SF, Land Area, Occupancy %, Parking Ratio, Construction Year, Zoning, Leasing Status | One-to-many Suites; many-to-many Accounts through Property Party; related Opportunities. |
| Suite | Suite Number, Floor/Stacking Order, Available SF, Lease Rate, Operating Expenses, Tenant Improvements, Tenant Account, Lease Start Date, Lease Expiration Date, Options, Vacancy Status | Parent Property; optional Tenant Account and Contact. |
| Property Party | Property, Account, Contact, Party Role, Ownership %, Effective From, Effective To | Supports owners, ownership entities, property managers, asset managers, landlords, and tenants. |

Available Suites hold leasing details and vacancy status. The Suite table is the source of office stacking and retail tenant-roster views; Property presents rollups for available area and occupancy.

### 4.4 Opportunity and Fees

Extend `Opportunity` with Business Line, Property (lookup), Deal Size SF, Lease Term, Sale Price, Cap Rate, Loan Information, LOI/Offer Date, Target Close Date, Probability, Pipeline Stage, Gross Commission, Net Commission, Expected Commission, Actual Commission, Commission Calculation Method, Co-Broker (Account lookup), Referral Source, and Deal Notes.

Create an `Opportunity Fee` child table with Fee Type, Payee Account/Contact, Calculation Basis, Rate, Amount, and Notes. Fee Type includes Referral Fee, Outside Broker Fee, Co-Broker Fee, House Portion, Broker Portion, and Adjustment. This preserves a complete fee breakdown and allows the opportunity commission totals to be calculated by rollup or flow.

## 5. Relationships and User Experience

Forms expose relationship subgrids and related tabs:

- Property: tenants, suites, ownership parties, managers, asset managers, and related opportunities.
- Tenant account/contact: properties and suites occupied, active requirements, lease dates, and related opportunities.
- Landlord account/contact: owned and managed portfolio, property parties, and related opportunities.
- Contact and account: activities, relationship classifications, designations, markets, and property associations.

Enable Dataverse search on contact name, account name, classifications, professional designations, markets, property address, market, submarket, and property type. Searchable/reportable multi-select values must be validated against the organization’s chosen reporting approach; where cross-filtering is insufficient, expose normalized relationship tables in the Power BI model.

## 6. Process Design

### 6.1 Business Process Flows

Create one BPF for each business line. The opportunity `Business Line` is required before process selection, and only the corresponding process is enabled for the record.

| Business line | Recommended stages |
| --- | --- |
| Tenant Representation | Qualification, Requirement Definition, Market Search, Tour/Proposal, LOI/Negotiation, Lease Execution, Won/Lost. |
| Landlord Representation | Qualification, Property Onboarding, Marketing, Prospecting/Tours, Proposal/Negotiation, Lease Execution, Won/Lost. |
| Investment Sales | Qualification, Valuation/Underwriting, Listing Preparation, Marketing, Offers, Due Diligence, Close, Won/Lost. |
| Property Management | Intake, Property Transition, Operations Planning, Vendor/Tenant Coordination, Reporting, Stabilized/Closed. |
| Development | Feasibility, Site Control, Entitlements, Design/Construction, Leasing/Sales, Delivery, Closed. |
| Capital Markets | Qualification, Underwriting, Capital Sourcing, Terms/LOI, Due Diligence, Close, Won/Lost. |
| Retail Site Selection & Consulting | Requirement Definition, Market Mapping, Site Search, Site Evaluation, Negotiation, Approval/Execution, Won/Lost. |

Each BPF requires the business line and property when relevant, target close date, probability, and a stage-specific next action. Stage transitions update the opportunity pipeline stage, create follow-up activities, and notify the owner where an approval or deadline is due.

### 6.2 Automation

| Trigger | Automation |
| --- | --- |
| Completed qualifying activity | Update the related contact’s Last Meaningful Contact. |
| Lease expiration enters 18, 12, or 6 month window | Create renewal task for Assigned Broker; escalate based on relationship tier. |
| Opportunity stage change | Validate required stage fields, update pipeline stage, create next-step task, and record stage history. |
| Opportunity fee created or changed | Recalculate expected and net commission totals. |
| Suite tenant or lease date changed | Refresh property occupancy and availability rollups. |
| Stale Tier A/B contact | Create owner task after 60 days without meaningful activity. |

## 7. Views, Reporting, and Dashboards

Provide system views and equivalent Power BI report pages for:

- Tenant requirements filtered by minimum/maximum SF, market, submarket, and property preference.
- Lease expirations in the next 6, 12, and 18 months.
- Stale Tier A/B contacts with no meaningful activity for more than 60 days.
- Available listings by market, submarket, and available SF.
- Landlord portfolios grouped by owner/account.
- Contacts by professional designation, including SIOR.
- Pipeline, forecast commission, actual commission, and fee breakdown by business line, broker, stage, market, and close period.

Views use owner-aware filtering and shared public views. Dashboards use refresh-aware Dataverse charts for operational use and Power BI for portfolio, commission, and trend analysis.

## 8. Security, Data Quality, and Governance

- Security roles: CRM Administrator, Broker, Broker Manager, Property Manager, Operations, Finance, and Read-Only.
- Brokers can read shared relationship/property data and update records they own or are assigned; Finance owns commission visibility and updates.
- Enable auditing for ownership, relationship tier, lease dates, pipeline-stage, commission, and fee changes.
- Configure duplicate detection for contact email, account name plus address, and property address.
- Use business rules for required fields, date validation, non-negative SF and currency, valid occupancy percentages, and role-specific ownership/fee fields.
- Deploy as a managed solution from development through test and production, with environment variables for notification recipients and shared-team references.

## 9. Delivery Plan and Acceptance Criteria

| Phase | Deliverables | Acceptance criteria |
| --- | --- | --- |
| Phase 1 | Contact and account extensions, Property/Suite/Property Party tables, forms, views, search, security baseline. | Users can classify contacts/accounts multiple ways, manage owners/managers/tenants, maintain suite rosters and lease dates, and execute every requested saved view. |
| Phase 2 | Opportunity extensions, Opportunity Fee, seven BPFs, stage automation, commission reporting. | Users can run the correct BPF by business line, meet stage requirements, manage all requested deal and fee data, and report expected/actual commissions. |
| UAT | Scenario scripts, migration validation, role testing, performance testing, and training. | Named business owners approve each business line, all view totals reconcile to source records, and no high-severity defects remain. |

## 10. Open Decisions

- Define values and ownership for Business Line, market hierarchy, property type, status, relationship tier, and qualification activity types.
- Confirm whether classification/designation values require normalized child tables for Power BI slicing or whether multi-select Dataverse choices meet reporting needs.
- Confirm source systems, data migration volume, document storage requirements, integration needs, retention policy, and commission-calculation rules.
- Confirm BPF stage names, required-field rules, approvals, notifications, and SLAs with leaders for each business line.
