trigger AssignedResourceEventTrigger on AssignedResource__e (after insert) {
    if(Trigger.isInsert && Trigger.isAfter) {
        System.debug('AssignedResourceEventTrigger AFTER INSERT');
        
        List<Id> assignedResourceIds = new List<Id>();

        for(AssignedResource__e event : Trigger.new) {
            assignedResourceIds.add(event.AssignedResourceId__c);
        }

        if(!assignedResourceIds.isEmpty()) {
            List<WorkOrder> workOrdersToUpdate = AssignedResourceTriggerService.updateRelatedWOs(assignedResourceIds);

            if(!workOrdersToUpdate.isEmpty()) {
                List<Database.SaveResult> results = Database.update(workOrdersToUpdate, false);
            }
        }
    }
}