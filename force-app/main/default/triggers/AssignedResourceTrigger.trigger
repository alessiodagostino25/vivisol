trigger AssignedResourceTrigger on AssignedResource (after insert, after update) {

    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        //List<String> toAlignRelatedWOIds = new List<String>();
        List<AssignedResource> toAlignRelatedWOs = new List<AssignedResource>();

        if(Trigger.isUpdate) {
            for(AssignedResource ar : Trigger.new) {
                if(Trigger.oldMap.get(ar.Id).ServiceResourceId != ar.ServiceResourceId) {
                    //toAlignRelatedWOIds.add(ar.Id);
                    toAlignRelatedWOs.add(ar);
                }
            }
        }
        else if(Trigger.isInsert) {
            for(AssignedResource ar : Trigger.new) {
                //toAlignRelatedWOIds.add(ar.Id);
                toAlignRelatedWOs.add(ar);
            }
        }

        /* if(!toAlignRelatedWOIds.isEmpty()) {
            AssignedResourceTriggerService.futureAssignedResourceHandling(toAlignRelatedWOIds);
        } */

        if(!toAlignRelatedWOs.isEmpty()) {
            List<AssignedResource__e> events = AssignedResourceTriggerService.createAssignedResourceEvents(toAlignRelatedWOs);

            if(!events.isEmpty()) {
                System.debug('Publishing events...');
                List<Database.SaveResult> results = Eventbus.publish(events);
            }
        }
    }
}