public class customOrderProductEditController {

    @AuraEnabled(cacheable = true)
    public static List<OrderItemDTO> getorderitemslist(String orderId ) {
       
        List<OrderItem> alpha = OrderItemDAO.getorderitemslistfromorderid(orderId);
        List<OrderItemDTO> OrderItemDTOs = new List<OrderItemDTO>();
        for(Integer i=0;i<alpha.size();i++){
            OrderItemDTO beta = new OrderItemDTO(alpha[i].Id,alpha[i].Product2.Product_Name_Translate__c ,alpha[i].Product2.Product_Code__c,alpha[i].Quantity,alpha[i].Product2.Unit_of_measure__c,alpha[i].Box__c,alpha[i].Description);
            OrderItemDTOs.add(beta);
        }
        System.debug(OrderItemDTOs);
        return OrderItemDTOs;
    }

    @AuraEnabled()
    public static String getOrderStatus(String orderId){
        return customOrderProductEditService.getOrderStatus(orderId);
    }

}