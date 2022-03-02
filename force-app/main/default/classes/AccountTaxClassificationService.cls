public class AccountTaxClassificationService {
    @future(callout=true)
    public static void futureCreateCallout(List<Id> asoIds) {
        List<Account_Sales_Organization__c> asoList = AccountSalesOrganizationDAO.getASOs(asoIds);
        ASOService.makeCreateCallout(asoList);
    }

    @future(callout=true)
    public static void futureUpdateCallout(List<Id> asoIds) {
        List<Account_Sales_Organization__c> asoList = AccountSalesOrganizationDAO.getASOs(asoIds);
        ASOService.makeUpdateCallout(asoList);
    }

    /* public static boolean isCreated(Id asoId) {
        Account_Sales_Organization__c aso = AccountSalesOrganizationDAO.getASO(asoId);
        if(aso.isCreatedSAP__c == true) {
            return true;
        }
        return false;
    } */

    public static Map<String, Account_Sales_Organization__c> getASOMap(List<String> ASOIds) {
        List<String> ASOQueryFields = new List<String>{'IsCreatedSAP__c'};

        Map<String, Account_Sales_Organization__c> ASOMap = new Map<String, Account_Sales_Organization__c>();
        List<Account_Sales_Organization__c> ASOs = AccountSalesOrganizationDAO.getASOsFromIds(ASOQueryFields, ASOIds);

        if(ASOs != null && !ASOs.isEmpty()) {
            for(Account_Sales_Organization__c aso : ASOs) {
                ASOMap.put(aso.Id, aso);
            }
        }

        return ASOMap;
    }

    public static void setNotSync(Id asoId) {
        Account_Sales_Organization__c aso = AccountSalesOrganizationDAO.getASO(asoId);
        aso.isSyncSAP__c = 'NotSync';
    }

    public static void updateRelatedAccountIsPortalSync(List<String> ASOIds) {
        List<String> accountQueryFields = new List<String>{'Is_Portal_Sync__c'};
        List<String> ASOQueryFields = new List<String>{'Account__c'};

        List<Account> accounts = new List<Account>();
        List<String> accountIds = new List<String>();

        List<Account_Sales_Organization__c> ASOs = AccountSalesOrganizationDAO.getASOsFromIds(ASOQueryFields, ASOIds);

        if(ASOs != null && !ASOs.isEmpty()) {
            ASOService.updateAccountIsPortalSync(ASOs);
        }
    }
}