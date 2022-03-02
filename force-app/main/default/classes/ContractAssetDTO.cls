public class ContractAssetDTO {
    
    @AuraEnabled
    public String Id { get; set; }

    @AuraEnabled
    public String serialNumber { get; set; }

    @AuraEnabled
    public String contractTreatmentId { get; set; }

    @AuraEnabled
    public String manufacturerId { get; set; }

    @AuraEnabled
    public String productId { get; set; }

    @AuraEnabled
    public String productNameTranslate { get; set; }

    @AuraEnabled
    public String productFamilyNameTranslate { get; set; }

    @AuraEnabled
    public String productCode { get; set; }

    @AuraEnabled
    public String manufacturerPartNumber { get; set; }

    @AuraEnabled
    public String productName { get; set; }

    public ContractAssetDTO(String Id, String serialNumber, String contractTreatmentId, String productName) {
        this.Id = Id;
        this.serialNumber = serialNumber;
        this.contractTreatmentId = contractTreatmentId;
        this.productName = productName;
    }

    public ContractAssetDTO(Contract_Asset__c contractAsset) {
        this.Id = contractAsset.Id;
        if(contractAsset.Asset__c != null) {
            this.serialNumber = contractAsset.Asset__r.SerialNumber;
            this.manufacturerId = contractAsset.Asset__r.Manufacturer_ID__c;
            this.productId = contractAsset.Asset__r.Product2Id;

            if(contractAsset.Asset__r.Product2Id != null) {
                this.productNameTranslate = contractAsset.Asset__r.Product2.Product_Name_Translate__c;
                this.productCode = contractAsset.Asset__r.Product2.Product_Code__c;
                this.productFamilyNameTranslate = contractAsset.Asset__r.Product2.Product_Family__r.Product_Name_Translate__c;
                this.manufacturerPartNumber = contractAsset.Asset__r.Product2.Manufacturer_part_number__c;
            }
            else {
                this.productNameTranslate = null;
                this.productCode = null;
                this.productFamilyNameTranslate = null;
                this.manufacturerPartNumber = null;
            }
        }
        else {
            this.serialNumber = null;
            this.manufacturerId = null;
            this.productId = null;
            this.productNameTranslate = null;
            this.productCode = null;
            this.productFamilyNameTranslate = null;
            this.manufacturerPartNumber = null;
        } 
    }
}