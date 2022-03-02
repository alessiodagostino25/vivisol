@isTest
public class TestAccountTreatmentStatusUpdateTrigger {

    // If aggiunto in seguito
    @isTest
    public static void triggerTestAddedIF(){
        Account acc = TestDataFactory.initAccount2();
        acc.Status__c = 'DEACTIVATED';
        update acc; 
        
        Account_Treatment__c patient = new Account_Treatment__c();
        patient.Account__c = acc.Id;
        patient.Status__c = 'S';
        insert patient;
        
        Account_Treatment_Status__c oldStatus = new Account_Treatment_Status__c();
        oldStatus.Patient_Treatment__c = patient.Id;
        insert oldStatus;
        Account_Treatment_Status__c newsstatus = new Account_Treatment_Status__c();
        newsstatus.Status__c = 'W';
        newsstatus.StartDate__c = Date.newInstance(2020, 12, 12);
        newsstatus.Patient_Treatment__c = patient.Id;
        patient.Activation_Date__c = newsstatus.StartDate__c;
        update patient;
        test.startTest();
        insert newsstatus;
        test.stopTest();
        
        Account accountAfterTest = [Select id, Status__c from Account where id=:acc.Id];
        system.assertEquals('NEW', accountAfterTest.Status__c, 'Account status');
    }
    
    
    //Entra nel primo IF
    @isTest
    public static void triggerTestFirstIF(){
        Account acc = TestDataFactory.initAccount2();
        acc.Status__c = 'NEW';
        update acc;
        
        Account_Treatment__c patient = new Account_Treatment__c();
        patient.Status__c = 'D';
        patient.Account__c = acc.Id;
        insert patient;
        
        Account_Treatment_Status__c oldStatus = new Account_Treatment_Status__c();
        oldStatus.Patient_Treatment__c = patient.Id;
        oldStatus.Is_Current_Status__c = true;
        insert oldStatus;
        
        Account_Treatment_Status__c newsstatus = new Account_Treatment_Status__c();
        newsstatus.Status__c = 'A';
        newsstatus.StartDate__c = Date.newInstance(2020, 12, 12);
        newsstatus.Patient_Treatment__c = patient.Id;
        
         // --------------------------------------------------------------------------------------
        Account_Treatment__c patient2 = new Account_Treatment__c();
        patient2.Status__c = 'D';
        patient2.Account__c = acc.Id;
        insert patient2;
        
        Account_Treatment_Status__c oldStatus2 = new Account_Treatment_Status__c();
        oldStatus2.Patient_Treatment__c = patient2.Id;
        oldStatus2.Is_Current_Status__c = true;
        insert oldStatus2;
        
        Account_Treatment_Status__c newsstatus2 = new Account_Treatment_Status__c();
        newsstatus2.Status__c = 'A';
        newsstatus2.StartDate__c = Date.newInstance(2012, 12, 12);
        newsstatus2.Patient_Treatment__c = patient2.Id;
        
        // -------------------------------------------------------------------------------------
        
        test.startTest();
        insert newsstatus;
        insert newsstatus2;
        test.stopTest();
        Account_Treatment__c patientAfterTrigger = [Select id, Status__c, Activation_Date__c, Deactivation_Date__c from Account_Treatment__c where id=:patient.Id];
        system.assertEquals('A', patientAfterTrigger.Status__c, 'Status ');
        system.assertEquals(newsstatus.StartDate__c, patientAfterTrigger.Activation_Date__c, 'Activation Date ok');
        system.assertEquals(NULL, patientAfterTrigger.Deactivation_Date__c, 'DeActivation Date ok');
        
        Account_Treatment_Status__c oldStatusAfterTrigger = [Select id, EndDate__c from Account_Treatment_Status__c where id=:oldStatus.Id];
        system.assertEquals(newsstatus.StartDate__c, oldStatusAfterTrigger.EndDate__c.addDays(1), 'Old Status Date Check');
        
        Account accountAfterTest = [Select id, Status__c from Account where id=:acc.Id];
        system.assertEquals('ACTIVE', accountAfterTest.Status__c, 'Account status');
        
        // -------------------------------------------------------------------------------------
        Account_Treatment__c patientAfterTrigger2 = [Select id, Status__c, Activation_Date__c, Deactivation_Date__c from Account_Treatment__c where id=:patient2.Id];
        system.assertEquals('A', patientAfterTrigger2.Status__c, 'Status');
        system.assertEquals(newsstatus2.StartDate__c, patientAfterTrigger2.Activation_Date__c, 'Activation Date ok');
        system.assertEquals(NULL, patientAfterTrigger2.Deactivation_Date__c, 'DeActivation Date ok');
        
        Account_Treatment_Status__c oldStatusAfterTrigger2 = [Select id, EndDate__c from Account_Treatment_Status__c where id=:oldStatus2.Id];
        system.assertEquals(newsstatus2.StartDate__c, oldStatusAfterTrigger2.EndDate__c.addDays(1), 'Old Status Date Check');
        // -------------------------------------------------------------------------------------
    }
    
