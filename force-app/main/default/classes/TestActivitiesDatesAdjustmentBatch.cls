@isTest
public class TestActivitiesDatesAdjustmentBatch {
    
    @isTest
    static void taskTest(){
        Account a = TestDataFactory.createPersonAccount();
        insert a;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        insert CTJ;

        Contract_Treatment_Job_SLA__c SLA = TestDataFactory.createFullCalendarSLA(CTJ.Id);
        insert SLA;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(a);
        accountTreatment.Business_Line__c = null;
        accountTreatment.Treatment_Type__c = null;
        accountTreatment.Contract_Treatment__c = contractTreatment.Id;
        insert accountTreatment;

        Account_Treatment_Job__c ATJ = TestDataFactory.createAccountTreatmentJob(accountTreatment.Id);
        ATJ.Contract_Treatment_Job__c = CTJ.Id;
        ATJ.Task__c = true;
        ATJ.Frequency__c = 1;
        ATJ.Frequency_Unit_of_measure__c = 'Month';
        ATJ.Scheduling_Time_Frame__c = 365;
        ATJ.Frequency_Type__c = 'NPU';
        insert ATJ;

        Case c = TestDataFactory.createCase();
        c.Account_Treatment_Job__c = ATJ.Id;
        c.AccountId = a.Id;
        c.Account_Treatment__c = accountTreatment.Id;
        c.Status = 'Closed';
        c.Autoscheduled__c = true;
        c.ExcludeFromAdjustment__c = false;
        c.External_Id__c = 'TASK_TEST_1';
        insert c;

        Task closedTask = TestDataFactory.createTask();
        closedTask.WhatId = c.Id;
        closedTask.ActivityDate = Date.today().addDays(-2);
        closedTask.Due_Date__c = Datetime.now().addDays(-1);
        closedTask.End_Date__c = Datetime.now().addDays(1);
        closedTask.Status = 'Completed';
        closedTask.Account_Treatment_Job__c = ATJ.Id;
        closedTask.Related_SLA__c = SLA.Id;
        closedTask.Autoscheduled__c = true;
        insert closedTask;

        Case c2 = TestDataFactory.createCase();
        c2.AccountId = a.Id;
        c2.Account_Treatment__c = accountTreatment.Id;
        c2.Account_Treatment_Job__c = ATJ.Id;
        c2.Status = 'New';
        c2.Autoscheduled__c = true;
        c2.External_Id__c = 'TASK_TEST_2';
        insert c2;

        Task t = TestDataFactory.createTask();
        t.WhatId = c2.Id;
        t.ActivityDate = Date.today();
        t.Autoscheduled__c = true;
        t.Account_Treatment_Job__c = ATJ.Id;
        t.Due_Date__c = Datetime.now();
        t.Related_SLA__c = SLA.Id;
        t.Autoscheduled__c = true;
        insert t;

        System.debug('----- TEST TASK ID: ' + t.Id);
        System.debug('----- TEST TASK SLA: ' + t.Related_SLA__c);

        Test.startTest();

        Id batchProcessId = Database.executeBatch(new ActivitiesDatesAdjustmentBatch(), 100);

        Test.stopTest();

        AsyncApexJob aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors 
                            FROM AsyncApexJob WHERE Id =: batchProcessId ];

