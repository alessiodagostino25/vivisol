trigger AccountCompanyTrigger on Account_Company__c (before insert, after insert, before update) {
    List<Id> relatedIds = new List<Id>();

    for(Account_Company__c company : Trigger.new) {
        if(company.Account__c != null) {
            relatedIds.add(company.Id);
        }
    }
    
    List<Id> CompanyIdsToCreate = new List<Id>();
    List<Id> CompanyIdsToUpdate = new List<Id>();
    Map<Id, Account_Company__c> oldMap = new Map<Id, Account_Company__c>();

    if(Trigger.isBefore && Trigger.isInsert) {
        List<Id> relatedAccountIds = new List<Id>();

        for(Account_Company__c ac : Trigger.new) {
            relatedAccountIds.add(ac.Account__c);
        }

        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Account_External_Id__c FROM Account WHERE Id IN: relatedAccountIds]);

        // Filling accountCompany.External_ID__c

        if(!accountMap.isEmpty()) {
            for(Account_Company__c ac : Trigger.new) {
                Account relatedAccount = accountMap.get(ac.Account__c);

                if(relatedAccount != null) {
                    String externalId = relatedAccount.Account_External_Id__c + ac.Company_Code__c;
                    ac.External_ID__c = externalId;
                }
            }
        }
    }

    if(Trigger.isInsert) {
        System.debug('IN INSERT');
    }
    else if(Trigger.isUpdate) {
        System.debug('IN UPDATE!!!!');
        for(Account_Company__c company : Trigger.old) {
            oldMap.put(company.Id, company);
        }
    }

    //If Trigger.isUpdate, I need to check whether ASOs have really changed, or only isSyncSAP__c has.
    if(Trigger.isUpdate) {
        System.debug('TRIGGER IS UPDATE');
        if(!System.isFuture()) {
            for(Account_Company__c company : Trigger.new) {
                Account_Company__c oldCompany = oldMap.get(company.Id);

                /*NEED TO CHECK WHETHER ANY FIELD HAS CHANGED OR ONLY isSyncSAP/isCreatedSAP HAS. In case, add that ASO to the ones to update and the record is
                    *not in Sync anymore*/ 
                if(AccountCompanyService.hasChanged(company, oldCompany) == true) {
                    System.debug('COMPANY HAS CHANGED');
                    if(company.isCreatedSAP__c == false) {
                        CompanyIdsToCreate.add(company.Id);
                    }
                    else if(company.isCreatedSAP__c == true){
                        CompanyIdsToUpdate.add(company.Id);
                        company.isSyncSAP__c = 'NotSync';
                    }

                } 
            }
        }
    }
    //If Trigger.isInsert, futureCreateCallout must be called for every record
    else if(Trigger.isInsert) {
        for(Account_Company__c company : Trigger.new) {
            CompanyIdsToCreate.add(company.Id);
        }
        if(!CompanyIdsToCreate.isEmpty()) {
            // Publishing events to tell the component that a callout is starting

            if(FeatureManagementService.getFeatureStatus('SAP_SO_Create') || Test.isRunningTest()) {
                /* List<Starting_Callout_Event__e> startingCalloutEvents = new List<Starting_Callout_Event__e>();

                for(Id companyId : CompanyIdsToCreate) {
                    Starting_Callout_Event__e startingCalloutEvent = new Starting_Callout_Event__e(
                        RecordId__c = companyId
                    );

                    startingCalloutEvents.add(startingCalloutEvent);
                } */

                /* if(!startingCalloutEvents.isEmpty()) {
                    List<Database.SaveResult> results = EventBus.publish(startingCalloutEvents);
                    System.debug('EVENTS STARTING CALLOUT PUBLISHED size: ' + results.size());
                } */
                    
                AccountCompanyService.futureCreateCallout(CompanyIdsToCreate);  //Is it correct to make the callout here?
            }
        }
    }
    //if(!relatedIds.isEmpty()) {
        /*IF A CREATION SAP-SIDE HAS FAILED (BUT HAS SUCCESS IN SALESFORCE), THE TRIGGER MUST MAKE A futureCreateCallout DUE FIELD: 
        UNO CHE MI DICE SE ESISTE ANCHE SU SAP, UNO CHE MI DICE LO STATO DI SINCRONIZZAZIONE (picklist)*/

        //Must not filter on Trigger.isInsert, because futureCreateCallout could be called also in Trigger.isUpdate for not-isCreatedSAP__c records
        
    if(Trigger.isUpdate) {
        if(!System.isFuture()) {
            //MUST NOT CALLOUT IF UPDATED FIELDS ARE ONLY THE ONES THAT REPRESENT SYNC-WITH-SAP STATUS
            if(!CompanyIdsToUpdate.isEmpty()) {
                if(FeatureManagementService.getFeatureStatus('SAP_SO_Update') || Test.isRunningTest()) {
                    // Publishing events to tell the component that a callout is starting

                    /* List<Starting_Callout_Event__e> startingCalloutEvents = new List<Starting_Callout_Event__e>();

                    for(Id companyId : CompanyIdsToUpdate) {
                        Starting_Callout_Event__e startingCalloutEvent = new Starting_Callout_Event__e(
                            RecordId__c = companyId
                        );

                        startingCalloutEvents.add(startingCalloutEvent);
                    } */

                    /* if(!startingCalloutEvents.isEmpty()) {
                        List<Database.SaveResult> results = EventBus.publish(startingCalloutEvents);
                        System.debug('EVENTS STARTING CALLOUT PUBLISHED size: ' + results.size());
                    } */

                    AccountCompanyService.futureUpdateCallout(CompanyIdsToUpdate);
                }
            }
            if(!CompanyIdsToCreate.isEmpty()) {
                if(FeatureManagementService.getFeatureStatus('SAP_SO_Create') || Test.isRunningTest()) {
                    // Publishing events to tell the component that a callout is starting

                    /* List<Starting_Callout_Event__e> startingCalloutEvents = new List<Starting_Callout_Event__e>();

                    for(Id companyId : CompanyIdsToCreate) {
                        Starting_Callout_Event__e startingCalloutEvent = new Starting_Callout_Event__e(
                            RecordId__c = companyId
                        );

                        startingCalloutEvents.add(startingCalloutEvent);
                    } */

                    /* if(!startingCalloutEvents.isEmpty()) {
                        List<Database.SaveResult> results = EventBus.publish(startingCalloutEvents);
                        System.debug('EVENTS STARTING CALLOUT PUBLISHED size: ' + results.size());
                    } */

                    AccountCompanyService.futureCreateCallout(CompanyIdsToCreate);
                }
            }
        }
    }
    //}
    
}