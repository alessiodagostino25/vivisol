@isTest
public class TestHerokuCalloutLoggerTrigger {
    @isTest
    static void insertAndDeleteTest() {
        List<Heroku_Callout_Logger__c> toInsert = new List<Heroku_Callout_Logger__c>();

        WorkOrder workOrder = TestDataFactory.createWorkOrder();
        workOrder.OrderExternalId__c = 'orderExternalId';
        insert workOrder;

        WorkOrder workOrder2 = TestDataFactory.createWorkOrder();
        workOrder2.OrderExternalId__c = 'orderExternalId1';
        insert workOrder2;

        WorkOrder workOrder3 = TestDataFactory.createWorkOrder();
        workOrder3.OrderExternalId__c = 'orderExternalId2';
        insert workOrder3;

        WorkOrder workOrder4 = TestDataFactory.createWorkOrder();
        workOrder4.OrderExternalId__c = 'orderExternalId3';
        insert workOrder4;


        Heroku_Callout_Logger__c hcl = new Heroku_Callout_Logger__c(
            Service__c = 'HEROKU_SAP4HANA__REBATE_DATA',
            Type__c = 'E',
            Log_External_Id__c = 'testExternalId'
        );
        toInsert.add(hcl);

        Heroku_Callout_Logger__c hcl1 = new Heroku_Callout_Logger__c(
            Service__c = 'HEROKU_SAP4HANA__BILLING_DATA',
            Type__c = 'W',
            Log_External_Id__c = 'testExternalId1'
        );
        toInsert.add(hcl1);

        Heroku_Callout_Logger__c hcl2 = new Heroku_Callout_Logger__c(
            Service__c = 'HEROKU_SAP4HANA__WORKORDER_UPSERT',
            Type__c = 'E',
            Log_External_Id__c = 'testExternalId2',
            orderexternalid__c = 'orderExternalId'
        );
        toInsert.add(hcl2);

        Heroku_Callout_Logger__c hcl3 = new Heroku_Callout_Logger__c(
            Service__c = 'HEROKU_SAP4HANA__WORKORDER_UPSERT',
            Type__c = 'E',
            Log_External_Id__c = 'testExternalId3',
            rebate_external_id__c = 'orderExternalId1'
        );
        toInsert.add(hcl3);

        Heroku_Callout_Logger__c hcl4 = new Heroku_Callout_Logger__c(
            Service__c = 'HEROKU_SAP4HANA__WORKORDER_UPSERT',
            Type__c = 'S',
            Log_External_Id__c = 'testExternalId4',
            orderexternalid__c = 'orderExternalId2'
        );
        toInsert.add(hcl4);

        Heroku_Callout_Logger__c hcl5 = new Heroku_Callout_Logger__c(
            Service__c = 'HEROKU_SAP4HANA__WORKORDER_UPSERT',
            Type__c = 'P',
            Log_External_Id__c = 'testExternalId5',
            orderexternalid__c = 'orderExternalId3'
        );
        toInsert.add(hcl5);

        Test.startTest();

        List<Database.SaveResult> results = Database.insert(toInsert);

        List<Heroku_Callout_Logger__c> queriedHCLs = [SELECT Id FROM Heroku_Callout_Logger__c];

        List<Database.DeleteResult> deleteResults = Database.delete(queriedHCLs);

        Test.stopTest();

        for(Database.SaveResult result : results) {
            System.assert(result.isSuccess());
        }

        List<Callout_Logger__c> calloutLoggers = [SELECT Id FROM Callout_Logger__c];

        System.assertEquals(0, calloutLoggers.size());
    }
}