global without sharing class ServiceTerritoryUpdateBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
    global WOLICreationBatch WOLIBatch;
    global ATAAlignmentBatch ATAAlignmentBatch;
    global Boolean sendAutoschedulingEndNotification;
    global String targetId;
    global Integer WOLIBatchSize;
    global Integer ATABatchSize;
    global List<WorkOrder> toRetry = new List<WorkOrder>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> queryFields = new List<String>{'Check_Service_Territory__c', 'ServiceTerritoryId', 'Latitude', 'Longitude', 'Delivery_Type__c'};

        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrder WHERE Check_Service_Territory__c = true AND LastModifiedDate = TODAY AND RecordType.DeveloperName != \'WorkOrder_CPAPSchool\' ' +
        'AND (Status = \'New\' OR Status = \'Draft\')';

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

            if(wo.Latitude != null && wo.Longitude != null) {
                Double relatedLongitude = wo.Longitude;
                Double relatedLatitude = wo.Latitude;

                System.debug('RelatedLongitude: ' + relatedLongitude);
                System.debug('RelatedLatitude: ' + relatedLatitude);

                Id newServiceTerritoryId = FSL.PolygonUtils.getTerritoryIdByPolygons(relatedLongitude, relatedLatitude);

                System.debug('Old ServiceTerritoryId: ' + wo.ServiceTerritoryId);
                System.debug('newServiceTerritoryId: ' + newServiceTerritoryId);

                if(newServiceTerritoryId != wo.ServiceTerritoryId) {
                    if(wo.Delivery_Type__c != 'Welcome Model' && wo.Delivery_Type__c != 'Remote Call') {
                        wo.ServiceTerritoryId = newServiceTerritoryId;
                    }

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
            else {
                System.debug('Latitude e Longitude nulle');

                if(wo.Delivery_Type__c != 'Welcome Model' &&  wo.Delivery_Type__c != 'Remote Call') {
                    wo.ServiceTerritoryId = null;
                }

                if(relatedServiceAppointments != null) {
                    if(!relatedServiceAppointments.isEmpty()) {
                        for(ServiceAppointment sa : relatedServiceAppointments) {
                            if(sa.ServiceTerritoryId != wo.ServiceTerritoryId) {
                                sa.ServiceTerritoryId = wo.ServiceTerritoryId;

                                serviceAppointmentsToUpdate.add(sa);
                            }
                        }
                    }
                }

                wo.Check_Service_Territory__c = false;
            }

            /* wo.Service_Territory_Batch_Counter__c = wo.ServiceTerritory_Batch_Counter__c + 1;

            if(wo.Service_Territory_Batch_Counter__c > 2 && wo.Check_Service_Territory__c == true) {
                wo.Check_Service_Territory__c = false;
            } */
        }

        try {
            update workOrders; // Salvarseli in variabile stateful per riprovare l'update nel finish (senza rilanciare tutto il batch)?
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

        if(ATAAlignmentBatch != null) {
            Integer batchSize = 100;

            if(ATABatchSize != null) {
                batchSize = ATABatchSize;
            }

            Database.executeBatch(ATAAlignmentBatch, batchSize);
        }

        if(WOLIBatch != null) {
            Integer batchSize = 3;

            if(WOLIBatchSize != null) {
                batchSize = WOLIBatchSize;
            }

            Database.executeBatch(WOLIBatch, batchSize);
        }

        if(sendAutoschedulingEndNotification == true && targetId != null) {
            CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Autoscheduling_Finished'];
            
            if(type != null) {
                Messaging.CustomNotification notification = new Messaging.CustomNotification();

                notification.setTargetId(targetId);
                notification.setNotificationTypeId(type.Id);
                notification.setBody(Label.Notification_AutoschedulingFinished_Body);
                notification.setTitle(Label.Notification_AutoschedulingFinished_Title);

                try {
                    notification.send(new Set<String>{Userinfo.getUserId()});
                }
                catch(Exception e) {
                    System.debug('Problem sending notification: ' + e.getMessage());
                }
            }

        }
    }

    public static void Execute(SchedulableContext ctx) {
        System.debug('Checking for already running Jobs...');

        List<AsyncApexJob> runningJobs = [SELECT Id FROM AsyncApexJob 
                                          WHERE (ApexClass.Name = 'WOLICreationBatch' OR ApexClass.Name = 'AutoscheduleActivitiesTherapyBatch')
                                          AND (Status = 'Processing' OR Status = 'Holding' OR Status = 'Queued' OR Status = 'Preparing')];

        if(runningJobs == null || runningJobs.isEmpty()) {
            System.debug('No other Jobs running, executing ServiceTerritoryUpdateBatch...');

            Database.executeBatch(new ServiceTerritoryUpdateBatch(), 50);
        }
    }
}