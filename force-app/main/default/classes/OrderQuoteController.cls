public without sharing class OrderQuoteController {
        
    public static String quoteId {get; set;}
    
    public OrderQuoteController(ApexPages.StandardController c){
    	
    }
    
    /**
     * The method returns true if the quoute object has the Status__c equal to “Accepted”,
     * false otherwise
    * */
    @AuraEnabled
    public static boolean checkQuoteStatus(String id){       
        Boolean checkStatus = null;
        if(String.isNotBlank(id)){
            quoteId = id;
           
            Quote__c q = [SELECT Id, Status__c FROM Quote__c WHERE Id = :quoteId];
            
            if(q != null && q.Status__c == 'Accepted'){
                return true;
            }else{
                return false;
            }
        }
        return checkStatus;
    }
    
    /**
     * The method creates Order and Order Item starting from the Quote selected by Id.
    * */
    @AuraEnabled
    public static String createOrder(String id){
        Order order = new Order();
        if(String.isNotBlank(id)){
            quoteId = id;
            Quote__c q = [SELECT Id, Account_Name__r.IsPersonAccount FROM Quote__c WHERE Id = :quoteId];
                        
            boolean isPersonAccount = q.Account_Name__r.IsPersonAccount;
            order = CreateOrderQuoteService.createOrderFromQuote(quoteId, isPersonAccount);
        }        
        return order.Id;
    }
}