trigger ContractProductLimitTrigger on Contract_Product_Limit__c (before insert) {

    List <String> productIds = new List <String>();

    for(Contract_Product_Limit__c cTJ : Trigger.New) {
        productIds.add(cTj.Product__c);
    }
    List <Product2> products = [SELECT Id, Name FROM Product2 WHERE Id IN :productIds];

    Map<String,String> productMap = New Map<String,String>();
    for (Product2 p : products){
        productMap.put(p.Id, p.Name);
    }
    for(Contract_Product_Limit__c productLimit : Trigger.New) {
        productLimit.Name = productMap.get(productLimit.Product__c);
    }
}