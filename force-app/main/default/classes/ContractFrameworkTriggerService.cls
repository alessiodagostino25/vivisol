public class ContractFrameworkTriggerService {
    
    public static void deactivateRelatedATs(List<Contract_Framework__c> contractFrameworks) {
        /* List<String> ATQueryFields = new List<String>{'Status__c'};

        List<String> contractFrameworkIds = new List<String>();
        List<Account_Treatment_Status__c> toInsert = new List<Account_Treatment_Status__c>();

        for(Contract_Framework__c cf : contractFrameworks) {
            contractFrameworkIds.add(cf.Id);
        }

        List<Account_Treatment__c> relatedAccountTreatments = AccountTreatmentDAO.getActiveATsFromCFIds(ATQueryFields, contractFrameworkIds);

        if(relatedAccountTreatments != null) {
            for(Account_Treatment__c at : relatedAccountTreatments) {
                Account_Treatment_Status__c newATS = new Account_Treatment_Status__c(
                    Patient_Treatment__c = at.Id,
                    Status__c = 'D'
                );

                toInsert.add(newATS);
            }
        }

        return toInsert; */

        AccountTreatmentDeactivationFromCFBatch deactivationBatch = new AccountTreatmentDeactivationFromCFBatch();
        deactivationBatch.contractFrameworks = contractFrameworks;

        Database.executeBatch(deactivationBatch, 5);
    }

    public static void checkPricebook(List<Contract_Framework__c> contractFrameworks) {
        System.debug('----- checkPricebook -----');

        List<Contract_Framework__c> toSetPricebook = new List<Contract_Framework__c>();

        for(Contract_Framework__c contractFramework : contractFrameworks) {
            if(contractFramework.Branch_of_belonging_sales_office__c != null) {
                toSetPricebook.add(contractFramework);
            }
        }

        if(!toSetPricebook.isEmpty()) {
            setPricebook(toSetPricebook);
        }
    }

    public static void setPricebook(List<Contract_Framework__c> contractFrameworks) {
        System.debug('----- setPricebook -----');

        List<String> ASOQueryFields = new List<String> {'Sales_Organization__r.Code__c', 'Distribution_Channel__c'};
        List<String> pricebookQueryFields = new List<String>{'External_ID__c'};

        List<String> relatedASOIds = new List<String>();
        List<String> pricebookExternalIds = new List<String>();
        List<Account_Sales_Organization__c> relatedASOs = new List<Account_Sales_Organization__c>();
        List<Pricebook2> relatedPricebooks = new List<Pricebook2>();

        Map<String, Account_Sales_Organization__c> ASOMap = new Map<String, Account_Sales_Organization__c>();
        Map<String, Pricebook2> pricebookMap = new Map<String, Pricebook2>();

        for(Contract_Framework__c contractFramework : contractFrameworks) {
            relatedASOIds.add(contractFramework.Branch_of_belonging_sales_office__c);
        }

        if(!relatedASOIds.isEmpty()) {
            relatedASOs = AccountSalesOrganizationDAO.getASOsFromIds(ASOQueryFields, relatedASOIds);

            if(!relatedASOs.isEmpty()) {
                for(Account_Sales_Organization__c aso : relatedASOs) {
                    ASOMap.put(aso.Id, aso);
                    
                    String pricebookExternalId = aso.Sales_Organization__r.Code__c;

                    if(aso.Distribution_Channel__c != null) {
                        pricebookExternalId = pricebookExternalId + aso.Distribution_Channel__c;
                    }

                    if(pricebookExternalId != null) {
                        pricebookExternalIds.add(pricebookExternalId);
                    }
                }
            }

            if(!pricebookExternalIds.isEmpty()) {
                relatedPricebooks = PricebookDAO.getPricebooksFromExternalIds(pricebookQueryFields, pricebookExternalIds);

                if(!relatedPricebooks.isEmpty()) {
                    for(Pricebook2 pricebook : relatedPricebooks) {
                        pricebookMap.put(pricebook.External_ID__c, pricebook);
                    }
                }
            }

            for(Contract_Framework__c contractFramework : contractFrameworks) {
                Account_Sales_Organization__c relatedASO = ASOMap.get(contractFramework.Branch_of_belonging_sales_office__c);

                if(relatedASO != null) {
                    if(contractFramework.Sales_Org_Code__c == null) {
                        contractFramework.Sales_Org_Code__c = relatedASO.Sales_Organization__r.Code__c;
                    }
                    
                    String pricebookExternalId = relatedASO.Sales_Organization__r.Code__c;

                    if(relatedASO.Distribution_Channel__c != null) {
                        pricebookExternalId = pricebookExternalId + relatedASO.Distribution_Channel__c;
                    }

                    if(pricebookExternalId != null) {
                        Pricebook2 relatedPricebook = pricebookMap.get(pricebookExternalId);

                        if(relatedPricebook != null) {
                            if(contractFramework.Price_list_code__c == null) {
                                contractFramework.Price_list_code__c = relatedPricebook.Id;
                            }

                            if(contractFramework.PriceListCode__c == null) {
                                contractFramework.PriceListCode__c = relatedPricebook.External_ID__c;
                            }
                        }
                    }
                }
            }
        }
    }

    public static void createContractPayer (List <Contract_Framework__c> inputFramework){
        String currentUserProfileId = UserInfo.getProfileId();
        List<String> profileQueryFields = new List<String>{'Name'};
        Profile currentUserProfile = ProfileDAO.getProfileById(profileQueryFields, currentUserProfileId);
        String profileName = currentUserProfile?.Name;
        if(profileName != null && profileName.contains('_NL')) {
            List <Contract_Payer__c> payers = new List <Contract_Payer__c>();
            for (Contract_Framework__c cf : inputFramework){
                Contract_Payer__c tmpPayer = new Contract_Payer__c();
                tmpPayer.Contract_Framework__c = cf.Id;
                tmpPayer.Account__c = cf.Customer__c;
                payers.add(tmpPayer);
            }
            insert payers;
        }
    }
}