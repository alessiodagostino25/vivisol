public without sharing class ProductRequestLineItemDAO {
    
    public static List<ProductRequestLineItem> getPRLIFromParentIds(List<String> queryFields, List<Id> parentIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        	query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM ProductRequestLineItem WHERE ParentId IN: parentIds';
        System.debug('getPRLIFromParentIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<ProductRequestLineItem> getAvailablePRLIFromParentIds(List<String> queryFields, List<Id> parentIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        	query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM ProductRequestLineItem WHERE ParentId IN: parentIds AND Availability__c = \'Available\' AND Status = \'2\'';
        System.debug('getAvailablePRLIFromParentIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<ProductRequestLineItem> getAvailablePRLIFromParentIdsStatus1(List<String> queryFields, List<Id> parentIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        	query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM ProductRequestLineItem WHERE ParentId IN: parentIds AND Availability__c = \'Available\' AND Status = \'1\'';
        System.debug('getAvailablePRLIFromParentIdsStatus1 QUERY: ' + query);
        
        return Database.query(query);
    }
}