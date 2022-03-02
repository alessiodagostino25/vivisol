public class AccountSalesOrganizationLogsBatch implements Database.Batchable<sObject>, Schedulable{
    public  Database.QueryLocator start(Database.BatchableContext bc){
        String sfdccreate = 'SFDC_SAP4HANA__SO_CREATE' ;
        String sfdcupdate = 'SFDC_SAP4HANA__SO_UPDATE' ;
        String accountSalesOrganisation = 'Account_Sales_Organization__c';
        String query = 'select Service__c ,Related_Account_Sales_Organization__c ,Object__c ,isSolved__c,RecordId__c From Callout_Logger__c WHERE isSolved__c = false AND (Service__c =:sfdccreate OR Service__c =:sfdcupdate ) AND Related_Account_Company__c = null AND Object__c =:accountSalesOrganisation  ';
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
		List<Account_Sales_Organization__c> relatedaccountSalesOrganisation = AccountSalesOrganizationDAO.getASOsFromRecordIds(queryfields, calloutLoggerRecordIds);
		Map<String, Id> externalIdandAccountIdMap = new Map<String, Id>();
		for (Account_Sales_Organization__c a : relatedaccountSalesOrganisation){
			externalIdandAccountIdMap.put(a.External_Id__c, a.Id);
		}
		for (Callout_Logger__c cl : calloutLoggers){
			cl.Related_Account_Sales_Organization__c = externalIdandAccountIdMap.get(cl.RecordId__c);
			calloutLoggerList.add(cl);
		}
		update calloutLoggerList;
	}

	public void finish(Database.BatchableContext bc){
		Database.executeBatch(new AssignAddressLogsBatch());
	}

	public static void Execute(SchedulableContext ctx){
		Database.executeBatch(new AccountSalesOrganizationLogsBatch()); //TODO
	}


}