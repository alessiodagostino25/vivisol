@IsTest
public class TestCTJFController {

    
    static testMethod void getCorporateTreatmentJobFamily(){
        Pricebook2 pb=TestDataFactory.initPricebook();
        Contract_Framework__c cf=TestDataFactory.initContractFramework2(pb);
        String contractFramework=cf.Id;//CAMPO
        Contract_Treatment__c ct=TestDataFactory.initContractTreatment(contractFramework);
        String ctID=ct.Id;
        Corporate_Treatment__c crt=TestDataFactory.initCorporateTreatment();
        String crtID=crt.Id;
        Contract_Treatment_Job__c ctj=TestDataFactory.initContractTreatmentJob(ctID,crtID);
        Corporate_Treatment_Job__c cotj=TestDataFactory.initCorporateTreatmentJob();
        String contractTreatmentJobId=ctj.Id;//CAMPO
        Product2 p=TestDataFactory.initProduct();
        Contract_Treatment_Job_Product__c ctjp=TestDataFactory.initCTJP(ctj, p);
        Corporate_Treatment_Job_Product__c cotjp=TestDataFactory.initCorporateTreatmentJobProduct(cotj, p);
        String idCOTJP=cotjp.Id;
        List<String> allSelectedIds=new List<String>();//CAMPO
        allSelectedIds.add(idCOTJP);
        
        String corporateTreatmentJob=cotj.Id;//CAMPO 
        Corporate_Treatment__c cot=TestDataFactory.initCorporateTreatment();
        String corporateTreatment=cot.Id;
            String picklistValue='';
            String searchValue='';
            Test.startTest();
        List<CorporateTreatmentJobProductDTO> result=CorporateTreatmentJobFamilyController.getCorporateTreatmentJobFamily(corporateTreatment,  corporateTreatmentJob, 
     contractFramework,  contractTreatmentJobId, picklistValue,  searchValue, allSelectedIds);
        System.debug('oo'+result);
        Test.stopTest();
        System.assertEquals(1,result.size());
    }
    
    static testMethod void getCorporateTreatmentJobFamily2(){
         Pricebook2 pb=TestDataFactory.initPricebook();
        Contract_Framework__c cf=TestDataFactory.initContractFramework2(pb);
        String contractFramework=cf.Id;//CAMPO
        Contract_Treatment__c ct=TestDataFactory.initContractTreatment(contractFramework);
        String ctID=ct.Id;
        Corporate_Treatment__c crt=TestDataFactory.initCorporateTreatment();
        String crtID=crt.Id;
        Contract_Treatment_Job__c ctj=TestDataFactory.initContractTreatmentJob(ctID,crtID);
        Corporate_Treatment_Job__c cotj=TestDataFactory.initCorporateTreatmentJob();
        String contractTreatmentJobId=ctj.Id;//CAMPO
        Product2 p=TestDataFactory.initProduct();
        Contract_Treatment_Job_Product__c ctjp=TestDataFactory.initCTJP(ctj, p);
        Corporate_Treatment_Job_Product__c cotjp=TestDataFactory.initCorporateTreatmentJobProduct(cotj, p);
        String idCOTJP=cotjp.Id;
        List<String> allSelectedIds=new List<String>();//CAMPO
        allSelectedIds.add(idCOTJP);
        
        String corporateTreatmentJob=cotj.Id;//CAMPO 
        Corporate_Treatment__c cot=TestDataFactory.initCorporateTreatment();
        String corporateTreatment=cot.Id;
            String picklistValue='';
            String searchValue='ciao';
            Test.startTest();
        List<CorporateTreatmentJobProductDTO> result=CorporateTreatmentJobFamilyController.getCorporateTreatmentJobFamily(corporateTreatment,  corporateTreatmentJob, 
     contractFramework,  contractTreatmentJobId, picklistValue,  searchValue, allSelectedIds);
        System.debug('oo'+result);
        Test.stopTest();
        System.assertEquals(1,result.size());
    }
    
