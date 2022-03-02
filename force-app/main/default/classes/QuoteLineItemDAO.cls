public class QuoteLineItemDAO {
    
    public static List<PricebookEntry> getPricebookEntry(String id, String strProductName, List<Object> pricebookentryList){
        List<PricebookEntry> result = new List<PricebookEntry>();
        List<PricebookEntry> resultSelected = new List<PricebookEntry>();
        List<PricebookEntry> resultList = new List<PricebookEntry>();
        if(String.isNotBlank(id) && String.isNotBlank(strProductName)){
            
            Quote__c quote = [SELECT Id, Price_Book__c FROM Quote__c WHERE id=:id];
           
            
            strProductName = '%' + strProductName + '%';
        
            if(pricebookentryList.size() > 0) {
            	List<String> pricebookList = new List<String>();
                for(Object pricebookentry :  pricebookentryList){
                    Map<Object,Object> data = (Map<Object,Object>) pricebookentry;                    
                    Object idValue = data.get('id');                   
                    pricebookList.add(idValue.toString());
                }
                result =  [SELECT  Id, Pricebook2Id,  Product2.Product_Name_Translate__c, Product2.Product_Code__c, Product2.Manufacturer_part_number__c, Product2.Product_Family__r.Product_Name_Translate__c, Product2Id
                                            FROM PricebookEntry
                                            WHERE Product2.Product_Family__c  != ''
                                                 AND Product2.type__c NOT IN ('ZSRT', 'ZJOB')
                                                 AND Pricebook2Id =: quote.Price_Book__c
                                                 AND Product2.IsActive = TRUE 
                           						 AND Id NOT IN :pricebookList
                                                 AND 
                                                    (                                                    
                                                        (Product2.Product_Name_Translate__c  LIKE :strProductName)
                                                   OR (Product2.Product_Code__c  LIKE :strProductName)
                                                   OR (Product2.Product_Name_Translate__c LIKE :strProductName)
                                                   OR (Product2.Manufacturer_part_number__c LIKE :strProductName)                                                    
                                                    )                      						
                                           ORDER BY Product2.Product_Name_Translate__c ASC LIMIT 100
                                           ];
                resultSelected =  [SELECT  Id, Pricebook2Id,  Product2.Product_Name_Translate__c, Product2.Product_Code__c, Product2.Manufacturer_part_number__c, Product2.Product_Family__r.Product_Name_Translate__c, Product2Id
                                            FROM PricebookEntry
                                            WHERE Id IN :pricebookList];
            }
            else {
                result =  [SELECT  Id, Pricebook2Id,  Product2.Product_Name_Translate__c, Product2.Product_Code__c, Product2.Manufacturer_part_number__c, Product2.Product_Family__r.Product_Name_Translate__c, Product2Id
                                            FROM PricebookEntry
                                            WHERE Product2.Product_Family__c  != ''
                                                 AND Product2.type__c NOT IN ('ZSRT', 'ZJOB')
                                                 AND Pricebook2Id =: quote.Price_Book__c
                                                 AND Product2.IsActive = TRUE 
                                                 AND 
                                                    (                                                    
                                                        (Product2.Product_Name_Translate__c  LIKE :strProductName)
                                                   OR (Product2.Product_Code__c  LIKE :strProductName)
                                                   OR (Product2.Product_Name_Translate__c LIKE :strProductName)
                                                   OR (Product2.Manufacturer_part_number__c LIKE :strProductName)                                                    
                                                    )                      						
                                           ORDER BY Product2.Product_Name_Translate__c ASC LIMIT 100
                                           ];
            }            
    	}
   	 	resultList.addAll(resultSelected);
        resultList.addAll(result);
    	return resultList;
     }
    
    
    public static List<PricebookEntry> getAllProducts(String id, List<Object> pricebookentryList){
        List<PricebookEntry> result = new List<PricebookEntry>();
        List<PricebookEntry> resultSelected = new List<PricebookEntry>();
        List<PricebookEntry> resultList = new List<PricebookEntry>();
        if(String.isNotBlank(id)){
               
            Quote__c quote = [SELECT Id, Price_Book__c FROM Quote__c WHERE id=:id];
            System.debug('quote.Price_Book__c: ' + quote.Price_Book__c);
               
            if(pricebookentryList.size() > 0) {
            	List<String> pricebookList = new List<String>();
                for(Object pricebookentry :  pricebookentryList){
                    Map<Object,Object> data = (Map<Object,Object>) pricebookentry;                    
                    Object idValue = data.get('id');                   
                    pricebookList.add(idValue.toString());
                }
                result =  [SELECT  Id, Product2.Product_Name_Translate__c, Product2.Product_Code__c, Product2.Manufacturer_part_number__c, Product2.Product_Family__r.Product_Name_Translate__c, Pricebook2Id, Product2Id
                                            FROM PricebookEntry
                                            WHERE Product2.Product_Family__c  != ''
                                                 AND Product2.type__c NOT IN ('ZSRT', 'ZJOB')
                                                 AND Pricebook2Id =: quote.Price_Book__c
                                                 AND Product2.IsActive = TRUE
                           						 AND Id NOT IN :pricebookList                                      		 
                                           ORDER BY Product2.Product_Name_Translate__c ASC LIMIT 100
                                           ];
                resultSelected =  [SELECT  Id, Pricebook2Id,  Product2.Product_Name_Translate__c, Product2.Product_Code__c, Product2.Manufacturer_part_number__c, Product2.Product_Family__r.Product_Name_Translate__c, Product2Id
                                            FROM PricebookEntry
                                            WHERE Id IN :pricebookList];
            }
            else {
            	result =  [SELECT  Id, Product2.Product_Name_Translate__c, Product2.Product_Code__c, Product2.Manufacturer_part_number__c, Product2.Product_Family__r.Product_Name_Translate__c, Pricebook2Id, Product2Id
                                            FROM PricebookEntry
                                            WHERE Product2.Product_Family__c  != ''
                                                 AND Product2.type__c NOT IN ( 'ZSRT', 'ZJOB')
                                                 AND Pricebook2Id =: quote.Price_Book__c
                                                 AND Product2.IsActive = TRUE                                      		 
                                           ORDER BY Product2.Product_Name_Translate__c ASC LIMIT 100
                                           ];               
            }
        
            
        }
   	 	resultList.addAll(resultSelected);
        resultList.addAll(result);
    	return resultList;
     }
    
    
    public static List<String> createQuoteLineItem(List<Object> pricebookentryList, String quoteId){
        List<Quote_Line_Item__c> quoteLineItems = new  List<Quote_Line_Item__c>();
        
        for(Object pricebookentry :  pricebookentryList){
            Map<Object,Object> data = (Map<Object,Object>) pricebookentry;
            system.debug(data.get('pricebook2id'));
            system.debug(data.get('product2id'));
            Object pricebook2id = data.get('pricebook2id');
            Object product2id = data.get('product2id');
           
            
            Quote_Line_Item__c q = new Quote_Line_Item__c();
            q.Pricebook__c = pricebook2id.toString();
            q.Product__c = product2id.toString();
            q.Quantity__c = 1;
	        q.Quote_Name__c=quoteId;
            quoteLineItems.add(q);
        }
        Database.SaveResult[] srList = Database.insert(quoteLineItems);
		List<String> result = new  List<String>();
		for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                result.add(sr.getId());
            }   
        }
		system.debug(result);
		return result;
        
    }
    
    public static List<Quote_Line_Item__c> getQuoteLineItemByIds(List<String> quoteLineItemsIds){
        List<Quote_Line_Item__c> quoteLineItem =[SELECT  Id, name, Product__r.Product_Name_Translate__c, Product__r.Product_Code__c, 
                                                toLabel(Product__r.Unit_of_measure__c), Quantity__c, Box__c, Description__c, Discount__c, DiscountType__c 
                                                FROM Quote_Line_Item__c WHERE Id in: quoteLineItemsIds];
        system.debug(quoteLineItem);
        return quoteLineItem;
    }

    public static List<Quote_Line_Item__c> getQuoteLineItemByQuoteId(List<String> fields, String quoteId){
        //Create query with fields
        String selectFields = '';
        for(String field: fields){
            selectFields += field+',';
        }
        selectFields = selectFields.removeEnd(',');
        
        //Dynamic SOQL Query with all fields
        String soqlQuery = 'SELECT '+ selectFields +' FROM Quote_Line_Item__c  WHERE Quote_Name__c = :quoteId';

        //Execute the SOQL query
        List<Quote_Line_Item__c> quoteLineItems = Database.Query(soqlQuery);
		System.debug('quoteLineItems: ' + quoteLineItems);
        System.debug('quoteLineItems size: ' + quoteLineItems.size() );
        
        return quoteLineItems;
    }
    
    public static String getQuoteStatus(String quoteId){
        System.debug('quoteId: ' + quoteId);
        Quote__c quote = [SELECT Status__c FROM Quote__c WHERE id=:quoteId];
        return quote.Status__c;
    }

    public static Quote_Line_Item__c getQuoteLineItemforsapFromId(String quotelineitemid) {

        Quote_Line_Item__c ql = [SELECT Id, Quote_Name__r.Account_Sales_Organization__r.Sales_Organization__r.Code__c, 
                                Quote_Name__r.Account_Sales_Organization__r.Distribution_Channel__c,Quote_Name__r.Account_Name__r.Account_External_Id__c,Quantity__c,
                                Product__r.Unit_of_Measure__c,Quote_Name__r.Contract_Treatment__r.Contract_Framework__r.Contract_Number__c,Product__r.Product_Code__c, 
                                Quote_Name__r.Account_Bill_To__r.Account_External_Id__c 
                                FROM Quote_Line_Item__c WHERE Id =: quotelineitemid];

        return ql;
    }

    public static List<Quote_Line_Item__c> getQLIsFromIds(List<String> queryFields, List<String> relatedIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Quote_Line_Item__c WHERE Id IN: relatedIds';
        System.debug('getQLIsFromIds QUERY: ' + query);
        
        return Database.query(query);
    }
}