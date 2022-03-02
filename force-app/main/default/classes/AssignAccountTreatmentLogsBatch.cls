public class AssignAccountTreatmentLogsBatch implements Database.Batchable<sObject>, Schedulable{
    public  Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Service__c , RecordId__c, Related_Account_Treatment__c, isSolved__c FROM Callout_Logger__c ' + 
        'WHERE Service__c = \'SFDC_PIMCORE_PATIENT_TREATMENT_UPSERT\' AND isSolved__c = false AND Related_Account_Treatment__c = null';
		System.debug(query);
		return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Callout_Logger__c> calloutLoggers){
        CalloutLoggerTriggerHelper.assignATCalloutLoggers(calloutLoggers);

        List<Database.SaveResult> results = Database.update(calloutLoggers, false);
    }

    public void finish(Database.BatchableContext bc){
		Database.executeBatch(new CalloutLoggerResolutionBatch(), 2000);
	}

	public static void Execute(SchedulableContext ctx){
		Database.executeBatch(new AssignAccountTreatmentLogsBatch()); //TODO
	}
}