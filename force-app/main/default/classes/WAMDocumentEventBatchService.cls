public class WAMDocumentEventBatchService {
    
    public static List<WAM_Document__e> createWAMDocumentEvents(List<ContentDocumentLink> contentDocumentLinks) {
        List<WAM_Document__e> WAMDocumentEvents = new List<WAM_Document__e>();
        List<ContentDocumentLink> prescriptionCDLs = new List<ContentDocumentLink>();
        List<ContentDocumentLink> serviceAppointmentCDLs = new List<ContentDocumentLink>();
        List<ContentDocumentLink> workOrderCDLs = new List<ContentDocumentLink>();
        List<ContentDocumentLink> workOrderLineItemCDLs = new List<ContentDocumentLink>();
        List<ContentVersion> allLatestContentVersions = new List<ContentVersion>();
        List<String> contentDocumentIds = new List<String>();
        List<ContentVersion> toUpdateExternalId = new List<ContentVersion>();

        Map<String, ContentVersion> contentDocumentToLatestVersionMap = new Map<String, ContentVersion>();

        for(ContentDocumentLink cdl : contentDocumentLinks) {
            System.debug('cdl: ' + cdl);
            Id linkedEntityId = cdl.LinkedEntityId;

            if(linkedEntityId != null) {
                String sObjectName = linkedEntityId.getSObjectType().getDescribe().getName();
                System.debug('sObjectName: ' + sObjectName);

                switch on sObjectName {
                    when 'Prescription__c' {
                        prescriptionCDLs.add(cdl);
                    }
                    when 'ServiceAppointment' {
                        serviceAppointmentCDLs.add(cdl);
                    }
                    when 'WorkOrder' {
                        workOrderCDLs.add(cdl);
                    }
                    when 'WorkOrderLineItem' {
                        workOrderLineItemCDLs.add(cdl);
                    }
                }
            }

            contentDocumentIds.add(cdl.ContentDocumentId);
        }

        // Getting all the latest ContentVersion for each ContentDocument linked to each CDL

        allLatestContentVersions = [SELECT Id, Category__c, ContentDocumentId, Content_Version_Number__c, External_Id__c FROM ContentVersion 
                                    WHERE IsLatest = true AND ContentDocumentId IN: contentDocumentIds];

        if(!allLatestContentVersions.isEmpty()) {
            for(ContentVersion cv : allLatestContentVersions) {
                if(cv.External_Id__c == null && cv.Content_Version_Number__c != null) {
                    cv.External_Id__c = cv.Content_Version_Number__c;
                    toUpdateExternalId.add(cv);
                }
                contentDocumentToLatestVersionMap.put(cv.ContentDocumentId, cv);
            }
        }

        // Eventually updating missing External Id

        if(!toUpdateExternalId.isEmpty()) {
            List<Database.SaveResult> results = Database.update(toUpdateExternalId, false);
        }

        // Creating platform events for different sObjects

        if(!prescriptionCDLs.isEmpty()) {
            List<WAM_Document__e> prescriptionWAMDocumentEvents = createPrescriptionWAMDocumentEvents(prescriptionCDLs, contentDocumentToLatestVersionMap);

            for(WAM_Document__e event : prescriptionWAMDocumentEvents) {
                WAMDocumentEvents.add(event);
            }
        }

        if(!serviceAppointmentCDLs.isEmpty()) {
            List<WAM_Document__e> serviceAppointmentWAMDocumentEvents = createServiceAppointmentWAMDocumentEvents(serviceAppointmentCDLs, contentDocumentToLatestVersionMap);

            for(WAM_Document__e event : serviceAppointmentWAMDocumentEvents) {
                WAMDocumentEvents.add(event);
            }
        }

        if(!workOrderCDLs.isEmpty()) {
            List<WAM_Document__e> workOrderWAMDocumentEvents = createWorkOrderWAMDocumentEvents(workOrderCDLs, contentDocumentToLatestVersionMap);

            for(WAM_Document__e event : workOrderWAMDocumentEvents) {
                WAMDocumentEvents.add(event);
            }
        }

        if(!workOrderLineItemCDLs.isEmpty()) {
            List<WAM_Document__e> workOrderLineItemWAMDocumentEvents = createWorkOrderLineItemWAMDocumentEvents(workOrderLineItemCDLs, contentDocumentToLatestVersionMap);

            for(WAM_Document__e event : workOrderLineItemWAMDocumentEvents) {
                WAMDocumentEvents.add(event);
            }
        }

        return WAMDocumentEvents;
    }

    public static List<WAM_Document__e> createPrescriptionWAMDocumentEvents(List<ContentDocumentLink> prescriptionCDLs, Map<String, ContentVersion> contentDocumentToLatestVersionMap) {
        System.debug('----- createPrescriptionWAMDocumentEvents -----');

        List<String> prescriptionQueryFields = new List<String>{'Name', 'Received_Date__c', 'Patient__r.Name', 'Patient__r.VAT_Number__c', 'Patient__r.Account_External_Id__c', 
        'Patient__r.Fiscal_Code__c', 'Sales_Organization__r.Code__c', 'Address__r.VisitorAddress.CountryCode'};

        List<Id> prescriptionIds = new List<Id>();
        List<Prescription__c> prescriptions = new List<Prescription__c>();
        List<WAM_Document__e> prescriptionWAMDocumentEvents = new List<WAM_Document__e>();

        Map<Id, Prescription__c> prescriptionMap = new Map<Id, Prescription__c>();

        for(ContentDocumentLink cdl : prescriptionCDLs) {
            prescriptionIds.add(cdl.LinkedEntityId);
            System.debug('cdl.LinkedEntityId: ' + cdl.LinkedEntityId);
        }

        prescriptions = PrescriptionDAO.getPrescriptionsFromIds(prescriptionQueryFields, prescriptionIds);

        if(!prescriptions.isEmpty()) {
            for(Prescription__c p : prescriptions) {
                prescriptionMap.put(p.Id, p);
            }

            for(ContentDocumentLink cdl : prescriptionCDLs) {
                Prescription__c relatedPrescription = prescriptionMap.get(cdl.LinkedEntityId);
                ContentVersion latestVersion = contentDocumentToLatestVersionMap.get(cdl.ContentDocumentId);

                if(relatedPrescription != null) {
                    WAM_Document__e WAMDocumentEvent = new WAM_Document__e(
                        Salesforce_Document_Id__c = cdl.ContentDocumentId,
                        Related_Record_Id__c = cdl.LinkedEntityId,
                        Related_Record_Type__c = 'Prescription__c',
                        DDT_Numero__c = relatedPrescription.Name,
                        Cliente_Ragione_Sociale__c = relatedPrescription.Patient__r.Name,
                        Cliente_PIva__c = relatedPrescription.Patient__r.VAT_Number__c,
                        S_Centro_di_Vendita__c = relatedPrescription.Sales_Organization__r.Code__c,
                        //S_Centro_di_Spedizione__c = ?,
                        //S_Codice_Destinatario_Merce__c = ?,
                        //S_Ragione_Sociale_Destinatario_Merce__c = ?,
                        S_Message_ID__c = cdl.ContentDocumentId,
                        S_Document_ID__c = cdl.ContentDocumentId,
                        S_Recipient_Entity_Id__c = relatedPrescription.Patient__r.Account_External_Id__c,
                        S_Recipient_Code__c = relatedPrescription.Patient__r.Account_External_Id__c,
                        //S_Delivery_Date__c = ?,
                        S_Country__c = relatedPrescription.Address__r.VisitorAddress.CountryCode,
                        //S_Customer_Payer_Code__c = ?,
                        //S_Customer_Payer_Name__c = ?,
                        Cliente_CF__c = relatedPrescription.Patient__r.Fiscal_Code__c,
                        S_Barcode39__c = '',
                        S_UfficioVendite__c = relatedPrescription.Sales_Organization__r.Code__c,
                        //S_NomeDriver__c = ?,
                        //S_CodiceDriver__c = ?,
                        Tablet__c = '1',
                        S_Annullata__c = '0'
                    );

                    if(relatedPrescription.Received_date__c != null) {
                        WAMDocumentEvent.DDT_Data__c = formatToPlainString(relatedPrescription.Received_date__c);
                    }

                    if(latestVersion != null && latestVersion.Category__c != null) {
                        WAMDocumentEvent.Category__c = latestVersion.Category__c;
                    }
                    else {
                        WAMDocumentEvent.Category__c = '91';
                    }

                    prescriptionWAMDocumentEvents.add(WAMDocumentEvent);
                    System.debug('EVENT: ' + WAMDocumentEvent);
                }
            }
        }

        return prescriptionWAMDocumentEvents;
    }

    public static List<WAM_Document__e> createServiceAppointmentWAMDocumentEvents(List<ContentDocumentLink> serviceAppointmentCDLs, Map<String, ContentVersion> contentDocumentToLatestVersionMap) {
        System.debug('----- createServiceAppointmentWAMDocumentEvents -----');

        List<String> serviceAppointmentQueryFields = new List<String>{'ActualStartTime', 'Account.Name', 'Account.VAT_Number__c', 'Account.Account_External_Id__c',
        'Account.Fiscal_Code__c', 'ParentRecordId'};

        List<String> workOrderQueryFields = new List<String>{'Sales_Office__c', 'SAP_Storage_Location__r.Location_Id__c', 'StartDate', 'CountryCode', 
        'Payer__r.Account_External_Id__c', 'Payer__r.Name', 'SalesOrganization__c', 'Resource__r.Name', 'Resource__r.BPResource__c'};

        List<Id> serviceAppointmentIds = new List<Id>();
        List<Id> relatedWorkOrderIds = new List<Id>();
        List<ServiceAppointment> serviceAppointments = new List<ServiceAppointment>();
        List<WorkOrder> relatedWorkOrders = new List<WorkOrder>();
        List<WAM_Document__e> serviceAppointmentWAMDocumentEvents = new List<WAM_Document__e>();

        Map<Id, WorkOrder> workOrderMap = new Map<Id, WorkOrder>();
        Map<Id, ServiceAppointment> serviceAppointmentMap = new Map<Id, ServiceAppointment>();

        for(ContentDocumentLink cdl : serviceAppointmentCDLs) {
            serviceAppointmentIds.add(cdl.LinkedEntityId);
            System.debug('cdl.LinkedEntityId: ' + cdl.LinkedEntityId);
        }

        serviceAppointments = ServiceAppointmentDAO.getSAsFromIds(serviceAppointmentQueryFields, serviceAppointmentIds);

        if(!serviceAppointments.isEmpty()) {
            for(ServiceAppointment sa : serviceAppointments) {
                relatedWorkOrderIds.add(sa.ParentRecordId);
                serviceAppointmentMap.put(sa.Id, sa);
            }

            relatedWorkOrders = WorkOrderDAO.getWorkOrdersFromIds(workOrderQueryFields, relatedWorkOrderIds);

            if(!relatedWorkOrders.isEmpty()) {
                for(WorkOrder wo : relatedWorkOrders) {
                    workOrderMap.put(wo.Id, wo);
                }
            }

            for(ContentDocumentLink cdl : serviceAppointmentCDLs) {
                ServiceAppointment relatedServiceAppointment = serviceAppointmentMap.get(cdl.LinkedEntityId);
                ContentVersion latestVersion = contentDocumentToLatestVersionMap.get(cdl.ContentDocumentId);

                System.debug('relatedServiceAppointment: ' + relatedServiceAppointment);

                if(relatedServiceAppointment != null) {
                    WorkOrder relatedWorkOrder = workOrderMap.get(relatedServiceAppointment.ParentRecordId);
                    System.debug('relatedWorkOrder: ' + relatedWorkOrder);

                    if(relatedWorkOrder != null) {
                        WAM_Document__e WAMDocumentEvent = new WAM_Document__e(
                            Salesforce_Document_Id__c = cdl.ContentDocumentId,
                            Related_Record_Id__c = relatedWorkOrder.Id,
                            Related_Record_Type__c = 'WorkOrder',
                            DDT_Numero__c = cdl.ContentDocument.Title,
                            Cliente_Ragione_Sociale__c = relatedServiceAppointment.Account.Name,
                            Cliente_PIva__c = relatedServiceAppointment.Account.VAT_Number__c,
                            S_Centro_di_Vendita__c = relatedWorkOrder.Sales_Office__c,
                            S_Centro_di_Spedizione__c = relatedWorkOrder.SAP_Storage_Location__r.Location_Id__c,
                            S_Codice_Destinatario_Merce__c = relatedServiceAppointment.Account.Account_External_Id__c,
                            S_Ragione_Sociale_Destinatario_Merce__c = relatedServiceAppointment.Account.Name,
                            S_Message_ID__c = cdl.ContentDocumentId,
                            S_Document_ID__c = cdl.ContentDocumentId,
                            S_Recipient_Entity_Id__c = relatedServiceAppointment.Account.Account_External_Id__c,
                            S_Recipient_Code__c = relatedServiceAppointment.Account.Account_External_Id__c,
                            S_Country__c = relatedWorkOrder.CountryCode,
                            S_Customer_Payer_Code__c = relatedWorkOrder.Payer__r.Account_External_Id__c,
                            S_Customer_Payer_Name__c = relatedWorkOrder.Payer__r.Name,
                            Cliente_CF__c = relatedServiceAppointment.Account.Fiscal_Code__c,
                            S_Barcode39__c = '',
                            S_UfficioVendite__c = relatedWorkOrder.SalesOrganization__c,
                            S_NomeDriver__c = relatedWorkOrder.Resource__r.Name,
                            S_CodiceDriver__c = relatedWorkOrder.Resource__r.BPResource__c,
                            Tablet__c = '1',
                            S_Annullata__c = '0'
                        );

                        if(relatedServiceAppointment.ActualStartTime != null) {
                            WAMDocumentEvent.DDT_Data__c = formatToPlainString(relatedServiceAppointment.ActualStartTime);
                        }

                        if(relatedWorkOrder.StartDate != null) {
                            WAMDocumentEvent.S_Delivery_Date__c = formatToPlainString(relatedWorkOrder.StartDate);
                        }

                        if(latestVersion != null && latestVersion.Category__c != null) {
                            WAMDocumentEvent.Category__c = latestVersion.Category__c;
                        }
                        else {
                            WAMDocumentEvent.Category__c = '90';
                        }

                        serviceAppointmentWAMDocumentEvents.add(WAMDocumentEvent);
                        System.debug('EVENT: ' + WAMDocumentEvent);
                    }
                }
            }
        }

        return serviceAppointmentWAMDocumentEvents;
    }

    public static List<WAM_Document__e> createWorkOrderWAMDocumentEvents(List<ContentDocumentLink> workOrderCDLs, Map<String, ContentVersion> contentDocumentToLatestVersionMap) {
        System.debug('----- createWorkOrderWAMDocumentEvents -----');
        System.debug('workOrderCDLs: ' + workOrderCDLs);

        List<String> workOrderQueryFields = new List<String>{'Account.Name', 'Account.VAT_Number__c', 'Account.Account_External_Id__c', 'StartDate', 'Sales_Office__c', 
        'SAP_Storage_Location__r.Location_Id__c', 'CountryCode', 'Payer__r.Account_External_Id__c', 'Payer__r.Name', 'Resource__r.Name', 'Resource__r.BPResource__c', 
        'SalesOrganization__c', 'Account.Fiscal_Code__c'};

        List<Id> workOrderIds = new List<Id>();
        List<WorkOrder> workOrders = new List<WorkOrder>();
        List<WAM_Document__e> workOrderWAMDocumentEvents = new List<WAM_Document__e>();

        Map<Id, WorkOrder> workOrderMap = new Map<Id, WorkOrder>();

        for(ContentDocumentLink cdl : workOrderCDLs) {
            workOrderIds.add(cdl.LinkedEntityId);
            System.debug('cdl.LinkedEntityId: ' + cdl.LinkedEntityId);
        }

        workOrders = WorkOrderDAO.getWorkOrdersFromIds(workOrderQueryFields, workOrderIds);

        if(!workOrders.isEmpty()) {
            for(WorkOrder wo : workOrders) {
                workOrderMap.put(wo.Id, wo);
            }

            for(ContentDocumentLink cdl : workOrderCDLs) {
                WorkOrder relatedWorkOrder = workOrderMap.get(cdl.LinkedEntityId);
                ContentVersion latestVersion = contentDocumentToLatestVersionMap.get(cdl.ContentDocumentId);

                if(relatedWorkOrder != null) {
                    WAM_Document__e WAMDocumentEvent = new WAM_Document__e(
                        Salesforce_Document_Id__c = cdl.ContentDocumentId,
                        Related_Record_Id__c = cdl.LinkedEntityId,
                        Related_Record_Type__c = 'WorkOrder',
                        DDT_Numero__c = cdl.ContentDocument.Title,
                        Cliente_Ragione_Sociale__c = relatedWorkOrder.Account.Name,
                        Cliente_PIva__c = relatedWorkOrder.Account.VAT_Number__c,
                        S_Centro_di_Vendita__c = relatedWorkOrder.Sales_Office__c,
                        S_Centro_di_Spedizione__c = relatedWorkOrder.SAP_Storage_Location__r.Location_Id__c,
                        S_Codice_Destinatario_Merce__c = relatedWorkOrder.Account.Account_External_Id__c,
                        S_Ragione_Sociale_Destinatario_Merce__c = relatedWorkOrder.Account.Name,
                        S_Message_ID__c = cdl.ContentDocumentId,
                        S_Document_ID__c = cdl.ContentDocumentId,
                        S_Recipient_Entity_Id__c = relatedWorkOrder.Account.Account_External_Id__c,
                        S_Recipient_Code__c = relatedWorkOrder.Account.Account_External_Id__c,
                        S_Country__c = relatedWorkOrder.CountryCode,
                        S_Customer_Payer_Code__c = relatedWorkOrder.Payer__r.Account_External_Id__c,
                        S_Customer_Payer_Name__c = relatedWorkOrder.Payer__r.Name,
                        Cliente_CF__c = relatedWorkOrder.Account.Fiscal_Code__c,
                        S_Barcode39__c = '',
                        S_UfficioVendite__c = relatedWorkOrder.SalesOrganization__c,
                        S_NomeDriver__c = relatedWorkOrder.Resource__r.Name,
                        S_CodiceDriver__c = relatedWorkOrder.Resource__r.BPResource__c,
                        Tablet__c = '1',
                        S_Annullata__c = '0'
                    );

                    if(relatedWorkOrder.StartDate != null) {
                        WAMDocumentEvent.DDT_Data__c = formatToPlainString(relatedWorkOrder.StartDate);
                        WAMDocumentEvent.S_Delivery_Date__c = formatToPlainString(relatedWorkOrder.StartDate);
                    }

                    if(latestVersion != null && latestVersion.Category__c != null) {
                        WAMDocumentEvent.Category__c = latestVersion.Category__c;
                    }
                    else {
                        WAMDocumentEvent.Category__c = '90';
                    }

                    workOrderWAMDocumentEvents.add(WAMDocumentEvent);
                    System.debug('EVENT: ' + WAMDocumentEvent);
                }
            }
        }

        return workOrderWAMDocumentEvents;
    }

    public static List<WAM_Document__e> createWorkOrderLineItemWAMDocumentEvents(List<ContentDocumentLink> workOrderLineItemCDLs, Map<String, ContentVersion> contentDocumentToLatestVersionMap) {
        System.debug('----- createWOLIWAMDocumentEvents -----');

        List<String> WOLIQueryFields = new List<String>{'WorkOrder.Account.Name', 'WorkOrder.Account.VAT_Number__c', 'WorkOrder.Account.Account_External_Id__c',
        'WorkOrder.StartDate', 'WorkOrder.Sales_Office__c', 'WorkOrder.SAP_Storage_Location__r.Location_Id__c', 'WorkOrder.CountryCode', 
        'WorkOrder.Payer__r.Account_External_Id__c', 'WorkOrder.Payer__r.Name', 'WorkOrder.Account.Fiscal_Code__c', 'WorkOrder.Resource__r.Name',
        'WorkOrder.Resource__r.BPResource__c', 'WorkOrder.SalesOrganization__c'};

        List<Id> WOLIIds = new List<Id>();
        List<WorkOrderLineItem> WOLIs = new List<WorkOrderLineItem>();
        List<WAM_Document__e> workOrderLineItemWAMDocumentEvents = new List<WAM_Document__e>();

        Map<Id, WorkOrderLineItem> WOLIMap = new Map<Id, WorkOrderLineItem>();

        for(ContentDocumentLink cdl : workOrderLineItemCDLs) {
            WOLIIds.add(cdl.LinkedEntityId);
            System.debug('cdl.LinkedEntityId: ' + cdl.LinkedEntityId);
        }

        WOLIs = WorkOrderLineItemDAO.getWOLIsFromIds(WOLIQueryFields, WOLIIds);

        if(!WOLIs.isEmpty()) {
            for(WorkOrderLineItem woli : WOLIs) {
                WOLIMap.put(woli.Id, woli);
            }

            for(ContentDocumentLink cdl : workOrderLineItemCDLs) {
                WorkOrderLineItem relatedWOLI = WOLIMap.get(cdl.LinkedEntityId);
                ContentVersion latestVersion = contentDocumentToLatestVersionMap.get(cdl.ContentDocumentId);

                if(relatedWOLI != null) {
                    WAM_Document__e WAMDocumentEvent = new WAM_Document__e(
                        Salesforce_Document_Id__c = cdl.ContentDocumentId,
                        Related_Record_Id__c = cdl.LinkedEntityId,
                        Related_Record_Type__c = 'WorkOrderLineItem',
                        DDT_Numero__c = cdl.ContentDocument.Title,
                        Cliente_Ragione_Sociale__c = relatedWOLI.WorkOrder.Account.Name,
                        Cliente_PIva__c = relatedWOLI.WorkOrder.Account.VAT_Number__c,
                        S_Centro_di_Vendita__c = relatedWOLI.WorkOrder.Sales_Office__c,
                        S_Centro_di_Spedizione__c = relatedWOLI.WorkOrder.SAP_Storage_Location__r.Location_Id__c,
                        S_Codice_Destinatario_Merce__c = relatedWOLI.WorkOrder.Account.Account_External_Id__c,
                        S_Ragione_Sociale_Destinatario_Merce__c = relatedWOLI.WorkOrder.Account.Name,
                        S_Message_ID__c = cdl.ContentDocumentId,
                        S_Document_ID__c = cdl.ContentDocumentId,
                        S_Recipient_Entity_Id__c = relatedWOLI.WorkOrder.Account.Account_External_Id__c,
                        S_Recipient_Code__c = relatedWOLI.WorkOrder.Account.Account_External_Id__c,
                        S_Country__c = relatedWOLI.WorkOrder.CountryCode,
                        S_Customer_Payer_Code__c = relatedWOLI.WorkOrder.Payer__r.Account_External_Id__c,
                        S_Customer_Payer_Name__c = relatedWOLI.WorkOrder.Payer__r.Name,
                        Cliente_CF__c = relatedWOLI.WorkOrder.Account.Fiscal_Code__c,
                        S_Barcode39__c = '',
                        S_UfficioVendite__c = relatedWOLI.WorkOrder.SalesOrganization__c,
                        S_NomeDriver__c = relatedWOLI.WorkOrder.Resource__r.Name,
                        S_CodiceDriver__c = relatedWOLI.WorkOrder.Resource__r.BPResource__c,
                        Tablet__c = '1',
                        S_Annullata__c = '0'
                    );

                    if(relatedWOLI.WorkOrder.StartDate != null) {
                        WAMDocumentEvent.DDT_Data__c = formatToPlainString(relatedWOLI.WorkOrder.StartDate);
                        WAMDocumentEvent.S_Delivery_Date__c = formatToPlainString(relatedWOLI.WorkOrder.StartDate);
                    }

                    if(latestVersion != null && latestVersion.Category__c != null) {
                        WAMDocumentEvent.Category__c = latestVersion.Category__c;
                    }
                    else {
                        WAMDocumentEvent.Category__c = '90';
                    }

                    workOrderLineItemWAMDocumentEvents.add(WAMDocumentEvent);
                    System.debug('EVENT: ' + WAMDocumentEvent);
                }
            }
        }

        return workOrderLineItemWAMDocumentEvents;
    }

    public static String formatToPlainString(Datetime toFormat) {
        String toReturnNoDot;
        String toReturn;

        String year = toFormat.year().format();
        String month = toFormat.month().format();
        String day = toFormat.day().format();
        String hour = toFormat.hour().format();
        String minute = toFormat.minute().format();
        String second = toFormat.second().format();

        if(month.length() == 1) {
            month = '0' + month;
        }

        if(day.length() == 1) {
            day = '0' + day;
        }

        if(hour.length() == 1) {
            hour = '0' + hour;
        }

        if(minute.length() == 1) {
            minute = '0' + minute;
        }

        if(second.length() == 1) {
            second = '0' + second;
        }

        String tmp = year + month + day + hour + minute + second;
        toReturnNoDot = tmp.remove('.');
        toReturn = toReturnNoDot.remove(',');

        return toReturn;
    }

    public static String formatToPlainString(Date toFormat) {
        String toReturnNoDot;
        String toReturn;

        String year = toFormat.year().format();
        String month = toFormat.month().format();
        String day = toFormat.day().format();

        if(month.length() == 1) {
            month = '0' + month;
        }

        if(day.length() == 1) {
            day = '0' + day;
        }

        String tmp = year + month + day;
        toReturnNoDot = tmp.remove('.');
        toReturn = toReturnNoDot.remove(',');

        return toReturn;
    }
}