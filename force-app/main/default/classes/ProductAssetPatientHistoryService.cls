public class ProductAssetPatientHistoryService {
    public static void setExternalId(List<Product_Asset_Patient_History__c> PAPHs) {
        if(!System.isBatch()) {
            List<String> PAPHIds = new List<String>();

            for(Product_Asset_Patient_History__c paph : PAPHs) {
                PAPHIds.add(paph.Id);
            }

            SObjectServiceClass.updateExternalIdFuture('Product_Asset_Patient_History__c', 'Name', 'External_Id__c', PAPHIds);
        }
        else {
            SObjectServiceClass.updateExternalId('Product_Asset_Patient_History__c', 'Name', 'External_Id__c', PAPHs);
        }
    }

    public static void setIsPortalSync(List<Product_Asset_Patient_History__c> PAPHs, Map<Id, Product_Asset_Patient_History__c> oldMap, Boolean performDML) {
        SObjectServiceClass.setIsPortalSync(PAPHs, oldMap, 'Product_Asset_Patient_History__c', false, performDML);
    }
}