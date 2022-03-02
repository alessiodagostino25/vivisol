public with sharing class TreatmentProductSelectionController {
	
	@AuraEnabled(cacheable = true) 
	public static List<Product2DTO> getProducts(String searchKey, String selectedjobid, String selectedrecordtype ,List<String> preselectedrowslist )  {
		List<String> productIds =  new List<String>();
		List<Id> queryResults = new List<Id>();
		List<Id> productIdspricebook = new List<Id>();
		List<Id> query1Ids = new List<Id>();
		List<Product2DTO> DTOsToReturn = new List<Product2DTO>();
		List<Account_Treatment_Job__c> query1 = AccountTreatmentJobDAO.getContractTreatmentJob(selectedjobid);

		for(Integer i = 0; i < query1.size(); i ++) {
			queryResults.add(query1.get(i).Contract_Treatment_Job__c);
		}

		Contract_Treatment_Job__c ctj = [SELECT Contract_Framework__r.Price_list_code__c FROM Contract_Treatment_Job__c WHERE Id =: queryResults];
		List<PricebookEntry> pricebookEntries = [SELECT Product2Id,IsActive FROM PricebookEntry 
												 WHERE Pricebook2Id =: ctj.Contract_Framework__r.Price_list_code__c AND IsActive = TRUE];
		
        for(PricebookEntry pe : pricebookEntries) {
            productIdspricebook.add(pe.Product2Id);
        }

		List<Contract_Treatment_Job_Product__c> query = ContractTreatmentJobProductDAO.getContractTreatmentJobProduct(queryResults);

		for(Integer i = 0; i < query.size(); i ++) {
			query1Ids.add(query.get(i).Product__c);
		}

		List<Product2> products = Product2DAO.Product2byIdByPreviousProducts(query1Ids, searchKey, preselectedrowslist, productIds, productIdspricebook);

		if(products != null && !products.isEmpty()) {
			for(Product2 product : products) {
				Product2DTO dto = new Product2DTO(product);
				DTOsToReturn.add(dto);
			}
		}

		return DTOsToReturn;
	}

	@AuraEnabled(cacheable = true)
	public static List<ContractAssetDTO> getAsset(String searchKey , List<String> preselectedrowslistasset ,String selectedjobid ) {
		List<ContractAssetDTO> DTOsToReturn = new List<ContractAssetDTO>();
		List<String> assetIds =  new List<String>();

		List<Account_Treatment_Job_Product__c> previousSelectedProducts =  [SELECT Asset__c,Patient_Treatment_Job__c FROM Account_Treatment_Job_Product__c 
																			WHERE Patient_Treatment_Job__c = : selectedjobid];
		List<Account_Treatment_Job__c> atj = [SELECT Contract_Treatment_Job__c,Contract_Treatment_Job__r.Contract_Treatment__c FROM Account_Treatment_Job__c 
											  WHERE Id = : selectedjobid ];

		String contractTreatmentJob = atj[0].Contract_Treatment_Job__c ;
		String contractTreatment  = atj[0].Contract_Treatment_Job__r.Contract_Treatment__c  ;

		for(Integer i =0;i<previousSelectedProducts.size();i++){
			assetIds.add(previousSelectedProducts[i].Asset__c);
		}

		List<Contract_Asset__c> contractAssets = ContractAssetDAO.getContractAssets(searchKey,contractTreatmentJob,contractTreatment,preselectedrowslistasset,assetIds);

		if(contractAssets != null && !contractAssets.isEmpty()) {
			for(Contract_Asset__c contractAsset : contractAssets) {
				ContractAssetDTO dto = new ContractAssetDTO(contractAsset);
				DTOsToReturn.add(dto);
			}
		}

		return DTOsToReturn;
	}   


	@AuraEnabled
	public static void createAccountProduct(List<String> selectedproducts, String atjid) {
		TreatmentProductSelectionService.createAccountProductbyId(selectedproducts, atjid);
	}

    @AuraEnabled
    public static void createAccountAsset( List<String> selectedasset, String atjid) {
		TreatmentProductSelectionService.createAccountAssetbyId(selectedasset, atjid) ;
    }

}