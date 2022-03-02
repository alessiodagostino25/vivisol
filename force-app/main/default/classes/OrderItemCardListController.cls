public class OrderItemCardListController {

    @AuraEnabled(cacheable=true)
    public static List<Id> getOrderItemIds(String orderId) {
        List<Id> orderItemIds = OrderItemCardListService.getOrderItemIds(orderId);
        System.debug('OrderItemIds: ' + orderItemIds);

        return orderItemIds;
    }

    @AuraEnabled()
    public static String getOrderStatus(String orderId){
        return OrderItemCardListService.getOrderStatus(orderId);
    }

}