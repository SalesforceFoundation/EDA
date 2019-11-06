import json
from cumulusci.tasks.salesforce import BaseSalesforceApiTask


class CheckPermSetLicenses(BaseSalesforceApiTask):
    task_options = {
        "permission_sets": {
            "description": "List of permission set names to check for, (ex: EinsteinAnalyticsUser)",
            "required": True,
        }
    }

    def _run_task(self):
        query = self._get_query()
        print(query)
        result = self.tooling.query(query)
        return result["size"] > 0

    def _get_query(self):
        where_targets = [f"'{name}'" for name in self.options["permission_sets"]]
        return f"""
        SELECT Name FROM PermissionSet WHERE Name IN ({','.join(where_targets)})
        """