    @isTest
    public static void triggerTestSecondIF(){
        Account acc = TestDataFactory.initAccount2();
        acc.Status__c = 'NEW';
        update acc; 
        
        Account_Treatment__c patient = new Account_Treatment__c();
        patient.Account__c = acc.Id;
        patient.Status__c = 'S';
        insert patient;
        
        Account_Treatment_Status__c oldStatus = new Account_Treatment_Status__c();
        oldStatus.Patient_Treatment__c = patient.Id;
        oldStatus.Is_Current_Status__c = true;
        insert oldStatus;
        Account_Treatment_Status__c newsstatus = new Account_Treatment_Status__c();
        newsstatus.Status__c = 'A';
        newsstatus.StartDate__c = Date.newInstance(2020, 12, 12);
        newsstatus.Patient_Treatment__c = patient.Id;
        patient.Activation_Date__c = newsstatus.StartDate__c;
        update patient;
        test.startTest();
        insert newsstatus;
        test.stopTest();
        
        Account accountAfterTest = [Select id, Status__c from Account where id=:acc.Id];
        system.assertEquals('ACTIVE', accountAfterTest.Status__c, 'Account status');
        
        Account_Treatment__c patientAfterTrigger = [Select id, Status__c, Activation_Date__c, Deactivation_Date__c, Suspension_end_date__c, Suspension_Reason__c,
                                                    Suspension_start_date__c, Suspension_Type__c from Account_Treatment__c where id=:patient.Id];
        system.assertEquals('A', patientAfterTrigger.Status__c, 'Status ');
        system.assertEquals(newsstatus.StartDate__c, patientAfterTrigger.Activation_Date__c, 'Activation Date ok');
        system.assertEquals(NULL, patientAfterTrigger.Deactivation_Date__c, 'DeActivation Date ok');
        system.assertEquals(NULL, patientAfterTrigger.Suspension_end_date__c, 'SUSPENSION END DATE ok');
        system.assertEquals(NULL, patientAfterTrigger.Suspension_Reason__c, 'SUSPENSION REASON ok');
        system.assertEquals(NULL, patientAfterTrigger.Suspension_start_date__c, 'SUSPENSION START DATE ok');
        system.assertEquals(NULL, patientAfterTrigger.Suspension_Type__c, 'SUSPENSION TYPE ok');
        
        Account_Treatment_Status__c oldStatusAfterTrigger = [Select id, EndDate__c from Account_Treatment_Status__c where id=:oldStatus.Id];
        system.assertEquals(newsstatus.StartDate__c, oldStatusAfterTrigger.EndDate__c.addDays(1), 'Old Status Date Check');
    }
    
