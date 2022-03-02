public with sharing class EntitlementDAO {
    
    public static List<Entitlement> getEntitlementsFromSvcApptBookingWindowsId(List<String> queryFields, List<Id> bookingWindowsIds, String type) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Entitlement WHERE SvcApptBookingWindowsId IN: bookingWindowsIds AND Type =: type';
        System.debug('getEntitlementsFromSvcApptBookingWindowsId QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Entitlement> getEntitlementsFromBusinessLines(List<String> queryFields, List<String> businessLines) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Entitlement WHERE Business_Line__c IN: businessLines AND Type = \'Home Visit\'';
        System.debug('getEntitlementsFromBusinessLines QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Entitlement> getEntitlementForNonTherapyWOs(List<String> queryFields) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Entitlement WHERE Business_Line__c = null AND Treatment_Type__c = null AND Type = \'Home Visit\'';
        System.debug('getEntitlementForNonTherapyWOs QUERY: ' + query);
        
        return Database.query(query);
    }

}