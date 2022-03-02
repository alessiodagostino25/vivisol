public class customOrderProductEditService {
    
    public static String getOrderStatus(String orderId) {
        return OrderDAO.getOrderFromId(orderId);
    }
}