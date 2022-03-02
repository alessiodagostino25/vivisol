public class AccountSalesOrganizationDTO {

    public class AccountSO {
		public String salesOrganization;
		public String distributionChannel;  
		public String division;
		public String paymentTerms;
		public String responsible;
		public String pricelist;
		public String priceGroup;
		public String replacedCurrency;     //Identifier name is reserved
		public String customerGroup;
		public String salesDistrict;
		public String salesOffice;
		public String salesGroup;
		public String authorizationGroup;
		public String priceProcedure;
		public String customerStatistics;
		public String shippingCondition;
		public Boolean podRelevant;
		// public Boolean completeDeliveryRequired;
        public String invoicingDates;
        // public String incoterm;
		public String accountAssignementGroup;
		public String invoiceSplittingCriterion;
		public String hic;
        public String billingMethod;
        public String dunningVia;
        // public String SOCode;
	}

	public List<SalesOrganization> salesOrganizationList;

	public class AccPartnerFunction {
		public String partnerFunction;
		public String account;
	}

	public class AccountCompany {
		public String companyCode;
		public String duringProcedure;
		public String paymentTerms;
		public String paymentMethods;
		public String reconcilitianAccount;
		public String keyForSorting;
        public String uzoviCode;
        public String dunningBlock;
        public String headOffice;
	}

	public class SalesOrganization {
		public String correlationID;
		public String accountExternalID;
		public AccountSO accountSO;
		public List<TaxCat> taxCat;
		public List<AccPartnerFunction> accPartnerFunction;
		public AccountCompany accountCompany;
	}

	public class TaxCat {
		public String taxCategory;
		public String taxClassification;
	}

	
	public static AccountSalesOrganizationDTO parse(String json) {
        String jsonReplacedString = json.replace('"currency":', '"replacedCurrency":');
		return (AccountSalesOrganizationDTO) System.JSON.deserialize(jsonReplacedString, AccountSalesOrganizationDTO.class);
    }
    
    public AccountSalesOrganizationDTO(List<Account_Sales_Organization__c> asoList, List<Account_Company__c> companyList) {
        this.salesOrganizationList = new List<SalesOrganization>();
        System.debug('SalesOrg size on start: ' + this.salesOrganizationList.size());
        //Need all Account_Tax_Classification__c with a Lookup to each Account_Sales_Organization__c in asoList
        if(asoList != null && companyList == null) {
            List<Account_Tax_Classification__c> taxes = new List<Account_Tax_Classification__c>();
            List<Id> asoIds = new List<Id>();
            Map<Id, List<Account_Tax_Classification__c>> taxMap = new Map<Id, List<Account_Tax_Classification__c>>();

            //Need all Account_Partner_Function__c with a Lookup to each Account_Sales_Organization__c in asoList
            List<Account_Partner_Function__c> partnerFunctions = new List<Account_Partner_Function__c>();
            Map<Id, List<Account_Partner_Function__C>> partnerFunctionsMap = new Map<Id, List<Account_Partner_Function__c>>();

            for(Account_Sales_Organization__c aso : asoList) {
                asoIds.add(aso.Id);
            }
            taxes = [SELECT Id, Name, Tax_Category__c, Tax_Classification__c, Account_Sales_Organization__c 
                    FROM Account_Tax_Classification__c WHERE Account_Sales_Organization__c IN: asoIds];
            System.debug('RELATED TAXES: ' + taxes);

            partnerFunctions = [SELECT Id, Name, Account__c, Partner_Function__c, Account_Sales_Organization__c, Account__r.Account_External_Id__c 
                                FROM Account_Partner_Function__c WHERE Account_Sales_Organization__c IN: asoIds];
            System.debug('RELATED PARTFUNCTIONS: ' + partnerFunctions);
            
            //Associate a List of Taxes to each ASO Id. If a List is already associated, add that Tax to the related List
            if(!taxes.isEmpty()) {
                System.debug('Taxes is NOT empty');
                for(Account_Tax_Classification__c atc : taxes) {
                    if(taxMap.get(atc.Account_Sales_Organization__c) == null) {
                        taxMap.put(atc.Account_Sales_Organization__c, new List<Account_Tax_Classification__c>());
                    }
                    taxMap.get(atc.Account_Sales_Organization__c).add(atc);
                }
            }
            //Associate a List of partnerFunctions to each ASO Id. If a List is already associated, add that partnerFunction to the related List
            if(!partnerFunctions.isEmpty()) {
                System.debug('P.Functions is NOT empty');
                for(Account_Partner_Function__c apf : partnerFunctions) {
                    if(partnerFunctionsMap.get(apf.Account_Sales_Organization__c) == null) {
                        partnerFunctionsMap.put(apf.Account_Sales_Organization__c, new List<Account_Partner_Function__c>());
                    }
                    partnerFunctionsMap.get(apf.Account_Sales_Organization__c).add(apf);
                }
            }
            //Build each SalesOrganization
            for(Integer i = 0; i < asoList.size(); i++) {
                System.debug('asoList size: ' + asoList.size());
                Account_Sales_Organization__c aso = asoList[i];
                System.debug('ASO: ' + aso);
                SalesOrganization so = new SalesOrganization();
                AccountSO accountSO = new AccountSO();
                AccountCompany accCompany = new AccountCompany();
                List<Account_Tax_Classification__c> relatedTaxes = new List<Account_Tax_Classification__c>();
                List<Account_Partner_Function__c> relatedPartnerFunctions = new List<Account_Partner_Function__c>();
                List<TaxCat> taxCats = new List<TaxCat>();
                List<AccPartnerFunction> accPartnerFunctions = new List<AccPartnerFunction>();

                //CorrelationID and AccountExternalID for SalesOrganization

                so.accountExternalID = aso.Account__r.Account_External_Id__c; //Correct?
                so.correlationID = aso.Account__r.Account_External_Id__c + aso.Sales_Organization__r.Code__c;
                if(aso.Distribution_Channel__c != null) {
                    so.correlationID = so.correlationID + aso.Distribution_Channel__c;
                }
                if(aso.Division__c != null) {
                    so.correlationID = so.correlationID + aso.Division__c;
                }

                //AccountSO for SalesOrganization
                
                //accountSO.salesOrganization = aso.Sales_Organization__c;
                accountSO.salesOrganization = aso.Sales_Organization__r.Code__c;
                if(aso.Distribution_Channel__c != null) {
                    accountSO.distributionChannel = aso.Distribution_Channel__c;
                }
                accountSO.replacedCurrency = aso.Currency__c;
                System.debug('CURRENCY: ' + accountSO.replacedCurrency);
                accountSO.division = aso.Division__c;
                accountSO.paymentTerms = aso.Payment_Terms__c;
                accountSO.responsible = aso.Responsabile_Vivisol_Account_Manager__r.Account_External_Id__c;
                System.debug('RESPONSIBILE: ' + accountSO.responsible);
                accountSO.pricelist = aso.Pricelist__c;
                accountSO.priceGroup = aso.Price_Group__c;
                accountSO.customerGroup = aso.Customer_Group__c;
                accountSO.salesDistrict = aso.Sales_district__c;
                accountSO.salesOffice = aso.Sales_Office__c;
                accountSO.salesGroup = aso.Sales_Group__c;
                accountSO.authorizationGroup = aso.Authorization_group__c;
                accountSO.priceProcedure = aso.Price_Procedure_Dterm__c;
                accountSO.customerStatistics = aso.Customer_Statistics_Group__c;
                accountSO.shippingCondition = aso.Shipping_Conditions__c;
                accountSO.podRelevant = aso.POD_Relevant__c;
                accountSO.invoicingDates = aso.Invoicing_Dates__c;
                accountSO.accountAssignementGroup = aso.Account_Assignment_Group__c;
                accountSO.invoiceSplittingCriterion = aso.Invoice_grouping_Y_N__c;
                accountSO.dunningVia = aso.Dunning_Via__c;
                accountSO.billingMethod = aso.Billing_Method__c;

                so.accountSO = accountSO;
                
                //TaxCat for SalesOrganization

                //List of Related Taxes is empty if the Trigger is After insert. Same for ParterFunctions

                if(!taxMap.isEmpty()) {
                    System.debug('ASO ID::: ' + aso.Id);
                    if(taxMap.get(aso.Id) != null) {
                        relatedTaxes = taxMap.get(aso.Id);
                        for(Account_Tax_Classification__c atc : relatedTaxes) {
                            TaxCat tax = new TaxCat();
                            tax.taxCategory = atc.Tax_Category__c;
                            tax.taxClassification = atc.Tax_Classification__c;
                            taxCats.add(tax);
                        }

                        so.taxCat = taxCats;
                    }
                }

                //AccPartnerFunction for SalesOrganization

                if(!partnerFunctionsMap.isEmpty()) {
                    if(partnerFunctionsMap.get(aso.Id) != null) {
                        relatedPartnerFunctions = partnerFunctionsMap.get(aso.Id);
                        for(Account_Partner_Function__c apf : relatedPartnerFunctions) {
                            AccPartnerFunction partnerFunction = new AccPartnerFunction();
                            partnerFunction.account = apf.Partner_Function__c;
                            partnerFunction.partnerFunction = apf.Account__r.Account_External_Id__c;
                            accPartnerFunctions.add(partnerFunction);
                        }

                        so.accPartnerFunction = accPartnerFunctions;
                    }
                }

                this.salesOrganizationList.add(so);
            }
        }
        //OTHER PART: If called by the Service of the AccountCompany Trigger, companyList will be populated and asoList won't
        else if(asoList == null && companyList != null) {
            //AccountCompany for SalesOrganization
            for(Account_Company__C company : companyList) {
                SalesOrganization so = new SalesOrganization();
                so.accountExternalID = company.Account__r.Account_External_Id__c; //Correct?
                so.correlationID = company.Account__r.Account_External_Id__c + company.Company_Code__c;
                AccountCompany accCompany = new AccountCompany();
                accCompany.companyCode = company.Company_Code__c;
                accCompany.duringProcedure = company.Dunning_Procedure__c;
                accCompany.keyForSorting = company.Key_for_sorting_according_to_assignment__c;
                if(company.Payment_Method__c != null) {
                    accCompany.paymentMethods = (company.Payment_Method__c).remove(';');
                }
                accCompany.paymentTerms = company.Payment_Terms__c;
                accCompany.reconcilitianAccount = company.Reconciliation_Account__c;
                accCompany.headOffice = company.Head_Office__r.Account_External_Id__c;
                if(company.Dunning_Block__c != 'NotBlocked') {
                    accCompany.dunningBlock = company.Dunning_Block__c;
                }
                accCompany.uzoviCode = company.UzoviCode__c;  
                so.accountCompany = accCompany;
                this.salesOrganizationList.add(so);
            }
        }
    }
}