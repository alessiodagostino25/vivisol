public with sharing class customordercalloutDTO {
    @AuraEnabled
	public Decimal NetAmount { get; set; }
	@AuraEnabled
	public Decimal VATAmount { get; set; }
	@AuraEnabled
    public Decimal Maxdiscount { get; set; }
    @AuraEnabled
	public String quantity { get; set; }
	
    
    public customordercalloutDTO() {
        this.NetAmount = 55;
        this.VATAmount = 45;
        this.Maxdiscount = 35;
  
}
}