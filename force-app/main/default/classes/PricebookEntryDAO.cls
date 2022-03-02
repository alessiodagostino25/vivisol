public with sharing class PricebookEntryDAO {
    public static List<PricebookEntry> getProductsfromPricebookEntry(String orderId,String searchKey,List<String> preselectedproducts){
        List<String> typevalues =  new List<String> ();
        typevalues.add('ZSRT');
        typevalues.add('ZJOB');
        String query = 'select Pricebook2Id,Product2Id,Id, Product2.Product_Name_Translate__c ,Product2.Product_Code__c ,Product2.Product_Family__r.Product_Name_Translate__c,Product2.Manufacturer_part_number__c from PricebookEntry WHERE (Product2.Product_Family__r.Product_Name_Translate__c  != null AND Product2.Type__c !=: typevalues AND Product2.IsActive = TRUE ) AND Pricebook2Id IN (select Pricebook__c  from Order where Id =: orderId) ';
        if(searchKey != null && searchKey != '') {
            String key = '%' + searchKey + '%';
            if(preselectedproducts != null && preselectedproducts.size() > 0){
                query += 'AND (Product2.Product_Name_Translate__c LIKE :key OR Product2.Product_Code__c LIKE :key OR Product2.Product_Family__r.Product_Name_Translate__c LIKE :key OR Product2.Manufacturer_part_number__c LIKE :key OR Product2Id IN :preselectedproducts  ) LIMIT 100';
            }
            else {
                query += 'AND (Product2.Product_Name_Translate__c LIKE :key OR Product2.Product_Code__c LIKE :key OR Product2.Product_Family__r.Product_Name_Translate__c LIKE :key OR Product2.Manufacturer_part_number__c LIKE :key ) LIMIT 100'; 
            }
        }
        else {
            query += 'LIMIT 100' ;
        }
        system.debug(query);
        return Database.query(query);
    }

    // This is used in DefaultBomProductSelectionService to get all the Products to display (no families)
    public static List<PricebookEntry> getPricebookEntriesFromJobId(List<String> queryFields, Id contractTreatmentJobId, List<Id> notToShow, Boolean limitSearch, 
    Integer queryLimit) {

        System.debug('CTJ Id in getPricebookEntriesFromJobId: ' + contractTreatmentJobId);
        if(notToShow != null) {
            System.debug('Not to show Ids: ' + notToShow.size());
        }
        List<Contract_Treatment_Job_Product__c> CTJPs = [SELECT Product__c, Contract_Treatment_Job__r.Contract_Framework__r.Price_list_code__c 
                                                         FROM Contract_Treatment_Job_Product__c
                                                         WHERE Contract_Treatment_Job__c =: contractTreatmentJobId AND Status__c = 'Active'];

        System.debug('Contract Treatment Job Products presi: ' + CTJPs.size());
                                                        
        List<Id> productIds = new List<Id>();
        List<Id> priceListCodes = new List<Id>();

        for(Contract_Treatment_Job_Product__c ctjp : CTJPs) {
            productIds.add(ctjp.Product__c);
            if(!priceListCodes.contains(ctjp.Contract_Treatment_Job__r.Contract_Framework__r.Price_list_code__c)) {
                priceListCodes.add(ctjp.Contract_Treatment_Job__r.Contract_Framework__r.Price_list_code__c);
            }
        }

        System.debug('priceListCodes.size: ' + priceListCodes.size());
        
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM PricebookEntry WHERE ((Product2.Product_Family__c IN: productIds) OR (Product2.Id IN: productIds ' +
        'AND Product2.Product_Family__c != NULL)) AND Pricebook2Id IN: priceListCodes AND IsActive = true AND Product2.IsActive = true';

        if(notToShow != null) {
            query += ' AND Id NOT IN: notToShow';
        }

        if(limitSearch == true && queryLimit != null) {
            query += ' LIMIT ' + queryLimit;
        }
        
        System.debug('getPricebookEntriesFromJobId QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<PricebookEntry> getPricebookEntriesWithSearch(List<String> queryFields, Id contractTreatmentJobId, String searchValue, List<Id> notToShow,
    Integer queryLimit) {

        if(notToShow != null) {
            System.debug('Not to show Ids with search: ' + notToShow.size());
        }
        String toSearch = '%' + searchValue + '%';

        List<Contract_Treatment_Job_Product__c> CTJPs = [SELECT Product__c, Contract_Treatment_Job__r.Contract_Framework__r.Price_list_code__c 
                                                         FROM Contract_Treatment_Job_Product__c
                                                         WHERE Contract_Treatment_Job__c =: contractTreatmentJobId AND Status__c = 'Active'];
                                                        
        List<Id> productIds = new List<Id>();
        List<Id> priceListCodes = new List<Id>();

        for(Contract_Treatment_Job_Product__c ctjp : CTJPs) {
            productIds.add(ctjp.Product__c);
            if(!priceListCodes.contains(ctjp.Contract_Treatment_Job__r.Contract_Framework__r.Price_list_code__c)) {
                priceListCodes.add(ctjp.Contract_Treatment_Job__r.Contract_Framework__r.Price_list_code__c);
            }
        }

        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM PricebookEntry WHERE ((Product2.Product_Family__c IN: productIds) OR (Product2.Id IN: productIds ' +
        'AND Product2.Product_Family__c != NULL)) AND Pricebook2Id IN: priceListCodes AND IsActive = true AND Product2.IsActive = true AND (';

        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ' LIKE: toSearch OR ';
        }
        query = query.substring(0, query.length() - 4);
        query += ')';

        if(notToShow != null) {
            query += ' AND Id NOT IN: notToShow';
        }

        query += ' LIMIT ' + queryLimit;
        
        System.debug('getPricebookEntriesFromJobId QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<PricebookEntry> getPricebookEntriesFromId(List<String> queryFields, List<String> pricebookEntryIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM PricebookEntry WHERE Id IN: pricebookEntryIds';
        
        System.debug('getPricebookEntriesFromId QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<PricebookEntry> getPEFromPricebookIds(List<String> queryFields, List<Id> pricebook2Ids) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM PricebookEntry WHERE Pricebook2Id IN: pricebook2Ids';
        
        System.debug('getPEFromPricebookIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<PricebookEntry> getPEFromProductIds(List<String> queryFields, List<Id> product2Ids) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM PricebookEntry WHERE Product2Id IN: product2Ids';
        
        System.debug('getPEFromProductIds QUERY: ' + query);
        
        return Database.query(query);
    }
    public static List<PricebookEntry> getPEFromPricebookIdsandproductid(List<String> queryFields, List<Id> pricebook2Id, List<Id> productId) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM PricebookEntry WHERE Pricebook2Id IN: pricebook2Id  AND Product2Id IN:productId';
        
        System.debug('getPEFromPricebookIds QUERY: ' + query);
        
        return Database.query(query);
    }
}