@isTest
public with sharing class ScheduleTest {
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    static testmethod void testScheduledJob() {
        String jobId = System.schedule('ScheduledApexTest',
        CRON_EXP, 
        new WarehouseSyncSchedule());
        
        System.assertEquals([SELECT Id from AsyncApexJob where JobType in ('BatchApexWorker','ScheduledApex')].size(), 
            1, 
            'Schedule job is not running');
    }
}
