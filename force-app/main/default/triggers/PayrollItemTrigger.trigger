trigger PayrollItemTrigger on Payroll_Item__c (before insert) {
    if(Trigger.isInsert && Trigger.isBefore) {
        // Setting Category And External Id
        PayrollItemTriggerService.setCategoryAndExternalId(Trigger.new);
    }
}