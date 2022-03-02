public with sharing class PricebookDAO{
	public static List<Pricebook2> getPricebookExternalIds(){
		String query = 'SELECT  Id ,External_ID__c from Pricebook2';
		System.debug(query);
		return Database.query(query);
	}

	public static List<Pricebook2> getPricebooksFromExternalIds(List<String> queryFields, List<String> externalIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Pricebook2 WHERE External_ID__c IN: externalIds';
        System.debug('getPricebooksFromExternalIds QUERY: ' + query);
        
        return Database.query(query);
    }
}