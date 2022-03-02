public class ContractTreatmentJobDetailController {

    @AuraEnabled
    public static void propagateDeliveryChannel (String contractTreatmentJobId){
        system.debug('propagateDeliveryChannel ---- contract treatment job: ' + contractTreatmentJobId);
        List<String> jobs = new List<String>();
        List<Contract_Treatment_Job__c> jobList = [SELECT id, Status__c, Delivery_Channel__c, Last_Propagated_Delivery_Channel__c from Contract_Treatment_Job__c WHERE id = :contractTreatmentJobId];
        jobs.add(contractTreatmentJobId); 
        BatchPropagateDeliveryChannel batchDeliveryChannel = new BatchPropagateDeliveryChannel();

        batchDeliveryChannel.contractTreatmentJobIds = jobs;
        batchDeliveryChannel.contractTreatmentJobs = jobList;

        Database.executeBatch(batchDeliveryChannel, 1000);
        List<Contract_Treatment_Job__c> updatedJobs = new List<Contract_Treatment_Job__c>();
        for (Contract_Treatment_Job__c ctj : jobList){
            ctj.Last_Propagated_Delivery_Channel__c = ctj.Delivery_Channel__c;
            updatedJobs.add(ctj);
        }
        update updatedJobs;
    }

    @AuraEnabled
    public static void propagateFrequency (String contractTreatmentJobId){
        system.debug('propagateFrequency ---- contract treatment job: ' + contractTreatmentJobId);
        List<String> jobs = new List<String>();
        List<Contract_Treatment_Job__c> jobList = [SELECT id, Status__c, Frequency__c, Frequency_Unit_of_measure__c, Frequency_Type__c, Last_Propagated_Frequency_Type__c, 
            Last_Propagated_Frequency__c, Last_Propagated_Frequency_UOM__c, Scheduling_Time_Frame__c FROM Contract_Treatment_Job__c WHERE id = :contractTreatmentJobId];
        jobs.add(contractTreatmentJobId); 
        BatchPropagateFrequencyToATJ batchFrequency = new BatchPropagateFrequencyToATJ();

        batchFrequency.contractTreatmentJobIds = jobs;
        batchFrequency.contractTreatmentJobs = jobList;

        Database.executeBatch(batchFrequency, 1000);
        List<Contract_Treatment_Job__c> updatedJobs = new List<Contract_Treatment_Job__c>();
        for (Contract_Treatment_Job__c ctj : jobList){
            ctj.Last_Propagated_Frequency__c = ctj.Frequency__c;
            ctj.Last_Propagated_Frequency_UOM__c = ctj.Frequency_Unit_of_measure__c;
            ctj.Last_Propagated_Frequency_Type__c = ctj.Frequency_Type__c;
            updatedJobs.add(ctj);
        }
        update updatedJobs;
    }

    @AuraEnabled
    public static Boolean getShowFrequencyButton(String contractTreatmentJobId){
        system.debug('getShowFrequencyButton ---- contract treatment job: ' + contractTreatmentJobId);
        List<String> jobs = new List<String>();
        List<Contract_Treatment_Job__c> jobList = [SELECT id, Frequency__c, Frequency_Unit_of_measure__c, Frequency_Type__c, Contract_Framework__r.Status__c,
        Last_Propagated_Frequency__c, Last_Propagated_Frequency_UOM__c, Last_Propagated_Frequency_Type__c FROM Contract_Treatment_Job__c WHERE id = :contractTreatmentJobId];
        List<Task> autoscheduledTasks = [SELECT Id FROM Task WHERE Account_Treatment_Job__r.Contract_Treatment_Job__c =: contractTreatmentJobId AND Autoscheduled__c = true];
       
        if (!jobList.isEmpty()){
            system.debug(jobList[0]);
            if (jobList[0].Contract_Framework__r.Status__c == 'Active' && (jobList[0].Frequency__c != jobList[0].Last_Propagated_Frequency__c || 
                jobList[0].Frequency_Unit_of_measure__c != jobList[0].Last_Propagated_Frequency_UOM__c || 
                jobList[0].Frequency_Type__c != jobList[0].Last_Propagated_Frequency_Type__c)){
                if(autoscheduledTasks != null && !autoscheduledTasks.isEmpty()) {
                    return true;
                }
                else {
                    List<WorkOrder> autoscheduledWorkOrders = [SELECT Id FROM WorkOrder 
                                                               WHERE Account_Treatment_Job__r.Contract_Treatment_Job__c =: contractTreatmentJobId 
                                                               AND Autoscheduled__c = true];

                    if(autoscheduledWorkOrders != null && !autoscheduledWorkOrders.isEmpty()) {
                        return true;
                    }
                    else {
                        return false;
                    }
                }
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    @AuraEnabled
    public static Boolean getShowDeliveryButton(String contractTreatmentJobId){
        system.debug('getShowDeliveryButton --- contract treatment job: ' + contractTreatmentJobId);
        List<String> jobs = new List<String>();
        List<Contract_Treatment_Job__c> jobList = [SELECT id, Delivery_Channel__c, Last_Propagated_Delivery_Channel__c, Contract_Framework__r.Status__c 
        FROM Contract_Treatment_Job__c WHERE id = :contractTreatmentJobId];
        if (!jobList.isEmpty()){
            system.debug(jobList[0]);
            if (jobList[0].Last_Propagated_Delivery_Channel__c != jobList[0].Delivery_Channel__c && jobList[0].Contract_Framework__r.Status__c == 'Active'){
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    
    }

    @AuraEnabled
    public static Boolean checkForSLAWarningMessage(String contractTreatmentJobId){
        System.debug('----- checkForSLAWarningMessage -----');
        System.debug('CTJ.Id: ' + contractTreatmentJobId);

        Contract_Treatment_Job__c CTJ = [SELECT Scheduling_Rule__c FROM Contract_Treatment_Job__c WHERE Id =: contractTreatmentJobId];

        System.debug('CTJ.SchedulingRule: ' + CTJ.Scheduling_Rule__c);

        if(CTJ.Scheduling_Rule__c != null) {
            List<Contract_Treatment_Job_SLA__c> relatedSLAs = [SELECT Id FROM Contract_Treatment_Job_SLA__c WHERE Contract_Treatment_Job__c =: contractTreatmentJobId];

            if(relatedSLAs == null || relatedSLAs.isEmpty()) {
                return true;
            }
        }
        
        return false;
    }
}