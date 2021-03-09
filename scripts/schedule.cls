public static void cancelScheduledJobs() {
    List<String> edaScheduledJobs =
        new List<String>{
            'Seasonal Addresses Update',
            'HEDA Async Apex Error Processing',
            'HEDA 90-day-old Error Cleaning'
        };

    List<CronJobDetail> edaCronJobDetailList = [
        SELECT Id,
        Name,
        JobType
        FROM CronJobDetail
        WHERE Name IN:edaScheduledJobs
    ];

    List<CronTrigger> edaCronTriggerList = [
        SELECT Id
        FROM CronTrigger
        WHERE CronJobDetailId IN: edaCronJobDetailList
    ];

    for(CronTrigger cronTrigger : edaCronTriggerList) {
        System.abortJob(cronTrigger.Id);
    }
}
