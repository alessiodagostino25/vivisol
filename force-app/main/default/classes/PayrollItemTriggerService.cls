public inherited sharing class PayrollItemTriggerService {
    public static void setCategoryAndExternalId(List<Payroll_Item__c> payrollItems) {
        List<String> payrollHeaderQueryFields = new List<String>{'Company__r.Company_Code__c', 'Employee__r.Employee_Code__c', 'Month__c', 'Year__c'};

        List<String> payrollHeaderIds = new List<String>();
        List<String> companyCodes = new List<String>();
        List<String> itemCodes = new List<String>();
        List<Payroll_Header__c> payrollHeaders = new List<Payroll_Header__c>();

        Map<String, Payroll_Header__c> payrollHeaderMap = new Map<String, Payroll_Header__c>();
        Map<String, PayrollItem_Mapping__mdt> categoryMappingMap = new Map<String, PayrollItem_Mapping__mdt>();

        for(Payroll_Item__c payrollItem : payrollItems) {
            payrollHeaderIds.add(payrollItem.Payroll_Header__c);
            
            if(payrollItem.Item_Code__c != null) {
                itemCodes.add(payrollItem.Item_Code__c);
            }
        }

        payrollHeaders = PayrollHeaderDAO.getPayrollHeadersFromIds(payrollHeaderQueryFields, payrollHeaderIds);

        if(!payrollHeaders.isEmpty()) {
            for(Payroll_Header__c ph : payrollHeaders) {
                payrollHeaderMap.put(ph.Id, ph);

                if(ph.Company__c != null && ph.Company__r.Company_Code__c != null) {
                    companyCodes.add(ph.Company__r.Company_Code__c);
                }
            }

            List<PayrollItem_Mapping__mdt> categoryMappings = [SELECT Category__c, CompanyCode__c, ItemCode__c 
                                                               FROM PayrollItem_Mapping__mdt
                                                               WHERE CompanyCode__c IN: companyCodes AND ItemCode__c IN: itemCodes];

            System.debug('categoryMappings: ' + categoryMappings);
            
            if(categoryMappings != null && !categoryMappings.isEmpty()) {
                for(PayrollItem_Mapping__mdt mapping : categoryMappings) {
                    categoryMappingMap.put(String.valueOf(mapping.CompanyCode__c) + String.valueOf(mapping.ItemCode__c), mapping);
                }

                for(Payroll_Item__c payrollItem : payrollItems) {
                    Payroll_Header__c relatedPayrollHeader = payrollHeaderMap.get(payrollItem.Payroll_Header__c);
                    System.debug('relatedPayrollHeader: ' + relatedPayrollHeader);

                    if(relatedPayrollHeader != null) {
                        PayrollItem_Mapping__mdt relatedCategoryMapping = categoryMappingMap.get(
                            String.valueOf(relatedPayrollHeader.Company__r.Company_Code__c) + String.valueOf(payrollItem.Item_Code__c)
                        );
                        System.debug('relatedCategoryMapping: ' + relatedCategoryMapping);

                        if(relatedCategoryMapping != null) {
                            payrollItem.Category__c = relatedCategoryMapping.Category__c;
                        }

                        // Setting External Id

                        if(payrollItem.External_Id__c == null) {
                            payrollItem.External_Id__c = relatedPayrollHeader.Employee__r.Employee_Code__c + relatedPayrollHeader.Month__c + relatedPayrollHeader.Year__c + 
                            payrollItem.Item_Code__c;
                        }
                    }
                }
            }
        }
    }
}