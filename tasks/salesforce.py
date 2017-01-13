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

task_options = BaseUpdateAdminProfile.task_options.copy()
task_options['skip_record_types'] = {
    'description': 'If True, setting record types will be skipped.  This is necessary when deploying to packaging as the ci_master flow does not deploy unpackaged/post.',
    'required': True,
}

class UpdateAdminProfile(BaseUpdateAdminProfile):

    task_options = task_options

    def _init_options(self, **kwargs):
        super(UpdateAdminProfile)._init_options(**kwargs)
        if 'skip_record_types' not in self.options:
            self.options['skip_record_types'] = False
        if self.options['skip_record_types'] == 'False':
            self.options['skip_record_types'] = False
        
    def _process_metadata(self):
        super(UpdateAdminProfile, self)._process_metadata()
       
        if self.options['skip_record_types']:
            return
 
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
