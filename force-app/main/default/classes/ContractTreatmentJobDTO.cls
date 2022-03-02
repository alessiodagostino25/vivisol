/* *
* @author Arturo Forneris
*/
public with sharing class ContractTreatmentJobDTO {

    @AuraEnabled
	public String Id { get; set; }
	@AuraEnabled
    public String Name { get; set; }
    @AuraEnabled
    public String Contract_Treatment { get; set; }
    @AuraEnabled
    public Boolean Billable { get; set; }
    @AuraEnabled
    public Integer Frequency { get; set; }
    @AuraEnabled
    public String Frequency_Unit_of_measure { get; set; }
    @AuraEnabled
    public Integer Quantity { get; set; }
    @AuraEnabled
    public Boolean Work_Order { get; set; }
    @AuraEnabled
    public Boolean Task { get; set; }
    @AuraEnabled
    public String Work_Type { get; set; }
    @AuraEnabled
    public String Corporate_Treatment_Job { get; set; }
    @AuraEnabled
    public String Contract_Treatment_Job_Code { get; set; }
    @AuraEnabled
    public String Delivery_Channel { get; set; }
    @AuraEnabled
    public String Case_Type { get; set; }
    @AuraEnabled
    public String Line_Number { get; set; }
    @AuraEnabled
    public String Customer_Product_Code { get; set; }
    @AuraEnabled
    public String Invoice_Splitting_group { get; set; }
    @AuraEnabled
    public String Scheduling_Rule { get; set; }
    @AuraEnabled
    public String workTypeName {get; set;}
    @AuraEnabled
    public String contractTreatmentName {get; set;}
    @auraEnabled
    public Decimal frequencyDecimal {get; set;}


    public ContractTreatmentJobDTO(String Id, String Name, String Contract_Treatment, Boolean Billable, Integer Frequency, String Frequency_Unit_of_measure, Integer Quantity, Boolean Work_Order, Boolean Task, String Work_Type, String Corporate_Treatment_Job, String Contract_Treatment_Job_Code, String Delivery_Channel, String Case_Type, String Line_Number, String Customer_Product_Code, String Invoice_Splitting_group, String Scheduling_Rule) {
        this.Id = Id;
        this.Name = Name;
        this.Contract_Treatment = Contract_Treatment;
        this.Billable = Billable;
        this.Frequency = Frequency;
        this.Frequency_Unit_of_measure = Frequency_Unit_of_measure;
        this.Quantity = Quantity;
        this.Work_Order = Work_Order;
        this.Task = Task;
        this.Work_Type = Work_Type;
        this.Corporate_Treatment_Job = Corporate_Treatment_Job;
        this.Contract_Treatment_Job_Code = Contract_Treatment_Job_Code;
        this.Delivery_Channel = Delivery_Channel;
        this.Case_Type = Case_Type;
        this.Line_Number = Line_Number;
        this.Customer_Product_Code = Customer_Product_Code;
        this.Invoice_Splitting_group = Invoice_Splitting_group;
        this.Scheduling_Rule = Scheduling_Rule;
    }

    public ContractTreatmentJobDTO(Contract_Treatment_Job__c CTJ) {
        this.workTypeName = CTJ.Work_Type__r.Name;
        this.contractTreatmentName = CTJ.Contract_Treatment__r.Name;
        this.Id = CTJ.Id;
        this.Name = CTJ.Name;
        this.frequencyDecimal = CTJ.Frequency__c;
        this.Frequency_Unit_of_measure = CTJ.Frequency_Unit_of_measure__c;
        this.Work_Order = CTJ.Work_Order__c;
        this.Task = CTJ.Task__c;
        this.Scheduling_Rule = CTJ.Scheduling_Rule__c;
        this.Work_Type = CTJ.Work_Type__c;
        this.Case_Type = CTJ.Case_Type__c;
    }
}