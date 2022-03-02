@isTest
public class TestProductRequestAssignmentBatch {

    @isTest
    static void ProductRequestAssignmentBatch_Test(){
        Profile adminProfile = TestDataFactory.getVivisolAdminProfile();
        User tmpUser = TestDataFactory.initUser(adminProfile);

        ServiceResource serviceResourceTest = TestDataFactory.createServiceResource();
        Date today = Date.today();
        Date tomorrow = today.addDays(1);
        serviceResourceTest.New_Van_Assignement_Date__c = tomorrow;
        Schema.Location newVan =TestDataFactory.createLocation();
        newVan.LocationType = 'Van';
        newVan.isInventoryLocation = true;
        newVan.IsMobile = true;
        insert newVan;
        serviceResourceTest.LocationId = newVan.Id;
        serviceResourceTest.NextLocation__c = newVan.Id;
        insert serviceResourceTest;
        
        ProductRequest testPicking = TestDataFactory.createPickingListProductRequest();
        testPicking.status = '1';
        testPicking.DestinationLocationId = newVan.Id;
        testPicking.OwnerId = tmpUser.Id;

        insert testPicking;

        Test.startTest();

		String sch1 = '0 00 * * * ?';
		System.schedule('TestProductRequestAss' + ' hh:30', sch1, new ProductRequestAssignmentBatch());

        Test.stopTest();

    }

}