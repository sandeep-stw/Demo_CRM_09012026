# Contact and Account Dataverse Change Manifest

## Solution Identity

| Property | Value |
| --- | --- |
| Display name | CRE Sales |
| Unique name | `cre_CRESales` |
| Publisher prefix | `cre` |
| Solution type | Unmanaged in development; managed for test and production |
| Primary app | Dynamics 365 Sales |

## Global Choices

Create the following global choices in the solution.

| Name | Values |
| --- | --- |
| `cre_BusinessLine` | Tenant Representation; Landlord Representation; Investment Sales; Property Management; Development; Capital Markets; Retail Site Selection & Consulting |
| `cre_RelationshipTier` | A; B; C; D |
| `cre_RenewalTimeline` | 18 Months; 12 Months; 6 Months; 3 Months; Expired; Not Applicable |
| `cre_PreferredCommunicationMethod` | Email; Phone; Mobile; Text Message; Other |
| `cre_AccountClassification` | Tenant; Landlord; Developer; REIT; Investment Group; Family Office; Franchise; Brokerage; Municipality; Property Owner; Vendor; Lender; Contractor |
| `cre_AccountLocationType` | Headquarters; Office; Regional Office; Branch; Property Office; Other |

## Custom Tables

### Contact Classification

| Property | Value |
| --- | --- |
| Schema name | `cre_ContactClassification` |
| Ownership | User or team |
| Primary column | `cre_Name` (autonumber or calculated display name) |
| Required columns | `cre_Contact` (Contact lookup), `cre_Classification` (reference lookup), `cre_EffectiveFrom` (date only), `cre_Active` (yes/no) |

Create a many-to-one relationship from Contact Classification to Contact. Seed governed classification references: Broker, Landlord, Tenant, Investor, Developer, Property Manager, Asset Manager, Lender, Attorney, Architect, Engineer, Vendor, Consultant, Municipality, Economic Development, Franchisee, Franchise Development, Owner/User, General Contractor, and Government Agency.

### Contact Designation

| Property | Value |
| --- | --- |
| Schema name | `cre_ContactDesignation` |
| Ownership | User or team |
| Primary column | `cre_Name` (autonumber or calculated display name) |
| Required columns | `cre_Contact` (Contact lookup), `cre_Designation` (reference lookup), `cre_EffectiveFrom` (date only), `cre_Active` (yes/no) |

Create a many-to-one relationship from Contact Designation to Contact. Seed governed designation references: SIOR, CCIM, ICSC, CRE, CPM, RPA, LEED, NAIOP, ULI, BOMA, MBA, and ALC.

### Account Location

| Property | Value |
| --- | --- |
| Schema name | `cre_AccountLocation` |
| Ownership | User or team |
| Primary column | `cre_LocationName` |
| Required columns | `cre_Account` (Account lookup), `cre_LocationName` (text) |
| Optional columns | Address Line 1, Address Line 2, City, State/Province, Postal Code, Country/Region, Main Phone, Location Type |

Create a many-to-one relationship from Account Location to Account. Use `cre_AccountLocationType` for Location Type.

### Supporting Reference Tables

Create governed `Market`, `Submarket`, `Industry`, `Tag`, `Classification Reference`, and `Designation Reference` tables. A Submarket must have one Market lookup. Add an `Active` yes/no column to each reference table and prevent deletion when a reference is in use.

## Contact Columns

Add the following columns to the standard Contact table. Prefix all custom schemas with `cre_`.

| Display name | Schema suffix | Type | Validation or behavior |
| --- | --- | --- | --- |
| Business Line | `BusinessLine` | Global choice | `cre_BusinessLine` |
| Assigned Broker | `AssignedBroker` | User lookup | Default to owner when a broker creates the record |
| Markets Served | `MarketsServed` | Related Market records | Many-to-many relationship |
| Geographic Coverage | `GeographicCoverage` | Multiple lines of text | Optional |
| Target Markets | `TargetMarkets` | Related Market records | Many-to-many relationship |
| Property Preferences | `PropertyPreferences` | Multiple lines of text | Optional |
| Min SF | `MinSF` | Whole number | Must be greater than or equal to zero and not greater than Max SF |
| Max SF | `MaxSF` | Whole number | Must be greater than or equal to Min SF |
| Lease Expiration Date | `LeaseExpirationDate` | Date only | Optional |
| Renewal Timeline | `RenewalTimeline` | Global choice | `cre_RenewalTimeline` |
| Referral Source | `ReferralSource` | Lookup | Use Contact/Account polymorphic lookup where enabled |
| Relationship Tier | `RelationshipTier` | Global choice | `cre_RelationshipTier` |
| Last Meaningful Contact | `LastMeaningfulContact` | Date and time | Read-only on forms; automation writes value |
| Preferred Communication Method | `PreferredCommunicationMethod` | Global choice | `cre_PreferredCommunicationMethod` |
| Social Media Links | `SocialMediaLinks` | Multiple lines of text | One URL per line |

## Account Columns

| Display name | Schema suffix | Type | Validation or behavior |
| --- | --- | --- | --- |
| Account Classification | `AccountClassification` | Multi-select global choice | `cre_AccountClassification` |
| Portfolio SF | `PortfolioSF` | Whole number | Must be greater than or equal to zero |
| Markets | `Markets` | Related Market records | Many-to-many relationship |
| Industries | `Industries` | Related Industry records | Many-to-many relationship |
| NAICS Code | `NAICSCode` | Text | Validate as a 2- to 6-digit numeric value |

## Forms and Views

- Add a **Relationship Profile** tab, Classifications subgrid, Designations subgrid, Markets tab, and Timeline to the Contact main form.
- Add a **CRE Profile** tab, Account Classification, Markets, Industries, Account Locations subgrid, linked Contacts subgrid, and Timeline to the Account main form.
- Add quick-create forms for Contact Classification, Contact Designation, and Account Location.
- Add views for active classifications/designations, contacts by market and tier, accounts by classification and market, and accounts with multiple locations.

## Search, Reporting, and Governance

- Enable Dataverse search for Contact/Account name, email, phone, market, classification, designation, account classification, industry, NAICS code, and location address fields.
- Include Contact Classification, Contact Designation, Market, Account Location, and Tag in the Power BI semantic model.
- Create a Contact business rule: `Min SF <= Max SF` when both values are populated.
- Create Account business rules for non-negative Portfolio SF and a 2- to 6-digit NAICS Code.
- Audit Assigned Broker, Relationship Tier, Lease Expiration Date, Account Classification, Contact Classification, and Contact Designation.
- Grant Brokers create/update rights on owned Contact, Account, and related relationship data; grant Broker Managers team access; grant Operations reference-data maintenance; restrict Finance to read access unless separately assigned.

## Acceptance Tests

1. A broker creates one contact with at least two active classifications and two active designations; both are visible in the form, search, and Power BI.
2. A broker records Contact relationship-profile values and cannot save Min SF greater than Max SF.
3. A user creates an Account with multiple classifications, Markets, Industries, and Account Locations.
4. An Account Location is created, edited, and included in a report as a related record.
5. Security-role tests confirm a permitted broker can update owned records and an unauthorized user cannot edit protected data.
6. Views filter Contacts and Accounts by classification, designation, market, tier, and NAICS Code.
