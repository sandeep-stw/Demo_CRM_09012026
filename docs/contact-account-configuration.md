# Contact and Account CRE Configuration

## Purpose

This configuration specification implements Issue #2, `Configure Contact and Account CRE relationship data`. It translates the solution design into a build-ready Dataverse configuration for standard `Contact` and `Account` tables.

## Contact Configuration

### Relationship classifications and designations

Use normalized child tables rather than multi-select columns for contact classifications and professional designations. This supports multiple active values, effective-date history, Dataverse search, and Power BI cross-filtering.

| Table | Required columns | Relationship | Initial reference values |
| --- | --- | --- | --- |
| Contact Classification | Contact, Classification, Effective From, Active | Many-to-one to Contact | Broker, Landlord, Tenant, Investor, Developer, Property Manager, Asset Manager, Lender, Attorney, Architect, Engineer, Vendor, Consultant, Municipality, Economic Development, Franchisee, Franchise Development, Owner/User, General Contractor, Government Agency |
| Contact Designation | Contact, Designation, Effective From, Active | Many-to-one to Contact | SIOR, CCIM, ICSC, CRE, CPM, RPA, LEED, NAIOP, ULI, BOMA, MBA, ALC |

`Classification` and `Designation` use governed reference values. The Contact form provides subgrids and quick-create actions for both tables. A contact may have any number of active classifications and designations.

### Contact relationship-profile columns

| Column | Type | Required | Notes |
| --- | --- | --- | --- |
| Business Line | Global choice | No | Uses the seven values defined in the SSD. |
| Assigned Broker | User lookup | No | Defaults to record owner when created by a broker. |
| Markets Served | Related Market records | No | Allows multiple markets. |
| Geographic Coverage | Multiple lines of text | No | Freeform coverage detail. |
| Target Markets | Related Market records | No | Allows multiple markets. |
| Property Preferences | Multiple lines of text | No | Captures asset and location preferences. |
| Min SF | Whole number | No | Must be zero or greater. |
| Max SF | Whole number | No | Must be greater than or equal to Min SF. |
| Lease Expiration Date | Date only | No | Used for renewal reporting. |
| Renewal Timeline | Global choice | No | 18 Months, 12 Months, 6 Months, 3 Months, Expired, Not Applicable. |
| Referral Source | Lookup to Contact or Account | No | Use a polymorphic lookup where available; otherwise provide separate contact and account lookups. |
| Relationship Tier | Global choice | No | A, B, C, or D. |
| Last Meaningful Contact | Date and time | No | Updated by automation; users cannot edit. |
| Preferred Communication Method | Global choice | No | Email, Phone, Mobile, Text Message, or Other. |
| Social Media Links | Multiple lines of text | No | Store one URL per line. |
| Tags | Related Tag records | No | Governed custom tag table. |

## Account Configuration

### Account classifications

Add `Account Classification` as a multi-select global choice. An account may hold one or more of these values:

Tenant, Landlord, Developer, REIT, Investment Group, Family Office, Franchise, Brokerage, Municipality, Property Owner, Vendor, Lender, and Contractor.

### Account profile columns

| Column | Type | Required | Notes |
| --- | --- | --- | --- |
| Portfolio SF | Whole number | No | Must be zero or greater. |
| Markets | Related Market records | No | Allows multiple markets. |
| Industries | Related Industry records | No | Allows multiple industries. |
| NAICS Code | Text | No | Validate as a 2- to 6-digit NAICS code. |

### Account locations

Create an `Account Location` child table with a required Account lookup and Location Name. Include Address Line 1, Address Line 2, City, State/Province, Postal Code, Country/Region, Main Phone, and Location Type. Location Type uses a global choice: Headquarters, Office, Regional Office, Branch, Property Office, and Other.

The Account form includes an Account Locations subgrid and quick-create action. Do not use a repeating-text field for locations.

## Forms, Search, and Reporting

- Contact main form: Relationship Profile tab, Classifications subgrid, Designations subgrid, Markets tab, and activity timeline.
- Account main form: CRE Profile tab, Account Classification field, Markets/Industries controls, Account Locations subgrid, linked Contacts subgrid, and activity timeline.
- Enable Dataverse search for contact/account name, email, phone, market, classification, designation, account classification, industry, NAICS code, and location address fields.
- Include Contact Classification, Contact Designation, Market, Account Location, and Tag tables in the Power BI semantic model.
- Create views for active classifications/designations, contacts by market and tier, accounts by classification/market, and accounts with multiple locations.

## Business Rules and Security

- Enforce Min SF less than or equal to Max SF.
- Enforce non-negative Portfolio SF and SF values.
- Restrict Last Meaningful Contact to flow updates.
- Brokers can create and update their owned contacts and accounts; Broker Managers can access team records; Operations maintains reference data; Finance has read access only unless separately assigned.
- Audit changes to Assigned Broker, Relationship Tier, Lease Expiration Date, Account Classification, Contact Classification, and Contact Designation.

## Acceptance Tests

1. A broker creates one contact with at least two classifications and two professional designations; both appear in the Contact form, Dataverse search, and Power BI.
2. A broker records all relationship-profile fields and cannot set Min SF above Max SF.
3. A user creates an account with multiple classifications, markets, industries, and locations.
4. An account location is added, edited, and reported as a related record.
5. A permitted broker can update an owned record while an unauthorized user cannot modify protected data.
6. Contact and account views filter correctly by classification, designation, market, tier, and NAICS code.
