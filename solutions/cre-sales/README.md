# CRE Sales Dynamics 365 Solution

## Purpose

`CRE Sales` is the Dynamics 365 Sales and Dataverse solution workspace for the commercial real estate CRM. This initial implementation delivers the Contact and Account relationship-data changes defined in `docs/contact-account-configuration.md`.

## Included Changes

- Contact relationship-profile columns.
- Normalized Contact Classification and Contact Designation tables.
- Account classification and CRE profile columns.
- Account Location child table.
- Contact and Account form, search, view, validation, security, and audit requirements.

## Deployment Prerequisites

- A Dynamics 365 Sales environment with Dataverse.
- Power Platform CLI (`pac`) authenticated to the target environment.
- System Administrator or System Customizer role.
- A publisher prefix reserved for this solution. The examples use `cre`.

## Build and Import

1. Install the Power Platform CLI on the build machine.
2. Authenticate with `pac auth create --url <environment-url>`.
3. Create an unmanaged solution named `CRE Sales` with unique name `cre_CRESales` and publisher prefix `cre`.
4. Use `implementation/contact-account-manifest.md` to configure tables, columns, relationships, forms, views, security, and auditing in the solution.
5. Export the solution using `scripts/export-solution.sh <environment-url>`.
6. Unpack the exported solution into `src/` with `pac solution unpack`, commit the generated source, and use `pac solution pack` for managed deployments.

## Deployment Order

1. Global choices and reference tables.
2. Contact Classification, Contact Designation, Tag, Market, and Account Location tables.
3. Contact and Account columns and relationships.
4. Forms, views, Dataverse search, business rules, security, and auditing.
5. Data migration and acceptance tests.

Do not deploy to production until the acceptance tests in the manifest have passed in a test environment.
