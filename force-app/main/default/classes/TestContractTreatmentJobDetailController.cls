@isTest
public class TestContractTreatmentJobDetailController {
    @isTest
    static void propagateDeliveryChannelTest() {
        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        CTJ.Delivery_Channel__c = 'Home Visit';
        insert CTJ;

        Account account = TestDataFactory.createPersonAccount();
        insert account;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(account);
        insert accountTreatment;

        Account_Treatment_Job__c ATJ = TestDataFactory.createAccountTreatmentJob(accountTreatment.Id);
        ATJ.Is_Delivery_Channel_different_from_Contr__c = false;
        ATJ.Contract_Treatment_Job__c = CTJ.Id;
        insert ATJ;

        WorkOrder workOrder = TestDataFactory.createWorkOrder();
        workOrder.Account_Treatment_Job__c = ATJ.Id;
        insert workOrder;

        Test.startTest();

        ContractTreatmentJobDetailController.propagateDeliveryChannel(CTJ.Id);

        Test.stopTest();

        Account_Treatment_Job__c queriedATJ = [SELECT Delivery_Channel__c FROM Account_Treatment_Job__c WHERE Id =: ATJ.Id];
        WorkOrder queriedWO = [SELECT Delivery_Type__c FROM WorkOrder WHERE Id =: workOrder.Id];

        System.assertEquals(CTJ.Delivery_Channel__c, queriedATJ.Delivery_Channel__c);
        System.assertEquals(CTJ.Delivery_Channel__c, queriedWO.Delivery_Type__c);
    }

    @isTest
    static void propagateFrequencyTest() {
        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        contractFramework.Price_list_code__c = Test.getStandardPricebookId();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        CTJ.Contract_Framework__c = contractFramework.Id;
        CTJ.Delivery_Channel__c = 'Home Visit';
        CTJ.Frequency__c = 6;
        CTJ.Frequency_Unit_of_measure__c = 'Year';
        CTJ.Scheduling_Rule__c = 'Autoscheduled';
        CTJ.Scheduling_Time_Frame__c = 365;
        CTJ.Frequency_Type__c = 'NPU';
        insert CTJ;

        Contract_Treatment_Job_SLA__c SLA = TestDataFactory.createFullCalendarSLA(CTJ.Id);
        SLA.Max_Time__c = 1;
        insert SLA;

        Account account = TestDataFactory.createPersonAccount();
        insert account;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(account);
        insert accountTreatment;

        Account_Treatment_Job__c ATJ = TestDataFactory.createAccountTreatmentJob(accountTreatment.Id);
        ATJ.Is_Delivery_Channel_different_from_Contr__c = false;
        ATJ.Contract_Treatment_Job__c = CTJ.Id;
        ATJ.Work_Order__c = true;
        ATJ.Task__c = true;
        ATJ.Scheduling_Rule__c = 'Autoscheduled';
        ATJ.Frequency__c = 1;
        ATJ.Frequency_Unit_of_measure__c = 'Month';
        ATJ.Scheduling_Time_Frame__c = 365;
        ATJ.Frequency_Type__c = 'NPU';
        insert ATJ;

        /* Product2 product = TestDataFactory.createProduct();
        insert product; */

        /* PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        insert pricebookEntry; */

        /* Account_Treatment_Job_Product__c ATJP = TestDataFactory.createATJP(ATJ.Id);
        ATJP.Product__c = product.Id;
        insert ATJP; */

        Case c = TestDataFactory.createCase();
        c.AccountId = account.Id;
        c.Account_Treatment__c = accountTreatment.Id;
        c.Account_Treatment_Job__c = ATJ.Id;
        c.Autoscheduled__c = true;
        c.External_Id__c = 'CASE_FREQ_1';
        insert c;

        WorkOrder workOrder = TestDataFactory.createWorkOrder();
        workOrder.Account_Treatment_Job__c = ATJ.Id;
        workOrder.CaseId = c.Id;
        workOrder.Autoscheduled__c = true;
        workOrder.Due_Date__c = Datetime.now();
        workOrder.Related_SLA__c = SLA.id;
        insert workOrder;

        Task t = TestDataFactory.createTask();
        t.Account_Treatment_Job__c = ATJ.Id;
        t.WhatId = c.Id;
        t.Autoscheduled__c = true;
        t.Start_Date__c = Datetime.now();
        t.Due_Date__c = Datetime.now();
        t.ActivityDate = Date.today();
        t.Related_SLA__c = SLA.id;
        insert t;

        Test.startTest();

        ContractTreatmentJobDetailController.propagateFrequency(CTJ.Id);

        Test.stopTest();

        Account_Treatment_Job__c queriedATJ = [SELECT Frequency__c, Frequency_Unit_of_measure__c FROM Account_Treatment_Job__c WHERE Id =: ATJ.Id];
        List<WorkOrder> newWorkOrders = [SELECT Id FROM WorkOrder WHERE Account_Treatment_Job__c =: ATJ.Id AND Status = 'New' AND Id !=: workOrder.Id];
        List<Task> newTasks = [SELECT Id FROM Task WHERE Account_Treatment_Job__c =: ATJ.Id AND Status = 'Open' AND Id !=: t.Id];

        System.assertEquals(CTJ.Frequency__c, queriedATJ.Frequency__c);
        System.assertEquals(CTJ.Frequency_Unit_of_measure__c, queriedATJ.Frequency_Unit_of_measure__c);
        System.assertEquals(5, newWorkOrders.size());
        System.assertEquals(5, newTasks.size());
    }

