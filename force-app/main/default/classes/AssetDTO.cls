public class AssetDTO {
    @AuraEnabled
    public String Id { get; set; }

    @AuraEnabled
    public String serialNumber { get; set; }

    @AuraEnabled
    public String manufacturerId { get; set; }

    @AuraEnabled
    public String productName { get; set; }

    @AuraEnabled
    public String productCode { get; set; }

    @AuraEnabled
    public String manufacturerPartNumber { get; set; }

    @AuraEnabled
    public String familyName { get; set; }

    public AssetDTO(String Id, String serialNumber, String manufacturerId, String productName, String productCode, String manufacturerPartNumber, String familyName) {
        this.Id = Id;
        this.serialNumber = serialNumber;
        this.manufacturerId = manufacturerId;
        this.productName = productName;
        this.productCode = productCode;
        this.manufacturerPartNumber = manufacturerPartNumber;
        this.familyName = familyName;
    }
}