public class AccountPartnerFunctionService{
	//Identical to AccountTaxClassificationService. Could be deleted
	@future(callout = true)
	public static void futureCreateCallout(List<Id> asoIds){
		if(FeatureManagementService.getFeatureStatus('SAP_SO_Create') || Test.isRunningTest()) {
			List<Account_Sales_Organization__c> asoList = AccountSalesOrganizationDAO.getASOs(asoIds);
			ASOService.makeCreateCallout(asoList);
		}
	}

	@future(callout = true)
	public static void futureUpdateCallout(List<Id> asoIds){
		if(FeatureManagementService.getFeatureStatus('SAP_SO_Update') || Test.isRunningTest()) {
			List<Account_Sales_Organization__c> asoList = AccountSalesOrganizationDAO.getASOs(asoIds);
			ASOService.makeUpdateCallout(asoList);
		}
	}

	public static void updateAccountbill(List<Account_Partner_Function__c> triggernew){
		List<Account_Sales_Organization__c> updateAso = new List<Account_Sales_Organization__c>();
		for (Account_Partner_Function__c apf : triggernew){
			if (apf.Partner_Function__c == 'RE'){
				Account_Sales_Organization__c aso = new Account_Sales_Organization__c();
				aso.Id = apf.Account_Sales_Organization__c;
				aso.Account_Bill_To__c = apf.Account__c;
				updateAso.add(aso);
			}
		}
		if (!updateAso.isEmpty()){
			update updateAso;
		}
	}
}