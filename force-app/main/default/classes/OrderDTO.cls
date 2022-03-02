public class OrderDTO {
    @AuraEnabled
    public Id AccountId { get; set; }
    @AuraEnabled
    public Id ShipToContactId { get; set; }
    @AuraEnabled
    public Id AccountSoldTo { get; set; }
    @AuraEnabled
    public Id AccountBillTo { get; set; }
    @AuraEnabled
    public Id Payer { get; set; }
    @AuraEnabled
    public Id ContractTreatment { get; set; }
    @AuraEnabled
    public Id ShippingAddress { get; set; }
    @AuraEnabled
    public Id BillingAddress { get; set; }
    @AuraEnabled
    public String CustomerRequestCode { get; set; }
    @AuraEnabled
    public String CustomerPON { get; set; }
    @AuraEnabled
    public Date CustomerPOD { get; set; }
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
    public String BillingStreet { get; set; }
    @AuraEnabled
    public String BillingPostalCode { get; set; }
    @AuraEnabled
    public String BillingCity { get; set; }
    @AuraEnabled
    public String BillingStateCode { get; set; }
    @AuraEnabled
    public String BillingCountryCode { get; set; }
    @AuraEnabled
    public Date EffectiveDate{ get; set; }
    

    public OrderDTO(Id AccountId, Id ContactId, Id Customer, Id ContractTreatment,
    Id AccountLocation, Id CustomerLocation, String CustomerBR, String CustomerPON,
    Date CustomerPOD, String PaymentCondition, String ShippingStreet, String ShippingPostalCode,
    String ShippingCity, String ShippingStateCode, String ShippingCountryCode, String CustomerSS,
    String CustomerSPC, String CustomerSC, String CustomerSSC, String CustomerSCC) {
        
        this.AccountId = AccountId;
        this.ShipToContactId = ContactId;
        this.AccountSoldTo = Customer;
        this.ContractTreatment = ContractTreatment;
        this.ShippingAddress = AccountLocation;
        this.BillingAddress = CustomerLocation;
        this.CustomerRequestCode = CustomerBR;
        this.CustomerPON = CustomerPON;
        this.CustomerPOD = CustomerPOD;
        this.PaymentTerms = PaymentCondition;
        this.ShippingStreet = ShippingStreet;
        this.ShippingPostalCode = ShippingPostalCode;
        this.ShippingCity = ShippingCity;
        this.ShippingStateCode = ShippingStateCode;
        this.ShippingCountryCode = ShippingCountryCode;
        this.BillingStreet = CustomerSS;
        this.BillingPostalCode = CustomerSPC;
        this.BillingCity = CustomerSC;
        this.BillingStateCode = CustomerSSC;
        this.BillingCountryCode = CustomerSCC;
        this.EffectiveDate = Date.today();

    }

    public OrderDTO() {

        this.AccountId = null;
        this.ShipToContactId = null;
        this.AccountSoldTo = null;
        this.ContractTreatment = null;
        this.ShippingAddress = null;
        this.BillingAddress = null;
        this.CustomerRequestCode = null;
        this.CustomerPON = null;
        this.CustomerPOD = null;
        this.PaymentTerms = null;
        this.ShippingStreet = null;
        this.ShippingPostalCode = null;
        this.ShippingCity = null;
        this.ShippingStateCode = null;
        this.ShippingCountryCode = null;
        this.BillingStreet = null;
        this.BillingPostalCode = null;
        this.BillingCity = null;
        this.BillingStateCode = null;
        this.BillingCountryCode = null;
        this.EffectiveDate = null;
    }

    public OrderDTO(Case relatedCase) {
        this.AccountId = relatedCase.AccountId;
        this.ShipToContactId = relatedCase.Account.PersonContactId;

        if(relatedCase.Contract_Treatment__c != null) {
            this.AccountSoldTo = relatedCase.Contract_Treatment__r.Contract_Framework__r.Customer__c;
            this.AccountBillTo = relatedCase.Contract_Treatment__r.Contract_Framework__r.Customer__c;
            this.Payer = relatedCase.Contract_Treatment__r.Contract_Framework__r.Customer__c;
        }
        else {
            this.AccountSoldTo = relatedCase.AccountId;
            this.AccountBillTo = relatedCase.AccountId;
            this.Payer = relatedCase.AccountId;
        }

        if(relatedCase.Account.IsPersonAccount == true) {
            this.ContractTreatment = relatedCase.Contract_Treatment__c;
            this.ShippingAddress = relatedCase.Account.Location__c;
            this.BillingAddress = relatedCase.Account.Location__c;
            this.CustomerRequestCode = null;
            this.CustomerPON = null;
            this.CustomerPOD = null;
            this.PaymentTerms = null;
            this.ShippingStreet = relatedCase.Account.Location__r.VisitorAddress.Street;
            this.ShippingPostalCode = relatedCase.Account.Location__r.VisitorAddress.PostalCode;
            this.ShippingCity = relatedCase.Account.Location__r.VisitorAddress.City;
            this.ShippingStateCode = relatedCase.Account.Location__r.VisitorAddress.StateCode;
            this.ShippingCountryCode = relatedCase.Account.Location__r.VisitorAddress.CountryCode;
            this.BillingStreet = relatedCase.Account.Location__r.VisitorAddress.Street;
            this.BillingPostalCode = relatedCase.Account.Location__r.VisitorAddress.PostalCode;
            this.BillingCity = relatedCase.Account.Location__r.VisitorAddress.City;
            this.BillingStateCode = relatedCase.Account.Location__r.VisitorAddress.StateCode;
            this.BillingCountryCode = relatedCase.Account.Location__r.VisitorAddress.CountryCode;
            this.EffectiveDate = Date.today();
        }
        else {
            this.ContractTreatment = relatedCase.Contract_Treatment__c;
            this.ShippingAddress = relatedCase.Account.Location__c;
            this.BillingAddress = relatedCase.Contract_Treatment__r.Contract_Framework__r.Customer__r.Location__c;
            this.CustomerRequestCode = relatedCase.Contract_Treatment__r.Contract_Framework__r.Customer__r.Billing_reference__c;
            this.CustomerPON = relatedCase.Contract_Treatment__r.Contract_Framework__r.Customer__r.Customer_Purchase_Order_Number__c;
            this.CustomerPOD = relatedCase.Contract_Treatment__r.Contract_Framework__r.Customer__r.Customer_Purchase_Order_Date__c;
            this.PaymentTerms = relatedCase.Contract_Treatment__r.Contract_Framework__r.Payment_Condition__c;
            this.ShippingStreet = relatedCase.Account.ShippingStreet;
            this.ShippingPostalCode = relatedCase.Account.ShippingPostalCode;
            this.ShippingCity = relatedCase.Account.ShippingCity;
            this.ShippingStateCode = relatedCase.Account.ShippingStateCode;
            this.ShippingCountryCode = relatedCase.Account.ShippingCountryCode;
            this.BillingStreet = relatedCase.Contract_Treatment__r.Contract_Framework__r.Customer__r.LocationStreet__c;
            this.BillingPostalCode = relatedCase.Contract_Treatment__r.Contract_Framework__r.Customer__r.LocationPostalCode__c;
            this.BillingCity = relatedCase.Contract_Treatment__r.Contract_Framework__r.Customer__r.LocationCity__c;
            this.BillingStateCode = relatedCase.Contract_Treatment__r.Contract_Framework__r.Customer__r.LocationStateCode__c;
            this.BillingCountryCode = relatedCase.Contract_Treatment__r.Contract_Framework__r.Customer__r.LocationCountryCode__c;
            this.EffectiveDate = Date.today();
        }
    }
}