from cumulusci.tasks.salesforce import BaseSalesforceTask

class TestTask(BaseSalesforceTask):
    def __call__(self):
        self.logger.info('testing')
