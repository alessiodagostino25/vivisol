@isTest
public class TestATMainComponentController {
    
    @isTest
    static void getRecordNameTest() {
        Account a = TestDataFactory.createPersonAccount();
        insert a;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(a);
        accountTreatment.Contract_Treatment__c = contractTreatment.Id;
        insert accountTreatment;

        Test.startTest();

        List<Account_Treatment__c> ATs = ATMainComponentController.getrecordnameandtreatment(accountTreatment.Id);

        Test.stopTest();

        System.assertEquals('MRD', ATs[0].Treatment_Type__c);
        System.assertEquals('AccountTreatment_Therapy', ATs[0].RecordType.DeveloperName);
        System.assertEquals(contractTreatment.Id, ATs[0].Contract_Treatment__c);
    }

    @isTest
    static void getTodayTest() {
        Datetime today = ATMainComponentController.getTodayDatetime();

        System.assertEquals(Datetime.now(), today);
    }

    @isTest
    static void checkForAddressPageTest() {
        Account a = TestDataFactory.createPersonAccount();
        insert a;

        Prescription__c prescription = new Prescription__c(
            Patient__c = a.Id,
            Received_date__c = Date.today()
        );
        insert prescription;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(a);
        accountTreatment.Contract_Treatment__c = contractTreatment.Id;
        accountTreatment.Prescription__c = prescription.Id;
        insert accountTreatment;

        Test.startTest();

        Boolean result = ATMainComponentController.checkForAddressSelectionPage(accountTreatment.Id);

        Test.stopTest();

        System.assertEquals(true, result);
    }

    @isTest
    static void getRecordTypeTest() {
        Account a = TestDataFactory.createPersonAccount();
        insert a;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(a);
        accountTreatment.Contract_Treatment__c = contractTreatment.Id;
        insert accountTreatment;

        Test.startTest();

        String recordType = ATMainComponentController.getAccountTreatmentRecordType(accountTreatment.Id);

        Test.stopTest();

        System.assertEquals('AccountTreatment_Therapy', recordType);
    }

    @isTest
    static void autoscheduleProcessTherapyTest() {
        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        insert CTJ;

        Contract_Treatment_Job_SLA__c SLA = TestDataFactory.createSLA(CTJ.Id);
        SLA.Unite_of_measure_Max_Time__c = 'Week';
        SLA.Max_Time__c = 1;
        SLA.Calculation_Mode__c = 'Calendar';
        SLA.Task_Unite_of_measure_Max_Time__c = 'Week';
        SLA.Task_MaxTime_Execution__c = 1;
        SLA.Task_Calculation_Mode__c = 'Calendar';
        SLA.Offset_Start_Date__c = 1;
        SLA.Offset_End_Date__c = 1;
        SLA.Offset_unit_of_measure__c = 'Week';
        SLA.Offset_calculation_mode__c = 'Calendar';
        SLA.Contract_Treatment_Job__c = CTJ.Id;
        insert SLA;

        Account a = TestDataFactory.createPersonAccount();
        insert a;

        Prescription__c prescription = new Prescription__c(
            Patient__c = a.Id,
            Received_date__c = Date.today()
        );
        insert prescription;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(a);
        accountTreatment.Prescription__c = prescription.Id;
        accountTreatment.Contract_Treatment__c = contractTreatment.Id;
        insert accountTreatment;

        Account_Treatment_Address__c ATA = TestDataFactory.createATA(accountTreatment);
        insert ATA;

        Account_Treatment_Job__c ATJ = TestDataFactory.createAccountTreatmentJob(accountTreatment.Id);
        ATJ.Frequency__c = 1;
        ATJ.Frequency_Unit_of_measure__c = 'Month';
        ATJ.Scheduling_Rule__c = 'Autoscheduled';
        ATJ.Task__c = true;
        ATJ.Task_Type__c = 'Follow Up';
        ATJ.Work_Order__c = true;
        ATJ.Contract_Treatment_Job__c = CTJ.Id;
        ATJ.Scheduling_Time_Frame__c = 365;
        ATJ.Frequency_Type__c = 'NPU';
        insert ATJ;

        Test.startTest();

        ATMainComponentController.autoscheduleProcess(accountTreatment.Id, null);

        Test.stopTest();

        List<Case> cases = [SELECT Id FROM Case];
        List<Task> tasks = [SELECT Id FROM Task];
        List<WorkOrder> workOrders = [SELECT Id FROM WorkOrder];

        System.assertEquals(12, cases.size());
        System.assertEquals(12, tasks.size());
        System.assertEquals(12, workOrders.size());
    }

    @isTest
    static void autoscheduleProcessSalesTest() {
        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        insert CTJ;

        Contract_Treatment_Job_SLA__c SLA = TestDataFactory.createSLA(CTJ.Id);
        SLA.Unite_of_measure_Max_Time__c = 'Week';
        SLA.Max_Time__c = 1;
        SLA.Calculation_Mode__c = 'Calendar';
        SLA.Task_Unite_of_measure_Max_Time__c = 'Week';
        SLA.Task_MaxTime_Execution__c = 1;
        SLA.Task_Calculation_Mode__c = 'Calendar';
        SLA.Offset_Start_Date__c = 1;
        SLA.Offset_End_Date__c = 1;
        SLA.Offset_unit_of_measure__c = 'Week';
        SLA.Offset_calculation_mode__c = 'Calendar';
        SLA.Contract_Treatment_Job__c = CTJ.Id;
        insert SLA;

        Account a = TestDataFactory.createPersonAccount();
        insert a;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(a);
        accountTreatment.Contract_Treatment__c = contractTreatment.Id;
        insert accountTreatment;

        Account_Treatment_Address__c ATA = TestDataFactory.createATA(accountTreatment);
        insert ATA;

        Account_Treatment_Job__c ATJ = TestDataFactory.createAccountTreatmentJob(accountTreatment.Id);
        ATJ.Frequency__c = 1;
        ATJ.Frequency_Unit_of_measure__c = 'Year';
        ATJ.Scheduling_Rule__c = 'Autoscheduled';
        ATJ.Task__c = true;
        ATJ.Task_Type__c = 'Follow Up';
        ATJ.Work_Order__c = true;
        ATJ.Contract_Treatment_Job__c = CTJ.Id;
        ATJ.Scheduling_Time_Frame__c = 365;
        ATJ.Frequency_Type__c = 'NPU';
        insert ATJ;

        Test.startTest();

        ATMainComponentController.autoscheduleProcess(accountTreatment.Id, Datetime.now());

        Test.stopTest();

        List<Case> cases = [SELECT Id FROM Case];
        List<Task> tasks = [SELECT Id FROM Task];
        List<WorkOrder> workOrders = [SELECT Id FROM WorkOrder];

        System.assertEquals(1, cases.size());
        System.assertEquals(1, tasks.size());
        System.assertEquals(1, workOrders.size());
    }

    @isTest
    static void getDefaultATAsNumberTest() {
        Account a = TestDataFactory.createPersonAccount();
        insert a;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(a);
        accountTreatment.Contract_Treatment__c = contractTreatment.Id;
        insert accountTreatment;

        Account_Treatment_Address__c ATA = TestDataFactory.createATA(accountTreatment);
        insert ATA;

        Test.startTest();

        Integer defaultATAnumber = ATMainComponentController.getDefaultAddressesNumber(accountTreatment.Id);

        Test.stopTest();

        System.assertEquals(1, defaultATAnumber);
    }
}