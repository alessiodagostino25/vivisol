public class ContractAssetTriggerService{
	
    public static void ContractAssetTriggerServicemethod(List<Contract_Asset__c>  ContractAssets){
        List<Id> caIds = new List<Id>();
        List<Id> caAssetIds = new List<Id>();
        List<id> caCTIds = new List<id>();
        List<String> queryFieldsForatjp = new List<String>{'Id', 'Status__c'};
        List<Account_Treatment_Job_Product__c> updateatjps = new List<Account_Treatment_Job_Product__c>();
        for (Contract_Asset__c ca : ContractAssets){
            if (ca.Status__c == 'Inactive'){
                caIds.add(ca.Id);
                caAssetIds.add(ca.Asset__c);
                caCTIds.add(ca.Contract_Treatment__c);
            }
        }
        List<Account_Treatment_Job_Product__c> atjps = AccountTreatmentJobProductDAO.getcontractassetrelatedATJs(queryFieldsForatjp, caCTIds, caAssetIds);
        for (Account_Treatment_Job_Product__c atjp : atjps){
            atjp.Status__c = 'Inactive';
            updateatjps.add(atjp);
        }
        update updateatjps;
    }
}