    @isTest
    static void getShowFrequencyButtonTest() {
        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        contractFramework.Price_list_code__c = Test.getStandardPricebookId();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        contractFramework.Status__c = 'Active';
        contractFramework.Contract_Start_date__c = Date.today();
        contractFramework.Contract_End_Date__c = Date.today().addMonths(1);
        update contractFramework;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        CTJ.Contract_Framework__c = contractFramework.Id;
        CTJ.Delivery_Channel__c = 'Home Visit';
        CTJ.Frequency__c = 6;
        CTJ.Frequency_Unit_of_measure__c = 'Year';
        CTJ.Scheduling_Rule__c = 'Autoscheduled';
        CTJ.Scheduling_Time_Frame__c = 365;
        CTJ.Frequency_Type__c = 'NPU';
        insert CTJ;

        Test.startTest();

        Boolean showButton = ContractTreatmentJobDetailController.getShowFrequencyButton(CTJ.Id);

        Test.stopTest();

        System.assertEquals(false, showButton);
    }

    @isTest
    static void getShowDeliveryButtonTest() {
        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        contractFramework.Price_list_code__c = Test.getStandardPricebookId();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        contractFramework.Status__c = 'Active';
        contractFramework.Contract_Start_date__c = Date.today();
        contractFramework.Contract_End_Date__c = Date.today().addMonths(1);
        update contractFramework;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        CTJ.Contract_Framework__c = contractFramework.Id;
        CTJ.Delivery_Channel__c = 'Home Visit';
        CTJ.Frequency__c = 6;
        CTJ.Frequency_Unit_of_measure__c = 'Year';
        CTJ.Scheduling_Rule__c = 'Autoscheduled';
        CTJ.Scheduling_Time_Frame__c = 365;
        CTJ.Frequency_Type__c = 'NPU';
        insert CTJ;

        Test.startTest();

        Boolean showButton = ContractTreatmentJobDetailController.getShowDeliveryButton(CTJ.Id);

        Test.stopTest();

        System.assertEquals(false, showButton);
    }

    @isTest
    static void checkSLAWarningTest() {
        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        contractFramework.Price_list_code__c = Test.getStandardPricebookId();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        CTJ.Contract_Framework__c = contractFramework.Id;
        CTJ.Delivery_Channel__c = 'Home Visit';
        CTJ.Frequency__c = 6;
        CTJ.Frequency_Unit_of_measure__c = 'Year';
        CTJ.Scheduling_Rule__c = 'Autoscheduled';
        CTJ.Scheduling_Time_Frame__c = 365;
        CTJ.Frequency_Type__c = 'NPU';
        insert CTJ;

        Test.startTest();

        Boolean showWarning = ContractTreatmentJobDetailController.checkForSLAWarningMessage(CTJ.Id);

        Test.stopTest();

        System.assertEquals(true, showWarning);
    }
}