@isTest
public class TestServiceAppointmentTrigger {

    @TestSetup
    static void makeData(){
        RecordType patientRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Account_Patient'];

        Account a = new Account(
            FirstName = 'Test',
            LastName = 'PersonAccount',
            Phone = '12345678',
            ShippingCity='city',
            ShippingCountry='Italy',
            ShippingPostalCode='80000',
            ShippingStreet='via ',
            ShippingCountryCode='It',
            RecordTypeId = patientRT.Id,
            PersonEmail = 'test@test.com'
            );
        insert a;

        Schema.Location location = TestDataFactory.initLocation(a);
        Schema.Location parentLocation = TestDataFactory.initLocation(a);

        parentLocation.LocationType = 'Plant';
        update parentLocation;

        location.isInventoryLocation = true;
        location.isMobile = true;
        location.ParentLocationId = parentLocation.Id;
        location.Plant__c = parentLocation.Id;

        update location;

        Account_Treatment__c MRDAccountTreatment = TestDataFactory.createMRDAccountTreatment(a);
        insert MRDAccountTreatment;

        Product2 product = TestDataFactory.createProduct();
        product.Type__c = 'ZJOB';
        product.Product_Code__c = 'testCode';
        insert product;

        Product2 product2 = TestDataFactory.createProduct();
        product2.Type__c = 'ZJOB';
        product2.Product_Code__c = 'testCode2';
        insert product2;
        
        Contract_Framework__c contractFramework = TestDataFactory.initContractFramework();
        
        Contract_Treatment__c contractTreatment = TestDataFactory.initContractTreatment(contractFramework.Id);
        
        Contract_Treatment_Job__c fatherCTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        fatherCTJ.Contract_Treatment_Job_Code__c = product.Id;
        insert fatherCTJ;

        WorkType workType = new WorkType();
        workType.Name = 'TestWorkType';
        workType.EstimatedDuration = 8.0;
        workType.ShouldAutoCreateSvcAppt = true;
        insert workType;
        
        Contract_Treatment_Job__c dependentCTJ = TestDataFactory.createDependentContractTreatmentJob(contractTreatment.Id, fatherCTJ.Id);
        dependentCTJ.Contract_Treatment_Job_Code__c = product2.Id;
        dependentCTJ.SA_Dependency_Job__c = fatherCTJ.Id;
        dependentCTJ.Work_Order__c = true;
        dependentCTJ.Delivery_Channel__c = 'Home Visit';
        dependentCTJ.Work_Type__c = workType.Id;
        insert dependentCTJ;

        Account_Treatment_Job__c accountTreatmentJob = TestDataFactory.createAccountTreatmentJob(MRDAccountTreatment.Id);
        accountTreatmentJob.Contract_Treatment_Job__c = fatherCTJ.Id;
        insert accountTreatmentJob;
        
        OperatingHours operatingHours = TestDataFactory.createOperatingHours();
        insert operatingHours;

        ServiceTerritory serviceTerritory = TestDataFactory.createServiceTerritory(operatingHours.Id, true);
        insert serviceTerritory;

        WorkOrder workOrderRelatedToATJ = TestDataFactory.createWorkOrder();
        workOrderRelatedToATJ.Account_Treatment_Job__c = accountTreatmentJob.Id;
        workOrderRelatedToATJ.AccountId = a.Id;
        workOrderRelatedToATJ.ServiceTerritoryId = serviceTerritory.Id;

        WorkOrder wo = TestDataFactory.createWorkOrder();
        wo.Account_Treatment__c = MRDAccountTreatment.Id;
        wo.Contract_Treatment_Job__c = dependentCTJ.Id;
        insert (new List<WorkOrder>{workOrderRelatedToATJ, wo});

        ServiceAppointment serviceAppointment = TestDataFactory.createServiceAppointment(workOrderRelatedToATJ.Id, serviceTerritory.Id, 'None');
        insert serviceAppointment;
    }

    @isTest
    static void insertAndUpdateTest() {
        WorkOrder wo = [SELECT Id, Contract_Treatment_Job__c, Contract_Treatment_Job__r.Scheduling_Rule__c, Contract_Treatment_Job__r.Contract_Treatment_Job__c 
                        FROM WorkOrder WHERE Contract_Treatment_Job__r.Contract_Treatment_Job__c != null];
        System.debug('wo.Contract_Treatment_Job__c: ' + wo.Contract_Treatment_Job__c);
        System.debug('Wo.CTJ.SchedulingRule: ' + wo.Contract_Treatment_Job__r.Scheduling_Rule__c);

        ServiceTerritory serviceTerritory = [SELECT Id FROM ServiceTerritory];

        ServiceAppointment serviceAppointment = TestDataFactory.createServiceAppointment(wo.Id, serviceTerritory.Id, 'None');

        Test.startTest();
        Database.SaveResult result = Database.insert(serviceAppointment);

        Schema.Location childLocation = [SELECT Id, ParentLocationId, Plant__c FROM Location WHERE ParentLocationId != null];

        ServiceResource serviceResource = TestDataFactory.createServiceResource();
        serviceResource.LocationId = childLocation.Id;
        insert serviceResource;

        OperatingHours oh = [SELECT Id FROM OperatingHours];

        ServiceTerritoryMember STM = TestDataFactory.createServiceTerritoryMember(oh.Id, serviceResource.Id, serviceTerritory.Id);
        insert STM;

        AssignedResource assignedResource = TestDataFactory.createAssignedResource(serviceAppointment.Id, serviceResource.Id);
        insert assignedResource;

        serviceAppointment.Status = 'Scheduled';

        Database.SaveResult updateResult = Database.update(serviceAppointment);
        Test.stopTest();

        List<FSL__Time_Dependency__c> timeDependencies = [SELECT Id FROM FSL__Time_Dependency__c];

        System.assert(result.isSuccess());
        System.assert(updateResult.isSuccess());
        System.assert(timeDependencies.size() > 0);
    }

