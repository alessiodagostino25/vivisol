public class OrderItemCardController {
    
    @AuraEnabled
    public static String getCardTitle(String orderItemId){
        return OrderItemCardService.getCardTitle(orderItemId);
    }

    @AuraEnabled
    public static void deleteOrderItem(String orderItemId){
        OrderItemCardService.deleteOrderItem(orderItemId);
    }

    @AuraEnabled
    public static OrderItem getOrderItem(String orderItemId) {
        System.debug('OrderItemId: ' + orderItemId);
        OrderItem toReturn = OrderItemDAO.getOrderItemFromId(orderItemId);

        if(toReturn != null) {
            return toReturn;
        }

        return null;
    }

    @AuraEnabled
    public static Boolean getAllowCallout(String orderItemId) {
        System.debug('----- getAllowCallout -----');
        System.debug('orderItemId: ' + orderItemId);

        List<String> orderItemQueryFields = new List<String>{/* 'Max_discount__c', */ 'Total_Amount_from_SAP_excluding_VAT__c', 'Total_VAT_from_SAP__c', 
        'Total_Amount_from_SAP_including_VAT__c', 'VAT__c', 'TotalPrice_Including_VAT__c', 'TotalPrice_excluding_VAT__c', 'Total_VAT__c'};

        Boolean allowCallout = true;
        List<OrderItem> orderItemList = OrderItemDAO.getOrderItemsFromIds(orderItemQueryFields, new List<String>{orderItemId});

        if(orderItemList != null && !orderItemList.isEmpty()) {
            OrderItem orderItem = orderItemList[0];
            
            for(String field : orderItemQueryFields) {
                System.debug('field: ' + field);
                System.debug('field value: ' + orderItem.get(field));

                if(orderItem.get(field) != null) {
                    allowCallout = false;
                    break;
                }
            }
        }

        return allowCallout;
    }
}