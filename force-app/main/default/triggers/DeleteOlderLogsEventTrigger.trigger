trigger DeleteOlderLogsEventTrigger on Delete_Older_Logs__e (after insert) {
    if(Trigger.isInsert && Trigger.isAfter) {
        // Deleting older Logs
        DeleteOlderLogsEventService.deleteOlderLogs(Trigger.new);
    }
}