    @isTest
    public static void triggerTestThirdIF(){
        Account acc = TestDataFactory.initAccount2();
        acc.Status__c = 'NEW';
        update acc; 
        
        Account_Treatment__c patient = new Account_Treatment__c();
        patient.Account__c = acc.Id;
        patient.Status__c = 'S';
        patient.Suspension_end_date__c = Date.newInstance(2019, 01, 12);
        patient.Suspension_start_date__c = Date.newInstance(2019, 01, 12);
        patient.Suspension_Type__c = 'BILLING';
        insert patient;

        Case relatedCase = TestDataFactory.createCase();
        relatedCase.Account_Treatment__c = patient.Id;
        relatedCase.AccountId = acc.Id;
        relatedCase.Start_Date__c = Date.newInstance(2020, 12, 14);
        insert relatedCase;

        Task relatedTask = TestDataFactory.createTask();
        relatedTask.WhatId = relatedCase.Id;
        relatedTask.ActivityDate = Date.today();
        insert relatedTask;

        WorkOrder relatedWorkOrder = TestDataFactory.createWorkOrder();
        relatedWorkOrder.CaseId = relatedCase.Id;
        relatedWorkOrder.Status = 'Assigned';
        relatedWorkOrder.Account_Treatment__c = patient.Id;
        relatedWorkOrder.EndDate = Date.newInstance(2020, 12, 15);
		relatedWorkOrder.StartDate = Date.newInstance(2020, 12, 13);
        insert relatedWorkOrder;
        
        Account_Treatment_Status__c oldStatus = new Account_Treatment_Status__c();
        oldStatus.Patient_Treatment__c = patient.Id;
        oldStatus.Is_Current_Status__c = true;
        insert oldStatus;
        
        Account_Treatment_Status__c newsstatus = new Account_Treatment_Status__c();
        newsstatus.Status__c = 'S';
        newsstatus.StartDate__c = Date.newInstance(2020, 12, 12);
        newsstatus.Suspension_Type__c = 'SERVICE';
        newsStatus.Suspension_end_date__c = Date.newInstance(2020, 12, 15);
		newsStatus.Suspension_start_date__c = Date.newInstance(2020, 12, 13);
        newsstatus.Patient_Treatment__c = patient.Id;
        newsstatus.Suspension_Reason__c = 'VIV';
        
        test.startTest();
        insert newsstatus;
        test.stopTest();
        
        Account_Treatment__c patientAfterTrigger = [Select id, Status__c, Activation_Date__c, Deactivation_Date__c, Suspension_end_date__c, Suspension_Reason__c,
                                                    Suspension_start_date__c, Suspension_Type__c from Account_Treatment__c where id=:patient.Id];
        system.assertEquals('S', patientAfterTrigger.Status__c, 'Status ');
        system.assertEquals(NULL, patientAfterTrigger.Deactivation_Date__c, 'DeActivation Date');
        system.assertEquals(newsstatus.Suspension_end_date__c, patientAfterTrigger.Suspension_end_date__c, 'SUSPENSION END DATE');
        system.assertEquals(newsstatus.Suspension_Reason__c, patientAfterTrigger.Suspension_Reason__c, 'SUSPENSION REASON');
        system.assertEquals(newsstatus.Suspension_start_date__c, patientAfterTrigger.Suspension_start_date__c, 'SUSPENSION START DATE');
        system.assertEquals(newsstatus.Suspension_Type__c, patientAfterTrigger.Suspension_Type__c, 'SUSPENSION TYPE');
        
        Account_Treatment_Status__c oldStatusAfterTrigger = [Select id, EndDate__c from Account_Treatment_Status__c where id=:oldStatus.Id];
        system.assertEquals(newsstatus.StartDate__c, oldStatusAfterTrigger.EndDate__c, 'Old Status Date Check');
    }
    
