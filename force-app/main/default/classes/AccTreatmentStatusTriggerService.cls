public class AccTreatmentStatusTriggerService {
     
    public static void onInsert(List<Account_Treatment_Status__c> statusListFromTrigger){
        System.debug('ACCOUNT TREATMENT STATUS TRIGGER ON INSERT.');
        List <String> statusids = new List<String>();
        List <String> patientTreatmentList = new List<String>();
        //Ciclo trigger.new aggiungendo campi alle liste precedentemente create
        for(Account_Treatment_Status__c status : statusListFromTrigger){
            statusids.add(status.Id);
            patientTreatmentList.add(status.Patient_Treatment__c);
        }
       
        //Creo una lista contenente tutti i record che hanno gli ID diversi da quelli della lista Trigger.New e il campo Patient_Treatment equivalente a quelli della lista Trigger.New
        /* List<Account_Treatment_Status__c> oldRecordsList = [SELECT id, EndDate__c, Status__c, Patient_Treatment__c FROM Account_Treatment_Status__c WHERE id not in:  statusids
             AND Patient_Treatment__c in: patientTreatmentList AND EndDate__c = null]; */

        //Creo una mappa "temporanea" per evitare un doppio ciclo for. Nella mappa inserisco tutti i record della lista oldRecordsList
        /* Map<String, Account_Treatment_Status__c> temporaryOldRecordMap = new Map<String, Account_Treatment_Status__c>();
        if(!oldRecordsList.isEmpty()){
            for(Account_Treatment_Status__c oldstatus : oldRecordsList){
                temporaryOldRecordMap.put(oldstatus.Patient_Treatment__c, oldstatus);
            }
        } */
        
        //Creo una mappa che dovrà conenere tutti i vecchi record.
        //Map<Id, Account_Treatment_Status__c> oldStatusMap = new Map<Id, Account_Treatment_Status__c>();
       
        //Popolo la mappa scorrendo la lista trigger.new
        /* if(!temporaryOldRecordMap.isEmpty()){
            for(Account_Treatment_Status__c newstatus : statusListFromTrigger){
                //Trovato un record Account_Treatment_Status__c che ha lo stesso valore nel campo Patient_Treatment__c di quello di Trigger.new faccio l'inserimento nella mappa
                if(temporaryOldRecordMap.containsKey(newstatus.Patient_Treatment__c)){
                    oldStatusMap.put(newstatus.Id, temporaryOldRecordMap.get(newstatus.Patient_Treatment__c));
                }
            }
        } */
        
        // Creo una lista con tutti gli Account_Treatment__c che hanno l'Id uguale a quelli del campo patientTreatmentList dei record presenti in Trigger.New
         List<Account_Treatment__c> accountTreatmentList = [Select id, Status__c, Activation_Date__c, Suspension_end_date__c, Suspension_Reason__c,  Suspension_Type__c,
                                                 Suspension_start_date__c, Account__c
                                                 from Account_Treatment__c 
                                                 where id in: patientTreatmentList];
        
        List<String> accountIds = new List<String>();
        
         //Creo una mappa "temporanea" per evitare un doppio ciclo for. Nella mappa inserisco tutti i record della lista accountTreatmentList
        Map<String, Account_Treatment__c> temporaryTreatmentMap = new Map<String, Account_Treatment__c>();
        if(!accountTreatmentList.isEmpty()){
            for(Account_Treatment__c treatment : accountTreatmentList){
                temporaryTreatmentMap.put(treatment.id, treatment);
                accountIds.add(treatment.Account__c);
            }
        }
        
        // Creo una map per contenere gli AccountTreatment 
        Map<Id, Account_Treatment__c> accountTreatmentMap = new Map<Id, Account_Treatment__c>();
        
        // Scorro la lista Trigger.New per assegnare i valori alla mappa quando combacia l'id del Treatment al campo patientTreatment dell'oggetto Account Treatment Stasus 
        if(!temporaryTreatmentMap.isEmpty()){
            for(Account_Treatment_Status__c newstatus : statusListFromTrigger){
                if(temporaryTreatmentMap.containsKey(newstatus.Patient_Treatment__c)){
                    accountTreatmentMap.put(newstatus.id, temporaryTreatmentMap.get(newstatus.Patient_Treatment__c));
                }
            }
        }
        
        List<Account> temporaryAccountsList = [Select id,Status__c, Recordtype.Name from Account where id in:accountIds];
        Map<String, Account> temporaryAccountsMap = new Map<String, Account>();
        
        if(!temporaryAccountsList.isEmpty()){
            for(Account acc : temporaryAccountsList){
                temporaryAccountsMap.put(acc.Id, acc);
            }
        }
        
        Map<String, Account> AccountsMap = new Map<String, Account>();
        
        if(!temporaryAccountsMap.isEmpty()){
            for(Account_Treatment__c treatment : accountTreatmentList){
                if(temporaryAccountsMap.containsKey(treatment.Account__c)){
                   AccountsMap.put(treatment.Id, temporaryAccountsMap.get(treatment.Account__c)); 
                }
            }
        }
        
        List<Account_Treatment__c> temporaryAccountTreatmentList2 = [Select id, Account__c, Status__c from Account_Treatment__c where Account__c in:accountIds];
        Map<String, List<Account_Treatment__c>> accountTreatmentListMap = new Map<String, List<Account_Treatment__c>>();

        Set<String> accountTreatmentSet = new Set<String>();
        
        if(!temporaryAccountTreatmentList2.isEmpty()){
            for(Account_Treatment__c acctreatment : temporaryAccountTreatmentList2){
                if(!accountTreatmentSet.contains(acctreatment.Account__c)){
                    accountTreatmentSet.add(acctreatment.Account__c);
                }
            }
        }
        
        if(!accountTreatmentSet.isEmpty()){
            for (String ids : accountTreatmentSet){
                accountTreatmentListMap.put(ids, New List<Account_Treatment__c>());
            }
        }
        
        if(!accountTreatmentListMap.isEmpty()){
            for(Account_Treatment__c accountTreatment : temporaryAccountTreatmentList2){
                if(accountTreatmentListMap.containsKey(accountTreatment.Account__c)){
                    accountTreatmentListMap.get(accountTreatment.Account__c).add(accountTreatment);
                }
            }
        }

        Map<String, List<Account_Treatment_Status__c>> ATIdToSuspendedATSMap = new Map<String, List<Account_Treatment_Status__c>>();

        // Getting all the Suspension ATS for these ATs to check whether I can update the Suspesion_Start_Date__c on the AT, or there's another Suspension ATS starting before

        List<Account_Treatment_Status__c> suspensionATSList = [SELECT Id, StartDate__c, Patient_Treatment__c, Suspension_end_date__c,
                                                               Suspension_Reason__c, Suspension_start_date__c, Suspension_Type__c 
                                                               FROM Account_Treatment_Status__c 
                                                               WHERE Status__c = 'S' 
                                                               AND Patient_Treatment__c IN: patientTreatmentList
                                                               AND Id NOT IN: statusids
                                                               AND Suspension_start_date__c >= TODAY
                                                               ORDER BY StartDate__c ASC];

        if(suspensionATSList != null) {
            for(Account_Treatment_Status__c ats : suspensionATSList) {
                if(ATIdToSuspendedATSMap.get(ats.Patient_Treatment__c) == null) {
                    ATIdToSuspendedATSMap.put(ats.Patient_Treatment__c, new List<Account_Treatment_Status__c>());
                }
                ATIdToSuspendedATSMap.get(ats.Patient_Treatment__c).add(ats);
            }
        }
        
        // Creo due liste per gli aggiornamenti dei campi in seguito.
        List <Account_Treatment_Status__c> statusList = new List<Account_Treatment_Status__c>();
        List<Account_Treatment_Status__c> newStatusList = new List<Account_Treatment_Status__c>();
    	List <Account_Treatment__c> treatmentList = new List<Account_Treatment__c>();
    	List <Account> accountsList = new List<Account>();
        
        for(Account_Treatment_Status__c actualStatus : statusListFromTrigger) {

            Boolean updateSuspensionOnAT = true;

            // Need to clone the ATS, because the record is read only in Trigger context
            Account_Treatment_Status__c tmpATS = new Account_Treatment_Status__c();
            tmpATS.Id = actualStatus.Id;
        	
            // Recupero il record precedente
            /* Account_Treatment_Status__c previousStatus = oldStatusMap.get(actualStatus.Id);
            System.debug('Previous status: ' + previousStatus); */
            
       		// Aggiorno il record precedente;
            /* if(previousStatus!=null){
                previousStatus.EndDate__c = actualStatus.StartDate__c;
            
                // Aggiorno il record che ha fatto scattare il trigger;
                tmpATS.Previous_Status__c = previousStatus.Id;
                newStatusList.add(tmpATS);
            } */
            
            Account_Treatment__c accountTreatment = accountTreatmentMap.get(actualStatus.Id);
            System.debug('Account Treatment: ' + accountTreatment);
            Account relatedAccount = AccountsMap.get(accountTreatment.Id);

            if(relatedAccount != null) {
                String currentAccountStatus = relatedAccount.Status__c;
                System.debug('Related Account: ' + relatedAccount);
                List<Account_Treatment__c> relatedAccountTreatmentList= accountTreatmentListMap.get(relatedAccount.Id);
                System.debug('------- RELATED ACCOUNTTREATMENTLIST: ' + relatedAccountTreatmentList);

                // Getting the (eventually) already present Suspended ATS for this AT

                List<Account_Treatment_Status__c> otherSuspendedATSList = ATIdToSuspendedATSMap.get(accountTreatment.Id);
            
                // condition added later 
                
                if(relatedAccount.Status__c != null){      
                    if(actualStatus.Status__c == 'W' && 
                    ((relatedAccount.Status__c == 'DEACTIVATED' || relatedAccount.Status__c == 'INACTIVE' ) && relatedAccount.Recordtype.Name == 'Account_Patient' )) {
                        relatedAccount.Status__c = 'NEW';
                    }
                }

                // First IF

                if (actualStatus.Status__c == 'A' && ((accountTreatment.Status__c != 'A' && accountTreatment.Status__c != 'S') || 
                (accountTreatment.Status__c == 'A' && accountTreatment.Activation_Date__c != actualStatus.StartDate__c))) {
                    System.debug('IN FIRST IF');

                    accountTreatment.Activation_Date__c = actualStatus.StartDate__c;

                    if(actualStatus.StartDate__c <= Date.today()) {
                        accountTreatment.Status__c = 'A';
                        accountTreatment.Deactivation_Date__c = NULL;
                        
                        if(relatedAccount.Status__c != 'ACTIVE' && relatedAccount.RecordType.Name == 'Account_Patient'){
                            relatedAccount.Status__c = 'ACTIVE';
                        }
                    }    
                }
                
                // Second IF

                if (actualStatus.Status__c == 'A' && accountTreatment.Status__c == 'S'){
                    System.debug('IN SECOND IF');

                    accountTreatment.Activation_Date__c = actualStatus.StartDate__c;

                    if(actualStatus.StartDate__c <= Date.today()) {
                        accountTreatment.Status__c = 'A';
                        accountTreatment.Deactivation_Date__c = NULL;

                        if(otherSuspendedATSList == null || otherSuspendedATSList.isEmpty()) {
                            accountTreatment.Suspension_end_date__c = NULL;
                            accountTreatment.Suspension_Reason__c = NULL;
                            accountTreatment.Suspension_start_date__c = NULL;
                            accountTreatment.Suspension_Type__c = NULL;
                        }
                        else {
                            Account_Treatment_Status__c nextSuspension = otherSuspendedATSList[0];

                            if(nextSuspension != null) {
                                accountTreatment.Suspension_end_date__c = nextSuspension.Suspension_end_date__c;
                                accountTreatment.Suspension_Reason__c = nextSuspension.Suspension_Reason__c;
                                accountTreatment.Suspension_start_date__c = nextSuspension.Suspension_start_date__c;
                                accountTreatment.Suspension_Type__c = nextSuspension.Suspension_Type__c;
                            }
                        }
                        
                        if(relatedAccount.Status__c != 'ACTIVE' && relatedAccount.Recordtype.Name == 'Account_Patient'){
                            relatedAccount.Status__c = 'ACTIVE';
                        }
                    }
                } 

                // Third IF

                if (actualStatus.Status__c == 'S' && 
                (accountTreatment.Status__c != 'S' || 
                (accountTreatment.Status__c == 'S'  && 
                (accountTreatment.Suspension_end_date__c != actualStatus.Suspension_end_date__c || 
                accountTreatment.Suspension_start_date__c != actualStatus.Suspension_start_date__c ||
                accountTreatment.Suspension_Reason__c != actualStatus.Suspension_Reason__c || 
                accountTreatment.Suspension_Type__c != actualStatus.Suspension_Type__c )))) {
                    if(actualStatus.Suspension_start_date__c <= Date.today() && actualStatus.Suspension_end_date__c >= Date.today()) {
                        accountTreatment.Status__c = 'S';
                    }

                    if(otherSuspendedATSList != null) {
                        for(Account_Treatment_Status__c ats : otherSuspendedATSList) {
                            if(ats.StartDate__c < actualStatus.StartDate__c) {
                                updateSuspensionOnAT = false;
                                break;
                            }
                        }
                    }

                    if(updateSuspensionOnAT) {
                        accountTreatment.Suspension_end_date__c = actualStatus.Suspension_end_date__c ;
                        accountTreatment.Suspension_Reason__c = actualStatus.Suspension_Reason__c;
                        accountTreatment.Suspension_start_date__c = actualStatus.Suspension_start_date__c;
                        accountTreatment.Suspension_Type__c = actualStatus.Suspension_Type__c;
                        accountTreatment.Deactivation_Date__c = NULL;   
                    }
                }

                // Fourth IF

                if (actualStatus.Status__c == 'D' && accountTreatment.Status__c == 'S' ) {
                    accountTreatment.Deactivation_Date__c = actualStatus.StartDate__c;

                    if(actualStatus.StartDate__c <= Date.today()) {
                        accountTreatment.Status__c = 'D';
                        accountTreatment.Suspension_end_date__c = NULL;
                        accountTreatment.Suspension_Reason__c = NULL;
                        accountTreatment.Suspension_start_date__c = NULL;
                        accountTreatment.Suspension_Type__c = NULL;
                        
                        boolean flag = true;
                        
                        if(!relatedAccountTreatmentList.isEmpty()){
                            for(Account_Treatment__c accTreatmentFromList: relatedAccountTreatmentList){
                                if(accTreatmentFromList.Id != accountTreatment.Id){
                                    if(accTreatmentFromList.Status__c!=null){
                                        if(accTreatmentFromList.Status__c != 'D'){
                                            flag = false;
                                        }
                                    }
                                }
                            }
                        
                        
                            if(relatedAccount.Status__c != 'DEACTIVATED' && relatedAccount.Recordtype.Name == 'Account_Patient' && flag){
                                relatedAccount.Status__c = 'DEACTIVATED';
                            }
                        }
                    }
                }

                // Fifth IF

                if (actualStatus.Status__c == 'D'/*  && (accountTreatment.Status__c != 'D' && accountTreatment.Status__c != 'S') */){
                    accountTreatment.Deactivation_Date__c = actualStatus.StartDate__c;

                    if(actualStatus.StartDate__c <= Date.today()) {
                        accountTreatment.Status__c = 'D';
                        accountTreatment.Suspension_end_date__c = NULL;
                        accountTreatment.Suspension_Reason__c = NULL;
                        accountTreatment.Suspension_start_date__c = NULL;
                        accountTreatment.Suspension_Type__c = NULL;
                        
                        boolean flag = true;
                        
                        if(!relatedAccountTreatmentList.isEmpty()){
                            for(Account_Treatment__c accTreatmentFromList: relatedAccountTreatmentList){
                                if(accTreatmentFromList.Id != accountTreatment.Id){
                                    if(accTreatmentFromList.Status__c!=null){
                                        if(accTreatmentFromList.Status__c != 'D'){
                                            flag = false;
                                        }
                                    }
                                }
                            }
                        
                            if(relatedAccount.Status__c != 'DEACTIVATED' && relatedAccount.Recordtype.Name == 'Account_Patient'  && flag){
                                relatedAccount.Status__c = 'DEACTIVATED';
                            }
                        }
                    }
                }

                // Sixth IF

                if (actualStatus.Status__c == 'R' && accountTreatment.Status__c != 'R'){
                    if(actualStatus.StartDate__c <= Date.today()) {
                        accountTreatment.Status__c = 'R';
                        accountTreatment.Suspension_end_date__c = NULL;
                        accountTreatment.Suspension_Reason__c = NULL;
                        accountTreatment.Suspension_start_date__c = NULL;
                        accountTreatment.Suspension_Type__c = NULL;

                        boolean flag = true;

                        if(!relatedAccountTreatmentList.isEmpty()){
                            for(Account_Treatment__c accTreatmentFromList: relatedAccountTreatmentList){
                                if(accTreatmentFromList.Id != accountTreatment.Id){
                                    if(accTreatmentFromList.Status__c!=null){
                                        if(accTreatmentFromList.Status__c != 'R'){
                                            flag = false;
                                        }
                                    }
                                }
                            }
                            
                            if(relatedAccount.Status__c != 'INACTIVE' && relatedAccount.Recordtype.Name == 'Account_Patient' && flag){
                                relatedAccount.Status__c = 'INACTIVE';
                            }
                        }
                    }
                }
            
                if (accountTreatment!=null) treatmentList.add(accountTreatment);
                //if (previousStatus != null) statusList.add(previousStatus);
                if (relatedAccount != null && !accountsList.contains(relatedAccount) && currentAccountStatus != 'DEAD') accountsList.add(relatedAccount);
            }
        }
        
        /* if(!newStatusList.isEmpty()) {
            update newStatusList;
        } */

        /* if (!statusList.isEmpty()){ 
            update statusList;
        } */
        if (!treatmentList.isEmpty()){ 
            update treatmentList;
        }
        if (!accountsList.isEmpty()){ 
            update accountsList;
        }
    }

    public static void updateWorkOrders(List<Account_Treatment_Status__c> ATSList) {
        List<String> workOrderQueryFields = new List<String>{'Account_Treatment__c', 'Status', 'Due_Date__c', 'LocationId', 'Street', 'PostalCode', 
        'StateCode', 'CountryCode', 'City', 'Delivery_Type__c', 'TaskCreated__c', 'CaseId', 'StartDate', 'EndDate', 'Reason__c', 
        'Account_Treatment_Job__r.Corporate_Treatment_Job_ExtId__c', 'Account_Treatment__r.Trial_Contract_Treatment__c',
        'Account_Treatment__r.Contract_Treatment__r.Contract_Framework__r.Contract_Type__c'};
        List<String> caseQueryFields = new List<String>{'Status', 'Account_Treatment__c', 'Account_Treatment_Job__r.Corporate_Treatment_Job_ExtId__c', 
        'Account_Treatment__r.Contract_Treatment__r.Contract_Framework__r.Contract_Type__c', 'Start_Date__c'};
        List<String> taskQueryFields = new List<String>{'Status', 'WhatId'};

        List<String> ATIds = new List<String>();
        List<String> allRelatedCaseIds = new List<String>();
        List<Case> allRelatedCases = new List<Case>();
        List<WorkOrder> allRelatedWorkOrders = new List<WorkOrder>();
        List<Task> allRelatedTasks = new List<Task>();
        List<WorkOrder> workOrdersToUpdate = new List<WorkOrder>();
        List<Task> tasksToUpdate = new List<Task>();
        List<Case> casesToUpdate = new List<Case>();
        List<Task> tasksToInsert = new List<Task>();

        Map<String, List<Case>> ATIdToCasesMap = new Map<String, List<Case>>();
        Map<String, List<WorkOrder>> caseIdToWOsMap = new Map<String, List<WorkOrder>>();
        Map<String, List<Task>> caseIdToTasksMap = new Map<String, List<Task>>();

        for(Account_Treatment_Status__c ats : ATSList) {
            ATIds.add(ats.Patient_Treatment__c);
        }

        // Getting all Cases

        allRelatedCases = CaseDAO.getOpenCasesFromATs(caseQueryFields, ATIds);

        if(!allRelatedCases.isEmpty()) {
            Group prePlannerNL = [SELECT Id FROM Group WHERE Name = 'Preplanner_NL' AND Type = 'Queue'];

            for(Case c : allRelatedCases) {
                allRelatedCaseIds.add(c.Id);
                if(ATIdToCasesMap.get(c.Account_Treatment__c) == null) {
                    ATIdToCasesMap.put(c.Account_Treatment__c, new List<Case>());
                }
                ATIdToCasesMap.get(c.Account_Treatment__c).add(c);
            }

            // Getting all WOs related to Cases

            allRelatedWorkOrders = WorkOrderDAO.getFutureWOsFromCaseIds(workOrderQueryFields, allRelatedCaseIds);

            if(!allRelatedWorkOrders.isEmpty()) {
                for(WorkOrder wo : allRelatedWorkOrders) {
                    if(caseIdToWOsMap.get(wo.CaseId) == null) {
                        caseIdToWOsMap.put(wo.CaseId, new List<WorkOrder>());
                    }
                    caseIdToWOsMap.get(wo.CaseId).add(wo);
                }
            }

            // Getting all Tasks related to Cases

            allRelatedTasks = TaskDAO.getOpenTasksFromWhatIds(taskQueryFields, allRelatedCaseIds);

            if(!allRelatedTasks.isEmpty()) {
                for(Task t : allRelatedTasks) {
                    if(caseIdToTasksMap.get(t.WhatId) == null) {
                        caseIdToTasksMap.put(t.WhatId, new List<Task>());
                    }
                    caseIdToTasksMap.get(t.WhatId).add(t);
                }
            }

            for(Account_Treatment_Status__c ats : ATSList) {
                List<Case> relatedFutureCases = ATIdToCasesMap.get(ats.Patient_Treatment__c);

                if(relatedFutureCases != null && !relatedFutureCases.isEmpty()) {
                    System.debug('relatedFutureCases size: ' + relatedFutureCases.size());
                    if(ats.Status__c == 'S' && (ats.Suspension_Reason__c == 'VIV' || ats.Suspension_Reason__c == 'HOS') && ats.Suspension_Type__c == 'SERVICE') {
                        for(Case c : relatedFutureCases) {
                            if(ats.Suspension_end_date__c == null || (ats.Suspension_end_date__c != null && 
                            (c.Start_Date__c.date() >= ats.Suspension_start_date__c && c.Start_Date__c.date() <= ats.Suspension_end_date__c) /* &&
                            (wo.EndDate.date() >= ats.Suspension_start_date__c && wo.EndDate.date() <= ats.Suspension_end_date__c) */)) {
                                System.debug('Suspending Case ' + c.Id + '...');

                                List<WorkOrder> relatedWorkOrders = caseIdToWOsMap.get(c.Id);
                                List<Task> relatedTasks = caseIdToTasksMap.get(c.Id);

                                // Suspending Case

                                c.Status = 'On Hold';

                                if(!casesToUpdate.contains(c)) {
                                    casesToUpdate.add(c);
                                }

                                // Suspending related WOs (and eventually creating new Task)

                                if(relatedWorkOrders != null && !relatedWorkOrders.isEmpty()) {
                                    for(WorkOrder wo : relatedWorkOrders) {
                                        String oldStatus = wo.Status;
                                        wo.Status = 'On Hold';
                                        wo.Reason__c = 'Treatment Suspension';

                                        workOrdersToUpdate.add(wo);

                                        if(oldStatus == 'Assigned') {
                                            Task newTask = new Task(
                                                Subject = Label.ATSuspension_Task_Subject,
                                                Description = Label.ATSuspension_Task_Description,
                                                WhatId = wo.CaseId,
                                                ActivityDate = Date.newInstance((wo.EndDate).year(), (wo.EndDate).month(), (wo.EndDate).day()),
                                                OwnerId = prePlannerNL.Id
                                            );
            
                                            tasksToInsert.add(newTask);
                                        }
                                    }
                                }

                                // Suspending related Tasks

                                if(relatedTasks != null && !relatedTasks.isEmpty()) {
                                    for(Task t : relatedTasks) {
                                        t.Status = 'On Hold';
                                        tasksToUpdate.add(t);
                                    }
                                }
                            }
                        }
                    }
                    else if(ats.Status__c == 'D') {
                        List<Case> casesToCheck = new List<Case>();

                        for(Case c : relatedFutureCases) {
                            if(c.Account_Treatment_Job__r.Corporate_Treatment_Job_ExtId__c != 'REM' && 
                            c.Account_Treatment__r.Contract_Treatment__r.Contract_Framework__r.Contract_Type__c != 'ZS0'/*  && 
                            c.Start_Date__c >= ats.StartDate__c */) {
                                casesToCheck.add(c);
                            }
                        }

                        if(!casesToCheck.isEmpty()) {
                            for(Case c : casesToCheck) {
                                System.debug('Canceling Case ' + c.Id + '...');

                                List<WorkOrder> relatedWorkOrders = caseIdToWOsMap.get(c.Id);
                                List<Task> relatedTasks = caseIdToTasksMap.get(c.Id);

                                // Canceling Case

                                c.Status = 'Canceled';

                                if(!casesToUpdate.contains(c)) {
                                    casesToUpdate.add(c);
                                }

                                // Canceling related WOs (and eventually creating new Task)

                                if(relatedWorkOrders != null && !relatedWorkOrders.isEmpty()) {
                                    for(WorkOrder wo : relatedWorkOrders) {
                                        String oldStatus = wo.Status;
                                        wo.Status = 'Canceled';
                                        wo.Reason__c = 'Treatment Deactivated';

                                        workOrdersToUpdate.add(wo);
                        
                                        if(oldStatus == 'Assigned') {
                                            Task newTask = new Task(
                                                Subject = Label.ATDeactivation_Task_Subject,
                                                Description = Label.ATDeactivation_Task_Description,
                                                WhatId = wo.CaseId,
                                                ActivityDate = Date.newInstance((wo.EndDate).year(), (wo.EndDate).month(), (wo.EndDate).day()),
                                                OwnerId = prePlannerNL.Id
                                            );

                                            tasksToInsert.add(newTask);
                                        }
                                    }
                                }

                                // Canceling related Tasks

                                if(relatedTasks != null && !relatedTasks.isEmpty()) {
                                    for(Task t : relatedTasks) {
                                        t.Status = 'Canceled';
                                        tasksToUpdate.add(t);
                                    }
                                }
                            }
                        }
                    }
                    else if(ats.Status__c == 'R') {
                        List<Case> casesToCheck = new List<Case>();

                        for(Case c : relatedFutureCases) {
                            if(c.Account_Treatment_Job__r.Corporate_Treatment_Job_ExtId__c != 'REM' && 
                            c.Account_Treatment__r.Contract_Treatment__r.Contract_Framework__r.Contract_Type__c != 'ZS0'/*  &&
                            c.Start_Date__c >= ats.StartDate__c */) {
                                casesToCheck.add(c);
                            }
                        }
    
                        if(!casesToCheck.isEmpty()) {
                            for(Case c : casesToCheck) {
                                System.debug('Canceling Case ' + c.Id + '...');

                                List<WorkOrder> relatedWorkOrders = caseIdToWOsMap.get(c.Id);
                                List<Task> relatedTasks = caseIdToTasksMap.get(c.Id);

                                // Canceling Case

                                c.Status = 'Canceled';

                                if(!casesToUpdate.contains(c)) {
                                    casesToUpdate.add(c);
                                }

                                // Canceling related WOs (and eventually creating new Task)

                                if(relatedWorkOrders != null && !relatedWorkOrders.isEmpty()) {
                                    for(WorkOrder wo : relatedWorkOrders) {
                                        String oldStatus = wo.Status;
                                        wo.Status = 'Canceled';
                                        wo.Reason__c = 'Treatment Deactivated';

                                        workOrdersToUpdate.add(wo);
                        
                                        if(oldStatus == 'Assigned') {
                                            Task newTask = new Task(
                                                Subject = Label.ATRemoval_Task_Subject,
                                                Description = Label.ATRemoval_Task_Description,
                                                WhatId = wo.CaseId,
                                                ActivityDate = Date.newInstance((wo.EndDate).year(), (wo.EndDate).month(), (wo.EndDate).day()),
                                                OwnerId = prePlannerNL.Id
                                            );

                                            tasksToInsert.add(newTask);
                                        }
                                    }
                                }

                                // Canceling related Tasks

                                if(relatedTasks != null && !relatedTasks.isEmpty()) {
                                    for(Task t : relatedTasks) {
                                        t.Status = 'Canceled';
                                        tasksToUpdate.add(t);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        if(!workOrdersToUpdate.isEmpty()) {
            update workOrdersToUpdate;
        }

        if(!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }

        if(!tasksToUpdate.isEmpty()) {
            update tasksToUpdate;
        }

        if(!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        }

        /* List<Id> relatedATIds = new List<Id>();
        List<String> allRelatedCaseIds = new List<String>();
        List<WorkOrder> workOrdersToUpdate = new List<WorkOrder>();
        List<Task> tasksToInsert = new List<Task>();
        List<Case> allRelatedCases = new List<Case>();
        List<Task> allRelatedTasks = new List<Task>();
        List<Case> casesToUpdate = new List<Case>();
        List<Task> tasksToUpdate = new List<Task>();

        Map<Id, List<WorkOrder>> ATIdToWorkOrdersMap = new Map<Id, List<WorkOrder>>();
        Map<String, Case> caseMap = new Map<String, Case>();
        Map<String, List<Task>> caseToTasksMap = new Map<String, List<Task>>();

        for(Account_Treatment_Status__c ats : ATSList) {
            relatedATIds.add(ats.Patient_Treatment__c);
        }

        List<WorkOrder> allRelatedWOs = WorkOrderDAO.getFutureWOsFromATIds(queryFieldsForWO, relatedATIds);

        Group prePlannerNL = [SELECT Id FROM Group WHERE Name = 'Preplanner_NL' AND Type = 'Queue'];

        if(allRelatedWOs != null) {
            for(WorkOrder wo : allRelatedWOs) {
                allRelatedCaseIds.add(wo.CaseId);

                if(ATIdToWorkOrdersMap.get(wo.Account_Treatment__c) == null) {
                    ATIdToWorkOrdersMap.put(wo.Account_Treatment__c, new List<WorkOrder>());
                }
                ATIdToWorkOrdersMap.get(wo.Account_Treatment__c).add(wo);
            }

            // Getting Case map

            allRelatedCases = CaseDAO.getCasesFromIds(caseQueryFields, allRelatedCaseIds);

            if(!allRelatedCases.isEmpty()) {
                for(Case c : allRelatedCases) {
                    caseMap.put(c.Id, c);
                }
            }

            // Getting Case.Id --> List<Related Tasks> map

            allRelatedTasks = TaskDAO.getOpenTasksFromWhatIds(taskQueryFields, allRelatedCaseIds);

            if(!allRelatedTasks.isEmpty()) {
                for(Task t : allRelatedTasks) {
                    if(caseToTasksMap.get(t.WhatId) == null) {
                        caseToTasksMap.put(t.WhatId, new List<Task>());
                    }
                    caseToTasksMap.get(t.WhatId).add(t);
                }
            }
        }

        for(Account_Treatment_Status__c ats : ATSList) {
            List<WorkOrder> relatedFutureWOs = ATIdToWorkOrdersMap.get(ats.Patient_Treatment__c);

            if(relatedFutureWOs != null) {
                System.debug('relatedFutureWOs size: ' + relatedFutureWOs.size());
                if(ats.Status__c == 'S' && (ats.Suspension_Reason__c == 'VIV' || ats.Suspension_Reason__c == 'HOS') && ats.Suspension_Type__c == 'SERVICE') {
                    for(WorkOrder wo : relatedFutureWOs) {
                        Case relatedCase = caseMap.get(wo.CaseId);

                        if(ats.Suspension_end_date__c == null || (ats.Suspension_end_date__c != null && 
                        (wo.StartDate.date() >= ats.Suspension_start_date__c && wo.StartDate.date() <= ats.Suspension_end_date__c) &&
                        (wo.EndDate.date() >= ats.Suspension_start_date__c && wo.EndDate.date() <= ats.Suspension_end_date__c))) {
                            System.debug('Suspending WorkOrder...');

                            String oldStatus = wo.Status;
                            wo.Status = 'On Hold';
                            wo.Reason__c = 'Treatment Suspension';

                            workOrdersToUpdate.add(wo);

                            if(oldStatus == 'Assigned') {
                                Task newTask = new Task(
                                    Subject = Label.ATSuspension_Task_Subject,
                                    Description = Label.ATSuspension_Task_Description,
                                    WhatId = wo.CaseId,
                                    ActivityDate = Date.newInstance((wo.EndDate).year(), (wo.EndDate).month(), (wo.EndDate).day()),
                                    OwnerId = prePlannerNL.Id
                                );

                                tasksToInsert.add(newTask);
                            }

                            // Setting Case and related open Tasks On Hold

                            if(relatedCase != null) {
                                List<Task> relatedTasks = caseToTasksMap.get(relatedCase.Id);

                                relatedCase.Status = 'On Hold';

                                if(!casesToUpdate.contains(relatedCase)) {
                                    casesToUpdate.add(relatedCase);
                                }

                                if(relatedTasks != null) {
                                    for(Task t : relatedTasks) {
                                        t.Status = 'On Hold';

                                        tasksToUpdate.add(t);
                                    }
                                }
                            }
                        }
                    }
                }
                else if(ats.Status__c == 'D') {
                    List<WorkOrder> workOrdersToCheck = new List<WorkOrder>();

                    for(WorkOrder wo : relatedFutureWOs) {
                        if(wo.Account_Treatment_Job__r.Corporate_Treatment_Job_ExtId__c != 'REM' && 
                        wo.Account_Treatment__r.Contract_Treatment__r.Contract_Framework__r.Contract_Type__c != 'ZS0' && 
                        wo.StartDate >= ats.StartDate__c) {
                            workOrdersToCheck.add(wo);
                        }
                    }

                    if(!workOrdersToCheck.isEmpty()) {
                        for(WorkOrder wo : workOrdersToCheck) {
                            Case relatedCase = caseMap.get(wo.CaseId);

                            String oldStatus = wo.Status;
                            wo.Status = 'Canceled';
                            wo.Reason__c = 'Treatment Deactivated';

                            workOrdersToUpdate.add(wo);
            
                            if(oldStatus == 'Assigned') {
                                Task newTask = new Task(
                                    Subject = Label.ATDeactivation_Task_Subject,
                                    Description = Label.ATDeactivation_Task_Description,
                                    WhatId = wo.CaseId,
                                    ActivityDate = Date.newInstance((wo.EndDate).year(), (wo.EndDate).month(), (wo.EndDate).day()),
                                    OwnerId = prePlannerNL.Id
                                );

                                tasksToInsert.add(newTask);
                            }

                            // Setting Case and related open Tasks On Hold

                            if(relatedCase != null) {
                                List<Task> relatedTasks = caseToTasksMap.get(relatedCase.Id);

                                relatedCase.Status = 'Canceled';

                                if(!casesToUpdate.contains(relatedCase)) {
                                    casesToUpdate.add(relatedCase);
                                }

                                if(relatedTasks != null) {
                                    for(Task t : relatedTasks) {
                                        t.Status = 'Canceled';

                                        tasksToUpdate.add(t);
                                    }
                                }
                            }
                        }
                    }
                }
                else if(ats.Status__c == 'R') {
                    List<WorkOrder> workOrdersToCheck = new List<WorkOrder>();

                    for(WorkOrder wo : relatedFutureWOs) {
                        if(wo.Account_Treatment_Job__r.Corporate_Treatment_Job_ExtId__c != 'REM' && 
                        wo.Account_Treatment__r.Contract_Treatment__r.Contract_Framework__r.Contract_Type__c != 'ZS0' &&
                        wo.StartDate >= ats.StartDate__c) {
                            workOrdersToCheck.add(wo);
                        }
                    }

                    if(!workOrdersToCheck.isEmpty()) {
                        for(WorkOrder wo : workOrdersToCheck) {
                            Case relatedCase = caseMap.get(wo.CaseId);

                            String oldStatus = wo.Status;
                            wo.Status = 'Canceled';
                            wo.Reason__c = 'Treatment Deactivated';

                            workOrdersToUpdate.add(wo);
            
                            if(oldStatus == 'Assigned') {
                                Task newTask = new Task(
                                    Subject = Label.ATRemoval_Task_Subject,
                                    Description = Label.ATRemoval_Task_Description,
                                    WhatId = wo.CaseId,
                                    ActivityDate = Date.newInstance((wo.EndDate).year(), (wo.EndDate).month(), (wo.EndDate).day()),
                                    OwnerId = prePlannerNL.Id
                                );

                                tasksToInsert.add(newTask);
                            }

                            // Setting Case and related open Tasks On Hold

                            if(relatedCase != null) {
                                List<Task> relatedTasks = caseToTasksMap.get(relatedCase.Id);

                                relatedCase.Status = 'Canceled';

                                if(!casesToUpdate.contains(relatedCase)) {
                                    casesToUpdate.add(relatedCase);
                                }

                                if(relatedTasks != null) {
                                    for(Task t : relatedTasks) {
                                        t.Status = 'Canceled';

                                        tasksToUpdate.add(t);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        if(!workOrdersToUpdate.isEmpty()) {
            update workOrdersToUpdate;
        }

        if(!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }

        if(!tasksToUpdate.isEmpty()) {
            update tasksToUpdate;
        }

        if(!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        } */
    }

    public static void handleStatusSuccession(List<Account_Treatment_Status__c> ATSList) {
        System.debug('----- handleStatusSuccession -----');
        System.debug('ATSList size: ' + ATSList.size());
        System.debug('ATSList: ' + ATSList);

        List<Account_Treatment_Status__c> newCurrentStatusList = new List<Account_Treatment_Status__c>();
        List<Account_Treatment_Status__c> pastStatusList = new List<Account_Treatment_Status__c>();
        List<Account_Treatment_Status__c> allCurrentStatusList = new List<Account_Treatment_Status__c>();
        List<Account_treatment_Status__c> toUpdate = new List<Account_Treatment_Status__c>();
        List<Account_Treatment_Status__c> toInsert = new List<Account_Treatment_Status__c>();
        List<String> accountTreatmentIds = new List<String>();

        Map<String, Account_Treatment_Status__c> currentATSMap = new Map<String, Account_Treatment_Status__c>();

        for(Account_Treatment_Status__c ats : ATSList) {
            accountTreatmentIds.add(ats.Patient_Treatment__c);

            // Current Status list

            if((ats.Status__c != 'S' && ats.StartDate__c <= Date.today()) ||
            (ats.Status__c == 'S' && ats.Suspension_start_date__c <= Date.today() && (ats.Suspension_end_date__c >= Date.today() || ats.Suspension_end_date__c == null))) {
                newCurrentStatusList.add(ats);
            }

            // Already ended Status list

            if(ats.Status__c == 'S' && ats.Suspension_start_date__c < Date.today() && ats.Suspension_end_date__c < Date.today()) {
                pastStatusList.add(ats);
            }
        }

        allCurrentStatusList = [SELECT Id, Is_Current_Status__c, Patient_Treatment__c, EndDate__c, Status__c, StartDate__c FROM Account_Treatment_Status__c 
                                WHERE Patient_Treatment__c IN: accountTreatmentIds
                                AND Is_Current_Status__c = true];
        
        if(!allCurrentStatusList.isEmpty()) {
            for(Account_Treatment_Status__c ats : allCurrentStatusList) {
                currentATSMap.put(ats.Patient_Treatment__c, ats);
            }
        }

        System.debug('newCurrentStatusList: ' + newCurrentStatusList);
        System.debug('pastStatusList: ' + pastStatusList);

        // If the new ATS is the new current one, I need to update it and the old status

        for(Account_Treatment_Status__c ats : newCurrentStatusList) {
            Account_Treatment_Status__c tmp = new Account_Treatment_Status__c();
            tmp.Id = ats.Id;

            Account_Treatment_Status__c oldCurrentStatus = currentATSMap.get(ats.Patient_Treatment__c);

            if(ats.Is_Current_Status__c == false) {
                tmp.Is_Current_Status__c = true;
            }

            if(oldCurrentStatus != null && oldCurrentStatus.Id != ats.Id) {
                tmp.Previous_Status__c = oldCurrentStatus.Id;
                oldCurrentStatus.Is_Current_Status__c = false;

                if(oldCurrentStatus.EndDate__c != ats.StartDate__c.addDays(-1)) {
                    oldCurrentStatus.EndDate__c = ats.StartDate__c.addDays(-1);
                }

                toUpdate.add(oldCurrentStatus);
            }

            toUpdate.add(tmp);
        }

        // If the new ATS is a past one, I need to "split" the past Active status to insert the Suspended status between. So it will be oldStatus1 - newStatus - oldStatus2

        for(Account_Treatment_Status__c ats : pastStatusList) {
            System.debug('--- In pastStatusList loop');
            System.debug('ats: ' + ats.Id);
            Account_Treatment_Status__c tmp = new Account_Treatment_Status__c();
            tmp.Id = ats.Id;

            Account_Treatment_Status__c oldCurrentStatus = currentATSMap.get(ats.Patient_Treatment__c);

            if(oldCurrentStatus != null) {
                tmp.Previous_Status__c = oldCurrentStatus.Id;
                tmp.EndDate__c = ats.Suspension_end_date__c;
                
                oldCurrentStatus.Is_Current_Status__c = false;

                // Stopping the old Status when the newly inserted Suspended Status begins...

                if(oldCurrentStatus.EndDate__c != ats.StartDate__c.addDays(-1)) {
                    oldCurrentStatus.EndDate__c = ats.StartDate__c.addDays(-1);
                }

                // ... Then creating the second part of the old Status, after the newly inserted Suspended Status

                Account_Treatment_Status__c oldStatusSecondPart = new Account_Treatment_Status__c(
                    StartDate__c = ats.Suspension_end_date__c.addDays(1),
                    Status__c = oldCurrentStatus.Status__c,
                    Previous_Status__c = ats.Id,
                    Is_Current_Status__c = true,
                    Patient_Treatment__c = oldCurrentStatus.Patient_Treatment__c
                );

                toUpdate.add(oldCurrentStatus);
                toUpdate.add(tmp);
                toInsert.add(oldStatusSecondPart);
            }
        }

        System.debug('toUpdate: ' + toUpdate);
        System.debug('toInsert: ' + toInsert);

        if(!toUpdate.isEmpty()) {
            List<Database.SaveResult> results = Database.update(toUpdate);
        }

        if(!toInsert.isEmpty()) {
            List<Database.SaveResult> results = Database.insert(toInsert);
        }
    }

    public static void updateRelatedAccountStatus(List<Account_Treatment_Status__c> ATSList) {
        System.debug('----- updateRelatedAccountStatus -----');

        List<String> accountQueryFields = new List<String>{'Status__c', 'RecordType.Name'};
        List<String> accountTreatmentQueryFields = new List<String>{'Account__c', 'Status__c'};

        List<String> relatedAccountIds = new List<String>();
        List<String> relatedAccountTreatmentIds = new List<String>();
        List<Account> relatedAccounts = new List<Account>();
        List<Account_Treatment__c> otherRelatedATs = new List<Account_Treatment__c>();
        List<Account> toUpdate = new List<Account>();

        Map<String, Account> accountMap = new Map<String, Account>();
        Map<String, List<Account_Treatment__c>> accountIdToOtherATsMap = new Map<String, List<Account_Treatment__c>>();

        for(Account_Treatment_Status__c ats : ATSList) {
            relatedAccountIds.add(ats.Patient_Treatment__r.Account__c);
            relatedAccountTreatmentIds.add(ats.Patient_Treatment__c);
        }

        relatedAccounts = AccountDAO.getAccountIsSapSyncFromRecordIds(accountQueryFields, relatedAccountIds);
        otherRelatedATs = AccountTreatmentDAO.getOtherATsFromAccounts(accountTreatmentQueryFields, relatedAccountIds, relatedAccountTreatmentIds);

        if(!otherRelatedATs.isEmpty()) {
            for(Account_Treatment__c at : otherRelatedATs) {
                if(accountIdToOtherATsMap.get(at.Account__c) == null) {
                    accountIdToOtherATsMap.put(at.Account__c, new List<Account_Treatment__c>());
                }
                accountIdToOtherATsMap.get(at.Account__c).add(at);
            }
        }

        if(!relatedAccounts.isEmpty()) {
            for(Account a : relatedAccounts) {
                accountMap.put(a.Id, a);
            }

            for(Account_Treatment_Status__c ats : ATSList) {
                Account relatedAccount = accountMap.get(ats.Patient_Treatment__r.Account__c);

                System.debug('ATS: ' + ats);
                System.debug('relatedAccount: ' + relatedAccount);

                if(relatedAccount != null) {
                    List<Account_Treatment__c> otherATsRelatedToAccount = accountIdToOtherATsMap.get(relatedAccount.Id);

                    Boolean canUpdateAccountDeactive = true;
                    Boolean canUpdateAccountInactive = true;

                    if(otherATsRelatedToAccount != null) {
                        for(Account_Treatment__c at : otherATsRelatedToAccount) {
                            if(at.Status__c != 'D') {
                                canUpdateAccountDeactive = false;
                            }
                            if(at.Status__c != 'R') {
                                canUpdateAccountInactive = false;
                            }
                        }
                    }

                    System.debug('canUpdateAccountDeactive: ' + canUpdateAccountDeactive);
                    System.debug('canUpdateAccountInactive: ' + canUpdateAccountInactive);

                    if(relatedAccount.RecordType.Name == 'Account_Patient') {
                        if(ats.Status__c == 'A') {
                            if(relatedAccount.Status__c != 'ACTIVE') {
                                System.debug('Updating Account Status...');

                                relatedAccount.Status__c = 'ACTIVE';

                                toUpdate.add(relatedAccount);
                            }
                        }
                        else if(ats.Status__c == 'D') {
                            if(relatedAccount.Status__c != 'DEACTIVATED' && canUpdateAccountDeactive) {
                                System.debug('Updating Account Status...');

                                relatedAccount.Status__c = 'DEACTIVATED';

                                toUpdate.add(relatedAccount);
                            }
                        }
                        else if(ats.Status__c == 'R') {
                            if(relatedAccount.Status__c != 'INACTIVE' && canUpdateAccountInactive) {
                                System.debug('Updating Account Status...');

                                relatedAccount.Status__c = 'INACTIVE';

                                toUpdate.add(relatedAccount);
                            }
                        }
                    }
                }
            }
        }

        if(!toUpdate.isEmpty()) {
            List<Database.SaveResult> results = Database.update(toUpdate);
        }
    }

}