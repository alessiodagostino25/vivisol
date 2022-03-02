public class AssignContractFrameworkBatch implements Database.Batchable<sObject>, Schedulable {
 
    public  Database.QueryLocator start(Database.BatchableContext bc){
        String sfdcservice = 'SFDC_SAP4HANA__CONTRACT' ;
        String query = 'select Service__c ,Related_Contract_Framework__c ,isSolved__c,RecordId__c From Callout_Logger__c WHERE isSolved__c = false AND Service__c =:sfdcservice AND Related_Contract_Framework__c = null';
        System.debug(query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Callout_Logger__c> calloutLoggers){
		List<String> calloutLoggerRecordIds = new List<String>();
		List<Callout_Logger__c> calloutLoggerList = new List<Callout_Logger__c>();
		for (Callout_Logger__c cl : calloutLoggers){
			calloutLoggerRecordIds.add(cl.RecordId__c);
		}
        List<String> queryfields = new List<String>{'Id', 'Contract_Number__c'};
        List<Contract_Framework__c> relatedContractFrameworks =  ContractFrameworkDAO.getCFsFromrecordids(queryfields,calloutLoggerRecordIds);
        Map<String, Id> contractnumberandId = new Map<String, Id>();
        for (Contract_Framework__c cf : relatedContractFrameworks) {
            contractnumberandId.put(cf.Contract_Number__c,cf.Id);
        }
        for (Callout_Logger__c cl : calloutLoggers) {
            cl.Related_Contract_Framework__c = contractnumberandId.get(cl.RecordId__c);
            calloutLoggerList.add(cl);
        }
        if(!calloutLoggerList.isEmpty()){
            update calloutLoggerList;
        } 
    }
        
	public void finish(Database.BatchableContext bc){
		Database.executeBatch(new AccountCompanyLogsBatch(), 2000);
	}

	public static void Execute(SchedulableContext ctx){
		Database.executeBatch(new AssignContractFrameworkBatch(), 2000); //TODO
	}
   
}