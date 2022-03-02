public class PricebookEntryDTO {

    @AuraEnabled
    public String Id { get; set; }
    @AuraEnabled
	public String Product2Id { get; set; }
	@AuraEnabled
	public String Product_Name_Translate { get; set; }
	@AuraEnabled
	public String Product_Code { get; set; }
	@AuraEnabled
	public String Product_Family { get; set; }
	@AuraEnabled
    public String Manufacturer_part_number { get; set; }
    @AuraEnabled 
    public boolean isChecked {get;set;}
    
    public PricebookEntryDTO(String Id,String Product2Id, String Product_Name_Translate, String Product_Code, String Product_Family, String Manufacturer_part_number,Boolean isChecked) {
        this.Id = Id;
        this.Product2Id = Product2Id ;
        this.Product_Name_Translate = Product_Name_Translate;
        this.Product_Code = Product_Code ;
		this.Product_Family = Product_Family;
        this.Manufacturer_part_number = Manufacturer_part_number;
        this.isChecked = isChecked;
    }
}