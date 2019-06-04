EDA Automation
==============


Key Tasks
------------------

### `update_admin_profile`
  Modified - On “deployment” this assigns the record type visibilities.


### `deploy_dev_config`
  Deploys metadata found under `unpackaged/config/dev`
  On deployment this assigns the page layouts, tab visibilities for Admin, and sets EDA App as default for Admin, and also sets the EDA App as available in Lightning
  * Accepts 'managed' option (Boolean)

### `deploy_qa_config`
  Deploys metadata found under `unpackaged/config/qa`
  This includes  additional page layouts, tabs, and other metadata.
  * Accepts 'managed' option (Boolean)


### `delete_dev_config`
  Deploys metadata found under `unpackaged/config/dev_delete`
  Removes the Record type visibilities, page layout assignments
  Required to remove an installed beta

### `execute_install_apex`
  Runs most of the install script methods from STG_InstallScript class


Key Flows
------------------

### `edaectomy`
  Removes configuration and unmanaged metadata.


### `dev_org`
  Modified - Deploys Dev configiguration and runs some post-install methods as the final tasks.


### `qa_org`
  Deploys Dev and additional QA configiguration for testing.

### `regression_org`
  Installs the latest beta release and deploys Dev and additional QA configiguration for regression testing.
