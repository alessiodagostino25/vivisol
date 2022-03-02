public class LocationDAO {
    
    public static List<Schema.Location> getLocationsFromAccountIds(List<String> queryFields, List<Id> accountIds) {

        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Location WHERE Account__c IN: accountIds';
        System.debug('getLocationsFromAccountIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Schema.Location> getLocationsFromlocationid( List<String> locationsIds){
        return [SELECT Account__c FROM Location WHERE Id IN : locationsIds ] ;
    }

    public static List<Schema.Location> getvisitoraddressFromlocationid( List<Id> locationsIds){
        return [SELECT Id,VisitorAddress.Street,VisitorAddress.PostalCode,VisitorAddress.StateCode,VisitorAddress.CountryCode,LocationType,VisitorAddress.City FROM Location WHERE Id IN : locationsIds ] ;
    }

    public static List<Schema.Location> getLocationsFromIds(List<String> queryFields, List<Id> relatedIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Location WHERE Id IN: relatedIds';
        System.debug('getLocationsFromIds QUERY: ' + query);
        return Database.query(query);
    }

    @AuraEnabled
    public static String getLocationNameFromId(Id locationId) {
        Schema.Location l = [SELECT Name FROM Location WHERE Id =: locationId];
        return l.Name;
    }

    public static List<Schema.Location> getLocationsFromExternalId(List<String> queryFields, String locationExternalId) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Location WHERE location_id__c = :locationExternalId';
        System.debug('getLocationsFromIds QUERY: ' + query);
        return Database.query(query);
    }

}