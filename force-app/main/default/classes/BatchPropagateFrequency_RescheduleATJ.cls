global class BatchPropagateFrequency_RescheduleATJ implements Database.Batchable<sObject>, Database.Stateful {

    global List<String> contractTreatmentJobIds = new List<String>();
    global List<Contract_Treatment_Job__c> contractTreatmentJobs = new List<Contract_Treatment_Job__c>();
    global Map<String,Decimal> contractFrequencyMap = new Map<String,Decimal>();
    global Map<String,String> contractFrequencyUoMMap = new Map<String,String>();
    global List<Account_Treatment_Job__c> updatedAccountTreatment = new List<Account_Treatment_Job__c>();
    global Boolean isFrequencyChanged = false;
    global Boolean isFrequencyUoMChanged = false;


    global Database.QueryLocator start(Database.BatchableContext bc) {

        //TODO: rifare query --- Prendere tutti gli ATJ che sono stati precedentemente ricalibrati
        System.debug('contractTreatmentJobIds: ' + contractTreatmentJobIds);
        String statusValue = 'R';
        for (Contract_Treatment_Job__c ct : contractTreatmentJobs){
            contractFrequencyMap.put(ct.Id, ct.Frequency__c);
            contractFrequencyUoMMap.put(ct.Id, ct.Frequency_Unit_of_measure__c);
        }
        String query = 'SELECT Id, Is_Frequency_Unit_of_Measure_different_f__c, Is_Frequency_Different_from_Contract__c, Frequency__c, '
            + ' Frequency_Unit_of_measure__c, Contract_Treatment_Job__c FROM Account_Treatment_Job__c '
            + ' WHERE Contract_Treatment_Job__c IN :contractTreatmentJobIds AND Patient_Treatment__r.Status__c != :statusValue';

		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext bc,List<Account_Treatment_Job__c> scope) {


        //Maintenance -- Aggiungere IF maintenance
        //AccountTreatmentDefaultBOMHelper.autoscheduleActivitiesMaintenance();


        //Questa parte è per tutti tranne maintenance:
        AssignmentRule assignmentRule = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' and Active = true LIMIT 1];

        Map<Account_Treatment_Job__c, Contract_Treatment_Job_SLA__c> accTreatmentSLAMap = ATMainComponentService.getATJtoSLAMap(scope);

        //CREAZIONE CASE --- FATTO
        // Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions DMLOptions = new Database.DMLOptions();
        DMLOptions.assignmentRuleHeader.assignmentRuleId = assignmentRule.Id;

        List<Case> newCases = ATMainComponentService.createCases(accTreatmentSLAMap, DMLOptions, true, null);


        //CREAZIONE WO
        //defaultAddressId :  id dell'address default sull'account treatment
        String defaultAddressId = '';
        //TODO: da fare bene la query degli address (ora è solo mockata)
        List<Account_Treatment_Address__c> addresses = [SELECT id FROM Account_Treatment_Address__c WHERE Default__c = true];
        if (!addresses.isEmpty()){
            //List<WorkOrder> newWO = ATMainComponentService.createWorkOrders(accTreatmentSLAMap, newCases, String.valueOf(addresses[0].Id));
        }

        BusinessHours bh = [SELECT Id, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime,
                            ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime, SundayStartTime, SundayEndTime  
                            FROM BusinessHours WHERE Name = 'NL'];

        //TODO: aggiungere la logica seguente: se c'è un WO, mettere (.,.,., false, WO) in questo modo usa l'ultimo WO eseguito come data di partenza.
        //Altrimenti tenere il metodo attuale.
        //List<Task> newWO = ATMainComponentService.createTasks(accTreatmentSLAMap, newCases, bh, true, null);


        //Questa parte è per i maintenance
        //TODO --- Questa parte da fare

        
	}

	public void finish(Database.BatchableContext bc) {

	}
}