global without sharing class AccountTreatmentDeactivationFromCFBatch implements Database.Batchable<sObject> {
    global List<Contract_Framework__c> contractFrameworks;

    public Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> contractFrameworkIds = new List<String>();

        for(Contract_Framework__c cf : contractFrameworks) {
            contractFrameworkIds.add(cf.Id);
        }

        String query = 'SELECT Status__c FROM Account_Treatment__c WHERE Contract_Treatment__r.Contract_Framework__c IN: contractFrameworkIds AND Status__c != \'R\' ' + 
        'AND Status__c != \'D\' AND Contract_Treatment__r.Scheduling_after_end_date__c = false';

        System.debug(query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Account_Treatment__c> accountTreatments) {
        System.debug('----- AccountTreatmentDeactivationFromCFBatch -----');
        System.debug('accountTreatments: ' + accountTreatments);

        List<Account_Treatment_Status__c> toInsert = new List<Account_Treatment_Status__c>();

        for(Account_Treatment__c at : accountTreatments) {
            Account_Treatment_Status__c newATS = new Account_Treatment_Status__c(
                Patient_Treatment__c = at.Id,
                Status__c = 'D',
                StartDate__c = Date.today()
            );

            toInsert.add(newATS);
        }

        if(!toInsert.isEmpty()) {
            List<Database.SaveResult> results = Database.insert(toInsert);
        }
    }

    public void finish(Database.BatchableContext bc) {
        system.debug('DONE'); //TODO
    }
}