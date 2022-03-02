public with sharing class ContractTreatmentDefaultBomDAO {
    
    public static List<Contract_Treatment_Default_BOM__c> getCTDBOMFromProductIds(List<String> queryFields, List<Id> productIds, Id contractTreatmentJobId) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Contract_Treatment_Default_BOM__c WHERE Product__c IN: productIds AND Contract_Treatment_Job_Product__r.Contract_Treatment_Job__c =: contractTreatmentJobId';
        System.debug('getCTDBOMFromProductIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Contract_Treatment_Default_BOM__c> getDefaultBOMsFromCTJPIds(List<String> queryFields, List<Id> CTJPIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Contract_Treatment_Default_BOM__c WHERE Contract_Treatment_Job_Product__c IN: CTJPIds';
        System.debug('getDefaultBOMsFromCTJPIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Contract_Treatment_Default_BOM__c> getDefaultBOMsFromJob(List<String> queryFields, Id contractTreatmentJobId) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Contract_Treatment_Default_BOM__c WHERE Contract_Treatment_Job_Product__r.Contract_Treatment_Job__c =: contractTreatmentJobId LIMIT 100';
        System.debug('getDefaultBOMsFromJob QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Contract_Treatment_Default_BOM__c> getDefaultBOMsWithSearch(List<String> queryFields, Id contractTreatmentJobId, String searchValue) {

        String toSearch = '%' + searchValue + '%';

        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Contract_Treatment_Default_BOM__c WHERE Contract_Treatment_Job_Product__r.Contract_Treatment_Job__c =: contractTreatmentJobId AND (';

        // Cannot use LIKE: on Id field (Product__c)
        query += ' Product__r.Product_Name_Translate__c LIKE: toSearch OR Product__r.Product_Code__c ' +
        'LIKE: toSearch OR Product__r.Product_Family__r.Product_Name_Translate__c LIKE: toSearch OR Product__r.Manufacturer_part_number__c LIKE: toSearch) LIMIT 100';
        
        System.debug('getDefaultBOMsWithSearch QUERY: ' + query);
        
        return Database.query(query);
    }

    public static Contract_Treatment_Default_BOM__c getDefaultBOMFromId(List<String> queryFields, Id defaultBOMId) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Contract_Treatment_Default_BOM__c WHERE Id =: defaultBOMId';
        System.debug('getDefaultBOMFromId QUERY: ' + query);
        
        return Database.query(query);
    }
    
    public static List<Contract_Treatment_Default_BOM__c> getDefaultBOMFromcontracttreatmentid(List<String> contractTreatmentJobIds) {
        String Active = 'Active' ;
        String query = 'SELECT Contract_Treatment_Job_Product__c ,Product__c ,Contract_Treatment_Job_Product__r.Name, Contract_Treatment_Job_Product__r.Max_Quantity__c,Contract_Treatment_Job_Product__r.Min_Quantity__c,Contract_Treatment_Job_Product__r.Quantity_Unit_of_measure__c,Contract_Treatment_Job_Product__r.Frequency__c,Contract_Treatment_Job_Product__r.Frequency_Unit_of_measure__c,Contract_Treatment_Job_Product__r.Billable__c,Contract_Treatment_Job_Product__r.Invoice_Splitting_group__c,Contract_Treatment_Job_Product__r.Purchase_order_number__c,Contract_Treatment_Job_Product__r.Customer_Treatment_Alias__c,Contract_Treatment_Job_Product__r.Quantity__c,Contract_Treatment_Job_Product__r.Contract_Treatment_Job__r.Contract_Treatment__r.Customer_Request_Code__c ,Contract_Treatment_Job_Product__r.Purchase_order_date__c ,Contract_Treatment_Job_Product__r.Contract_Treatment_Job__c, Contract_Treatment_Job_Product__r.Plant__c, Contract_Treatment_Job_Product__r.Storage_Location__c ';
        query += ' FROM Contract_Treatment_Default_BOM__c WHERE Contract_Treatment_Job_Product__r.Contract_Treatment_Job__c IN :contractTreatmentJobIds AND Contract_Treatment_Job_Product__r.Status__c =: Active AND Contract_Treatment_Job_Product__r.Contract_Treatment_Job__r.Default_BOM__c = TRUE';
        System.debug('getDefaultBOMFromcontracttreatmentid QUERY: ' + query);
        return Database.query(query);
    }
}