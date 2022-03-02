public class CreateOrderQuoteService {
    
    public static Order createOrderFromQuote(String quoteId, boolean isPersonAccount){
        Order order = null;
        if(String.isNotBlank(quoteId)){
            // GET QUOTE BY ID
            Quote__c quote = QuoteDAO.getQuoteForOrderCreation(quoteId);
            // CREATE ORDER BY QUOTE
            order = createOrderByQuote(quote, isPersonAccount);
            // GET QUOTE LINE ITEM ASSOCITED TO THE QUOTE
            List<Quote_Line_Item__c> qliList = QuoteDAO.getQuoteLineItemByQuoteId(quoteId);
            // CREATE ORDER ITEM BY QUOTE LINE ITEM
            if(order.Id != null) {
                createOrderItem(qliList, order.id);
            }
        }
        return order;
    }
    
    
    private static Order createOrderByQuote(Quote__c quote, boolean isPersonAccount){        
        Order o = null;
        if(quote != null){
            o = new Order();
            o.AccountId = quote.Account_Name__c;
            //o.Account_Sold_To__c = isPersonAccount ? quote.Account_Name__c : quote.Contract_Treatment__r.Contract_Framework__r.Customer__c;

            /* if(quote.Contract_Treatment__c == null) {
                o.Account_Sold_To__c = quote.Account_Name__c;
            } */

            //o.Account_Bill_To__c = o.Account_Sold_To__c;
            o.Account_Sold_To__c = quote.Account_Sold_To__c;
            o.Account_Bill_To__c = quote.Account_Bill_To__c;
            o.Payer__c = quote.Payer__c;
            o.Case__c = quote.Case__c;
            o.Quote__c = quote.Id;
            o.Description = quote.Description__c;
            o.EffectiveDate = System.today();
            o.Contract_Treatment__c = quote.Contract_Treatment__c;
            o.Name = quote.Name;
            o.Status = 'New';
            o.Payment_Status__c = 'Not Paid';
            o.Delivery_Terms__c = quote.Delivery_Terms__c;
            o.Payment_Terms__c = quote.Payment_Terms__c;
            o.PaymentMethod__c = quote.PaymentMethod__c;
            o.Shipping_Address__c = quote.Location__c;
            o.ShippingStreet = quote.Street__c;
            o.ShippingPostalCode = quote.PostalCode__c;
            o.ShippingCity = quote.City__c;
            o.ShippingStateCode = quote.StateCode__c;
            o.ShippingCountryCode = quote.CountryCode__c;
            o.Billing_Address__c = isPersonAccount ? quote.Location__c : quote.Contract_Treatment__r.Contract_Framework__r.Customer__r.Location__c;
            o.BillingStreet = isPersonAccount ? quote.Street__c : quote.Contract_Treatment__r.Contract_Framework__r.Customer__r.LocationStreet__c;
            o.BillingPostalCode = isPersonAccount ? quote.PostalCode__c : quote.Contract_Treatment__r.Contract_Framework__r.Customer__r.LocationPostalCode__c;
            o.BillingCity = isPersonAccount ? quote.City__c : quote.Contract_Treatment__r.Contract_Framework__r.Customer__r.LocationCity__c;
            o.BillingStateCode = isPersonAccount ? quote.StateCode__c : quote.Contract_Treatment__r.Contract_Framework__r.Customer__r.LocationStateCode__c;
            o.BillingCountryCode = isPersonAccount ? quote.CountryCode__c : quote.Contract_Treatment__r.Contract_Framework__r.Customer__r.LocationCountryCode__c;
            o.ShipToContactId = quote.Contact__c;
            o.Pricebook__c = quote.Price_Book__c;
            o.Pricebook2Id = quote.Price_Book__c;
            o.AccountManager__c = quote.AccountManager__c;
            o.Account_Sales_Organization__c = quote.Account_Sales_Organization__c;
            o.Discount__c = quote.Discount__c;
            if(!isPersonAccount){
                o.Customer_Request_Code__c = quote.Contract_Treatment__r.Contract_framework__r.Customer_Request_Code__c;
                o.Customer_Purchase_Order_Number__c = quote.Contract_Treatment__r.Contract_framework__r.Customer_Purchase_Order_Number__c;
                o.Customer_Purchase_Order_Date__c = quote.Contract_Treatment__r.Contract_framework__r.Customer_Purchase_Order_Date__c;                    
            }
            insert o;               
        }
        return o;
    }
    
    private static void createOrderItem(List<Quote_Line_Item__c> qliList, String orderId){
        List<OrderItem> ordItemList = new List<OrderItem>();
        if(qliList != null && !qliList.IsEmpty()){
            try{
                
                List<ID> productsId = new List<Id>();
                List<ID> priceBooksId = new List<Id>(); 
                for(Quote_Line_Item__c quoteItem: qliList){
                	priceBooksId.add(quoteItem.Pricebook__c);
                    productsId.add(quoteItem.Product__c);
                }
                
                Map<Id, Map<Id, PricebookEntry>> priceEntryMap = getPriceEntryMap(productsId, priceBooksId);
                
                for(Quote_Line_Item__c quoteItem: qliList){                   
                    OrderItem ordItem = new OrderItem();
                    ordItem.OrderId = orderId;
                    ordItem.Quote_Line_Item__c = quoteItem.Id;
                    Map<Id, PricebookEntry> mapPriceBook = priceEntryMap.get(quoteItem.Pricebook__c);
                    if(mapPriceBook != null){
                        PricebookEntry priceBookEntry = mapPriceBook.get(quoteItem.Product__c);
                    	ordItem.PricebookEntryId = priceBookEntry != null ? priceBookEntry.id : null;
                    }
                    ordItem.Description = quoteItem.Description__c;
                    ordItem.Product2Id = quoteItem.Product__c;
                    ordItem.UnitPrice = 1;
                    ordItem.Quantity = quoteItem.Quantity__c;
                    ordItem.Max_discount__c = quoteItem.Max_discount__c;
                    ordItem.Asset__c = quoteItem.Asset__c;
                    ordItem.Box__c = quoteItem.Box__c;
                    ordItem.Discount_Description__c = quoteItem.Discount_Description__c;
                    ordItem.Pricebook__c = quoteItem.Pricebook__c;
                    ordItem.Total_VAT__c = quoteItem.Total_VAT__c;
                    ordItem.Total_VAT_from_SAP__c = quoteItem.Total_VAT_from_SAP__c;
                    ordItem.TotalPrice_excluding_VAT__c = quoteItem.TotalPrice_excluding_VAT__c;
                    ordItem.TotalPrice_Including_VAT__c = quoteItem.TotalPrice_Including_VAT__c;
                    ordItem.VAT__c = quoteItem.VAT__c;
                    ordItem.Total_Amount_from_SAP_excluding_VAT__c = quoteItem.Total_Amount_from_SAP_excluding_VAT__c;
                    ordItem.Total_Amount_from_SAP_including_VAT__c = quoteItem.Total_Amount_from_SAP_including_VAT__c;
                    ordItem.Discount__c = quoteItem.Discount__c;
                    ordItem.DiscountType__c = quoteItem.DiscountType__c;
                    
                    ordItemList.add(ordItem);
                }
            } catch (Exception e){
                system.debug('Exception during OrderItem creation: '+ e.getMessage());
            }
        }
        if(ordItemList.size() > 0){
        	insert ordItemList;
        }
    }
    
    private static Map<Id, Map<Id, PricebookEntry>> getPriceEntryMap( List<ID> productsId, List<ID> priceBooksId){
        Map<Id, Map<Id, PricebookEntry>> pb2c2p2PBE = new Map<Id, Map<Id, PricebookEntry>>();

        for (PricebookEntry pbEntry : [SELECT Id, Pricebook2Id, Product2Id FROM PricebookEntry WHERE Product2Id IN :productsId and Pricebook2Id IN :priceBooksId]) {
            if (!pb2c2p2PBE.containsKey(pbEntry.Pricebook2Id)) {
                pb2c2p2PBE.put(pbEntry.Pricebook2Id, new Map<Id, PricebookEntry>());
            }
            pb2c2p2PBE.get(pbEntry.Pricebook2Id).put(pbEntry.Product2Id,pbEntry);
        }
        return pb2c2p2PBE;
    }
    
    
}