    @isTest
    static void dispatchedTest() {
        OperatingHours oh = [SELECT Id FROM OperatingHours];
        ServiceTerritory serviceTerritory = [SELECT Id FROM ServiceTerritory];
        Schema.Location location = [SELECT Id FROM Location WHERE IsMobile = true LIMIT 1];
        
        ServiceResource serviceResource = TestDataFactory.createServiceResource();
        serviceResource.OwnerId = UserInfo.getUserId();
        serviceResource.LocationId = location.Id;
        insert serviceResource;

        ServiceTerritoryMember stm = TestDataFactory.createServiceTerritoryMember(oh.Id, serviceResource.Id, serviceTerritory.Id);
        insert stm;

        Test.startTest();

        ServiceAppointment serviceAppointment = [SELECT Id FROM ServiceAppointment LIMIT 1];

        AssignedResource assignedResource = TestDataFactory.createAssignedResource(serviceAppointment.Id, serviceResource.Id);
        insert assignedResource;

        serviceAppointment.Status = 'Dispatched';
        Database.SaveResult result = Database.update(serviceAppointment);

        Test.stopTest();

        ServiceAppointment queriedSA = [SELECT Id, OwnerId FROM ServiceAppointment WHERE Id =: serviceAppointment.Id];

        System.assert(result.isSuccess());
        System.assertEquals(serviceResource.OwnerId, queriedSA.OwnerId);
    }

    @isTest
    static void canceledTest() {
        OperatingHours oh = [SELECT Id FROM OperatingHours];
        ServiceTerritory serviceTerritory = [SELECT Id FROM ServiceTerritory];
        Schema.Location location = [SELECT Id FROM Location WHERE IsMobile = true LIMIT 1];
        
        ServiceResource serviceResource = TestDataFactory.createServiceResource();
        serviceResource.LocationId = location.Id;
        insert serviceResource;

        ServiceTerritoryMember stm = TestDataFactory.createServiceTerritoryMember(oh.Id, serviceResource.Id, serviceTerritory.Id);
        insert stm;

        Test.startTest();

        ServiceAppointment serviceAppointment = [SELECT Id, ParentRecordId FROM ServiceAppointment LIMIT 1];

        AssignedResource assignedResource = TestDataFactory.createAssignedResource(serviceAppointment.Id, serviceResource.Id);
        insert assignedResource;

        serviceAppointment.Status = 'Canceled';
        Database.SaveResult result = Database.update(serviceAppointment);

        Test.stopTest();

        List<WorkOrder> relatedWOs = [SELECT Status FROM WorkOrder WHERE Id =: serviceAppointment.ParentRecordId];

        System.assert(result.isSuccess());
        System.assertEquals('New', relatedWOs[0].Status);
    }

    @isTest
    static void updateAddressTest() {
        ServiceAppointment serviceAppointment = [SELECT Id, ParentRecordId FROM ServiceAppointment LIMIT 1];
        OperatingHours oh = [SELECT Id FROM OperatingHours];
        WorkOrder wo = [SELECT Id, Street, City, PostalCode, StateCode, CountryCode FROM WorkOrder WHERE Id =: serviceAppointment.ParentRecordId];

        wo.Street = 'Corso Cavour';
        wo.City = 'Vigevano';
        wo.PostalCode = '27029';
        wo.CountryCode = 'IT';

        update wo;

        ServiceTerritory newServiceTerritory = TestDataFactory.createServiceTerritory(oh.Id, true);
        newServiceTerritory.Name = 'New Service Territory';
        insert newServiceTerritory;

        Test.startTest();

        serviceAppointment.ServiceTerritoryId = newServiceTerritory.Id;

        Database.SaveResult result = Database.update(serviceAppointment);

        ServiceAppointment queriedSA = [SELECT Street, City, PostalCode, CountryCode FROM ServiceAppointment WHERE Id =: serviceAppointment.Id];

        Test.stopTest();

        System.assert(result.isSuccess());
        System.assertEquals(wo.Street, queriedSA.Street);
        System.assertEquals(wo.City, queriedSA.City);
        System.assertEquals(wo.PostalCode, queriedSA.PostalCode);
        System.assertEquals(wo.CountryCode, queriedSA.CountryCode);
    }

    @isTest
    static void duplicateExceptionTest() {
        ServiceAppointment serviceAppointment = [SELECT Id, ParentRecordId FROM ServiceAppointment LIMIT 1];
        ServiceTerritory serviceTerritory = [SELECT Id FROM ServiceTerritory];

        ServiceAppointment serviceAppointment1 = TestDataFactory.createServiceAppointment(serviceAppointment.ParentRecordId, serviceTerritory.Id, 'None');

        Test.startTest();

        Database.SaveResult result = Database.insert(serviceAppointment1, false);

        Test.stopTest();

        System.assert(!result.isSuccess());
    }
}