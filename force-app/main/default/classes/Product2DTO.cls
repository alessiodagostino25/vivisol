public class Product2DTO {
    @AuraEnabled
    public String id {get; set;}

    @AuraEnabled
    public String productFamily {get; set;}

    @AuraEnabled
    public String productNameTranslate {get; set;}

    @AuraEnabled
    public String productCode {get; set;}

    @AuraEnabled
    public String manufacturerPartNumber {get; set;}

    public Product2DTO(Product2 product) {
        this.id = product.Id;
        if(product.Product_Family__c != null) {
            this.productFamily = product.Product_Family__r.Product_Name_Translate__c;
        }
        else {
            this.productFamily = null;
        }
        this.productNameTranslate = product.Product_Name_Translate__c;
        this.productCode = product.Product_Code__c;
        this.manufacturerPartNumber = product.Manufacturer_part_number__c;
    }
}