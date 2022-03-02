public without sharing class AccountTreatmentSuspensionBatch implements Database.Batchable<sObject>, Schedulable{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Patient_Treatment__c, Status__c, Suspension_start_date__c, Suspension_end_date__c, StartDate__c, EndDate__c, Is_Current_Status__c, ' +
        'Patient_Treatment__r.Account__c ' +
        'FROM Account_Treatment_Status__c WHERE (Suspension_start_date__c = TODAY AND Status__c =\'S\') OR ' +
        '(StartDate__c = TODAY AND (Status__c = \'R\' OR Status__c = \'D\' OR Status__c = \'A\'))';
        System.debug(query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Account_Treatment_Status__c> ATSList) {
        System.debug('----- AccountTreatmentSuspensionBatch -----');
        System.debug('ATSList: ' + ATSList);

        List<String> accountTreatmentQueryFields = new List<String>{'Status__c', 'Activation_Date__c', 'Deactivation_Date__c'};

        List<String> accountTreatmentIds = new List<String>();
        List<Account_Treatment__c> relatedAccountTreatments = new List<Account_Treatment__c>();
        List<Account_Treatment__c> accountTreatmentsToUpdate = new List<Account_Treatment__c>();

        Map<String, Account_Treatment__c> accountTreatmentMap = new Map<String, Account_Treatment__c>();

        for(Account_Treatment_Status__c ats : ATSList) {
            accountTreatmentIds.add(ats.Patient_Treatment__c);
        }

        relatedAccountTreatments = AccountTreatmentDAO.getAccountTreatmentsFromIds(accountTreatmentQueryFields, accountTreatmentIds);

        if(relatedAccountTreatments != null) {
            for(Account_Treatment__c at : relatedAccountTreatments) {
                accountTreatmentMap.put(at.Id, at);
            }
        }

        for(Account_Treatment_Status__c ats : ATSList) {
            Account_Treatment__c relatedAccountTreatment = accountTreatmentMap.get(ats.Patient_Treatment__c);

            if(relatedAccountTreatment != null) {
                relatedAccountTreatment.Status__c = ats.Status__c;

                if(ats.Status__c == 'A') {
                    relatedAccountTreatment.Activation_Date__c = ats.StartDate__c;
                }
                else if(ats.Status__c == 'D') {
                    relatedAccountTreatment.Deactivation_Date__c = ats.StartDate__c;
                }

                if(!accountTreatmentsToUpdate.contains(relatedAccountTreatment)) {
                    accountTreatmentsToUpdate.add(relatedAccountTreatment);
                }
            }
        }

        if(!accountTreatmentsToUpdate.isEmpty()) {
            List<Database.SaveResult> results = Database.update(accountTreatmentsToUpdate);
        }

        // Setting the new Status as Current and unsetting the old one

        AccTreatmentStatusTriggerService.handleStatusSuccession(ATSList);

        // Updating the related Accounts

        AccTreatmentStatusTriggerService.updateRelatedAccountStatus(ATSList);
    }

    public void finish(Database.BatchableContext bc) {
        system.debug('DONE'); //TODO
    }

    public static void Execute(SchedulableContext ctx) {
        Database.executeBatch(new AccountTreatmentSuspensionBatch());
    }
}