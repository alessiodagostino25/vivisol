public with sharing class PrescriptionDAO {
    
    public static List<Prescription__c> getPrescriptionsbyId(String accountId) {
        return [select Id,Name,Patient__c,Principal_Information__c From Prescription__c where Patient__c =: accountId ];
    }

    public static List<Prescription__c> getPrescriptionsvaluesbyprescriptionfields(List<String> Prescriptionfields, List<String> Prescriptionids) {
        String query = 'SELECT ';
        for (Integer i = 0; i < Prescriptionfields.size(); i++){
		    query += Prescriptionfields[i] + ' ,';
	    }
	    if (Prescriptionfields.size() != 0){
		    query = query.substring(0, query.length() - 1);
	    }
        query += 'FROM Prescription__c Where id IN :Prescriptionids';
        System.debug(query) ;
        return Database.query(query);
    }

    public static List<Prescription__c> getPrescriptionsFromIds(List<String> queryFields, List<String> relatedIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        	query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Prescription__c WHERE Id IN: relatedIds';
        System.debug('getPrescriptionsFromIds QUERY: ' + query);
        
        return Database.query(query);
    }
}