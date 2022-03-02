public without sharing class SAPAccountCompanyBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    Integer batchGroup;

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Company_Code__c, Dunning_Procedure__c, Name, External_ID__c, Key_for_sorting_according_to_assignment__c, ' + 
        'Payment_Method__c, Payment_Terms__c, Reconciliation_Account__c, isCreatedSAP__c, isSyncSAP__c, ' +
        'Account__r.Account_External_Id__c, Account__c, Head_Office__c, Head_Office__r.Account_External_Id__c, Dunning_Block__c, UzoviCode__c FROM Account_Company__c ' + 
        'WHERE (isCreatedSAP__c = false OR isSyncSAP__c = \'NotSync\')';

        if(batchGroup != null) {
            query += ' AND Account__r.Batch_Group__c =: batchGroup';
        }

        System.debug(query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Account_Company__c> companies) {
        System.debug('----- SAPAccountCompanyBatch -----');
        System.debug('----- Handling ' + companies.size() + ' AccountCompanies in batch');
        System.debug('----- Batch Group: ' + batchGroup);

        List<Account_Company__c> companiesToInsert = new List<Account_Company__c>();
        List<Account_Company__c> companiesToUpdate = new List<Account_Company__c>();

        List<Callout_Logger__c> calloutLoggersToInsert = new List<Callout_Logger__c>();
        List<Account_Company__c> toUpdateFields = new List<Account_Company__c>();

        // Retry for ASOs

        for(Account_Company__c company : companies) {
            if(company.isCreatedSAP__c == false) {
                companiesToInsert.add(company);
            }
            else if(company.isCreatedSAP__c == true && company.isSyncSAP__c == 'NotSync') {
                companiesToUpdate.add(company);
            }
        }

        /* if(FeatureManagementService.getFeatureStatus('SAP_SO_Create_Batch')) {
            if(!companiesToInsert.isEmpty()) {
                AccountCompanyService.makeCreateCallout(companiesToInsert);
            }
        }

        if(FeatureManagementService.getFeatureStatus('SAP_SO_Update_Batch')) {
            if(!companiesToUpdate.isEmpty()) {
                AccountCompanyService.makeUpdateCallout(companiesToUpdate);
            }
        } */

        if(FeatureManagementService.getFeatureStatus('SAP_SO_Create_Batch') || Test.isRunningTest()) {
            if(!companiesToInsert.isEmpty()) {
                CalloutService.ReturnDTO returnDTO = CalloutService.makeCallout(companiesToInsert, 'callout:SAP_SO_CREATE', 'POST', 'CREATE', 'SFDC_SAP4HANA__SO_CREATE');

                if(returnDTO.calloutLoggers != null) {
                    for(Callout_Logger__c calloutLogger : returnDTO.calloutLoggers) {
                        calloutLoggersToInsert.add(calloutLogger);
                    }
                }

                if(returnDTO.responseDTO != null) {
                    List<Callout_Logger__c> calloutLoggers = CalloutService.createCalloutLoggers(
                        returnDTO.responseDTO, 
                        returnDTO.request, 
                        returnDTO.response, 
                        'Account_Company__c', 
                        'SFDC_SAP4HANA__SO_CREATE'
                    );

                    if(calloutLoggers != null) {
                        for(Callout_Logger__c calloutLogger : calloutLoggers) {
                            calloutLoggersToInsert.add(calloutLogger);
                        }
                    }

                    List<Account_Company__c> toUpdateFieldsTmp = CalloutService.handleRecordsFields(companiesToInsert, returnDTO.responseDTO, 'CREATE');

                    if(toUpdateFieldsTmp != null) {
                        for(Account_Company__c ac : toUpdateFieldsTmp) {
                            toUpdateFields.add(ac);
                        }
                    }
                }
            }
        }

        if(FeatureManagementService.getFeatureStatus('SAP_SO_Update_Batch') || Test.isRunningTest()) {
            if(!companiesToUpdate.isEmpty()) {
                CalloutService.ReturnDTO returnDTO = CalloutService.makeCallout(companiesToUpdate, 'callout:SAP_SO_UPDATE', 'POST', 'UPDATE', 'SFDC_SAP4HANA__SO_UPDATE');

                if(returnDTO.calloutLoggers != null) {
                    for(Callout_Logger__c calloutLogger : returnDTO.calloutLoggers) {
                        calloutLoggersToInsert.add(calloutLogger);
                    }
                }

                if(returnDTO.responseDTO != null) {
                    List<Callout_Logger__c> calloutLoggers = CalloutService.createCalloutLoggers(
                        returnDTO.responseDTO, 
                        returnDTO.request, 
                        returnDTO.response, 
                        'Account_Company__c', 
                        'SFDC_SAP4HANA__SO_UPDATE'
                    );

                    if(calloutLoggers != null) {
                        for(Callout_Logger__c calloutLogger : calloutLoggers) {
                            calloutLoggersToInsert.add(calloutLogger);
                        }
                    }

                    List<Account_Company__c> toUpdateFieldsTmp = CalloutService.handleRecordsFields(companiesToUpdate, returnDTO.responseDTO, 'UPDATE');

                    if(toUpdateFieldsTmp != null) {
                        for(Account_Company__c ac : toUpdateFieldsTmp) {
                            toUpdateFields.add(ac);
                        }
                    }
                }
            }
        }

        System.debug('----- Created ' + calloutLoggersToInsert.size() + ' Callout Loggers');
        System.debug('----- Updating ' + toUpdateFields.size() + ' Account Companies');

        if(!calloutLoggersToInsert.isEmpty()) {
            try {
                List<Database.SaveResult> results = Database.insert(calloutLoggersToInsert);
            }
            catch(DmlException e) {
                System.debug('EXCEPTION: ' + e.getMessage());
            }
        }

        if(!toUpdateFields.isEmpty()) {
            try {
                List<Database.SaveResult> results = Database.update(toUpdateFields);
            }
            catch(DmlException e) {
                System.debug('EXCEPTION: ' + e.getMessage());
            }
        }
    }

    public SAPAccountCompanyBatch(Integer batchGroup) {
        this.batchGroup = batchGroup;
    }

    public SAPAccountCompanyBatch() {
        
    }

    public void finish(Database.BatchableContext bc) {
        system.debug('DONE'); //TODO
    }
}