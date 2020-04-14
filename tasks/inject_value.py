import os
from cumulusci.tasks.util import FindReplace

from cumulusci.core.exceptions import TaskOptionsError
from cumulusci.tasks.salesforce import BaseSalesforceApiTask


class InjectMetaDataValue(BaseSalesforceApiTask):
    """This class is used for the injection of variables at run time."""

    task_options = {
        "path": {
            "description": "Metadata API version to use, if not project__package__api_version.",
            "required": True,
        },
        "find": {
            "description": "Value to be replaced with within a file",
            "required": True,
        },
        "env_var": {
            "description": "Represents the value to replace the find variable in the file",
            "required": False,
        },
        "literal_var": {
            "description": "Represents the value to replace the find variable in the file",
            "required": False,
        },
    }

    def _init_options(self, kwargs):
        super()._init_options(kwargs)

        self.api_version = (
            self.options.get("api_version")
            or self.project_config.project__package__api_version
        )

        if any(["path" not in self.options, "find" not in self.options]):
            raise TaskOptionsError("Please check your options passed in.")

        self.options["replace"] = f"{self.api_version}"

    def _run_task(self):
        task = FindReplace(self.project_config, self.task_config, self.org_config)
        task()
