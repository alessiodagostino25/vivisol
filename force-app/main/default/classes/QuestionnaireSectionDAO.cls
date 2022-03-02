public with sharing class QuestionnaireSectionDAO {

    public static List<QuestionnaireSection__c> getQuestionnaireSectionsByIds(List<String> queryFields, List<String> ids) {
		String query = 'SELECT ';
		for(Integer i = 0; i < queryFields.size(); i++) {
		    query += queryFields[i] + ', ';
		}
		query = query.substring(0, query.length() - 2);
		query += ' FROM QuestionnaireSection__c WHERE Id IN: ids';		
		return Database.query(query);
  	}

}