global without sharing class SAPAccountSalesOrgBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    Integer batchGroup;

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Name, Account__c, Account__r.Account_External_Id__c, Account_Assignment_Group__c, Authorization_group__c, ' +
        'Code__c, CreatedById, Credit_Limit__c, Currency__c, ' +
        'Customer_Group__c, Customer_Statistics_Group__c, Distribution_Channel__c, ' +
        'Division__c, Invoice_grouping_Y_N__c, Invoicing_Dates__c, ' + 
        'LastModifiedById, OwnerId, Payment_Terms__c, POD_Relevant__c, Price_Group__c, ' +
        'Price_Procedure_Dterm__c, Pricelist__c, Responsabile_Vivisol_Account_Manager__c, ' +
        'Sales_district__c, Sales_Group__c, Sales_Office__c, Sales_Organization__c, Sales_Organization__r.Code__c, ' +
        'Shipping_Conditions__c, isCreatedSAP__c, isSyncSAP__c, Responsabile_Vivisol_Account_Manager__r.Account_External_Id__c, Dunning_Via__c, Billing_Method__c,  ' +
        'External_Id__c ' + 
        'FROM Account_Sales_Organization__c WHERE (isCreatedSAP__c = false OR isSyncSAP__c = \'NotSync\')';

        if(batchGroup != null) {
            query += ' AND Account__r.Batch_Group__c =: batchGroup';
        }

        System.debug(query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Account_Sales_Organization__c> asos) {
        System.debug('----- SAPAccountSalesOrgBatch -----');
        System.debug('----- Handling ' + asos.size() + ' ASOs in batch');
        System.debug('----- Batch Group: ' + batchGroup);

        List<Account_Sales_Organization__c> asosToInsert = new List<Account_Sales_Organization__c>();
        List<Account_Sales_Organization__c> asosToUpdate = new List<Account_Sales_Organization__c>();

        List<Callout_Logger__c> calloutLoggersToInsert = new List<Callout_Logger__c>();
        List<Account_Sales_Organization__c> toUpdateFields = new List<Account_Sales_Organization__c>();

        // Retry for ASOs

        for(Account_Sales_Organization__c aso : asos) {
            System.debug('----- ASO.Id: ' + aso.Id);
            System.debug('----- ASO.External_Id__c: ' + aso.External_Id__c);

            if(aso.isCreatedSAP__c == false) {
                asosToInsert.add(aso);
            }
            else if(aso.isCreatedSAP__c == true && aso.isSyncSAP__c == 'NotSync') {
                asosToUpdate.add(aso);
            }
        }

        /* if(FeatureManagementService.getFeatureStatus('SAP_SO_Create_Batch')) {
            if(!asosToInsert.isEmpty()) {
                ASOService.makeCreateCallout(asosToInsert);
            }
        }

        if(FeatureManagementService.getFeatureStatus('SAP_SO_Update_Batch')) {
            if(!asosToUpdate.isEmpty()) {
                ASOService.makeUpdateCallout(asosToUpdate);
            }
        } */

        if(FeatureManagementService.getFeatureStatus('SAP_SO_Create_Batch') || Test.isRunningTest()) {
            if(!asosToInsert.isEmpty()) {
                CalloutService.ReturnDTO returnDTO = CalloutService.makeCallout(asosToInsert, 'callout:SAP_SO_CREATE', 'POST', 'CREATE', 'SFDC_SAP4HANA__SO_CREATE');

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
                        'Account_Sales_Organization__c', 
                        'SFDC_SAP4HANA__SO_CREATE'
                    );

                    if(calloutLoggers != null) {
                        for(Callout_Logger__c calloutLogger : calloutLoggers) {
                            calloutLoggersToInsert.add(calloutLogger);
                        }
                    }

                    List<Account_Sales_Organization__c> toUpdateFieldsTmp = CalloutService.handleRecordsFields(asosToInsert, returnDTO.responseDTO, 'CREATE');

                    if(toUpdateFieldsTmp != null) {
                        for(Account_Sales_Organization__c aso : toUpdateFieldsTmp) {
                            toUpdateFields.add(aso);
                        }
                    }
                }
            }
        }

        if(FeatureManagementService.getFeatureStatus('SAP_SO_Update_Batch') || Test.isRunningTest()) {
            if(!asosToUpdate.isEmpty()) {
                CalloutService.ReturnDTO returnDTO = CalloutService.makeCallout(asosToUpdate, 'callout:SAP_SO_UPDATE', 'POST', 'UPDATE', 'SFDC_SAP4HANA__SO_UPDATE');

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
                        'Account_Sales_Organization__c', 
                        'SFDC_SAP4HANA__SO_UPDATE'
                    );

                    if(calloutLoggers != null) {
                        for(Callout_Logger__c calloutLogger : calloutLoggers) {
                            calloutLoggersToInsert.add(calloutLogger);
                        }
                    }

                    List<Account_Sales_Organization__c> toUpdateFieldsTmp = CalloutService.handleRecordsFields(asosToUpdate, returnDTO.responseDTO, 'UPDATE');

                    if(toUpdateFieldsTmp != null) {
                        for(Account_Sales_Organization__c aso : toUpdateFieldsTmp) {
                            toUpdateFields.add(aso);
                        }
                    }
                }
            }
        }

        System.debug('----- Created ' + calloutLoggersToInsert.size() + ' Callout Loggers');
        System.debug('----- Updating ' + toUpdateFields.size() + ' ASOs');

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

    public SAPAccountSalesOrgBatch(Integer batchGroup) {
        this.batchGroup = batchGroup;
    }

    public SAPAccountSalesOrgBatch() {
        
    }

    public void finish(Database.BatchableContext bc) {
        system.debug('DONE'); //TODO
    }
}