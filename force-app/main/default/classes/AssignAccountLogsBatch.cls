public class AssignAccountLogsBatch implements Database.Batchable<sObject>, Schedulable{
	public Database.QueryLocator start(Database.BatchableContext bc){
		String sfdccreate = 'SFDC_SAP4HANA__PATIENT_CREATE';
		String sfdcupdate = 'SFDC_SAP4HANA__PATIENT_UPDATE';
		String query = 'select Service__c ,RecordId__c,Related_Address__c,isSolved__c,Related_Account__c From Callout_Logger__c WHERE isSolved__c = false AND (Service__c =:sfdccreate OR Service__c =:sfdcupdate ) AND Related_Account__c = null ';
		System.debug(query);
		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext bc, List<Callout_Logger__c> calloutLoggers){
		List<String> calloutLoggerRecordIds = new List<String>();
		List<Callout_Logger__c> calloutLoggerList = new List<Callout_Logger__c>();
		for (Callout_Logger__c cl : calloutLoggers){
			calloutLoggerRecordIds.add(cl.RecordId__c);
		}
		List<String> queryfields = new List<String>{'Id', 'Account_External_Id__c'};
		List<Account> relatedAccounts = AccountDAO.getAccountFromRecordIds(queryfields, calloutLoggerRecordIds);
		Map<String, Id> externalIdandAccountIdMap = new Map<String, Id>();
		for (Account a : relatedAccounts){
			externalIdandAccountIdMap.put(a.Account_External_Id__c, a.Id);
		}
		for (Callout_Logger__c cl : calloutLoggers){
			cl.Related_Account__c = externalIdandAccountIdMap.get(cl.RecordId__c);
			calloutLoggerList.add(cl);
		}
		update calloutLoggerList;
	}

	public void finish(Database.BatchableContext bc){
		Database.executeBatch(new AccountSalesOrganizationLogsBatch());
	}

	public static void Execute(SchedulableContext ctx){
		Database.executeBatch(new AssignAccountLogsBatch()); //TODO
	}


}