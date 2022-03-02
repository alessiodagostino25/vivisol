@isTest
public class TestContractFrameworkTrigger {
    
    @TestSetup
    static void makeData(){
        Pricebook2 pricebook = TestDataFactory.createPricebook();
        pricebook.External_ID__c = '6300ZZ';

        insert pricebook;
    }

    @isTest
    static void insertTest() {
        Pricebook2 pricebook = [SELECT Id, External_ID__c FROM Pricebook2];

        Account a = TestDataFactory.createB2BAccount();
        insert a;

        Sales_Organization__c salesOrganization = TestDataFactory.createSalesOrganization();
        salesOrganization.Code__c = '6300';
        insert salesOrganization;

        Account_Sales_Organization__c ASO = new Account_Sales_Organization__c(
            Account__c = a.Id,
            Sales_Organization__c = salesOrganization.Id,
            Payment_Terms__c = 'NL00',
            Distribution_Channel__c = 'ZZ'
        );
        insert ASO;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();

        contractFramework.Customer__c = a.Id;
        contractFramework.Branch_of_belonging_sales_office__c = ASO.Id;
        contractFramework.Status__c = 'Active';
        contractFramework.Contract_Start_date__c = Date.today();

        Test.startTest();

        Database.SaveResult result = Database.insert(contractFramework);

        Test.stopTest();

        Contract_Framework__c queriedContractFramework = [SELECT Id, PriceListCode__c FROM Contract_Framework__c];

        System.assert(result.isSuccess());

        System.assertEquals(queriedContractFramework.PriceListCode__c, pricebook.External_ID__c);
    }

    @isTest
    static void updateTest() {
        Pricebook2 pricebook = [SELECT Id, External_ID__c FROM Pricebook2];

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        contractFramework.Status__c = 'Active';
        contractFramework.Price_list_code__c = pricebook.Id;
        contractFramework.Contract_Start_date__c = Date.today();

        insert contractFramework;

        contractFramework.Name = 'Updated Name';

        Test.startTest();

        Database.SaveResult result = Database.update(contractFramework);

        Test.stopTest();

        System.assert(result.isSuccess());
    }

    @isTest
    static void updateStatusTest() {
        Pricebook2 pricebook = [SELECT Id, External_ID__c FROM Pricebook2];

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        contractFramework.Price_list_code__c = pricebook.Id;

        insert contractFramework;

        contractFramework.Status__c = 'Active';
        contractFramework.Contract_Start_date__c = Date.today();

        Test.startTest();

        Database.SaveResult result = Database.update(contractFramework);

        Test.stopTest();

        System.assert(result.isSuccess());
        System.assert(ContractFrameworkEventHelper.contracteventsUpdate.size()==1);
    }

    @isTest
    static void deactivateTest() {
        Pricebook2 pricebook = [SELECT Id, External_ID__c FROM Pricebook2];

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        contractFramework.Status__c = 'Active';
        contractFramework.External_Id__c = 'CF-TEST-0000001';
        contractFramework.Price_list_code__c = pricebook.Id;
        contractFramework.Contract_Start_date__c = Date.today();

        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        contractTreatment.External_Id__c = 'CT-TEST-0000001';
        insert contractTreatment;

        Contract_Treatment_Job__c contractTreatmentJob = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        contractTreatmentJob.External_Id__c = 'CTJ-TEST-0000001';
        insert contractTreatmentJob;

        Account account = TestDataFactory.createPersonAccountWithExternalId('PA-DEACT-000001');
        insert account;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(account);
        accountTreatment.Contract_Treatment__c = contractTreatment.Id;
        accountTreatment.External_Id__c = 'AT-TEST-00000001';
        insert accountTreatment;

        Account_Treatment_Job__c accountTreatmentJob = TestDataFactory.createAccountTreatmentJob(accountTreatment.Id);
        accountTreatmentJob.External_Id__c = 'ATJ-TEST-00000001';
        insert accountTreatmentJob;

        contractFramework.Status__c = 'Inactive';
        Account_Treatment_Status__c accTreatStatus = [SELECT Id, External_Id__c FROM Account_Treatment_Status__c LIMIT 1];
        accTreatStatus.External_Id__c = 'ATS-00000234541';
        update accTreatStatus;

        Test.startTest();

        Database.SaveResult result = Database.update(contractFramework);

        Test.stopTest();

        List<Account_Treatment_Status__c> ATSList = [SELECT Id, Status__c FROM Account_Treatment_Status__c WHERE Status__c = 'D'];

        System.assert(result.isSuccess());
        System.assertEquals(1, ATSList.size());
    }
}