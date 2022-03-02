@IsTest
public class TestContractTreatmentJobController {
    
    @IsTest
    private static void testGetContractTreatmentJob() {
        Pricebook2 pb=TestDataFactory.initPricebook();
        Contract_Framework__c cF = TestDataFactory.initContractFramework(pb);
        String contractFrameworkId = cF.Id;
        Contract_Treatment__c cT = TestDataFactory.initContractTreatment(contractFrameworkId);
        String ctID=cT.Id;
        Corporate_Treatment__c crt=TestDataFactory.initCorporateTreatment();
        String crtID=crt.Id;
        Contract_Treatment_Job__c ctj=TestDataFactory.initContractTreatmentJob(ctID,crtID);
        
        Test.startTest();
        
        List<Contract_Treatment_Job__c> cTJList = ContractTreatmentJobController.getContractTreatmentJob(cT.Id);
        
        for(Contract_Treatment_Job__c job : cTJList) {
            // System.assertEquals(job.Name + ' - ' + job.Corporate_Treatment_Job__r.Name, cT.Name + ' - ' + cTJ.Corporate_Treatment_Job__r.Name);
        }
            
       Test.stopTest();
    }
    
    @IsTest
    private static void testGetContractTreatmentName() {
        
        Pricebook2 pb=TestDataFactory.initPricebook();
        Contract_Framework__c cF = TestDataFactory.initContractFramework(pb);
        String contractFrameworkId = cF.Id;
        Contract_Treatment__c ct=TestDataFactory.initContractTreatment(contractFrameworkId);
        String ctID=ct.Id;
        Corporate_Treatment__c crt=TestDataFactory.initCorporateTreatment();
        String crtID=crt.Id;
        Contract_Treatment_Job__c ctj=TestDataFactory.initContractTreatmentJob(ctID,crtID);
        
        Test.startTest();
        
        List<Contract_Treatment_Job__c> cTJList = ContractTreatmentJobController.getContractTreatmentName(cT.Id);
        
        for(Contract_Treatment_Job__c job : cTJList) {
                // System.assertEquals(cT.Name, job.Name);
        }
        
        Test.stopTest();
        
    }
    
    @IsTest
    private static void testGetCorporateJobFromContractJob() {
        
        Pricebook2 pb=TestDataFactory.initPricebook();
        Contract_Framework__c cF = TestDataFactory.initContractFramework(pb);
        String contractFrameworkId = cF.Id;
        Contract_Treatment__c ct=TestDataFactory.initContractTreatment(contractFrameworkId);
        String ctID=ct.Id;
        Corporate_Treatment__c crt=TestDataFactory.initCorporateTreatment();
        String crtID=crt.Id;
        Contract_Treatment_Job__c ctj=TestDataFactory.initContractTreatmentJob(ctID,crtID);
        
        Test.startTest();
        
        String corJ = ContractTreatmentJobController.getCorporateJobFromContractJob(cTJ.Id);          
        System.assertEquals(corJ, cTJ.Corporate_Treatment_Job__c);
        
        Test.stopTest();
        
    }
    
    @IsTest
    private static void testGetCorporateTreatment() {
        
        Pricebook2 pb=TestDataFactory.initPricebook();
        Contract_Framework__c cF = TestDataFactory.initContractFramework(pb);
        String contractFrameworkId = cF.Id;
        Contract_Treatment__c ct=TestDataFactory.initContractTreatment(contractFrameworkId);
        String ctID=ct.Id;
        Corporate_Treatment__c crt=TestDataFactory.initCorporateTreatment();
        String crtID=crt.Id;
        Contract_Treatment_Job__c ctj=TestDataFactory.initContractTreatmentJob(ctID,crtID);
            
        Test.startTest();
        
        String corT = ContractTreatmentJobController.getCorporateTreatment(cTJ.Id);
        System.assertEquals(corT, cT.Corporate_Treatment__c);
        
        Test.stopTest();
    }

