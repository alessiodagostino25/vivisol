public with sharing class ATMainComponentController {
    @AuraEnabled(cacheable=true)
    public static List<Account_Treatment__c> getrecordnameandtreatment(String accounttreatmentrecordid) {
 
        return AccountTreatmentDAO.getrecordnameandtreatment(accounttreatmentrecordid) ;
    }

    @AuraEnabled
    public static Datetime getTodayDatetime() {
        return Datetime.now();
    }

    @AuraEnabled(cacheable=true)
    public static Boolean checkForAddressSelectionPage(Id accountTreatmentId){
        Boolean toReturn = ATMainComponentService.checkForAddressSelectionPage(accountTreatmentId);
        // Doing this because I was receiving nothing in Result.data in front end
        if(toReturn == true) {
            return true;
        }

        return false;
    }

    @AuraEnabled(cacheable=true)
    public static Boolean checkPrescriptionFilled(String accountTreatmentId) {
        Account_Treatment__c accountTreatment = [SELECT Prescription__c, Prescription__r.Received_date__c FROM Account_Treatment__c WHERE Id =: accountTreatmentId];

        if(accountTreatment.Prescription__c != null && accountTreatment.Prescription__r.Received_date__c != null) {
            return true;
        }

        return false;
    }

    @AuraEnabled
    public static String getAccountTreatmentRecordType(Id accountTreatmentId){
        Account_Treatment__c at = [SELECT RecordType.DeveloperName FROM Account_Treatment__c WHERE Id =: accountTreatmentId];

        return at.RecordType.DeveloperName;
    }

    // StartDateForSales is != null only when the autoscheduleProcess starts from a Sales AT. Otherwise it's null and the autoscheduling is normal for Therapy AT
    @AuraEnabled
    public static void autoscheduleProcess(Id accountTreatmentId, Datetime startDateForSales) {
        /* System.debug('startDateForSales: ' + startDateForSales);

        List<String> caseQueryFields = new List<String>{'AccountId', 'Account_Treatment__c', 'Account_Treatment_Job__c', 'Origin', 'Contract_Treatment__c', 
        'Patient__c', 'Status', 'Subject', 'Subtype__c', 'Type', 'Treatment__c', 'Autoscheduled__c', 'ContactId', 'OwnerId', 'Start_Date__c', 'Next_Activity_Date__c'};

        List<Id> ATIdList = new List<Id>();
        List<Id> newCaseIds = new List<Id>();
        ATIdList.add(accountTreatmentId);

        BusinessHours bh = [SELECT Id, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime,
                            ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime  
                            FROM BusinessHours WHERE Name = 'NL'];

        AssignmentRule assignmentRule = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' and Active = true LIMIT 1];

        // Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions DMLOptions = new Database.DMLOptions();
        DMLOptions.assignmentRuleHeader.assignmentRuleId = assignmentRule.Id;
        
        // This first method checks for all the requirements to create Cases and WO/Tasks, and returns a map of the eligible ATJs and the related SLA
        Map<Account_Treatment_Job__c, Contract_Treatment_Job_SLA__c> ATJToSLAMap = ATMainComponentService.checkRequirements(accountTreatmentId);

        // This second method creates a Case for each previously obtained ATJ and schedules the next ones
        List<Case> newCases = ATMainComponentService.createCases(ATJtoSLAMap, DMLOptions, 365);
        List<Case> queriedNewCases = new List<Case>();

        // Inserting new Cases
        if(!newCases.isEmpty()) {
            insert newCases;

            for(Case c : newCases) {
                newCaseIds.add(c.Id);
            }

            queriedNewCases = CaseDAO.getCasesFromIds(caseQueryFields, newCaseIds);
        }

        List<WorkOrder> newWorkOrders;
        List<Task> newTasks;

        // Therapy

        if(startDateForSales == null) {
            // This third method creates a WO for the ATJs with Work_Order__c = true and schedules the next ones. Called with null on startDateForSales = null for Therapy
            newWorkOrders = ATMainComponentService.createWorkOrders(ATJToSLAMap, queriedNewCases, null);

            // This fourth method creates a Task for the ATJs with Task__c = true and schedules the next ones. Calling this with usePrescription = true and closedWO = null
            newTasks = ATMainComponentService.createTasks(ATJToSLAMap, queriedNewCases, bh, true, null, null, null, null);
        }

        // Sales
        
        else {
            // Methods called with startDateForSales if present (Sales AT case)
            newWorkOrders = ATMainComponentService.createWorkOrders(ATJToSLAMap, queriedNewCases, startDateForSales);

            newTasks = ATMainComponentService.createTasks(ATJToSLAMap, queriedNewCases, bh, false, null, null, startDateForSales, null);
        }

        if(!newTasks.isEmpty()) {
            insert newTasks;
            update queriedNewCases;
        }

        if(!System.isBatch()) {
            // Executing Batch to align workOrders for different created addresses (Temporary and Default)
            ATAAlignmentBatch ATABatch = new ATAAlignmentBatch();
            ATABatch.ATIds = ATIdList;

            Database.executeBatch(ATABatch, 100);
        } */

        List<String> accountTreatmentIds = new List<String>();
        Map<String, Datetime> startDateMap = new Map<String, Datetime>();

        accountTreatmentIds.add(accountTreatmentId);

        if(startDateForSales != null) {
            startDateMap.put(accountTreatmentId, startDateForSales);
        }

        AutoscheduleActivitiesTherapyBatch autoschedulingBatch = new AutoscheduleActivitiesTherapyBatch();
        autoschedulingBatch.accountTreatmentIds = accountTreatmentIds;

        if(!startDateMap.isEmpty()) {
            autoschedulingBatch.startDateMap = startDateMap;
        }

        Database.executeBatch(autoschedulingBatch, 1);
    }

    @AuraEnabled
    public static Integer getDefaultAddressesNumber(Id accountTreatmentId) {
        List<String> queryFields = new List<String>{'Default__c'};

        List<Account_Treatment_Address__c> defaultAddresses = AccountTreatmentAddressDAO.getDefaultATAFromATs(queryFields, new List<Id>{accountTreatmentId});

        if(defaultAddresses == null) {
            return 0;
        }

        System.debug('defaultAddresses.size(): ' + defaultAddresses.size());
        return defaultAddresses.size();
    }
}