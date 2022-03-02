public without sharing class DeleteOlderLogsEventService {
    public static final List<String> SERVICES_TO_EXCLUDE = new List<String>{'HEROKU_SAP4HANA__WORKORDER_UPSERT', 'HEROKU_SAP4HANA__BILLING_DATA', 
    'HEROKU_SAP4HANA__REBATE_DATA'};

    public static void deleteOlderLogs(List<Delete_Older_Logs__e> events) {
        System.debug('----- deleteOlderLogs -----');

        List<String> calloutLoggerQueryFields = new List<String>{'RecordId__c', 'UUID_Flow__c'};

        List<String> recordIds = new List<String>();
        List<String> UUIDs = new List<String>();
        List<String> services = new List<String>();
        List<Callout_Logger__c> allOtherCalloutLoggers = new List<Callout_Logger__c>();
        Boolean canDeleteAll = FeatureManagementService.getFeatureStatus('Delete_Logs_On_Success', false);

        /**
         * When I have no UUID_Flow__c on the event, it means that I'm trying to delete all the Logs related to a record because of a complete success;
         * I will only do that if the CMDT is enabled (canDeleteAll)
         **/

        for(Delete_Older_Logs__e event : events) {
            if(!SERVICES_TO_EXCLUDE.contains(event.Service__c)) {
                if(event.Record_Id__c != null && (event.UUID_Flow__c != null || canDeleteAll)) {
                    System.debug('Event.Record_Id__c: ' + event.Record_Id__c);
                    recordIds.add(event.Record_Id__c);
                }
                if(event.UUID_Flow__c != null) {
                    System.debug('Event.UUID_Flow__c: ' + event.UUID_Flow__c);
                    UUIDs.add(event.UUID_Flow__c);
                }
                if(event.Service__c != null) {
                    System.debug('Event.Service__c: ' + event.Service__c);
                    services.add(event.Service__c);
                }
            }
        }

        if(!recordIds.isEmpty() && !services.isEmpty()) {
            allOtherCalloutLoggers = CalloutLoggerDAO.getCalloutLoggersFromRecordIdsExcludingUUIDs(calloutLoggerQueryFields, recordIds, UUIDs, services, 10000);

            if(!allOtherCalloutLoggers.isEmpty()) {
                System.debug('Deleting ' + allOtherCalloutLoggers.size() + ' Callout Loggers...');
                List<Database.DeleteResult> results = Database.delete(allOtherCalloutLoggers, false);
            }
        }
    }
}