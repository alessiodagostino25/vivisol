public class OrderAndQuoteController {

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
            toReturn = OrderAndQuoteService.getPrefilledOrder(caseId);
        }
        else {
            toReturn = OrderAndQuoteService.getNotPrefilledOrder();
        }

        return toReturn;
    }

    @AuraEnabled
    public static QuoteDTO getPrefilledQuote(String caseId) {

        //Getting the SObject of the Id passed. If it is a Case, then prefill the Quote
        Id myId = (Id) caseId;
        Schema.SObjectType sobjectType = myId.getSObjectType();
        String sobjectName = sobjectType.getDescribe().getName();
        System.debug('sobjectName: ' + sobjectName);

        QuoteDTO toReturn;
        if(sobjectName == 'Case') {
            toReturn = OrderAndQuoteService.getPrefilledQuote(caseId);
        } else {
            toReturn = OrderAndQuoteService.getNotPrefilledQuote();
        }
        
        return toReturn;
    }
}