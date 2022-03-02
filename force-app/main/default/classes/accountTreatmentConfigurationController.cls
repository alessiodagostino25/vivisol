public with sharing class accountTreatmentConfigurationController {

	@AuraEnabled(cacheable=true)
	public static List<AccountTreatmentFields__mdt> getFields(String therapy, string recordtype) {

		List<AccountTreatmentFields__mdt> fields = new List<AccountTreatmentFields__mdt>();
		fields = [SELECT FieldApiName__c, Order__c FROM AccountTreatmentFields__mdt WHERE AccountTreatmentType__r.RecordTypeName__c = :recordtype AND AccountTreatmentType__r.TreatmentType__c = :therapy ORDER BY Order__c];
		for (AccountTreatmentFields__mdt f :fields){
			System.debug(f);
		}
		return fields;
	}

}