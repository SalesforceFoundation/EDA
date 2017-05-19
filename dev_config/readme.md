
Developer Configuration Tasks
============================

Goal
----
To automate the [HEDA configuration](https://powerofus.force.com/articles/Resource/Install-and-Configure-the-Higher-Education-Data-Architecture-HEDA) and to reverse it so a Beta can be removed.


New/Modified tasks
------------------

### `update_admin_profile`
  Modified - On “deployment” this assigns the record type visibilities.


### `deploy_dev_config`
  Deploys metadata found under /src/admin_config
  On “deployment” this assigns the page layouts, tab visibilities for Admin, and sets HEDA App as default for Admin, and also sets the HEDA App as available in Lightning
  * Accepts 'managed' option (Boolean)


### `delete_dev_config`
  Deploys metadata found under /delete
  Removes the Record type visibilities, page layout assignments
  Required to remove an installed beta

### `execute_install_apex`
  Runs most of the install script methods from STG_InstallScript class

### `execute_install_apex_managed`
  Runs most of the install script methods from STG_InstallScript class for Managed code

New/Modified Flows
------------------

### `hedaectomy`
  Removes the config and non-managed HEDA metadata


### `ci_beta_install`
  Modified - First will attempt to run `delete_dev_config` ignoring failures to remove previous Dev configuration. Finally deploys DEV config as last task


### `dev_org`
  Modified - Deploys DEV config as last task


### `install_beta`
  Modified - Deploys DEV config as last task
