public class CalloutLoggerResolutionBatch implements Database.Batchable<sObject>, Schedulable {

    public  Database.QueryLocator start(Database.BatchableContext bc){
        List <String> services = new List<String>{'SFDC_SAP4HANA__PATIENT_CREATE', 'SFDC_SAP4HANA__PATIENT_UPDATE',
            'SFDC_PIMCORE_CUSTOMER_UPSERT', 'PIMCORE_SFDC_CUSTOMER_UPSERT' , 'SFDC_SAP4HANA__SO_CREATE', 'SFDC_SAP4HANA__SO_UPDATE',
            'SFDC_SAP4HANA__ADDRESS_CREATE', 'SFDC_SAP4HANA__ADDRESS_UPDATE', 'PIMCORE_SFDC_ADDRESS_UPSERT', 'SFDC_PIMCORE_ADDRESS_UPSERT',
            'SFDC_SAP4HANA__CONTRACT', 'SFDC_PIMCORE_CONTRACT_FRAMEWORK__UPSERT', 'HEROKU_SAP4HANA__WORKORDER_UPSERT', 'SAP4HANA_SFDC__END_DELIVERY',
            'SFDC_PIMCORE_ORDER', 'PIMCORE_SFDC_ORDER_CREATE', 'SFDC_SAP4HANA__PICKING_LOADING_UPDATE', 'SFDC_SAP4HANA__VAN_UNLOADING',
            'SFDC_SAP4HANA__MEASUREMENT_POINT_CREATE', 'SFDC_PIMCORE_EQUIPMENT_UPSERT', 'SFDC_PIMCORE_PAPH__UPSERT', 'SFDC_PIMCORE_PATIENT_TREATMENT_UPSERT'};
        String query = 'SELECT Service__c, Related_Address__c,isSolved__c, TimestampSolved__c, Related_Account__c, Related_Account_Sales_Organization__c, '
        + 'Related_Account_Company__c, Related_Contract_Framework__c, Related_Account_Treatment__c FROM Callout_Logger__c WHERE isSolved__c = false AND Service__c != null' 
        + ' AND Service__c = :services';
		System.debug(query);
		return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Callout_Logger__c> calloutLoggers){
        List<Id> addressIds = new List<Id>();
        List<Id> accountIds = new List<Id>();
        List<Id> salesOrganisationIds = new List<Id>();
        List<Id> accountCompanyIds = new List<Id>();
        List<Id> contractFrameworkIds = new List<Id>();
        List<Id> accountTreatmentIds = new List<Id>();
        List<Callout_Logger__c> calloutLoggerList = new List<Callout_Logger__c>();

        for (Callout_Logger__c cl : calloutLoggers) {
            if(cl.Related_Account__c != null){
                accountIds.add(cl.Related_Account__c) ;
            }
            if(cl.Related_Address__c != null){
                addressIds.add(cl.Related_Address__c) ;
            }
            if (cl.Related_Account_Sales_Organization__c != null) {
                salesOrganisationIds.add(cl.Related_Account_Sales_Organization__c);
            }
            if (cl.Related_Account_Company__c != null) {
                accountCompanyIds.add(cl.Related_Account_Company__c);
            }
            if (cl.Related_Contract_Framework__c  != null) {
                contractFrameworkIds.add(cl.Related_Contract_Framework__c);
            }
            if(cl.Related_Account_Treatment__c != null) {
                accountTreatmentIds.add(cl.Related_Account_Treatment__c);
            }
        }
        
        List<Schema.Address> relatedaddress =  AddressDAO.getAddressesSapSyncForCalloutLoggers(addressIds) ;
        List<String> queryFieldsForAccount = new List<String>{'Id','IsSyncSAP__c', 'Is_Portal_Sync__c'};
        List<String> queryFieldsForASO = new List<String>{'Id','IsSyncSAP__c'};
        List<String> queryfieldsforaccountCompany = new List<String>{'Id','IsSyncSAP__c'};
        List<String> queryfieldsforContractFramework = new List<String>{'Id','IsSyncSAP__c', 'Is_Portal_Sync__c'};
        List<String> queryFieldsForAccountTreatment = new List<String>{'Is_Portal_Sync__c'};

        List<Contract_Framework__c> relatedContractFramework = ContractFrameworkDAO.getCFsFromIds(queryfieldsforContractFramework, contractFrameworkIds);
        List<Account_Sales_Organization__c> relatedasos = AccountSalesOrganizationDAO.getASOsFromIds(queryFieldsForASO, salesOrganisationIds);
        List<Account_Company__c> relatedAccountCompany =  AccountCompanyDAO.getAccountcompanyFromIds(queryFieldsForAccountCompany, accountCompanyIds);
        List<Account> relatedAccounts = AccountDAO.getAccountIsSapSyncFromRecordIds(queryFieldsForAccount,accountIds);
        List<Account_Treatment__c> relatedAccountTreatments = AccountTreatmentDAO.getAccountTreatmentsFromIds(queryFieldsForAccountTreatment, accountTreatmentIds);

        //ASSIGNING THE STATUS OF SINCRONIZATION
        Map<Id, String> accountsIdandIssyncsap = new Map<Id, String>();
        Map<Id, String> accountsPortalStatus = new Map<Id, String>();
        for (Account acc : relatedAccounts) {
            accountsIdandIssyncsap.put(acc.Id , acc.IsSyncSAP__c) ;
            accountsPortalStatus.put(acc.Id , acc.Is_Portal_Sync__c) ;
        }

        Map<Id, Boolean> addressIdandIssyncsap = new Map<Id, Boolean>();
        Map<Id, String> addressPortalStatus = new Map<Id, String>();
        for (Schema.Address a : relatedaddress) {
            addressIdandIssyncsap.put(a.Id , a.IsSyncSAP__c);
            addressPortalStatus.put(a.Id , a.Is_Portal_Sync__c);
        }

        Map<Id, String> asoIdandIssyncsap = new Map<Id, String>();
        for (Account_Sales_Organization__c aso : relatedasos) {
            asoIdandIssyncsap.put(aso.Id, aso.IsSyncSAP__c);
        }

        Map<Id, String> accountCompanyIdandIssyncsap = new Map<Id, String>();
        for (Account_Company__c ac : relatedAccountCompany) {
            accountCompanyIdandIssyncsap.put(ac.Id, ac.IsSyncSAP__c);
        }

        Map<Id, String> CfIdandIssyncsap = new Map<Id, String>();
        Map<Id, String> CFPortalStatusMap = new Map<Id, String>();
        for (Contract_Framework__c cf : relatedContractFramework) {
            CfIdandIssyncsap.put(cf.Id, cf.IsSyncSAP__c);
            CFPortalStatusMap.put(cf.Id, cf.Is_Portal_Sync__c);
        }

        Map<Id, String> ATPortalStatusMap = new Map<Id, String>();
        for(Account_Treatment__c at : relatedAccountTreatments) {
            ATPortalStatusMap.put(at.Id, at.Is_Portal_Sync__c);
        }

        //CHECKING THE LOGS
        for (Callout_Logger__c cl : calloutLoggers) {
            if (cl.Service__c == 'SFDC_PIMCORE_CUSTOMER_UPSERT'){
                if (accountsPortalStatus.get(cl.Related_Account__c) == '01'){
                    cl.isSolved__c = true; 
                    cl.TimestampSolved__c = Datetime.Now();
                    calloutLoggerList.add(cl);
                }    
            } else
            if (cl.Service__c == 'SFDC_PIMCORE_ADDRESS_UPSERT'){
                if (addressPortalStatus.get(cl.Related_Address__c) == '01'){
                    cl.isSolved__c = true; 
                    cl.TimestampSolved__c = Datetime.Now();
                    calloutLoggerList.add(cl);
                }    
            } else
            if(addressIdandIssyncsap.get(cl.Related_Address__c) == true){
                cl.isSolved__c = true ; 
                cl.TimestampSolved__c = Datetime.Now() ;
                calloutLoggerList.add(cl) ;
            } else
            if(accountsIdandIssyncsap.get(cl.Related_Account__c) == 'Sync'){
                cl.isSolved__c = true ; 
                cl.TimestampSolved__c = Datetime.Now() ;
                calloutLoggerList.add(cl) ;
            } else
            if(asoIdandIssyncsap.get(cl.Related_Account_Sales_Organization__c) == 'Sync'){
                cl.isSolved__c = true ; 
                cl.TimestampSolved__c = Datetime.Now() ;
                calloutLoggerList.add(cl) ;
            } else
            if(accountCompanyIdandIssyncsap.get(cl.Related_Account_Company__c) == 'Sync'){
                cl.isSolved__c = true ; 
                cl.TimestampSolved__c = Datetime.Now() ;
                calloutLoggerList.add(cl) ;
            }
            else if(cl.Service__c == 'SFDC_PIMCORE_CONTRACT_FRAMEWORK__UPSERT') {
                if(CFPortalStatusMap.get(cl.Related_Contract_Framework__c) == '01') {
                    cl.isSolved__c = true; 
                    cl.TimestampSolved__c = Datetime.Now();
                    calloutLoggerList.add(cl);
                }
            } else
            if(CfIdandIssyncsap.get(cl.Related_Contract_Framework__c) == 'Sync'){
                cl.isSolved__c = true ; 
                cl.TimestampSolved__c = Datetime.Now() ;
                calloutLoggerList.add(cl) ;
            }
            else if(cl.Service__c == 'SFDC_PIMCORE_PATIENT_TREATMENT_UPSERT') {
                if(ATPortalStatusMap.get(cl.Related_Account_Treatment__c) == '01') {
                    cl.isSolved__c = true;
                    cl.TimestampSolved__c = Datetime.now();
                    calloutLoggerList.add(cl);
                }
            }
        }

        update calloutLoggerList;
    }
    public void finish(Database.BatchableContext bc){
        system.debug('DONE'); 
    }

    public static void Execute(SchedulableContext ctx){
        Database.executeBatch(new CalloutLoggerResolutionBatch()); //TODO
    }

}