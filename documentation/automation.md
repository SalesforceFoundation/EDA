# EDA Automation

## Key Workflows

| Workflow                  | Flow                 | Org Type         | Managed | Namespace |
|---------------------------|----------------------|------------------|---------|-----------|
| Development               | `dev_org`            | `dev`            |         |           |
| Development (Namespaced)  | `dev_org_namespaced` | `dev_namespaced` |         | ✔         |
| QA                        | `qa_org`             | `dev`            |         |           |
| Regression                | `regression_org`     | `release`        | ✔       |           |
| Regression (Push Upgrade) | `upgraded_org`       | `release`        | ✔       |           |
| Latest Trial Template     | N/A                  | `trial`          | ✔       |           |
| Upgraded Org              | `upgraded_org`       | `release`        | ✔       |           |
| Net New Org               | `net_new_org`        | `release`        | ✔       |           |

### Testing Scenarios

#### Regression testing

##### Regression Testing EDA Beta on an Upgraded Org with All Metadata Configurations:

    git checkout master
    git pull
    cci org scratch release <orgname> --default
    cci flow run regression_org 
    cci org browser <orgname>

##### Regression Testing EDA Beta on a Net-New Org:

    git checkout master
    git pull
    cci org scratch release <orgname> --default
    cci flow run net_new_org
    cci org browser <orgname>

##### Regression Testing EDA Beta on an Existing Customer Org:

    git checkout master
    git pull
    cci org scratch release <orgname> --default
    cci flow run upgraded_org 
    cci org browser <orgname>

## Utility Tasks and Flows

-   **`edaectomy`:** Removes configuration and unmanaged metadata.

-   **`setup_encryption`:** Sets up Shield Platform Encryption in the target Org. It is recommended that this flow be run in developer scratch orgs only.

-   **`regression_org`** Simulates an EDA org upgraded from the latest production release to the current beta and its dependencies, using the unpackaged metadata from the current beta. Use this when you want an upgraded org without needing to make any manual configurations.

-   **`net_new_org`** Simulates the creation of a new EDA org for a new customer, installing the latest beta of EDA and dependencies. Use this when you want a fully configured regression environment that matches a new installation.

-   **`upgraded_org`** Simulates a push upgrade of EDA and dependencies to existing customer orgs, from the latest production release to the current beta. This means all push-upgradable components have been updated, but only the unpackaged metadata from the previous version will exist in the org (and not the unpackaged metadata from the current beta.) Use this when you want to see which manual configuration steps are required in order for existing customers to use new functionality.

-   **`translations`** Enables platform encrpyted languages and sets specific languages to active. This flow will enable the platfrom encryption languages first, then deploy the given langauges with any translation file present. 

### Tasks

-   **`execute_install_apex`:** Runs most of the install script methods from STG<sub>InstallScript</sub> class.

-   **`delete_dev_config`:** Deploys metadata found under `unpackaged/config/dev_delete` Removes the Record type visibilities, page layout assignments Required to remove an installed beta.

## Unpackaged Metadata

Unpackaged directory structure:

    unpackaged/config
    ├── analytics
    ├── dev
    ├── dev_delete
    ├── qa
    └── spe

Each directory is used as follows:

| Directory           | Purpose                                 | Deploy task                 | Retrieve task         |
|---------------------|-----------------------------------------|-----------------------------|-----------------------|
| `config/analytics`  | Einstein Analytics R&A templates        | `deploy_einstein_templates` |                       |
| `config/dev`        | Development metadata                    | `deploy_dev_config`         | `retrieve_config_dev` |
| `config/dev_delete` | Deletes development metadata            | `delete_dev_config`         |                       |
| `config/qa`         | QA metadata                             | `deploy_qa_config`          | `retrieve_qa_config`  |
| `config/spe`        | "Manage Encryption Keys" permission set | `deploy_encryption_permset` |                       |
