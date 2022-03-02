public with sharing class ContractAssetDAO {
    public static List<Contract_Asset__c> getContractAssetsFromCTIds(List<String> queryFields, List<String> CTIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        	query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Contract_Asset__c WHERE Contract_Treatment__c IN: CTIds';
        System.debug('getContractAssetsFromCTIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Contract_Asset__c> getContractAssets(String searchKey, String contractTreatmentJob , String contractTreatment ,List<String> preselectedrowslistasset,List<String> assetIds) {

        String query = 'Select Asset__r.Id,Asset__r.Product2Id,Asset__r.Product2.Product_Name_Translate__c,Asset__r.Product2.Product_Code__c,Asset__r.Product2.Product_Family__r.Product_Name_Translate__c,Asset__r.Product2.Manufacturer_part_number__c,Asset__r.SerialNumber,Asset__r.Manufacturer_ID__c,Asset__r.AssetProvidedById,Asset__r.AssetServicedById,Asset__c,Status__c  From Contract_Asset__c ';
        String Active = 'Active' ;
        if(searchKey != null && searchKey != '') {
			String key = '%' + searchKey + '%';
			if(preselectedrowslistasset != null && preselectedrowslistasset.size() > 0) {
				query += ' WHERE Contract_Treatment_Job__c =:contractTreatmentJob AND Contract_Treatment__c =:contractTreatment AND Status__c =:Active AND (Asset__r.Product2.Product_Name_Translate__c LIKE :key OR Asset__r.Product2.Product_Code__c LIKE :key OR Asset__r.Manufacturer_ID__c LIKE :key OR Asset__r.Product2.Manufacturer_part_number__c LIKE :key OR Asset__r.SerialNumber LIKE :key OR Asset__r.Product2.Product_Family__r.Product_Name_Translate__c LIKE :key OR Asset__c In :preselectedrowslistasset) ';
			} else {
				query += ' WHERE Contract_Treatment_Job__c =:contractTreatmentJob AND Contract_Treatment__c =:contractTreatment AND Status__c =:Active AND (Asset__r.Product2.Product_Name_Translate__c LIKE :key OR Asset__r.Product2.Product_Code__c LIKE :key OR Asset__r.Manufacturer_ID__c LIKE :key OR Asset__r.Product2.Manufacturer_part_number__c LIKE :key OR Asset__r.SerialNumber LIKE :key OR Asset__r.Product2.Product_Family__r.Product_Name_Translate__c LIKE :key) ';
			}
			if(assetIds.size() > 0 ){
				query += ' AND Asset__c NOT IN :assetIds' ;
			}
		} else  if (assetIds.size() > 0) {
			query += ' Where Asset__c NOT IN :assetIds' ;
		}

		system.debug(query);
		return Database.query(query);
    }
}