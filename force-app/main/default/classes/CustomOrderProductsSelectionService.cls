public class CustomOrderProductsSelectionService{
	public static void createorderproducts(String orderId, List<String> selectedproducts,List<String> selectedpricebookentry){
		System.debug('selectedProducts.size: ' + selectedproducts.size());

		List<OrderItem> orderproductupdatelist = new List<OrderItem>();
		

		List<Order> pricebook = [SELECT  Pricebook__c
		                         FROM Order
								 WHERE Id = :orderId];
			string pricebookvalue = pricebook[0].Pricebook__c ;
			List<PricebookEntry> PricebookEntry = [SELECT 
		                                             Product2Id, 
		                                             Id, 
		                                             Pricebook2Id
		                                       FROM PricebookEntry
											   WHERE Product2Id IN :selectedproducts AND Pricebook2Id =: pricebookvalue ];
											   
		System.debug(PricebookEntry);						 
		System.debug('pricebookvalue'+pricebook[0].Pricebook__c) ;
		for (Integer i = 0; i < selectedproducts.size(); i++){
			OrderItem orderproducts = new OrderItem();
			orderproducts.OrderId = orderId;
			orderproducts.Pricebook__c = PricebookEntry[i].Pricebook2Id;
			orderproducts.UnitPrice = 1;
			orderproducts.Quantity = 1;
		 	orderproducts.PricebookEntryId = PricebookEntry[i].Id;
			orderproducts.Product2Id = PricebookEntry[i].Product2Id ; 
			orderproductupdatelist.add(orderproducts);
		}
		System.debug('ORDER id' + orderId);
		System.debug('selectedproducts' + selectedproducts);
		upsert orderproductupdatelist;
		System.debug(selectedproducts);
	}
}