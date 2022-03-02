@isTest
public class TestCalloutLogsCleaningBatch {
    @isTest
    static void batchTest() {
        List<Callout_Logger__c> toInsert = new List<Callout_Logger__c>();

        // Only one because the CalloutLoggerTrigger would do the work (pointless test)...

        for(Integer i = 0; i < 1; i++) {
            Callout_Logger__c calloutLogger = new Callout_Logger__c(
                RecordId__c = 'testRecordId',
                UUID_Flow__c = String.valueOf(i)
            );

            toInsert.add(calloutLogger);
        }

        insert toInsert;

        Test.startTest();

        Database.executeBatch(new CalloutLogsCleaningBatch(null, null, null));

        Test.stopTest();

        List<Callout_Logger__c> calloutLoggers = [SELECT Id FROM Callout_Logger__c WHERE RecordId__c = 'testRecordId'];

        System.assertEquals(1, calloutLoggers.size());
    }
}