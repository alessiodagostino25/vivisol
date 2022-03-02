public without sharing class SAPMeasurementBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts{

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Serialized_Item__c, Serialized_Item__r.Equipment_Key__c, Date_Measurement__c, Measure__c, Parameter_1_Value__c, ' +
        'isCreatedSAP__c FROM Measurement__c WHERE isCreatedSAP__c = false AND Measure__c = \'COUNTER\''; 
        System.debug(query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Measurement__c> measurements) {
        if(FeatureManagementService.getFeatureStatus('SAP_Measurement_Create') || Test.isRunningTest()) {
            MeasurementService.makeCalloutWrapper(measurements);
        }
    }

    public void finish(Database.BatchableContext bc) {
        system.debug('DONE'); //TODO
    }

    public static void Execute(SchedulableContext ctx) {
        Database.executeBatch(new SAPMeasurementBatch(), 5);
    }

}