public with sharing class ContractTreatmentsDTO {
	@AuraEnabled
	public String Id { get; set; }
	@AuraEnabled
	public String Name { get; set; }
	@AuraEnabled
	public String customerPurchaseOrderNumber { get; set; }
	@AuraEnabled
	public String Customer_Name { get; set; }
	@AuraEnabled
	public String customerTreatmentAlias { get; set; }
	@AuraEnabled
	public String customerRequestCode { get; set; }
	@AuraEnabled
    public String Uzovi_code { get; set; }
    @AuraEnabled
	public Date customerPurchaseOrderDate  { get; set; }
	@AuraEnabled
	public Decimal Threshold_day  { get; set; }
	@AuraEnabled
	public Decimal Threshold_hour  { get; set; }

	public ContractTreatmentsDTO(Contract_Treatment__c contractTreatment) {
		this.Id = contractTreatment.Id;
        this.Name = contractTreatment.Name;
        this.customerPurchaseOrderDate = contractTreatment.Customer_Purchase_Order_Date__c;
		this.customerPurchaseOrderNumber = contractTreatment.Customer_Purchase_Order_Number__c;
		this.Customer_Name = contractTreatment.Customer_Name__c;
		this.customerTreatmentAlias = contractTreatment.Customer_Treatment_Alias__c;
		this.customerRequestCode = contractTreatment.Customer_Request_Code__c;
		this.Uzovi_code = contractTreatment.Contract_Framework__r.Customer__r.Uzovi_code__c;
		this.Threshold_day = contractTreatment.Threshold_day__c;
		this.Threshold_hour = contractTreatment.Threshold_hour__c;
    }	

}