public class TreatmentProductSelectionService{

	public static void createAccountProductbyId(List<String> selectedproducts, String atjid){
		List<String> nonMatchedProductcs = selectedproducts;
		
		system.debug('after' + nonMatchedProductcs);
		List<Account_Treatment_Job__c> q3 = AccountTreatmentJobDAO.getContractTreatmentJob(atjid);
		Id contractTreatmentJobId = q3[0].Contract_Treatment_Job__c;
		List<Account_Treatment_Job_Product__c> atjpupdatelist = new List<Account_Treatment_Job_Product__c>();
		List<Contract_Treatment_Job_Product__c> ctjpQueryFinal = new List<Contract_Treatment_Job_Product__c>();
		List<Id> productfamilies = new List<Id>();
		List<String> queryfields = new List<String>{'Product_Family__c'};
		List<Product2> q1 = Product2DAO.getProduct2sFromIds(queryfields, nonMatchedProductcs);
		//    Map<Id, Id> productfamilyandIdMap = new Map<Id, Id>();
		Map<Id, Id> productAndProductFamily = new Map<Id, Id>();
		for (Product2 p : q1){
			productfamilies.add(p.Product_Family__c);
			//    productfamilyandIdMap.put(p.Product_Family__c, p.Id);
			productAndProductFamily.put(p.Id, p.Product_Family__c);
		}
		ctjpQueryFinal = [SELECT Id, Product__c, Frequency__c, Frequency_Unit_of_measure__c, Max_Quantity__c, Min_Quantity__c, Quantity_Unit_of_measure__c, 
						  Invoice_Splitting_group__c, Purchase_order_number__c, Purchase_order_date__c, Customer_Treatment_Alias__c, Billable__c, 
						  Customer_Request_Code__c, Quantity__c, Plant__c, Storage_Location__c 
		                  FROM Contract_Treatment_Job_Product__c
		                  WHERE (Contract_Treatment_Job__c = :contractTreatmentJobId) AND (Product__c IN :nonMatchedProductcs OR Product__c IN :productfamilies)];
		Map<Id, Contract_Treatment_Job_Product__c> productAndCtjp = new Map<Id, Contract_Treatment_Job_Product__c>();
		for (Contract_Treatment_Job_Product__c ctjp : ctjpQueryFinal){
			productAndCtjp.put(ctjp.Product__c, ctjp);
		}


		for (Integer i = 0; i < nonMatchedProductcs.size(); i++){
			List<Contract_Treatment_Job_Product__c> listCtjp = new List<Contract_Treatment_Job_Product__c>();
			if (productAndCtjp.containsKey(nonMatchedProductcs[i])){
				Contract_Treatment_Job_Product__c ctjp = productAndCtjp.get(nonMatchedProductcs[i]);
				listCtjp.add(ctjp);
			} else{
				Id productfamily = productAndProductFamily.get(nonMatchedProductcs[i]);
				Contract_Treatment_Job_Product__c ctjp = productAndCtjp.get(productfamily);
				listCtjp.add(ctjp);
			}
			Contract_Treatment_Job_Product__c productQueryFinal = listCtjp[0];
			Account_Treatment_Job_Product__c atjp = new Account_Treatment_Job_Product__c();
			// if (productfamilyandIdMap.containsKey(productQueryFinal.Product__c)){
			//     atjp.Product__c = productfamilyandIdMap.get(productQueryFinal.Product__c);
			// } else{
			//     atjp.Product__c = productQueryFinal.Product__c;
			// }
			atjp.Product__c = nonMatchedProductcs[i];
			atjp.Patient_Treatment_Job__c = atjid;
			atjp.Contract_Treatment_Job_Product__c = productQueryFinal.Id;
			atjp.Max_Quantity__c = productQueryFinal.Max_Quantity__c;
			atjp.Min_Quantity__c = productQueryFinal.Min_Quantity__c;
			atjp.Quantity_Unit_of_measure__c = productQueryFinal.Quantity_Unit_of_measure__c;
			atjp.Frequency__c = productQueryFinal.Frequency__c;
			atjp.Frequency_Unit_of_measure__c = productQueryFinal.Frequency_Unit_of_measure__c;
			atjp.Billable__c = productQueryFinal.Billable__c;
			atjp.Invoice_Splitting_group__c = productQueryFinal.Invoice_Splitting_group__c;
			atjp.Purchase_order_number__c = productQueryFinal.Purchase_order_number__c;
			atjp.Purchase_order_date__c = productQueryFinal.Purchase_order_date__c;
			atjp.Customer_Treatment_Alias__c = productQueryFinal.Customer_Treatment_Alias__c;
			atjp.Customer_Request_Code__c = productQueryFinal.Customer_Request_Code__c;
			atjp.Quantity__c = productQueryFinal.Quantity__c;
			atjp.Plant__c = productQueryFinal.Plant__c;
			atjp.Storage_Location__c = productQueryFinal.Storage_Location__c;
			atjpupdatelist.add(atjp);
		}
		System.debug('selectedjobs' + nonMatchedProductcs);
		insert atjpupdatelist;
		System.debug(atjpupdatelist);
	}

