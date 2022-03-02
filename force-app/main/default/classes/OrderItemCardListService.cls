public class OrderItemCardListService {
    
    public static List<Id> getOrderItemIds(String orderId) {
        List<Id> orderItemIds = OrderItemDAO.getOrderItemIds(orderId);
        return orderItemIds;
    }

    public static String getOrderStatus(String orderId) {
        return OrderDAO.getOrderFromId(orderId);
    }
}