        System.assert(aaj != null);
    }

    @isTest
    static void WOTest(){
        List<Case> casesToInsert = new List<Case>();
        List<WorkOrder> workOrdersToInsert = new List<WorkOrder>();

        Account a = TestDataFactory.createPersonAccount();
        insert a;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        insert CTJ;

        Contract_Treatment_Job_SLA__c SLA = TestDataFactory.createFullCalendarSLA(CTJ.Id);
        insert SLA;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(a);
        accountTreatment.Business_Line__c = null;
        accountTreatment.Treatment_Type__c = null;
        insert accountTreatment;

        Account_Treatment_Job__c ATJ = TestDataFactory.createAccountTreatmentJob(accountTreatment.Id);
        ATJ.Contract_Treatment_Job__c = CTJ.Id;
        ATJ.Work_Order__c = true;
        ATJ.Frequency__c = 1;
        ATJ.Frequency_Unit_of_measure__c = 'Month';
        ATJ.Scheduling_Time_Frame__c = 365;
        ATJ.Frequency_Type__c = 'NPU';
        insert ATJ;

        Case c = TestDataFactory.createCase();
        c.AccountId = a.Id;
        c.Account_Treatment_Job__c = ATJ.Id;
        c.Account_Treatment__c = accountTreatment.Id;
        c.Status = 'Closed';
        c.Autoscheduled__c = true;
        c.ExcludeFromAdjustment__c = false;
        c.External_Id__c = 'TASK_TEST_3';
        casesToInsert.add(c);

        Case c2 = TestDataFactory.createCase();
        c2.AccountId = a.Id;
        c2.Account_Treatment_Job__c = ATJ.Id;
        c2.Account_Treatment__c = accountTreatment.Id;
        c2.Status = 'New';
        c2.Autoscheduled__c = true;
        c2.External_Id__c = 'TASK_TEST_4';
        casesToInsert.add(c2);

        insert casesToInsert;

        WorkOrder closedWorkOrder = TestDataFactory.createWorkOrder();
        closedWorkOrder.Due_Date__c = Datetime.now();
        closedWorkOrder.EndDate = Datetime.now().addDays(1);
        closedWorkOrder.CaseId = c.Id;
        closedWorkOrder.Related_SLA__c = SLA.Id;
        closedWorkOrder.Account_Treatment_Job__c = ATJ.Id;
        closedWorkOrder.Autoscheduled__c = true;
        workOrdersToInsert.add(closedWorkOrder);

        WorkOrder wo = TestDataFactory.createWorkOrder();
        wo.CaseId = c2.Id;
        wo.Status = 'New';
        wo.Autoscheduled__c = true;
        wo.Due_Date__c = Date.today();
        wo.Related_SLA__c = SLA.Id;
        wo.Account_Treatment_Job__c = ATJ.Id;
        wo.Autoscheduled__c = true;
        workOrdersToInsert.add(wo);

        insert workOrdersToInsert;

        Test.startTest();

        Id batchProcessId = Database.executeBatch(new ActivitiesDatesAdjustmentBatch(), 100);

        Test.stopTest();

        AsyncApexJob aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors 
                            FROM AsyncApexJob WHERE Id =: batchProcessId ];

        
        System.assert(aaj != null);
    }

    @isTest
    static void taskAndWOTest(){
        List<Case> casesToInsert = new List<Case>();
        List<WorkOrder> workOrdersToInsert = new List<WorkOrder>();

        Account a = TestDataFactory.createPersonAccount();
        insert a;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        insert CTJ;

        Contract_Treatment_Job_SLA__c SLA = TestDataFactory.createFullCalendarSLA(CTJ.Id);
        insert SLA;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(a);
        accountTreatment.Business_Line__c = null;
        accountTreatment.Treatment_Type__c = null;
        insert accountTreatment;

        Account_Treatment_Job__c ATJ = TestDataFactory.createAccountTreatmentJob(accountTreatment.Id);
        ATJ.Contract_Treatment_Job__c = CTJ.Id;
        ATJ.Task__c = true;
        ATJ.Work_Order__c = true;
        ATJ.Frequency__c = 1;
        ATJ.Frequency_Unit_of_measure__c = 'Month';
        ATJ.Scheduling_Time_Frame__c = 365;
        ATJ.Frequency_Type__c = 'NPU';
        insert ATJ;

        Case c = TestDataFactory.createCase();
        c.AccountId = a.Id;
        c.Account_Treatment_Job__c = ATJ.Id;
        c.Account_Treatment__c = accountTreatment.Id;
        c.Status = 'Closed';
        c.Autoscheduled__c = true;
        c.ExcludeFromAdjustment__c = false;
        c.External_Id__c = 'TASK_TEST_5';
        casesToInsert.add(c);

        Case c2 = TestDataFactory.createCase();
        c2.AccountId = a.Id;
        c2.Account_Treatment_Job__c = ATJ.Id;
        c2.Account_Treatment__c = accountTreatment.Id;
        c2.Status = 'New';
        c2.Autoscheduled__c = true;
        c2.External_Id__c = 'TASK_TEST_6';
        casesToInsert.add(c2);

        insert casesToInsert;

        WorkOrder closedWorkOrder = TestDataFactory.createWorkOrder();
        closedWorkOrder.Due_Date__c = Datetime.now();
        closedWorkOrder.EndDate = Datetime.now().addDays(1);
        closedWorkOrder.CaseId = c.Id;
        closedWorkOrder.Related_SLA__c = SLA.Id;
        closedWorkOrder.Account_Treatment__c = accountTreatment.Id;
        closedWorkOrder.Account_Treatment_Job__c = ATJ.Id;
        closedWorkOrder.Autoscheduled__c = true;
        workOrdersToInsert.add(closedWorkOrder);

        WorkOrder wo = TestDataFactory.createWorkOrder();
        wo.CaseId = c2.Id;
        wo.Due_Date__c = Date.today();
        wo.Related_SLA__c = SLA.Id;
        wo.Autoscheduled__c = true;
        wo.Account_Treatment_Job__c = ATJ.Id;
        wo.Status = 'New';
        wo.Autoscheduled__c = true;
        workOrdersToInsert.add(wo);

        insert workOrdersToInsert;

        Task t = TestDataFactory.createTask();
        t.WhatId = c2.Id;
        t.ActivityDate = Date.today();
        t.Related_SLA__c = SLA.Id;
        t.Autoscheduled__c = true;
        t.Account_Treatment_Job__c = ATJ.Id;
        t.Due_Date__c = Datetime.now().addDays(1);
        insert t;

        Test.startTest();

        Id batchProcessId = Database.executeBatch(new ActivitiesDatesAdjustmentBatch(), 100);

        Test.stopTest();

        AsyncApexJob aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors 
                            FROM AsyncApexJob WHERE Id =: batchProcessId ];

        
        System.assert(aaj != null);
    }
}