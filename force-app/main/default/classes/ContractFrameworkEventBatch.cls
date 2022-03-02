public class ContractFrameworkEventBatch implements Database.Batchable<sObject>, Schedulable{
    public Database.QueryLocator start(Database.BatchableContext bc){
        //query to get all the Contract Frameworks based on conditions 
        String active = 'Active' ;
        String query = 'SELECT Contract_Number__c,Name,Contract_Start_date__c,Contract_End_date__c,Sales_Organization__c,Distribution_Channel__c,Division__c,Customer__r.Account_External_Id__c,Contract_Type__c, IsSyncSAP__c '+
        ' FROM Contract_Framework__c WHERE IsSyncSAP__c = \'NotSync\' AND Status__c =:active '; 
		
		System.debug(query);
		return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Contract_Framework__c> contractFrameworks){
        List<Contract__e> contractEventsUpdate = new List<Contract__e>();
        List<Contract_Framework__c> cfUpdate = new List<Contract_Framework__c>();
        for(Integer i=0 ;i < contractFrameworks.size(); i++ ){
            Contract__e contractEvent = new Contract__e();
            contractEvent.Contract_Number__c = contractFrameworks[i].Contract_Number__c ;
            contractEvent.Name__c = contractFrameworks[i].Name;
            contractEvent.Contract_Start_date__c = contractFrameworks[i].Contract_Start_date__c;
            contractEvent.Contract_End_date__c = contractFrameworks[i].Contract_End_date__c;
            contractEvent.Sales_Organization__c = contractFrameworks[i].Sales_Organization__c;
            contractEvent.Distribution_Channel__c   = contractFrameworks[i].Distribution_Channel__c   ;
            contractEvent.Division__c = contractFrameworks[i].Division__c ;
            contractEvent.Contract_Type__c = contractFrameworks[i].Contract_Type__c;
            contractEvent.ContractFrameWorkId__c = contractFrameworks[i].Id ;
            contractEvent.Customer__c = contractFrameworks[i].Customer__r.Account_External_Id__c;
            contractEventsUpdate.add(contractEvent);
            contractFrameworks[i].IsSyncSAP__c = 'Sync';
            cfUpdate.add(contractFrameworks[i]);
        }

        List<Database.SaveResult> createEvents = EventBus.publish(contractEventsUpdate);
        update cfUpdate ;
    }

    public void finish(Database.BatchableContext bc){
		system.debug('DONE');
	}

	public static void Execute(SchedulableContext ctx){
		Database.executeBatch(new ContractFrameworkEventBatch());
	}


}