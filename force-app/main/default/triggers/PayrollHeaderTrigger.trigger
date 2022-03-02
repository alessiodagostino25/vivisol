trigger PayrollHeaderTrigger on Payroll_Header__c (before insert) {
    if(Trigger.isInsert && Trigger.isBefore) {
        // Setting Name and Corporate_Role from Employee + External Id
        PayrollHeaderTriggerService.setNameAndCorporateRoleAndExternalId(Trigger.new);

        // Setting Budget_Item__c
        PayrollHeaderTriggerService.setBudgetItem(Trigger.new);
    }
}