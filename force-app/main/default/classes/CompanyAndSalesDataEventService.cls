public without sharing class CompanyAndSalesDataEventService {
    public static void createCompanyAndSalesData(List<String> accountIds) {
        List<String> accountQueryFields = new List<String>{'AutoCreateCompanyData__c', 'AutoCreateSalesData__c', 'Entity_type__c', 'RecordType.DeveloperName'};

        List<Account> accounts = new List<Account>();
        List<Account> toCreateCompanyData = new List<Account>();
        List<Account> toCreateSalesData = new List<Account>();

        accounts = AccountDAO.getAccountIsSapSyncFromRecordIds(accountQueryFields, accountIds);

        if(!accounts.isEmpty()) {
            for(Account a : accounts) {
                if(a.AutoCreateCompanyData__c != null) {
                    toCreateCompanyData.add(a);
                }
                if(a.AutoCreateSalesData__c != null) {
                    toCreateSalesData.add(a);
                }
            }

            // Auto creating Account Company

            if(!toCreateCompanyData.isEmpty()) {
                AccountService.createCompanyData(toCreateCompanyData);
            }

            // Auto creating ASO + Account Tax Classification

            if(!toCreateSalesData.isEmpty()) {
                AccountService.createSalesData(toCreateSalesData);
            }
        }
    }
}