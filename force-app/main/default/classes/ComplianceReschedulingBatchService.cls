public class ComplianceReschedulingBatchService {
    
    // Calling the adjustment methods with the map in input will make the methods use other datesDifferences
    
    public static void adjustDatesTaskCasesCompliance(List<Case> taskCases, Map<Id, Account_Treatment_History__c> ATIdToATHMap) {
        ActivitiesDatesAdjustmentService.adjustDatesTaskCases(taskCases, ATIdToATHMap);
    }

    public static List<WorkOrder> adjustDatesWOCasesCompliance(List<Case> WOCases, Map<Id, Account_Treatment_History__c> ATIdToATHMap) {
        List<WorkOrder> newWorkOrders = ActivitiesDatesAdjustmentService.adjustDatesWOCases(WOCases, ATIdToATHMap);

        return newWorkOrders;
    }

    public static List<WorkOrder> adjustDatesTaskAndWOCasesCompliance(List<Case> taskAndWOCases, Map<Id, Account_Treatment_History__c> ATIdToATHMap) {
        List<WorkOrder> newWorkOrders = ActivitiesDatesAdjustmentService.adjustDatesTaskAndWOCases(taskAndWOCases, ATIdToATHMap);

        return newWorkOrders;
    }
}