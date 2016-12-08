import os
from cumulusci.tasks.salesforce import UpdateAdminProfile as BaseUpdateAdminProfile
from cumulusci.utils import findReplace
from cumulusci.utils import findReplaceRegex

rt_visibility_template = """
<recordTypeVisibilities>
    <default>{}</default>
    <personAccountDefault>true</personAccountDefault>
    <recordType>{}</recordType>
    <visible>true</visible>
</recordTypeVisibilities>
"""

class UpdateAdminProfile(BaseUpdateAdminProfile):
        
    def _process_metadata(self):
        super(UpdateAdminProfile, self)._process_metadata()
        
        # Strip record type visibilities
        findReplaceRegex(
            '<recordTypeVisibilities>([^\$]+)</recordTypeVisibilities>',
            '',
            os.path.join(self.tempdir, 'profiles'),
            'Admin.profile'
        )
        
        # Set record type visibilities
        self._set_record_type('Course_Enrollment__c.Default', 'false')
        self._set_record_type('Course_Enrollment__c.Faculty', 'false')
        self._set_record_type('Course_Enrollment__c.Student', 'true')

    def _set_record_type(self, name, default):
        rt = rt_visibility_template.format(default, name)
        findReplace(
            '<tabVisibilities>',
            '{}<tabVisibilities>'.format(rt),
            os.path.join(self.tempdir, 'profiles'),
            'Admin.profile',
            max=1,
        )
