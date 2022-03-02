global without sharing class ServiceTerritoryCheckBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
    global List<WorkOrder> toRetry = new List<WorkOrder>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> queryFields = new List<String>{'Check_Service_Territory__c', 'ServiceTerritoryId', 'Latitude', 'Longitude', 'Delivery_Type__c'};

        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrder WHERE Check_Service_Territory__c = false AND StatusCategory = \'New\' AND Latitude != null AND Longitude != null ' +
        'AND ServiceTerritoryId = null AND Delivery_Type__c = \'Home Visit\'';

        System.debug(query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<WorkOrder> workOrders) {
        System.debug('workOrders: ' + workOrders);

        List<String> serviceAppointmentQueryFields = new List<String>{'ServiceTerritoryId', 'ParentRecordId'};

        List<Id> workOrderIds = new List<Id>();
        List<ServiceAppointment> allRelatedNoneSAs = new List<ServiceAppointment>();
        List<ServiceAppointment> serviceAppointmentsToUpdate = new List<ServiceAppointment>();

        Map<String, List<ServiceAppointment>> workOrderToSAsMap = new Map<String, List<ServiceAppointment>>();

        for(WorkOrder wo : workOrders) {
            workOrderIds.add(wo.Id);
        }

        allRelatedNoneSAs = ServiceAppointmentDAO.getNoneAndNewSAsFromParentIds(serviceAppointmentQueryFields, workOrderIds);

        if(!allRelatedNoneSAs.isEmpty()) {
            for(ServiceAppointment sa : allRelatedNoneSAs) {
                if(workOrderToSAsMap.get(sa.ParentRecordId) == null) {
                    workOrderToSAsMap.put(sa.ParentRecordId, new List<ServiceAppointment>());
                }
                workOrderToSAsMap.get(sa.ParentRecordId).add(sa);
            }
        }

        for(WorkOrder wo : workOrders) {
            List<ServiceAppointment> relatedServiceAppointments = new List<ServiceAppointment>();
            relatedServiceAppointments = workOrderToSAsMap.get(wo.Id);
            System.debug('relatedServiceAppointments: ' + relatedServiceAppointments);

            Double relatedLongitude = wo.Longitude;
            Double relatedLatitude = wo.Latitude;

            System.debug('RelatedLongitude: ' + relatedLongitude);
            System.debug('RelatedLatitude: ' + relatedLatitude);

            Id newServiceTerritoryId = FSL.PolygonUtils.getTerritoryIdByPolygons(relatedLongitude, relatedLatitude);

            System.debug('Old ServiceTerritoryId: ' + wo.ServiceTerritoryId);
            System.debug('newServiceTerritoryId: ' + newServiceTerritoryId);

            if(newServiceTerritoryId != wo.ServiceTerritoryId) {
                wo.ServiceTerritoryId = newServiceTerritoryId;
                wo.Check_Service_Territory__c = false;
            }

            if(relatedServiceAppointments != null) {
                if(!relatedServiceAppointments.isEmpty()) {
                    for(ServiceAppointment sa : relatedServiceAppointments) {
                        System.debug('Updating SA.ST...');

                        if(sa.ServiceTerritoryId != wo.ServiceTerritoryId) {
                            sa.ServiceTerritoryId = wo.ServiceTerritoryId;

                            serviceAppointmentsToUpdate.add(sa);
                        }
                    }
                }
            }
        }

        try {
            update workOrders;
        }
        catch(DmlException e) {
            System.debug('Exception caught!');
            System.debug(e.getMessage());
            System.debug('--- Adding to toRetry... ---');
            toRetry.addAll(workOrders);
        }

        if(!serviceAppointmentsToUpdate.isEmpty()) {
            List<Database.SaveResult> results = Database.update(serviceAppointmentsToUpdate);
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('DONE');

        if(!toRetry.isEmpty()) {
            System.debug('--- Retrying failed records... ---');
            update toRetry;  // try/catch?
        }
    }

    public static void Execute(SchedulableContext ctx) {
        System.debug('Checking for already running Jobs...');

        List<AsyncApexJob> runningJobs = [SELECT Id FROM AsyncApexJob 
                                          WHERE (ApexClass.Name = 'WOLICreationBatch' OR ApexClass.Name = 'AutoscheduleActivitiesTherapyBatch')
                                          AND (Status = 'Processing' OR Status = 'Holding' OR Status = 'Queued' OR Status = 'Preparing')];

        if(runningJobs == null || runningJobs.isEmpty()) {
            System.debug('No other Jobs running, executing ServiceTerritoryCheckBatch...');

            Database.executeBatch(new ServiceTerritoryCheckBatch(), 50);
        }
    }
}