    @isTest
    static void testCloneCTJ() {
        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Product2 product = TestDataFactory.createProduct();
        product.Type__c = 'ZJOB';
        product.Product_Code__c = 'testCode';
        insert product;

        Product2 product2 = TestDataFactory.createProduct();
        product2.Type__c = 'ZJOB';
        product2.Product_Code__c = 'testCode2';
        insert product2;

        Corporate_Treatment_Job__c corporateTJ = TestDataFactory.initCorporateTreatmentJob();

        Contract_Treatment_Job__c toClone = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        toClone.Corporate_Treatment_Job__c = corporateTJ.Id;
        toClone.Contract_Treatment_Job_Code__c = product.Id;
        insert toClone;

        Contract_Treatment_Job_SLA__c sla = TestDataFactory.createSLA(toClone.Id);
        sla.Offset_End_Date__c = 7;
        sla.Offset_Start_Date__c = 7;
        sla.Offset_calculation_mode__c = 'Calendar';
        sla.Offset_unit_of_measure__c = 'Day';
        insert sla;

        Product2 product3 = TestDataFactory.createProduct();
        insert product3;

        Contract_Treatment_Job_Product__c CTJP = TestDataFactory.createCTJP(toClone.Id);
        CTJP.Product__c = product.Id;
        insert CTJP;

        Contract_Treatment_Default_BOM__c defaultBOM = TestDataFactory.createDefaultBOM(CTJP.Id, CTJP.Product__c);
        insert defaultBOM;

        Contract_Product_Limit__c CPL = TestDataFactory.createLimit(contractTreatment.Id, product3.Id);
        insert CPL;

        String newCTJId = ContractTreatmentJobController.cloneContractTreatmentJob(
            toClone.Id, 
            toClone.Corporate_Treatment_Job__c, 
            product2.Id, 
            toClone.Contract_Treatment__c, 
            contractFramework.Id
        );

        List<Contract_Treatment_Job__c> CTJs = [SELECT Id FROM Contract_Treatment_Job__c];
        System.assert(newCTJId != null);
        System.assertEquals(2, CTJs.size());
    }

    @isTest
    static void testGetCTJClonable() {
        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Product2 product = TestDataFactory.createProduct();
        product.Type__c = 'ZJOB';
        insert product;

        Corporate_Treatment__c corporateTreatment = TestDataFactory.initCorporateTreatment();
        Corporate_Treatment_Job__c corporateTJ = TestDataFactory.initCorporateTreatmentJob();

        Contract_Treatment_Job__c toClone = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        toClone.Corporate_Treatment_Job__c = corporateTJ.Id;
        toClone.Contract_Treatment_Job_Code__c = product.Id;
        insert toClone;

        List<ContractTreatmentJobDTO> CTJs = ContractTreatmentJobController.getContractTreatmentJobClonable(
            corporateTJ.Id, 
            corporateTreatment.Id, 
            contractTreatment.Id, 
            'SearchTerm'
        );

        List<ContractTreatmentJobDTO> CTJsNoSearchTerm = ContractTreatmentJobController.getContractTreatmentJobClonable(
            corporateTJ.Id, 
            corporateTreatment.Id, 
            contractTreatment.Id, 
            null
        );

        System.assert(CTJs != null);
        System.assert(CTJsNoSearchTerm != null);  
    }

    @isTest
    static void testCheckExistence() {
        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Product2 product = TestDataFactory.createProduct();
        product.Type__c = 'ZJOB';
        insert product;

        Corporate_Treatment__c corporateTreatment = TestDataFactory.initCorporateTreatment();
        Corporate_Treatment_Job__c corporateTJ = TestDataFactory.initCorporateTreatmentJob();

        Contract_Treatment_Job__c toClone = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        toClone.Corporate_Treatment_Job__c = corporateTJ.Id;
        toClone.Contract_Treatment_Job_Code__c = product.Id;
        insert toClone;

        Boolean alreadyExisting = ContractTreatmentJobController.checkIfJobAlreadyExist(
            corporateTJ.Id, 
            toClone.Contract_Treatment_Job_Code__c, 
            contractTreatment.Id
        );

        System.assertEquals(true, alreadyExisting);
    }

}