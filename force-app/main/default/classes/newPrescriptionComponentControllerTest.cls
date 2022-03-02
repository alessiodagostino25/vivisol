//S: Sidea V4AT-189
@isTest
public with sharing class newPrescriptionComponentControllerTest {
    @TestSetup
    static void makeData(){
            Sales_Organization__c so = new Sales_Organization__c(name = 'VIV - AT - 6200');
            Contract_Framework__c cf = TestDataFactory.initContractFramework(); //Name ='testContractFramework'
            Contract_Treatment__c ct = new Contract_Treatment__c(Name ='testCF', Contract_Framework__c = cf.Id, Business_Line__c = 'VTD');
            Account a = TestDataFactory.createPersonAccount();
            insert so;
            insert ct;
            insert a;
            Contract_Payer__c cp = new Contract_Payer__c(Contract_Framework__c = cf.Id, Business_Line__c = 'VTD', Payer__c = a.id, Bill_To__c = a.id, Approver__c = a.id);
            insert cp;
    }

    @isTest
    public static void getPrescriptionRecordTypesTest() {
        Test.startTest();
        List<newPrescriptionComponentController.RecordTypeDTO> recordTypeDTOList = newPrescriptionComponentController.getPrescriptionRecordTypes();
        Test.stopTest();
        System.assert(recordTypeDTOList.size() > 0);
    }

    @isTest
    public static void getSalesOrganizationIdTest() {
        Test.startTest();
        String s = newPrescriptionComponentController.getSalesOrganizationId();
        Test.stopTest();
        System.assert(!String.isBlank(s));
    }

    @isTest
    public static void getBusinessLineOptionsTest() {
        Contract_Framework__c cf = [SELECT Id FROM Contract_Framework__c WHERE name = 'testContractFramework'];
        Test.startTest();
        List<newPrescriptionComponentController.BusinessLinePicklistDTO> DTOOptions = newPrescriptionComponentController.getBusinessLineOptions(cf.Id);
        Test.stopTest();
        System.assert(DTOOptions.size() > 0);
    }

    @isTest
    public static void getTableContractPayerTest() {
        Contract_Framework__c cf = [SELECT Id FROM Contract_Framework__c WHERE name = 'testContractFramework'];
        Test.startTest();
        List<Contract_Payer__c> CPList = newPrescriptionComponentController.getTableContractPayer(cf.id, 'VTD');
        Test.stopTest();
        System.assert(CPList.size() > 0);
    }

    @isTest
    public static void getTableContractTreatmentTest() {
        Contract_Framework__c cf = [SELECT Id FROM Contract_Framework__c WHERE name = 'testContractFramework'];
        Test.startTest();
        List<Contract_Treatment__c> CTList = newPrescriptionComponentController.getTableContractTreatment(cf.id, 'VTD');
        Test.stopTest();
        System.assert(CTList.size() > 0);
    }

    @isTest
    public static void getAccountFieldsTest() {
        Account acc = [SELECT Id FROM Account WHERE LastName = 'PersonAccount'];
        Test.startTest();
        String s = newPrescriptionComponentController.getAccountFields(acc.Id);
        Test.stopTest();
        System.assert(!String.isBlank(s));
    }

    @isTest
    public static void currentDateTimeTest() {
        Test.startTest();
        Datetime dt = newPrescriptionComponentController.currentDateTime();
        Test.stopTest();
    }

    
    @isTest
    public static void newPrescriptionTest() {

        Account acc = [SELECT Id FROM Account WHERE LastName = 'PersonAccount']; //parametro n3/n5
        Contract_Framework__c cf = [SELECT Id FROM Contract_Framework__c WHERE name = 'testContractFramework']; //parametro n7
        Sales_Organization__c SO = [SELECT Id FROM Sales_Organization__c WHERE Name = 'VIV - AT - 6200'];

        /* Example of prescriptions field from front end
        {
            "sobjectType": "Prescription__c",
            "Patient__c": "0011w00001AsXMTAA3",
            "Sales_Organization__c": "a2n1w000001vwQpAAI",
            "Address__c": "1311w0000003OHWAA2",
            "Customer_B2B_and_B2C_Paying_Customer__c": "0011w00001AsWz6AAF",
            "Prescriber__c": null,
            "Hospital__c": null,
            "Contract_Framework__c": "a251w0000015jhlAAA",
            "Prescription_Date__c": null,
            "Received_date__c": "2022-02-23T09:10:06.768Z",
            "Consignment_Installation__c": false,
            "Required_Information__c": null,
            "Responsible__c": null,
            "Notes__c": null
        }
        */

        Prescription__c prescriptionObject = new Prescription__c();
        prescriptionObject.Patient__c = acc.Id;
        prescriptionObject.Sales_Organization__c = SO.Id;
        prescriptionObject.Customer_B2B_and_B2C_Paying_Customer__c = acc.Id;   
        prescriptionObject.Received_date__c = newPrescriptionComponentController.currentDateTime();
        prescriptionObject.Consignment_Installation__c = false;
        prescriptionObject.Contract_Framework__c = cf.Id;


        String serializedPrescription = JSON.serialize(prescriptionObject); //parametro n1

        List<String> treatmentTypes = new List<String>();   //parametro n2
        treatmentTypes.add('SO');
        
        List<Contract_Treatment__c> CTList = [SELECT Id FROM Contract_Treatment__c WHERE Name = 'testCF'];
        List<String> CTIdsList = new List<String>(); //parametro n4
        for (Contract_Treatment__c c : CTList) {
            CTIdsList.add(c.Id);
        }

        String recordTypeName = 'Hiflow Humidification Therapy';  //parametro n6
        
        String businessLine = 'AEROSOL';    //parametro n8

        Contract_Payer__c cp = [SELECT Id FROM Contract_Payer__c WHERE Business_Line__c = 'VTD' LIMIT 1];  //parametro n9

        Test.startTest();
        Boolean result = newPrescriptionComponentController.newPrescription(serializedPrescription, treatmentTypes, acc.Id, CTIdsList, acc.Id, recordTypeName, cf.Id, businessLine, cp.Id);
        Test.stopTest();
    }
    
}
//E: Sidea V4AT-189
