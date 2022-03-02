public with sharing class AddressDAO {

    public static List<Schema.Address> getAddressesToNotDefault(Id accountId, Id newDefaultAddress) {
        List<Schema.Address> addresses = [SELECT Id, ParentId, Is_Default__c, Parent.Account__c FROM Address 
                                          WHERE Parent.Account__c =: accountId AND Id !=: newDefaultAddress];
        return addresses;
    }

    public static Schema.Address getAddressFromId(Id addressId) {
        return [SELECT Id, ParentId, Parent.Account__c, Parent.Location_Id__c, Is_Default__c FROM Address WHERE Id =: addressId];
    }

    public static List<Schema.Address> getAddressesFromIds(List<Id> addressIds) {
        return [SELECT Id, ParentId,Parent.Account__c, Parent.Location_Id__c, Is_Default__c,City,Country,CountryCode,Phone_number__c, Regional_Grouping__c, State,
        StateCode,Street,TransportationZone__c,LocationType,PostalCode,IsCreatedSAP__c,IsSyncSAP__c, toLabel(AddressType), Parent.Account__r.Account_External_Id__c,
        Parent.Name, Description
        FROM Address WHERE Id IN: addressIds];
    }

    public static List<Schema.Address> getAddressesForCalloutLoggers(List<String> addressIds) {
        return [SELECT Id,Parent.Location_Id__c FROM Address WHERE Parent.Location_Id__c IN: addressIds];
    }
    
    public static List<Schema.Address> getAddressesSapSyncForCalloutLoggers(List<Id> addressIds) {
        return [SELECT Id,IsSyncSAP__c,Is_Portal_Sync__c  FROM Address WHERE Id IN: addressIds];
    }

    public static List<Schema.Address> getAddressesFromLocation(List<Id> locationId) {
        return [SELECT Id, City, PostalCode, StateCode, CountryCode, AddressType, ParentId FROM Address WHERE ParentId IN :locationId];
    }

    public static List<Schema.Address> getAddressesFromIds(List<String> queryFields, List<Id> relatedIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        	query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Address WHERE Id IN: relatedIds';
        System.debug('getAddressesFromIds QUERY: ' + query);
        
        return Database.query(query);
	}
}