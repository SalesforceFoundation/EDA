![Salesforce Higher Education Data Architecture](https://cloud.githubusercontent.com/assets/1894238/13441500/13d366ec-dfbd-11e5-9df6-d9dee50ce87d.jpg "Salesforce Higher Education Data Architecture")

The Salesforce Higher Education Data Architecture (HEDA) Project (HEDAP) provides an Higher-Ed-specific platform for growth for organizations utilizing Salesforce.  HEDA utilizes a Salesforce managed package and some light unmanaged customization to give Higher Education users a familiar nomenclature and data model for many higher education applications.  In addition, Higher Education developers and administrators can utilize HEDA's advanced trigger management capabilities, robust error handling and pluggable framework to better manage and coordinate the data in their Salesforce instance.

HEDA is built from industry-wide best practices used across higher education and the Salesforce ecosystem and we welcome feedback and contributions for the project. See below for more information on how to get involved.

#### Try it out

You can install HEDA utilizing our custom application installer into any Developer Edition, Sandbox or Enterprise Edition Salesforce org.

* <a href="https://mrbelvedere.salesforcefoundation.org/mpinstaller/hed" target="_blank">HEDA Installer</a>
* <a href="https://mrbelvedere.salesforcefoundation.org/mpinstaller/hed/beta" target="_blank">HEDA BETA Installer</a>

#### For Developers

The Higher Education Data Architecture is released under the open source BSD license (see link below for additional license information).  Contributions (code and otherwise) are welcome and encouraged.  You can fork this repository and deploy the unmanaged version of the code into a Salesforce org of your choice.  

* Fork the repository by clicking on the "Fork" button in the upper-righthand corner.  This creates your own copy of HEDA for your Github user.
* Clone your fork to your local machine via the command line
```sh
$ git clone https://github.com/YOUR-USERNAME/hedap.git
```
* You now have a local copy on your machine.  HEDAP has some built-in scripts to make deploying to your Salesforce org easier.  Utilizing ant and the Force.com Migration tool, you can push your local copy of HEDAP to the org of your choice.  You'll need to provide a build.properties to tell ant where to deploy.  An example file might look like:

```
sf.username= YOUR_ORG_USERNAME
sf.password = YOUR_ORG_PASSWORD
sf.serverurl = https://login.salesforce.com ##or test.salesforce.com for sandbox environments
sf.maxPoll = 20
```

* Now deploy to your org utilizing ant (note: you may need to deploy CumulusCI to your local machine to utilize the built-in scripts)

```sh
$ cd hedap
$ ant deploy -buildfile PATH_TO_YOUR_BUILDFILE
```

* Full ApexDoc code documentation can be found <a href="http://developer.salesforce.org/HEDAP/ApexDocumentation/" target="_blank">here</a>.

#### Meta

Released under the [BSD 3-Clause License](http://www.opensource.org/licenses/BSD-3-Clause).
