/* *
* @author Arturo Forneris
*/
public with sharing class ContractTreatmentJobSlaDAO {

    public static List<Contract_Treatment_Job_Sla__c> getContractTreatmentJobSlaListByCTJId(String contractTreatmentJobId) {
        String query = 'SELECT Id, Name, Urgency_Level__c, IsDefault__c, Offset_Start_Date__c, Offset_End_Date__c, Max_Time__c, Calculation_Mode__c, ' +
        'Task_MaxTime_Execution__c, Unite_of_measure_Max_Time__c, Task_Calculation_Mode__c, Task_Unite_of_measure_Max_Time__c, ' +
        'Offset_unit_of_measure__c, Offset_calculation_mode__c, Offset_calculation_mode_Task__c, Offset_unit_of_measure_Task__c, Offset_Start_Date_Task__c, ' +
        'Offset_End_Date_Task__c ' + 
        'FROM Contract_Treatment_Job_Sla__c';

        query += ' WHERE Contract_Treatment_Job__c =:contractTreatmentJobId';
	
		system.debug(query);
		return Database.query(query);
    }

    public static List<Contract_Treatment_Job_SLA__c> getSLAsFromCTJs(List<String> queryFields, List<Id> CTJIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Contract_Treatment_Job_SLA__c WHERE Contract_Treatment_Job__c IN: CTJIds';
        System.debug('getSLAsFromCTJs QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Contract_Treatment_Job_SLA__c> getSLAsFromCTJs(List<String> queryFields, Set<Id> CTJIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Contract_Treatment_Job_SLA__c WHERE Contract_Treatment_Job__c IN: CTJIds';
        System.debug('getSLAsFromCTJs QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Contract_Treatment_Job_SLA__c> getSLAsFromIds(List<String> queryFields, List<Id> relatedIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Contract_Treatment_Job_SLA__c WHERE Id IN: relatedIds';
        System.debug('getSLAsFromIds QUERY: ' + query);
        
        return Database.query(query);
    }
}