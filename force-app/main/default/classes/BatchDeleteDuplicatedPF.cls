Global class BatchDeleteDuplicatedPF implements Database.Batchable<sObject>, Database.Stateful {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT ID from Account_Sales_Organization__c';

        System.debug(query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Account_Sales_Organization__c> asos) {

        List<String> asoIds = new List <String>();
        for (Account_Sales_Organization__c aso : asos){
            asoIds.add(aso.id);
        }

        List<Account_Partner_Function__c > apf = [SELECT id, Account_Sales_Organization__c, Partner_Function__c FROM Account_Partner_Function__c where Account_Sales_Organization__c IN :asoIds];

        Map <String, List<String>> pfMap = new Map<String, List<String>>();
        List<Account_Partner_Function__c> toDelete = new List<Account_Partner_Function__c>();
        for (Account_Partner_Function__c af : apf){
            if (pfMap.containsKey(af.Account_Sales_Organization__c)) {
                List<String> tmp = pfMap.get(af.Account_Sales_Organization__c);
                if (tmp.contains(af.Partner_Function__c)){
                    toDelete.add(af);
                } else {
                    tmp.add(af.Partner_Function__c);
                    pfMap.put(af.Account_Sales_Organization__c, tmp);
                }
            } else {
                List<String> tmp = new List<String>();
                tmp.add(af.Partner_Function__c);
                pfMap.put(af.Account_Sales_Organization__c, tmp);
            }
        }

        if (toDelete!= null){
            delete toDelete;
        }

    }

    public void finish(Database.BatchableContext bc) {
        system.debug('DONE'); //TODO
    }
}