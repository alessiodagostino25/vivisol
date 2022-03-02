public without sharing class LocationService {
    public static void setIsPortalSync(List<Schema.Location> locations, Map<Id, Schema.Location> oldMap) {
        List<String> addressQueryFields = new List<String>{'Is_Portal_Sync__c'};

        List<String> visitorAddressIds = new List<String>();
        List<Schema.Location> toUpdateVisitorAddress = new List<Schema.Location>();
        List<Schema.Address> relatedVisitorAddresses = new List<Schema.Address>();

        Map<String, Schema.Address> addressMap = new Map<String, Schema.Address>();

        Profile adminMulesoft = [SELECT Id FROM Profile WHERE Name = 'System_Admin_Mulesoft'];
        if(UserInfo.getProfileId() != adminMulesoft.Id) {
            List<Pimcore_Field_Mapping__mdt> fieldMappings = [SELECT Object__c, Field__c FROM Pimcore_Field_Mapping__mdt WHERE Object__c =: 'Location'];

            if(fieldMappings != null && !fieldMappings.isEmpty()) {
                for(Schema.Location record : locations) {
                    SObject oldRecord = oldMap.get((String)record.get('Id'));

                    if(oldRecord != null) {
                        for(Pimcore_Field_Mapping__mdt fieldMapping : fieldMappings) {
                            if(oldRecord.get(fieldMapping.Field__c) != record.get(fieldMapping.Field__c)) {
                                toUpdateVisitorAddress.add(record);
                                break;
                            }
                        }
                    }
                }

                if(!toUpdateVisitorAddress.isEmpty()) {
                    for(Schema.Location location : toUpdateVisitorAddress) {
                        visitorAddressIds.add(location.VisitorAddressId);
                    }

                    relatedVisitorAddresses = AddressDAO.getAddressesFromIds(addressQueryFields, visitorAddressIds);
                  
                    if(!relatedVisitorAddresses.isEmpty()) {
                        SObjectServiceClass.updateGenericField('Address', '03', 'Is_Portal_Sync__c', relatedVisitorAddresses);
                    } 
                }
            }
        }
    }
}