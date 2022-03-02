trigger ASOTrigger on Account_Sales_Organization__c (before insert, after insert, before update, after update) {
    List<String> ASOQueryFields = new List<String>{'Sales_Organization__r.Code__c', 'Account__c'};

    List<Id> relatedAccountIds = new List<Id>();
    List<Id> relatedIds = new List<Id>();

    Map<Id, Account_Sales_Organization__c> asoMap = new Map<Id, Account_Sales_Organization__c>();

    for(Account_Sales_Organization__c aso : Trigger.new) {
        if(aso.Account__c != null && aso.Sales_Organization__c != null) {
            relatedAccountIds.add(aso.Account__c);
            relatedIds.add(aso.Id);
        }
    }
    
    if(!relatedAccountIds.isEmpty()) {
        List<Id> ASOIdsToCreate = new List<Id>();
        List<Id> ASOIdsToUpdate = new List<Id>();
        Map<Id, Account_Sales_Organization__c> oldMap = new Map<Id, Account_Sales_Organization__c>();
        if(Trigger.isInsert) {
            System.debug('IN INSERT');
        }
        else if(Trigger.isUpdate && Trigger.isBefore) {
            System.debug('IN UPDATE!!!!');
            for(Account_Sales_Organization__c aso : Trigger.old) {
                oldMap.put(aso.Id, aso);
            }
        }

        //If Trigger.isUpdate, I need to check whether ASOs have really changed, or only isSyncSAP__c has.

        if(Trigger.isUpdate && Trigger.isBefore) {
            if(!System.isFuture()) {
                System.debug('TRIGGER IS UPDATE');
                for(Account_Sales_Organization__c aso : Trigger.new) {
                    Account_Sales_Organization__c oldASO = oldMap.get(aso.Id);

                    /*NEED TO CHECK WHETHER ANY FIELD HAS CHANGED OR ONLY isSyncSAP/isCreatedSAP HAS. In case, add that ASO to the ones to update and the record is
                    *not in Sync anymore*/ 
                    if(ASOService.hasChanged(aso, oldASO) == true) {
                        System.debug('ASO HAS CHANGED');
                        if(aso.isCreatedSAP__c == false) {
                            ASOIdsToCreate.add(aso.Id);
                        }
                        else if(aso.isCreatedSAP__c == true){
                            ASOIdsToUpdate.add(aso.Id);
                            aso.isSyncSAP__c = 'NotSync';
                        }
                    } 
                }
            }
        }

        //If Trigger.isInsert, futureCreateCallout must be called for every record

        else if(Trigger.isInsert && Trigger.isAfter) {
            try{
                AccountSalesOrganizationTriggerHandler.handleTrigger(trigger.New, Trigger.operationType);
            } catch(Exception e){
                System.debug('Error');
            }
            
            for(Account_Sales_Organization__c aso : Trigger.new) {
                ASOIdsToCreate.add(aso.Id);
            }

            if(!ASOIdsToCreate.isEmpty()) {

                /*Updating the new ASO Name. This method also does a CREATE on SAP, because it tries to UPDATE a record with isCreated__c = false.
                Therefore, it does a CREATE (see above logic for update trigger)*/

                ASOService.updateASOName(ASOIdsToCreate);
                
                //ASOService.futureCreateCallout(ASOIdsToCreate);  
            }

        }

        if(Trigger.isInsert) {
            List<Account> relatedAccounts = AccountSalesOrganizationDAO.getRelatedAccounts(relatedAccountIds);

            if(Trigger.isInsert && Trigger.isBefore) {
                List<Id> relatedSOIds = new List<Id>();

                for(Account_Sales_Organization__c aso : Trigger.new) {
                    relatedSOIds.add(aso.Sales_Organization__c);
                }

                Map<Id, Account> accountMap = new Map<Id, Account>();
                Map<Id, Sales_Organization__c> salesOrgMap = new Map<Id, Sales_Organization__c>([SELECT Id, Code__c FROM Sales_Organization__c WHERE Id IN: relatedSOIds]);

                if(relatedAccounts != null && !relatedAccounts.isEmpty()) {
                    for(Account a : relatedAccounts) {
                        accountMap.put(a.Id, a);
                    }
                }
                
                // Filling aso.External_Id__c
                
                for(Account_Sales_Organization__c aso : Trigger.new) {
                    if(!accountMap.isEmpty() && !salesOrgMap.isEmpty()) {
                        Account relatedAccount = accountMap.get(aso.Account__c);
                        Sales_Organization__c relatedSalesOrg = salesOrgMap.get(aso.Sales_Organization__c);

                        if(relatedAccount != null && relatedSalesOrg != null) {
                            String externalId = relatedAccount.Account_External_Id__c + relatedSalesOrg.Code__c;

                            if(aso.Distribution_Channel__c != null) {
                                externalId = externalId + aso.Distribution_Channel__c;
                            }
                            if(aso.Division__c != null) {
                                externalId = externalId + aso.Division__c;
                            }
                            aso.External_Id__c = externalId;
                        }
                    }
                }
            }

            if(Trigger.isInsert && Trigger.isAfter) {
                List<Account_Sales_Organization__c> queriedASOs = AccountSalesOrganizationDAO.getASOsFromIds(ASOQueryFields, relatedIds);

                for(Account_Sales_Organization__c aso : queriedASOs) {
                    asoMap.put(aso.Account__c, aso);
                }

                if(!relatedAccounts.isEmpty()) {
                    ASOService.updateRelatedAccounts(relatedAccounts, asoMap);
                }

                List<Account_Sales_Organization__c> toUpdateRelatedAccounts = new List<Account_Sales_Organization__c>();

                for(Account_Sales_Organization__c aso : Trigger.new) {
                    if(aso.Account__c != null) {
                        toUpdateRelatedAccounts.add(aso);
                    }
                }

                if(FeatureManagementService.getFeatureStatus('Update_Account_Is_Portal_Sync') || Test.isRunningTest()) {
                    if(!toUpdateRelatedAccounts.isEmpty()) {
                        ASOService.updateAccountIsPortalSync(toUpdateRelatedAccounts);
                    }
                }
            }
        }

        /*IF A CREATION SAP-SIDE HAS FAILED (BUT HAS SUCCESS IN SALESFORCE), THE TRIGGER MUST MAKE A futureCreateCallout DUE FIELD: 
        UNO CHE MI DICE SE ESISTE ANCHE SU SAP, UNO CHE MI DICE LO STATO DI SINCRONIZZAZIONE (picklist)*/
        
        //Must not filter on Trigger.isInsert, because futureCreateCallout could be called also in Trigger.isUpdate for not-isCreatedSAP__c records
        
        if(Trigger.isUpdate && Trigger.isBefore) {
            if(!System.isFuture()) {
                //MUST NOT CALLOUT IF UPDATED FIELDS ARE ONLY THE ONES THAT REPRESENT SYNC-WITH-SAP STATUS
                if(!ASOIdsToUpdate.isEmpty()) {
                    if(FeatureManagementService.getFeatureStatus('SAP_SO_Update') || Test.isRunningTest()) {
                        System.debug('Ids calling UPDATE on: ' + ASOIdsToUpdate);

                        // Publishing events to tell the component that a callout is starting

                        /* List<Starting_Callout_Event__e> startingCalloutEvents = new List<Starting_Callout_Event__e>();

                        for(Id asoId : ASOIdsToUpdate) {
                            Starting_Callout_Event__e startingCalloutEvent = new Starting_Callout_Event__e(
                                RecordId__c = asoId
                            );

                            startingCalloutEvents.add(startingCalloutEvent);
                        } */

                        /* if(!startingCalloutEvents.isEmpty()) {
                            List<Database.SaveResult> results = EventBus.publish(startingCalloutEvents);
                            System.debug('EVENTS STARTING CALLOUT PUBLISHED size: ' + results.size());
                        } */

                        // Update callout
                
                        ASOService.futureUpdateCallout(ASOIdsToUpdate);
                    }
                }
                if(!ASOIdsToCreate.isEmpty()) {
                    if(FeatureManagementService.getFeatureStatus('SAP_SO_Create') || Test.isRunningTest()) {
                        System.debug('Ids calling CREATE on: ' + ASOIdsToCreate);

                        // Publishing events to tell the component that a callout is starting

                        /* List<Starting_Callout_Event__e> startingCalloutEvents = new List<Starting_Callout_Event__e>();

                        for(Id asoId : ASOIdsToCreate) {
                            Starting_Callout_Event__e startingCalloutEvent = new Starting_Callout_Event__e(
                                RecordId__c = asoId
                            );

                            startingCalloutEvents.add(startingCalloutEvent);
                        } */

                        /* if(!startingCalloutEvents.isEmpty()) {
                            List<Database.SaveResult> results = EventBus.publish(startingCalloutEvents);
                            System.debug('EVENTS STARTING CALLOUT PUBLISHED size: ' + results.size());
                        } */

                        // Create callout
                
                        ASOService.futureCreateCallout(ASOIdsToCreate);
                    }
                }
            }
        }
    }

    if(Trigger.isUpdate && Trigger.isAfter) {
        List<Account_Sales_Organization__c> toUpdateRelatedAccounts = new List<Account_Sales_Organization__c>();

        for(Account_Sales_Organization__c aso : Trigger.new) {
            if(aso.Account__c != null) {
                toUpdateRelatedAccounts.add(aso);
            }
        }

        if(FeatureManagementService.getFeatureStatus('Update_Account_Is_Portal_Sync') || Test.isRunningTest()) {
            if(!toUpdateRelatedAccounts.isEmpty()) {
                ASOService.updateAccountIsPortalSync(toUpdateRelatedAccounts);
            }
        }
    }
}