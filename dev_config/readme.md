
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
  Accepts 'managed' option depending on usage


### `delete_dev_config`
  Deploys metadata found under /delete
  Removes the Record type visibilities, page layout assignments
  Required to remove an installed beta


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


## Still to do
- Execute APEX to run some basic install script tasks - [W-018513](https://foundation--agf.na6.visual.force.com/apex/adm_userstorydetail?id=a2x800000006VadAAE&sfdc.override=1)
