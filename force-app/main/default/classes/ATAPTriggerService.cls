public class ATAPTriggerService {
    
    public static List<WorkOrder> updateRelatedWOsPayerFields(List<Id> ATAPIds) {

        System.debug('----- updateRelatedWOsPayerFields -----');

        List<String> ATAPQueryFields = new List<String>{'Payer__c', 'Account_Treatment__c', 'Account_Treatment_Address__r.Location__c'};
        List<String> workOrderQueryFields = new List<String>{'Payer__c', 'Account_Treatment__c', 'Account_BillTo__c', 'LocationId', 
        'Account_Sales_Organization__r.Sales_Organization__c', 'Account_Sold_To__c', 'IsEmergency__c', 'Contract_Framework__c'};

        List<Id> relatedLocationIds = new List<Id>();
        List<Id> relatedAccountTreatmentIds = new List<Id>();
        List<WorkOrder> workOrdersToUpdate = new List<WorkOrder>();

        List<Account_Treatment_Address_Payer__c> ATAPs = AccountTreatmentAddressPayerDAO.getATAPsFromIds(ATAPQueryFields, ATAPIds);

        System.debug('ATAPs: ' + ATAPs);

        for(Account_Treatment_Address_Payer__c atap : ATAPs) {
            relatedLocationIds.add(atap.Account_Treatment_Address__r.Location__c);
            relatedAccountTreatmentIds.add(atap.Account_Treatment__c);
        }

        List<WorkOrder> relatedWorkOrders = WorkOrderDAO.getWOsRelatedToATAPs(workOrderQueryFields, relatedLocationIds, relatedAccountTreatmentIds);

        System.debug('relatedWorkOrders: ' + relatedWorkOrders);

        if(!relatedWorkOrders.isEmpty()) {
            System.debug('relatedWorkOrders size: ' + relatedWorkOrders.size());
            System.debug('calling WorkOrderService.setPayerFields...');
            
            workOrdersToUpdate = WorkOrderService.setPayerFields(relatedWorkOrders, 'BEFORE_UPDATE');
        }

        return workOrdersToUpdate;
    }

    public static void checkForDuplicates(List<Account_Treatment_Address_Payer__c> ATAPs) {
        List<String> ATAPQueryFields = new List<String>{'Account_Treatment_Address__c', 'Payer__c'};

        List<String> ATAIds = new List<String>();
        List<String> payerIds = new List<String>();
        Map<String, Account_Treatment_Address_Payer__c> ATAPMap = new Map<String, Account_Treatment_Address_Payer__c>();

        for(Account_Treatment_Address_Payer__c ATAP : ATAPs) {
            if(ATAP.Account_Treatment_Address__c != null) {
                ATAIds.add(ATAP.Account_Treatment_Address__c);
            }
            if(ATAP.Payer__c != null) {
                payerIds.add(ATAP.Payer__c);
            }

            if(ATAP.Account_Treatment_Address__c != null && ATAP.Payer__c != null) {
                ATAPMap.put(String.valueOf(ATAP.Account_Treatment_Address__c) + String.valueOf(ATAP.Payer__c), ATAP);
            }
        }

        if(!ATAIds.isEmpty() && !payerIds.isEmpty()) {
            List<Account_Treatment_Address_Payer__c> possibleDuplicates = AccountTreatmentAddressPayerDAO.getATAPsFromAddressAndPayer(ATAPQueryFields, ATAIds, payerIds);
            
            if(possibleDuplicates != null && !possibleDuplicates.isEmpty()) {
                for(Account_Treatment_Address_Payer__c possibleDuplicate : possibleDuplicates) {
                    Account_Treatment_Address_Payer__c duplicate = ATAPMap.get(
                        String.valueOf(possibleDuplicate.Account_Treatment_Address__c) + String.valueOf(possibleDuplicate.Payer__c));

                    if(duplicate != null) {
                        duplicate.addError(Label.ATAP_Duplicate_Exception);
                    }
                }
            }
        }
    }
}