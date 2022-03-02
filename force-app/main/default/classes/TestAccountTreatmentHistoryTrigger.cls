@isTest
public class TestAccountTreatmentHistoryTrigger {
    @isTest
    static void complianceTest() {
        List<Account_Treatment_Job__c> ATJsToInsert = new List<Account_Treatment_Job__c>();
        List<Contract_Treatment_Job__c> CTJsToInsert = new List<Contract_Treatment_Job__c>();
        List<Product2> productsToInsert = new List<Product2>();
        List<Contract_Treatment_Job_SLA__c> SLAsToInsert = new List<Contract_Treatment_Job_SLA__c>();
        List<Case> casesToInsert = new List<Case>();
        List<WorkOrder> WOsToInsert = new List<WorkOrder>();

        RecordType complianceRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'AccountTreatmentHistory_ComplianceRegistration'];
        //Account_Treatment__c accountTreatment = [SELECT Id FROM Account_Treatment__c][0];

        Product2 product = TestDataFactory.createProduct();
        product.Type__c = 'ZJOB';
        product.Product_Code__c = 'testCode';
        productsToInsert.add(product);

        Product2 product2 = TestDataFactory.createProduct();
        product2.Type__c = 'ZJOB';
        product2.Product_Code__c = 'testCode2';
        productsToInsert.add(product2);

        Product2 product3 = TestDataFactory.createProduct();
        product3.Type__c = 'ZJOB';
        product3.Product_Code__c = 'testCode3';
        productsToInsert.add(product3);

        insert productsToInsert;

        Account account = TestDataFactory.createPersonAccount();
        insert account;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        CTJ.ComplianceFollowUp__c = true;
        CTJ.Contract_Treatment_Job_Code__c = product.Id;
        CTJsToInsert.add(CTJ);

        Contract_Treatment_Job__c CTJ2 = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        CTJ2.ComplianceFollowUp__c = true;
        CTJ2.Contract_Treatment_Job_Code__c = product2.Id;
        CTJsToInsert.add(CTJ2);

        Contract_Treatment_Job__c CTJ3 = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        CTJ3.ComplianceFollowUp__c = true;
        CTJ3.Contract_Treatment_Job_Code__c = product3.Id;
        CTJsToInsert.add(CTJ3);

        insert CTJsToInsert;

        Contract_Treatment_Job_SLA__c SLACalendarDay = TestDataFactory.createSLA(CTJ.Id);
        SLACalendarDay.Offset_End_Date__c = 7;
        SLACalendarDay.Offset_Start_Date__c = 7;
        SLACalendarDay.Offset_calculation_mode__c = 'Calendar';
        SLACalendarDay.Offset_unit_of_measure__c = 'Day';
        SLACalendarDay.Task_MaxTime_Execution__c = 7;
        SLACalendarDay.Task_Calculation_Mode__c = 'Calendar';
        SLACalendarDay.Task_Unite_of_measure_Max_Time__c = 'Day';
        SLAsToInsert.add(SLACalendarDay);

        Contract_Treatment_Job_SLA__c SLABusinessDay = TestDataFactory.createSLA(CTJ2.Id);
        SLABusinessDay.Offset_End_Date__c = 7;
        SLABusinessDay.Offset_Start_Date__c = 7;
        SLABusinessDay.Offset_calculation_mode__c = 'Business';
        SLABusinessDay.Offset_unit_of_measure__c = 'Day';
        SLABusinessDay.Task_MaxTime_Execution__c = 7;
        SLABusinessDay.Task_Calculation_Mode__c = 'Business';
        SLABusinessDay.Task_Unite_of_measure_Max_Time__c = 'Day';
        SLAsToInsert.add(SLABusinessDay);
        
        Contract_Treatment_Job_SLA__c SLACalendarWeek= TestDataFactory.createSLA(CTJ3.Id);
        SLACalendarWeek.Offset_End_Date__c = 7;
        SLACalendarWeek.Offset_Start_Date__c = 7;
        SLACalendarWeek.Offset_calculation_mode__c = 'Calendar';
        SLACalendarWeek.Offset_unit_of_measure__c = 'Week';
        SLACalendarWeek.Task_MaxTime_Execution__c = 7;
        SLACalendarWeek.Task_Calculation_Mode__c = 'Calendar';
        SLACalendarWeek.Task_Unite_of_measure_Max_Time__c = 'Week';
        SLAsToInsert.add(SLACalendarWeek);

        insert SLAsToInsert;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(account);
        accountTreatment.Contract_Treatment__c = contractTreatment.Id;
        insert accountTreatment;

        Account_Treatment_Address__c ATA = TestDataFactory.createATA(accountTreatment);
        ATA.Start_Date__c = Date.today();
        ATA.End_Date__c = Date.today().addMonths(1);
        insert ATA;

        Account_Treatment_Address__c ATA2 = TestDataFactory.createATA(accountTreatment);
        ATA2.Default__c = true;
        insert ATA2;

        Account_Treatment_Job__c atjWOYear = TestDataFactory.createAccountTreatmentJob(accountTreatment.Id);
        atjWOYear.Contract_Treatment_Job__c = CTJ.Id;
        atjWOYear.ComplianceSource__c = 'PH';
        atjWOYear.Task__c = false;
        atjWOYear.Work_Order__c = true;
        atjWOYear.Frequency__c = 6;
        atjWOYear.Frequency_Unit_of_measure__c = 'Year';
        atjWOYear.Scheduling_Rule__c = 'Compliance Registration';
        atjWOYear.Scheduling_Time_Frame__c = 365;
        atjWOYear.Frequency_Type__c = 'NPU';
        ATJsToInsert.add(atjWOYear);

        Account_Treatment_Job__c atjWOMonth = TestDataFactory.createAccountTreatmentJob(accountTreatment.Id);
        atjWOMonth.Contract_Treatment_Job__c = CTJ2.Id;
        atjWOMonth.ComplianceSource__c = 'PH';
        atjWOMonth.Task__c = false;
        atjWOMonth.Work_Order__c = true;
        atjWOMonth.Frequency__c = 3;
        atjWOMonth.Frequency_Unit_of_measure__c = 'Month';
        atjWOMonth.Scheduling_Time_Frame__c = 365;
        atjWOMonth.Frequency_Type__c = 'NPU';
        ATJsToInsert.add(atjWOMonth);

        Account_Treatment_Job__c atjWOWeek = TestDataFactory.createAccountTreatmentJob(accountTreatment.Id);
        atjWOWeek.Contract_Treatment_Job__c = CTJ3.Id;
        atjWOWeek.ComplianceSource__c = 'PH';
        atjWOWeek.Task__c = false;
        atjWOWeek.Work_Order__c = true;
        atjWOWeek.Frequency__c = 2;
        atjWOWeek.Frequency_Unit_of_measure__c = 'Week';
        atjWOWeek.Scheduling_Time_Frame__c = 365;
        atjWOWeek.Frequency_Type__c = 'NPU';
        ATJsToInsert.add(atjWOWeek);

