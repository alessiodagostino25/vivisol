public class WorkTypeDAO {
    
    public static List<WorkType> getWorkTypesFromIds(List<String> queryFields, List<String> relatedIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkType WHERE Id IN: relatedIds';
        
        return Database.query(query);
    }
}