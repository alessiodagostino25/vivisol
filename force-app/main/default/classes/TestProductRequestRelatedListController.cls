@IsTest
public class TestProductRequestRelatedListController {
   
    @isTest
    static void testGetProductRequests(){
        Account a = TestDataFactory.createPersonAccount();
        insert a;

        Schema.Location locInventory = TestDataFactory.initInventoryLocation(a);
        locInventory.IsMobile = true;
        update locInventory;

        Schema.Location loc = TestDataFactory.createLocation();
        loc.LocationType = 'Warehouse';
        loc.Location_Id__c = '67WC';
        loc.Sales_Org_Code__c = '6300';
        insert loc;

        Schema.Location plantLoc = TestDataFactory.createLocation();
        plantLoc.LocationType = 'Plant';
        insert plantLoc;


        ProductRequest pr = TestDataFactory.createPickingListProductRequest();
        pr.DestinationLocationId = loc.Id;
        pr.Status = '1';
        insert pr;

        OperatingHours operhour = TestDataFactory.createOperatingHours();
        insert operhour;
        ServiceTerritory st = TestDataFactory.createServiceTerritory(operhour.Id, true);
        st.Stock__c = true;
        st.Warehouse__c = loc.Id;
        st.Plant__c = plantLoc.Id;
        insert st;
        ServiceResource servResource = TestDataFactory.createServiceResource();
        servResource.LocationId = locInventory.Id;
        insert servResource;

        ServiceTerritoryMember stm = TestDataFactory.createServiceTerritoryMember(operhour.Id, servResource.Id, st.Id);
        stm.EffectiveStartDate =  date.today().addDays(-5);
        stm.EffectiveEndDate =  date.today().addDays(5);
        insert stm;

        List<ProductRequestCardDTO> testResponse = new List<ProductRequestCardDTO>();
        
        Test.startTest();

        testResponse = ProductRequestRelatedListController.getProductRequests(1);

        Test.stopTest();
        System.assert(testResponse.size() != 0);
    }

}