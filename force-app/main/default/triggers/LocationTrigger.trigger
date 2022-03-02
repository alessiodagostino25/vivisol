trigger LocationTrigger on Location (before update) {
    if(Trigger.isBefore && Trigger.isUpdate) {
        LocationService.setIsPortalSync(Trigger.new, Trigger.oldMap);
    }
}