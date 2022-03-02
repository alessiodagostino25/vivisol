@IsTest
public class TestContractTreatmentJobSla {

    @IsTest 
    static void testGetContractTreatmentJobSla() {
        
        Pricebook2 pb=TestDataFactory.initPricebook();
        Contract_Framework__c cF = TestDataFactory.initContractFramework(pb);
        String contractFrameworkId = cF.Id;
         Contract_Treatment__c cT = TestDataFactory.initContractTreatment(contractFrameworkId);
        String ctID=cT.Id;
        Corporate_Treatment__c crt=TestDataFactory.initCorporateTreatment();
        String crtID=crt.Id;
        Contract_Treatment_Job__c ctj=TestDataFactory.initContractTreatmentJob(ctID,crtID);
        String ctjId=ctj.Id;
        TestDataFactory.initTreatmentJobSla(ctjId);
        
        Test.startTest();

        List<Contract_Treatment_Job_SLA__c> slaList = ContractTreatmentJobSlaController.getContractTreatmentJobSla(cTJ.Id);
        
        System.assertEquals(slaList[0].Contract_Treatment_Job__c, cTJ.Id);
        
        Test.stopTest();
    }
}