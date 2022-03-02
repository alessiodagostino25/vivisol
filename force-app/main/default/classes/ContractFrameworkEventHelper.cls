public class ContractFrameworkEventHelper {
    @testVisible
    private static List<Contract__e> contracteventsUpdate = new List<Contract__e>();

    @AuraEnabled
    public static void createEvent(List<Id> cfIds) {
        List<Contract_Framework__c> contractFrameworks = ContractFrameworkDAO.getContractFrameworkFromListId(cfIds);

        List<Contract_Framework__c> cfUpdate = new List<Contract_Framework__c>();
        for (Integer i = 0; i < contractFrameworks.size(); i++) {
            Contract__e contractEvent = new Contract__e();
            contractEvent.Contract_Number__c = contractFrameworks[i].Contract_Number__c;
            contractEvent.Name__c = contractFrameworks[i].Name;
            contractEvent.Contract_End_date__c = contractFrameworks[i].Contract_End_Date__c;
            contractEvent.Contract_Start_date__c = contractFrameworks[i].Contract_Start_date__c;
            contractEvent.Sales_Organization__c = contractFrameworks[i].Sales_Organization__c;
            contractEvent.Distribution_Channel__c = contractFrameworks[i].Distribution_Channel__c;
            contractEvent.Division__c = contractFrameworks[i].Division__c;
            contractEvent.Contract_Type__c = contractFrameworks[i].Contract_Type__c;
            contractEvent.ContractFrameWorkId__c = contractFrameworks[i].Id;
            contractEvent.Customer__c = contractFrameworks[i].Customer__r.Account_External_Id__c;
            contracteventsUpdate.add(contractEvent);
            contractFrameworks[i].IsSyncSAP__c = 'Sync';
            cfUpdate.add(contractFrameworks[i]);
            System.debug('PLATFORM EVENT: ' + contractEvent);
        }
        List<Database.SaveResult> createevents = EventBus.publish(contracteventsUpdate);
        update cfUpdate;
    }

    /**
     * @author: Giacomo.
     * @description: this method checks if two contract framework (old and new) are dirrent each other
     */
    public static Boolean isContractUpdated(Contract_Framework__c newFramework, Contract_Framework__c oldFramework){
        if (newFramework.Contract_Number__c != oldFramework.Contract_Number__c){
            return true;
        }
        if (newFramework.Name != oldFramework.Name){
            return true;
        }
        if (newFramework.Contract_Start_date__c != oldFramework.Contract_Start_date__c){
            return true;
        }
        if (newFramework.Contract_End_date__c != oldFramework.Contract_End_date__c){
            return true;
        }        
        if (newFramework.Sales_Organization__c != oldFramework.Sales_Organization__c){
            return true;
        }        
        if (newFramework.Distribution_Channel__c != oldFramework.Distribution_Channel__c){
            return true;
        }
        if (newFramework.Division__c != oldFramework.Division__c){
            return true;
        }
        if (newFramework.Contract_Type__c != oldFramework.Contract_Type__c){
            return true;
        }
        if (newFramework.Customer__c != oldFramework.Customer__c){
            return true;
        }
        if (newFramework.Status__c != oldFramework.Status__c){
            return true;
        }
        return false;
    }
}