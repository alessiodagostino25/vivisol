@isTest
public class TestProductItemTrigger {
    
    @TestSetup
    static void makeData(){
        Account a = TestDataFactory.initAccountWithAddress();

        Schema.Location l = TestDataFactory.initInventoryLocation(a);

        Product2 parentProduct = new Product2(
            Name = 'Parent Product',
            Product_Code__c = 'testParentProductCode'
        );
        insert parentProduct;

        Product2 p = TestDataFactory.createProduct();
        p.Name = 'prova';
        p.Product_Code__c = 'testProductCode';
        p.Product_Family__c = parentProduct.Id;
        insert p;

        Product2 p2 = TestDataFactory.createProduct();
        p2.Name = 'prova';
        p2.Product_Code__c = 'testProductCode1';
        p2.Product_Family__c = parentProduct.Id;
        insert p2;
    }

    @isTest
    static void testWithOtherProduct() {
        List<Schema.Location> locations = [SELECT Id FROM Location WHERE Account__r.FirstName = 'first name'];
        System.debug('locations size: ' + locations.size());
        Schema.Location l = locations[1];
        Schema.Location l2 = locations[0];
        List<Product2> products = [SELECT Id, Product_Family__r.Name FROM Product2 WHERE Name = 'prova'];
        Product2 p = products[0];
        Product2 p2 = products[1];
        System.debug('Family Name del Product2: ' + p.Product_Family__r.Name);

        ProductItem pi = new ProductItem(
            LocationId = l.Id,
            Product2Id = p.Id,
            QuantityOnHand = 2
        );

        ProductItem pi2 = new ProductItem(
            LocationId = l2.Id,
            Product2Id = p.Id,
            QuantityOnHand = 3
        );

        ProductItem pi3 = new ProductItem(
            LocationId = l.Id,
            Product2Id = p2.Id,
            QuantityOnHand = 3
        );

        List<ProductItem> toInsert = new List<ProductItem>{pi, pi2, pi3};
        
        Test.startTest();
        List<Database.SaveResult> insertResults = Database.insert(toInsert);
        ProductItem queriedPI = [SELECT Family_Name__c FROM ProductItem WHERE Id =: pi.Id];
        System.debug('Family_Name PI: ' + queriedPI.Family_Name__c);

        Database.DeleteResult deleteResult = Database.delete(toInsert[0]);
        Test.stopTest();

        for(Database.SaveResult sr : insertResults) {
            System.assert(sr.isSuccess(), true);
        }

        System.assert(deleteResult.isSuccess());
    }

    @isTest
    static void testWithoutOtherProduct() {
        List<Schema.Location> locations = [SELECT Id FROM Location WHERE Account__r.FirstName = 'first name'];
        System.debug('locations size: ' + locations.size());
        Schema.Location l = locations[1];
        Schema.Location l2 = locations[0];
        List<Product2> products = [SELECT Id, Product_Family__r.Name FROM Product2 WHERE Name = 'prova'];
        Product2 p = products[0];
        Product2 p2 = products[1];
        System.debug('Family Name del Product2: ' + p.Product_Family__r.Name);

        ProductItem pi = new ProductItem(
            LocationId = l.Id,
            Product2Id = p.Id,
            QuantityOnHand = 2
        );

        ProductItem pi2 = new ProductItem(
            LocationId = l2.Id,
            Product2Id = p.Id,
            QuantityOnHand = 3
        );

        List<ProductItem> toInsert = new List<ProductItem>{pi, pi2};
        
        Test.startTest();
        List<Database.SaveResult> insertResults = Database.insert(toInsert);
        ProductItem queriedPI = [SELECT Family_Name__c FROM ProductItem WHERE Id =: pi.Id];
        System.debug('Family_Name PI: ' + queriedPI.Family_Name__c);

        Database.DeleteResult deleteResult = Database.delete(toInsert[0]);
        Test.stopTest();

        for(Database.SaveResult sr : insertResults) {
            System.assert(sr.isSuccess(), true);
        }

        System.assert(deleteResult.isSuccess());
    }

    @isTest
    static void testWithPCSF() {
        List<Product2> products = [SELECT Product_Family__r.Name FROM Product2 WHERE Name = 'prova'];
        Product2 queriedP = products[0];

        List<Schema.Location> locations = [SELECT Id FROM Location WHERE Account__r.FirstName = 'first name'];
        System.debug('locations size: ' + locations.size());
        Schema.Location l = locations[1];

        Picklist_Choise_Set_Flow__c pcsf = TestDataFactory.createPCSF(l.Id, queriedP.Product_Family__r.Name, l.Id, 'testProductCode');
        insert pcsf;
        System.debug('PCSF ParentId: ' + pcsf.Parent_Id__c);
        System.debug('PCSF Value: ' + pcsf.Value__c);

        testWithoutOtherProduct();
    }

    @isTest
    static void relatedItemTest() {
        Schema.Location location = [SELECT Id FROM Location LIMIT 1];
        Account account = TestDataFactory.createPersonAccountWithExternalId('ACC_PI_TEST001');
        insert account;

        Asset asset = TestDataFactory.createAsset(account.Id);
        asset.LocationId = location.Id;
        insert asset;

        ProductItem relatedProductItem = TestDataFactory.createProductItem();
        relatedProductItem.Serialized_Item__c = asset.Id;
        insert relatedProductItem;

        ProductItem productItem = TestDataFactory.createProductItem();
        productItem.RelatedProductItem__c = relatedProductItem.Id;
        
        Test.startTest();

        Database.SaveResult result = Database.insert(productItem);

        Test.stopTest();

        ProductItem queriedProductItem = [SELECT Id, RelatedContainer__c FROM ProductItem WHERE Id =: productItem.Id];

        System.assert(result.isSuccess());
        System.assertEquals(relatedProductItem.Serialized_Item__c, queriedProductItem.RelatedContainer__c);
    }

    @isTest
    static void setOldExternalIdTest() {
        List<Schema.Location> locations = [SELECT Id FROM Location WHERE Account__r.FirstName = 'first name'];
        Schema.Location l = locations[1];
        List<Product2> products = [SELECT Id, Product_Family__r.Name FROM Product2 WHERE Name = 'prova'];
        Product2 p = products[0];
        Account account = [SELECT Id FROM Account WHERE FirstName = 'first name' LIMIT 1];

        Asset a = TestDataFactory.createAsset(account.Id);
        a.SerialNumber = 'X12345Y';
        a.LocationId = l.Id;
        insert a;

        ProductItem pi = new ProductItem(
            LocationId = l.Id,
            Product2Id = p.Id,
            QuantityOnHand = 2,
            SerialNumber = 'XXX',
            Serialized_Item__c = a.Id
        );
        
        Test.startTest();

        Database.SaveResult result = Database.insert(pi);

        Test.stopTest();

        ProductItem queriedPI = [SELECT OLDExternalID__c FROM ProductItem WHERE Id =: pi.Id];

        System.assert(result.isSuccess());
        System.assertEquals(pi.SerialNumber, queriedPI.OLDExternalID__c);
    }
}