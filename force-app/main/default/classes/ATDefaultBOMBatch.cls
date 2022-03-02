global without sharing class ATDefaultBOMBatch implements Database.Batchable<sObject> {
    global Integer batchGroup;

    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('--- batchGroup: ' + batchGroup);
        String query = 'SELECT Contract_Treatment__c, DataMigration__c FROM Account_Treatment__c WHERE DataMigration__c = true AND Batch_Group__c =: batchGroup';
        System.debug(query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Account_Treatment__c> accountTreatments) {
        System.debug('----- Executing ATDefaultBOMBatch... -----');
        System.debug('Processing ' + accountTreatments.size() + ' records...');

        List<String> accountTreatmentIds = new List<String>();
        List<String> relatedCTIds = new List<String>();

        for(Account_Treatment__c at : accountTreatments) {
            accountTreatmentIds.add(at.Id);

            if(at.Contract_Treatment__c != null) {
                relatedCTIds.add(at.Contract_Treatment__c);
            }
        }

        if(!accountTreatmentIds.isEmpty() && !relatedCTIds.isEmpty()) {
            AccountTreatmentDefaultBOMHelper.AccountTreatmentDefaultBOMHelperwithid(accountTreatmentIds, accountTreatments, relatedCTIds);

            for(Account_Treatment__c at : accountTreatments) {
                at.DataMigration__c = false;
            }
    
            List<Database.SaveResult> results = Database.update(accountTreatments);
        }
    }

    public void finish(Database.BatchableContext bc) {
        system.debug('DONE'); //TODO
    }

    public ATDefaultBOMBatch() {

    }

    public ATDefaultBOMBatch(Integer batchGroup) {
        this.batchGroup = batchGroup;
    }
}