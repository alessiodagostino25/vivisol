public class ServiceAppointmentTriggerService {
    
    public static Map<Id, WorkOrder> updateDatesAndNotMRD(List<ServiceAppointment> serviceAppointments) {
        List<String> workOrderQueryFields = new List<String>{'StartDate', 'EndDate', 'Account_Treatment__r.Treatment_Type__c', 
        'Contract_Treatment_Job__r.SADependency__c', 'Contract_Treatment_Job__r.Scheduling_Rule__c',
        'Contract_Treatment_Job__r.Contract_Treatment_Job__c', 'Account_Treatment__c', 'Contract_Treatment_Job__c', 'Contract_Treatment_Job__r.SA_Dependency_Job__c'};

        List<Id> parentRecordIds = new List<Id>();
        List<Id> relatedWorkOrderIds = new List<Id>();
        List<ServiceAppointment> SAsToUpdate = new List<ServiceAppointment>();

        Map<Id, WorkOrder> workOrderMap = new Map<Id, WorkOrder>();

        for(ServiceAppointment sa : serviceAppointments) {
            parentRecordIds.add(sa.ParentRecordId);
        }

        // Searching for WorkOrder Ids in the list of ParentRecordIds by getting the sObject Name...

        if(!parentRecordIds.isEmpty()) {
            for(Id parentRecordId : parentRecordIds) {
                Schema.SObjectType sObjectType = parentRecordId.getSObjectType();
                String sObjectName = sObjectType.getDescribe().getName();

                if(sObjectName == 'WorkOrder') {
                    relatedWorkOrderIds.add(parentRecordId);
                }
            }
        }

        // ... If found, get all the related Parent WorkOrders and build a map

        if(!relatedWorkOrderIds.isEmpty()) {
            List<WorkOrder> parentWorkOrders = WorkOrderDAO.getWorkOrdersFromIds(workOrderQueryFields, relatedWorkOrderIds);

            if(parentWorkOrders != null) {
                for(WorkOrder wo : parentWorkOrders) {
                    workOrderMap.put(wo.Id, wo);
                }
            }
        }

        // Updating fields of the ServiceAppointments (by cloning the ServiceAppointment because the Trigger fires after insert)

        if(!workOrderMap.isEmpty()) {
            for(ServiceAppointment sa : serviceAppointments) {
                WorkOrder parentWorkOrder = workOrderMap.get(sa.ParentRecordId);

                if(parentWorkOrder != null) {
                    ServiceAppointment tmp = new ServiceAppointment();
                    tmp.Id = sa.Id;
                    
                    if(sa.Status == 'None') {
                        tmp.DueDate = parentWorkOrder.EndDate;
                        tmp.EarliestStartTime = parentWorkOrder.StartDate;
                    }

                    System.debug('parentWorkOrder.Account_Treatment__r.Treatment_Type__c: ' + parentWorkOrder.Account_Treatment__r.Treatment_Type__c);
                    if((parentWorkOrder.Account_Treatment__r.Treatment_Type__c) == 'MRD') {
                        tmp.NotMRD__c = false;
                    }

                    SAsToUpdate.add(tmp);
                }
            }
        }

        if(!SAsToUpdate.isEmpty()) {
            update SAsToUpdate;
        }

        // Returning workOrderMap because I'll need this for another method in the Trigger

        return workOrderMap;
    }

    public static List<FSL__Time_Dependency__c> createTimeDependencies(Map<Id, WorkOrder> SAIdToParentWOMap) {
        List<String> ATJQueryFields = new List<String>{'Patient_Treatment__c', 'Contract_Treatment_Job__c'};
        List<String> workOrderQueryFields = new List<String>{'Account_Treatment_Job__c'};
        List<String> serviceAppointmentQueryFields = new List<String>{'ParentRecordId'};

        List<FSL__Time_Dependency__c> newTimeDependencies = new List<FSL__Time_Dependency__c>();
        List<Id> SAIdsToCreateDependency = new List<Id>();

        // Filtering the ServiceAppointmentIds and considering only the ones whose WorkOrder satisfies certain conditions

        for(Id serviceAppointmentId : SAIdToParentWOMap.keySet()) {
            WorkOrder relatedWorkOrder = SAIdToParentWOMap.get(serviceAppointmentId);
            System.debug('relatedWorkOrder: ' + relatedWorkOrder);

            if(
                ((relatedWorkOrder.Contract_Treatment_Job__r.SADependency__c) != null) && 
                ((relatedWorkOrder.Contract_Treatment_Job__r.Scheduling_Rule__c) == 'Autoscheduled' || 
                (relatedWorkOrder.Contract_Treatment_Job__r.Scheduling_Rule__c) == 'Dependent Job Execution') &&
                ((relatedWorkOrder.Contract_Treatment_Job__r.SA_Dependency_Job__c) != null)
            ) {
                SAIdsToCreateDependency.add(serviceAppointmentId);
            }
        }

        System.debug('SAIdsToCreateDependency size: ' + SAIdsToCreateDependency.size());
        if(!SAIdsToCreateDependency.isEmpty()) {
            List<Id> relatedWorkOrderIds = new List<Id>();
            List<Id> relatedATIds = new List<Id>();
            List<Id> relatedParentCTJIds = new List<Id>();
            List<Id> ATJIds = new List<Id>();
            List<Id> workOrderIds = new List<Id>();

            List<Account_Treatment_Job__c> ATJsRelatedToWorkOrders = new List<Account_Treatment_Job__c>();
            List<WorkOrder> workOrdersRelatedToATJs = new List<WorkOrder>();
            List<ServiceAppointment> SAsRelatedToWOs = new List<ServiceAppointment>();

            Map<Id, WorkOrder> ATJIdToWOMap = new Map<Id, WorkOrder>();
            Map<Id, ServiceAppointment> parentIdToSAMap = new Map<Id, ServiceAppointment>();

            // Getting the lists of all WorkOrderIds and ATIds and ParentCTJIds related to the WorkOrder related to the ServiceAppointment

            for(Id serviceAppointmentId : SAIdsToCreateDependency) {
                WorkOrder relatedWorkOrder = SAIdToParentWOMap.get(serviceAppointmentId);

                relatedWorkOrderIds.add(relatedWorkOrder.Id);
                relatedATIds.add(relatedWorkOrder.Account_Treatment__c);
                relatedParentCTJIds.add(relatedWorkOrder.Contract_Treatment_Job__r.SA_Dependency_Job__c);
            }

            System.debug('relatedWorkOrderIds size: ' + relatedWorkOrderIds.size());
            System.debug('relatedATIds: ' + relatedATIds);
            System.debug('relatedParentCTJIds: ' + relatedParentCTJIds);
            if(!relatedWorkOrderIds.isEmpty()) {

                // Getting all the ATJs related (by AT Id and CTJ Id) to the WorkOrders related to the ServiceAppointments

                ATJsRelatedToWorkOrders = AccountTreatmentJobDAO.getATJsFromATsAndCTJs(ATJQueryFields, relatedATIds, relatedParentCTJIds);

                System.debug('ATJsRelatedToWorkOrders: ' + ATJsRelatedToWorkOrders);
                if(!ATJsRelatedToWorkOrders.isEmpty()) {
                    System.debug('ATJsRelatedToWorkOrders size: ' + ATJsRelatedToWorkOrders.size());
                    for(Account_Treatment_Job__c atj : ATJsRelatedToWorkOrders) {
                        ATJIds.add(atj.Id);
                    }
                }

                // Getting all the WorkOrders related to the ATJs previously found. These are different WOs, and there is one for each ATJ

                if(!ATJIds.isEmpty()) {
                    workOrdersRelatedToATJs = WorkOrderDAO.getWorkOrdersFromATJIds(workOrderQueryFields, ATJIds);

                    System.debug('workOrdersRelatedToATJs: ' + workOrdersRelatedToATJs);
                    if(!workOrdersRelatedToATJs.isEmpty()) {
                        System.debug('workOrdersRelatedToATJs size: ' + workOrdersRelatedToATJs.size());
                        for(WorkOrder wo : workOrdersRelatedToATJs) {
                            workOrderIds.add(wo.Id);
                            ATJIdToWOMap.put(wo.Account_Treatment_Job__c, wo);
                        }

                        // Getting all the ServiceAppointments related to those WOs

                        if(!workOrderIds.isEmpty()) {
                            SAsRelatedToWOs = ServiceAppointmentDAO.getNoneSAsFromParentIds(serviceAppointmentQueryFields, workOrderIds);

                            System.debug('SAsRelatedToWOs: ' + SAsRelatedToWOs);
                            if(!SAsRelatedToWOs.isEmpty()) {
                                System.debug('SAsRelatedToWOs size: ' + SAsRelatedToWOs.size());
                                for(ServiceAppointment sa : SAsRelatedToWOs) {
                                    parentIdToSAMap.put(sa.ParentRecordId, sa);
                                }
                            }
                        }
                    }
                }
            }

            for(Id serviceAppointmentId : SAIdsToCreateDependency) {
                WorkOrder relatedWorkOrder = SAIdToParentWOMap.get(serviceAppointmentId);
                Account_Treatment_Job__c relatedATJ;
                System.debug('relatedWorkOrder: ' + relatedWorkOrder);

                // Cycling all the ATJs related to all the WorkOrders to find the one linked to the WorkOrder of this ServiceAppointment

                for(Account_Treatment_Job__c atj : ATJsRelatedToWorkOrders) {
                    if(atj.Patient_Treatment__c == relatedWorkOrder.Account_Treatment__c && 
                    atj.Contract_Treatment_Job__c == (relatedWorkOrder.Contract_Treatment_Job__r.SA_Dependency_Job__c)) {
                        relatedATJ = atj;
                        break;
                    }
                }

                // Getting the WorkOrder (another one) linked to the ATJ found (if found). There will be only one WO per ATJ

                System.debug('relatedATJ: ' + relatedATJ);
                if(relatedATJ != null) {
                    WorkOrder WORelatedToATJ = ATJIdToWOMap.get(relatedATJ.Id);
                    System.debug('WORelatedToATJ: ' + WORelatedToATJ);

                    // Getting the ServiceAppointment (another one) related to the WorkOrder found before

                    if(WORelatedToATJ != null) {
                        ServiceAppointment relatedServiceAppointment = parentIdToSAMap.get(WORelatedToATJ.Id);
                        System.debug('relatedServiceAppointment: ' + relatedServiceAppointment);

                        // Creating Time Dependency

                        if(relatedServiceAppointment != null) {
                            FSL__Time_Dependency__c newTimeDependency = new FSL__Time_Dependency__c(
                                FSL__Dependency__c = relatedWorkOrder.Contract_Treatment_Job__r.SADependency__c,
                                FSL__Service_Appointment_1__c = serviceAppointmentId,
                                FSL__Service_Appointment_2__c = relatedServiceAppointment.Id
                            );

                            newTimeDependencies.add(newTimeDependency);
                        }
                    }
                }
            }
        }

        return newTimeDependencies;
    }

    public static void launchEmailFlow(Id serviceAppointmentId) {
        if(FeatureManagementService.getFeatureStatus('SATrigger_Launch_Email_Flow') || Test.isRunningTest()) {
            ServApptEmailFlowController.serviceAppointmentId = serviceAppointmentId;
            ServApptEmailFlowController.start();
        }
    }

    public static List<WorkOrder> updateRelatedWorkOrders(List<ServiceAppointment> serviceAppointments) {
        System.debug('IN updateRelatedWorkOrders');
        List<String> workOrderQueryFields = new List<String>{'SAScheduledStart__c', 'Status', 'Delivery_Type__c', 'SAP_Plant__c', 'SAP_Storage_Location__c', 
        'ServiceTerritoryId'};
        List<String> serviceTerritoryQueryFields = new List<String>{'Plant__c', 'Warehouse__c', 'Stock__c'};

        List<WorkOrder> workOrdersToUpdate = new List<WorkOrder>();
        List<Id> relatedWorkOrderIds = new List<Id>();
        List<Id> serviceTerritoryIds = new List<Id>();

        Map<Id, WorkOrder> workOrderMap = new Map<Id, WorkOrder>();
        Map<Id, ServiceTerritory> serviceTerritoryMap = new Map<Id, ServiceTerritory>();

        for(ServiceAppointment sa : serviceAppointments) {
            relatedWorkOrderIds.add(sa.ParentRecordId);
            serviceTerritoryIds.add(sa.ServiceTerritoryId);
        }

        List<WorkOrder> relatedWorkOrders = WorkOrderDAO.getWorkOrdersFromIds(workOrderQueryFields, relatedWorkOrderIds);
        List<ServiceTerritory> relatedServiceTerritories = ServiceTerritoryDAO.getServiceTerritoriesFromIds(serviceTerritoryQueryFields, serviceTerritoryIds);

        for(WorkOrder wo : relatedWorkOrders) {
            workOrderMap.put(wo.Id, wo);
        }

        for(ServiceTerritory st : relatedServiceTerritories) {
            serviceTerritoryMap.put(st.Id, st);
        }
        System.debug('workOrderMap: ' + workOrderMap);

        if(!workOrderMap.isEmpty()) {
            for(ServiceAppointment sa : serviceAppointments) {
                WorkOrder relatedWorkOrder = workOrderMap.get(sa.ParentRecordId);
                System.debug('relatedWorkOrder: ' + relatedWorkOrder);

                if(relatedWorkOrder != null) {
                    relatedWorkOrder.SAScheduledStart__c = sa.SchedStartTime;
                    relatedWorkOrder.Status = 'Assigned';

                    if(relatedWorkOrder.ServiceTerritoryId != sa.ServiceTerritoryId) {
                        relatedWorkOrder.ServiceTerritoryId = sa.ServiceTerritoryId;
                    }

                    if(relatedWorkOrder.Delivery_Type__c == 'Welcome Model' && !serviceTerritoryMap.isEmpty()) {
                        ServiceTerritory relatedServiceTerritory = serviceTerritoryMap.get(sa.ServiceTerritoryId);
                        System.debug('relatedServiceTerritory: ' + relatedServiceTerritory);

                        if(relatedServiceTerritory != null && relatedServiceTerritory.Stock__c == true) {
                            relatedWorkOrder.SAP_Plant__c = relatedServiceTerritory.Plant__c;
                            relatedWorkOrder.SAP_Storage_Location__c = relatedServiceTerritory.Warehouse__c;
                        }
                    }

                    workOrdersToUpdate.add(relatedWorkOrder);
                }
            }
        }

        return workOrdersToUpdate;
    }

    public static List<WorkOrder> blankRelatedWorkOrders(List<ServiceAppointment> serviceAppointments) {
        System.debug('----- blankRelatedWorkOrders -----');
        
        List<String> workOrderQueryFields = new List<String>{'SAScheduledStart__c', 'Status', 'Delivery_Type__c', 'SAP_Plant__c', 'SAP_Storage_Location__c', 
        'Resource__c', 'Source_Location__c'};
        List<String> assignedResourceQueryFields = new List<String>{'Id'};

        List<WorkOrder> workOrdersToUpdate = new List<WorkOrder>();
        List<ServiceAppointment> serviceAppointmentsToUpdate = new List<ServiceAppointment>();
        List<Id> relatedWorkOrderIds = new List<Id>();
        List<Id> serviceAppointmentIds = new List<Id>();
        List<Id> linkedSAIds = new List<Id>();

        Map<Id, WorkOrder> workOrderMap = new Map<Id, WorkOrder>();
        Map<Id, List<FSL__Time_Dependency__c>> SAToTimeDependencyMap = new Map<Id, List<FSL__Time_Dependency__c>>();
        Map<Id, ServiceAppointment> linkedSAMap = new Map<Id, ServiceAppointment>();

        for(ServiceAppointment sa : serviceAppointments) {
            relatedWorkOrderIds.add(sa.ParentRecordId);
            serviceAppointmentIds.add(sa.Id);
        }

        List<WorkOrder> relatedWorkOrders = WorkOrderDAO.getWorkOrdersFromIds(workOrderQueryFields, relatedWorkOrderIds);
        List<AssignedResource> relatedAssignedResources = AssignedResourceDAO.getAssignedResourcesFromSAIds(assignedResourceQueryFields, serviceAppointmentIds);

        List<FSL__Time_Dependency__c> allRelatedTimeDependencies = [SELECT Id, FSL__Service_Appointment_1__c, FSL__Service_Appointment_2__c, FSL__Dependency__c
                                                                   FROM FSL__Time_Dependency__c 
                                                                   WHERE FSL__Service_Appointment_2__c IN: serviceAppointmentIds
                                                                   OR FSL__Service_Appointment_1__c IN: serviceAppointmentIds];

        System.debug('allRelatedTimeDependencies: ' + allRelatedTimeDependencies);

        for(WorkOrder wo : relatedWorkOrders) {
            workOrderMap.put(wo.Id, wo);
        }

        for(FSL__Time_Dependency__c td : allRelatedTimeDependencies) {
            if(serviceAppointmentIds.contains(td.FSL__Service_Appointment_2__c)) {
                linkedSAIds.add(td.FSL__Service_Appointment_1__c);

                if(SAToTimeDependencyMap.get(td.FSL__Service_Appointment_2__c) == null) {
                    SAToTimeDependencyMap.put(td.FSL__Service_Appointment_2__c, new List<FSL__Time_Dependency__c>());
                }
                SAToTimeDependencyMap.get(td.FSL__Service_Appointment_2__c).add(td);
            }
            else if(serviceAppointmentIds.contains(td.FSL__Service_Appointment_1__c)) {
                linkedSAIds.add(td.FSL__Service_Appointment_2__c);

                if(SAToTimeDependencyMap.get(td.FSL__Service_Appointment_1__c) == null) {
                    SAToTimeDependencyMap.put(td.FSL__Service_Appointment_1__c, new List<FSL__Time_Dependency__c>());
                }
                SAToTimeDependencyMap.get(td.FSL__Service_Appointment_1__c).add(td);
            }
        }
        
        // Getting all the SAs related to the ones that have been canceled via Time Dependency (FSL__Service_Appointment_1__c)

        List<ServiceAppointment> linkedServiceAppointments = [SELECT Id, Status FROM ServiceAppointment WHERE Id IN: linkedSAIds];

        for(ServiceAppointment sa : linkedServiceAppointments) {
            linkedSAMap.put(sa.Id, sa);
        }

        // Blanking the related WOs and canceling the SAs related to these ones via Time Dependency

        if(!workOrderMap.isEmpty()) {
            for(ServiceAppointment sa : serviceAppointments) {
                WorkOrder relatedWorkOrder = workOrderMap.get(sa.ParentRecordId);
                List<FSL__Time_Dependency__c> relatedTimeDependencies;

                if(!SAToTimeDependencyMap.isEmpty()) {
                    relatedTimeDependencies = SAToTimeDependencyMap.get(sa.Id);
                    System.debug('relatedTimeDependencies: ' + relatedTimeDependencies);
                }

                if(relatedWorkOrder != null && relatedWorkOrder.Status == 'Assigned') {
                    relatedWorkOrder.SAScheduledStart__c = null;
                    relatedWorkOrder.Status = 'New';
                    relatedWorkOrder.Resource__c = null;
                    relatedWorkOrder.Source_Location__c = null;
                    relatedWorkOrder.SAP_Plant__c = null;
                    relatedWorkOrder.SAP_Storage_Location__c = null;

                    workOrdersToUpdate.add(relatedWorkOrder);
                }

                if(relatedTimeDependencies != null) {
                    System.debug('relatedTimeDependencies != null');
                    for(FSL__Time_Dependency__c td : relatedTimeDependencies) {
                        ServiceAppointment linkedServiceAppointment;

                        System.debug('linkedSAMap: ' + linkedSAMap);
                        if(!linkedSAMap.isEmpty()) {
                            System.debug('current SA Id: ' + sa.Id);
                            System.debug('TD.ServiceAppointment 1: ' + td.FSL__Service_Appointment_1__c);
                            System.debug('TD.ServiceAppointment 2: ' + td.FSL__Service_Appointment_2__c);

                            if(sa.Id == td.FSL__Service_Appointment_2__c) {
                                linkedServiceAppointment = linkedSAMap.get(td.FSL__Service_Appointment_1__c);
                            }
                            else if(sa.Id == td.FSL__Service_Appointment_1__c) {
                                if(td.FSL__Dependency__c == 'Same Start') {
                                    linkedServiceAppointment = linkedSAMap.get(td.FSL__Service_Appointment_2__c);
                                }
                            }

                            System.debug('linkedServiceAppointment: ' + linkedServiceAppointment);
                        }

                        if(linkedServiceAppointment != null) {
                            if(sa.Status == 'Canceled') {
                                if(linkedServiceAppointment.Status != 'Canceled') {
                                    linkedServiceAppointment.Status = 'Canceled';
                                }
                            }
                            else if(sa.Status == 'None') {
                                if(linkedServiceAppointment.Status != 'None') {
                                    linkedServiceAppointment.Status = 'None';
                                }
                            }

                            if(!serviceAppointmentsToUpdate.contains(linkedServiceAppointment)) {
                                serviceAppointmentsToUpdate.add(linkedServiceAppointment);
                            }
                        }
                    }
                }
            }
        }

        // Deleting the related Assigned Resources

        List<Database.DeleteResult> results = Database.delete(relatedAssignedResources);

        // Canceling the SAs related via Time Dependency

        System.debug('serviceAppointmentsToUpdate size: ' + serviceAppointmentsToUpdate.size());
        if(!serviceAppointmentsToUpdate.isEmpty()) {
            List<Database.SaveResult> updateResults = Database.update(serviceAppointmentsToUpdate);
        }

        return workOrdersToUpdate;
    }

    public static List<ServiceAppointment> updateServiceTerritory(List<ServiceAppointment> serviceAppointments) {
        List<String> workOrderQueryFields = new List<String>{'ServiceTerritoryId'};

        List<WorkOrder> relatedWorkOrders = new List<WorkOrder>();
        List<String> relatedWorkOrderIds = new List<String>();
        List<ServiceAppointment> toUpdate = new List<ServiceAppointment>();

        Map<String, WorkOrder> workOrderMap = new Map<String, WorkOrder>();

        for(ServiceAppointment sa : serviceAppointments) {
            relatedWorkOrderIds.add(sa.ParentRecordId);
        }

        relatedWorkOrders = WorkOrderDAO.getWorkOrdersFromIds(workOrderQueryFields, relatedWorkOrderIds);

        if(!relatedWorkOrders.isEmpty()) {
            for(WorkOrder wo : relatedWorkOrders) {
                workOrderMap.put(wo.Id, wo);
            }
        }

        if(!workOrderMap.isEmpty()) {
            for(ServiceAppointment sa : serviceAppointments) {
                WorkOrder relatedWorkOrder = workOrderMap.get(sa.ParentRecordId);

                if(relatedWorkOrder != null && relatedWorkOrder.ServiceTerritoryId != null && sa.ServiceTerritoryId == null) {
                    ServiceAppointment tmp = new ServiceAppointment();
                    tmp.Id = sa.Id;
                    tmp.ServiceTerritoryId = relatedWorkOrder.ServiceTerritoryId;

                    toUpdate.add(tmp);
                }
            }
        }

        return toUpdate;
    }

    public static List<ServiceAppointment> updateAddressFromWorkOrder(List<ServiceAppointment> serviceAppointments) {
        List<String> workOrderQueryFields = new List<String>{'Street', 'City', 'PostalCode', 'StateCode', 'CountryCode'};

        List<String> workOrderIds = new List<String>();
        List<ServiceAppointment> toUpdate = new List<ServiceAppointment>();

        Map<String, WorkOrder> workOrderMap = new Map<String, WorkOrder>();

        for(ServiceAppointment sa : serviceAppointments) {
            workOrderIds.add(sa.ParentRecordId);
        }

        List<WorkOrder> relatedWorkOrders = WorkOrderDAO.getWorkOrdersFromIds(workOrderQueryFields, workOrderIds);

        if(relatedWorkOrders != null && !relatedWorkOrders.isEmpty()) {
            for(WorkOrder wo : relatedWorkOrders) {
                workOrderMap.put(wo.Id, wo);
            }

            for(ServiceAppointment sa : serviceAppointments) {
                WorkOrder relatedWorkOrder = workOrderMap.get(sa.ParentRecordId);

                if(relatedWorkOrder != null) {
                    ServiceAppointment tmp = new ServiceAppointment();
                    Boolean hasChanged = false;

                    tmp.Id = sa.Id;

                    if(sa.Street != relatedWorkOrder.Street) {
                        tmp.Street = relatedWorkOrder.Street;

                        if(hasChanged == false) {
                            hasChanged = true;
                        }
                    }
                    if(sa.City != relatedWorkOrder.City) {
                        tmp.City = relatedWorkOrder.City;

                        if(hasChanged == false) {
                            hasChanged = true;
                        }
                    }
                    if(sa.PostalCode != relatedWorkOrder.PostalCode) {
                        tmp.PostalCode = relatedWorkOrder.PostalCode;

                        if(hasChanged == false) {
                            hasChanged = true;
                        }
                    }
                    if(sa.StateCode != relatedWorkOrder.StateCode) {
                        tmp.StateCode = relatedWorkOrder.StateCode;

                        if(hasChanged == false) {
                            hasChanged = true;
                        }
                    }
                    if(sa.CountryCode != relatedWorkOrder.CountryCode) {
                        tmp.CountryCode = relatedWorkOrder.CountryCode;

                        if(hasChanged == false) {
                            hasChanged = true;
                        }
                    }

                    if(hasChanged) {
                        toUpdate.add(tmp);
                    }
                }
            }
        }

        return toUpdate;
    }

    public static List<ServiceAppointment> updateSAOwner(List<ServiceAppointment> serviceAppointments) {
        List<String> assignedResourceQueryFields = new List<String>{'ServiceResource.RelatedRecordId', 'ServiceAppointmentId'};

        List<AssignedResource> allRelatedAssignedResources = new List<AssignedResource>();
        List<ServiceAppointment> toUpdate = new List<ServiceAppointment>();
        List<String> serviceAppointmentIds = new List<String>();

        Map<String, AssignedResource> assignedResourceMap = new Map<String, AssignedResource>();

        for(ServiceAppointment sa : serviceAPpointments) {
            serviceAppointmentIds.add(sa.Id);
        }

        allRelatedAssignedResources = AssignedResourceDAO.getAssignedResourcesFromSAIds(assignedResourceQueryFields, serviceAppointmentIds);

        if(!allRelatedAssignedResources.isEmpty()) {
            for(AssignedResource ar : allRelatedAssignedResources) {
                assignedResourceMap.put(ar.ServiceAppointmentId, ar);
            }

            for(ServiceAppointment sa : serviceAppointments) {
                ServiceAppointment tmp = new ServiceAppointment();
                tmp.Id = sa.Id;

                AssignedResource relatedAssignedResource = assignedResourceMap.get(sa.Id);

                if(relatedAssignedResource != null) {
                    tmp.OwnerId = relatedAssignedResource.ServiceResource.RelatedRecordId;

                    toUpdate.add(tmp);
                }
            }
        }

        return toUpdate;
    }

    public static void updateTreatmentTypeAndSalesOrgAndHasFrequency(List<ServiceAppointment> serviceAppointments) {
        List<String> workOrderQueryFields = new List<String>{'Treatment_Type__c', 'SalesOrganization__c', 'Account_Treatment_Job__c', 
        'Account_Treatment_Job__r.Frequency__c', 'Account_Treatment_Job__r.Frequency_Unit_of_measure__c', 'Account_Treatment_Job__r.Frequency_Type__c'};

        List<String> workOrderIds = new List<String>();
        List<WorkOrder> relatedWorkOrders = new List<WorkOrder>();

        Map<String, WorkOrder> workOrderMap = new Map<String, WorkOrder>();

        for(ServiceAppointment sa : serviceAppointments) {
            workOrderIds.add(sa.ParentRecordId);
        }

        relatedWorkOrders = WorkOrderDAO.getWorkOrdersFromIds(workOrderQueryFields, workOrderIds);

        if(!relatedWorkOrders.isEmpty()) {
            for(WorkOrder wo : relatedWorkOrders) {
                workOrderMap.put(wo.Id, wo);
            }
        }

        for(ServiceAppointment sa : serviceAppointments) {
            WorkOrder relatedWorkOrder = workOrderMap.get(sa.ParentRecordId);

            if(relatedWorkOrder != null) {
                sa.SalesOrganization__c = relatedWorkOrder.SalesOrganization__c;
                sa.TreatmentType__c = relatedWorkOrder.Treatment_Type__c;
            }
        }

        setHasFrequency(serviceAppointments, workOrderMap);
    }

    public static void setHasFrequency(List<ServiceAppointment> serviceAppointments, Map<String, WorkOrder> workOrderMap) {
        System.debug('----- setHasFrequency -----');

        for(ServiceAppointment sa : serviceAppointments) {
            WorkOrder relatedWorkOrder = workOrderMap.get(sa.ParentRecordId);
            System.debug('relatedWorkOrder: ' + relatedWorkOrder);

            if(relatedWorkOrder != null) {
                if(relatedWorkOrder.Account_Treatment_Job__c != null) {
                    if(relatedWorkOrder.Account_Treatment_Job__r.Frequency__c != null && relatedWorkOrder.Account_Treatment_Job__r.Frequency_Unit_of_measure__c != null) {
                        Decimal frequency = relatedWorkOrder.Account_Treatment_Job__r.Frequency__c;
                        String frequencyUOM = relatedWorkOrder.Account_Treatment_Job__r.Frequency_Unit_of_measure__c;
                        String frequencyType = relatedWorkOrder.Account_Treatment_Job__r.Frequency_Type__c;

                        System.debug('frequency: ' + frequency);
                        System.debug('frequencyUOM: ' + frequencyUOM);
                        System.debug('frequencyType: ' + frequencyType);

                        /* if(frequencyUOM == 'Day' || frequencyUOM == 'Week' || frequencyUOM == 'Month' ||
                        (frequencyUOM == 'Year' && frequency > 5)) {
                            sa.Has_Frequency__c = true;
                        }
                        else {
                            sa.Has_Frequency__c = false;
                        } */

                        if(frequencyType == 'NPU') {
                            if(frequencyUOM == 'Day' || frequencyUOM == 'Week' || frequencyUOM == 'Month' ||
                            (frequencyUOM == 'Year' && frequency > 5)) {
                                sa.Has_Frequency__c = true;
                            }
                            else {
                                sa.Has_Frequency__c = false;
                            }
                        }
                        else if(frequencyType == 'IB') {
                            if((frequencyUOM == 'Day' && frequency < 70) || (frequencyUOM == 'Week' && frequency < 10) || (frequencyUOM == 'Month' && frequency < 3)) {
                                sa.Has_Frequency__c = true;
                            }
                            else {
                                sa.Has_Frequency__c = false;
                            }
                        }
                        else {
                            sa.Has_Frequency__c = false;
                        }
                    }
                    else {
                        sa.Has_Frequency__c = false;
                    }
                }
                else {
                    sa.Has_Frequency__c = false;
                }
            }
            else {
                sa.Has_Frequency__c = false;
            }
        }
    }

    public static void checkForOtherSAs(List<ServiceAppointment> serviceAppointments) {
        List<String> serviceAppointmentQueryFields = new List<String>{'ParentRecordId'};

        List<String> workOrderIds = new List<String>();
        List<ServiceAppointment> allOtherSAs = new List<ServiceAppointment>();

        Map<String, List<ServiceAppointment>> workOrderToSAsMap = new Map<String, List<ServiceAppointment>>();

        for(ServiceAppointment sa : serviceAppointments) {
            if(sa.ParentRecordId != null) {
                workOrderIds.add(sa.ParentRecordId);
            }
        }

        if(!workOrderIds.isEmpty()) {
            allOtherSAs = ServiceAppointmentDAO.getNotCanceledSAsFromParentIds(serviceAppointmentQueryFields, workOrderIds);

            for(ServiceAppointment sa : allOtherSAs) {
                if(workOrderToSAsMap.get(sa.ParentRecordId) == null) {
                    workOrderToSAsMap.put(sa.ParentRecordId, new List<ServiceAppointment>());
                }
                workOrderToSAsMap.get(sa.ParentRecordId).add(sa);
            }

            for(ServiceAppointment sa : serviceAppointments) {
                List<ServiceAppointment> relatedOtherSAs = workOrderToSAsMap.get(sa.ParentRecordId);

                if(relatedOtherSAs != null && !relatedOtherSAs.isEmpty()) {
                    sa.addError(Label.ServiceAppointment_OtherSA_Exception);
                }
            }
        }
    }
}