	public static void createAccountAssetbyId(List<String> selectedasset, String atjid){
		List<String> nonMatchedassets = new List<String>();
		List<String> assetIds = getselectedassetbyAtjId(atjid);
		if (selectedasset.size() > 0 && assetIds.size() > 0){
			for (Integer i = 0; i < selectedasset.size(); i++){
				if (!assetIds.contains(selectedasset[i])){
					nonMatchedassets.add(selectedasset[i]);
				}
			}
		}
		System.debug('before' + nonMatchedassets);
		if (assetIds.size() < 1){
			for (Integer i = 0; i < selectedasset.size(); i++){
				nonMatchedassets.add(selectedasset[i]);
			}
		}
		system.debug('after' + nonMatchedassets);
		List<String> queryFieldsForAsset = new List<String>{'Product2Id', 'Id'};
		List<Asset> assetQuery = AssetDAO.getAssetsFromIds(queryFieldsForAsset, nonMatchedassets);
		List<Account_Treatment_Job_Product__c> atjpupdatelist = new List<Account_Treatment_Job_Product__c>();
		for (Integer i = 0; i < assetQuery.size(); i++){
			Account_Treatment_Job_Product__c atjp = new Account_Treatment_Job_Product__c();
			atjp.Product__c = assetQuery[0].Product2Id;
			atjp.Patient_Treatment_Job__c = atjid;
			atjp.Asset__c = assetQuery[i].Id;
			atjpupdatelist.add(atjp);
		}
		insert atjpupdatelist;
		System.debug(atjpupdatelist);
	}

	public static List<String> getAtjpByAtjId(String atjid){
		List<String> productsids2 = new List<String>();
		List<String> queryforproducts = new List<String>{'Product__c'};
		List<Account_Treatment_Job_Product__c> productsids1 = AccountTreatmentJobProductDAO.getProductsFromATJs(queryforproducts, atjid);
		for (Integer i = 0; i < productsids1.size(); i++){
			productsids2.add(productsids1[i].Product__c);
		}
		return productsids2;
	}

	public static List<String> getselectedassetbyAtjId(String atjid){
		List<String> assetids2 = new List<String>();
		List<String> assetids3 = new List<String>();
		List<String> queryforassets = new List<String>{'Product__c'};
		List<Account_Treatment_Job_Product__c> assetids1 = AccountTreatmentJobProductDAO.getProductsFromATJs(queryforassets, atjid);
		for (Integer i = 0; i < assetids1.size(); i++){
			assetids2.add(assetids1[i].Product__c);
		}
		List<String> queryFieldsForAssetQuery1 = new List<String>{'Product2Id', 'Id'};
		List<Asset> assetQuery1 = AssetDAO.getAssetsFromIds(queryFieldsForAssetQuery1, assetids2);
		for (Integer i = 0; i < assetQuery1.size(); i++){
			assetids3.add(assetQuery1[i].Id);
		}
		return assetids3;
	}
}