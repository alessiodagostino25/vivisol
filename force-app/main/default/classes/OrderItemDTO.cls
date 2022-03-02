public with sharing class OrderItemDTO {
  
    @AuraEnabled
    public String Id { get; set; }
	@AuraEnabled
	public String Product_Name_Translate { get; set; }
	@AuraEnabled
	public String Product_Code { get; set; }
	@AuraEnabled
    public Decimal Quantity { get; set; }
	@AuraEnabled
    public Decimal Box { get; set; }
    @AuraEnabled
    public String ProductUnitofMeasure { get; set; }
    @AuraEnabled
    public String Description { get; set; }
    @AuraEnabled
    public String Name { get; set; }
 
    
    public OrderItemDTO(String Id, String Product_Name_Translate, String Product_Code, Decimal Quantity, String ProductUnitofMeasure,Decimal Box,String Description) {
        this.Id = Id;
        this.Name = Product_Name_Translate + '-'+ Product_Code;
        this.Quantity = Quantity ;
		this.ProductUnitofMeasure = ProductUnitofMeasure;
        this.Box = Box;
        this.Description = Description;
        this.Product_Code = Product_Code ;	
    }
    
}