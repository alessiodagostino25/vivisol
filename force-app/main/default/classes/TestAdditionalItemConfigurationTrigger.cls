@isTest
public class TestAdditionalItemConfigurationTrigger {
    @isTest
    static void insertTest() {
        Additional_Item_Configuration__c aic = new Additional_Item_Configuration__c();
        
        Test.startTest();

        Database.SaveResult result = Database.insert(aic);

        Test.stopTest();

        Additional_Item_Configuration__c queriedAIC = [SELECT Name, External_Id__c FROM Additional_Item_Configuration__c WHERE Id =: aic.Id];

        //System.assertEquals(queriedAIC.Name, queriedAIC.External_Id__c);
    }
}