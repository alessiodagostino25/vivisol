public with sharing class customOrderRelatedListController {
    @AuraEnabled(cacheable=true)
    public static List<OrderItem> getOrderProductList(String orderId) {
        String query = 'select Product2.Product_Name_Translate__c , Product2.Product_Code__c,Quantity,UnitPrice,TotalPrice,OrderId ,Id from OrderItem Where OrderId =: orderId ';
        system.debug(query);
        System.debug(Database.query(query));
		return Database.query(query);
        
     }
}