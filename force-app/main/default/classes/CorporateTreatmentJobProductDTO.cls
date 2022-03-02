public with sharing class CorporateTreatmentJobProductDTO {
    @AuraEnabled
    public String Name { get; set; }
    @AuraEnabled
    public String Product_Code { get; set; }
    @AuraEnabled
    public String productId {get; set; }
    @AuraEnabled
    public String family_name {get; set; }
    @AuraEnabled
    public String family_code {get; set; }
    @AuraEnabled
    public String manufacturer_number {get; set; }
    @AuraEnabled
    public Boolean configured {get; set; }
    @AuraEnabled
    public String product_type {get; set; }
    @AuraEnabled
    public String selected {get; set; }
    @AuraEnabled
    public String id {get; set; }
    @AuraEnabled
    public String ok {get; set; }
    @AuraEnabled
    public String idCSS {get; set; }
    @AuraEnabled
    public Decimal min_quantity {get; set; }
    @AuraEnabled
    public Decimal max_quantity {get; set; }
    @AuraEnabled
    public String quantity_UOM {get; set; }
    @AuraEnabled
    public Decimal quantity {get; set; }
    @AuraEnabled
    public String status {get; set; }
    @AuraEnabled
    public Boolean billable {get; set; }

    public CorporateTreatmentJobProductDTO(String Id, String productId, String name, String product_code, String selected, String ok) {
        this.ok = ok;
        this.id = Id;
        this.Name = name;
        this.Product_Code = product_code;
        this.productId = productId;
        this.selected = selected;
        this.idCSS = 'slds-hidden';
        system.debug('Product ID passato alla DTO: ' + this.productId);
    }

    public CorporateTreatmentJobProductDTO(String productId, String name, String product_code, String family_name, String family_code, String manufacturer_number, String ok) {
        this.Name = name;
        this.Product_Code = product_code;
        this.id = productId;
        this.productId = productId;
        this.family_name = family_name;
        this.manufacturer_number = manufacturer_number;
        this.family_code = family_code;
    }

    public CorporateTreatmentJobProductDTO(String productId, String name, String product_code, String family_name, 
    String manufacturer_number, Boolean configured, String product_type, Decimal min_quantity, Decimal max_quantity, String quantity_UOM, Decimal quantity, 
    String status, Boolean billable) {
        this.productId = productId;
        this.Name = name;
        this.Product_Code = product_code;
        this.family_name = family_name;
        this.manufacturer_number = manufacturer_number;
        this.configured = configured;
        this.product_type = product_type;
        this.min_quantity = min_quantity;
        this.max_quantity = max_quantity;
        this.quantity_UOM = quantity_UOM;
        this.quantity = quantity;
        this.status = status;
        this.billable = billable;
    }
}