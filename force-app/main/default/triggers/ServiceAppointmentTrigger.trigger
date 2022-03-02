trigger ServiceAppointmentTrigger on ServiceAppointment (before insert, after insert, after update) {

    if(Trigger.isBefore && Trigger.isInsert) {
        if(FeatureManagementService.getFeatureStatus('ServiceAppointment_Duplicate_Exception') || Test.isRunningTest()) {
            ServiceAppointmentTriggerService.checkForOtherSAs(Trigger.new);
        }

        ServiceAppointmentTriggerService.updateTreatmentTypeAndSalesOrgAndHasFrequency(Trigger.new);
    }

    if(Trigger.isAfter && Trigger.isInsert) {
        System.debug('SA TRIGGER IN INSERT');

        List<ServiceAppointment> toUpdateWorkOrders = new List<ServiceAppointment>();
        List<ServiceAppointment> noneServiceAppointments = new List<ServiceAppointment>();
        List<ServiceAppointment> toUpdateSAOwner = new List<ServiceAppointment>();

        // Updating Date fields and MRD (for certain SAs), then returning the workOrderMap built in the method

        Map<Id, WorkOrder> workOrderMap = ServiceAppointmentTriggerService.updateDatesAndNotMRD(Trigger.new);

        if(workOrderMap != null) {
            Map<Id, WorkOrder> SAIdToParentWOMap = new Map<Id, WorkOrder>();

            // Using the previous map to get the WorkOrder related to each ServiceAppointment...

            for(ServiceAppointment sa : Trigger.new) {
                WorkOrder relatedWorkOrder = workOrderMap.get(sa.ParentRecordId);

                // ... Then building another Map to link SA Id and the related WorkOrder

                if(relatedWorkOrder != null) {
                    SAIdToParentWOMap.put(sa.Id, relatedWorkOrder);
                }
            }

            // Calling the method to create new Time Dependencies if needed

            if(!SAIdToParentWOMap.isEmpty()) {
                List<FSL__Time_Dependency__c> newTimeDependencies = ServiceAppointmentTriggerService.createTimeDependencies(SAIdToParentWOMap);
                System.debug('newTimeDependencies size: ' + newTimeDependencies.size());
                
                if(newTimeDependencies.size() != 0) {
                    insert newTimeDependencies;
                }
            }
        }

        for(ServiceAppointment sa : Trigger.new) {
            // Launching " Email to Patient on Service Appointment" flow

            if(sa.Status == 'Dispatched') {
                //System.debug('Launching email flow for Dispatched insert');
                toUpdateSAOwner.add(sa);
                //ServiceAppointmentTriggerService.launchEmailFlow(sa.Id);
            }
            else if(sa.Status == 'Scheduled') {
                if(sa.ArrivalWindowStartTime != null && sa.ArrivalWindowEndTime != null) {
                    System.debug('Launching email flow for Scheduled insert with dates != null');
                    ServiceAppointmentTriggerService.launchEmailFlow(sa.Id);
                }
            }

            else if(sa.Status == 'None') {
                noneServiceAppointments.add(sa);
            }

            /* if(sa.Status == 'Scheduled') {
                toUpdateWorkOrders.add(sa);
            } */
        }

        // Updating Service Territory

        if(!noneServiceAppointments.isEmpty()) {
            List<ServiceAppointment> toUpdate = ServiceAppointmentTriggerService.updateServiceTerritory(noneServiceAppointments);

            if(!toUpdate.isEmpty()) {
                List<Database.SaveResult> results = Database.update(toUpdate);
            }
        }

        // Updating SA Owner

        if(!toUpdateSAOwner.isEmpty()) {
            List<ServiceAppointment> toUpdate = ServiceAppointmentTriggerService.updateSAOwner(toUpdateSAOwner);

            if(!toUpdate.isEmpty()) {
                List<Database.SaveResult> results = Database.update(toUpdate);
            }
        }

        /* if(!toUpdateWorkOrders.isEmpty()) {
            System.debug('Calling updateRelatedWorkOrders...');
            List<WorkOrder> workOrdersToUpdate = ServiceAppointmentTriggerService.updateRelatedWorkOrders(toUpdateWorkOrders);

            if(!workOrdersToUpdate.isEmpty()) {
                update workOrdersToUpdate;
            }
        } */
    }

    if(Trigger.isAfter && Trigger.isUpdate) {
        System.debug('SA TRIGGER IN UPDATE');
        List<ServiceAppointment> toUpdateWorkOrders = new List<ServiceAppointment>();
        List<ServiceAppointment> toBlankWorkOrders = new List<ServiceAppointment>();
        List<ServiceAppointment> unscheduledServiceAppointments = new List<ServiceAppointment>();
        List<ServiceAppointment> toUpdateAddress = new List<ServiceAppointment>();
        List<ServiceAppointment> toUpdateSAOwner = new List<ServiceAppointment>();

        for(ServiceAppointment sa : Trigger.new) {
            ServiceAppointment oldServiceAppointment = Trigger.oldMap.get(sa.Id);

            if(sa.Status == 'Scheduled' && sa.ArrivalWindowStartTime != null && sa.ArrivalWindowEndTime != null && 
            oldServiceAppointment.ArrivalWindowStartTime != null && oldServiceAppointment.ArrivalWindowEndTime != null && 
            (oldServiceAppointment.Status != 'Scheduled' || 
            oldServiceAppointment.ArrivalWindowStartTime != sa.ArrivalWindowStartTime || oldServiceAppointment.ArrivalWindowEndTime != sa.ArrivalWindowEndTime)) {
                System.debug('Launching email flow for Scheduled update with dates != null');

                if(sa.Status == 'Scheduled' && oldServiceAppointment.Status != 'Scheduled') {
                    System.debug('CHANGE: Status');
                }
                if(oldServiceAppointment.ArrivalWindowStartTime != sa.ArrivalWindowStartTime) {
                    System.debug('CHANGE: StartTime');
                    System.debug('oldSA.StartTime: ' + oldServiceAppointment.ArrivalWindowStartTime);
                    System.debug('SA.StartTime: ' + sa.ArrivalWindowStartTime);
                }
                if(oldServiceAppointment.ArrivalWindowEndTime != sa.ArrivalWindowEndTime) {
                    System.debug('CHANGE: EndTime');
                    System.debug('oldSA.EndTime: ' + oldServiceAppointment.ArrivalWindowEndTime);
                    System.debug('SA.EndTime: ' + sa.ArrivalWindowEndTime);
                }
                ServiceAppointmentTriggerService.launchEmailFlow(sa.Id);
            }

            if((sa.Status == 'Scheduled' && (oldServiceAppointment.Status != 'Scheduled' || oldServiceAppointment.SchedStartTime != sa.SchedStartTime))) {
                toUpdateWorkOrders.add(sa);
            }
            else if(sa.Status == 'Dispatched' && (oldServiceAppointment.SchedStartTime != sa.SchedStartTime)) {
                toUpdateWorkOrders.add(sa);
            }

            /* if((oldServiceAppointment.Status != 'Scheduled' && sa.Status == 'Scheduled') ||
            (oldServiceAppointment.SchedStartTime != sa.SchedStartTime)) {
                toUpdateWorkOrders.add(sa);
            } */

            if(oldServiceAppointment.Status != 'Dispatched' && sa.Status == 'Dispatched') {
                //System.debug('Launching email flow for Dispatched update');
                //ServiceAppointmentTriggerService.launchEmailFlow(sa.Id);
                toUpdateSAOwner.add(sa);
            }

            if(oldServiceAppointment.Status != 'Canceled' && sa.Status == 'Canceled') {
                toBlankWorkOrders.add(sa);
            }

            if(oldServiceAppointment.Status != 'None' && sa.Status == 'None') {
                unscheduledServiceAppointments.add(sa);
            }

            // Updating the Address with the Work Order's one if the ST is updated

            if(sa.Status == 'None') {
                if(oldServiceAppointment.ServiceTerritoryId != sa.ServiceTerritoryId) {
                    toUpdateAddress.add(sa);
                }
            }
        }

        if(!toUpdateWorkOrders.isEmpty()) {
            List<WorkOrder> workOrdersToUpdate = ServiceAppointmentTriggerService.updateRelatedWorkOrders(toUpdateWorkOrders);

            if(!workOrdersToUpdate.isEmpty()) {
                update workOrdersToUpdate;
            }
        }

        if(!toBlankWorkOrders.isEmpty()) {
            List<WorkOrder> workOrdersToUpdate = ServiceAppointmentTriggerService.blankRelatedWorkOrders(toBlankWorkOrders);

            if(!workOrdersToUpdate.isEmpty()) {
                update workOrdersToUpdate;
            }
        }

        if(!unscheduledServiceAppointments.isEmpty()) {
            List<WorkOrder> workOrdersToUpdate = ServiceAppointmentTriggerService.blankRelatedWorkOrders(unscheduledServiceAppointments);

            if(!workOrdersToUpdate.isEmpty()) {
                update workOrdersToUpdate;
            }
        }

        if(!toUpdateAddress.isEmpty()) {
            List<ServiceAppointment> toUpdate = ServiceAppointmentTriggerService.updateAddressFromWorkOrder(toUpdateAddress);

            if(!toUpdate.isEmpty()) {
                List<Database.SaveResult> results = Database.update(toUpdate);
            }
        }

        // Updating SA Owner

        if(!toUpdateSAOwner.isEmpty()) {
            List<ServiceAppointment> toUpdate = ServiceAppointmentTriggerService.updateSAOwner(toUpdateSAOwner);

            if(!toUpdate.isEmpty()) {
                List<Database.SaveResult> results = Database.update(toUpdate);
            }
        }
    }
}