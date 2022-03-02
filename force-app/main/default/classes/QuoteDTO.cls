public class QuoteDTO {
    @AuraEnabled
    public Id AccountName { get; set; }
    @AuraEnabled
    public Id Contact { get; set; }
    @AuraEnabled
    public Id AccountSoldTo { get; set; }
    @AuraEnabled
    public Id AccountBillTo { get; set; }
    @AuraEnabled
    public Id Payer { get; set; }
    @AuraEnabled
    public Id ContractTreatment { get; set; }
    @AuraEnabled
    public Id Location { get; set; }
    @AuraEnabled
    public String PaymentTerms { get; set; }
    @AuraEnabled
    public String ShippingStreet { get; set; }
    @AuraEnabled
    public String ShippingPostalCode { get; set; }
    @AuraEnabled
    public String ShippingCity { get; set; }
    @AuraEnabled
    public String ShippingStateCode { get; set; }
    @AuraEnabled
    public String ShippingCountryCode { get; set; }
    @AuraEnabled
    public Id ContractFramework { get; set; }
    
    
    public QuoteDTO(Case relatedCase) {
        this.AccountName = relatedCase.AccountId;
        this.Contact = relatedCase.Account.PersonContactId;

        if(relatedCase.Contract_Treatment__c != null) {
            this.AccountSoldTo = relatedCase.Contract_treatment__r.Contract_Framework__r.Customer__c;
            this.AccountBillTo = relatedCase.Contract_treatment__r.Contract_Framework__r.Customer__c;
            this.Payer = relatedCase.Contract_treatment__r.Contract_Framework__r.Customer__c;
        }
        else {
            this.AccountSoldTo = relatedCase.AccountId;
            this.AccountBillTo = relatedCase.AccountId;
            this.Payer = relatedCase.AccountId;
        }

        this.ContractTreatment = relatedCase.Contract_Treatment__c;
        this.Location = relatedCase.Account.Location__c;
        this.PaymentTerms = relatedCase.Contract_Treatment__r.Contract_Framework__r.Payment_Condition__c;
        this.ShippingStreet = relatedCase.Account.Location__r.VisitorAddress.Street;
        this.ShippingPostalCode = relatedCase.Account.Location__r.VisitorAddress.PostalCode;
        this.ShippingCity = relatedCase.Account.Location__r.VisitorAddress.City;
        this.ShippingStateCode = relatedCase.Account.Location__r.VisitorAddress.StateCode;
        this.ShippingCountryCode = relatedCase.Account.Location__r.VisitorAddress.CountryCode;
        this.ContractFramework = relatedCase.Contract_Treatment__r.Contract_Framework__c;

    }

    public QuoteDTO(Id AccountId, Id ContactId, Id ContractTreatment,
    Id AccountLocation, String PaymentCondition, String ShippingStreet, String ShippingPostalCode,
    String ShippingCity, String ShippingStateCode, String ShippingCountryCode) {
        
        this.AccountName = AccountId;
        this.Contact = ContactId;
        this.ContractTreatment = ContractTreatment;
        this.Location = AccountLocation;
        this.PaymentTerms = PaymentCondition;
        this.ShippingStreet = ShippingStreet;
        this.ShippingPostalCode = ShippingPostalCode;
        this.ShippingCity = ShippingCity;
        this.ShippingStateCode = ShippingStateCode;
        this.ShippingCountryCode = ShippingCountryCode;
    }

    public QuoteDTO() {

        this.AccountName = null;
        this.Contact = null;
        this.ContractTreatment = null;
        this.Location = null;
        this.PaymentTerms = null;
        this.ShippingStreet = null;
        this.ShippingPostalCode = null;
        this.ShippingCity = null;
        this.ShippingStateCode = null;
        this.ShippingCountryCode = null;
        this.ContractFramework = null;
    }
}