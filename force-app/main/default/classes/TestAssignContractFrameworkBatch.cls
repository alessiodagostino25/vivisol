@isTest
public class TestAssignContractFrameworkBatch {
    @isTest
    static void batchTest() {
        List<Callout_Logger__c> toInsert = new List<Callout_Logger__c>();
        List<Callout_Logger__c> toUpdate = new List<Callout_Logger__c>();

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Account_Company__c accountCompany = TestDataFactory.createAccountCompany();
        insert accountCompany;

        Account queriedAccount = [SELECT Id, AutoNumber__c, Account_External_Id__c FROM Account LIMIT 1];
        queriedAccount.Account_External_Id__c = queriedAccount.AutoNumber__c;
        update queriedAccount;

        Sales_Organization__c salesOrganization = TestDataFactory.createSalesOrganization();
        insert salesOrganization;

        Account_Sales_Organization__c ASO = TestDataFactory.getAso(queriedAccount.Id);
        ASO.Sales_Organization__c = salesOrganization.Id;
        insert ASO;

        Account_Sales_Organization__c queriedASO = [SELECT External_Id__c, IsSyncSAP__c FROM Account_Sales_Organization__c WHERE Id =: ASO.Id];
        Account_Company__c queriedAccountCompany = [SELECT External_Id__c, IsSyncSAP__c FROM Account_Company__c WHERE Id =: accountCompany.Id];
        Contract_Framework__c queriedContractFramework = [SELECT Contract_Number__c , IsSyncSAP__c FROM Contract_Framework__c WHERE Id =: contractFramework.Id];
        Schema.Address queriedAddress = [SELECT Parent.Location_Id__c, IsSyncSAP__c FROM Address LIMIT 1];

        Callout_Logger__c calloutLogger = new Callout_Logger__c(
            Service__c = 'SFDC_SAP4HANA__CONTRACT',
            isSolved__c = false,
            RecordId__c = queriedContractFramework.Contract_Number__c
        );
        toInsert.add(calloutLogger);

        Callout_Logger__c calloutLogger1 = new Callout_Logger__c(
            Service__c = 'SFDC_SAP4HANA__SO_CREATE',
            isSolved__c = false,
            Object__c = 'Account_Company__c',
            RecordId__c = queriedAccountCompany.External_ID__c
        );
        toInsert.add(calloutLogger1);

        Callout_Logger__c calloutLogger2 = new Callout_Logger__c(
            Service__c = 'SFDC_SAP4HANA__PATIENT_CREATE',
            isSolved__c = false,
            Object__c = 'Account',
            RecordId__c = queriedAccount.Account_External_Id__c
        );
        toInsert.add(calloutLogger2);

        Callout_Logger__c calloutLogger3 = new Callout_Logger__c(
            Service__c = 'SFDC_SAP4HANA__SO_CREATE',
            isSolved__c = false,
            Object__c = 'Account_Sales_Organization__c',
            RecordId__c = queriedASO.External_Id__c
        );
        toInsert.add(calloutLogger3);

        Callout_Logger__c calloutLogger4 = new Callout_Logger__c(
            Service__c = 'SFDC_SAP4HANA__ADDRESS_CREATE',
            isSolved__c = false,
            Object__c = 'Address',
            RecordId__c = queriedAddress.Parent.Location_Id__c
        );
        toInsert.add(calloutLogger4);

        insert toInsert;

        // The trigger sets the field immediately, but I need to test the batch so I reset the field

        calloutLogger.Related_Contract_Framework__c = null;
        calloutLogger1.Related_Account_Company__c = null;
        calloutLogger2.Related_Account__c = null;
        calloutLogger3.Related_Account_Sales_Organization__c = null;
        calloutLogger4.Related_Address__c = null;

        toUpdate.add(calloutLogger);
        toUpdate.add(calloutLogger1);
        toUpdate.add(calloutLogger2);
        toUpdate.add(calloutLogger3);
        toUpdate.add(calloutLogger4);

        update toUpdate;

        Test.startTest();

        Database.executeBatch(new AssignContractFrameworkBatch());

        queriedAccount.IsSyncSAP__c = 'Sync';
        queriedAccountCompany.IsSyncSAP__c = 'Sync';
        queriedAddress.IsSyncSAP__c = true;
        queriedASO.IsSyncSAP__c = 'Sync';
        queriedContractFramework.IsSyncSAP__c = 'Sync';

        update queriedAccount;
        update queriedAccountCompany;
        update queriedAddress;
        update queriedASO;
        update queriedContractFramework;

        Test.stopTest();

        Callout_Logger__c queriedCalloutLogger = [SELECT Related_Contract_Framework__c FROM Callout_Logger__c WHERE Id =: calloutLogger.Id];
        Callout_Logger__c queriedCalloutLogger1 = [SELECT Related_Account_Company__c FROM Callout_Logger__c WHERE Id =: calloutLogger1.Id];
        Callout_Logger__c queriedCalloutLogger2 = [SELECT Related_Account__c FROM Callout_Logger__c WHERE Id =: calloutLogger2.Id];
        Callout_Logger__c queriedCalloutLogger3 = [SELECT Related_Account_Sales_Organization__c FROM Callout_Logger__c WHERE Id =: calloutLogger3.Id];
        Callout_Logger__c queriedCalloutLogger4 = [SELECT Related_Address__c FROM Callout_Logger__c WHERE Id =: calloutLogger4.Id];

        System.assertEquals(contractFramework.Id, queriedCalloutLogger.Related_Contract_Framework__c);
        System.assertEquals(accountCompany.Id, queriedCalloutLogger1.Related_Account_Company__c);
        System.assertEquals(queriedAccount.Id, queriedCalloutLogger2.Related_Account__c);
        System.assertEquals(queriedASO.Id, queriedCalloutLogger3.Related_Account_Sales_Organization__c);
        System.assertEquals(queriedAddress.Id, queriedCalloutLogger4.Related_Address__c);
    }
}