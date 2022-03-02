public class AccountTreatmentListDTO {
    
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String status;
    @AuraEnabled
    public Date activationDate;
    @AuraEnabled
    public String treatmentType;
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String treatment;
    @AuraEnabled
    public String contractTreatment;

    public AccountTreatmentListDTO(Account_Treatment__c treatment){
        this.name = treatment.Name;
        this.status = treatment.Status__c;
        this.activationDate = treatment.Activation_Date__c;
        this.treatmentType = treatment.Treatment_Type__c;
        this.id = treatment.Id;   
        this.treatment = treatment.Treatment__c;
        this.contractTreatment = treatment.Contract_Treatment__c;
    }
    
}