        insert ATJsToInsert;

        Case caseWOYear = TestDataFactory.createCase();
        caseWOYear.Status = 'New';
        caseWOYear.Origin = 'System';
        caseWOYear.AccountId = account.Id;
        caseWOYear.Patient__c = account.Id;
        caseWOYear.External_Id__c = '5';
        caseWOYear.Contract_Treatment__c = contractTreatment.Id;
        caseWOYear.Account_Treatment__c = atjWOYear.Patient_Treatment__c;
        caseWOYear.Account_Treatment_Job__c = atjWOYear.Id;
        caseWOYear.Start_Date__c = Datetime.now();
        caseWOYear.Autoscheduled__c = true;
        casesToInsert.add(caseWOYear);

        Case caseWOMonth = TestDataFactory.createCase();
        caseWOMonth.Status = 'New';
        caseWOMonth.Origin = 'System';
        caseWOMonth.AccountId = account.Id;
        caseWOMonth.Patient__c = account.Id;
        caseWOMonth.External_Id__c = '6';
        caseWOMonth.Contract_Treatment__c = contractTreatment.Id;
        caseWOMonth.Account_Treatment__c = atjWOMonth.Patient_Treatment__c;
        caseWOMonth.Account_Treatment_Job__c = atjWOMonth.Id;
        caseWOMonth.Start_Date__c = Datetime.now();
        caseWOMonth.Autoscheduled__c = true;
        casesToInsert.add(caseWOMonth);

        Case caseWOWeek = TestDataFactory.createCase();
        caseWOWeek.Status = 'New';
        caseWOWeek.Origin = 'System';
        caseWOWeek.AccountId = account.Id;
        caseWOWeek.Patient__c = account.Id;
        caseWOWeek.External_Id__c = '7';
        caseWOWeek.Contract_Treatment__c = contractTreatment.Id;
        caseWOWeek.Account_Treatment__c = atjWOWeek.Patient_Treatment__c;
        caseWOWeek.Account_Treatment_Job__c = atjWOWeek.Id;
        caseWOWeek.Start_Date__c = Datetime.now();
        caseWOWeek.Autoscheduled__c = true;
        casesToInsert.add(caseWOWeek);

        insert casesToInsert;

        WorkOrder wo = TestDataFactory.createWorkOrder();
        wo.CaseId = caseWOYear.Id;
        wo.Account_Treatment_Job__c = atjWOYear.Id;
        wo.Account_Treatment__c = accountTreatment.Id;
        wo.Related_SLA__c = SLACalendarDay.Id;
        wo.Autoscheduled__c = true;
        wo.StartDate = Datetime.now();
        wo.Due_Date__c = Datetime.now().addDays(3);
        WOsToInsert.add(wo);

        WorkOrder assignedWO = TestDataFactory.createWorkOrder();
        assignedWO.CaseId = caseWOYear.Id;
        assignedWO.Account_Treatment_Job__c = atjWOYear.Id;
        assignedWO.Account_Treatment__c = accountTreatment.Id;
        assignedWO.Related_SLA__c = SLACalendarDay.Id;
        assignedWO.Autoscheduled__c = true;
        assignedWO.Status = 'Assigned';
        assignedWO.StartDate = Datetime.now();
        assignedWO.Due_Date__c = Datetime.now().addDays(3);
        WOsToInsert.add(assignedWO);

        WorkOrder welcomeAssignedWO = TestDataFactory.createWorkOrder();
        welcomeAssignedWO.CaseId = caseWOYear.Id;
        welcomeAssignedWO.Account_Treatment_Job__c = atjWOYear.Id;
        welcomeAssignedWO.Account_Treatment__c = accountTreatment.Id;
        welcomeAssignedWO.Related_SLA__c = SLACalendarDay.Id;
        welcomeAssignedWO.Autoscheduled__c = true;
        welcomeAssignedWO.Status = 'Assigned';
        welcomeAssignedWO.Delivery_Type__c = 'Welcome Model';
        welcomeAssignedWO.StartDate = Datetime.now();
        welcomeAssignedWO.Due_Date__c = Datetime.now().addDays(3);
        WOsToInsert.add(welcomeAssignedWO);

        WorkOrder wo2 = TestDataFactory.createWorkOrder();
        wo2.CaseId = caseWOMonth.Id;
        wo2.Account_Treatment_Job__c = atjWOMonth.Id;
        wo2.Related_SLA__c = SLABusinessDay.Id;
        wo2.Autoscheduled__c = true;
        wo2.StartDate = Datetime.now();
        wo2.Due_Date__c = Datetime.now().addDays(3);
        WOsToInsert.add(wo2);

        WorkOrder wo3 = TestDataFactory.createWorkOrder();
        wo3.CaseId = caseWOWeek.Id;
        wo3.Account_Treatment_Job__c = atjWOWeek.Id;
        wo3.Related_SLA__c = SLACalendarWeek.Id;
        wo3.Autoscheduled__c = true;
        wo3.StartDate = Datetime.now();
        wo3.Due_Date__c = Datetime.now().addDays(3);
        WOsToInsert.add(wo3);

        Test.startTest();

        insert WOsToInsert;

        Account_Treatment_History__c ath = TestDataFactory.createATH();
        ath.RecordTypeId = complianceRT.Id;
        ath.NotCompliant__c = false;
        ath.PlannedComplianceRegistration__c = false;
        ath.Account_Treatment__c = accountTreatment.Id;
        ath.ComplianceSource__c = 'PH';

        Database.SaveResult result = Database.insert(ath);

        Test.stopTest();

        List<Case> cases = [SELECT Id FROM Case];
        //List<Task> tasks = [SELECT Id FROM Task];
        List<WorkOrder> workOrders = [SELECT Id FROM WorkOrder];

