public without sharing class SAPAccountBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    Integer batchGroup;

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, AutoNumber__c, Account_External_Id__c, RecordType.DeveloperName, FirstName, Salutation, ' +  
        'Entity_Type__c, Name, Name_2__c, Name_3__c, Name_4__c, MiddleName, LastName, PersonBirthdate, HealthCloudGA__DeceasedDate__pc, ' +
        'HealthCloudGA__Gender__pc, Birth_city__pc, Birth_country__pc, Fiscal_Code__c, VAT_Number__c, Social_Security_Number__pc, ' + 
        'PersonHomePhone, Work_Phone__c, Phone, PersonMobilePhone, PersonEmail, Email_B2B__c, Fax, ShippingStreet, ShippingPostalCode, ' + 
        'ShippingCity, ShippingStateCode, ShippingCountry, Shipping_Telephone__c, Address_ID__c, Patients_insurance_number__pc, ' + 
        'Iban__c, Billing_Reference__c, Customer_Purchase_Order_Number__c, ' +
        'Customer_Purchase_Order_Date__c, Chamber_of_commerce_number__c, Language__c, Description, RecordType.Name, ShippingCountryCode, IsPersonAccount, ' +
        'IsCreatedSAP__c, IsSyncSAP__c, TransportationZone__c, Dunning_Email__c, Billing_Email__c, Bank_Account_Owner__c, Regional_Grouping__c FROM Account ' +
        'WHERE (IsSyncSAP__c = \'NotSync\' OR IsCreatedSAP__c = false)';

        if(batchGroup != null) {
            query += ' AND Batch_Group__c =: batchGroup';
        }

        System.debug(query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Account> accounts) {
        System.debug('----- SAPAccountBatch -----');
        System.debug('Handling ' + accounts.size() + ' Accounts in batch');

        List<Account> personAccountToAlign = new List<Account>();
        List<Account> businessAccountToAlign = new List<Account>();
        List<Callout_Logger__c> calloutLogs = new List<Callout_Logger__c>();
        //List<Status_Change_Event__e> changeEvents = new List<Status_Change_Event__e>();

        //Retry for Accounts
        for(Account a : accounts) {
            if(a.isCreatedSAP__c == false) {
                if(FeatureManagementService.getFeatureStatus('SAP_Customer_Create_Batch') || Test.isRunningTest()) {
                    AccountService.ReturnDTO returnDTO = AccountService.doAccountCreateCallout(a);
                    for(Account acc : returnDTO.personAccounts) {
                        personAccountToAlign.add(acc);
                        System.debug('isCreatedSAP: ' + acc.isCreatedSAP__c + '   isSyncSAP: ' + acc.isSyncSAP__c);
                    }

                    for(Account acc : returnDTO.businessAccounts) {
                        businessAccountToAlign.add(acc);
                    }

                    for(Callout_Logger__c cl : returnDTO.loggerList) {
                        calloutLogs.add(cl);
                    }

                    /* for(Status_Change_Event__e event : returnDTO.changeEvents) {
                        changeEvents.add(event);
                    } */

                }
            }
            else if(a.isCreatedSAP__c == true && a.isSyncSAP__c == 'NotSync') {
                if(FeatureManagementService.getFeatureStatus('SAP_Customer_Update_Batch') || Test.isRunningTest()) {
                    System.debug('MAKING UPDATE CALLOUT FROM BATCH');

                    AccountService.ReturnDTO returnDTO = AccountService.doAccountUpdateCallout(a);

                    for(Account acc : returnDTO.personAccounts) {
                        personAccountToAlign.add(acc);
                        System.debug('isCreatedSAP: ' + acc.isCreatedSAP__c + '   isSyncSAP: ' + acc.isSyncSAP__c);
                    }

                    for(Account acc : returnDTO.businessAccounts) {
                        businessAccountToAlign.add(acc);
                    }

                    for(Callout_Logger__c cl : returnDTO.loggerList) {
                        calloutLogs.add(cl);
                    }

                    /* for(Status_Change_Event__e event : returnDTO.changeEvents) {
                        changeEvents.add(event);
                    } */
                }
            }
        }

        System.debug('----- Created ' + calloutLogs.size() + ' Callout Loggers');
        System.debug('----- Updating ' + personAccountToAlign.size() + ' Person Accounts');
        System.debug('----- Updating ' + businessAccountToAlign.size() + ' Business Accounts');

        if(!personAccountToAlign.isEmpty()) {
            List<Database.SaveResult> results = Database.update(personAccountToAlign, false);
        }
        if(!businessAccountToAlign.isEmpty()) {
            List<Database.SaveResult> results = Database.update(businessAccountToAlign, false);
        }
        if(!calloutLogs.isEmpty()) {
            List<Database.SaveResult> results = Database.insert(calloutLogs, false);
        }

        /* if(!changeEvents.isEmpty()) {
            List<Database.SaveResult> results = EventBus.publish(changeEvents);
            System.debug('EVENTS PUBLISHED size: ' + results.size());
        } */
    }

    public void finish(Database.BatchableContext bc) {
        system.debug('DONE'); //TODO
    }

    public SAPAccountBatch(Integer batchGroup) {
        this.batchGroup = batchGroup;
    }

    public SAPAccountBatch() {
        
    }

}