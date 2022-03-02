trigger CalloutLoggerTrigger on Callout_Logger__c (before insert, after insert) {

    if(Trigger.isBefore && Trigger.isInsert) {
        // Assigning Logs
        CalloutLoggerTriggerHelper.assignCalloutLoggers(Trigger.new);
    }

    if(Trigger.isAfter && Trigger.isInsert) {
        // Deleting older Logs related to the same record but different UUID flow (Asynchronous with PE)
        CalloutLoggerTriggerHelper.deleteOlderLogs(Trigger.new);
    }
}