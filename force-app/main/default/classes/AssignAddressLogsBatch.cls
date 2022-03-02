public class AssignAddressLogsBatch implements Database.Batchable<sObject>, Schedulable{
    
    public  Database.QueryLocator start(Database.BatchableContext bc){
        String sfdccreate = 'SFDC_SAP4HANA__ADDRESS_CREATE' ;
        String sfdcupdate = 'SFDC_SAP4HANA__ADDRESS_UPDATE' ;
        String query = 'select Service__c ,RecordId__c,Related_Address__c,isSolved__c  From Callout_Logger__c WHERE (Service__c =:sfdccreate OR Service__c =:sfdcupdate ) AND isSolved__c = false AND Related_Address__c = null';
		System.debug(query);
		return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Callout_Logger__c> calloutLoggers){
        List<String> recordIds = new List<String>();
        List<Callout_Logger__c> calloutLoggerList = new List<Callout_Logger__c>();
        for (Callout_Logger__c cl : calloutLoggers) {
            recordIds.add(cl.RecordId__c) ;
        }
        List<Schema.Address> relatedaddress =  AddressDAO.getAddressesForCalloutLoggers(recordIds) ;
        Map<String, Id> addressIdandrecordId = new Map<String, Id>();
        for (Schema.Address a : relatedaddress) {
            addressIdandrecordId.put(a.Parent.Location_Id__c , a.Id);
        }
        for (Callout_Logger__c cl : calloutLoggers) {
            cl.Related_Address__c = addressIdandrecordId.get(cl.RecordId__c);
            calloutLoggerList.add(cl) ;
        }
        update calloutLoggerList ;
    }

    public void finish(Database.BatchableContext bc){
		//Database.executeBatch(new CalloutLoggerResolutionBatch(), 2000);
        Database.executeBatch(new AssignAccountTreatmentLogsBatch());
	}

	public static void Execute(SchedulableContext ctx){
		Database.executeBatch(new AssignAddressLogsBatch()); //TODO
	}



}