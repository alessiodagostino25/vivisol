public class OrderHKDAO {

    public static List<OrderHK__c> getOrderHKbyworkorderId(List<String> queryFields, List<Id> recordIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        	query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM OrderHK__c WHERE WorkOrder__c IN: recordIds';
        System.debug('getOrderHKbyworkorderId QUERY: ' + query);
        
        return Database.query(query);
    }
}