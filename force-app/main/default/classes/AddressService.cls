public class AddressService {

    public static void updateRelatedLocations(List<Schema.Address> addresses) {
        System.debug('----- updateRelatedLocations -----');
        List<Id> relatedAccountIds = new List<Id>();
        List<Id> addressIds = new List<Id>();
        List<Id> parentIds = new List<Id>();
        List<Schema.Address> addressUpdate = new List<Schema.Address>();
        List<Schema.Address> addressesFromQuery = new List<Schema.Address>();

        Map<Id, Schema.Address> addressMap = new Map<Id, Schema.Address>();
        Map<Id, Schema.Location> locationMap = new Map<Id, Schema.Location>();
        Map<Id, Account> accountMap = new Map<Id, Account>();

        //Addresses from a query to get toLabel(AddressType). Then map to Ids to use these values

        for(Schema.Address a : addresses) {
            addressIds.add(a.Id);
            parentIds.add(a.ParentId);
        }
        addressesFromQuery = AddressDAO.getAddressesFromIds(addressIds);
        for(Schema.Address a : addressesFromQuery) {
            addressMap.put(a.Id, a);
        }

        if(!parentIds.isEmpty()) {
            List<String> locationQueryFields = new List<String>{'Name','Account__c','Location_Id__c'};
            List<Schema.Location> locations = LocationDAO.getLocationsFromIds(locationQueryFields, parentIds);
            if(!locations.isEmpty()) {
                for(Integer i=0; i<locations.size(); i++){
                    locationMap.put(locations[i].Id, locations[i]);
                }

                for(Schema.Location loc : locations) {
                    relatedAccountIds.add(loc.Account__c);
                }
                
                List<Account> relatedAccounts = AccountDAO.getAccountFromIds(relatedAccountIds);
                List<Schema.Location> locationsToUpdate = new List<Schema.Location>();

                if(relatedAccounts != null && !relatedAccounts.isEmpty()) {
                    for(Account a : relatedAccounts) {
                        accountMap.put(a.Id, a);
                    } 

                    for(Schema.Address newaddress : addressesFromQuery ){
                        Schema.Location relatedLocation = locationMap.get(newaddress.ParentId);
                        if(relatedLocation != null) {
                            Id relatedAccountId = relatedLocation.Account__c;
                            Account relatedAccount = accountMap.get(relatedAccountId);
                            if(relatedAccount != null) {
                                String name;
                                String firstName;
                                String middleName;
                                String lastName;
                                System.debug('Person Account?: ' + relatedAccount.IsPersonAccount); 
                                if(relatedAccount.IsPersonAccount == false) {
                                    name = relatedAccount.Name;
                                    firstName = '';
                                    middleName = '';
                                    lastName = '';
                                }else {
                                    name = '';
                                    if(relatedAccount.FirstName != null) {
                                        firstName = relatedAccount.FirstName + ' ';
                                    } else {
                                        firstName = '';
                                    }
                                    if(relatedAccount.MiddleName != null) {
                                        middleName = relatedAccount.MiddleName +' ';
                                    } else {
                                        middleName = '';
                                    }
                                    lastName = relatedAccount.LastName;  //mandatory field
                                    name = firstName + middleName + lastName;
                                }

                                relatedLocation.City__c = newaddress.City;
                                relatedLocation.Country__c = newaddress.Country;
                                relatedLocation.CountryCode__c = newaddress.CountryCode;
                                relatedLocation.State__c = newaddress.State;
                                relatedLocation.Street__c = newaddress.Street;
                                relatedLocation.PostalCode__c = newaddress.PostalCode;
                                relatedLocation.Address__c = newaddress.Street + '\n' + newaddress.City + ' ' + newaddress.PostalCode;

                                if(newaddress.State != null) {
                                    relatedLocation.Address__c = relatedLocation.Address__c + '\n' + newaddress.State;
                                }

                                relatedLocation.Address__c = relatedLocation.Address__c + '\n' + newaddress.Country;

                                if(newaddress.AddressType != relatedLocation.Name) {
                                    System.debug('AddressType: ' + addressMap.get(newaddress.Id).AddressType);
                                    if(newaddress.AddressType != 'XXDEFAULT') {
                                        relatedLocation.Name = name + ' - ' + addressMap.get(newaddress.Id).AddressType;
                                    }
                                }
                                if(!locationsToUpdate.contains(relatedLocation)) {
                                    locationsToUpdate.add(relatedLocation);
                                    System.debug('Location name: ' + relatedLocation.Name);
                                }
                            }
                        } 
                    }
                    if(!locationsToUpdate.isEmpty()) {
                        update locationsToUpdate;
                        System.debug('Location updated');
                    }
                }
            }
        }
    }

    @AuraEnabled
    public static void publishAddressCreationEvents(List<Id> addressIds) {
        System.debug('----- publishAddressCreationEvents -----');
        List<Address_Creation__e> addressCreationEvents = new List<Address_Creation__e>();

        List<Schema.Address> addressesFromQuery = [SELECT Id, ParentId,Parent.Account__c, Parent.Location_Id__c, Is_Default__c,City,Country,CountryCode,Phone_number__c, Regional_Grouping__c,
        StateCode,Street,TransportationZone__c,LocationType,PostalCode,IsCreatedSAP__c,IsSyncSAP__c, AddressType, Parent.Account__r.Account_External_Id__c,
        Parent.Name, Description
        FROM Address WHERE Id IN: addressIds];

        for(Schema.Address newAddress : addressesFromQuery) {
            Address_Creation__e  addressCreateEvent = new Address_Creation__e ();
            addressCreateEvent.Account__c = newAddress.Parent.Account__r.Account_External_Id__c;
            addressCreateEvent.AddressType__c = newaddress.AddressType;
            addressCreateEvent.City__c = newaddress.City;
            addressCreateEvent.Country__c = newaddress.CountryCode;
            addressCreateEvent.Location_Id__c = newAddress.Parent.Location_Id__c;
            addressCreateEvent.Location_Name__c = newAddress.Parent.Name;
            addressCreateEvent.Location_Type__c = newaddress.LocationType;
            addressCreateEvent.Phone_number__c = newaddress.Phone_number__c;
            addressCreateEvent.Postal_Code__c = newaddress.PostalCode;
            addressCreateEvent.State__c = newaddress.StateCode;
            addressCreateEvent.Street__c = newaddress.Street;
            addressCreateEvent.TransportationZone__c = newaddress.TransportationZone__c;
            addressCreateEvent.Address_Id__c = newAddress.Id;
            addressCreateEvent.Regional_Grouping__c = newAddress.Regional_Grouping__c;
            System.debug('AddressCreationEvent: ' + addressCreateEvent);

            addressCreationEvents.add(addressCreateEvent);

            // Mulesoft will update to false if not successful
            newaddress.IsSyncSAP__c = true; 
            newaddress.IsCreatedSAP__c = true; 
        }

        if(!addressCreationEvents.isEmpty()) {
            List<Database.SaveResult> results = EventBus.publish(addressCreationEvents);
            System.debug('SaveResult of Address Creation Events size: ' + results.size());
            for(Database.SaveResult result : results) {
                System.debug('isSuccess of this SaveResult: ' + result.isSuccess());
            }

            update addressesFromQuery;
        }
    }

    @AuraEnabled
    public static void publishAddressUpdateEvents(List<Id> addressIds) {
        System.debug('----- publishAddressUpdateEvents -----');
        List<Address_Update__e> addressUpdateEvents = new List<Address_Update__e>();
        List<Schema.Address> addressesFromQuery = [SELECT Id, ParentId,Parent.Account__c, Parent.Location_Id__c, Is_Default__c,City,Country,CountryCode,Phone_number__c, Regional_Grouping__c,
        StateCode,Street,TransportationZone__c,LocationType,PostalCode,IsCreatedSAP__c,IsSyncSAP__c, AddressType, Parent.Account__r.Account_External_Id__c,
        Parent.Name, Description
        FROM Address WHERE Id IN: addressIds];

        for(Schema.Address newAddress : addressesFromQuery) {
            // Should set isSyncSAP to false.. but it has no sense without checking the isSuccess before setting it to true. But I can't do that. Should add AddressId on the event
            Address_Update__e addressUpdateEvent = new Address_Update__e();
            addressUpdateEvent.Account__c = newAddress.Parent.Account__r.Account_External_Id__c;
            addressUpdateEvent.AddressType__c = newaddress.AddressType;
            addressUpdateEvent.City__c = newaddress.City;
            addressUpdateEvent.Country__c = newaddress.CountryCode;
            addressUpdateEvent.Location_Id__c = newAddress.Parent.Location_Id__c;
            addressUpdateEvent.Location_Name__c = newAddress.Parent.Name;
            addressUpdateEvent.Location_Type__c = newaddress.LocationType;
            addressUpdateEvent.Phone_number__c = newaddress.Phone_number__c;
            addressUpdateEvent.Postal_Code__c = newaddress.PostalCode;
            addressUpdateEvent.State__c = newaddress.StateCode;
            addressUpdateEvent.Street__c = newaddress.Street;
            addressUpdateEvent.TransportationZone__c = newaddress.TransportationZone__c;
            addressUpdateEvent.Address_Id__c = newAddress.Id;
            addressUpdateEvent.Regional_Grouping__c = newAddress.Regional_Grouping__c;
            System.debug('AddressUpdateEvent: ' + addressUpdateEvent);

            addressUpdateEvents.add(addressUpdateEvent);

            // Mulesoft will update to false if not successful
            newaddress.IsSyncSAP__c = true; 
            newaddress.IsCreatedSAP__c = true; 
        }

        if(!addressUpdateEvents.isEmpty()) {
            List<Database.SaveResult> results = EventBus.publish(addressUpdateEvents);
            System.debug('SaveResult of Address Update Events size: ' + results.size());
            for(Database.SaveResult result : results) {
                System.debug('isSuccess of this SaveResult: ' + result.isSuccess());
            }

            update addressesFromQuery;
        }
    }

    /*
    public static Address_Update__e initAddressUpdateEvent(Schema.Address newDefaults) {
        // init Address_Update__e event ---> just init it.
    }*/


    public static void handleDefaultUpdate(List<Schema.Address> newDefaults) {
        Schema.Address newDefault = new Schema.Address();
        List<Schema.Address> addressesToUpdate = new List<Schema.Address>();
        Account relatedAccount = new Account();
        //Is this correct? Maybe only one record is passed to this method
        if(newDefaults.size() < 1) {
            System.debug('Empty defaults list');
        }
        else {
            newDefault = AddressDAO.getAddressFromId(newDefaults[0].Id);
        }
        //Setting the list of Address to update to Not-Default-Anymore and getting the Account related to the Location related to the Address
        if(newDefault != null) {
            addressesToUpdate = AddressDAO.getAddressesToNotDefault(newDefault.Parent.Account__c, newDefault.Id);
            Id relatedAccountId = newDefault.Parent.Account__c;
            List<String> queryFields = new List<String>{'Id', 'Location__c'};
            relatedAccount = AccountDAO.getAccountFromId(queryFields, relatedAccountId);
        }
        //Updating all the other Addresses of that Location to Is_Default__c = false
        if(!addressesToUpdate.isEmpty()) {
            for(Schema.Address a : addressesToUpdate) {
                a.Is_Default__c = false;
            }
            update addressesToUpdate;
        }
        //Updating the Location__c of the related Account with the LocationId of the new Default Address
        if(relatedAccount != null) {
            if(newDefault.Is_Default__c == true) {
                relatedAccount.Location__c = newDefault.ParentId;
                relatedAccount.Address_ID__c = newDefault.Parent.Location_Id__c;
                update relatedAccount;
            }
        }
    }

    public static void updateAndcreateEventforbatchprocess(List<Id> parentIds, List<Schema.Address> triggernew) {
        System.debug('UPDATEANDEVENT');
        Map<Id, Schema.Location> locationMap = new Map<Id, Schema.Location>();
        Map<Id, Account> accountMap = new Map<Id, Account>();
        List<Id> relatedAccountIds = new List<Id>();
        List<Id> addressIds = new List<Id>();
        List<Schema.Address> addressesFromQuery = new List<Schema.Address>();
        List<Schema.Address> addressUpdate = new List<Schema.Address>();
        
        for(Schema.Address a : triggernew) {
            addressIds.add(a.Id);
        }

        addressesFromQuery = [SELECT Id, ParentId,Parent.Account__c, Parent.Location_Id__c, Is_Default__c,City,Country,CountryCode,Phone_number__c, Regional_Grouping__c,
        StateCode,Street,TransportationZone__c,LocationType,PostalCode,IsCreatedSAP__c,IsSyncSAP__c, AddressType, Parent.Account__r.Account_External_Id__c,
        Parent.Name, Description
        FROM Address WHERE Id IN: addressIds];
        
        if(parentIds != null) {
            List<String> locationQueryFields = new List<String>{'Name','Account__c','Location_Id__c'};
            List<Schema.Location> locations = LocationDAO.getLocationsFromIds(locationQueryFields, parentIds);

            if(locations != null) {
                for(Integer i=0; i<locations.size(); i++){
                    locationMap.put(locations[i].Id, locations[i]);
                }

                for(Schema.Location loc : locations) {
                    relatedAccountIds.add(loc.Account__c);
                }

                List<Account> relatedAccounts = AccountDAO.getAccountFromIds(relatedAccountIds);

                List<Address_Update__e> addressUpdateEventList = new List<Address_Update__e>();
                List<Address_Creation__e> addressCreateEventList = new List<Address_Creation__e>();

                if(relatedAccounts != null) {
                    for(Account a : relatedAccounts) {
                        accountMap.put(a.Id, a);
                    } 

                    for(Schema.Address newAddress : addressesFromQuery ) {
                        Schema.Location relatedLocation = locationMap.get(newAddress.ParentId);
                        Id relatedAccountId = relatedLocation.Account__c;
                        
                        if(relatedAccountId != null) {
                            Account relatedAccount = accountMap.get(relatedAccountId);

                            if(relatedAccount != null) {
                                if(newAddress.IsCreatedSAP__c == true) {
                                    Address_Update__e addressUpdateEvent = new Address_Update__e();
                                    addressUpdateEvent.Account__c = relatedAccount.Account_External_Id__c;
                                    addressUpdateEvent.AddressType__c = newAddress.AddressType;
                                    addressUpdateEvent.City__c = newAddress.City;
                                    addressUpdateEvent.Country__c = newAddress.CountryCode;
                                    addressUpdateEvent.Location_Id__c = relatedLocation.Location_Id__c;
                                    addressUpdateEvent.Location_Name__c = relatedLocation.Name;
                                    addressUpdateEvent.Location_Type__c = newAddress.LocationType;
                                    addressUpdateEvent.Phone_number__c = newAddress.Phone_number__c;
                                    addressUpdateEvent.Postal_Code__c = newAddress.PostalCode;
                                    addressUpdateEvent.State__c = newAddress.StateCode;
                                    addressUpdateEvent.Street__c = newAddress.Street;
                                    addressUpdateEvent.TransportationZone__c = newAddress.TransportationZone__c;
                                    addressUpdateEvent.Address_Id__c = newAddress.Id;
                                    addressUpdateEvent.Regional_Grouping__c = newAddress.Regional_Grouping__c;
                                    addressUpdateEventList.add(addressUpdateEvent) ;
                                    newAddress.IsSyncSAP__c = true ;
                                    addressUpdate.add(newAddress);
                                }
                                if(newAddress.IsCreatedSAP__c == false ) {
                                    Address_Creation__e  addressCreateEvent = new Address_Creation__e ();
                                    addressCreateEvent.Account__c = relatedAccount.Account_External_Id__c;
                                    addressCreateEvent.AddressType__c = newAddress.AddressType;
                                    addressCreateEvent.City__c = newAddress.City;
                                    addressCreateEvent.Country__c = newAddress.CountryCode;
                                    addressCreateEvent.Location_Id__c = relatedLocation.Location_Id__c;
                                    addressCreateEvent.Location_Name__c = relatedLocation.Name;
                                    addressCreateEvent.Location_Type__c = newAddress.LocationType;
                                    addressCreateEvent.Phone_number__c = newAddress.Phone_number__c;
                                    addressCreateEvent.Postal_Code__c = newAddress.PostalCode;
                                    addressCreateEvent.State__c = newAddress.StateCode;
                                    addressCreateEvent.Street__c = newAddress.Street;
                                    addressCreateEvent.TransportationZone__c = newAddress.TransportationZone__c;
                                    addressCreateEvent.Address_Id__c = newAddress.Id;
                                    addressCreateEvent.Regional_Grouping__c = newAddress.Regional_Grouping__c;
                                    addressCreateEventList.add(addressCreateEvent) ;
                                    newAddress.IsSyncSAP__c = true ; 
                                    newAddress.IsCreatedSAP__c = true ; 
                                    addressUpdate.add(newAddress) ;
                                } 
                            }
                        }    
                    }

                    List<Database.SaveResult> updatevents = EventBus.publish(addressUpdateEventList);
                    List<Database.SaveResult> createevents = EventBus.publish(addressCreateEventList);
                    update addressUpdate ;
                  
                }
            }
        }
    }

    public static Boolean isAddressChanged(Schema.Address newAddress, Schema.Address oldAddress){
        if(newAddress.AddressType != oldAddress.AddressType){
            return true;
        }
        if(newAddress.City != oldAddress.City){
            return true;
        }
        if(newAddress.CountryCode != oldAddress.CountryCode){
            return true;
        }
        if(newAddress.LocationType != oldAddress.LocationType){
            return true;
        }
        if(newAddress.Phone_number__c != oldAddress.Phone_number__c){
            return true;
        }
        if(newAddress.PostalCode != oldAddress.PostalCode){
            return true;
        }
        if(newAddress.StateCode != oldAddress.StateCode){
            return true;
        }
        if(newAddress.Street != oldAddress.Street){
            return true;
        }
        if(newAddress.TransportationZone__c != oldAddress.TransportationZone__c){
            return true;
        }
        if(newAddress.Regional_Grouping__c != oldAddress.Regional_Grouping__c){
            return true;
        }
        if(newAddress.Is_Default__c != oldAddress.Is_Default__c){
            return true;
        }
        return false;
    }

    public static void setIsPortalSync(List<Schema.Address> addresses, Map<Id, Schema.Address> oldMap, Boolean checkProfile, Boolean performDML) {
        SObjectServiceClass.setIsPortalSync(addresses, oldMap, 'Address', checkProfile, performDML);
    }
}