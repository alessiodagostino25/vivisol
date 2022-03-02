public without sharing class AddressSyncSapBatch implements Database.Batchable<sObject>, Schedulable{

	public Database.QueryLocator start(Database.BatchableContext bc){
		String query = 'SELECT Id,IsSyncSAP__c,ParentId,AddressType,City,Country,LocationType,Phone_number__c,PostalCode,StateCode,Street,TransportationZone__c FROM Address where IsSyncSAP__c = false ';
		System.debug(query);
		return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Schema.Address> Address){
        List<Id> parentIds = new List<Id>();
        for(Schema.Address a : Address) {
            parentIds.add(a.ParentId); 
        }
        AddressService.updateAndcreateEventforbatchprocess(parentIds, Address);
    }
    
    public void finish(Database.BatchableContext bc) {
        system.debug('DONE'); 
    }

    public static void Execute(SchedulableContext ctx){
        Database.executeBatch(new AddressSyncSapBatch()); 
    }


}