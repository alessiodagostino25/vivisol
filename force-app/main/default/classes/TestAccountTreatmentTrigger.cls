@isTest
public class TestAccountTreatmentTrigger {

    @isTest
    public static void testAccountTreatmentHistory(){
        Account acc = TestDataFactory.initAccount2();
        acc.Status__c = 'DEACTIVATED';
        update acc; 
        
        Account_Treatment__c patient = new Account_Treatment__c();
        patient.Account__c = acc.Id;
        patient.Status__c = 'W';
        insert patient;
        
        Account_Treatment_Status__c oldStatus = new Account_Treatment_Status__c();
        oldStatus.Patient_Treatment__c = patient.Id;
        insert oldStatus;
        Account_Treatment_Status__c newsstatus = new Account_Treatment_Status__c();
        newsstatus.Status__c = 'A';
        newsstatus.StartDate__c = Date.newInstance(2020, 12, 12);
        newsstatus.Patient_Treatment__c = patient.Id;
        patient.Activation_Date__c = newsstatus.StartDate__c;
        patient.Autostart__c = true;
        test.startTest();
        update patient;
        patient.APAP_Mmax_pressure__c = 5;
        update patient;
        insert newsstatus;
        test.stopTest();
        List<Account_Treatment_History__c> history = [SELECT Id FROM Account_Treatment_History__c];
        Account accountAfterTest = [Select id, Status__c from Account where id=:acc.Id];
        system.assertEquals('ACTIVE', accountAfterTest.Status__c, 'Account status');
        system.assertEquals(false, history.isEmpty(), 'Account history not created');
    }

/*     @isTest
    static void updateTest() {
        List<Account_Treatment_Job_Product__c> ATJPsToInsert = new List<Account_Treatment_Job_Product__c>();

        RecordType maintenanceRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'AccountTreatment_Maintenance'];

        Account a = TestDataFactory.createPersonAccount();
        insert a;

        Product2 product = TestDataFactory.createProduct();
        insert product;

        PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        insert pricebookEntry;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        contractFramework.Price_list_code__c = Test.getStandardPricebookId();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        CTJ.Contract_Framework__c = contractFramework.Id;
        insert CTJ;

        Contract_Treatment_Job_SLA__c SLA = TestDataFactory.createSLA(CTJ.Id);
        SLA.Offset_End_Date__c = 7;
        SLA.Offset_Start_Date__c = 7;
        SLA.Offset_calculation_mode__c = 'Calendar';
        SLA.Offset_unit_of_measure__c = 'Day';
        SLA.Task_MaxTime_Execution__c = 7;
        SLA.Task_Calculation_Mode__c = 'Calendar';
        SLA.Task_Unite_of_measure_Max_Time__c = 'Day';
        insert SLA;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(a);
        accountTreatment.Business_Line__c = null;
        accountTreatment.Treatment_Type__c = null;
        accountTreatment.RecordTypeId = maintenanceRT.Id;
        accountTreatment.Status__c = 'W';
        accountTreatment.Contract_Treatment__c = contractTreatment.Id;
        insert accountTreatment;

        Account_Treatment_Job__c ATJ = TestDataFactory.createAccountTreatmentJob(accountTreatment.Id);
        ATJ.Contract_Treatment_Job__c = CTJ.Id;
        ATJ.Task__c = true;
        ATJ.Work_Order__c = true;
        insert ATJ;

        Asset asset = TestDataFactory.createAsset(a.Id);
        insert asset;

        Account_Treatment_Job_Product__c ATJP = TestDataFactory.createATJP(ATJ.Id);
        ATJP.Status__c = 'Active';
        ATJP.Product__c = product.Id;
        ATJPsToInsert.add(ATJP);

        Account_Treatment_Job_Product__c assetATJP = TestDataFactory.createATJP(ATJ.Id);
        assetATJP.Status__c = 'Active';
        assetATJP.Asset__c = asset.Id;
        ATJPsToInsert.add(assetATJP);

        insert ATJPsToInsert;

        accountTreatment.Status__c = 'A';

        Test.startTest();

        Database.SaveResult result = Database.update(accountTreatment);

        Test.stopTest();

        List<Case> cases = [SELECT Id FROM Case];
        List<Task> tasks = [SELECT Id FROM Task];
        List<WorkOrder> workOrders = [SELECT Id FROM WorkOrder];
        List<WorkOrderLineItem> WOLIs = [SELECT Id FROM WorkOrderLineItem];

        System.assert(result.isSuccess());
        
        System.assertEquals(1, cases.size());
        System.assertEquals(1, tasks.size());
        System.assertEquals(1, workOrders.size());
        System.assertEquals(1, WOLIs.size());

    } */

    @isTest
    static void setTreatmentModalityTest() {
        Product2 product = new Product2(
            Type__c = 'ZSRT',
            Name = 'Test Product'
        );
        insert product;

        Account a = TestDataFactory.createPersonAccount();
        insert a;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Modality__c ctm = TestDataFactory.createContractTreatmentModality(contractTreatment);
        ctm.Treatment__c = product.Id;
        ctm.Treatment_Type__c = 'PAP';
        ctm.Sub_Treatment__c = 'CPAP';
        ctm.Installation_Type__c = 'HV';
        insert ctm;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(a);
        accountTreatment.Treatment_Type__c = 'PAP';
        accountTreatment.Treatment__c = 'CPAP';
        accountTreatment.Installation_Type__c = 'HV';
        accountTreatment.Contract_Treatment__c = contractTreatment.Id;

        Account_Treatment__c accountTreatment1 = TestDataFactory.createMRDAccountTreatment(a);
        accountTreatment1.Treatment_Type__c = 'PAP';
        accountTreatment1.Treatment__c = 'CPAP';
        accountTreatment1.Contract_Treatment__c = contractTreatment.Id;

        Account_Treatment__c accountTreatment2 = TestDataFactory.createMRDAccountTreatment(a);
        accountTreatment2.Treatment_Type__c = 'PAP';
        accountTreatment2.Installation_Type__c = 'HV';
        accountTreatment2.Contract_Treatment__c = contractTreatment.Id;

        Test.startTest();

        List<Database.SaveResult> results = Database.insert(new List<Account_Treatment__c>{accountTreatment, accountTreatment1, accountTreatment2});

        Test.stopTest();

        List<Account_Treatment__c> queriedATs = [SELECT Treatment_Modality__c FROM Account_Treatment__c WHERE Id =: accountTreatment.Id OR Id =: accountTreatment1.Id 
                                                OR Id =: accountTreatment2.Id];

        for(Account_Treatment__c at : queriedATs) {
            System.assertEquals(ctm.Id, at.Treatment_Modality__c);
        }
    }
}