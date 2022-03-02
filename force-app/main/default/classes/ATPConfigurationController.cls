public class ATPConfigurationController {

    @AuraEnabled
    public static Boolean getShowQuantityButton(String accountTreatmentJobProductId){
        system.debug('getShowQuantityButton --- account treatment job product: ' + accountTreatmentJobProductId);
        List<Account_Treatment_Job_Product__c> jobList = [SELECT id, Quantity__c, Last_Propagated_Quantity__c from Account_Treatment_Job_Product__c WHERE id = :accountTreatmentJobProductId];
       
        if (!jobList.isEmpty()){
            system.debug(jobList[0]);
            if (jobList[0].Quantity__c != jobList[0].Last_Propagated_Quantity__c){
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }    

    @AuraEnabled
    public static Boolean propagateQuantity(String accountTreatmentJobProductId){
        system.debug('propagateQuantity --- account treatment job product: ' + accountTreatmentJobProductId);
        List<Account_Treatment_Job_Product__c> jobList = [SELECT id, Quantity__c, Last_Propagated_Quantity__c from Account_Treatment_Job_Product__c WHERE id = :accountTreatmentJobProductId];

        for (Integer i = 0; i<jobList.size(); i++){
            jobList[i].Last_Propagated_Quantity__c = jobList[i].Quantity__c;
        }

        BatchPropagateQuantityToWOLI batchUpdateWOLI = new BatchPropagateQuantityToWOLI();
        batchUpdateWOLI.accountTreatmentJobProducts = jobList;
        Database.executeBatch(batchUpdateWOLI, 500);
        update jobList;
        return true;
    }

    @AuraEnabled
    public static Boolean propagateDeleteToWOLI(String accountTreatmentJobProductId){
        List<WOLI_Delete_Configuration__mdt> configs = new List<WOLI_Delete_Configuration__mdt>();
        configs = WOLIDeleteConfigurationDAO.getAllWOLIDeleteConfigs();
        List<String> woliFields = new List<String>();
        Map<String,String> woliFieldValueMap = new Map<String,String>();
        for (WOLI_Delete_Configuration__mdt config : configs){
            woliFields.add(config.Field_API_Name__c);
            woliFieldValueMap.put(config.Field_API_Name__c, config.Field_Value__c);
        }
        
        List<WorkOrderLineItem> queriedWOLIs = WorkOrderLineItemDAO.getWOLIsFromATJP(woliFields, accountTreatmentJobProductId);

        try {
            if (!queriedWOLIs.isEmpty()){
                for(WorkOrderLineItem woli : queriedWOLIs){
                    for (WOLI_Delete_Configuration__mdt config : configs){
                        woli.put(config.Field_API_Name__c, woliFieldValueMap.get(config.Field_API_Name__c));
                    }
                }
                update queriedWOLIs;
                return true;
            } else{
                return true;
            }
        } catch (Exception e){
            system.debug('Exception: ' + e.getMessage());
            return false;
        }
    }    
}