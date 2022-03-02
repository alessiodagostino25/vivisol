public with sharing class OrderItemDAO {
    
    public static List<Id> getOrderItemIds(String orderId) {
        List<OrderItem> orderItems = [SELECT Id FROM OrderItem WHERE OrderId =: orderId];
        List<Id> orderItemIds = new List<Id>();

        for(OrderItem oi : orderItems) {
            orderItemIds.add(oi.Id);
        }

        return orderItemIds;
    }

    public static OrderItem getOrderItemFromId(String orderItemId) {
        OrderItem oi = [SELECT Id, Product2.Product_Name_Translate__c, Product2.Product_Code__c, toLabel(Product2.Unit_of_measure__c) FROM OrderItem WHERE Id =: orderItemId];
        return oi;
    }

    public static List<OrderItem> getorderitemslistfromorderid(String orderId) {
        return [SELECT Product2.Product_Name_Translate__c , Product2.Product_Code__c,Quantity,Description,Box__c,OrderId ,Id,Product2.Unit_of_measure__c  FROM OrderItem WHERE OrderId =: orderId];
    }

    public static List<OrderItem> getorderitemslistfromid(String orderId) {
        List<OrderItem> orderItems = [SELECT Id FROM OrderItem WHERE OrderId =: orderId];

        return orderItems ;
    }

    public static OrderItem getOrderItemforsapFromId(String orderItemId) {
        OrderItem oi = [SELECT Id, Order.Account_Sales_Organization__r.Sales_Organization__r.Code__c ,Order.Account_Sales_Organization__r.Distribution_Channel__c,Order.Account_Bill_To__r.Account_External_Id__c,Quantity,Product2.Unit_of_Measure__c,Order.Contract_Treatment__r.Contract_Framework__r.Contract_Number__c ,Product2.Product_Code__c FROM OrderItem WHERE Id =: orderItemId];

        return oi;
    }

    public static List<OrderItem> getOrderItemsFromIds(List<String> queryFields, List<String> relatedIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM OrderItem WHERE Id IN: relatedIds';
        System.debug('getOrderItemsFromIds QUERY: ' + query);
        
        return Database.query(query);
    }
}