public class OrderAndQuoteService {

    @AuraEnabled
    public static OrderDTO getPrefilledOrder(String caseId) {

        Case c = CaseDAO.getCaseForOrder(caseId);

        OrderDTO dtoToReturn;

        /* if(c.Account.IsPersonAccount == true) {

            dtoToReturn = new OrderDTO(
                c.AccountId, 
                c.ContactId, 
                c.AccountId,
                c.Contract_Treatment__c,
                c.Account.Location__c,
                c.Account.Location__c,
                null,
                null,
                null, 
                null,
                c.Account.Location__r.VisitorAddress.Street,
                c.Account.Location__r.VisitorAddress.PostalCode,
                c.Account.Location__r.VisitorAddress.City,
                c.Account.Location__r.VisitorAddress.StateCode,
                c.Account.Location__r.VisitorAddress.CountryCode,
                c.Account.Location__r.VisitorAddress.Street,
                c.Account.Location__r.VisitorAddress.PostalCode,
                c.Account.Location__r.VisitorAddress.City,
                c.Account.Location__r.VisitorAddress.StateCode,
                c.Account.Location__r.VisitorAddress.CountryCode);
        }

        else if(c.Account.IsPersonAccount == false) {

            dtoToReturn = new OrderDTO(
                c.AccountId, 
                c.ContactId, 
                c.Contract_Treatment__r.Contract_Framework__r.Customer__c,
                c.Contract_Treatment__c,
                c.Account.Location__c,
                c.Contract_Treatment__r.Contract_Framework__r.Customer__r.Location__c,
                c.Contract_Treatment__r.Contract_Framework__r.Customer__r.Billing_reference__c,
                c.Contract_Treatment__r.Contract_Framework__r.Customer__r.Customer_Purchase_Order_Number__c,
                c.Contract_Treatment__r.Contract_Framework__r.Customer__r.Customer_Purchase_Order_Date__c, 
                c.Contract_Treatment__r.Contract_Framework__r.Payment_Condition__c,
                c.Account.ShippingStreet,
                c.Account.ShippingPostalCode,
                c.Account.ShippingCity,
                c.Account.ShippingStateCode,
                c.Account.ShippingCountryCode,
                c.Contract_Treatment__r.Contract_Framework__r.Customer__r.LocationStreet__c,
                c.Contract_Treatment__r.Contract_Framework__r.Customer__r.LocationPostalCode__c,
                c.Contract_Treatment__r.Contract_Framework__r.Customer__r.LocationCity__c,
                c.Contract_Treatment__r.Contract_Framework__r.Customer__r.LocationStateCode__c,
                c.Contract_Treatment__r.Contract_Framework__r.Customer__r.LocationCountryCode__c);
        } */

        dtoToReturn = new OrderDTO(c);

        System.debug('DTO: ' + dtoToReturn);
        System.debug('EffectiveDate: ' + dtoToReturn.EffectiveDate);    
        return dtoToReturn;
    }

    @AuraEnabled
    public static OrderDTO getNotPrefilledOrder(){
        
        return new OrderDTO();
    }

    // Quote

    @AuraEnabled
    public static QuoteDTO getPrefilledQuote(String caseId) {
        Case c = CaseDAO.getCaseForQuote(caseId);

        /* QuoteDTO dtoToReturn = new QuoteDTO(
            c.AccountId, 
            c.ContactId, 
            c.Contract_Treatment__c,
            c.Account.Location__c,
            c.Contract_Treatment__r.Contract_Framework__r.Payment_Condition__c,
            c.Account.Location__r.VisitorAddress.Street,
            c.Account.Location__r.VisitorAddress.PostalCode,
            c.Account.Location__r.VisitorAddress.City,
            c.Account.Location__r.VisitorAddress.StateCode,
            c.Account.Location__r.VisitorAddress.CountryCode,
            c.Contract_Treatment__r.Contract_Framework__c
        ); */

        QuoteDTO dtoToReturn = new QuoteDTO(c);
        
        return dtoToReturn;
    }

    @AuraEnabled
    public static QuoteDTO getNotPrefilledQuote(){
        
        return new QuoteDTO();
    }
}