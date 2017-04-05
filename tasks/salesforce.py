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
task_options['managed'] = {
    'description': 'If True, uses the namespace prefix where appropriate.  Use if running against an org with the managed package installed.  Defaults to False',
    'required': True,
}
task_options['skip_record_types'] = {
    'description': 'If True, setting record types will be skipped.  This is necessary when deploying to packaging as the ci_master flow does not deploy unpackaged/post.',
    'required': True,
}

#Used to set the record type visibilities
class UpdateAdminProfile(BaseUpdateAdminProfile):

    task_options = task_options

    def _init_options(self, kwargs):
        super(UpdateAdminProfile, self)._init_options(kwargs)
        if 'skip_record_types' not in self.options:
            self.options['skip_record_types'] = False
        if self.options['skip_record_types'] == 'False':
            self.options['skip_record_types'] = False
        if 'managed' not in self.options:
            self.options['managed'] = False
        if self.options['managed'] == 'False':
            self.options['managed'] = False
        
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
        namespace_prefix = ''
        if self.options['managed']:
            namespace_prefix = '{}__'.format(self.project_config.project__package__namespace)

        # Set record type visibilities for Course Connections
        self._set_record_type('{}Course_Enrollment__c.Default'.format(namespace_prefix), 'false')
        self._set_record_type('{}Course_Enrollment__c.Faculty'.format(namespace_prefix), 'false')
        self._set_record_type('{}Course_Enrollment__c.Student'.format(namespace_prefix), 'true')

        # Set record type visibilities for Accounts
        self._set_record_type('{}Account.Administrative'.format(namespace_prefix), 'true')
        self._set_record_type('{}Account.Academic_Program'.format(namespace_prefix), 'false')
        self._set_record_type('{}Account.Business_Organization'.format(namespace_prefix), 'false')
        self._set_record_type('{}Account.Educational_Institution'.format(namespace_prefix), 'false')
        self._set_record_type('{}Account.HH_Account'.format(namespace_prefix), 'false')
        self._set_record_type('{}Account.Sports_Organization'.format(namespace_prefix), 'false')
        self._set_record_type('{}Account.University_Department'.format(namespace_prefix), 'false')

    def _set_record_type(self, name, default):
        rt = rt_visibility_template.format(default, name)
        findReplace(
            '<tabVisibilities>',
            '{}<tabVisibilities>'.format(rt),
            os.path.join(self.tempdir, 'profiles'),
            'Admin.profile',
            max=1,
        )

#Used to reverse the changes to Admin profile.
class ClearAdminProfile(BaseUpdateAdminProfile):

    task_options = task_options

    def _init_options(self, kwargs):
        super(UpdateAdminProfile, self)._init_options(kwargs)
        if 'skip_record_types' not in self.options:
            self.options['skip_record_types'] = False
        if self.options['skip_record_types'] == 'False':
            self.options['skip_record_types'] = False
        if 'managed' not in self.options:
            self.options['managed'] = False
        if self.options['managed'] == 'False':
            self.options['managed'] = False
        
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
