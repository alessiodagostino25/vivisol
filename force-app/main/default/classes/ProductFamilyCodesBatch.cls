public class ProductFamilyCodesBatch implements Database.Batchable<sObject>, Schedulable{

	public Database.QueryLocator start(Database.BatchableContext bc){
		//query to get the product families
		String familyname = 'ZFAM';
		String query = 'select Id,Type__c,Family_Product_Type__c  From Product2  ';
		System.debug(query);
		return Database.getQueryLocator(query);
	}
	
	public void execute(Database.BatchableContext bc, List<Product2> productQuery){

		List<Product2> productfamilies = new List<Product2>();
		List<Product2> productfamilytype = new List<Product2>();
		List<Product2> finalproductupdate = new List<Product2>();
		List<Id> productfamiliesids = new List<Id>();
		for (Product2 p : productQuery) {
			if (p.Type__c == 'ZFAM') {
				productfamilies.add(p);
			}else if(p.Type__c != null && p.Type__c != 'ZFAM' && p.Family_Product_Type__c == null ){
				productfamilytype.add(p);
			}
		}
		//update the familyproducttype 
		for (Product2 p : productfamilytype) {
			p.Family_Product_Type__c  = p.Type__c ;	
			finalproductupdate.add(p);
		}
        //get the product family ids
		for (Product2 p : productfamilies){
			productfamiliesids.add(p.Id);
        }
        // get the subproducts related to the productfamilies.
		List<Product2> subproducts = new List<Product2>();
        subproducts = Product2DAO.getthesubproductsoffamilies(productfamiliesids);
        //map the product families and types of the product that are related to the product family 
		Map<Id, List<String>> familyidandtpyes = new Map<Id, List<String>>();
		for (Product2 p2 : subproducts){
			List<String> temp = familyidandtpyes.get(p2.Product_Family__c);
			if (temp == null){
				familyidandtpyes.put(p2.Product_Family__c, new List<String>{p2.Type__c});
			} else{
				temp.add(p2.Type__c);
			}
		}
		for (Product2 P1 : productfamilies){
			String concatetypes = '';
			List<String> typeslist = new List<String>();
            List<String> subproducttypes = familyidandtpyes.get(P1.Id);
            //add the types into a list without repeating 
			if (subproducttypes != null){
				for (Integer i = 0; i < subproducttypes.size(); i++){
					if (!typeslist.contains(subproducttypes[i] )){
						typeslist.add(subproducttypes[i]);
					}
                }
                //concate the types into a string
				for (Integer i = 0; i < typeslist.size(); i++){
                    if(i == 0){
                    concatetypes += typeslist[i];
                    }else{
                        concatetypes += ';'+typeslist[i]; 
                    }
                 }
                 //assign the string to the product family
                P1.Family_Product_Type__c = concatetypes; 
                finalproductupdate.add(P1);
			 }
		}
		update finalproductupdate;
	}
	
	 public void finish(Database.BatchableContext bc) {
        system.debug('DONE'); 
	}
	
    public static void Execute(SchedulableContext ctx){
		Database.executeBatch(new ProductFamilyCodesBatch()); 
	}


     
}