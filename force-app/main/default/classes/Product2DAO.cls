public with sharing class Product2DAO {

	public static List<Product2> Product2byId(List<Id> query1Ids, String searchKey, List<String> preselectedrowslist) {
		String query = 'Select Product_Name_Translate__c, Product_Code__c, Product_Family__r.Product_Name_Translate__c, Manufacturer_part_number__c, Id From Product2 WHERE (Product_Family__c IN :query1Ids OR Id IN :query1Ids) AND Product_Family__c != NULL ';

		if(searchKey != null && searchKey != '') {
			String key = '%' + searchKey + '%';
			if(preselectedrowslist != null && preselectedrowslist.size() > 0) {
				query += ' AND (Product_Name_Translate__c LIKE :key OR Manufacturer_part_number__c LIKE :key OR Product_Family__r.Product_Name_Translate__c LIKE :key OR Product_Code__c LIKE :key OR Id IN :preselectedrowslist)';
			} else {
				query += ' AND (Product_Name_Translate__c LIKE :key OR Manufacturer_part_number__c LIKE :key OR Product_Family__r.Product_Name_Translate__c LIKE :key OR Product_Code__c LIKE :key)';
			}
		}

		system.debug(query);
		return Database.query(query);

	}

	public static List<Product2> Product2byIdByPreviousProducts(List<Id> query1Ids, String searchKey, List<String> preselectedrowslist, List<String> productIds, List<Id> productIdspricebook) {
		String query = 'Select Product_Name_Translate__c, Product_Code__c, Product_Family__r.Product_Name_Translate__c, Manufacturer_part_number__c, Id,Status__c,IsActive  From Product2 WHERE (Product_Family__c IN :query1Ids OR Id IN :query1Ids) AND Product_Family__c != NULL AND Id IN :productIdspricebook AND IsActive = True ';

		if(searchKey != null && searchKey != '') {
			String key = '%' + searchKey + '%';
			if(preselectedrowslist != null && preselectedrowslist.size() > 0) {
				query += ' AND (Product_Name_Translate__c LIKE :key OR Manufacturer_part_number__c LIKE :key OR Product_Family__r.Product_Name_Translate__c LIKE :key OR Product_Code__c LIKE :key OR Id IN :preselectedrowslist)';
			} else {
				query += ' AND (Product_Name_Translate__c LIKE :key OR Manufacturer_part_number__c LIKE :key OR Product_Family__r.Product_Name_Translate__c LIKE :key OR Product_Code__c LIKE :key)';
			}
		}
		if(productIds.size() > 0) {
			query+= 'AND  Id NOT IN :productIds';
		}
		query+= ' LIMIT 50';
		system.debug(query);
		return Database.query(query);

	}
	public static List<Product2> getthesubproductsoffamilies(List<Id> productfamiliesids) {
		
		String query = 'Select Id,Type__c ,Product_Family__c  From Product2 WHERE Product_Family__c IN : productfamiliesids ';
		system.debug(query);
		return Database.query(query);

	}

	public static List<Product2> getProduct2sFromIds(List<String> queryFields, List<Id> relatedIds) {
		String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Product2 WHERE Id IN: relatedIds';
        System.debug('getProduct2sFromIds QUERY: ' + query);
        return Database.query(query);
	}

}