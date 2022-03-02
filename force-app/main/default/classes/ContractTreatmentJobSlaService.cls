/* *
* @author Arturo Forneris
*/
public with sharing class ContractTreatmentJobSlaService {

    public static List<Contract_Treatment_Job_SLA__c> getSlaListByCTJId(String contractTreatmentJobId) {
        List<Contract_Treatment_Job_SLA__c> cTJSlaList = [SELECT Id, Name, Max_Time__c, Unite_of_measure_Max_Time__c, Calculation_Mode__c, Offset_Start_Date__c, Offset_End_Date__c, Contract_Treatment_Job__c, Task_MaxTime_Execution__c, Task_Unite_of_measure_Max_Time__c, Task_Calculation_Mode__c, Urgency_Level__c, IsDefault__c 
            FROM Contract_Treatment_Job_SLA__c 
            WHERE Contract_Treatment_Job__c =:contractTreatmentJobId];

        return cTJSlaList;
    }
}