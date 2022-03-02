public class CreateQuoteButtonController {
    @AuraEnabled
    public static QuoteDTO getPrefilledQuote(String caseId) {

        //Getting the SObject of the Id passed. If it is a Case, then prefill the Order

        Id myId = (Id) caseId;
        Schema.SObjectType sobjectType = myId.getSObjectType();
        String sobjectName = sobjectType.getDescribe().getName();
        System.debug('sobjectName: ' + sobjectName);

        QuoteDTO toReturn;
        if(sobjectName == 'Case') {
            toReturn = CreateQuoteButtonService.getPrefilledQuote(caseId);
        }
        else {
            toReturn = CreateQuoteButtonService.getNotPrefilledQuote();
        }
        
        return toReturn;
    }
}