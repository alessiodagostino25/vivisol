@isTest
public class TestAccountTreatmentJobTrigger {
    
    @isTest
    static void insertTest() {
        Account account = TestDataFactory.createPersonAccount();
        insert account;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(account);
        insert accountTreatment;

        Account_Treatment_Job__c ATJ = TestDataFactory.createAccountTreatmentJob(accountTreatment.Id);
        ATJ.Delivery_Channel__c = 'Home Visit';
        ATJ.Frequency__c = 2;
        ATJ.Frequency_Unit_of_measure__c = 'Week';
        ATJ.Scheduling_Time_Frame__c = 365;
        ATJ.Frequency_Type__c = 'NPU';

        Test.startTest();

        Database.SaveResult result = Database.insert(ATJ);

        Test.stopTest();

        Account_Treatment_Job__c queriedATJ = [SELECT Id, Delivery_Channel__c, Frequency__c, Frequency_Unit_of_measure__c, Last_Propagated_Delivery_Channel__c,
        Last_Propagated_Frequency__c, Last_Propagated_Frequency_UOM__c FROM Account_Treatment_Job__c];

        System.assert(result.isSuccess());

        System.assertEquals(queriedATJ.Delivery_Channel__c, queriedATJ.Last_Propagated_Delivery_Channel__c);
        System.assertEquals(queriedATJ.Frequency__c, queriedATJ.Last_Propagated_Frequency__c);
        System.assertEquals(queriedATJ.Frequency_Unit_of_measure__c, queriedATJ.Last_Propagated_Frequency_UOM__c);
    }

    @isTest
    static void updateFrequencyTest() {
        Account account = TestDataFactory.createPersonAccount();
        insert account;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(account);
        insert accountTreatment;

        Account_Treatment_Job__c ATJ = TestDataFactory.createAccountTreatmentJob(accountTreatment.Id);
        ATJ.Delivery_Channel__c = 'Home Visit';
        ATJ.Frequency__c = 1;
        ATJ.Frequency_Unit_of_measure__c = 'Year';
        ATJ.Scheduling_Time_Frame__c = 365;
        ATJ.Frequency_Type__c = 'NPU';
        insert ATJ;

        Case c = TestDataFactory.createCase();
        c.AccountId = account.Id;
        c.Account_Treatment__c = accountTreatment.Id;
        c.Account_Treatment_Job__c = ATJ.Id;
        insert c;

        WorkOrder wo = TestDataFactory.createWorkOrder();
        wo.CaseId = c.Id;
        wo.Account_Treatment__c = accountTreatment.Id;
        wo.Account_Treatment_Job__c = ATJ.Id;
        insert wo;

        OperatingHours operatingHours = TestDataFactory.createOperatingHours();
        insert operatingHours;

        ServiceTerritory serviceTerritory = TestDataFactory.createServiceTerritory(operatingHours.Id, true);
        insert serviceTerritory;

        ServiceAppointment serviceAppointment = TestDataFactory.createServiceAppointment(wo.Id, serviceTerritory.Id, 'New');
        insert serviceAppointment;

        ATJ.Frequency__c = 6;

        Test.startTest();
        
        Database.SaveResult result = Database.update(ATJ);

        Test.stopTest();

        ServiceAppointment queriedSA = [SELECT Id, Has_Frequency__c FROM ServiceAppointment WHERE Id =: serviceAppointment.Id];

        System.assert(result.isSuccess());
        System.assertEquals(true, queriedSA.Has_Frequency__c);
    }
}