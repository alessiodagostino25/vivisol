@isTest
public class TestBatchDeleteDuplicatedPF {
    @isTest
    static void batchTest() {
        List<Account_Partner_Function__c> toInsert = new List<Account_Partner_Function__c>();

        Account account = TestDataFactory.createPersonAccount();
        insert account;

        Sales_Organization__c salesOrg = TestDataFactory.createSalesOrganization();
        salesOrg.Code__c = 'SalesOrgCode';
        insert salesOrg;

        Account_Sales_Organization__c ASO = TestDataFactory.getAso(account.Id);
        ASO.Sales_Organization__c = salesOrg.Id;
        insert ASO;

        Account_Partner_Function__c apf = new Account_Partner_Function__c(
            Account_Sales_Organization__c = ASO.Id,
            Account__c = account.Id,
            Partner_Function__c = 'WE'
        );
        toInsert.add(apf);

        insert toInsert;

        Test.startTest();

        Database.executeBatch(new BatchDeleteDuplicatedPF());

        Test.stopTest();

        List<Account_Partner_Function__c> APFs = [SELECT Id FROM Account_Partner_Function__c WHERE Account_Sales_Organization__c =: ASO.Id];

        System.assertEquals(4, APFs.size());
    }
}