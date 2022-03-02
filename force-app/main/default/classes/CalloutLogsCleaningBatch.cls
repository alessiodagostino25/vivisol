public without sharing class CalloutLogsCleaningBatch implements Database.Batchable<sObject>, Database.Stateful {
    public List<String> servicesToExclude = new List<String>{'HEROKU_SAP4HANA__WORKORDER_UPSERT', 'HEROKU_SAP4HANA__BILLING_DATA', 
    'HEROKU_SAP4HANA__REBATE_DATA'};
    public List<String> servicesToInclude;
    public List<String> recordIds;

    public Database.QueryLocator start(Database.BatchableContext bc){
        System.debug('servicesToExclude: ' + this.servicesToExclude);
        System.debug('servicesToInclude (null = all): ' + this.servicesToInclude);

        String query = 'SELECT RecordId__c, UUID_Flow__c, Service__c, CreatedDate FROM Callout_Logger__c WHERE Service__c != null AND Service__c NOT IN: servicesToExclude ' +
        'AND RecordId__c != null AND UUID_Flow__c != null ';

        if(servicesToInclude != null && !servicesToInclude.isEmpty()) {
            query += 'AND Service__c IN: servicesToInclude ';
        }

        if(recordIds != null && !recordIds.isEmpty()) {
            query += 'AND RecordId__c IN: recordIds ';
        }

        query += 'ORDER BY CreatedDate DESC';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Callout_Logger__c> calloutLoggers){
        List<String> calloutLoggerQueryFields = new List<String>{'RecordId__c', 'UUID_Flow__c', 'Service__c', 'CreatedDate'};

        List<String> recordIds = new List<String>();
        List<String> UUIDs = new List<String>();
        List<String> services = new List<String>();
        List<Callout_Logger__c> allOtherLogs = new List<Callout_Logger__c>();
        List<Callout_Logger__c> toDelete = new List<Callout_Logger__c>();

        Map<String, Callout_Logger__c> recordIdToLastCLMap = new Map<String, Callout_Logger__c>();
        Map<String, Callout_Logger__c> recordIdToMoreRecentCLMap = new Map<String, Callout_Logger__c>();

        for(Callout_Logger__c calloutLogger : calloutLoggers) {
            recordIds.add(calloutLogger.RecordId__c);
            UUIDs.add(calloutLogger.UUID_Flow__c);
            services.add(calloutLogger.Service__c);

            String key = String.valueOf(calloutLogger.RecordId__c) + '_' + String.valueOf(calloutLogger.Service__c);

            if(recordIdToLastCLMap.get(key) == null) {
                recordIdToLastCLMap.put(key, calloutLogger);
            }
            else {
                if(recordIdToLastCLMap.get(key).UUID_Flow__c != calloutLogger.UUID_Flow__c) {
                    System.debug('DELETING Callout Logger - RecordId: ' + calloutLogger.RecordId__c + ' - UUID: ' + calloutLogger.UUID_Flow__c);
                    toDelete.add(calloutLogger);
                }
            }
        }

        allOtherLogs = CalloutLoggerDAO.getCalloutLoggersFromRecordIdsExcludingUUIDs(calloutLoggerQueryFields, recordIds, /* UUIDs */new List<String>(), services, 50000);
        System.debug('allOtherLogs size: ' + allOtherLogs.size());

        for(Callout_Logger__c otherCL : allOtherLogs) {
            String key = String.valueOf(otherCL.RecordId__c) + '_' + String.valueOf(otherCL.Service__c);

            if(recordIdToMoreRecentCLMap.get(key) == null) {
                Callout_Logger__c lastCalloutLogger = recordIdToLastCLMap.get(key);

                if(lastCalloutLogger != null) {
                    if(otherCL.CreatedDate > lastCalloutLogger.CreatedDate && otherCL.UUID_Flow__c != lastCalloutLogger.UUID_Flow__c) {
                        recordIdToMoreRecentCLMap.put(key, otherCL);
                    }
                }
            }
        }

        for(Callout_Logger__c cl : calloutLoggers) {
            String key = String.valueOf(cl.RecordId__c) + '_' + String.valueOf(cl.Service__c);

            if(!toDelete.contains(cl)) {
                if(recordIdToMoreRecentCLMap.get(key) != null) {
                    System.debug('DELETING Callout Logger - RecordId: ' + cl.RecordId__c + ' - UUID: ' + cl.UUID_Flow__c);
                    toDelete.add(cl);
                }
            }
        }

        if(!toDelete.isEmpty()) {
            System.debug('Deleting ' + toDelete.size() + ' Logs...');
            List<Database.DeleteResult> results = Database.delete(toDelete, false);
        }
    }

    public void finish(Database.BatchableContext bc){
        system.debug('DONE'); 
    }

    public CalloutLogsCleaningBatch() {
        
    }

    public CalloutLogsCleaningBatch(List<String> servicesToInclude, List<String> servicesToExclude, List<String> recordIds) {
        this.servicesToInclude = servicesToInclude;
        this.recordIds = recordIds;

        if(servicesToExclude != null) {
            this.servicesToExclude.addAll(servicesToExclude);
        }
    }
}