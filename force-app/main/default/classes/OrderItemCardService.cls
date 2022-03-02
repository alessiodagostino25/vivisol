public class OrderItemCardService {
    
    public static String getCardTitle(String orderItemId) {
        OrderItem oi = OrderItemDAO.getOrderItemFromId(orderItemId);

        String cardTitle = oi.Product2.Product_Name_Translate__c + ' ' + oi.Product2.Product_Code__c;

        return cardTitle;
    }

    public static void deleteOrderItem(String orderItemId) {
        OrderItem oi = [SELECT Id FROM OrderItem WHERE Id =: orderItemId];

        if(oi != null) {
            delete oi;
        }
    }
}