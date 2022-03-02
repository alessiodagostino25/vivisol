@isTest
public class TestAutoscheduleActivitiesInvocable {
    @TestSetup
    static void makeData(){
        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        contractFramework.Price_list_code__c = Test.getStandardPricebookId();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c contractTreatmentJob = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        contractTreatmentJob.Contract_Framework__c = contractFramework.Id;
        insert contractTreatmentJob;

        Contract_Treatment_Job_SLA__c SLA = TestDataFactory.createFullCalendarSLA(contractTreatmentJob.Id);
        SLA.Max_Time__c = 1;
        insert SLA;

        Account account = TestDataFactory.createPersonAccount();
        insert account;

        Prescription__c prescription = new Prescription__c(
            Patient__c = account.Id,
            Received_date__c = Datetime.now()
        );
        insert prescription;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(account);
        accountTreatment.Treatment_Type__c = null;
        accountTreatment.Contract_Treatment__c = contractTreatment.Id;
        accountTreatment.Prescription__c = prescription.Id;
        insert accountTreatment;

        Account_Treatment_Address__c ATA = TestDataFactory.createATA(accountTreatment);
        ATA.Default__c = true;
        insert ATA;

        Account_Treatment_Job__c accountTreatmentJob = TestDataFactory.createAccountTreatmentJob(accountTreatment.Id);
        accountTreatmentJob.Contract_Treatment_Job__c = contractTreatmentJob.Id;
        accountTreatmentJob.Scheduling_Rule__c = 'Autoscheduled';
        accountTreatmentJob.Frequency__c = 1;
        accountTreatmentJob.Frequency_Unit_of_measure__c = 'Month';
        accountTreatmentJob.Work_Order__c = true;
        accountTreatmentJob.Task__c = true;
        accountTreatmentJob.Delivery_Channel__c = 'Currier';
        accountTreatmentJob.Case_Type__c = 'Delivery';
        accountTreatmentJob.Case_Subtype__c = 'My Vivisol order';
        accountTreatmentJob.Task_Type__c = 'Call';
        accountTreatmentJob.Scheduling_Time_Frame__c = 365;
        accountTreatmentJob.Frequency_Type__c = 'NPU';
        insert accountTreatmentJob;

        Product2 product = TestDataFactory.createProduct();
        insert product;

        PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        insert pricebookEntry;

        /* Account_Treatment_Job_Product__c ATJP = TestDataFactory.createATJP(accountTreatmentJob.Id);
        ATJP.Product__c = product.Id;
        insert ATJP; */
    }

    @isTest
    static void schedulingTest() {
        Account_Treatment__c accountTreatment = [SELECT Id FROM Account_Treatment__c WHERE Contract_Treatment__c != null LIMIT 1];

        Test.startTest();

        AutoscheduleActivitiesTherapyInvocable.autoscheduleActivitiesTherapy(new List<String>{accountTreatment.Id});

        Test.stopTest();

        List<Case> cases = [SELECT Id FROM Case];

        System.assert(cases.size() > 0);
    }
}