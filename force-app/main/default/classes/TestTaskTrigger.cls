@isTest
public class TestTaskTrigger {
    @isTest
    static void dependentActivitiesSchedulingTest() {
        List<Account_Treatment_Job__c> ATJsToInsert = new List<Account_Treatment_Job__c>();
        List<Contract_Treatment_Job__c> CTJsToInsert = new List<Contract_Treatment_Job__c>();
        List<Product2> productsToInsert = new List<Product2>();

        Account account = TestDataFactory.createPersonAccount();
        insert account;

        Product2 product = TestDataFactory.createProduct();
        product.Type__c = 'ZJOB';
        product.Product_Code__c = 'productCode';
        productsToInsert.add(product);

        Product2 product1 = TestDataFactory.createProduct();
        product1.Type__c = 'ZJOB';
        product1.Product_Code__c = 'productCode1';
        productsToInsert.add(product1);

        insert productsToInsert;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        CTJ.Contract_Treatment_Job_Code__c = product.Id;
        CTJsToInsert.add(CTJ);

        Contract_Treatment_Job__c dependentCTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        dependentCTJ.Contract_Treatment_Job_Code__c = product1.Id;
        CTJsToInsert.add(dependentCTJ);

        insert CTJsToInsert;

        Contract_Treatment_Job_SLA__c SLA = TestDataFactory.createFullCalendarSLA(dependentCTJ.Id);
        SLA.Max_Time__c = 1;
        insert SLA;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(account);
        accountTreatment.Contract_Treatment__c = contractTreatment.Id;
        insert accountTreatment;

        Account_Treatment_Job__c ATJ = TestDataFactory.createAccountTreatmentJob(accountTreatment.Id);
        ATJ.Contract_Treatment_Job__c = CTJ.Id;
        ATJ.Task__c = true;
        ATJ.Work_Order__c = false;
        insert ATJ;

        Account_Treatment_Job__c dependentATJ = TestDataFactory.createAccountTreatmentJob(accountTreatment.Id);
        dependentATJ.Contract_Treatment_Job__c = dependentCTJ.Id;
        dependentATJ.Scheduling_Rule__c = 'Dependent Job Execution';
        dependentATJ.Account_Treatment_Job__c = ATJ.Id;
        dependentATJ.Task__c = true;
        dependentATJ.Work_Order__c = false;
        dependentATJ.Task_Type__c = 'Call';
        dependentATJ.Frequency__c = 1;
        dependentATJ.Frequency_Unit_of_measure__c = 'Month';
        dependentATJ.Scheduling_Time_Frame__c = 365;
        dependentATJ.Frequency_Type__c = 'NPU';
        ATJsToInsert.add(dependentATJ);

        insert ATJsToInsert;

        Case c = TestDataFactory.createCase();
        c.AccountId = account.Id;
        c.Account_Treatment__c = accountTreatment.Id;
        c.Account_Treatment_Job__c = ATJ.Id;
        c.External_Id__c = 'EXT_1_AAA';
        insert c;

        Task t = TestDataFactory.createTask();
        t.WhatId = c.Id;
        t.Account_Treatment_Job__c = ATJ.Id;
        t.ActivityDate = Date.today();
        insert t;

        t.Status = 'Completed';

        Test.startTest();

        Database.SaveResult result = Database.update(t);

        Test.stopTest();

        List<Task> createdTasks = [SELECT Id FROM Task WHERE Id !=: t.Id];

        System.assertEquals(12, createdTasks.size());
    }

    @isTest
    static void setOwnerTest() {
        Profile mulesoftProfile = [SELECT Id FROM Profile WHERE Name = 'System_Admin_Mulesoft' LIMIT 1];

        User u = TestDataFactory.initUser(mulesoftProfile);

        Case c = TestDataFactory.createCase();
        c.External_Id__c = 'EXT_1_AAA';
        insert c;

        Task t = TestDataFactory.createTask();
        t.WhatId = c.Id;
        t.ActivityDate = Date.today();

        System.runAs(u) {
            Test.startTest();

            insert t;

            Test.stopTest();
        }

        Case queriedCase = [SELECT OwnerId FROM Case WHERE Id =: c.Id];
        Task queriedTask = [SELECT OwnerId FROM Task WHERE Id =: t.Id];

        System.assert(queriedTask.OwnerId != null);
        System.assertEquals(queriedCase.OwnerId, queriedTask.OwnerId);
    }

