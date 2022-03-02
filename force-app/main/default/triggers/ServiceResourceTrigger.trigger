trigger ServiceResourceTrigger on ServiceResource (before insert, before update) {

    if(Trigger.isInsert && Trigger.isBefore) {
        System.debug('----- ServiceResourceTrigger in BEFORE INSERT -----');

        List<ServiceResource> toValidate = new List<ServiceResource>();

        for(ServiceResource sr : Trigger.new) {
            if(sr.NextLocation__c != null) {
                toValidate.add(sr);
            }
        }

        System.debug('toValidate INSERT: ' + toValidate);

        if(!toValidate.isEmpty()) {
            ServiceResourceTriggerService.validateServiceResources(toValidate);
        }
    }

    if(Trigger.isUpdate && Trigger.isBefore) {
        System.debug('----- ServiceResourceTrigger in BEFORE UPDATE -----');

        List<ServiceResource> toValidate = new List<ServiceResource>();

        for(ServiceResource sr : Trigger.new) {
            if(sr.NextLocation__c != null && (Trigger.oldMap.get(sr.Id).NextLocation__c != sr.NextLocation__c)) {
                toValidate.add(sr);
            }
        }

        System.debug('toValidate UPDATE: ' + toValidate);
        
        if(!toValidate.isEmpty()) {
            ServiceResourceTriggerService.validateServiceResources(toValidate);
        }
    }
}