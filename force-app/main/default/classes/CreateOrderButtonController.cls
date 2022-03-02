public class CreateOrderButtonController {
    @AuraEnabled
    public static OrderDTO getPrefilledOrder(String caseId) {

        //Getting the SObject of the Id passed. If it is a Case, then prefill the Order

        Id myId = (Id) caseId;
        System.debug('String caseId: ' + caseId);
        Schema.SObjectType sobjectType = myId.getSObjectType();
        String sobjectName = sobjectType.getDescribe().getName();
        System.debug('sobjectName: ' + sobjectName);

        OrderDTO toReturn;
        if(sobjectName == 'Case') {
            toReturn = CreateOrderButtonService.getPrefilledOrder(caseId);
        }
        else {
            toReturn = CreateOrderButtonService.getNotPrefilledOrder();
        }

        return toReturn;
    }
}