        System.assert(result.isSuccess());
        System.assert(cases.size() > 12);
        //System.assert(tasks.size() == 12);
        System.assert(workOrders.size() > 12);
    }

    @isTest
    static void complianceTest2() {
        List<Account_Treatment_Job__c> ATJsToInsert = new List<Account_Treatment_Job__c>();
        List<Contract_Treatment_Job__c> CTJsToInsert = new List<Contract_Treatment_Job__c>();
        List<Product2> productsToInsert = new List<Product2>();
        List<Contract_Treatment_Job_SLA__c> SLAsToInsert = new List<Contract_Treatment_Job_SLA__c>();
        List<Case> casesToInsert = new List<Case>();
        List<WorkOrder> WOsToInsert = new List<WorkOrder>();
        List<Task> tasksToInsert = new List<Task>();

        RecordType complianceRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'AccountTreatmentHistory_ComplianceRegistration'];
        //Account_Treatment__c accountTreatment = [SELECT Id FROM Account_Treatment__c][1];

        Product2 product4 = TestDataFactory.createProduct();
        product4.Type__c = 'ZJOB';
        product4.Product_Code__c = 'testCode4';
        productsToInsert.add(product4);

        Product2 product5 = TestDataFactory.createProduct();
        product5.Type__c = 'ZJOB';
        product5.Product_Code__c = 'testCode5';
        productsToInsert.add(product5);

        Product2 product6 = TestDataFactory.createProduct();
        product6.Type__c = 'ZJOB';
        product6.Product_Code__c = 'testCode6';
        productsToInsert.add(product6);

        insert productsToInsert;

        Account account2 = TestDataFactory.createPersonAccount();
        insert account2;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ4 = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        CTJ4.ComplianceFollowUp__c = true;
        CTJ4.Contract_Treatment_Job_Code__c = product4.Id;
        CTJsToInsert.add(CTJ4);

        Contract_Treatment_Job__c CTJ5 = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        CTJ5.ComplianceFollowUp__c = true;
        CTJ5.Contract_Treatment_Job_Code__c = product5.Id;
        CTJsToInsert.add(CTJ5);

        Contract_Treatment_Job__c CTJ6 = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        CTJ6.ComplianceFollowUp__c = true;
        CTJ6.Contract_Treatment_Job_Code__c = product6.Id;
        CTJsToInsert.add(CTJ6);

        insert CTJsToInsert;

        Contract_Treatment_Job_SLA__c SLACalendarDay = TestDataFactory.createSLA(CTJ4.Id);
        SLACalendarDay.Offset_End_Date__c = 7;
        SLACalendarDay.Offset_End_Date_Task__c = 7;
        SLACalendarDay.Offset_Start_Date__c = 7;
        SLACalendarDay.Offset_Start_Date_Task__c = 7;
        SLACalendarDay.Offset_calculation_mode__c = 'Calendar';
        SLACalendarDay.Offset_calculation_mode_Task__c = 'Calendar';
        SLACalendarDay.Offset_unit_of_measure__c = 'Day';
        SLACalendarDay.Offset_unit_of_measure_Task__c = 'Day';
        SLACalendarDay.Task_MaxTime_Execution__c = 7;
        SLACalendarDay.Task_Calculation_Mode__c = 'Calendar';
        SLACalendarDay.Task_Unite_of_measure_Max_Time__c = 'Day';
        SLAsToInsert.add(SLACalendarDay);

        Contract_Treatment_Job_SLA__c SLABusinessDay = TestDataFactory.createSLA(CTJ5.Id);
        SLABusinessDay.Offset_End_Date__c = 7;
        SLABusinessDay.Offset_End_Date_Task__c = 7;
        SLABusinessDay.Offset_Start_Date__c = 7;
        SLABusinessDay.Offset_Start_Date_Task__c = 7;
        SLABusinessDay.Offset_calculation_mode__c = 'Business';
        SLABusinessDay.Offset_calculation_mode_Task__c = 'Business';
        SLABusinessDay.Offset_unit_of_measure__c = 'Day';
        SLABusinessDay.Offset_unit_of_measure_Task__c = 'Day';
        SLABusinessDay.Task_MaxTime_Execution__c = 7;
        SLABusinessDay.Task_Calculation_Mode__c = 'Business';
        SLABusinessDay.Task_Unite_of_measure_Max_Time__c = 'Day';
        SLAsToInsert.add(SLABusinessDay);

        Contract_Treatment_Job_SLA__c SLACalendarMonth = TestDataFactory.createSLA(CTJ6.Id);
        SLACalendarMonth.Offset_End_Date__c = 7;
        SLACalendarMonth.Offset_End_Date_Task__c = 7;
        SLACalendarMonth.Offset_Start_Date__c = 7;
        SLACalendarMonth.Offset_Start_Date_Task__c = 7;
        SLACalendarMonth.Offset_calculation_mode__c = 'Calendar';
        SLACalendarMonth.Offset_calculation_mode_Task__c = 'Calendar';
        SLACalendarMonth.Offset_unit_of_measure__c = 'Month';
        SLACalendarMonth.Offset_unit_of_measure_Task__c = 'Month';
        SLACalendarMonth.Task_MaxTime_Execution__c = 7;
        SLACalendarMonth.Task_Calculation_Mode__c = 'Calendar';
        SLACalendarMonth.Task_Unite_of_measure_Max_Time__c = 'Month';
        SLAsToInsert.add(SLACalendarMonth);

        insert SLAsToInsert;

        Account_Treatment__c accountTreatment2 = TestDataFactory.createMRDAccountTreatment(account2);
        accountTreatment2.Contract_Treatment__c = contractTreatment.Id;
        insert accountTreatment2;

        Account_Treatment_Job__c atjWODay = TestDataFactory.createAccountTreatmentJob(accountTreatment2.Id);
        atjWODay.Contract_Treatment_Job__c = CTJ4.Id;
        atjWODay.ComplianceSource__c = 'PH';
        atjWODay.Task__c = false;
        atjWODay.Work_Order__c = true;
        atjWODay.Frequency__c = 1;
        atjWODay.Frequency_Unit_of_measure__c = 'Day';
        atjWODay.Scheduling_Time_Frame__c = 365;
        atjWODay.Frequency_Type__c = 'NPU';
        ATJsToInsert.add(atjWODay);

        Account_Treatment_Job__c atjTaskYear = TestDataFactory.createAccountTreatmentJob(accountTreatment2.Id);
        atjTaskYear.Contract_Treatment_Job__c = CTJ5.Id;
        atjTaskYear.ComplianceSource__c = 'PH';
        atjTaskYear.Task__c = true;
        atjTaskYear.Work_Order__c = false;
        atjTaskYear.Frequency__c = 6;
        atjTaskYear.Frequency_Unit_of_measure__c = 'Year';
        atjTaskYear.Scheduling_Time_Frame__c = 365;
        atjTaskYear.Frequency_Type__c = 'NPU';
        ATJsToInsert.add(atjTaskYear);

        Account_Treatment_Job__c atjTaskMonth = TestDataFactory.createAccountTreatmentJob(accountTreatment2.Id);
        atjTaskMonth.Contract_Treatment_Job__c = CTJ6.Id;
        atjTaskMonth.ComplianceSource__c = 'PH';
        atjTaskMonth.Task__c = true;
        atjTaskMonth.Work_Order__c = false;
        atjTaskMonth.Frequency__c = 3;
        atjTaskMonth.Frequency_Unit_of_measure__c = 'Month';
        atjTaskMonth.Scheduling_Time_Frame__c = 365;
        atjTaskMonth.Frequency_Type__c = 'NPU';
        ATJsToInsert.add(atjTaskMonth);

        insert ATJsToInsert;

        Case caseTaskYear = TestDataFactory.createCase();
        caseTaskYear.Status = 'New';
        caseTaskYear.Origin = 'System';
        caseTaskYear.AccountId = account2.Id;
        caseTaskYear.Patient__c = account2.Id;
        caseTaskYear.External_Id__c = '1';
        caseTaskYear.Contract_Treatment__c = contractTreatment.Id;
        caseTaskYear.Account_Treatment__c = atjTaskYear.Patient_Treatment__c;
        caseTaskYear.Account_Treatment_Job__c = atjTaskYear.Id;
        caseTaskYear.Start_Date__c = Datetime.now();
        caseTaskYear.Autoscheduled__c = true;
        casesToInsert.add(caseTaskYear);

        Case caseTaskMonth = TestDataFactory.createCase();
        caseTaskMonth.Status = 'New';
        caseTaskMonth.Origin = 'System';
        caseTaskMonth.AccountId = account2.Id;
        caseTaskMonth.Patient__c = account2.Id;
        caseTaskMonth.External_Id__c = '2';
        caseTaskMonth.Contract_Treatment__c = contractTreatment.Id;
        caseTaskMonth.Account_Treatment__c = atjTaskMonth.Patient_Treatment__c;
        caseTaskMonth.Account_Treatment_Job__c = atjTaskMonth.Id;
        caseTaskMonth.Start_Date__c = Datetime.now();
        caseTaskMonth.Autoscheduled__c = true;
        casesToInsert.add(caseTaskMonth);

        Case caseWODay = TestDataFactory.createCase();
        caseWODay.Status = 'New';
        caseWODay.Origin = 'System';
        caseWODay.AccountId = account2.id;
        caseWODay.Patient__c = account2.Id;
        caseWODay.External_Id__c = '8';
        caseWODay.Contract_Treatment__c = contractTreatment.Id;
        caseWODay.Account_Treatment__c = atjWODay.Patient_Treatment__c;
        caseWODay.Account_Treatment_Job__c = atjWODay.Id;
        caseWODay.Start_Date__c = Datetime.now();
        caseWODay.Autoscheduled__c = true;
        casesToInsert.add(caseWODay);

        insert casesToInsert;

        Task t = TestDataFactory.createTask();
        t.WhatId = caseTaskYear.Id;
        t.Account_Treatment_Job__c = atjTaskYear.Id;
        t.Related_SLA__c = SLACalendarDay.Id;
        t.Autoscheduled__c = true;
        t.Start_Date__c = Datetime.now();
        t.Due_Date__c = Datetime.now().addDays(3);
        t.Status = 'Open';
        tasksToInsert.add(t);

        Task t2 = TestDataFactory.createTask();
        t2.WhatId = caseTaskMonth.Id;
        t2.Account_Treatment_Job__c = atjTaskMonth.Id;
        t2.Related_SLA__c = SLABusinessDay.Id;
        t2.Autoscheduled__c = true;
        t2.Start_Date__c = Datetime.now();
        t2.Due_Date__c = Datetime.now().addDays(3);
        t2.Status = 'Open';
        tasksToInsert.add(t2);

        insert tasksToInsert;

        WorkOrder wo4 = TestDataFactory.createWorkOrder();
        wo4.CaseId = caseWODay.Id;
        wo4.Account_Treatment_Job__c = atjWODay.Id;
        wo4.Related_SLA__c = SLACalendarMonth.Id;
        wo4.Autoscheduled__c = true;
        wo4.StartDate = Datetime.now();
        wo4.Due_Date__c = Datetime.now().addDays(3);
        WOsToInsert.add(wo4);

        insert WOsToInsert;

        Account_Treatment_History__c ath = TestDataFactory.createATH();
        ath.RecordTypeId = complianceRT.Id;
        ath.NotCompliant__c = false;
        ath.PlannedComplianceRegistration__c = false;
        ath.Account_Treatment__c = accountTreatment2.Id;
        ath.ComplianceSource__c = 'PH';

        Test.startTest();

        Database.SaveResult result = Database.insert(ath);

        Test.stopTest();

        List<Case> cases = [SELECT Id FROM Case];
        List<Task> tasks = [SELECT Id FROM Task];
        List<WorkOrder> workOrders = [SELECT Id FROM WorkOrder];

        System.assert(result.isSuccess());
        System.assert(cases.size() > 12);
        System.assert(tasks.size() > 10);
        System.assert(workOrders.size() > 12);
    }

    @isTest
    static void complianceTest3() {
        List<Account_Treatment_Job__c> ATJsToInsert = new List<Account_Treatment_Job__c>();
        List<Contract_Treatment_Job__c> CTJsToInsert = new List<Contract_Treatment_Job__c>();
        List<Product2> productsToInsert = new List<Product2>();
        List<Contract_Treatment_Job_SLA__c> SLAsToInsert = new List<Contract_Treatment_Job_SLA__c>();
        List<Case> casesToInsert = new List<Case>();
        List<WorkOrder> WOsToInsert = new List<WorkOrder>();
        List<Task> tasksToInsert = new List<Task>();

        RecordType complianceRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'AccountTreatmentHistory_ComplianceRegistration'];
        //Account_Treatment__c accountTreatment = [SELECT Id FROM Account_Treatment__c][2];

        Product2 product7 = TestDataFactory.createProduct();
        product7.Type__c = 'ZJOB';
        product7.Product_Code__c = 'testCode7';
        productsToInsert.add(product7);

        Product2 product8 = TestDataFactory.createProduct();
        product8.Type__c = 'ZJOB';
        product8.Product_Code__c = 'testCode8';
        productsToInsert.add(product8);

        Product2 product9 = TestDataFactory.createProduct();
        product9.Type__c = 'ZJOB';
        product9.Product_Code__c = 'testCode9';
        productsToInsert.add(product9);

        insert productsToInsert;

        Account account3 = TestDataFactory.createPersonAccount();
        insert account3;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ7 = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        CTJ7.ComplianceFollowUp__c = true;
        CTJ7.Contract_Treatment_Job_Code__c = product7.Id;
        CTJsToInsert.add(CTJ7);

        Contract_Treatment_Job__c CTJ8 = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        CTJ8.ComplianceFollowUp__c = true;
        CTJ8.Contract_Treatment_Job_Code__c = product8.Id;
        CTJsToInsert.add(CTJ8);

        Contract_Treatment_Job__c CTJ9 = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        CTJ9.ComplianceFollowUp__c = true;
        CTJ9.Contract_Treatment_Job_Code__c = product9.Id;
        CTJsToInsert.add(CTJ9);

        insert CTJsToInsert;

        Contract_Treatment_Job_SLA__c SLACalendarWeek= TestDataFactory.createSLA(CTJ7.Id);
        SLACalendarWeek.Offset_End_Date__c = 7;
        SLACalendarWeek.Offset_End_Date_Task__c = 7;
        SLACalendarWeek.Offset_Start_Date__c = 7;
        SLACalendarWeek.Offset_Start_Date_Task__c = 7;
        SLACalendarWeek.Offset_calculation_mode__c = 'Calendar';
        SLACalendarWeek.Offset_calculation_mode_Task__c = 'Calendar';
        SLACalendarWeek.Offset_unit_of_measure__c = 'Week';
        SLACalendarWeek.Offset_unit_of_measure_Task__c = 'Week';
        SLACalendarWeek.Task_MaxTime_Execution__c = 7;
        SLACalendarWeek.Task_Calculation_Mode__c = 'Calendar';
        SLACalendarWeek.Task_Unite_of_measure_Max_Time__c = 'Week';
        SLAsToInsert.add(SLACalendarWeek);

        Contract_Treatment_Job_SLA__c SLACalendarMonth = TestDataFactory.createSLA(CTJ8.Id);
        SLACalendarMonth.Offset_End_Date__c = 7;
        SLACalendarMonth.Offset_End_Date_Task__c = 7;
        SLACalendarMonth.Offset_Start_Date__c = 7;
        SLACalendarMonth.Offset_Start_Date_Task__c = 7;
        SLACalendarMonth.Offset_calculation_mode__c = 'Calendar';
        SLACalendarMonth.Offset_calculation_mode_Task__c = 'Calendar';
        SLACalendarMonth.Offset_unit_of_measure__c = 'Month';
        SLACalendarMonth.Offset_unit_of_measure_Task__c = 'Month';
        SLACalendarMonth.Task_MaxTime_Execution__c = 7;
        SLACalendarMonth.Task_Calculation_Mode__c = 'Calendar';
        SLACalendarMonth.Task_Unite_of_measure_Max_Time__c = 'Month';
        SLAsToInsert.add(SLACalendarMonth);

        Contract_Treatment_Job_SLA__c SLACalendarDay = TestDataFactory.createSLA(CTJ9.Id);
        SLACalendarDay.Offset_End_Date__c = 7;
        SLACalendarDay.Offset_End_Date_Task__c = 7;
        SLACalendarDay.Offset_Start_Date__c = 7;
        SLACalendarDay.Offset_Start_Date_Task__c = 7;
        SLACalendarDay.Offset_calculation_mode__c = 'Calendar';
        SLACalendarDay.Offset_calculation_mode_Task__c = 'Calendar';
        SLACalendarDay.Offset_unit_of_measure__c = 'Day';
        SLACalendarDay.Offset_unit_of_measure_Task__c = 'Day';
        SLACalendarDay.Task_MaxTime_Execution__c = 7;
        SLACalendarDay.Task_Calculation_Mode__c = 'Calendar';
        SLACalendarDay.Task_Unite_of_measure_Max_Time__c = 'Day';
        SLAsToInsert.add(SLACalendarDay);

        Contract_Treatment_Job_SLA__c SLABusinessHour = TestDataFactory.createSLA(CTJ7.Id);
        SLABusinessHour.Offset_End_Date__c = 7;
        SLABusinessHour.Offset_End_Date_Task__c = 7;
        SLABusinessHour.Offset_Start_Date__c = 7;
        SLABusinessHour.Offset_Start_Date_Task__c = 7;
        SLABusinessHour.Offset_calculation_mode__c = 'Business';
        SLABusinessHour.Offset_calculation_mode_Task__c = 'Business';
        SLABusinessHour.Offset_unit_of_measure__c = 'Hour';
        SLABusinessHour.Offset_unit_of_measure_Task__c = 'Hour';
        SLABusinessHour.Task_MaxTime_Execution__c = 7;
        SLABusinessHour.Task_Calculation_Mode__c = 'Business';
        SLABusinessHour.Task_Unite_of_measure_Max_Time__c = 'Hour';
        SLAsToInsert.add(SLABusinessHour);

        insert SLAsToInsert;

        Account_Treatment__c accountTreatment3 = TestDataFactory.createMRDAccountTreatment(account3);
        accountTreatment3.Contract_Treatment__c = contractTreatment.Id;
        insert accountTreatment3;

        Account_Treatment_Job__c atjTaskWeek = TestDataFactory.createAccountTreatmentJob(accountTreatment3.Id);
        atjTaskWeek.Contract_Treatment_Job__c = CTJ7.Id;
        atjTaskWeek.ComplianceSource__c = 'PH';
        atjTaskWeek.Task__c = true;
        atjTaskWeek.Work_Order__c = false;
        atjTaskWeek.Frequency__c = 2;
        atjTaskWeek.Frequency_Unit_of_measure__c = 'Week';
        atjTaskWeek.Scheduling_Time_Frame__c = 365;
        atjTaskWeek.Frequency_Type__c = 'NPU';
        ATJsToInsert.add(atjTaskWeek);

        Account_Treatment_Job__c atjTaskDay = TestDataFactory.createAccountTreatmentJob(accountTreatment3.Id);
        atjTaskDay.Contract_Treatment_Job__c = CTJ8.Id;
        atjTaskDay.ComplianceSource__c = 'PH';
        atjTaskDay.Task__c = true;
        atjTaskDay.Work_Order__c = false;
        atjTaskDay.Frequency__c = 1;
        atjTaskDay.Frequency_Unit_of_measure__c = 'Day';
        atjTaskDay.Scheduling_Time_Frame__c = 365;
        atjTaskDay.Frequency_Type__c = 'NPU';
        ATJsToInsert.add(atjTaskDay);

        Account_Treatment_Job__c atjTaskWOYear = TestDataFactory.createAccountTreatmentJob(accountTreatment3.Id);
        atjTaskWOYear.Contract_Treatment_Job__c = CTJ9.Id;
        atjTaskWOYear.ComplianceSource__c = 'PH';
        atjTaskWOYear.Task__c = true;
        atjTaskWOYear.Work_Order__c = true;
        atjTaskWOYear.Frequency__c = 6;
        atjTaskWOYear.Frequency_Unit_of_measure__c = 'Year';
        atjTaskWOYear.Scheduling_Time_Frame__c = 365;
        atjTaskWOYear.Frequency_Type__c = 'NPU';
        ATJsToInsert.add(atjTaskWOYear);

        insert ATJsToInsert;

        Case caseTaskWeek = TestDataFactory.createCase();
        caseTaskWeek.Status = 'New';
        caseTaskWeek.Origin = 'System';
        caseTaskWeek.AccountId = account3.Id;
        caseTaskWeek.Patient__c = account3.Id;
        caseTaskWeek.External_Id__c = '3';
        caseTaskWeek.Contract_Treatment__c = contractTreatment.Id;
        caseTaskWeek.Account_Treatment__c = atjTaskWeek.Patient_Treatment__c;
        caseTaskWeek.Account_Treatment_Job__c = atjTaskWeek.Id;
        caseTaskWeek.Start_Date__c = Datetime.now();
        caseTaskWeek.Autoscheduled__c = true;
        casesToInsert.add(caseTaskWeek);

        Case caseTaskDay = TestDataFactory.createCase();
        caseTaskDay.Status = 'New';
        caseTaskDay.Origin = 'System';
        caseTaskDay.AccountId = account3.Id;
        caseTaskDay.Patient__c = account3.Id;
        caseTaskDay.External_Id__c = '4';
        caseTaskDay.Contract_Treatment__c = contractTreatment.Id;
        caseTaskDay.Account_Treatment__c = atjTaskDay.Patient_Treatment__c;
        caseTaskDay.Account_Treatment_Job__c = atjTaskDay.Id;
        caseTaskDay.Start_Date__c = Datetime.now();
        caseTaskDay.Autoscheduled__c = true;
        casesToInsert.add(caseTaskDay);

        Case caseTaskWOYear = TestDataFactory.createCase();
        caseTaskWOYear.Status = 'New';
        caseTaskWOYear.Origin = 'System';
        caseTaskWOYear.AccountId = account3.Id;
        caseTaskWOYear.Patient__c = account3.Id;
        caseTaskWOYear.External_Id__c = '9';
        caseTaskWOYear.Contract_Treatment__c = contractTreatment.Id;
        caseTaskWOYear.Account_Treatment__c = atjTaskWOYear.Patient_Treatment__c;
        caseTaskWOYear.Account_Treatment_Job__c = atjTaskWOYear.Id;
        caseTaskWOYear.Start_Date__c = Datetime.now();
        caseTaskWOYear.Autoscheduled__c = true;
        casesToInsert.add(caseTaskWOYear);

        insert casesToInsert;

        Task t3 = TestDataFactory.createTask();
        t3.WhatId = caseTaskWeek.Id;
        t3.Account_Treatment_Job__c = atjTaskWeek.Id;
        t3.Related_SLA__c = SLACalendarWeek.Id;
        t3.Autoscheduled__c = true;
        t3.Start_Date__c = Datetime.now();
        t3.Due_Date__c = Datetime.now().addDays(3);
        t3.Status = 'Open';
        tasksToInsert.add(t3);

        Task t4 = TestDataFactory.createTask();
        t4.WhatId = caseTaskDay.Id;
        t4.Account_Treatment_Job__c = atjTaskDay.Id;
        t4.Related_SLA__c = SLACalendarMonth.Id;
        t4.Autoscheduled__c = true;
        t4.Start_Date__c = Datetime.now();
        t4.Due_Date__c = Datetime.now().addDays(3);
        t4.Status = 'Open';
        tasksToInsert.add(t4);

        Task t6 = TestDataFactory.createTask();
        t6.WhatId = caseTaskWOYear.Id;
        t6.Account_Treatment_Job__c = atjTaskWOYear.Id;
        t6.Related_SLA__c = SLACalendarDay.Id;
        t6.Autoscheduled__c = true;
        t6.Start_Date__c = Datetime.now();
        t6.Due_Date__c = Datetime.now().addDays(3);
        t6.Status = 'Open';
        tasksToInsert.add(t6);

        Task t10 = TestDataFactory.createTask();
        t10.WhatId = caseTaskWOYear.Id;
        t10.Account_Treatment_Job__c = atjTaskWOYear.Id;
        t10.Related_SLA__c = SLABusinessHour.Id;
        t10.Autoscheduled__c = true;
        t10.Start_Date__c = Datetime.now();
        t10.Due_Date__c = Datetime.now().addDays(3);
        t10.Status = 'Open';
        tasksToInsert.add(t10);

        insert tasksToInsert;

        WorkOrder wo6 = TestDataFactory.createWorkOrder();
        wo6.CaseId = caseTaskWOYear.Id;
        wo6.Account_Treatment_Job__c = atjTaskWOYear.Id;
        wo6.Related_SLA__c = SLACalendarDay.Id;
        wo6.Autoscheduled__c = true;
        wo6.StartDate = Datetime.now();
        wo6.Due_Date__c = Datetime.now().addDays(3);
        WOsToInsert.add(wo6);

        WorkOrder wo10 = TestDataFactory.createWorkOrder();
        wo10.CaseId = caseTaskWOYear.Id;
        wo10.Account_Treatment_Job__c = atjTaskWOYear.Id;
        wo10.Related_SLA__c = SLABusinessHour.Id;
        wo10.Autoscheduled__c = true;
        wo10.StartDate = Datetime.now();
        wo10.Due_Date__c = Datetime.now().addDays(3);
        WOsToInsert.add(wo10);

        insert WOsToInsert;

        Account_Treatment_History__c ath = TestDataFactory.createATH();
        ath.RecordTypeId = complianceRT.Id;
        ath.NotCompliant__c = false;
        ath.PlannedComplianceRegistration__c = false;
        ath.Account_Treatment__c = accountTreatment3.Id;
        ath.ComplianceSource__c = 'PH';

        Test.startTest();

        Database.SaveResult result = Database.insert(ath);

        Test.stopTest();

        List<Case> cases = [SELECT Id FROM Case];
        List<Task> tasks = [SELECT Id FROM Task];
        List<WorkOrder> workOrders = [SELECT Id FROM WorkOrder];

        System.assert(result.isSuccess());
        System.assert(cases.size() > 12);
        System.assert(tasks.size() > 10);
        //System.assert(workOrders.size() > 6);
    }

    /* @isTest
    static void complianceTest4() {
        RecordType complianceRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'AccountTreatmentHistory_ComplianceRegistration'];
        Account_Treatment__c accountTreatment = [SELECT Id FROM Account_Treatment__c][3];

        Account_Treatment_History__c ath = TestDataFactory.createATH();
        ath.RecordTypeId = complianceRT.Id;
        ath.NotCompliant__c = false;
        ath.PlannedComplianceRegistration__c = false;
        ath.Account_Treatment__c = accountTreatment.Id;
        ath.ComplianceSource__c = 'PH';

        Test.startTest();

        Database.SaveResult result = Database.insert(ath);

        Test.stopTest();

        List<Case> cases = [SELECT Id FROM Case];
        List<Task> tasks = [SELECT Id FROM Task];
        List<WorkOrder> workOrders = [SELECT Id FROM WorkOrder];

        System.assert(result.isSuccess());
        System.assert(cases.size() > 12);
        System.assert(tasks.size() > 10);
        System.assert(workOrders.size() > 12);
    } */

    @isTest
    static void noComplianceTest() {
        List<Account_Treatment_Job__c> ATJsToInsert = new List<Account_Treatment_Job__c>();
        List<Contract_Treatment_Job__c> CTJsToInsert = new List<Contract_Treatment_Job__c>();
        List<Product2> productsToInsert = new List<Product2>();
        List<Contract_Treatment_Job_SLA__c> SLAsToInsert = new List<Contract_Treatment_Job_SLA__c>();
        List<Case> casesToInsert = new List<Case>();
        List<WorkOrder> WOsToInsert = new List<WorkOrder>();

        RecordType complianceRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'AccountTreatmentHistory_ComplianceRegistration'];
        //Account_Treatment__c accountTreatment = [SELECT Id, Account__c FROM Account_Treatment__c][0];

        Product2 product = TestDataFactory.createProduct();
        product.Type__c = 'ZJOB';
        product.Product_Code__c = 'testCode';
        productsToInsert.add(product);

        Product2 product2 = TestDataFactory.createProduct();
        product2.Type__c = 'ZJOB';
        product2.Product_Code__c = 'testCode2';
        productsToInsert.add(product2);

        Product2 product3 = TestDataFactory.createProduct();
        product3.Type__c = 'ZJOB';
        product3.Product_Code__c = 'testCode3';
        productsToInsert.add(product3);

        insert productsToInsert;

        Account account = TestDataFactory.createPersonAccount();
        insert account;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        CTJ.ComplianceFollowUp__c = true;
        CTJ.Contract_Treatment_Job_Code__c = product.Id;
        CTJsToInsert.add(CTJ);

        Contract_Treatment_Job__c CTJ2 = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        CTJ2.ComplianceFollowUp__c = true;
        CTJ2.Contract_Treatment_Job_Code__c = product2.Id;
        CTJsToInsert.add(CTJ2);

        Contract_Treatment_Job__c CTJ3 = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        CTJ3.ComplianceFollowUp__c = true;
        CTJ3.Contract_Treatment_Job_Code__c = product3.Id;
        CTJsToInsert.add(CTJ3);

        insert CTJsToInsert;

        Contract_Treatment_Job_SLA__c SLACalendarDay = TestDataFactory.createSLA(CTJ.Id);
        SLACalendarDay.Offset_End_Date__c = 7;
        SLACalendarDay.Offset_End_Date_Task__c = 7;
        SLACalendarDay.Offset_Start_Date__c = 7;
        SLACalendarDay.Offset_Start_Date_Task__c = 7;
        SLACalendarDay.Offset_calculation_mode__c = 'Calendar';
        SLACalendarDay.Offset_calculation_mode_Task__c = 'Calendar';
        SLACalendarDay.Offset_unit_of_measure__c = 'Day';
        SLACalendarDay.Offset_unit_of_measure_Task__c = 'Day';
        SLACalendarDay.Task_MaxTime_Execution__c = 7;
        SLACalendarDay.Task_Calculation_Mode__c = 'Calendar';
        SLACalendarDay.Task_Unite_of_measure_Max_Time__c = 'Day';
        SLAsToInsert.add(SLACalendarDay);

        Contract_Treatment_Job_SLA__c SLABusinessDay = TestDataFactory.createSLA(CTJ2.Id);
        SLABusinessDay.Offset_End_Date__c = 7;
        SLABusinessDay.Offset_End_Date_Task__c = 7;
        SLABusinessDay.Offset_Start_Date__c = 7;
        SLABusinessDay.Offset_Start_Date_Task__c = 7;
        SLABusinessDay.Offset_calculation_mode__c = 'Business';
        SLABusinessDay.Offset_calculation_mode_Task__c = 'Business';
        SLABusinessDay.Offset_unit_of_measure__c = 'Day';
        SLABusinessDay.Offset_unit_of_measure_Task__c = 'Day';
        SLABusinessDay.Task_MaxTime_Execution__c = 7;
        SLABusinessDay.Task_Calculation_Mode__c = 'Business';
        SLABusinessDay.Task_Unite_of_measure_Max_Time__c = 'Day';
        SLAsToInsert.add(SLABusinessDay);
        
        Contract_Treatment_Job_SLA__c SLACalendarWeek= TestDataFactory.createSLA(CTJ3.Id);
        SLACalendarWeek.Offset_End_Date__c = 7;
        SLACalendarWeek.Offset_End_Date_Task__c = 7;
        SLACalendarWeek.Offset_Start_Date__c = 7;
        SLACalendarWeek.Offset_Start_Date_Task__c = 7;
        SLACalendarWeek.Offset_calculation_mode__c = 'Calendar';
        SLACalendarWeek.Offset_calculation_mode_Task__c = 'Calendar';
        SLACalendarWeek.Offset_unit_of_measure__c = 'Week';
        SLACalendarWeek.Offset_unit_of_measure_Task__c = 'Week';
        SLACalendarWeek.Task_MaxTime_Execution__c = 7;
        SLACalendarWeek.Task_Calculation_Mode__c = 'Calendar';
        SLACalendarWeek.Task_Unite_of_measure_Max_Time__c = 'Week';
        SLAsToInsert.add(SLACalendarWeek);

        insert SLAsToInsert;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(account);
        accountTreatment.Contract_Treatment__c = contractTreatment.Id;
        insert accountTreatment;

        Account_Treatment_Job__c atjWOYear = TestDataFactory.createAccountTreatmentJob(accountTreatment.Id);
        atjWOYear.Contract_Treatment_Job__c = CTJ.Id;
        atjWOYear.ComplianceSource__c = 'PH';
        atjWOYear.Task__c = false;
        atjWOYear.Work_Order__c = true;
        atjWOYear.Frequency__c = 6;
        atjWOYear.Frequency_Unit_of_measure__c = 'Year';
        atjWOYear.Scheduling_Rule__c = 'Compliance Registration';
        atjWOYear.Scheduling_Time_Frame__c = 365;
        atjWOYear.Frequency_Type__c = 'NPU';
        ATJsToInsert.add(atjWOYear);

        Account_Treatment_Job__c atjWOMonth = TestDataFactory.createAccountTreatmentJob(accountTreatment.Id);
        atjWOMonth.Contract_Treatment_Job__c = CTJ2.Id;
        atjWOMonth.ComplianceSource__c = 'PH';
        atjWOMonth.Task__c = true;
        atjWOMonth.Work_Order__c = false;
        atjWOMonth.Frequency__c = 3;
        atjWOMonth.Frequency_Unit_of_measure__c = 'Month';
        atjWOMonth.Scheduling_Rule__c = 'Compliance Registration';
        atjWOMonth.Scheduling_Time_Frame__c = 365;
        atjWOMonth.Frequency_Type__c = 'NPU';
        ATJsToInsert.add(atjWOMonth);

        Account_Treatment_Job__c atjWOWeek = TestDataFactory.createAccountTreatmentJob(accountTreatment.Id);
        atjWOWeek.Contract_Treatment_Job__c = CTJ3.Id;
        atjWOWeek.ComplianceSource__c = 'PH';
        atjWOWeek.Task__c = true;
        atjWOWeek.Work_Order__c = true;
        atjWOWeek.Frequency__c = 2;
        atjWOWeek.Frequency_Unit_of_measure__c = 'Week';
        atjWOWeek.Scheduling_Rule__c = 'Compliance Registration';
        atjWOWeek.Scheduling_Time_Frame__c = 365;
        atjWOWeek.Frequency_Type__c = 'NPU';
        ATJsToInsert.add(atjWOWeek);

        insert ATJsToInsert;

        Account_Treatment_Address__c ATA = TestDataFactory.createATA(accountTreatment);
        ATA.Default__c =  true;
        insert ATA;

        Case c = TestDataFactory.createCase();
        insert c;

        Account_Treatment_History__c ath = TestDataFactory.createATH();
        ath.RecordTypeId = complianceRT.Id;
        ath.NotCompliant__c = true;
        ath.PlannedComplianceRegistration__c = false;
        ath.Account_Treatment__c = accountTreatment.Id;
        ath.ComplianceSource__c = 'PH';
        ath.Case__c = c.Id;

        Test.startTest();

        Database.SaveResult result = Database.insert(ath);

        Test.stopTest();

        List<Case> cases = [SELECT Id FROM Case];
        List<Task> tasks = [SELECT Id FROM Task];
        List<WorkOrder> workOrders = [SELECT Id FROM WorkOrder];

        System.assert(result.isSuccess());
        System.assert(cases.size() > 12);
        System.assert(tasks.size() > 12);
        System.assert(workOrders.size() > 12);
    }

    @isTest
    static void closeNonComplianceCasesTestPart1() {
        List<Task> tasksToInsert = new List<Task>();
        List<Case> casesToInsert = new List<Case>();
        List<WorkOrder> workOrdersToInsert = new List<WorkOrder>();

        RecordType complianceRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'AccountTreatmentHistory_ComplianceRegistration'];

        Account account = TestDataFactory.createPersonAccount();
        insert account;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(account);
        accountTreatment.Contract_Treatment__c = contractTreatment.Id;
        insert accountTreatment;

        Case c = TestDataFactory.createCase();
        c.AccountId = account.Id;
        c.Account_Treatment__c = accountTreatment.Id;
        c.Type = 'Non Compliance';
        casesToInsert.add(c);
        
        insert casesToInsert;

        Task t = TestDataFactory.createTask();
        t.WhatId = c.Id;
        tasksToInsert.add(t);

        insert tasksToInsert;

        Account_Treatment_History__c ath = TestDataFactory.createATH();
        ath.RecordTypeId = complianceRT.Id;
        ath.NotCompliant__c = false;
        ath.PlannedComplianceRegistration__c = true;
        ath.Account_Treatment__c = accountTreatment.Id;
        ath.ComplianceSource__c = 'PH';
        ath.Case__c = c.Id;

        Test.startTest();

        Database.SaveResult result = Database.insert(ath);

        Test.stopTest();

        Case queriedCase = [SELECT Status FROM Case WHERE Id =: c.Id];
        Task queriedTask = [SELECT Status FROM Task WHERE Id =: t.Id];

        System.assertEquals('Closed', queriedCase.Status);
        System.assertEquals('Completed', queriedTask.Status);
    }

    @isTest
    static void closeNonComplianceCasesTestPart2() {
        List<Task> tasksToInsert = new List<Task>();
        List<Case> casesToInsert = new List<Case>();
        List<WorkOrder> workOrdersToInsert = new List<WorkOrder>();

        RecordType complianceRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'AccountTreatmentHistory_ComplianceRegistration'];

        Account account = TestDataFactory.createPersonAccount();
        insert account;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(account);
        accountTreatment.Contract_Treatment__c = contractTreatment.Id;
        insert accountTreatment;

        Account_Treatment_Job__c ATJ = TestDataFactory.createAccountTreatmentJob(accountTreatment.Id);
        ATJ.ComplianceSource__c = 'PH';
        insert ATJ;

        Case c = TestDataFactory.createCase();
        c.AccountId = account.Id;
        c.Account_Treatment__c = accountTreatment.Id;
        casesToInsert.add(c);

        Case c1 = TestDataFactory.createCase();
        c1.AccountId = account.Id;
        c1.Account_Treatment__c = accountTreatment.Id;
        c1.Type = 'Non Compliance';
        c1.Account_Treatment_Job__c = ATJ.Id;
        casesToInsert.add(c1);

        insert casesToInsert;

        Task t1 = TestDataFactory.createTask();
        t1.WhatId = c1.Id;
        t1.ActivityDate = Date.today();
        tasksToInsert.add(t1);

        insert tasksToInsert;

        WorkOrder wo1 = TestDataFactory.createWorkOrder();
        wo1.CaseId = c1.Id;
        workOrdersToInsert.add(wo1);

        insert workOrdersToInsert;

        Account_Treatment_History__c ath = TestDataFactory.createATH();
        ath.RecordTypeId = complianceRT.Id;
        ath.NotCompliant__c = false;
        ath.PlannedComplianceRegistration__c = true;
        ath.Account_Treatment__c = accountTreatment.Id;
        ath.ComplianceSource__c = 'PH';
        ath.Case__c = c.Id;

        Test.startTest();

        Database.SaveResult result = Database.insert(ath);

        Test.stopTest();

        Case queriedCase = [SELECT Status FROM Case WHERE Id =: c1.Id];
        Task queriedTask = [SELECT Status FROM Task WHERE Id =: t1.Id];
        WorkOrder queriedWorkOrder = [SELECT Status FROM WorkOrder WHERE Id =: wo1.Id];

        System.assertEquals('Canceled', queriedCase.Status);
        System.assertEquals('Canceled', queriedTask.Status);
        System.assertEquals('Canceled', queriedWorkOrder.Status);
    }
}