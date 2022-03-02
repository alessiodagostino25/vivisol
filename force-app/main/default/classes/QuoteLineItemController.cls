public inherited sharing class QuoteLineItemController {

    @AuraEnabled(Cacheable = true)
    public static List<PricebookEntry> getPricebookEntry(String id, String strProductName, List<Object> pricebookentryList){
        List<PricebookEntry> result = new List<PricebookEntry>();
        if(String.isNotBlank(id) && String.isNotBlank(strProductName)){
            result = QuoteLineItemService.getPricebookEntry(id, strProductName, pricebookentryList);
        }
        return result;   
    }
    
    @AuraEnabled
    public static List<PricebookEntry> getAllProducts(String id, List<Object> pricebookentryList){       
        List<PricebookEntry> result = new List<PricebookEntry>();
        System.debug('quote.id: ' + id);
        if(String.isNotBlank(id)){
            result = QuoteLineItemService.getAllProducts(id, pricebookentryList);
        }
   	 	return result;     
     }
    
     @AuraEnabled
     public static List<String> createQuoteLineItem(List<Object> pricebookentryList, String quoteId){
        List<String> result = new List<String>();        
        if(String.isNotBlank(quoteId)  && pricebookentryList != null && pricebookentryList.size() > 0 ){
        	result = QuoteLineItemService.createQuoteLineItem(pricebookentryList, quoteId);
        }
        return result;
    }
    
    @AuraEnabled
    public static List<QuoteLineItemDTO> getQuoteLineItemByIds(List<String> quoteLineItemsIds){
		return QuoteLineItemService.getQuoteLineItemByIds(quoteLineItemsIds);
    }
    
    @AuraEnabled
    public static List<Quote_Line_Item__c> getQuoteLineItemByIdsToObj(List<Object> quoteLineItemsIds){
        List<String> quoteLineItemsIdsToReturn = new List<String>();
        System.debug('quoteLineItemsIds: ' + quoteLineItemsIds);
        for(Object obj : quoteLineItemsIds){
            String str = obj.toString();
            System.debug('Id: ' + str);
            quoteLineItemsIdsToReturn.add(str);
        }
		  return [SELECT  Id, name, Product__r.Product_Name_Translate__c, Product__r.Product_Code__c, 
          toLabel(Product__r.Unit_of_measure__c), Quantity__c, Box__c, Description__c FROM Quote_Line_Item__c WHERE Id in: quoteLineItemsIdsToReturn];
    }
    
    @AuraEnabled
    public static List<QuoteLineItemDTO> getQuoteLineItems(String quoteId){        
        List<QuoteLineItemDTO> toReturn = new List<QuoteLineItemDTO>();
        List<Quote_Line_Item__c> quoteLineItems = QuoteLineItemService.getQuoteLineItemInitButton(quoteId);

        if(quoteLineItems != null) {
            for(Quote_Line_Item__c qli : quoteLineItems) {
                QuoteLineItemDTO dto = new QuoteLineItemDTO(qli);
                toReturn.add(dto);
            }
        }

        return toReturn;
    }
    
    @AuraEnabled(Cacheable = true)
    public static String getQuoteStatus(String quoteId){
         return QuoteLineItemService.getQuoteStatus(quoteId);
    }
    
    @AuraEnabled
    public static String getSAPQuoteLineItemDTO(String quotelineitemid) {

        String calloutresponse  =  QuoteLineItemCallout.QuoteLineItemCalloutMethod(quotelineitemid);

        
        return calloutresponse;
    }

    @AuraEnabled
    public static void deleteQuoteLineItem(String quoteLineItemId){
        Quote_Line_Item__c quoteLineItem = [SELECT Id FROM Quote_Line_Item__c WHERE Id =: quoteLineItemId];

        if(quoteLineItem != null) {
            delete quoteLineItem;
        }
    }

    @AuraEnabled
    public static Boolean getAllowCallout(String quoteLineItemId) {
        System.debug('----- getAllowCallout -----');
        System.debug('quoteLineItemId: ' + quoteLineItemId);

        List<String> QLIQueryFields = new List<String>{/* 'Max_discount__c', */ 'Total_Amount_from_SAP_excluding_VAT__c', 'Total_VAT_from_SAP__c', 
        'Total_Amount_from_SAP_including_VAT__c', 'VAT__c', 'TotalPrice_Including_VAT__c', 'TotalPrice_excluding_VAT__c', 'Total_VAT__c'};

        Boolean allowCallout = true;
        List<Quote_Line_Item__c> quoteLineItemList = QuoteLineItemDAO.getQLIsFromIds(QLIQueryFields, new List<String>{quoteLineItemId});

        if(quoteLineItemList != null && !quoteLineItemList.isEmpty()) {
            Quote_Line_Item__c quoteLineItem = quoteLineItemList[0];
            
            for(String field : QLIQueryFields) {
                System.debug('field: ' + field);
                System.debug('field value: ' + quoteLineItem.get(field));

                if(quoteLineItem.get(field) != null) {
                    allowCallout = false;
                    break;
                }
            }
        }

        return allowCallout;
    }
}