public with sharing class RecordTypeDAO {

	public static List<RecordType> getRecordTypeLabelbyId(String selectedRecordLabel) {
		String query = 'SELECT id,DeveloperName FROM RecordType';
		if(selectedRecordLabel != null && selectedRecordLabel != '') {
			String key = selectedRecordLabel;
			query += ' WHERE id =: key ';
		}
		system.debug(query);
		system.debug(selectedRecordLabel);
		return Database.query(query);
	}

	public static List<RecordType> getRecordTypebysobject(String sObjectAPIName) {
		//Account_Treatment__c
		return  [SELECT id, DeveloperName, Name FROM RecordType WHERE SobjectType = :sObjectAPIName];
	}

	public static List<RecordType> getRecordTypesFromDeveloperNames(List<String> queryFields, List<String> developerNames) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM RecordType WHERE DeveloperName IN: developerNames';
        System.debug('getRecordTypesFromDeveloperNames QUERY: ' + query);
        
        return Database.query(query);
    }
}