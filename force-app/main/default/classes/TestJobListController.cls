@IsTest
public class TestJobListController {

    static testMethod void getselectJobs(){
      /*Profile pr=TestDataFactory.getVivisolBackofficeProfile();
        User u=TestDataFactory.initUser(pr);
        List<User> lu=new List<User>();
        lu.add(u); */
        //System.runAs(lu[0]){
            Account a = TestDataFactory.createPersonAccount();
            insert a;
            
            Product2 p=TestDataFactory.initProduct2();
            Pricebook2 pb=TestDataFactory.initPricebook();
            Contract_Framework__c cF = TestDataFactory.initContractFramework();
            String contractFrameworkId = cF.Id;
            Contract_Treatment__c cT = TestDataFactory.initContractTreatment(contractFrameworkId);
            String ctID=cT.Id;
            Corporate_Treatment__c crt=TestDataFactory.initCorporateTreatment();
            String crtID=crt.Id;
            Contract_Treatment_Job__c ctj=TestDataFactory.initContractTreatmentJob(ctID,crtID);
            
            Account_Treatment__c accountTreatment= TestDataFactory.createMRDAccountTreatment(a);
            accountTreatment.Business_Line__c = null;
            accountTreatment.Treatment_Type__c = null;
            insert accountTreatment;

            Account_Treatment_Job__c at=TestDataFactory.initAccountTreatmentJob2(p, ctj, accountTreatment);
            String recordid2=accountTreatment.id; 
            Test.startTest();
            List<Account_Treatment_Job__c> result=JobListController.getselectJobs(recordid2);
            List<Account_Treatment__c> statusList = JobListController.getaccounttreatmentstatus(accountTreatment.Id);
            System.debug('oo'+result);
            Test.stopTest();
            System.assertEquals(1, result.size());
        //}
    }
    
    
}