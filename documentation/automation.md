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

### Testing Scenarios

#### Regression testing

Regression testing the latest beta:

    git checkout master
    git pull
    cci org scratch release <orgname> --default
    cci flow run regression_org 
    cci org browser <orgname>

Regression Testing a Net New Org:

    git checkout master
    git pull
    cci org scratch release <orgname> --default
    cci flow run new_org
    cci org browser <orgname>

Testing an org that has been push upgraded from the latest release and has received the latest managed package from EDA (Represents an "Existing Org"):

    git checkout master
    git pull
    cci org scratch release <orgname> --default
    cci flow run upgraded_org 
    cci org browser <orgname>

## Utility Tasks and Flows

-   **`edaectomy`:** Removes configuration and unmanaged metadata.

-   **`setup_encryption`:** Sets up Shield Platform Encryption in the target Org. It is recommended that this flow be run in developer scratch orgs only.

-   **`regression_org`** 
simulates an org with the last production version of K-12 Kit upgraded with the latest Beta releases of K-12 Kit and its dependencies (EDA). Use this when you want a fully configured regression testing environment.

-   **`net_new_org`** simulates the creation of a new K-12 Kit org for a new customer with the latest betas of K-12 Kit and dependencies. Use this when you want to test in an environment that matches a new installation.

-   **`upgraded_org`** simulates a push upgrade of K-12 Kit  and dependencies to existing customer orgs. This means all push-upgradable components have been updated, but only the unpackaged metadata from the previous version will exist in the org. Use this when you want to see what steps are required for existing customers to use new functionality.

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