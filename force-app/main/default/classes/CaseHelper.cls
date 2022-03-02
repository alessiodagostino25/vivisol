public class CaseHelper {

    public static void setDmlOptions(List<Id> caseIds) {
        List<AssignmentRule> AR = new List<AssignmentRule>();
        List<Case> caseUpdateList = new List<Case>();
        AR = [SELECT id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = true AND name = 'NL_AssignmentRule' LIMIT 1] ;
        Database.DMLOptions dmo = new Database.DMLOptions();
        if(!AR.isEmpty()){
            dmo.assignmentRuleHeader.assignmentRuleId= AR[0].id;
        }
        List<String> queryFieldsForCase = new List<String>{'Id'};
        List<Case> caselist =   CaseDAO.getCasesFromIds(queryFieldsForCase, caseIds);

        for(Case c : caselist){
            c.setOptions(dmo);
            caseUpdateList.add(c);
        }

        update caseUpdateList;
    }

    public static void setExternalId(List<Case> cases) {
        SObjectServiceClass.updateExternalId('Case', 'CaseNumber', 'External_Id__c', cases);
    }

    public static void updateTreatmentAndCT(List<Case> cases) {
        List<String> accountTreatmentQueryFields = new List<String>{'Contract_Treatment__c', 'Treatment_Type__c'};

        List<String> accountTreatmentIds = new List<String>();
        List<Account_Treatment__c> relatedAccountTreatments = new List<Account_Treatment__c>();

        Map<String, Account_Treatment__c> accountTreatmentMap = new Map<String, Account_Treatment__c>();

        for(Case c : cases) {
            accountTreatmentIds.add(c.Account_Treatment__c);
        }

        relatedAccountTreatments = AccountTreatmentDAO.getAccountTreatmentsFromIds(accountTreatmentQueryFields, accountTreatmentIds);

        if(!relatedAccountTreatments.isEmpty()) {
            for(Account_Treatment__c at : relatedAccountTreatments) {
                accountTreatmentMap.put(at.Id, at);
            }

            for(Case c : cases) {
                Account_Treatment__c relatedAccountTreatment = accountTreatmentMap.get(c.Account_Treatment__c);

                if(relatedAccountTreatment != null) {
                    c.Treatment__c = relatedAccountTreatment.Treatment_Type__c;
                    c.Contract_Treatment__c = relatedAccountTreatment.Contract_Treatment__c;
                }
            }
        }
    }

    public static void checkForClosure(List<Case> cases) {
        System.debug('----- checkForClosure -----');

        final String ERROR_MESSAGE = Label.Case_ClosedWithOpenActivities_Error;
        List<String> workOrderQueryFields = new List<String>{'CaseId'};
        List<String> taskQueryFields = new List<String>{'WhatId'};

        List<WorkOrder> allRelatedWorkOrders = new List<WorkOrder>();
        List<Task> allRelatedTasks = new List<Task>();
        List<String> caseIds = new List<String>();
        List<Case> errorAdded = new List<Case>();

        Map<String, Case> caseMap = new Map<String, Case>();

        for(Case c : cases) {
            caseIds.add(c.Id);
            caseMap.put(c.Id, c);
        }

        allRelatedWorkOrders = WorkOrderDAO.getNotClosedWOsFromCaseIds(workOrderQueryFields, caseIds);
        allRelatedTasks = TaskDAO.getNotClosedTasksFromCaseIds(taskQueryFields, caseIds);

        if(!allRelatedWorkOrders.isEmpty()) {
            for(WorkOrder wo : allRelatedWorkOrders) {
                Case relatedCase = caseMap.get(wo.CaseId);

                if(relatedCase != null && !errorAdded.contains(relatedCase)) {
                    relatedCase.addError(ERROR_MESSAGE);
                    errorAdded.add(relatedCase);
                }
            }
        }

        if(!allRelatedTasks.isEmpty()) {
            for(Task t : allRelatedTasks) {
                Case relatedCase = caseMap.get(t.WhatId);

                if(relatedCase != null && !errorAdded.contains(relatedCase)) {
                    relatedCase.addError(ERROR_MESSAGE);
                    errorAdded.add(relatedCase);
                }
            }
        }
    }
}