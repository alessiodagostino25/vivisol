@isTest
public class TestBatchToDeleteOldCalloutLogger {
    
    @isTest
    static void testScheduledJob() {
        Callout_Logger__c calloutlogger1 = new Callout_Logger__c();
        calloutlogger1.Timestamp__c = Date.today();
        insert calloutlogger1;
        
        Callout_Logger__c calloutlogger2 = new Callout_Logger__c();
        calloutlogger2.Timestamp__c = Date.today().addDays(-7);
        insert calloutlogger2;
        
        Test.startTest();
        BatchToDeleteOldCalloutLogger.activateSchedule('ScheduleName', 5);   
        Test.stopTest();
        List<CronTrigger> cronTriggerList = [SELECT Id FROM CronTrigger];
        system.assert(cronTriggerList.size()>0);
    }
    
    @isTest
    static void testBatch() {
        Callout_Logger__c calloutlogger1 = new Callout_Logger__c();
        calloutlogger1.Timestamp__c = Date.today();
        insert calloutlogger1;
        
        Callout_Logger__c calloutlogger2 = new Callout_Logger__c();
        calloutlogger2.Timestamp__c = Date.today().addDays(-7);
        insert calloutlogger2;
        
        Test.startTest();
        BatchToDeleteOldCalloutLogger testClass = new BatchToDeleteOldCalloutLogger(5);
        Database.executeBatch(testClass);   
        Test.stopTest();
        List <Callout_Logger__c> calloutloggerlist = [Select id from Callout_Logger__c];
        system.assertEquals(1, calloutloggerlist.size(), 'calloutloggerlist size');
	}
    
    @isTest
    static void testBatch2() {
        Callout_Logger__c calloutlogger1 = new Callout_Logger__c();
        calloutlogger1.Timestamp__c = Date.today();
        insert calloutlogger1;
        
        Callout_Logger__c calloutlogger2 = new Callout_Logger__c();
        calloutlogger2.Timestamp__c = Date.today().addDays(-1);
        insert calloutlogger2;
        
        Test.startTest();
        BatchToDeleteOldCalloutLogger testClass = new BatchToDeleteOldCalloutLogger(5);
        Database.executeBatch(testClass);   
        Test.stopTest();
        List <Callout_Logger__c> calloutloggerlist = [Select id from Callout_Logger__c];
        system.assertEquals(2, calloutloggerlist.size(), 'calloutloggerlist size');
	}
    
    @isTest
    static void testBatch3() {
        Callout_Logger__c calloutlogger1 = new Callout_Logger__c();
        calloutlogger1.Timestamp__c = Date.today().addDays(-7);
        insert calloutlogger1;
        
        Callout_Logger__c calloutlogger2 = new Callout_Logger__c();
        calloutlogger2.Timestamp__c = Date.today().addDays(-12);
        insert calloutlogger2;
        
        Test.startTest();
        BatchToDeleteOldCalloutLogger testClass = new BatchToDeleteOldCalloutLogger(5);
        Database.executeBatch(testClass);   
        Test.stopTest();
        List <Callout_Logger__c> calloutloggerlist = [Select id from Callout_Logger__c];
        system.assertEquals(0, calloutloggerlist.size(), 'calloutloggerlist size');
	}

}