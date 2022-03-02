public class SAPQuoteLineItemDTO {
	@AuraEnabled
    public Decimal NetAmount { get; set; }
    @AuraEnabled
    public Decimal VatAmount { get; set; }
	@AuraEnabled
    public Decimal MaxDiscount { get; set; }

  

    public SAPQuoteLineItemDTO(){
        
    }
    
    public SAPQuoteLineItemDTO(Decimal NetAmount, Decimal VatAmount, Decimal MaxDiscount) {
        this.NetAmount = NetAmount;
        this.VatAmount = VatAmount;
        this.MaxDiscount = MaxDiscount;
    }
}