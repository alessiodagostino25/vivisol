public with sharing class ProductLimitDTO {
    @AuraEnabled
    public String Id { get; set; }
    @AuraEnabled
    public String Name { get; set; }
    @AuraEnabled
    public String ContractTreatment { get; set; }
    @AuraEnabled
    public Integer Frequency {get; set; }
    @AuraEnabled
    public String FrequencyUnitMeasure {get; set; }
    @AuraEnabled
    public Integer MaxQuantity {get; set; }
    @AuraEnabled
    public Integer MinQuantity {get; set; }
    @AuraEnabled
    public String Product {get; set; }
    @AuraEnabled
    public String ProductName {get; set; }
    @AuraEnabled
    public String QuantityUnitMeasure {get; set; }
    @AuraEnabled
    public String Status {get; set; }
    @AuraEnabled
    public Boolean Configured{get; set; }
    @AuraEnabled
    public String ProductCode{get; set; }

    public ProductLimitDTO(String Id, String Name, String ContractTreatment, Integer Frequency, String FrequencyUnitMeasure, Integer MaxQuantity, 
    Integer MinQuantity, String Product, String ProductName, String ProductCode, String QuantityUnitMeasure, String Status, Boolean Configured) {
        this.Id = Id;
        this.Name = ProductName; //Name of limit = name of product
        this.ContractTreatment = ContractTreatment;
        this.Frequency = Frequency;
        this.FrequencyUnitMeasure = FrequencyUnitMeasure;
        this.MaxQuantity = MaxQuantity;
        this.MinQuantity = MinQuantity;
        this.Product = Product;
        this.ProductName = ProductName;
        this.QuantityUnitMeasure = QuantityUnitMeasure;
        this.Status = Status;
        this.Configured = Configured;
        this.ProductCode = ProductCode;
        system.debug('Product Name arrivato alla DTO: ' + this.Name);
    }
}