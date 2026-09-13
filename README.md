![Salesforce Education Data Architecture](https://github.com/SalesforceFoundation/EDA/blob/main/EDA%20GitHub.png "Salesforce Education Data Architecture")

Education Data Architecture (EDA) from [Salesforce.org](https://www.salesforce.org/) is an open-source managed package that standardizes the starting point for educational institutions building a CRM. Its data model supports the K–20 student journey—accounts and contacts, affiliations, relationships, academic programs, enrollments, courses, and related education objects—plus the automation, settings, and Health Check tools that keep that model consistent.

EDA is a Salesforce DX project (`sourceApiVersion` 52.0) with namespace **`hed`**. Install-time setup runs through `STG_InstallScript`. Trigger logic is table-driven (TDTM). Build, scratch org, and installer automation is defined in CumulusCI.

## Get EDA

The easiest way to get started is to sign up for a [trial](https://www.salesforce.org/trial/eda/). To install EDA in an existing Salesforce org, use the [EDA Installer](https://install.salesforce.org/products/eda).

The installer requires **My Domain**. It deploys the managed package and post-install unpackaged metadata (`customer_org` in `cumulusci.yml`).

## Repository layout

| Path | Role |
| --- | --- |
| `force-app/` | Packaged metadata (default SFDX package directory) |
| `force-app/main/default/` | Core objects, Apex, Aura, LWC settings, triggers |
| `force-app/main/tdtm/` | Table-Driven Trigger Management framework |
| `force-app/main/educationCloudSettings/` | Education Cloud Settings UI and product registry |
| `force-app/main/interoperability/` | Product registry services for other Education Cloud products |
| `force-app/main/releaseGating/` | Release gate APIs |
| `force-app/main/universalLearner/` | Universal learner-related metadata |
| `unpackaged/` | Org-only config: `pre`/`post` install, `config/dev`, QA, trial, translations, functional tests |
| `orgs/` | Scratch org definitions (`dev`, `qa`, `trial`, `regression`, …) |
| `robot/` | Browser and API Robot Framework tests |
| `documentation/automation.md` | CumulusCI flows, org types, and unpackaged deploy tasks |
| `cumulusci.yml` | Project config, tasks, flows, and MetaDeploy plans |

## Data model (high level)

EDA extends standard **Account**, **Contact**, **Lead**, **Opportunity**, and **Case**, and adds education-specific objects, including:

| Area | Custom objects (examples) |
| --- | --- |
| Affiliations & households | `Affiliation__c`, `Affl_Mappings__c`, `Relationship__c`, `Relationship_Lookup__c`, `Relationship_Auto_Create__c` |
| Addresses | `Address__c` (seasonal and default address automation) |
| Academic structure | `Course__c`, `Course_Offering__c`, `Course_Offering_Schedule__c`, `Course_Enrollment__c`, `Term__c`, `Term_Grade__c`, `Time_Block__c`, `Facility__c` |
| Programs | `Program_Enrollment__c`, `Program_Plan__c`, `Plan_Requirement__c` |
| Applications & credentials | `Application__c`, `Education_History__c`, `Academic_Certification__c`, `Credential__c`, `Attribute__c`, `Test__c`, `Test_Score__c` |
| Languages & behavior | `Language__c`, `Contact_Language__c`, `Attendance_Event__c`, `Behavior_Involvement__c`, `Behavior_Response__c` |
| Configuration | `Hierarchy_Settings__c` (org-wide EDA settings), `Error__c`, `Product_Registry__mdt` |

Account record types used throughout the product include Administrative, Household (`HH_Account`), Academic Program, Educational Institution, University Department, Business Organization, and Sports Organization.

Org-wide behavior is stored in **Hierarchy Settings** and edited from the **EDA Settings** Lightning app (`edaSettings` LWC and related Aura settings components). Health Check (`healthCheck*` LWCs) validates account model, affiliation mappings, and course connections.

## Trigger framework (TDTM)

EDA uses **Table-Driven Trigger Management**: one trigger per object (for example `TDTM_Contact`) that calls `TDTM_Global_API.run(...)`. Which Apex classes run, on which events, and in which order is stored in `Trigger_Handler__c` records.

Default handlers live in `TDTM_DefaultConfig`. On first install, `STG_InstallScript` loads those defaults via `TDTM_Global_API.setTdtmConfig(...)`. You can disable, reorder, or add handlers without changing trigger source. Custom or namespaced handlers should set `Owned_by_Namespace__c` appropriately so upgrades do not overwrite them.

Public entry points: `TDTM_Global_API.getTdtmConfig()`, `getDefaultTdtmConfig()`, and `setTdtmConfig()`.

## Local development

### Prerequisites

- [Salesforce CLI](https://developer.salesforce.com/tools/sfdxcli)
- [CumulusCI](https://cumulusci.readthedocs.io/) 3.74.0 or later (`minimum_cumulusci_version` in `cumulusci.yml`)
- Node.js and [Yarn](https://classic.yarnpkg.com/en/docs/install)
- A Dev Hub enabled for scratch orgs

### JavaScript tooling

```bash
yarn install
```

This installs Prettier (with `prettier-plugin-apex`), Husky, lint-staged, lockfile-lint, and LWC Jest.

Format Apex, LWC, Aura, and metadata XML to match this repo. Config is in `.prettierrc.yml`; ignored paths are in `.prettierignore`.

A pre-commit hook (`.huskyrc.json` → `scripts/pre-commit.sh`) runs Prettier checks on staged files and `lockfile-lint` on `yarn.lock`. If install fails, delete `node_modules` and run `yarn install` again.

### Scratch orgs with CumulusCI

Unmanaged development org:

```bash
cci org scratch dev mydev --default
cci flow run dev_org
cci org browser
```

Namespaced development org (`hed`):

```bash
cci org scratch dev_namespaced myns --default
cci flow run dev_org_namespaced
```

Common flows (see [documentation/automation.md](documentation/automation.md) for the full matrix):

| Flow | Use |
| --- | --- |
| `dev_org` / `dev_org_namespaced` | Deploy source and apply dev config, EDA settings, and extra users |
| `qa_org` | QA metadata and sample Apex setup |
| `net_new_org` | Latest beta as a new customer install |
| `upgraded_org` | Production → current beta push-upgrade simulation |
| `regression_org` | Upgraded org plus current-beta unpackaged metadata |
| `trial_org` | Trial template configuration |

After `dev_org`, install Apex is emulated (`unpackaged/config/install_emulator` + `execute_install_apex`) so TDTM handlers, affiliation mappings, and default Hierarchy Settings exist without a managed-package install.

## Testing

| Kind | How |
| --- | --- |
| Apex unit tests | `cci task run run_tests` in a configured scratch org |
| Unpackaged Apex (`*_UTST`) | `cci flow run run_unpackaged_tests` |
| Functional Apex (`*_FTST`) | `cci flow run run_functional_tests` (managed package installed) |
| LWC unit tests | `yarn test:unit` (`sfdx-lwc-jest`; see `jest.config.js`) |
| Robot Framework | `cci task run robot` — suites under `robot/EDA/tests/` |

## Contribute

1. Open an issue using the template in `.github/ISSUE_TEMPLATE.md`, or discuss in the [Trailblazer Community](https://trailhead.salesforce.com/trailblazer-community/groups/0F94S000000kHi4SAE). GitHub issues are intended for internal use; community questions belong in Trailblazer Community, and product ideas belong on [IdeaExchange](https://ideas.salesforce.com/s/search?filter=Education#t=All&sort=relevancy&f:@sfcategoryfull=[Education%7CEducation%20Data%20Architecture]).
2. Fork and branch from `main`.
3. Keep formatting consistent with Prettier; do not skip the pre-commit hook.
4. Add or update Apex, LWC Jest, or Robot coverage for the behavior you change.
5. Open a pull request using `.github/PULL_REQUEST_TEMPLATE.md` (critical changes, testing notes, new or deleted metadata).

## Learn more

- [Ask questions or get help](https://trailhead.salesforce.com/trailblazer-community/groups/0F94S000000kHi4SAE)
- [Feature requests (IdeaExchange)](https://ideas.salesforce.com/s/search?filter=Education#t=All&sort=relevancy&f:@sfcategoryfull=[Education%7CEducation%20Data%20Architecture])
- [Open bugs](https://github.com/SalesforceFoundation/EDA/labels/bug)
- [Release notes and beta releases](https://github.com/SalesforceFoundation/EDA/releases)
- [CumulusCI automation notes](documentation/automation.md)

## Meta

The Education Data Architecture technology (“EDA”) is an open-source package licensed by Salesforce.org (“SFDO”) under the BSD-3 Clause License, found at https://opensource.org/licenses/BSD-3-Clause. ANY MASTER SUBSCRIPTION AGREEMENT YOU OR YOUR ENTITY MAY HAVE WITH SFDO DOES NOT APPLY TO YOUR USE OF EDA. EDA IS PROVIDED “AS IS” AND AS AVAILABLE, AND SFDO MAKES NO WARRANTY OF ANY KIND REGARDING EDA, WHETHER EXPRESS, IMPLIED, STATUTORY OR OTHERWISE, INCLUDING BUT NOT LIMITED TO ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, FREEDOM FROM DEFECTS OR NON-INFRINGEMENT, TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW.
SFDO WILL HAVE NO LIABILITY ARISING OUT OF OR RELATED TO YOUR USE OF EDA FOR ANY DIRECT DAMAGES OR FOR ANY LOST PROFITS, REVENUES, GOODWILL OR INDIRECT, SPECIAL, INCIDENTAL, CONSEQUENTIAL, EXEMPLARY, COVER, BUSINESS INTERRUPTION OR PUNITIVE DAMAGES, WHETHER AN ACTION IS IN CONTRACT OR TORT AND REGARDLESS OF THE THEORY OF LIABILITY, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGES OR IF A REMEDY OTHERWISE FAILS OF ITS ESSENTIAL PURPOSE. THE FOREGOING DISCLAIMER WILL NOT APPLY TO THE EXTENT PROHIBITED BY LAW. SFDO DISCLAIMS ALL LIABILITY AND INDEMNIFICATION OBLIGATIONS FOR ANY HARM OR DAMAGES CAUSED BY ANY THIRD-PARTY HOSTING PROVIDERS.

(Release 244)
