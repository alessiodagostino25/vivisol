public with sharing class AssetDAO {
	
	public static List<Asset> getAssetbyName(String searchKey,List<String> preselectedrowslistasset) {
		String query = 'Select Product2Id,Product2.Product_Name_Translate__c,Product2.Product_Code__c,Product2.Product_Family__r.Product_Name_Translate__c,Product2.Manufacturer_part_number__c,SerialNumber,Label__c,Manufacturer_ID__c,AssetProvidedById,AssetServicedById,Id From Asset';
		if(searchKey != null && searchKey != '') {
			String key = '%' + searchKey + '%';

			if(preselectedrowslistasset != null && preselectedrowslistasset.size() > 0) {
				query += ' WHERE Product2.Product_Name_Translate__c LIKE :key OR Product2.Product_Code__c LIKE :key OR Manufacturer_ID__c LIKE :key OR Product2.Manufacturer_part_number__c LIKE :key OR SerialNumber LIKE :key OR Label__c LIKE :key OR Product2.Product_Family__r.Product_Name_Translate__c LIKE :key OR Id In :preselectedrowslistasset ';
			} else {
				query += ' WHERE Product2.Product_Name_Translate__c LIKE :key OR Product2.Product_Code__c LIKE :key OR Manufacturer_ID__c LIKE :key OR Product2.Manufacturer_part_number__c LIKE :key OR SerialNumber LIKE :key OR Label__c LIKE :key ';
			}
		}	
		system.debug(query);
		return Database.query(query);
	}

	public static List<Asset> getAssetbyName2(String searchKey,List<String> preselectedrowslistasset,List<String> assetIds) {
		String query = 'Select Product2Id,Product2.Product_Name_Translate__c,Product2.Product_Code__c,Product2.Product_Family__r.Product_Name_Translate__c ' + 
		',Product2.Manufacturer_part_number__c,SerialNumber,Label__c,Manufacturer_ID__c,AssetProvidedById,AssetServicedById,Id From Asset ';
		if(searchKey != null && searchKey != '') {
			String key = '%' + searchKey + '%';
			if(preselectedrowslistasset != null && preselectedrowslistasset.size() > 0) {
				query += ' WHERE (Product2.Product_Name_Translate__c LIKE :key OR Product2.Product_Code__c LIKE :key OR Manufacturer_ID__c LIKE :key OR Product2.Manufacturer_part_number__c LIKE :key OR SerialNumber LIKE :key OR Label__c LIKE :key OR Product2.Product_Family__r.Product_Name_Translate__c LIKE :key OR Id In :preselectedrowslistasset) ';
			} else {
				query += ' WHERE (Product2.Product_Name_Translate__c LIKE :key OR Product2.Product_Code__c LIKE :key OR Manufacturer_ID__c LIKE :key OR Product2.Manufacturer_part_number__c LIKE :key OR SerialNumber LIKE :key OR Label__c LIKE :key) ';
			}
			if(assetIds.size() > 0 ){
				query += ' AND Id NOT IN :assetIds' ;
			}
		} else  if (assetIds.size() > 0) {
			query += ' Where Id NOT IN :assetIds' ;
		}

		system.debug(query);
		return Database.query(query);
	}

	public static List<Asset> getAssetbyequipmentkey(List<String> serialNumbers) {
		return [SELECT Id,Equipment_Key__c FROM Asset WHERE Equipment_Key__c  IN : serialNumbers] ;
	}

	public static List<Asset> getAssetsFromIds(List<String> queryFields, List<Id> relatedIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        	query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Asset WHERE Id IN: relatedIds';
        System.debug('getAssetsFromIds QUERY: ' + query);
        
        return Database.query(query);
	}

	public static List<Asset> getAssetsFromIds(List<String> queryFields, List<String> relatedIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        	query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Asset WHERE Id IN: relatedIds';
        System.debug('getAssetsFromIds QUERY: ' + query);
        
        return Database.query(query);
	}
	
	public static List<Asset> getAssetbyId(List<Id> assetIds) {
		return [SELECT Id,LocationId FROM Asset WHERE Id  IN : assetIds] ;
	}

	public static List<Asset> getAssetsFromEquipmentKey(List<String> queryFields, List<String> equipmentKeys) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        	query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Asset WHERE Equipment_Key__c IN: equipmentKeys';
        System.debug('getAssetsFromEquipmentKey QUERY: ' + query);
        
        return Database.query(query);
	}
}