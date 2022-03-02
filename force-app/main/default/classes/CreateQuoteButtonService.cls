public class CreateQuoteButtonService {
    
    @AuraEnabled
    public static QuoteDTO getPrefilledQuote(String caseId) {
        Case c = CaseDAO.getCaseForQuote(caseId);

        QuoteDTO dtoToReturn = new QuoteDTO(
            c.AccountId, 
            c.ContactId, 
            c.Contract_Treatment__c,
            c.Account.Location__c,
            c.Contract_Treatment__r.Contract_Framework__r.Payment_Condition__c,
            c.Account.Location__r.VisitorAddress.Street,
            c.Account.Location__r.VisitorAddress.PostalCode,
            c.Account.Location__r.VisitorAddress.City,
            c.Account.Location__r.VisitorAddress.StateCode,
            c.Account.Location__r.VisitorAddress.CountryCode);
        
        return dtoToReturn;
    }

    @AuraEnabled
    public static QuoteDTO getNotPrefilledQuote(){
        
        return new QuoteDTO();
    }
}