public with sharing class ContractTreatmentJobProductDTO {
    @AuraEnabled
    public String Id { get; set; }
    @AuraEnabled
    public String Name { get; set; }
    @AuraEnabled
    public String Product { get; set; }
    @AuraEnabled
    public String Contract_Treatment_Job {get; set; }

    public ContractTreatmentJobProductDTO(String Id, String Name, String Product, String Contract_Treatment_Job) {
        this.Id = Id;
        this.Name = Name;
        this.Product = Product;
        this.Contract_Treatment_Job = Contract_Treatment_Job;
        system.debug('Product Name arrivato alla DTO: ' + this.Name);
    }
}