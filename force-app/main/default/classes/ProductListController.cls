public with sharing class ProductListController {

	@AuraEnabled(cacheable=true)
	public static List<Account_Treatment_Job_Product__c> getSelectedProducts(String selectedjobid2) {
		return AccountTreatmentJobProductDAO.getSelectedProducts(selectedjobid2);
	}

}