trigger AddressTrigger on Address (before insert, after insert, before update, after update) {
    if(Trigger.isBefore && Trigger.isInsert) {
        if(!FeatureManagementService.getFeatureStatus('SAP_Address_Create')) {
            for(Schema.Address a : Trigger.new) {
                a.IsCreatedSAP__c = false;
                a.IsSyncSAP__c = false;
            }
        }
    }

    if(Trigger.isAfter && Trigger.isInsert) {
        // New default addresses are sent to SAP via flow, but we need to publish the Creation event for the ones created via Mulesoft (portals)

        Id currentUserId = UserInfo.getUserId();
        User currentUser = [SELECT Id, Profile.Name FROM User WHERE Id =: currentUserId];

        if(currentUser.Profile.Name == 'System_Admin_Mulesoft') {
            List<String> toSendWithEventIds = new List<String>();

            for(Schema.Address address : Trigger.new) {
                if(address.AddressType != 'XXDEFAULT') {
                    toSendWithEventIds.add(address.Id);
                }
            }

            if(!toSendWithEventIds.isEmpty()) {
                if(FeatureManagementService.getFeatureStatus('SAP_Address_Create') || Test.isRunningTest()) {
                    AddressService.publishAddressCreationEvents(toSendWithEventIds);
                }
            }
        }
    }

    if(Trigger.isBefore && Trigger.isUpdate) {
        AddressService.setIsPortalSync(Trigger.new, Trigger.oldMap, true, false);

        if(!FeatureManagementService.getFeatureStatus('SAP_Address_Update')) {
            for(Schema.Address a : Trigger.new) {
                Schema.Address oldAddress = Trigger.oldMap.get(a.Id);

                if(AddressService.isAddressChanged(a, oldAddress)) {
                    a.IsCreatedSAP__c = false;
                    a.IsSyncSAP__c = false;
                }
            }
        }
    }

    if(Trigger.isAfter && Trigger.isUpdate) {
        List<Id> parentIds = new List<Id>();
        List<Id> relatedAccountIds = new List<Id>();
        List<Id> addressIdsForCreationEvent = new List<Id>();
        List<Id> addressIdsForUpdateEvent = new List<Id>();
        List<Schema.Address> newDefaults = new List<Schema.Address>();
        List<Schema.Address> changedAddresses = new List<Schema.Address>();
        //List<Status_Change_Event__e> changeEvents = new List<Status_Change_Event__e>();
        
        Map<Id, Account> accountMap = new Map<Id, Account>();

        for(Schema.Address a : Trigger.new) {
            Schema.Address oldAddress = Trigger.oldMap.get(a.Id);

            if(AddressService.isAddressChanged(a, oldAddress)) {
                parentIds.add(a.ParentId);
                changedAddresses.add(a);

                if(a.IsCreatedSAP__c == true){
                    addressIdsForUpdateEvent.add(a.Id);
                }

                if(a.IsCreatedSAP__c == false){
                    addressIdsForCreationEvent.add(a.Id);   
                }
            }

            if(a.Is_Default__c == true && oldAddress.Is_Default__c == false) {
                newDefaults.add(a);
            }

            /* if((oldAddress.IsSyncSAP__c == true && a.IsSyncSAP__c == false) ||
            (oldAddress.IsCreatedSAP__c == true && a.IsCreatedSAP__c == false)) {
                Status_Change_Event__e changeEvent = new Status_Change_Event__e(
                    RecordId__c = a.Id
                );

                changeEvents.add(changeEvent);
            } */
        }

        /* if(!changeEvents.isEmpty()) {
            List<Database.SaveResult> results = Eventbus.publish(changeEvents);
            System.debug('STATUS CHANGE EVENTS ADDRESS PUBLISHED size: ' + results.size());
        } */

        // If an Address is set to Default, all the others are not Default anymore and the Location of the Account is this Address

        if(!newDefaults.isEmpty()) {
            AddressService.handleDefaultUpdate(newDefaults);
        }

        // Update the Location Name
        
        if(!changedAddresses.isEmpty() && !parentIds.isEmpty()) {
            AddressService.updateRelatedLocations(changedAddresses);
        }

        // Fire sync events

        if(!addressIdsForCreationEvent.isEmpty()) {
            if(FeatureManagementService.getFeatureStatus('SAP_Address_Create') || Test.isRunningTest()) {
                AddressService.publishAddressCreationEvents(addressIdsForCreationEvent);
            }
        }

        if(!addressIdsForUpdateEvent.isEmpty()) {
            if(FeatureManagementService.getFeatureStatus('SAP_Address_Update') || Test.isRunningTest()) {
                AddressService.publishAddressUpdateEvents(addressIdsForUpdateEvent);
            }
        }
    }
}