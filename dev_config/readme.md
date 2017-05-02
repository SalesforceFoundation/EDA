
Developer Confguration Tasks
============================

Goal
----
To automate the [HEDA configuration](https://powerofus.force.com/articles/Resource/Install-and-Configure-the-Higher-Education-Data-Architecture-HEDA) and to reverse it so a Beta can be removed.


New/Modified tasks
------------------

### `update_admin_profile`
  Modified - On “deployment” this assigns the record type visibilities.


### `deploy_dev_config`
  On “deployment” this assigns the page layouts and tab visibilities
  Accepts 'managed' option


### `delete_dev_config`
  Removes the Record type visibilities, page layout assignments
  Required to remove an installed beta


New/Modified Flows
------------------

### `hedaectomy`
  Removes the config and non-managed HEDA metadata


### `ci_beta_install`
  Deploys DEV config as last task
  You'll need to run delete_dev_config if re-running this on a persistent org


### `dev_org`
  Deploys DEV config as last task


### `install_beta`
  Deploys DEV config as last task


## Still to do
Execute APEX to run some basic install script tasks - [W-018513](https://foundation--agf.na6.visual.force.com/apex/adm_userstorydetail?id=a2x800000006VadAAE&sfdc.override=1)


