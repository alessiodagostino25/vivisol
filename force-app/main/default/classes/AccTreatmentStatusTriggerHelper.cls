public class AccTreatmentStatusTriggerHelper {
    
    public static void onInsert(List<Account_Treatment_Status__c> statusList){
        AccTreatmentStatusTriggerService.onInsert(statusList);

        AccTreatmentStatusTriggerService.handleStatusSuccession(statusList);
    }

    public static void updateWorkOrders(List<Account_Treatment_Status__c> ATSList) {
        AccTreatmentStatusTriggerService.updateWorkOrders(ATSList);
    }

}