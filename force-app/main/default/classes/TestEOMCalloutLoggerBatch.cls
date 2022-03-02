@isTest
public class TestEOMCalloutLoggerBatch {
    @isTest
    static void batchTest() {
        Callout_Logger__c calloutLogger = new Callout_Logger__c(
            Service__c = 'HEROKU_SAP4HANA__BILLING_DATA',
            RecordId__c = 'test'
        );
        insert calloutLogger;

        EndOfMonthHeader__c eom = new EndOfMonthHeader__c(
            ext_order_id__c = 'test',
            id_session_bigint__c = 'test1'
        );
        insert eom;

        Test.startTest();

        Database.executeBatch(new EOMCalloutLoggerBatch());

        Test.stopTest();

        Callout_Logger__c queriedCL = [SELECT Related_EOM__c FROM Callout_Logger__c WHERE Id =: calloutLogger.Id];

        System.assertEquals(eom.Id, queriedCL.Related_EOM__c);
    }
}