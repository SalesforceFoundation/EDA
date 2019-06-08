import os
from cumulusci.core.utils import process_bool_arg
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
task_options['namespaced_org'] = {
    'description': 'If True, attempts to prefix all unmanaged metadata references with the namespace prefix for deployment to the packaging org or a namespaced scratch org',
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
        self.options['skip_record_types'] = process_bool_arg(
            self.options.get('skip_record_types', False)
        )
        self.options['managed'] = process_bool_arg(
            self.options.get('managed', False)
        )
        self.options['namespaced_org'] = process_bool_arg(
            self.options.get('namespaced_org', False)
        )
        # For namespaced orgs, managed should always be True
        if self.options['namespaced_org']:
            self.options['managed'] = True

        # Set up namespace prefix strings
        namespace_prefix = '{}__'.format(self.project_config.project__package__namespace)
        self.namespace_prefix = namespace_prefix if self.options['managed'] else ''
        self.namespaced_org_prefix = namespace_prefix if self.options['namespaced_org'] else ''

        
    def _process_metadata(self):
        super(UpdateAdminProfile, self)._process_metadata()
       
        # Strip record type visibilities
        findReplaceRegex(
            '<recordTypeVisibilities>([^\$]+)</recordTypeVisibilities>',
            '',
            os.path.join(self.tempdir, 'profiles'),
            'Admin.profile'
        )

        namespace_args = {
            'managed': self.namespace_prefix,
            'namespaced_org': self.namespaced_org_prefix,
        }
        
        # Set record type visibilities for Accounts
        self._set_record_type(
            'Account.{namespaced_org}Administrative'.format(**namespace_args),
            'true',
        )
        self._set_record_type(
            'Account.{namespaced_org}Academic_Program'.format(**namespace_args),
            'false',
        )
        self._set_record_type(
            'Account.{namespaced_org}Business_Organization'.format(**namespace_args),
            'false',
        )
        self._set_record_type(
            'Account.{namespaced_org}Educational_Institution'.format(**namespace_args),
            'false',
        )
        self._set_record_type(
            'Account.{namespaced_org}HH_Account'.format(**namespace_args),
            'false',
        )
        self._set_record_type(
            'Account.{namespaced_org}Sports_Organization'.format(**namespace_args),
            'false',
        )
        self._set_record_type(
            'Account.{namespaced_org}University_Department'.format(**namespace_args),
            'false',
        )

        if self.options['skip_record_types']:
            return
 
        # Set record type visibilities for Course Connections
        self._set_record_type(
            '{managed}Course_Enrollment__c.{namespaced_org}Default'.format(**namespace_args),
            'false',
        )
        self._set_record_type(
            '{managed}Course_Enrollment__c.{namespaced_org}Faculty'.format(**namespace_args),
            'false',
        )
        self._set_record_type(
            '{managed}Course_Enrollment__c.{namespaced_org}Student'.format(**namespace_args),
            'true',
        )

        # Set record type visibilities for Attribute
        self._set_record_type(
            '{managed}Attribute__c.{namespaced_org}Credential'.format(**namespace_args),
            'true',
        )
        self._set_record_type(
            '{managed}Attribute__c.{namespaced_org}Student Characteristic'.format(**namespace_args),
            'false',
        )

    def _set_record_type(self, name, default):
        rt = rt_visibility_template.format(default, name)
        findReplace(
            '<tabVisibilities>',
            '{}<tabVisibilities>'.format(rt),
            os.path.join(self.tempdir, 'profiles'),
            'Admin.profile',
            max=1,
        )
