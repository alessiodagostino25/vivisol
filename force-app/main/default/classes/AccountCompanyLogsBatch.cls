public class AccountCompanyLogsBatch implements Database.Batchable<sObject>, Schedulable{

    public  Database.QueryLocator start(Database.BatchableContext bc){
        String sfdccreate = 'SFDC_SAP4HANA__SO_CREATE';
        String sfdcupdate = 'SFDC_SAP4HANA__SO_UPDATE';
        String accountcompany = 'Account_Company__c';
        String query = 'SELECT Service__c ,Related_Account_Company__c ,Object__c ,isSolved__c,RecordId__c From Callout_Logger__c WHERE isSolved__c = false AND (Service__c =:sfdccreate OR Service__c =:sfdcupdate ) AND Related_Account_Company__c = null AND Object__c =:accountcompany  ';
		System.debug(query);
		return Database.getQueryLocator(query);
	}
	
    public void execute(Database.BatchableContext bc, List<Callout_Logger__c> calloutLoggers){
		List<String> calloutLoggerRecordIds = new List<String>();
		List<Callout_Logger__c> calloutLoggerList = new List<Callout_Logger__c>();
		for (Callout_Logger__c cl : calloutLoggers){
			calloutLoggerRecordIds.add(cl.RecordId__c);
		}
		List<String> queryfields = new List<String>{'Id', 'External_Id__c'};
		List<Account_Company__c> relatedAccountCompanies = AccountCompanyDAO.getAccountcompanyFromRecordIds(queryfields, calloutLoggerRecordIds);
		Map<String, Id> externalIdandAccountIdMap = new Map<String, Id>();
		for (Account_Company__c a : relatedAccountCompanies){
			externalIdandAccountIdMap.put(a.External_Id__c, a.Id);
		}
		for (Callout_Logger__c cl : calloutLoggers){
			cl.Related_Account_Company__c = externalIdandAccountIdMap.get(cl.RecordId__c);
			calloutLoggerList.add(cl);
		}
		update calloutLoggerList;
	}

	public void finish(Database.BatchableContext bc){
		Database.executeBatch(new AssignAccountLogsBatch(), 1500);
	}

	public static void execute(SchedulableContext ctx){
		Database.executeBatch(new AccountCompanyLogsBatch()); //TODO
	}

}