import os
import tempfile

from pathlib import Path
from cumulusci.salesforce_api.metadata import ApiRetrieveUnpackaged
from cumulusci.core.exceptions import TaskOptionsError
from cumulusci.core.utils import process_bool_arg
from cumulusci.tasks.salesforce import Deploy
from cumulusci.utils import CUMULUSCI_PATH
from cumulusci.utils import elementtree_parse_file


class UpdateProfile(Deploy):
    name = "UpdateProfile"

    task_options = {
        "package_xml": {
            "description": "Override the default package.xml file for retrieving the Admin.profile and all objects and classes that need to be included by providing a path to your custom package.xml"
        },
        "record_types": {
            "description": "A list of dictionaries containing the required key `record_type` with a value specifying the record type in format <object>.<developer_name>.  Record type names can use the token strings {managed} and {namespaced_org} for namespace prefix injection as needed.  By default, all listed record types will be set to visible and not default.  Use the additional keys `visible`, `default`, and `person_account_default` set to true/false to override.  NOTE: Setting record_types is only supported in cumulusci.yml, command line override is not supported."
        },
        "managed": {
            "description": "If True, uses the namespace prefix where appropriate.  Use if running against an org with the managed package installed.  Defaults to False"
        },
        "namespaced_org": {
            "description": "If True, attempts to prefix all unmanaged metadata references with the namespace prefix for deployment to the packaging org or a namespaced scratch org.  Defaults to False"
        },
        "profile_name": {
            "description": "Name of the Profile to target for updates.",
            "default": "Admin",
        },
    }

    namespaces = {"sf": "http://soap.sforce.com/2006/04/metadata"}

    def _init_options(self, kwargs):
        super(UpdateProfile, self)._init_options(kwargs)

        self.options["managed"] = process_bool_arg(self.options.get("managed", False))

        self.options["namespaced_org"] = process_bool_arg(
            self.options.get("namespaced_org", False)
        )

        # For namespaced orgs, managed should always be True
        if self.options["namespaced_org"]:
            self.options["managed"] = True

        # Set up namespace prefix strings
        namespace_prefix = "{}__".format(
            self.project_config.project__package__namespace
        )
        self.namespace_prefixes = {
            "managed": namespace_prefix if self.options["managed"] else "",
            "namespaced_org": namespace_prefix
            if self.options["namespaced_org"]
            else "",
        }

        self.profile_name = self.options.get("profile_name") or "Admin"

    def _run_task(self):
        self.retrieve_dir = None
        self.deploy_dir = None
        with tempfile.TemporaryDirectory() as tempdir:
            self._create_directories(tempdir)
            self._retrieve_unpackaged()
            self._process_metadata()
            self._deploy_metadata()

    def _create_directories(self, tempdir):
        self.retrieve_dir = Path(tempdir, "retrieve")
        self.deploy_dir = Path(tempdir, "deploy")
        self.retrieve_dir.mkdir()
        self.deploy_dir.mkdir()

    def _get_retrieve_package_xml_content(self):
        path = self.options.get("package_xml") or os.path.join(
            CUMULUSCI_PATH, "cumulusci", "files", "admin_profile.xml"
        )
        with open(path, "r") as f:
            package_xml_content = f.read()

        package_xml_content = package_xml_content.format(
            **self.namespace_prefixes, profile_name=self.profile_name
        )

        return package_xml_content

    def _retrieve_unpackaged(self):
        self.logger.info(
            "Retrieving metadata using {}".format(
                self.options.get("package_xml", "default package.xml")
            )
        )
        api_retrieve = ApiRetrieveUnpackaged(
            self,
            self._get_retrieve_package_xml_content(),
            self.project_config.project__package__api_version,
        )
        unpackaged = api_retrieve()
        unpackaged.extractall(self.retrieve_dir)

    def _process_metadata(self):
        self.logger.info(f"Processing retrieved metadata in {self.retrieve_dir}")
        path = self.retrieve_dir / "profiles" / f"{self.profile_name}.profile"
        self.tree = elementtree_parse_file(path)

        self._set_apps_visible()
        self._set_classes_enabled()
        self._set_fields_editable()
        self._set_fields_readable()
        self._set_pages_enabled()
        self._set_tabs_visibility()
        self._set_record_types()

        self.tree.write(
            path, "utf-8", xml_declaration=True, default_namespace=self.namespaces["sf"]
        )

    def _set_apps_visible(self):
        xpath = ".//sf:applicationVisibilities[sf:visible='false']"
        for elem in self.tree.findall(xpath, self.namespaces):
            elem.find("sf:visible", self.namespaces).text = "true"

    def _set_classes_enabled(self):
        xpath = ".//sf:classAccess[sf:enabled='false']"
        for elem in self.tree.findall(xpath, self.namespaces):
            elem.find("sf:enabled", self.namespaces).text = "true"

    def _set_fields_editable(self):
        xpath = ".//sf:fieldPermissions[sf:editable='false']"
        for elem in self.tree.findall(xpath, self.namespaces):
            elem.find("sf:editable", self.namespaces).text = "true"

    def _set_fields_readable(self):
        xpath = ".//sf:fieldPermissions[sf:readable='false']"
        for elem in self.tree.findall(xpath, self.namespaces):
            elem.find("sf:readable", self.namespaces).text = "true"

    def _set_pages_enabled(self):
        xpath = ".//sf:pageAccesses[sf:enabled='false']"
        for elem in self.tree.findall(xpath, self.namespaces):
            elem.find("sf:enabled", self.namespaces).text = "true"

    def _set_record_types(self):
        record_types = self.options.get("record_types") or []

        # If defaults are specified,
        # clear any pre-existing defaults
        if any("default" in rt for rt in record_types):
            for default in ("sf:default", "sf:personAccountDefault"):
                xpath = ".//sf:recordTypeVisibilities/{}".format(default)
                for elem in self.tree.findall(xpath, self.namespaces):
                    elem.text = "false"

        # Set recordTypeVisibilities
        for rt in record_types:
            # Replace namespace prefix tokens in rt name
            rt_prefixed = rt["record_type"].format(**self.namespace_prefixes)

            # Look for the recordTypeVisiblities element
            xpath = ".//sf:recordTypeVisibilities[sf:recordType='{}']".format(
                rt_prefixed
            )
            elem = self.tree.find(xpath, self.namespaces)
            if elem is None:
                raise TaskOptionsError(
                    f"Record Type {rt['record_type']} not found in retrieved {self.profile_name}.profile"
                )

            # Set visibile
            elem.find("sf:visible", self.namespaces).text = str(
                rt.get("visible", "true")
            ).lower()

            # Set default
            elem.find("sf:default", self.namespaces).text = str(
                rt.get("default", "false")
            ).lower()

            # Set person account default if element exists
            pa_default = elem.find("sf:personAccountDefault", self.namespaces)
            if pa_default is not None:
                pa_default.text = str(rt.get("person_account_default", "false")).lower()

    def _set_tabs_visibility(self):
        xpath = ".//sf:tabVisibilities[sf:visibility='Hidden']"
        for elem in self.tree.findall(xpath, self.namespaces):
            elem.find("sf:visibility", self.namespaces).text = "DefaultOn"

    def _get_deploy_package_xml_content(self):
        return f"""<?xml version="1.0" encoding="UTF-8"?><Package xmlns="http://soap.sforce.com/2006/04/metadata">
        <types><members>{self.profile_name}</members><name>Profile</name></types><version>39.0</version></Package>
        """

    def _deploy_metadata(self):
        self.logger.info(
            f"Deploying updated {self.profile_name}.profile from {self.deploy_dir}"
        )

        target_profile_xml = Path(self.deploy_dir, "package.xml")
        target_profile_xml.write_text(self._get_deploy_package_xml_content())

        retrieved_profile_dir = Path(self.retrieve_dir, "profiles")
        target_profile_dir = Path(self.deploy_dir, "profiles")
        retrieved_profile_dir.replace(target_profile_dir)

        api = self._get_api(path=self.deploy_dir)
        return api()


UpdateAdminProfile = UpdateProfile
