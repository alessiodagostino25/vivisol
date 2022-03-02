public class BatchToDeleteOldCalloutLogger implements Schedulable, Database.Batchable<sObject> {
	public static Date timestampdate;

	public BatchToDeleteOldCalloutLogger() {
	}

	public BatchToDeleteOldCalloutLogger(Integer days) {
		timestampdate = Date.today().addDays(-days);
	}

	public static Database.QueryLocator start(Database.BatchableContext bc) {
		system.debug('timestampdate:: ' + timestampdate);
		return Database.getQueryLocator(
			'SELECT Id FROM Callout_Logger__c WHERE Timestamp__c <:timestampdate'
		);
	}

	public static void execute(Database.BatchableContext bc,List<Callout_Logger__c> scope) {
		delete scope;
	}

	public void finish(Database.BatchableContext bc) {
	}

	public static void execute(SchedulableContext scon) {
		Database.executeBatch(new BatchToDeleteOldCalloutLogger());
	}

	public static void activateSchedule(String name, Integer days) {
		String CRON_EXP = '0 30 5 ? * * *';
		System.schedule(name, CRON_EXP, new BatchToDeleteOldCalloutLogger(days));
	}
}