    // FOURTH IF
    @isTest
    public static void triggerTestFourthIF(){
        Account acc = TestDataFactory.initAccount2();
        acc.Status__c = 'ACTIVE';
        update acc;
        
        Account_Treatment__c patient = new Account_Treatment__c();
        patient.Account__c = acc.Id;
        patient.Status__c = 'R';
        insert patient;

        Case relatedCase = TestDataFactory.createCase();
        relatedCase.Account_Treatment__c = patient.Id;
        relatedCase.AccountId = acc.Id;
        relatedCase.Start_Date__c = Date.newInstance(2020, 12, 14);
        insert relatedCase;

        Task relatedTask = TestDataFactory.createTask();
        relatedTask.WhatId = relatedCase.Id;
        relatedTask.ActivityDate = Date.today();
        insert relatedTask;

        WorkOrder relatedWorkOrder = TestDataFactory.createWorkOrder();
        relatedWorkOrder.CaseId = relatedCase.Id;
        relatedWorkOrder.Status = 'Assigned';
        relatedWorkOrder.Account_Treatment__c = patient.Id;
        relatedWorkOrder.EndDate = Date.newInstance(2020, 12, 15);
		relatedWorkOrder.StartDate = Date.newInstance(2020, 12, 13);
        insert relatedWorkOrder;
        
        Account_Treatment_Status__c oldStatus = new Account_Treatment_Status__c();
        oldStatus.Patient_Treatment__c = patient.Id;
        oldStatus.Is_Current_Status__c = true;
        insert oldStatus;
        
        Account_Treatment_Status__c newsstatus = new Account_Treatment_Status__c();
        newsstatus.Status__c = 'D';
        newsstatus.StartDate__c = Date.newInstance(2020, 12, 12);
        newsstatus.Patient_Treatment__c = patient.Id;
        patient.Activation_Date__c = newsstatus.StartDate__c;
        update patient;
        
        test.startTest();
        insert newsstatus;
        test.stopTest();
        Account_Treatment__c patientAfterTrigger = [Select id, Status__c, Activation_Date__c, Deactivation_Date__c, Suspension_end_date__c, Suspension_Reason__c,
                                                    Suspension_start_date__c, Suspension_Type__c from Account_Treatment__c where id=:patient.Id];
        system.assertEquals('D', patientAfterTrigger.Status__c, 'Status');
        system.assertEquals(newsstatus.StartDate__c, patientAfterTrigger.Deactivation_Date__c, 'DeActivation Date');
        
        Account_Treatment_Status__c oldStatusAfterTrigger = [Select id, EndDate__c from Account_Treatment_Status__c where id=:oldStatus.Id];
        system.assertEquals(newsstatus.StartDate__c, oldStatusAfterTrigger.EndDate__c.addDays(1), 'Old Status Date Check');
        
        Account accountAfterTrigger = [Select id, Status__c from Account where id=:acc.Id];
        system.assertEquals('DEACTIVATED', accountAfterTrigger.Status__c, 'Account Status Check');
    }
    
    @isTest
    public static void triggerTestFifthIF(){
        Account acc = TestDataFactory.initAccount2();
        acc.Status__c = 'ACTIVE';
        update acc;
        
        Account_Treatment__c patient = new Account_Treatment__c();
        patient.Account__c = acc.Id;
        patient.Status__c = 'S';
        insert patient;
        
        Account_Treatment_Status__c oldStatus = new Account_Treatment_Status__c();
        oldStatus.Patient_Treatment__c = patient.Id;
        oldStatus.Is_Current_Status__c = true;
        insert oldStatus;
        
        Account_Treatment_Status__c newsstatus = new Account_Treatment_Status__c();
        newsstatus.Status__c = 'D';
        newsstatus.StartDate__c = Date.newInstance(2020, 12, 12);
        newsstatus.Patient_Treatment__c = patient.Id;
        patient.Activation_Date__c = newsstatus.StartDate__c;
        update patient;
        
        test.startTest();
        insert newsstatus;
        test.stopTest();
        Account_Treatment__c patientAfterTrigger = [Select id, Status__c, Activation_Date__c, Deactivation_Date__c, Suspension_end_date__c, Suspension_Reason__c,
                                                    Suspension_start_date__c, Suspension_Type__c from Account_Treatment__c where id=:patient.Id];
        system.assertEquals('D', patientAfterTrigger.Status__c, 'Status');
        system.assertEquals(newsstatus.StartDate__c, patientAfterTrigger.Deactivation_Date__c, 'DeActivation Date');
        system.assertEquals(NULL, patientAfterTrigger.Suspension_end_date__c, 'SUSPENSION END DATE');
        system.assertEquals(NULL, patientAfterTrigger.Suspension_Reason__c, 'SUSPENSION REASON');
        system.assertEquals(NULL, patientAfterTrigger.Suspension_start_date__c, 'SUSPENSION START DATE');
        system.assertEquals(NULL, patientAfterTrigger.Suspension_Type__c, 'SUSPENSION TYPE');
        
        Account_Treatment_Status__c oldStatusAfterTrigger = [Select id, EndDate__c from Account_Treatment_Status__c where id=:oldStatus.Id];
        system.assertEquals(newsstatus.StartDate__c, oldStatusAfterTrigger.EndDate__c.addDays(1), 'Old Status Date Check');
        
        Account accountAfterTrigger = [Select id, Status__c from Account where id=:acc.Id];
        system.assertEquals('DEACTIVATED', accountAfterTrigger.Status__c, 'Account Status Check');
        
    }
    
