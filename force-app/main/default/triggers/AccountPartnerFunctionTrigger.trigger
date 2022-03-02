trigger AccountPartnerFunctionTrigger on Account_Partner_Function__c (after insert, before update, after update) {
    List<Id> relatedIds = new List<Id>();
    List<Id> asoIds = new List<Id>();
    Map<Id, Account_Partner_Function__c> apfMap = new Map<Id, Account_Partner_Function__c>();
    for(Account_Partner_Function__c apf : Trigger.new) {
        relatedIds.add(apf.Id);
        asoIds.add(apf.Account_Sales_Organization__c);
    }
    
    List<Id> ASOIdsToCreate = new List<Id>();
    List<Id> ASOIdsToUpdate = new List<Id>();
    if(Trigger.isInsert) {
        System.debug('IN INSERT');
    }
    else if(Trigger.isUpdate) {
        System.debug('IN UPDATE!!!!');
    }
    //If Trigger.isUpdate, I need to check whether ATCs have really changed, or only isSyncSAP__c has.
    if(Trigger.isUpdate) {
        System.debug('TRIGGER IS UPDATE');

        List<String> relatedASOIds = new List<String>();

        for(Account_Partner_Function__c apf : Trigger.new) {
            /*NEED TO CHECK WHETHER ANY FIELD HAS CHANGED OR ONLY isSyncSAP/isCreatedSAP HAS. In case, add that ASO to the ones to update and the record is
             *not in Synce anymore*/ 
            //if(AccountTaxClassificationService.hasChanged(atc, oldATC) == true) {
            /* if(AccountTaxClassificationService.isCreated(apf.Account_Sales_Organization__c) == false) {
                ASOIdsToCreate.add(apf.Account_Sales_Organization__c);
            }
            else if(AccountTaxClassificationService.isCreated(apf.Account_Sales_Organization__c) == true){
                ASOIdsToUpdate.add(apf.Account_Sales_Organization__c);
                AccountTaxClassificationService.setNotSync(apf.Account_Sales_Organization__c);
            } */



            //} 

           relatedASOIds.add(apf.Account_Sales_Organization__c);
        }

        if(!relatedASOIds.isEmpty()) {
            Map<String, Account_Sales_Organization__c> relatedASOMap = AccountTaxClassificationService.getASOMap(relatedASOIds);

            if(relatedASOMap != null && !relatedASOMap.isEmpty()) {
                for(Account_Partner_Function__c apf : Trigger.new) {
                    Account_Sales_Organization__c relatedASO = relatedASOMap.get(apf.Account_Sales_Organization__c);

                    if(relatedASO != null) {
                        if(relatedASO.IsCreatedSAP__c == true) {
                            ASOIdsToUpdate.add(apf.Account_Sales_Organization__c);
                            AccountTaxClassificationService.setNotSync(apf.Account_Sales_Organization__c);
                        }
                        else {
                            ASOIdsToCreate.add(apf.Account_Sales_Organization__c);
                        }
                    }
                }
            }
        }
    }
    //If Trigger.isInsert, futureCreateCallout must be called for every record
    else if(Trigger.isInsert) {
        
        AccountPartnerFunctionService.updateAccountbill(Trigger.new);
        
        List<String> relatedASOIds = new List<String>();

        for(Account_Partner_Function__c apf : Trigger.new) {
       
            /* if(AccountTaxClassificationService.isCreated(apf.Account_Sales_Organization__c) == true) {
                ASOIdsToUpdate.add(apf.Account_Sales_Organization__c);
            }
            else {
                ASOIdsToCreate.add(apf.Account_Sales_Organization__c);
            } */
            relatedASOIds.add(apf.Account_Sales_Organization__c);
        }

        if(!relatedASOIds.isEmpty()) {
            Map<String, Account_Sales_Organization__c> relatedASOMap = AccountTaxClassificationService.getASOMap(relatedASOIds);

            if(relatedASOMap != null && !relatedASOMap.isEmpty()) {
                for(Account_Partner_Function__c apf : Trigger.new) {
                    Account_Sales_Organization__c relatedASO = relatedASOMap.get(apf.Account_Sales_Organization__c);

                    if(relatedASO != null) {
                        if(relatedASO.IsCreatedSAP__c == true) {
                            ASOIdsToUpdate.add(apf.Account_Sales_Organization__c);
                        }
                        else {
                            ASOIdsToCreate.add(apf.Account_Sales_Organization__c);
                        }
                    }
                }
            }
        }

        if(!ASOIdsToCreate.isEmpty()) {
            if(FeatureManagementService.getFeatureStatus('SAP_SO_Create') || Test.isRunningTest()) {
                AccountPartnerFunctionService.futureCreateCallout(ASOIdsToCreate);  //Is it correct to make the callout here?
            }
        }

        if(!ASOIdsToUpdate.isEmpty()) {
            if(FeatureManagementService.getFeatureStatus('SAP_SO_Update') || Test.isRunningTest()) {
                AccountPartnerFunctionService.futureUpdateCallout(ASOIdsToUpdate);
            }
        }
    }

    /*IF A CREATION SAP-SIDE HAS FAILED (BUT HAS SUCCESS IN SALESFORCE), THE TRIGGER MUST MAKE A futureCreateCallout DUE FIELD: 
     *UNO CHE MI DICE SE ESISTE ANCHE SU SAP, UNO CHE MI DICE LO STATO DI SINCRONIZZAZIONE (picklist)*/

    //Must not filter on Trigger.isInsert, because futureCreateCallout could be called also in Trigger.isUpdate for not-isCreatedSAP__c records
    if(Trigger.isUpdate) {
        //MUST NOT CALLOUT IF UPDATED FIELDS ARE ONLY THE ONES THAT REPRESENT SYNC-WITH-SAP STATUS
        if(!ASOIdsToUpdate.isEmpty()) {
            if(FeatureManagementService.getFeatureStatus('SAP_SO_Update') || Test.isRunningTest()) {
                AccountPartnerFunctionService.futureUpdateCallout(ASOIdsToUpdate);
            }
        }
        if(!ASOIdsToCreate.isEmpty()) {
            if(FeatureManagementService.getFeatureStatus('SAP_SO_Create') || Test.isRunningTest()) {
                AccountPartnerFunctionService.futureCreateCallout(ASOIdsToCreate);
            }
        }
    }

    if(Trigger.isInsert && Trigger.isAfter) {
        List<String> relatedASOIds = new List<String>();

        for(Account_Partner_Function__c apf : Trigger.new) {
            if(apf.Account_Sales_Organization__c != null) {
                relatedASOIds.add(apf.Account_Sales_Organization__c);
            }
        }

        if(!relatedASOIds.isEmpty()) {
            if(FeatureManagementService.getFeatureStatus('Update_Account_Is_Portal_Sync') || Test.isRunningTest()) {
                AccountTaxClassificationService.updateRelatedAccountIsPortalSync(relatedASOIds);
            }
        }
    }

    if(Trigger.isUpdate && Trigger.isAfter) {
        List<String> relatedASOIds = new List<String>();

        for(Account_Partner_Function__c apf : Trigger.new) {
            if(apf.Account_Sales_Organization__c != null) {
                relatedASOIds.add(apf.Account_Sales_Organization__c);
            }
        }

        if(!relatedASOIds.isEmpty()) {
            if(FeatureManagementService.getFeatureStatus('Update_Account_Is_Portal_Sync') || Test.isRunningTest()) {
                AccountTaxClassificationService.updateRelatedAccountIsPortalSync(relatedASOIds);
            }
        }
    }
}