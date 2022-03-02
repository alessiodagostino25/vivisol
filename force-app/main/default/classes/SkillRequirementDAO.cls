public with sharing class SkillRequirementDAO {
    
    public static List<SkillRequirement> getSkillRequirementsFromRelatedRecordIds(List<String> queryFields, List<Id> relatedRecordIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM SkillRequirement WHERE RelatedRecordId IN: relatedRecordIds';
        System.debug('getSkillRequirementsFromRelatedRecordIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<SkillRequirement> getSkillRequirementsFromIds(List<String> queryFields, List<Id> relatedIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM SkillRequirement WHERE Id IN: relatedIds';
        System.debug('getSkillRequirementsFromIds QUERY: ' + query);
        
        return Database.query(query);
    }
}