    @isTest
    public static void triggerTestSixthIF(){
        Account acc = TestDataFactory.initAccount2();
        acc.Status__c = 'ACTIVE';
        update acc;
        
        Account_Treatment__c patient = new Account_Treatment__c();
        patient.Account__c = acc.Id;
        patient.Status__c = 'A';
        insert patient;

        Case relatedCase = TestDataFactory.createCase();
        relatedCase.Account_Treatment__c = patient.Id;
        relatedCase.AccountId = acc.Id;
        relatedCase.Start_Date__c = Date.newInstance(2020, 12, 14);
        insert relatedCase;

        Task relatedTask = TestDataFactory.createTask();
        relatedTask.WhatId = relatedCase.Id;
        relatedTask.ActivityDate = Date.today();
        insert relatedTask;

        WorkOrder relatedWorkOrder = TestDataFactory.createWorkOrder();
        relatedWorkOrder.CaseId = relatedCase.Id;
        relatedWorkOrder.Status = 'Assigned';
        relatedWorkOrder.Account_Treatment__c = patient.Id;
        relatedWorkOrder.EndDate = Date.newInstance(2020, 12, 15);
		relatedWorkOrder.StartDate = Date.newInstance(2020, 12, 13);
        insert relatedWorkOrder;
        
        Account_Treatment_Status__c oldStatus = new Account_Treatment_Status__c();
        oldStatus.Patient_Treatment__c = patient.Id;
        oldStatus.Is_Current_Status__c = true;
        insert oldStatus;
        
        Account_Treatment_Status__c newsstatus = new Account_Treatment_Status__c();
        newsstatus.Status__c = 'R';
        newsstatus.StartDate__c = Date.newInstance(2020, 12, 12);
        newsstatus.Patient_Treatment__c = patient.Id;
        patient.Activation_Date__c = newsstatus.StartDate__c;
        update patient;
        
        test.startTest();
        insert newsstatus;
        test.stopTest();
        
        Account accountAfterTrigger = [Select id, Status__c from Account where id=:acc.Id];
        system.assertEquals('INACTIVE', accountAfterTrigger.Status__c, 'Account Status Check');
        
        Account_Treatment__c patientAfterTrigger = [Select id, Status__c, Activation_Date__c, Deactivation_Date__c, Suspension_end_date__c, Suspension_Reason__c,
                                                    Suspension_start_date__c, Suspension_Type__c from Account_Treatment__c where id=:patient.Id];
        system.assertEquals('R', patientAfterTrigger.Status__c, 'Status ok!');
        system.assertEquals(NULL, patientAfterTrigger.Suspension_end_date__c, 'SUSPENSION END DATE');
        system.assertEquals(NULL, patientAfterTrigger.Suspension_Reason__c, 'SUSPENSION REASON');
        system.assertEquals(NULL, patientAfterTrigger.Suspension_start_date__c, 'SUSPENSION START DATE');
        system.assertEquals(NULL, patientAfterTrigger.Suspension_Type__c, 'SUSPENSION TYPE');
    }    
    
}