public class ATPrescriptionMappingTriggerHelper{
	public static Account_Treatment__c ATPrescriptionMappingTriggerHelperwithId(Prescription__c queriedPrescription, Account_Treatment__c queriedAccountTreatments, List<String> Prescriptionfields, List<String> AccountTreatmentfields){
		// mapping the prescription fields and accounttreatment fields from the meta data
		Map<String, String> presandatfields = new Map<String, String>();
		for (Integer i = 0; i < Prescriptionfields.size(); i++){
			presandatfields.put(Prescriptionfields[i], AccountTreatmentfields[i]);
		}
		//mapping the prescription field and the value from the quieried list
		Map<String, Object> prescriptionandvalue = new Map<String, Object>();
		Prescription__c p = new Prescription__c();
		p = queriedPrescription;
		for (String fieldName : Prescriptionfields){
			System.debug('field name is ' + fieldName + ', value is ' + p.get(fieldName));
			prescriptionandvalue.put(fieldName, p.get(fieldName));
		}
		//mapping the account treatment field and the value from the quieried list
		Map<String, Object> atfieldsandvalue = new Map<String, Object>();
		for (String fieldName : Prescriptionfields){
			atfieldsandvalue.put(presandatfields.get(fieldName), prescriptionandvalue.get(fieldName));
		}
		Account_Treatment__c a = new Account_Treatment__c();
		a = queriedAccountTreatments;
		List<Account_Treatment__c> AccountTreatments = new List<Account_Treatment__c>();
		Map<String, Schema.SObjectField> M;
		M = Schema.SObjectType.Account_Treatment__c.fields.getMap();
		for (String fieldName : AccountTreatmentfields){
			Schema.SObjectField field = M.get(fieldName);
			Schema.DisplayType FldType = field.getDescribe().getType();
			if (FldType.name() == 'BOOLEAN'){
				a.put(fieldName, atfieldsandvalue.get(fieldName));
			}
			if (a.get(fieldName) == null){
				a.put(fieldName, atfieldsandvalue.get(fieldName));
			}
		}
		// return the account treatment to be updated.
		return a;
	}

	/*  List<AccountTreatmentPrescriptionMapping__mdt> fieldsfrommetadata = new List<AccountTreatmentPrescriptionMapping__mdt>();
	 List<String> Prescriptionfields = new List<String>();
	 List<String> AccountTreatmentfields = new List<String>();
	 fieldsfrommetadata = ATPrescriptionMappingmdtDAO.ATPrescriptionMappingmdtfields();
	 for (Integer i = 0; i < fieldsfrommetadata.size(); i++) {
	 Prescriptionfields.add(fieldsfrommetadata[i].Prescription_Field__c);
	 }
	 for (Integer i = 0; i < fieldsfrommetadata.size(); i++) {
	 AccountTreatmentfields.add(fieldsfrommetadata[i].Account_Treatment_Field__c);
	 }

	 Map<String, String> presandatfields = new Map<String, String>();
	 for (Integer i = 0; i < Prescriptionfields.size(); i++) {
	 presandatfields.put(
	 Prescriptionfields[i],
	 AccountTreatmentfields[i]
	 );
	 }
	 Map<String, Object> prescriptionandvalue = new Map<String, Object>();
	 Prescription__c p = new Prescription__c();

	 String query = 'SELECT ';
	 for (Integer i = 0; i < Prescriptionfields.size(); i++) {
	 query += Prescriptionfields[i] + ' ,';
	 }
	 if (Prescriptionfields.size() != 0) {
	 query = query.substring(0, query.length() - 1);
	 }
	 query += 'FROM Prescription__c Where id =:PrescriptionId';
	 List<Prescription__c> queriedPrescription = new List<Prescription__c>();
	 queriedPrescription = (List<Prescription__c>) Database.query(query);

	 p = queriedPrescription[0];
	 for (String fieldName : Prescriptionfields) {
	 System.debug('field name is ' +fieldName +', value is ' +p.get(fieldName));
	 prescriptionandvalue.put(fieldName, p.get(fieldName));
	 }

	 Map<String, Object> atfieldsandvalue = new Map<String, Object>();
	 for (String fieldName : Prescriptionfields) {
	 atfieldsandvalue.put(presandatfields.get(fieldName),prescriptionandvalue.get(fieldName));
	 }

	 Account_Treatment__c a = new Account_Treatment__c();

	 String query1 = 'SELECT ';
	 for (Integer i = 0; i < AccountTreatmentfields.size(); i++) {
	 query1 += AccountTreatmentfields[i] + ' ,';
	 }
	 if (AccountTreatmentfields.size() != 0) {
	 query1 = query1.substring(0, query1.length() - 1);
	 }
	 query1 += 'FROM Account_Treatment__c Where id =:atid';
	 List<Account_Treatment__c> queriedAccountTreatments = new List<Account_Treatment__c>();
	 queriedAccountTreatments = (List<Account_Treatment__c>) Database.query(query1);
	 a = queriedAccountTreatments[0]
	 List<Account_Treatment__c> AccountTreatments = new List<Account_Treatment__c>();


	 Map<String, Schema.SObjectField> M;
	 M = Schema.SObjectType.Account_Treatment__c.fields.getMap();

	 for (String fieldName : AccountTreatmentfields) {
	 Schema.SObjectField field = M.get(fieldName);
	 Schema.DisplayType FldType = field.getDescribe().getType();

	 if (FldType.name() == 'BOOLEAN') {
	 a.put(fieldName, atfieldsandvalue.get(fieldName));
	 }

	 if (a.get(fieldName) == null) {
	 a.put(fieldName, atfieldsandvalue.get(fieldName));
	 }
	 }
	 AccountTreatments.add(a);


	 upsert AccountTreatments;
	 } */
}