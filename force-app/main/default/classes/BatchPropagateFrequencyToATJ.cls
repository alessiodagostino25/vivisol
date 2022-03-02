/**
 * @author: Giacomo
 * @description: Questp batch viene lanciato al cambio della frequency sul contract treatment job. Il compito del batch è di trovare tutti gli Account_Treatment_Job__c
 *  ad esso collegati e propagarne la modifica. In seguito verranno eseguiti altri processi per la rimozione dei WO associati e la creazione dei nuovi WO, Task e Case.
 */

global class BatchPropagateFrequencyToATJ implements Database.Batchable<sObject>, Database.Stateful {

    global List<String> contractTreatmentJobIds = new List<String>();
    global List<Contract_Treatment_Job__c> contractTreatmentJobs = new List<Contract_Treatment_Job__c>();
    global Map<String,Decimal> contractFrequencyMap = new Map<String,Decimal>();
    global Map<String,String> contractFrequencyUoMMap = new Map<String,String>();
    global Map<String, String> contractFrequencyTypeMap = new Map<String, String>();
    global Map<String, Decimal> contractSTFMap = new Map<String, Decimal>();
    global List<Account_Treatment_Job__c> updatedAccountTreatment = new List<Account_Treatment_Job__c>();
    global Boolean isFrequencyChanged = false;
    global Boolean isFrequencyUoMChanged = false;
    global List<Account_Treatment_Job__c> maintenanceList = new List<Account_Treatment_Job__c>();
    global List<Account_Treatment_Job__c> therapyList = new List<Account_Treatment_Job__c>();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('contractTreatmentJobIds: ' + contractTreatmentJobIds);
        String statusValue = 'R';
        for (Contract_Treatment_Job__c ct : contractTreatmentJobs){
            contractFrequencyMap.put(ct.Id, ct.Frequency__c);
            contractFrequencyUoMMap.put(ct.Id, ct.Frequency_Unit_of_measure__c);
            contractFrequencyTypeMap.put(ct.Id, ct.Frequency_Type__c);
            contractSTFMap.put(ct.Id, ct.Scheduling_Time_Frame__c);
        }

        String query = 'SELECT Id, Is_Frequency_Unit_of_Measure_different_f__c, Is_Frequency_Different_from_Contract__c, Frequency__c, '
            + ' Frequency_Unit_of_measure__c, Frequency_Type__c, Contract_Treatment_Job__c, Patient_Treatment__r.RecordType.DeveloperName, ' +
            'Scheduling_Time_Frame__c FROM Account_Treatment_Job__c '
            + ' WHERE Contract_Treatment_Job__c IN :contractTreatmentJobIds AND Patient_Treatment__r.Status__c != :statusValue';

		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext bc,List<Account_Treatment_Job__c> scope) {
        List<Account_Treatment_Job__c> updateList = new List<Account_Treatment_Job__c>();

        for (Account_Treatment_Job__c atj : scope){
            if (atj.Patient_Treatment__r.RecordType.DeveloperName == 'AccountTreatment_Maintenance'){
                maintenanceList.add(atj);
            } else{
                therapyList.add(atj);
            }

            Boolean toBeUpdated = false;
            if (atj.Is_Frequency_Different_from_Contract__c == false && atj.Frequency__c != contractFrequencyMap.get(atj.Contract_Treatment_Job__c)){
                atj.Frequency__c = contractFrequencyMap.get(atj.Contract_Treatment_Job__c);
                atj.Last_Propagated_Frequency__c = contractFrequencyMap.get(atj.Contract_Treatment_Job__c);
                toBeUpdated = true;
            } 
            if (atj.Is_Frequency_Unit_of_Measure_different_f__c == false && atj.Frequency_Unit_of_measure__c != contractFrequencyUoMMap.get(atj.Contract_Treatment_Job__c)){
                atj.Frequency_Unit_of_measure__c = contractFrequencyUoMMap.get(atj.Contract_Treatment_Job__c);
                atj.Last_Propagated_Frequency_UOM__c = contractFrequencyUoMMap.get(atj.Contract_Treatment_Job__c);
                toBeUpdated = true;
            } 
            if(atj.Is_Frequency_Different_from_Contract__c == false && atj.Frequency_Type__c != contractFrequencyTypeMap.get(atj.Contract_Treatment_Job__c)) {
                atj.Frequency_Type__c = contractFrequencyTypeMap.get(atj.Contract_Treatment_Job__c);
                atj.Last_Propagated_Frequency_Type__c = contractFrequencyTypeMap.get(atj.Contract_Treatment_Job__c);
                toBeUpdated = true;
            }
            if(atj.Is_Frequency_Different_from_Contract__c == false && atj.Scheduling_Time_Frame__c != contractSTFMap.get(atj.Contract_Treatment_Job__c)) {
                atj.Scheduling_Time_Frame__c = contractSTFMap.get(atj.Contract_Treatment_Job__c);
                toBeUpdated = true;
            }
            if (toBeUpdated == true){
                updateList.add(atj);
                updatedAccountTreatment.add(atj);
            }
        }
        update updateList;
	}

	public void finish(Database.BatchableContext bc) {

        BatchPropagateFrequency_WO propagateToWO = new BatchPropagateFrequency_WO();
        propagateToWO.accTreatmentJobs = updatedAccountTreatment;
        Database.executeBatch(propagateToWO, 1);
        
	}
}