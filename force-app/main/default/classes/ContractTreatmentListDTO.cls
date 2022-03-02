public with sharing class ContractTreatmentListDTO {
    
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String contractTreatmentExternalId;
    @AuraEnabled
    public String corporateTreatment;
    @AuraEnabled
    public String corporateTreatmentId;
    @AuraEnabled
    public Boolean active;
    @AuraEnabled
    public Boolean billable;
    @AuraEnabled
    public Date contractStartDate;
    @AuraEnabled
    public String contractFrameworkId;
    @AuraEnabled
    public Date contractEndDate;
    
    
    public ContractTreatmentListDTO(Contract_Treatment__c contractTreatment) {
        this.name = contractTreatment.Name;
        this.id = contractTreatment.Id;  
        this.contractTreatmentExternalId = contractTreatment.Contract_Treatment_ID__c;
        this.corporateTreatment = contractTreatment.Corporate_Treatment__r.Name;
        this.corporateTreatmentId = contractTreatment.Corporate_Treatment__c;
        this.billable = contractTreatment.Billable__c;
        //this.contractStartDate = PER ORA NON POPOLATO
        //this.contractEndDate = PER ORA NON POPOLATO
        this.contractFrameworkId = contractTreatment.Contract_Framework__c;
    }
}