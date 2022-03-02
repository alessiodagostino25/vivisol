public with sharing class MeasurementDAO {
    
    public static List<Measurement__c> getMeasurementsFromIds(List<Id> measurementIds, List<String> queryFields) {
		String query = 'SELECT ';
		for (Integer i = 0; i < queryFields.size(); i++) {
			query += queryFields[i] + ', ';
		}
        query = query.substring(0, query.length() - 2);

		query += ' FROM Measurement__c WHERE Id IN: measurementIds';
        List<Measurement__c> queriedMeasures = Database.query(query);
        return queriedMeasures;
    }
}