@isTest
public class TestServiceResourceBatch {

    @isTest
    static void ServiceResourceBatch(){
        ServiceResource serviceResourceTest = TestDataFactory.createServiceResource();
        Date today = Date.today();
        Date tomorrow = today.addDays(1);
        serviceResourceTest.New_Van_Assignement_Date__c = tomorrow;
        Schema.Location newVan =TestDataFactory.createLocation();
        newVan.LocationType = 'Van';
        newVan.isInventoryLocation = true;
        newVan.IsMobile = true;
        insert newVan;
        serviceResourceTest.NextLocation__c = newVan.Id;

        insert serviceResourceTest;

        Test.startTest();

        ServiceResourceBatch srB = new ServiceResourceBatch();
        String jobId = 'Test srB';
        SchedulerClass.scheduleServiceResourceBatch(jobId);

        Test.stopTest();

    }
    

}