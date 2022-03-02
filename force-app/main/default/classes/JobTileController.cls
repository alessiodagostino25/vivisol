public class JobTileController {

    @AuraEnabled(cacheable = true) 
	public static List<String> getPreviouslySelectedProducts(String atjobid ) {
        List<Account_Treatment_Job_Product__c> previousSelectedProducts =  [SELECT Product__c,Patient_Treatment_Job__c 
            FROM Account_Treatment_Job_Product__c WHERE Patient_Treatment_Job__c = : atjobid];
        List<String> productIds =  new List<String>();
        for(Integer i =0;i<previousSelectedProducts.size();i++){
            productIds.add(previousSelectedProducts[i].Product__c);
        }
        return productIds ;
    }

    @AuraEnabled(cacheable = true) 
    public static void deleteproductsrelatedtoatj(String atjobid ) {
        List<Account_Treatment_Job_Product__c> deleteproducts =  [SELECT Id FROM Account_Treatment_Job_Product__c WHERE Patient_Treatment_Job__c = : atjobid];
        if(deleteproducts.size()>0){
            delete deleteproducts;
        }
    }

    @AuraEnabled
    public static Boolean getShowFrequencyButton(String accountTreatmentJobId){
        system.debug('getShowFrequencyButton ---- account treatment job: ' + accountTreatmentJobId);
        List<Account_Treatment_Job__c> jobList = [SELECT id, Frequency__c, Frequency_Unit_of_measure__c, Frequency_Type__c, 
                                                  Last_Propagated_Frequency__c, Last_Propagated_Frequency_UOM__c, Last_Propagated_Frequency_Type__c 
                                                  FROM Account_Treatment_Job__c WHERE id = :accountTreatmentJobId];
        List<Task> autoscheduledTasks = [SELECT Id FROM Task WHERE Account_Treatment_Job__c =: accountTreatmentJobId AND Autoscheduled__c = true];
       
        if (!jobList.isEmpty()){
            system.debug(jobList[0]);
            if (jobList[0].Frequency__c != jobList[0].Last_Propagated_Frequency__c || jobList[0].Frequency_Unit_of_measure__c != jobList[0].Last_Propagated_Frequency_UOM__c ||
                jobList[0].Frequency_Type__c != jobList[0].Last_Propagated_Frequency_Type__c){
                if(autoscheduledTasks != null && !autoscheduledTasks.isEmpty()) {
                    return true;
                }
                else {
                    List<WorkOrder> autoscheduledWorkOrders = [SELECT Id FROM WorkOrder WHERE Account_Treatment_Job__c =: accountTreatmentJobId AND Autoscheduled__c = true];

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
    public static Boolean getShowDeliveryButton(String accountTreatmentJobId){
        system.debug('getShowDeliveryButton --- account treatment job: ' + accountTreatmentJobId);
        List<Account_Treatment_Job__c> jobList = [SELECT id, Delivery_Channel__c, Last_Propagated_Delivery_Channel__c FROM Account_Treatment_Job__c WHERE id = :accountTreatmentJobId];
       
        if (!jobList.isEmpty()){
            system.debug(jobList[0]);
            if (jobList[0].Last_Propagated_Delivery_Channel__c != jobList[0].Delivery_Channel__c){
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    @AuraEnabled
    public static void propagateDeliveryChannel (String accountTreatmentJobId){
        system.debug('propagateDeliveryChannel ---- contract treatment job: ' + accountTreatmentJobId);
        List<String> jobs = new List<String>();
        List<Account_Treatment_Job__c> jobList = [SELECT id, Status__c, Delivery_Channel__c, Last_Propagated_Delivery_Channel__c from Account_Treatment_Job__c WHERE id = :accountTreatmentJobId];
        jobs.add(accountTreatmentJobId);

        BatchPropagateDeliveryChannel_WO batchDeliveryChannel = new BatchPropagateDeliveryChannel_WO();
        batchDeliveryChannel.accountTreatmentJobs = jobList;
        Database.executeBatch(batchDeliveryChannel, 500);

        List<Account_Treatment_Job__c> updatedJobs = new List<Account_Treatment_Job__c>();
        for (Account_Treatment_Job__c ctj : jobList){
            ctj.Last_Propagated_Delivery_Channel__c = ctj.Delivery_Channel__c;
            updatedJobs.add(ctj);
        }
        update updatedJobs;
    }

    @AuraEnabled
    public static void propagateFrequency (String accountTreatmentJobId){
        system.debug('propagateFrequency ---- contract treatment job: ' + accountTreatmentJobId);
        List<String> jobs = new List<String>();
        List<Account_Treatment_Job__c> jobList = [SELECT id, Status__c, Frequency__c, Frequency_Unit_of_measure__c, Frequency_Type__c, Last_Propagated_Frequency_Type__c, 
            Last_Propagated_Frequency__c, Last_Propagated_Frequency_UOM__c FROM Account_Treatment_Job__c WHERE id = :accountTreatmentJobId];
        jobs.add(accountTreatmentJobId);
        
        BatchPropagateFrequency_WO propagateToWO = new BatchPropagateFrequency_WO();
        propagateToWO.accTreatmentJobs = jobList;
        Database.executeBatch(propagateToWO, 50);

        List<Account_Treatment_Job__c> updatedJobs = new List<Account_Treatment_Job__c>();
        for (Account_Treatment_Job__c ctj : jobList){
            system.debug('Last_Propagated_Frequency__c ---- ' + ctj.Frequency__c);
            system.debug('Frequency_Unit_of_measure__c ---- ' + ctj.Frequency_Unit_of_measure__c);
            ctj.Last_Propagated_Frequency__c = ctj.Frequency__c;
            ctj.Last_Propagated_Frequency_UOM__c = ctj.Frequency_Unit_of_measure__c;
            ctj.Last_Propagated_Frequency_Type__c = ctj.Frequency_Type__c;
            updatedJobs.add(ctj);
        }
        update updatedJobs;
    }

    @AuraEnabled
    public static Boolean getIsScheduleActivitiesDisabled(String accountTreatmentJobId) {
        System.debug('----- getIsScheduleActivitiesDisabled -----');
        System.debug('ATJ Id: ' + accountTreatmentJobId);
        
        List<String> ATJQueryFields = new List<String>{'Contract_Treatment_Job__c', 'Frequency__c', 'Frequency_Unit_of_measure__c', 'Patient_Treatment__c'};
        List<String> SLAQueryFields = new List<String>{'Id'};
        List<String> ATAQueryFields = new List<String>{'Id'};
        
        List<Account_Treatment_Job__c> ATJList = AccountTreatmentJobDAO.getATJSFROMIds(ATJQueryFields, new List<String>{accountTreatmentJobId});
        Account_Treatment_Job__c accountTreatmentJob = ATJList[0];

        if(accountTreatmentJob.Contract_Treatment_Job__c != null) {
            List<Contract_Treatment_Job_SLA__c> relatedSLAs = ContractTreatmentJobSlaDAO.getSLAsFromCTJs(
                SLAQueryFields, 
                new List<String>{accountTreatmentJob.Contract_Treatment_Job__c}
            );
            List<Account_Treatment_Address__c> relatedDefaultATAs = AccountTreatmentAddressDAO.getDefaultATAFromATs(
                ATAQueryFields, 
                new List<String>{accountTreatmentJob.Patient_Treatment__c}
            );

            if(relatedSLAs != null && !relatedSLAs.isEmpty() && relatedDefaultATAs != null && !relatedDefaultATAs.isEmpty()) {
                if(accountTreatmentJob.Frequency__c == null && accountTreatmentJob.Frequency_Unit_of_measure__c == null) {
                    return false;
                }
                else if(accountTreatmentJob.Frequency__c != null && accountTreatmentJob.Frequency_Unit_of_measure__c != null) {
                    List<WorkOrder> relatedAutoscheduledWOs = [SELECT Id FROM WorkOrder 
                                                               WHERE Account_Treatment_Job__c =: accountTreatmentJobId AND Autoscheduled__c = true AND
                                                               IsClosed = false];

                    if(relatedAutoscheduledWOs != null && !relatedAutoscheduledWOs.isEmpty()) {
                        return true;
                    }
                    else {
                        List<Task> relatedAutoscheduledTasks = [SELECT Id FROM Task
                                                                WHERE Account_Treatment_Job__c =: accountTreatmentJobId AND Autoscheduled__c = true 
                                                                AND IsClosed = false];

                        if(relatedAutoscheduledTasks != null && !relatedAutoscheduledTasks.isEmpty()) {
                            return true;
                        }
                        else {
                            List<Case> relatedAutoscheduledCases = [SELECT Id FROM Case
                                                                    WHERE Account_Treatment_Job__c =: accountTreatmentJobId AND Autoscheduled__c = true
                                                                    AND (IsClosed = false OR (IsClosed = true AND ClosedDate = TODAY AND Status != 'Canceled'))];

                            if(relatedAutoscheduledCases != null && !relatedAutoscheduledCases.isEmpty()) {
                                return true;
                            }
                            else {
                                return false;
                            }
                        }
                    }
                }
            }
            else {
                return true;
            }
        }
        
        return true;
    }
}