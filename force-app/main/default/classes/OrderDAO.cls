public with sharing class OrderDAO {

    public static String getOrderFromId(String orderId) {
        List<Order> orders = [SELECT Id, Status FROM Order WHERE Id =: orderId];
        String orderstatus = orders[0].Status;
        return orderstatus;
    }

    public static List<Order> getOrdersFromIds(List<String> queryFields, List<Id> relatedIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Order WHERE Id IN: relatedIds';
        System.debug('getOrdersFromIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Order> getOrdersFromCases(List<String> queryFields, List<Id> caseIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Order WHERE Case__c IN: caseIds';
        System.debug('getOrdersFromCases QUERY: ' + query);
        
        return Database.query(query);
    }

}