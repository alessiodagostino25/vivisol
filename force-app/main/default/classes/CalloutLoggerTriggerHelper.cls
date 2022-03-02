public class CalloutLoggerTriggerHelper {
    public static void assignCalloutLoggers(List<Callout_Logger__c> calloutLoggers) {
        List<Callout_Logger__c> accountCalloutLoggers = new List<Callout_Logger__c>();
        List<Callout_Logger__c> accountCompanyCalloutLoggers = new List<Callout_Logger__c>();
        List<Callout_Logger__c> ASOCalloutLoggers = new List<Callout_Logger__c>();
        List<Callout_Logger__c> addressCalloutLoggers = new List<Callout_Logger__c>();
        List<Callout_Logger__c> contractFrameworkCalloutLoggers = new List<Callout_Logger__c>();
        List<Callout_Logger__c> workOrderCalloutLoggers = new List<Callout_Logger__c>();
        List<Callout_Logger__c> productRequestCalloutLoggers = new List<Callout_Logger__c>();
        List<Callout_Logger__c> measurementCalloutLoggers = new List<Callout_Logger__c>();
        List<Callout_Logger__c> quoteLineItemCalloutLoggers = new List<Callout_Logger__c>();
        List<Callout_Logger__c> orderItemCalloutLoggers = new List<Callout_Logger__c>();
        List<Callout_Logger__c> endOfMonthHeaderCalloutLoggers = new List<Callout_Logger__c>();
        List<Callout_Logger__c> rebateCalloutLoggers = new List<Callout_Logger__c>();
        List<Callout_Logger__c> assetCalloutLoggers = new List<Callout_Logger__c>();
        List<Callout_Logger__c> PAPHCalloutLoggers = new List<Callout_Logger__c>();
        List<Callout_Logger__c> accountTreatmentCalloutLoggers = new List<Callout_Logger__c>();

        for(Callout_Logger__c cl : calloutLoggers) {
            switch on cl.Service__c {
                when 'SFDC_SAP4HANA__PATIENT_CREATE', 'SFDC_SAP4HANA__PATIENT_UPDATE', 'SFDC_PIMCORE_CUSTOMER_UPSERT', 'PIMCORE_SFDC_CUSTOMER_UPSERT' {
                    accountCalloutLoggers.add(cl);
                }
                when 'SFDC_SAP4HANA__SO_CREATE', 'SFDC_SAP4HANA__SO_UPDATE' {
                    if(cl.Object__c == 'Account_Sales_Organization__c') {
                        ASOCalloutLoggers.add(cl);
                    }
                    else if(cl.Object__c == 'Account_Company__c') {
                        accountCompanyCalloutLoggers.add(cl);
                    }
                }
                when 'SFDC_SAP4HANA__ADDRESS_CREATE', 'SFDC_SAP4HANA__ADDRESS_UPDATE', 'PIMCORE_SFDC_ADDRESS_UPSERT', 'SFDC_PIMCORE_ADDRESS_UPSERT' {
                    addressCalloutLoggers.add(cl);
                }
                when 'SFDC_SAP4HANA__CONTRACT', 'SFDC_PIMCORE_CONTRACT_FRAMEWORK__UPSERT' {
                    contractFrameworkCalloutLoggers.add(cl);
                }
                when 'HEROKU_SAP4HANA__WORKORDER_UPSERT', 'SAP4HANA_SFDC__END_DELIVERY', 'SFDC_PIMCORE_ORDER', 'PIMCORE_SFDC_ORDER_CREATE' {
                    workOrderCalloutLoggers.add(cl);
                }
                when 'SFDC_SAP4HANA__PICKING_LOADING_UPDATE', 'SFDC_SAP4HANA__VAN_UNLOADING' {
                    productRequestCalloutLoggers.add(cl);
                }
                when 'SFDC_SAP4HANA__MEASUREMENT_POINT_CREATE' {
                    measurementCalloutLoggers.add(cl);
                }
                when 'SFDC_SAP4HANA__PRODUCT_PRICE' {
                    if(cl.Object__c == 'Quote_Line_Item__c') {
                        quoteLineItemCalloutLoggers.add(cl);
                    }
                    else if(cl.Object__c == 'OrderItem') {
                        orderItemCalloutLoggers.add(cl);
                    }
                }
                when 'HEROKU_SAP4HANA__BILLING_DATA' {
                    endOfMonthHeaderCalloutLoggers.add(cl);
                }
                when 'HEROKU_SAP4HANA__REBATE_DATA' {
                    rebateCalloutLoggers.add(cl);
                }
                when 'SFDC_PIMCORE_EQUIPMENT_UPSERT' {
                    assetCalloutLoggers.add(cl);
                }
                when 'SFDC_PIMCORE_PAPH__UPSERT' {
                    PAPHCalloutLoggers.add(cl);
                }
                when 'SFDC_PIMCORE_PATIENT_TREATMENT_UPSERT' {
                    accountTreatmentCalloutLoggers.add(cl);
                }
            }
        }

        if(!accountCalloutLoggers.isEmpty()) {
            assignAccountCalloutLoggers(accountCalloutLoggers);
        }

        if(!ASOCalloutLoggers.isEmpty()) {
            assignASOCalloutLoggers(ASOCalloutLoggers);
        }

        if(!accountCompanyCalloutLoggers.isEmpty()) {
            assignAccountCompanyCalloutLoggers(accountCompanyCalloutLoggers);
        }

        if(!addressCalloutLoggers.isEmpty()) {
            assignAddressCalloutLoggers(addressCalloutLoggers);
        }

        if(!contractFrameworkCalloutLoggers.isEmpty()) {
            assignContractFrameworkCalloutLoggers(contractFrameworkCalloutLoggers);
        }

        if(!workOrderCalloutLoggers.isEmpty()) {
            assignWorkOrderCalloutLoggers(workOrderCalloutLoggers);
        }

        if(!productRequestCalloutLoggers.isEmpty()) {
            assignProductRequestCalloutLoggers(productRequestCalloutLoggers);
        }

        if(!measurementCalloutLoggers.isEmpty()) {
            assignMeasurementCalloutLoggers(measurementCalloutLoggers);
        }

        if(!quoteLineItemCalloutLoggers.isEmpty()) {
            assignQuoteLineItemCalloutLoggers(quoteLineItemCalloutLoggers);
        }

        if(!orderItemCalloutLoggers.isEmpty()) {
            assignOrderItemCalloutLoggers(orderItemCalloutLoggers);
        }

        if(!endOfMonthHeaderCalloutLoggers.isEmpty()) {
            assignEndOfMonthHeaderCalloutLoggers(endOfMonthHeaderCalloutLoggers);
        }

        if(!rebateCalloutLoggers.isEmpty()) {
            assignRebateCalloutLoggers(rebateCalloutLoggers);
        }

        if(!assetCalloutLoggers.isEmpty()) {
            assignAssetCalloutLoggers(assetCalloutLoggers);
        }

        if(!PAPHCalloutLoggers.isEmpty()) {
            assignPAPHCalloutLoggers(PAPHCalloutLoggers);
        }

        if(!accountTreatmentCalloutLoggers.isEmpty()) {
            assignATCalloutLoggers(accountTreatmentCalloutLoggers);
        }
    }

    public static void assignAccountCalloutLoggers(List<Callout_Logger__c> calloutLoggers) {
        List<String> accountQueryFields = new List<String>{'Account_External_Id__c'};

        List<String> accountExternalIds = new List<String>();

        Map<String, Account> extIdToAccountMap = new Map<String, Account>();

        for(Callout_Logger__c cl : calloutLoggers) {
            accountExternalIds.add(cl.RecordId__c);
        }

        List<Account> relatedAccounts = AccountDAO.getAccountFromRecordIds(accountQueryFields, accountExternalIds);

        for(Account a : relatedAccounts) {
            extIdToAccountMap.put(a.Account_External_Id__c, a);
        }

        for(Callout_Logger__c cl : calloutLoggers) {
            Account relatedAccount = extIdToAccountMap.get(cl.RecordId__c);

            if(relatedAccount != null) {
                cl.Related_Account__c = relatedAccount.Id;
            }
        }
    }

    public static void assignASOCalloutLoggers(List<Callout_Logger__c> calloutLoggers) {
        List<String> ASOQueryFields = new List<String>{'External_Id__c'};

        List<String> ASOExternalIds = new List<String>();

        Map<String, Account_Sales_Organization__c> extIdToASOMap = new Map<String, Account_Sales_Organization__c>();

        for(Callout_Logger__c cl : calloutLoggers) {
            ASOExternalIds.add(cl.RecordId__c);
        }

        List<Account_Sales_Organization__c> relatedASOs = AccountSalesOrganizationDAO.getASOsFromRecordIds(ASOQueryFields, ASOExternalIds);

        for(Account_Sales_Organization__c aso : relatedASOs) {
            extIdToASOMap.put(aso.External_Id__c, aso);
        }

        for(Callout_Logger__c cl : calloutLoggers) {
            Account_Sales_Organization__c relatedASO = extIdToASOMap.get(cl.RecordId__c);

            if(relatedASO != null) {
                cl.Related_Account_Sales_Organization__c = relatedASO.Id;
            }
        }
    }

    public static void assignAccountCompanyCalloutLoggers(List<Callout_Logger__c> calloutLoggers) {
        List<String> accountCompanyQueryFields = new List<String>{'External_ID__c'};

        List<String> accountCompanyExternalIds = new List<String>();

        Map<String, Account_Company__c> extIdToACMap = new Map<String, Account_Company__c>();

        for(Callout_Logger__c cl : calloutLoggers) {
            accountCompanyExternalIds.add(cl.RecordId__c);
        }

        List<Account_Company__c> relatedAccountCompanies = AccountCompanyDAO.getAccountcompanyFromRecordIds(accountCompanyQueryFields, accountCompanyExternalIds);

        for(Account_Company__c ac : relatedAccountCompanies) {
            extIdToACMap.put(ac.External_ID__c, ac);
        }

        for(Callout_Logger__c cl : calloutLoggers) {
            Account_Company__c relatedAC = extIdToACMap.get(cl.RecordId__c);

            if(relatedAC != null) {
                cl.Related_Account_Company__c = relatedAC.Id;
            }
        }
    }

    public static void assignAddressCalloutLoggers(List<Callout_Logger__c> calloutLoggers) {
        List<String> addressExternalIds = new List<String>();

        Map<String, Schema.Address> locationIdToAddressMap = new Map<String, Schema.Address>();

        for(Callout_Logger__c cl : calloutLoggers) {
            addressExternalIds.add(cl.RecordId__c);
        }

        List<Schema.Address> relatedAddresses = AddressDAO.getAddressesForCalloutLoggers(addressExternalIds);

        for(Schema.Address address : relatedAddresses) {
            locationIdToAddressMap.put(address.Parent.Location_Id__c, address);
        }

        for(Callout_Logger__c cl : calloutLoggers) {
            Schema.Address relatedAddress = locationIdToAddressMap.get(cl.RecordId__c);

            if(relatedAddress != null) {
                cl.Related_Address__c = relatedAddress.Id;
            }
        }
    }

    public static void assignContractFrameworkCalloutLoggers(List<Callout_Logger__c> calloutLoggers) {
        List<String> contractFrameworkQueryFields = new List<String>{'Contract_Number__c'};

        List<String> contractFrameworkExternalIds = new List<String>();

        Map<String, Contract_Framework__c> extIdToFrameworkMap = new Map<String, Contract_Framework__c>();

        for(Callout_Logger__c cl : calloutLoggers) {
            contractFrameworkExternalIds.add(cl.RecordId__c);
        }

        List<Contract_Framework__c> relatedContractFrameworks = ContractFrameworkDAO.getCFsFromrecordids(contractFrameworkQueryFields, contractFrameworkExternalIds);

        for(Contract_Framework__c cf : relatedContractFrameworks) {
            extIdToFrameworkMap.put(cf.Contract_Number__c, cf);
        }

        for(Callout_Logger__c cl : calloutLoggers) {
            Contract_Framework__c relatedCF = extIdToFrameworkMap.get(cl.RecordId__c);

            if(relatedCF != null) {
                cl.Related_Contract_Framework__c = relatedCF.Id;
            }
        }
    }

    public static void assignWorkOrderCalloutLoggers(List<Callout_Logger__c> calloutLoggers) {
        List<String> workOrderQueryFields = new List<String>{'OrderExternalId__c'};

        List<String> workOrderExternalIds = new List<String>();

        Map<String, WorkOrder> extIdToWorkOrderMap = new Map<String, WorkOrder>();

        for(Callout_Logger__c cl : calloutLoggers) {
            workOrderExternalIds.add(cl.RecordId__c);
        }

        List<WorkOrder> relatedWorkOrders = WorkOrderDAO.getWorkOrdersFromExternalIds(workOrderQueryFields, workOrderExternalIds);

        for(WorkOrder wo : relatedWorkOrders) {
            extIdToWorkOrderMap.put(wo.OrderExternalId__c, wo);
        }

        for(Callout_Logger__c cl : calloutLoggers) {
            WorkOrder relatedWO = extIdToWorkOrderMap.get(cl.RecordId__c);

            if(relatedWO != null) {
                cl.Related_Work_Order__c = relatedWO.Id;
            }
        }
    }

    public static void assignProductRequestCalloutLoggers(List<Callout_Logger__c> calloutLoggers) {
        for(Callout_Logger__c cl : calloutLoggers) {
            cl.Related_Product_Request__c = cl.RecordId__c;
        }
    }

    public static void assignMeasurementCalloutLoggers(List<Callout_Logger__c> calloutLoggers) {
        for(Callout_Logger__c cl : calloutLoggers) {
            cl.Related_Measurement__c = cl.RecordId__c;
        }
    }

    public static void assignQuoteLineItemCalloutLoggers(List<Callout_Logger__c> calloutLoggers) {
        for(Callout_Logger__c cl : calloutLoggers) {
            cl.Related_Quote_Line_Item__c = cl.RecordId__c;
        }
    }

    public static void assignOrderItemCalloutLoggers(List<Callout_Logger__c> calloutLoggers) {
        for(Callout_Logger__c cl : calloutLoggers) {
            cl.Related_Order_Item__c = cl.RecordId__c;
        }
    }

    public static void assignEndOfMonthHeaderCalloutLoggers(List<Callout_Logger__c> calloutLoggers) {
        List<String> EOMHQueryFields = new List<String>{'ext_order_id__c'};

        List<String> EOMHExternalIds = new List<String>();

        Map<String, EndOfMonthHeader__c> extIdToEOMHMap = new Map<String, EndOfMonthHeader__c>();

        for(Callout_Logger__c cl : calloutLoggers) {
            EOMHExternalIds.add(cl.RecordId__c);
        }

        List<EndOfMonthHeader__c> relatedEOMHs = EndOfMonthHeaderDAO.getEOMHsFromExternalIds(EOMHQueryFields, EOMHExternalIds);

        for(EndOfMonthHeader__c eomh : relatedEOMHs) {
            extIdToEOMHMap.put(eomh.ext_order_id__c, eomh);
        }

        for(Callout_Logger__c cl : calloutLoggers) {
            EndOfMonthHeader__c relatedEOMH = extIdToEOMHMap.get(cl.RecordId__c);

            if(relatedEOMH != null) {
                cl.Related_EOM__c = relatedEOMH.Id;
            }
        }
    }

    public static void assignRebateCalloutLoggers(List<Callout_Logger__c> calloutLoggers) {
        List<String> rebateQueryFields = new List<String>{'id_rebate__c'};

        List<String> rebateExternalIds = new List<String>();

        Map<String, Rebate__c> extIdToRebateMap = new Map<String, Rebate__c>();

        for(Callout_Logger__c cl : calloutLoggers) {
            rebateExternalIds.add(cl.RecordId__c);
        }

        List<Rebate__c> relatedRebates = RebateDAO.getRebatesFromExternalIds(rebateQueryFields, rebateExternalIds);

        for(Rebate__c rebate : relatedRebates) {
            extIdToRebateMap.put(rebate.id_rebate__c, rebate);
        }

        for(Callout_Logger__c cl : calloutLoggers) {
            Rebate__c relatedRebate = extIdToRebateMap.get(cl.RecordId__c);

            if(relatedRebate != null) {
                cl.Related_Rebate__c = relatedRebate.Id;
            }
        }
    }

    public static void assignAssetCalloutLoggers(List<Callout_Logger__c> calloutLoggers) {
        List<String> assetQueryFields = new List<String>{'Equipment_Key__c'};

        List<String> assetExternalIds = new List<String>();

        Map<String, Asset> extIdToAssetMap = new Map<String, Asset>();

        for(Callout_Logger__c cl : calloutLoggers) {
            assetExternalIds.add(cl.RecordId__c);
        }

        List<Asset> relatedAssets = AssetDAO.getAssetsFromEquipmentKey(assetQueryFields, assetExternalIds);

        for(Asset asset : relatedAssets) {
            extIdToAssetMap.put(asset.Equipment_Key__c, asset);
        }

        for(Callout_Logger__c cl : calloutLoggers) {
            Asset relatedAsset = extIdToAssetMap.get(cl.RecordId__c);

            if(relatedAsset != null) {
                cl.Related_Asset__c = relatedAsset.Id;
            }
        }
    }

    public static void assignPAPHCalloutLoggers(List<Callout_Logger__c> calloutLoggers) {
        List<String> PAPHQueryFields = new List<String>{'External_Id__c'};

        List<String> PAPHExternalIds = new List<String>();

        Map<String, Product_Asset_Patient_History__c> extIdToPAPHMap = new Map<String, Product_Asset_Patient_History__c>();

        for(Callout_Logger__c cl : calloutLoggers) {
            PAPHExternalIds.add(cl.RecordId__c);
        }

        List<Product_Asset_Patient_History__c> relatedPAPHs = ProductAssetPatientHistoryDAO.getPAPHFromExternalIds(PAPHQueryFields, PAPHExternalIds);

        for(Product_Asset_Patient_History__c paph : relatedPAPHs) {
            extIdToPAPHMap.put(paph.External_Id__c, paph);
        }

        for(Callout_Logger__c cl : calloutLoggers) {
            Product_Asset_Patient_History__c relatedPAPH = extIdToPAPHMap.get(cl.RecordId__c);

            if(relatedPAPH != null) {
                cl.Related_PAPH__c = relatedPAPH.Id;
            }
        }
    }

    public static void assignATCalloutLoggers(List<Callout_Logger__c> calloutLoggers) {
        List<String> ATQueryFields = new List<String>{'External_Id__c'};

        List<String> ATExternalIds = new List<String>();

        Map<String, Account_Treatment__c> extIdToATMap = new Map<String, Account_Treatment__c>();

        for(Callout_Logger__c cl : calloutLoggers) {
            ATExternalIds.add(cl.RecordId__c);
        }

        List<Account_Treatment__c> relatedATs = AccountTreatmentDAO.getATsFromExternalIds(ATQueryFields, ATExternalIds);

        for(Account_Treatment__c at : relatedATs) {
            extIdToATMap.put(at.External_Id__c, at);
        }

        for(Callout_Logger__c cl : calloutLoggers) {
            Account_Treatment__c relatedAT = extIdToATMap.get(cl.RecordId__c);

            if(relatedAT != null) {
                cl.Related_Account_Treatment__c = relatedAT.Id;
            }
        }
    }

    public static void deleteOlderLogs(List<Callout_Logger__c> calloutLoggers) {
        System.debug('----- deleteOlderLogs -----');

        List<Delete_Older_Logs__e> eventsToPublish = new List<Delete_Older_Logs__e>();

        for(Callout_Logger__c cl : calloutLoggers) {
            Delete_Older_Logs__e deleteOlderLogsEvent = new Delete_Older_Logs__e(
                Record_Id__c = cl.RecordId__c,
                UUID_Flow__c = cl.UUID_Flow__c,
                Service__c = cl.Service__c
            );
            System.debug('DeleteOlderLogs Event: ' + deleteOlderLogsEvent);

            eventsToPublish.add(deleteOlderLogsEvent);
        }

        List<Database.SaveResult> results = EventBus.publish(eventsToPublish);
    }
}