    static testMethod void getCorporateTreatmentJobFamily3(){
      Pricebook2 pb=TestDataFactory.initPricebook();
        Contract_Framework__c cf=TestDataFactory.initContractFramework2(pb);
        String contractFramework=cf.Id;//CAMPO
        Contract_Treatment__c ct=TestDataFactory.initContractTreatment(contractFramework);
        String ctID=ct.Id;
        Corporate_Treatment__c crt=TestDataFactory.initCorporateTreatment();
        String crtID=crt.Id;
        Contract_Treatment_Job__c ctj=TestDataFactory.initContractTreatmentJob(ctID,crtID);
        Corporate_Treatment_Job__c cotj=TestDataFactory.initCorporateTreatmentJob();
        String contractTreatmentJobId=ctj.Id;//CAMPO
        Product2 p=TestDataFactory.initProduct();
        Contract_Treatment_Job_Product__c ctjp=TestDataFactory.initCTJP(ctj, p);
        Corporate_Treatment_Job_Product__c cotjp=TestDataFactory.initCorporateTreatmentJobProduct(cotj, p);
        String idCOTJP=cotjp.Id;
        List<String> allSelectedIds=new List<String>();//CAMPO
        allSelectedIds.add(idCOTJP);
        
        String corporateTreatmentJob=cotj.Id;//CAMPO 
        Corporate_Treatment__c cot=TestDataFactory.initCorporateTreatment();
        String corporateTreatment=cot.Id;
            String picklistValue='ciao';
            String searchValue='';
            Test.startTest();
        List<CorporateTreatmentJobProductDTO> result=CorporateTreatmentJobFamilyController.getCorporateTreatmentJobFamily(corporateTreatment,  corporateTreatmentJob, 
     contractFramework,  contractTreatmentJobId, picklistValue,  searchValue, allSelectedIds);
        System.debug('oo'+result);
        Test.stopTest();
        System.assertEquals(1,result.size());
    }
    
    static testMethod void getCorporateTreatmentJobFamily4(){
        Pricebook2 pb=TestDataFactory.initPricebook();
        Contract_Framework__c cf=TestDataFactory.initContractFramework2(pb);
        String contractFramework=cf.Id;//CAMPO
        Contract_Treatment__c ct=TestDataFactory.initContractTreatment(contractFramework);
        String ctID=ct.Id;
        Corporate_Treatment__c crt=TestDataFactory.initCorporateTreatment();
        String crtID=crt.Id;
        Contract_Treatment_Job__c ctj=TestDataFactory.initContractTreatmentJob(ctID,crtID);
        Corporate_Treatment_Job__c cotj=TestDataFactory.initCorporateTreatmentJob();
        String contractTreatmentJobId=ctj.Id;//CAMPO
        Product2 p=TestDataFactory.initProduct();
        Contract_Treatment_Job_Product__c ctjp=TestDataFactory.initCTJP(ctj, p);
        Corporate_Treatment_Job_Product__c cotjp=TestDataFactory.initCorporateTreatmentJobProduct(cotj, p);
        String idCOTJP=cotjp.Id;
        List<String> allSelectedIds=new List<String>();//CAMPO
        allSelectedIds.add(idCOTJP);
        
        String corporateTreatmentJob=cotj.Id;//CAMPO 
        Corporate_Treatment__c cot=TestDataFactory.initCorporateTreatment();
        String corporateTreatment=cot.Id;
            String picklistValue='ciao';
            String searchValue='ciao';
            Test.startTest();
        List<CorporateTreatmentJobProductDTO> result=CorporateTreatmentJobFamilyController.getCorporateTreatmentJobFamily(corporateTreatment,  corporateTreatmentJob, 
     contractFramework,  contractTreatmentJobId, picklistValue,  searchValue, allSelectedIds);
        System.debug('oo'+result);
        Test.stopTest();
        System.assertEquals(1,result.size());
       
    }
    
       static testMethod void getProductTypes(){
        TestDataFactory.initProduct2();
           Test.startTest();
        List<ProductTypeDTO> l = CorporateTreatmentJobFamilyController.getProductTypes();
        System.debug('eccomi:' + l);
           Test.stopTest();
        System.assert(l.size() >= 15);
    }
}