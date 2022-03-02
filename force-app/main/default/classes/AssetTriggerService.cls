public class AssetTriggerService{
	public static void assetTriggerServicemethod(List<String> assetIds){

		List<String> assetQueryFields = new List<String>{'TemporaryLabel__c', 
		'Account_Treatment__r.Contract_Treatment__r.Contract_Framework__r.Branch_of_belonging_sales_office__c', 'Account_Treatment__c', 
		'Account_Treatment__r.Contract_Treatment__r.Contract_Framework__r.Attachment_Addendum_Type__c', 
		'Account_Treatment__r.Contract_Treatment__r.Contract_Framework__r.Billing_Via__c', 'Account_Treatment__r.Contract_Treatment__r.Contract_Framework__c', 
		'Account_Treatment__r.Contract_Treatment__c', 'Account_Treatment__r.Contract_Treatment__r.Contract_Framework__r.Customer__r.Customer_Purchase_Order_Date__c', 
		'Account_Treatment__r.Contract_Treatment__r.Contract_Framework__r.Customer__r.Customer_Purchase_Order_Number__c', 
		'Account_Treatment__r.Contract_Treatment__r.Contract_Framework__r.Customer_Purchase_Order_Number__c', 
		'Account_Treatment__r.Contract_Treatment__r.Contract_Framework__r.Customer_Purchase_Order_Date__c', 
		'Account_Treatment__r.Contract_Treatment__r.Contract_Framework__r.Customer__r.Billing_reference__c', 
		'Account_Treatment__r.Contract_Treatment__r.Contract_Framework__r.Branch_of_belonging_sales_office__r.Division__c', 
		'Account_Treatment__r.Contract_Treatment__r.Contract_Framework__r.Branch_of_belonging_sales_office__r.Distribution_Channel__c', 
		'Account_Treatment__r.Contract_Treatment__r.Contract_Framework__r.Invoice_splitting_criterion__c', 
		'Account_Treatment__r.Contract_Treatment__r.Contract_Framework__r.Invoice_Layout__c', 
		'Account_Treatment__r.Contract_Treatment__r.Contract_Framework__r.Payment_Condition__c', 
		'Account_Treatment__r.Contract_Treatment__r.Contract_Framework__r.PaymentMethod__c', 
		'Account_Treatment__r.Contract_Treatment__r.Contract_Framework__r.Branch_of_belonging_sales_office__r.Sales_Group__c', 
		'Account_Treatment__r.Contract_Treatment__r.Contract_Framework__r.Branch_of_belonging_sales_office__r.Sales_Office__c', 
		'Account_Treatment__r.Contract_Treatment__r.Contract_Framework__r.Branch_of_belonging_sales_office__r.Sales_Organization__r.Code__c', 'Plant__c', 
		'StorageLocation__c', 'Equipment_Key__c', 'Account_Treatment__r.Contract_Treatment__r.Invoice_Splitting_group__c', 
		'Account_Treatment__r.Contract_Treatment__r.Customer_Purchase_Order_Date__c', 'Account_Treatment__r.Contract_Treatment__r.Customer_Purchase_Order_Number__c', 
		'Account_Treatment__r.Contract_Treatment__r.Customer_Request_Code__c', 'Product2Id', 'SerialNumber', 'Product2.Unit_of_measure__c', 'AssetServicedById', 
		'LocationId'};

		List<Asset> changedAssets = new List<Asset>();
		List<Asset> assetsToUpdate = new List<Asset>();
		List<String> temporaryLabels = new List<String>();
		List<Id> woIds = new List<Id>();
		List<Id> Pricebookids = new List<Id>();
		List<Id> productsids = new List<Id>();
		Map<String, Asset> labelAndAsset = new Map<String, Asset>();
		List<Product_Asset_Patient_History__c> insertpaph = new List<Product_Asset_Patient_History__c>();
		List<ProductTransfer> insertProductTransfer = new List<ProductTransfer>();
		List<DocumentType__mdt> code = [SELECT Code__c
		                                FROM DocumentType__mdt
										WHERE DeveloperName = 'Return'];
		
		changedAssets = AssetDAO.getAssetsFromIds(assetQueryFields, assetIds);

		for (Asset a : changedAssets){
			temporaryLabels.add(a.TemporaryLabel__c);
			labelAndAsset.put(a.TemporaryLabel__c, a);
		}

		List<Id> ParentWorkOrderIds = new List<Id>();
		List<String> queryfieldsforsourceproducts = new List<String>{'Serialized_Item__c'};
		List<ProductItem> sourceProducts = ProductItemDAO.getProductItemsFromSerializedItem(queryfieldsforsourceproducts, assetIds);
		Map<Id, Id> assetIdAndSourceProduct = new Map<Id, Id>();
		for (ProductItem pI : sourceProducts){
			assetIdAndSourceProduct.put(pI.Serialized_Item__c, pI.Id);
		}
		List<WorkOrder> insertWorkOrder = new List<WorkOrder>();

		List<String> queryFields = new List<String>{'WorkOrder.AccountId', 'WorkOrder.Account_BillTo__c', 'WorkOrder.Attachment_Addendum_Type__c', 
		'WorkOrder.Billing_Via__c', 'WorkOrder.Billable__c', 'WorkOrder.CaseId', 'WorkOrder.Delivery_Type__c', 'WorkOrder.Description', 'WorkOrder.Discount__c', 
		'WorkOrder.EndDate', 'WorkOrder.LocationId', 'WorkOrder.Note__c', 'WorkOrder.Id', 'WorkOrder.Pricebook2Id', 'WorkOrder.Reason__c', 'WorkOrder.Resource__c', 
		'WorkOrder.SAP_Plant__c', 'WorkOrder.SAP_Storage_Location__c', 'WorkOrder.SAScheduledStart__c', 'WorkOrder.ServiceTerritoryId', 'WorkOrder.Source_Location__c', 
		'WorkOrder.StartDate', 'Serial_Number__c', 'WorkOrder.Payer__c', 'WorkOrder.Account_Sold_To__c', 'WorkOrder.Account_Sales_Organization__c', 'WorkOrder.Account_Treatment__c',
		'WorkOrder.Contract_Framework__c', 'WorkOrder.Contract_Treatment__c', 'WorkOrder.Customer_Purchase_Order_Date__c', 'WorkOrder.Customer_Purchase_Order_Number__c',
		'WorkOrder.Billing_reference__c', 'WorkOrder.Division__c', 'WorkOrder.Distribution_Channel__c', 'WorkOrder.Invoice_splitting_criterion__c', 'WorkOrder.InvoiceLayout__c',
		'WorkOrder.PaymentCondition__c', 'WorkOrder.PaymentMethod__c', 'WorkOrder.Sales_Group__c', 'WorkOrder.Sales_Office__c', 'WorkOrder.SalesOrganization__c',
		'WorkOrder.Treatment_InvoiceSplittingGroup__c', 'WorkOrder.Treatment_Customer_Purchase_Order_Date__c', 'WorkOrder.Treatment_Customer_Purchase_Order_Number__c',
		'WorkOrder.Treatment_Customer_Request_Code__c', 'WorkOrder.Treatment_Product_Code__c'};

		List<WorkOrderLineItem> wolis = WorkOrderLineItemDAO.getWOLIsFromLabels(queryFields, temporaryLabels);
		System.debug('Temporary labels: ' + temporaryLabels);
		System.debug('wolis: ' + wolis);
		for (WorkOrderLineItem workorderlineitem : wolis){

			WorkOrderLineItem woli = workorderlineitem;
			Asset a = labelAndAsset.get(woli.Serial_Number__c);

			// creation of workorder
			WorkOrder wo = new WorkOrder();
			wo.AccountId = woli.WorkOrder.AccountId;
			wo.Account_BillTo__c = woli.WorkOrder.Account_BillTo__c;
			wo.Payer__c = woli.WorkOrder.Payer__c;
			wo.Account_Sold_To__c = woli.WorkOrder.Account_Sold_To__c;
			wo.Account_Sales_Organization__c =  woli.WorkOrder.Account_Sales_Organization__c;
			wo.Account_Treatment__c = woli.WorkOrder.Account_Treatment__c;
			wo.Attachment_Addendum_Type__c = woli.WorkOrder.Attachment_Addendum_Type__c;
			wo.Billing_Via__c = woli.WorkOrder.Billing_Via__c;
			wo.CaseId = woli.WorkOrder.CaseId;
			wo.Contract_Framework__c = woli.WorkOrder.Contract_Framework__c;
			wo.Contract_Treatment__c = woli.WorkOrder.Contract_Treatment__c;
			wo.Customer_Purchase_Order_Date__c = woli.WorkOrder.Customer_Purchase_Order_Date__c;
			wo.Customer_Purchase_Order_Number__c = woli.WorkOrder.Customer_Purchase_Order_Number__c;
			wo.Billing_reference__c = woli.WorkOrder.Billing_reference__c;
			wo.Delivery_Type__c = woli.WorkOrder.Delivery_Type__c;
			wo.Description = woli.WorkOrder.Description;
			wo.Discount__c = woli.WorkOrder.Discount__c;
			wo.Division__c = woli.WorkOrder.Division__c;
			wo.Distribution_Channel__c = woli.WorkOrder.Distribution_Channel__c;
			wo.Document_Type__c = code[0].Code__c;
			wo.EndDate = woli.WorkOrder.EndDate;
			wo.Invoice_splitting_criterion__c = woli.WorkOrder.Invoice_splitting_criterion__c;
			wo.InvoiceLayout__c = woli.WorkOrder.InvoiceLayout__c;
			wo.LocationId = woli.WorkOrder.LocationId;
			wo.Note__c = woli.WorkOrder.Note__c;
		    wo.OrderReason__c = 'Z01';
			wo.ParentWorkOrderId = woli.WorkOrder.Id;
			wo.PaymentCondition__c = woli.WorkOrder.PaymentCondition__c;
			wo.PaymentMethod__c = woli.WorkOrder.PaymentMethod__c;
			wo.Pricebook2Id = woli.WorkOrder.Pricebook2Id;
			wo.Reason__c = woli.WorkOrder.Reason__c;
			wo.Sales_Group__c = woli.WorkOrder.Sales_Group__c;
			wo.Sales_Office__c = woli.WorkOrder.Sales_Office__c;
			wo.SalesOrganization__c = woli.WorkOrder.SalesOrganization__c;
			wo.SAP_Plant__c = a.Plant__c ;
			wo.SAP_Storage_Location__c = a.StorageLocation__c;
			wo.SAScheduledStart__c = woli.WorkOrder.SAScheduledStart__c;
			wo.ServiceTerritoryId = woli.WorkOrder.ServiceTerritoryId;
			//wo.Source_Location__c = woli.WorkOrder.Source_Location__c;
			wo.StartDate = woli.WorkOrder.StartDate;
			wo.Status = 'Completed';
			
			wo.Subject = 'RETURN Order - Equipment ' + a.Equipment_Key__c;
			wo.Treatment_InvoiceSplittingGroup__c = woli.WorkOrder.Treatment_InvoiceSplittingGroup__c;
			wo.Treatment_Customer_Purchase_Order_Date__c = woli.WorkOrder.Treatment_Customer_Purchase_Order_Date__c;
			wo.Treatment_Customer_Purchase_Order_Number__c = woli.WorkOrder.Treatment_Customer_Purchase_Order_Number__c;
			wo.Treatment_Customer_Request_Code__c =  woli.WorkOrder.Treatment_Customer_Request_Code__c;
			wo.Treatment_Product_Code__c =  woli.WorkOrder.Treatment_Product_Code__c;
			insertWorkOrder.add(wo);
			ParentWorkOrderIds.add(woli.WorkOrder.Id);
			Pricebookids.add(woli.WorkOrder.Pricebook2Id);
			productsids.add(a.Product2Id);


			if(a.Account_Treatment__c != null) {
				//creation of Product_Asset_Patient_History__c

				Product_Asset_Patient_History__c paph = new Product_Asset_Patient_History__c();
				paph.Account_Treatment__c = a.Account_Treatment__c;
				if (woli.WorkOrder.EndDate != null){
					DateTime dT = woli.WorkOrder.EndDate;
					paph.Date__c = date.newinstance(dT.year(), dT.month(), dT.day());
				}
				paph.Product__c = a.Product2Id;
				paph.Quantity__c = 1;
				paph.Serialized_Item__c = a.Id;
				paph.SerialNumber__c = a.SerialNumber;
				paph.Type__c = 'Removal';
				paph.Location__c = woli.WorkOrder.LocationId;
				paph.Account__c = woli.WorkOrder.AccountId;
				insertpaph.add(paph);
			}


			//creation of ProductTransfer


			ProductTransfer pt = new ProductTransfer();
			if (woli.WorkOrder.EndDate != null){
				DateTime dtime = woli.WorkOrder.EndDate;
				pt.Date__c = date.newinstance(dtime.year(), dtime.month(), dtime.day());
			}
			pt.DestinationLocationId = a.StorageLocation__c;
			pt.Label__c = a.SerialNumber;
			pt.Product2Id = a.Product2Id;
			pt.QuantityReceived = 1;
			pt.QuantitySent = 1;
			pt.IsReceived = true;
			pt.Serialized_Item__c = a.Id;
			pt.SourceLocationId = woli.WorkOrder.LocationId;
			pt.SourceProductItemId = assetIdAndSourceProduct.get(a.Id);
			pt.Status = 'Completed';
			pt.QuantityUnitOfMeasure = a.Product2.Unit_of_measure__c;
			pt.Return__c = true;
			insertProductTransfer.add(pt);

		}

		if (!insertWorkOrder.isEmpty()){
			System.debug('New WO size: ' + insertWorkOrder.size());
			List<Database.SaveResult> insertwo = Database.insert(insertWorkOrder);
			System.debug('New WOs: ' + insertWorkOrder);
			for (Database.SaveResult wo : insertwo){
				woIds.add(wo.getId());
			}
		}
		if (!insertpaph.isEmpty()){
			System.debug('insertpaph size: ' + insertpaph.size());
			System.debug('insertpaph: ' + insertpaph);

			insert insertpaph;
		}

		SingletonClass.setFlag();
		
		if (!insertProductTransfer.isEmpty()){
			insert insertProductTransfer;
		}


		List<String> queryfieldsforwo = new List<String>{'Id', 'ParentWorkOrderId'};
		List<WorkOrder> workordercreated = WorkOrderDAO.getWorkOrdersFromparentid(queryfieldsforwo, ParentWorkOrderIds);
		Map<Id, Id> parentwoIdandwoId = new Map<Id, Id>();
		for (WorkOrder wo : workordercreated){
			parentwoIdandwoId.put(wo.ParentWorkOrderId, wo.Id);
		}
		List<String> queryfieldsforppe = new List<String>{'Id', 'Product2Id'};
		List<PricebookEntry> products = PricebookEntryDAO.getPEFromPricebookIdsandproductid(queryfieldsforppe, Pricebookids, productsids);
		Map<Id, Id> productIdandpbeId = new Map<Id, Id>();
		for (PricebookEntry product : products){
			productIdandpbeId.put(product.Product2Id, product.Id);
		}
		List<WorkOrderLineItem> insertwoli = new List<WorkOrderLineItem>();
		for (Integer i = 0; i < wolis.size(); i++){
			WorkOrderLineItem woli = wolis[i];
			Asset a = labelAndAsset.get(woli.Serial_Number__c);

			//creation of workorderlineitem
			System.debug('entered creation of woli ');
			
			WorkOrderLineItem nwoli = new WorkOrderLineItem();
			nwoli.InvoiceSplittingGroup__c = null;
			nwoli.Movement_Type__c = 'Removal (-)';
			nwoli.Plant__c = null ;
			nwoli.PricebookEntryId = productIdandpbeId.get(a.Product2Id);
			nwoli.Quantity = 1;
			nwoli.QuantityDelivered__c = 1;
			nwoli.Serial_Number__c = a.SerialNumber;
			nwoli.AssetId = a.Id;
			nwoli.Status = 'Completed';
			nwoli.WorkOrderId = woIds[i];
			nwoli.StorageLocation__c = null;
			insertwoli.add(nwoli);


		}
		if(!insertwoli.isEmpty()){
			insert insertwoli;
		}

		for(Asset asset : changedAssets) {
			Asset tmp = new Asset();
			tmp.Id = asset.Id;

			tmp.Account_Treatment__c = null;
			tmp.AssetServicedById = null;
			tmp.LocationId = asset.StorageLocation__c;

			assetsToUpdate.add(tmp);
		}

		if(!assetsToUpdate.isEmpty()) {
			List<Database.SaveResult> results = Database.update(assetsToUpdate);
		}
	}

	public static void setIsPortalSync(List<Asset> assets, Map<Id, Asset> oldMap, Boolean performDML) {
		SObjectServiceClass.setIsPortalSync(assets, oldMap, 'Asset', false, performDML);
	}

	public static void setAccountTreatmentNumber(List<Asset> assets) {
		List<String> accountTreatmentQueryFields = new List<String>{'Account_Treatment_Number__c'};

		List<String> accountTreatmentIds = new List<String>();
		List<Account_Treatment__c> relatedAccountTreatments = new List<Account_Treatment__c>();

		Map<String, Account_Treatment__c> accountTreatmentMap = new Map<String, Account_Treatment__c>();

		for(Asset a : assets) {
			if(a.Account_Treatment__c != null) {
				accountTreatmentIds.add(a.Account_Treatment__c);
			}
		}

		if(!accountTreatmentIds.isEmpty()) {
			relatedAccountTreatments = AccountTreatmentDAO.getAccountTreatmentsFromIds(accountTreatmentQueryFields, accountTreatmentIds);

			for(Account_Treatment__c at : relatedAccountTreatments) {
				accountTreatmentMap.put(at.Id, at);
			}
		}

		for(Asset a : assets) {
			Account_Treatment__c relatedAccountTreatment = accountTreatmentMap.get(a.Account_Treatment__c);

			if(relatedAccountTreatment == null) {
				a.Account_Treatment_Number__c = null;
			}
			else {
				a.Account_Treatment_Number__c = relatedAccountTreatment.Account_Treatment_Number__c;
			}
		}
	}
}