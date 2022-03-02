public class AssignedResourceTriggerService {
    public static List<WorkOrder> updateRelatedWOs(List<Id> assignedResourceIds) {
        System.debug('----- AssignedResourceTriggerService.updateRelatedWOs -----');
        List<String> workOrderQueryFields = new List<String>{'Status', 'Resource__c', 'Source_Location__c', 'SAP_Plant__c', 'SAP_Storage_Location__c', 'Delivery_Type__c',
        'ParentWorkOrderId'};
        List<String> assignedResourceQueryFields = new List<String>{'ServiceResourceId', 'ServiceAppointmentId'};
        List<String> serviceResourceQueryFields = new List<String>{'LocationId', 'Location.Plant__c', 'Location.ParentLocationId'};
        List<String> locationQueryFields = new List<String>{'ParentLocationId', 'Plant__c'};
        List<String> serviceAppointmentQueryFields = new List<String>{'ParentRecordId', 'SchedStartTime', 'ServiceTerritoryId', 'ServiceTerritory.Stock__c'};

        List<Id> relatedWorkOrderIds = new List<Id>();
        List<Id> serviceAppointmentIds = new List<Id>();
        List<Id> serviceResourceIds = new List<Id>();
        List<Id> locationIds = new List<Id>();
        List<String> welcomeModelIds = new List<String>();
        List<String> welcomeModelServiceResourceIds = new List<String>();
        List<WorkOrder> toUpdate = new List<WorkOrder>();
        List<WorkOrder> allDependentWOs = new List<WorkOrder>();

        Map<Id, AssignedResource> assignedResourceMap = new Map<Id, AssignedResource>();
        Map<Id, ServiceResource> serviceResourceMap = new Map<Id, ServiceResource>();
        Map<Id, ServiceAppointment> serviceAppointmentMap = new Map<Id, ServiceAppointment>();
        Map<Id, Schema.Location> locationMap = new Map<Id, Schema.Location>();
        Map<Id, Schema.Location> storageLocationMap = new Map<Id, Schema.Location>();

        List<AssignedResource> assignedResources = AssignedResourceDAO.getAssignedResourcesFromIds(assignedResourceQueryFields, assignedResourceIds);

        for(AssignedResource ar : assignedResources) {
            serviceAppointmentIds.add(ar.ServiceAppointmentId);
            assignedResourceMap.put(ar.ServiceAppointmentId, ar);
            serviceResourceIds.add(ar.ServiceResourceId);
        }   

        // Getting all the related WOs and Service Appointments...

        List<ServiceAppointment> relatedServiceAppointments = ServiceAppointmentDAO.getSAsFromIds(serviceAppointmentQueryFields, serviceAppointmentIds);

        for(ServiceAppointment sa : relatedServiceAppointments) {
            Id parentId = sa.ParentRecordId;
            Schema.SObjectType sobjectType = parentId.getSObjectType();
            String sobjectName = sobjectType.getDescribe().getName();

            if(sobjectName == 'WorkOrder') {
                relatedWorkOrderIds.add(sa.ParentRecordId);
            }

            serviceAppointmentMap.put(sa.ParentRecordId, sa);
        }

        List<WorkOrder> relatedWorkOrders = WorkOrderDAO.getWorkOrdersFromIds(workOrderQueryFields, relatedWorkOrderIds);

        if(relatedWorkOrders != null && !relatedWorkOrders.isEmpty()) {
            for(WorkOrder wo : relatedWorkOrders) {
                if(wo.Delivery_Type__c == 'Welcome Model') {
                    ServiceAppointment relatedServiceAppointment = serviceAppointmentMap.get(wo.Id);

                    if(relatedServiceAppointment != null) {
                        AssignedResource relatedAssignedResource = assignedResourceMap.get(relatedServiceAppointment.Id);

                        if(relatedAssignedResource != null) {
                            welcomeModelIds.add(wo.Id);
                            welcomeModelServiceResourceIds.add(relatedAssignedResource.ServiceResourceId);
                        }
                    }
                } 
            }

            // Updating WOs linked to AR.SA.ParentRecordId (via ParentWorkOrderId) with Resource = SARelatedToParentWO.AR.ServiceResource, if Parent is a WelcomeModel
 
            if(!welcomeModelIds.isEmpty() && !welcomeModelServiceResourceIds.isEmpty()) {
                List<WorkOrder> toUpdateAssignedResource = WorkOrderDAO.getWOsFromParentsAndDifferentResource(workOrderQueryFields, welcomeModelIds, 
                welcomeModelServiceResourceIds);

                List<ServiceResource> WMServiceResources = ServiceResourceDAO.getServiceResourcesFromIds(serviceResourceQueryFields, welcomeModelServiceResourceIds);

                if(WMServiceResources != null && !WMServiceResources.isEmpty()) {
                    for(ServiceResource sr : WMServiceResources) {
                        serviceResourceMap.put(sr.Id, sr);
                    }
                }

                if(toUpdateAssignedResource != null && !toUpdateAssignedResource.isEmpty()) {
                    for(WorkOrder wo : toUpdateAssignedResource) {
                        ServiceAppointment SARelatedToParent = serviceAppointmentMap.get(wo.ParentWorkOrderId);

                        if(SARelatedToParent != null) {
                            AssignedResource ARRelatedToParent = assignedResourceMap.get(SARelatedToParent.Id);

                            if(ARRelatedToParent != null) {
                                ServiceResource relatedServiceResource = serviceResourceMap.get(ARRelatedToParent.ServiceResourceId);

                                if(relatedServiceResource != null) {
                                    wo.Resource__c = relatedServiceResource.Id;

                                    if(SARelatedToParent.ServiceTerritory.Stock__c == false) {
                                        wo.Source_Location__c = relatedServiceResource.LocationId;
                                        wo.SAP_Plant__c = relatedServiceResource.Location.Plant__c;
                                        wo.SAP_Storage_Location__c = relatedServiceResource.Location.ParentLocationId;
                                    }

                                    toUpdate.add(wo);
                                }
                            }
                        }
                    }
                }
            }
        }

        // ... Then all the Service Resources using the ServiceResourceIds of the previously retrieved ARs...

        List<ServiceResource> relatedServiceResources = ServiceResourceDAO.getServiceResourcesFromIds(serviceResourceQueryFields, serviceResourceIds);

        for(ServiceResource sr : relatedServiceResources) {
            locationIds.add(sr.LocationId);
            serviceResourceMap.put(sr.Id, sr);
        }

        // ... Then all the Locations using the LocationIds of the previously retrieved SRs

        List<Schema.Location> relatedLocations = LocationDAO.getLocationsFromIds(locationQueryFields, locationIds);

        for(Schema.Location l : relatedLocations) {
            locationMap.put(l.Id, l);
        }

        if(relatedWorkOrders != null && !serviceAppointmentMap.isEmpty()) {
            for(WorkOrder wo : relatedWorkOrders) {

                // Getting "in chain" all the related resources I need, then updating the WO

                ServiceAppointment relatedServiceAppointment = serviceAppointmentMap.get(wo.Id);
                AssignedResource relatedAR = assignedResourceMap.get(relatedServiceAppointment.Id);

                System.debug('relatedServiceAppointment: ' + relatedServiceAppointment);
                System.debug('relatedAR: ' + relatedAR);

                if(relatedServiceAppointment != null && relatedAR != null) {
                    wo.Resource__c = relatedAR.ServiceResourceId;

                    if(wo.Delivery_Type__c == 'Home Visit' || wo.Delivery_Type__c == 'Remote Call' || 
                    (wo.Delivery_Type__c == 'Welcome Model' && relatedServiceAppointment.ServiceTerritory.Stock__c == false)) {
                        
                        ServiceResource relatedServiceResource = serviceResourceMap.get(relatedAR.ServiceResourceId);
                        Schema.Location relatedLocation = locationMap.get(relatedServiceResource.LocationId);

                        System.debug('relatedServiceResource: ' + relatedServiceResource);
                        System.debug('relatedLocation: ' + relatedLocation);

                        if(relatedServiceResource != null) {
                            wo.Source_Location__c = relatedServiceResource.LocationId;
                        }
                        if(relatedLocation != null) {
                            wo.SAP_Plant__c = relatedLocation.Plant__c;
                            wo.SAP_Storage_Location__c = relatedLocation.ParentLocationId;
                        }
                    }
                    else if(wo.Delivery_Type__c == 'Welcome Model' && relatedServiceAppointment.ServiceTerritory.Stock__c == true) {
                        System.debug('Welcome Model WorkOrder with ServiceTerritory.Stock__c = true');
                    }

                    if(!toUpdate.contains(wo)) {
                        toUpdate.add(wo);
                    }
                }
            }
        }

        return toUpdate;
    }

    public static List<AssignedResource__e> createAssignedResourceEvents(List<AssignedResource> assignedResources) {
        System.debug('----- createAssignedResourceEvents -----');

        List<AssignedResource__e> events = new List<AssignedResource__e>();

        for(AssignedResource ar : assignedResources) {
            AssignedResource__e event = new AssignedResource__e(
                AssignedResourceId__c = ar.Id
            );

            events.add(event);
            System.debug('event: ' + event);
        }

        return events;
    }

    /* @future
    public static void futureAssignedResourceHandling(List<String> assignedResourceIds) {
        if(!assignedResourceIds.isEmpty()) {
            List<WorkOrder> workOrdersToUpdate = updateRelatedWOs(assignedResourceIds);

            if(!workOrdersToUpdate.isEmpty()) {
                List<Database.SaveResult> results = Database.update(workOrdersToUpdate);
            }
        }
    } */
}