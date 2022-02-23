![Salesforce Education Data Architecture](https://github.com/SalesforceFoundation/EDA/blob/main/EDA%20GitHub.png "Salesforce Education Data Architecture")

Education Data Architecture (EDA) from <a href="http://salesforce.org/" target="_blank">Salesforce.org</a> standardizes the starting point for educational institutions building a CRM. Its core and common data model supports the entire K-20 student journey and its open-source architecture allows anyone to view the source code in GitHub. EDA is developed in close collaboration with our customers, partners, and the K-20 community to foster common acceptance. Solutions built on EDA share an open and flexible, extensible framework that accommodates a range of use cases and end-user customization. With EDA, you get a standardized data model—including preconfigured objects, functionality, logic, and automation—tailored for education right out of the box.

The EDA framework, supported by the Salesforce Platform, can serve as the foundation for managing data and data relationships across your entire institution. We welcome your feedback and contributions to EDA. 

## Get EDA

The easiest way to get started with EDA is to sign up for a <a href="https://www.salesforce.org/trial/eda/" target="_blank">trial</a>. If you need to install EDA in an existing Salesforce org, use the <a href="https://install.salesforce.org/products/eda" target="_blank">EDA Installer</a>. See <a href="https://powerofus.force.com/s/article/EDA-Install-and-Configure" target="_blank">Install EDA</a> for more information.

## Contribute to EDA

Use a code formatter, like Prettier, to ensure that code you contribute to EDA is formatted consistent with the EDA code base. 

### Install a package manager

Make sure `yarn` is installed on your local machine. For more information, check <a href="https://classic.yarnpkg.com/en/docs/install/#mac-stableA" target="_blank">yarn installation</a>.

### Install dependency packages

 Use a CLI to install dependency packages in your local repo:

 ```
 yarn install
 ```

 If you’re using Prettier, these dependency packages will be installed to your local repo: prettier, prettier-plugin-apex, husky, and lint-staged.

 ### Configure your code formatter

 Configure your code formatter, as needed. For example, customize Prettier configurations in `prettierrc.yml` or specify code for Prettier to ignore in `.prettierignore`.

 ### Bypass pre-commit hook

 Pre-commit hooks help ensure the quality of code, but if you need to bypass them, append `--no-verify` to git commit or use a similar commit option for your GUI clients.

 ### Troubleshoot errors

 If you encounter errors, remove the node_modules folder and run `yarn install` again.

## Learn More

* <a href="https://trailhead.salesforce.com/trailblazer-community/groups/0F94S000000kHi4SAE" target="_blank">Ask questions or get help</a>
* <a href="https://ideas.salesforce.com/s/search?filter=Education#t=All&sort=relevancy&f:@sfcategoryfull=[Education%7CEducation%20Data%20Architecture]" target="_blank">Feature Request</a>
* <a href="https://powerofus.force.com/EDA-Documentation" target="_blank">User Documentation</a>
* Check out existing <a href="https://github.com/SalesforceFoundation/EDA/labels/bug" target="_blank">bugs</a> and <a href="https://trailblazer.salesforce.com/ideaSearch?filter=Education+%3E+Education+Data+Architecture" target="_blank">feature and enhancement requests</a>
* <a href="https://github.com/SalesforceFoundation/EDA/releases" target="_blank">Release Notes and Beta Releases</a>
* Learn about EDA objects and fields, see <a href="https://powerofus.force.com/EDA_Data_Dictionary" target="_blank">EDA Data Dictionary</a>.

## Meta

The Education Data Architecture technology (“EDA”) is an open-source package licensed by Salesforce.org (“SFDO”) under the BSD-3 Clause License, found at https://opensource.org/licenses/BSD-3-Clause. ANY MASTER SUBSCRIPTION AGREEMENT YOU OR YOUR ENTITY MAY HAVE WITH SFDO DOES NOT APPLY TO YOUR USE OF EDA. EDA IS PROVIDED “AS IS” AND AS AVAILABLE, AND SFDO MAKES NO WARRANTY OF ANY KIND REGARDING EDA, WHETHER EXPRESS, IMPLIED, STATUTORY OR OTHERWISE, INCLUDING BUT NOT LIMITED TO ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, FREEDOM FROM DEFECTS OR NON-INFRINGEMENT, TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW.
SFDO WILL HAVE NO LIABILITY ARISING OUT OF OR RELATED TO YOUR USE OF EDA FOR ANY DIRECT DAMAGES OR FOR ANY LOST PROFITS, REVENUES, GOODWILL OR INDIRECT, SPECIAL, INCIDENTAL, CONSEQUENTIAL, EXEMPLARY, COVER, BUSINESS INTERRUPTION OR PUNITIVE DAMAGES, WHETHER AN ACTION IS IN CONTRACT OR TORT AND REGARDLESS OF THE THEORY OF LIABILITY, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGES OR IF A REMEDY OTHERWISE FAILS OF ITS ESSENTIAL PURPOSE. THE FOREGOING DISCLAIMER WILL NOT APPLY TO THE EXTENT PROHIBITED BY LAW. SFDO DISCLAIMS ALL LIABILITY AND INDEMNIFICATION OBLIGATIONS FOR ANY HARM OR DAMAGES CAUSED BY ANY THIRD-PARTY HOSTING PROVIDERS.