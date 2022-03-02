public  class CustomOrderProductsSelectionController {
    @AuraEnabled(cacheable = true)
    public static List<PricebookEntryDTO> getorderproducts(String orderId ,String searchKey , List<String> preselectedproducts ) {
       
    List<PricebookEntry> alpha = PricebookEntryDAO.getProductsfromPricebookEntry(orderId,searchKey,preselectedproducts);
    List<PricebookEntryDTO> PricebookEntryDTOs = new List<PricebookEntryDTO>();
    for(Integer i=0;i<alpha.size();i++){
        PricebookEntryDTO beta = new PricebookEntryDTO(alpha[i].Id,alpha[i].Product2Id,alpha[i].Product2.Product_Name_Translate__c ,alpha[i].Product2.Product_Code__c,alpha[i].Product2.Product_Family__r.Product_Name_Translate__c,alpha[i].Product2.Manufacturer_part_number__c,false);
        PricebookEntryDTOs.add(beta);
    }
    System.debug(PricebookEntryDTOs);
    return PricebookEntryDTOs;
 } 


 @AuraEnabled
 public static List<OrderItem> numberoforderproducts(String orderId) {
     System.debug('----- numberoforderproducts -----');
    List<OrderItem> orderitems = OrderItemDAO.getorderitemslistfromid(orderId);
    System.debug(orderitems);
    return orderitems;
 } 




 @AuraEnabled
	public static void createorderproducts(String orderId, List<String> selectedproducts,List<String> selectedpricebookentry) {

		CustomOrderProductsSelectionService.createorderproducts(orderId, selectedproducts,selectedpricebookentry);
	}
}