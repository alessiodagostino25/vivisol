public class OrderItemHKDAO {

    public static List<OrderItemHK__c> getOrderItemHKbyworkorderId(List<String> queryFields, List<Id> recordIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        	query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM OrderItemHK__c WHERE WorkOrderLineItem__c IN: recordIds';
        System.debug('getOrderItemHKbyworkorderId QUERY: ' + query);
        return Database.query(query);
    }

}