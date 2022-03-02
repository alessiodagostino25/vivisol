@isTest
public class TestContractTreatmentJobTrigger {
    public static testMethod void ContractTreatmentJobTrigger(){
        Pricebook2 pb = TestDataFactory.initPricebook();
        Contract_Framework__c cf = TestDataFactory.initContractFramework2(pb);
        Contract_Treatment__c ct = TestDataFactory.initContractTreatment(cf.Id);
        Corporate_Treatment_Job__c cotj = TestDataFactory.initCorporateTreatmentJob();  
        Contract_Treatment_Job__c ctj = TestDataFactory.initContractTreatmentJob2(ct.Id, cotj.Id);
        test.startTest();
        Database.SaveResult result = Database.insert(ctj);
        test.stopTest();
        system.assert(result.isSuccess());
    }

    @isTest
    static void toSetSTFTest() {
        Corporate_Treatment__c corporateTreatment = TestDataFactory.createCorporateTreatment();
        corporateTreatment.Scheduling_Time_Frame__c = 180;
        insert corporateTreatment;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        contractTreatment.Corporate_Treatment__c = corporateTreatment.Id;
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);

        Test.startTest();

        Database.SaveResult result = Database.insert(CTJ);

        Test.stopTest();

        Contract_Treatment_Job__c queriedCTJ = [SELECT Scheduling_Time_Frame__c FROM Contract_Treatment_Job__c WHERE Id =: CTJ.Id];

        System.assert(result.isSuccess());
        System.assertEquals(corporateTreatment.Scheduling_Time_Frame__c, queriedCTJ.Scheduling_Time_Frame__c);
    }
}