    @isTest
    static void updateCaseStartDateTest() {
        Case c = TestDataFactory.createCase();
        c.External_Id__c = 'EXT_1_AAA';
        c.Start_Date__c = Date.today().addDays(2);
        insert c;

        WorkOrder wo = TestDataFactory.createWorkOrder();
        wo.CaseId = c.Id;
        wo.StartDate = Date.today().addDays(2);
        insert wo;

        Task t = TestDataFactory.createTask();
        t.WhatId = c.Id;
        t.ActivityDate = Date.today().addDays(2);
        insert t;

        Test.startTest();

        t.ActivityDate = Date.today();
        Database.SaveResult result = Database.update(t);
        
        Test.stopTest();

        Case queriedCase = [SELECT Start_Date__c FROM Case WHERE Id =: c.Id];

        System.assert(result.isSuccess());
    } 

    @isTest
    static void checkCaseStatusTest() {
        List<Account_Treatment_Job__c> ATJsToInsert = new List<Account_Treatment_Job__c>();
        List<Contract_Treatment_Job__c> CTJsToInsert = new List<Contract_Treatment_Job__c>();
        List<Product2> productsToInsert = new List<Product2>();

        Account account = TestDataFactory.createPersonAccount();
        insert account;

        Product2 product = TestDataFactory.createProduct();
        product.Type__c = 'ZJOB';
        product.Product_Code__c = 'productCode';
        productsToInsert.add(product);

        Product2 product1 = TestDataFactory.createProduct();
        product1.Type__c = 'ZJOB';
        product1.Product_Code__c = 'productCode1';
        productsToInsert.add(product1);

        insert productsToInsert;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        CTJ.Contract_Treatment_Job_Code__c = product.Id;
        CTJsToInsert.add(CTJ);

        Contract_Treatment_Job__c dependentCTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        dependentCTJ.Contract_Treatment_Job_Code__c = product1.Id;
        CTJsToInsert.add(dependentCTJ);

        insert CTJsToInsert;

        Contract_Treatment_Job_SLA__c SLA = TestDataFactory.createFullCalendarSLA(dependentCTJ.Id);
        SLA.Max_Time__c = 1;
        insert SLA;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(account);
        accountTreatment.Contract_Treatment__c = contractTreatment.Id;
        insert accountTreatment;

        Account_Treatment_Job__c ATJ = TestDataFactory.createAccountTreatmentJob(accountTreatment.Id);
        ATJ.Contract_Treatment_Job__c = CTJ.Id;
        ATJ.Task__c = true;
        ATJ.Work_Order__c = false;
        insert ATJ;

        Account_Treatment_Job__c dependentATJ = TestDataFactory.createAccountTreatmentJob(accountTreatment.Id);
        dependentATJ.Contract_Treatment_Job__c = dependentCTJ.Id;
        dependentATJ.Scheduling_Rule__c = 'Dependent Job Execution';
        dependentATJ.Account_Treatment_Job__c = ATJ.Id;
        dependentATJ.Task__c = true;
        dependentATJ.Work_Order__c = false;
        dependentATJ.Task_Type__c = 'Call';
        dependentATJ.Frequency__c = 1;
        dependentATJ.Frequency_Unit_of_measure__c = 'Month';
        dependentATJ.Scheduling_Time_Frame__c = 365;
        dependentATJ.Frequency_Type__c = 'NPU';
        ATJsToInsert.add(dependentATJ);

        insert ATJsToInsert;

        Case c = TestDataFactory.createCase();
        c.AccountId = account.Id;
        c.Account_Treatment__c = accountTreatment.Id;
        c.Account_Treatment_Job__c = ATJ.Id;
        c.External_Id__c = 'EXT_1_AAA';
        insert c;

        Task t = TestDataFactory.createTask();
        t.WhatId = c.Id;
        t.Account_Treatment_Job__c = ATJ.Id;
        t.ActivityDate = Date.today();
        insert t;

        t.Status = 'Completed';
        update t;

        c.Status = 'Closed';
        update c;

        t.Status = 'Open';

        Test.startTest();

        Database.SaveResult result = Database.update(t, false);

        Test.stopTest();

        System.assert(!result.isSuccess());
    }
}