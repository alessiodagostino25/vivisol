trigger CompanyAndSalesDataEventTrigger on CompanyAndSalesDataEvent__e (after insert) {
    if(Trigger.isInsert && Trigger.isAfter) {
        List<String> accountIds = new List<String>();

        for(CompanyAndSalesDataEvent__e e : Trigger.new) {
            if(e.Account_Id__c != null) {
                accountIds.add(e.Account_Id__c);
            }
        }

        if(!accountIds.isEmpty()) {
            CompanyAndSalesDataEventService.createCompanyAndSalesData(accountIds);
        }
    }
}