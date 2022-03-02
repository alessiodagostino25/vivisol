public class CallOutForProductPriceDTO {
    
    public String salesOrderType { get; set; }
    @AuraEnabled
    public String salesOrganization { get; set; }
    @AuraEnabled
    public String distributionChannel { get; set; }
    @AuraEnabled
    public String accountExternalId { get; set; }
    @AuraEnabled
    public String carrier { get; set; }
    @AuraEnabled
    public String itemId { get; set; }
    @AuraEnabled
    public String contract { get; set; }
    @AuraEnabled
    public String productUnitofMeasure { get; set; }
    @AuraEnabled
    public String productCode { get; set; }
    @AuraEnabled
    public String complianceLvl { get; set; }
    @AuraEnabled
    public Decimal quantity { get; set; }
    @AuraEnabled
    public String unitOfMeasure { get; set; }

    public CallOutForProductPriceDTO(OrderItem orderItem) {
        this.salesOrderType = 'YOV0';          
        this.salesOrganization =  orderItem.Order.Account_Sales_Organization__r.Sales_Organization__r.Code__c;
        this.distributionChannel = orderItem.Order.Account_Sales_Organization__r.Distribution_Channel__c ;
        this.accountExternalId = orderItem.Order.Account_Bill_To__r.Account_External_Id__c;
        this.productCode = orderItem.Product2.Product_Code__c;
        this.quantity = orderItem.Quantity ;
        this.unitOfMeasure = orderItem.Product2.Unit_of_Measure__c;
        this.itemId =  orderItem.Id ;
        this.contract = orderItem.Order.Contract_Treatment__r.Contract_Framework__r.Contract_Number__c ;
        this.complianceLvl = null ;
    }
    
    public CallOutForProductPriceDTO(Quote_Line_Item__c quoteLineItem) {
        this.salesOrderType = 'YOV0';          
        this.salesOrganization =  quoteLineItem.Quote_Name__r.Account_Sales_Organization__r.Sales_Organization__r.Code__c;
        this.distributionChannel = quoteLineItem.Quote_Name__r.Account_Sales_Organization__r.Distribution_Channel__c ;
        this.accountExternalId = quoteLineItem.Quote_Name__r.Account_Bill_To__r.Account_External_Id__c;
        this.productCode = quoteLineItem.Product__r.Product_Code__c;
        this.quantity = quoteLineItem.Quantity__c ;
        this.unitOfMeasure = quoteLineItem.Product__r.Unit_of_Measure__c;
        this.itemId =  quoteLineItem.Id ;
        this.contract = quoteLineItem.Quote_Name__r.Contract_Treatment__r.Contract_Framework__r.Contract_Number__c;
        this.complianceLvl = null ;
    }
}