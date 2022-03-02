public class ProductTypeDTO {
    
    @AuraEnabled
    public String label { get; set; }
    
    @AuraEnabled
    public String value { get; set; }

    public ProductTypeDTO(String l, String v) {
        this.label = l;
        this.value = v;
    }
}