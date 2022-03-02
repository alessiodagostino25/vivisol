@isTest
public class TestWorkOrderCreationBatch {
    @isTest
    static void batchTest() {
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

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(account);
        accountTreatment.Treatment_Type__c = null;
        accountTreatment.Contract_Treatment__c = contractTreatment.Id;
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

        Case c = new Case(
            AccountId = account.Id,
            Account_Treatment__c = accountTreatment.Id,
            Account_Treatment_Job__c = accountTreatmentJob.Id,
            WorkOrderToBeCreated__c = true,
            Next_Activity_Date__c = Datetime.now()
        ); 
        insert c;

        Test.startTest();

        Database.executeBatch(new WorkOrderCreationBatch());

        Test.stopTest();

        List<WorkOrder> workOrders = [SELECT CaseId FROM WorkOrder WHERE CaseId =: c.Id];

        System.assertEquals(1, workOrders.size());
    }
}