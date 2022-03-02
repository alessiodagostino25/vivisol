public class AccountSalesOrganizationTriggerHandler {

    public static void handleTrigger(List<Account_Sales_Organization__c> triggerNew, System.TriggerOperation triggerEvent){
        AccountSalesOrganizationTriggerService ts=new AccountSalesOrganizationTriggerService();
        switch on triggerEvent{
            when AFTER_INSERT{
                ts.afterInsertOperation(triggerNew);
            }
        }
    }
}