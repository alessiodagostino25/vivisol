trigger ProductRequestLineItemTrigger on ProductRequestLineItem (before insert, before update) {

    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        RecordType extraLoading = [SELECT Id FROM RecordType WHERE DeveloperName = 'ProductRequestLineItem_ExtraLoading'];

        for(ProductRequestLineItem prli : Trigger.new) {
            if(prli.RecordTypeId == extraLoading.Id && prli.Availability__c == 'Available' && prli.Loaded_Quantity__c == null) {
                prli.Loaded_Quantity__c = prli.QuantityRequested;
            }
        }
    }
}