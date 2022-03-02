public without sharing class EOMCalloutLoggerBatch implements Database.Batchable<sObject> {
    public  Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Related_EOM__c, RecordId__c FROM Callout_Logger__c WHERE Service__c = \'HEROKU_SAP4HANA__BILLING_DATA\' AND Related_EOM__c = null AND RecordId__c != null';
		System.debug(query);
		return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Callout_Logger__c> calloutLoggers){
        List<Callout_Logger__c> toUpdate = new List<Callout_Logger__c>();

        CalloutLoggerTriggerHelper.assignEndOfMonthHeaderCalloutLoggers(calloutLoggers);

        for(Callout_Logger__c cl : calloutLoggers) {
            if(cl.Related_EOM__c != null) {
                toUpdate.add(cl);
            }
        }

        if(!toUpdate.isEmpty()) {
            List<Database.SaveResult> results = Database.update(toUpdate, false);
        }
    }
    public void finish(Database.BatchableContext bc){
        system.debug('DONE'); 
    }
}