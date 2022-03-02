public class ContractTreatmentModalityDTO {
    @AuraEnabled
    public String id { get; set; }

	@AuraEnabled
	public String treatmentType { get; set; }

	@AuraEnabled
	public String subTreatment { get; set; }

	@AuraEnabled
    public String installationType { get; set; }

	@AuraEnabled
    public String treatment { get; set; }

    @AuraEnabled
    public String contractTreatment { get; set; }

    @AuraEnabled
    public String status { get; set; }

    @AuraEnabled
    public String rebate { get; set; }
 
    public ContractTreatmentModalityDTO(Contract_Treatment_Modality__c ctm) {
        this.id = ctm.Id;
        this.treatmentType = ctm.Treatment_Type__c;
        this.subTreatment = ctm.Sub_Treatment__c;
        this.installationType = ctm.Installation_Type__c;
        this.treatment = ctm.Treatment__c;
        this.contractTreatment = ctm.Contract_Treatment__c;
        this.status = ctm.Status__c;
        this.rebate = ctm.Rebate__c;
    }
}