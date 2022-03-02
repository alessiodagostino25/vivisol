public without sharing class ProductRequestDAO {
    
    public static List<ProductRequest> getProductRequestsFromIds(List<String> queryFields, List<Id> productRequestIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM ProductRequest WHERE Id IN: productRequestIds';
        System.debug('getProductRequestsFromIds QUERY: ' + query);
        
        return Database.query(query);
    }
}