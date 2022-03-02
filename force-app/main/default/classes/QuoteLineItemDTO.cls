public class QuoteLineItemDTO {
    @AuraEnabled
    public String id { get; set; }

    @AuraEnabled
    public String name { get; set; }

    @AuraEnabled
    public String productId { get; set; }

    @AuraEnabled
    public String productNameTranslate { get; set; }

    @AuraEnabled
    public String productCode { get; set; }

    @AuraEnabled
    public String productUOM { get; set; }

    @AuraEnabled
    public Decimal quantity { get; set; }

	@AuraEnabled
    public Decimal box { get; set; }

    @AuraEnabled
    public String description { get; set; }

    @AuraEnabled
    public Decimal discount { get; set; }

    @AuraEnabled
    public String discountType { get; set; }

    @AuraEnabled
    public Boolean hasDiscountType { get; set; }
    
    public QuoteLineItemDTO(Quote_Line_Item__c quoteLineItem) {
        this.id = quoteLineItem.Id;
        this.name = quoteLineItem.Name;
        this.productId = quoteLineItem.Product__c;
        this.productNameTranslate = quoteLineItem.Product__r.Product_Name_Translate__c;
        this.productCode = quoteLineItem.Product__r.Product_Code__c;
        this.productUOM = quoteLineItem.Product__r.Unit_of_measure__c;
        this.quantity = quoteLineItem.Quantity__c;
        this.box = quoteLineItem.Box__c;
        this.description = quoteLineItem.Description__c;
        this.discount = quoteLineItem.Discount__c;
        this.discountType = quoteLineItem.DiscountType__c;

        if(this.discountType != null) {
            this.hasDiscountType = true;
        }
        else {
            this.hasDiscountType = false;
        }
    }
}