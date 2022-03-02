public class QuoteLineItemService {
    
    public static List<PricebookEntry> getPricebookEntry(String id, String strProductName, List<Object> pricebookentryList){
        List<PricebookEntry> result = QuoteLineItemDAO.getPricebookEntry(id, strProductName, pricebookentryList);
   	 	return result;   
    }
    
    
    public static List<PricebookEntry> getAllProducts(String id, List<Object> pricebookentryList){
        List<PricebookEntry> result = QuoteLineItemDAO.getAllProducts(id, pricebookentryList);
   	 	return result;     
    }

    public static List<String> createQuoteLineItem(List<Object> pricebookentryList, String quoteId){
        return QuoteLineItemDAO.createQuoteLineItem(pricebookentryList, quoteId);
    }
    
    public static List<QuoteLineItemDTO> getQuoteLineItemByIds(List<String> quoteLineItemsIds){
        List<QuoteLineItemDTO> toReturn = new List<QuoteLineItemDTO>();
        List<Quote_Line_Item__c> quoteLineItems = QuoteLineItemDAO.getQuoteLineItemByIds(quoteLineItemsIds);

        if(quoteLineItems != null) {
            for(Quote_Line_Item__c qli : quoteLineItems) {
                QuoteLineItemDTO dto = new QuoteLineItemDTO(qli);
                toReturn.add(dto);
            }
        }

        return toReturn;
    }

    public static List<Quote_Line_Item__c> getQuoteLineItemInitButton(String quoteId){
        List<String> fields = new List<String>{
            'Id', 'name', 'Product__r.Product_Name_Translate__c', 'Product__r.Product_Code__c', 
                'toLabel(Product__r.Unit_of_measure__c)', 'Quantity__c', 'Box__c', 'Description__c', 'Quote_Name__r.Status__c', 'Discount__c', 'DiscountType__c'
        };
        return QuoteLineItemDAO.getQuoteLineItemByQuoteId(fields, quoteId);
    }
   
    public static String getQuoteStatus(String quoteId){
        return QuoteLineItemDAO.getQuoteStatus(quoteId);        
    }
}