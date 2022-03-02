public class AccountTreatmentJobService {
    public static void setExternalId(List<Account_Treatment_Job__c> accountTreatmentJobs) {
        SObjectServiceClass.updateExternalId('Account_Treatment_Job__c', 'Account_Treatment_Job_Number__c', 'External_Id__c', accountTreatmentJobs);
    }

    public static void updateAccountTreatmentIsPortalSync(List<Account_Treatment_Job__c> ATJs) {
        List<String> ATQueryFields = new List<String>{'Is_Portal_Sync__c'};

        List<Account_Treatment__c> accountTreatments = new List<Account_Treatment__c>();
        List<String> ATIds = new List<String>();

        for(Account_Treatment_Job__c atj : ATJs) {
            ATIds.add(atj.Patient_Treatment__c);
        }

        accountTreatments = AccountTreatmentDAO.getAccountTreatmentsFromIds(ATQueryFields, ATIds);

        if(!accountTreatments.isEmpty()) {
            SObjectServiceClass.updateGenericField('Account_Treatment__c', '03', 'Is_Portal_Sync__c', accountTreatments);
        }
    }

    public static void updateServiceAppointmentHasFrequency(List<Account_Treatment_Job__c> ATJs) {
        System.debug('----- updateServiceAppointmentHasFrequency -----');
        
        List<String> workOrderQueryFields = new List<String>{'Account_Treatment_Job__c', 'Account_Treatment_Job__r.Frequency__c', 
        'Account_Treatment_Job__r.Frequency_Unit_of_measure__c', 'Account_Treatment_Job__r.Frequency_Type__c'};
        List<String> serviceAppointmentQueryFields = new List<String>{'ParentRecordId'};

        List<String> ATJIds = new List<String>();
        List<String> relatedWorkOrderIds = new List<String>();
        List<WorkOrder> relatedWorkOrders = new List<WorkOrder>();
        List<ServiceAppointment> relatedServiceAppointments = new List<ServiceAppointment>();

        Map<String, WorkOrder> workOrderMap = new Map<String, WorkOrder>();

        for(Account_Treatment_Job__c atj : ATJs) {
            ATJIds.add(atj.Id);
        }

        relatedWorkOrders = WorkOrderDAO.getWorkOrdersFromATJIds(workOrderQueryFields, ATJIds);

        if(!relatedWorkOrders.isEmpty()) {
            for(WorkOrder wo : relatedWorkOrders) {
                relatedWorkOrderIds.add(wo.Id);
                workOrderMap.put(wo.Id, wo);
            }

            relatedServiceAppointments = ServiceAppointmentDAO.getAllSAsFromParentIds(serviceAppointmentQueryFields, relatedWorkOrderIds);

            if(!relatedServiceAppointments.isEmpty()) {
                ServiceAppointmentTriggerService.setHasFrequency(relatedServiceAppointments, workOrderMap);
                List<Database.SaveResult> results = Database.update(relatedServiceAppointments, false);
            }
        }
    }

    public static void scheduleActivities(String accountTreatmentJobId, Datetime startDatetimeWO, Datetime startDatetimeTask) {
        List<String> ATJQueryFields = new List<String>{'Patient_Treatment__c', 'Contract_Treatment_Job__c'};

        List<Account_Treatment_Job__c> accountTreatmentJobList = AccountTreatmentJobDAO.getATJSFROMIds(ATJQueryFields, new List<String>{accountTreatmentJobId});
        Account_Treatment_Job__c accountTreatmentJob = accountTreatmentJobList[0];

        // Launching autoscheduling batch with these parameters to let it schedule only accountTreatmentJob and selected startDatetimes as activities' DueDates

        AutoscheduleActivitiesTherapyBatch autoschedulingBatch = new AutoscheduleActivitiesTherapyBatch();
        autoschedulingBatch.accountTreatmentIds = new List<String>{accountTreatmentJob.Patient_Treatment__c};
        autoschedulingBatch.accountTreatmentJobId = accountTreatmentJobId;
        autoschedulingBatch.startDatetimeWO = startDatetimeWO;
        autoschedulingBatch.startDatetimeTask = startDatetimeTask;

        Database.executeBatch(autoschedulingBatch, 1);
    }
}