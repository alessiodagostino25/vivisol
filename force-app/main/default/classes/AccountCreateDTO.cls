public class AccountCreateDTO {
	public String externalId;
	public String entityType;
	public String name;
	public String name2;
	public String name3;
	public String name4;
	public String salutation;
	public String firstName;
	public String middleName;
	public String lastName;
	public String birthDate;
	public String deceasedDate;
	public String gender;
	public String birthCity;
	public String birthCountry;
	public String fiscalCode;
	public String vatNumber;
	public String socialSecurityNumber;
	public String homePhone;
	public String workPhone;
	public String phone;
	public String personMobilePhone;
	public String personEmail;
	public String emailB2B;
	public String dunningEmail;
	public String billingEmail;
	public String fax;
	public String shippingStreet;
	public String shippingTelephone;
	public String transportationZone;
	public String shippingPostalCode;
	public String shippingCity;
	public String shippingStateCode;
	public String shippingCountry;
	public String addressId;
	public String patientsInsuranceNumber;
	public String iban;
	public String bankAccountOwner;
	public String billingReference;
	public String customerPurchaseOrderNumber;
	public String customerPurchaseOrderDate;
	public String chamberOfCommerceNumber;
	public String language;
	public String regionalGrouping;
	public String description;
	//public String accountId;

	public static AccountCreateDTO parse(String json) {
		return (AccountCreateDTO) System.JSON.deserialize(json, AccountCreateDTO.class);
	}
	
	public static String stringifyDate(Date toStringify) {
		String stringDate;
		String day;
		String month;
		String year;

		// Day
		if((String.valueOf(toStringify.day())).length() == 1) {
			day = '0' + (String.valueOf(toStringify.day()));
		}
		else {
			day = (String.valueOf(toStringify.day()));
		}

		// Month
		if((String.valueOf(toStringify.month())).length() == 1) {
			month = '0' + (String.valueOf(toStringify.month()));
		}
		else {
			month = (String.valueOf(toStringify.month()));
		}

		// Year
		year = (String.valueOf(toStringify.year()));

		stringDate = day + '/' + month + '/' + year;

		return stringDate;
	}
    
    public AccountCreateDTO(Account acc, Schema.Location relatedLocation) {
		//this.accountId = acc.Id;
		//Setting different attributes basing on the recordType: PA or Business
		if(acc.IsPersonAccount == true) {
			this.firstName = acc.FirstName;
			this.middleName = acc.MiddleName; 
			this.lastName = acc.LastName;
			this.salutation = acc.Salutation;
		}
		if (acc.Account_External_Id__c != null){
			System.debug('Account_External_Id__c popolato');
			this.externalId = acc.Account_External_Id__c;
		} else {
			System.debug('Account_External_Id__c null');
			this.externalId = acc.AutoNumber__c;
		}
		this.entityType = acc.Entity_Type__c;
		if(acc.IsPersonAccount == false) {
			this.name = acc.Name;
			this.name2 = acc.Name_2__c;
			this.name3 = acc.Name_3__c;
			this.name4 = acc.Name_4__c;
		}
		if(acc.PersonBirthDate != null) {
			String stringBirthdate = stringifyDate(acc.PersonBirthdate);
			this.birthDate = stringBirthdate;  
		}

		if(acc.HealthCloudGA__DeceasedDate__pc != null){
			String stringDeceasedDate = stringifyDate(acc.HealthCloudGA__DeceasedDate__pc);
			this.deceasedDate = stringDeceasedDate;
		}

		System.debug('GENDER::::::: ' + acc.HealthCloudGA__Gender__pc);
		if(acc.HealthCloudGA__Gender__pc != 'N/A') {
			this.gender = acc.HealthCloudGA__Gender__pc;
			/*if(acc.HealthCloudGA__Gender__pc == 'M') {
				this.gender = '1';
			}
			else if(acc.HealthCloudGA__Gender__pc == 'F') {
				this.gender = '2';
			}*/
		}
		this.birthCity = acc.Birth_city__pc;
		this.birthCountry = acc.Birth_country__pc;
		this.fiscalCode = acc.Fiscal_Code__c;
		this.vatNumber = acc.VAT_Number__c;
		this.socialSecurityNumber = acc.Social_Security_Number__pc;
		this.homePhone = acc.PersonHomePhone; //Correct?
		this.workPhone = acc.Work_Phone__c;
		this.phone = acc.Phone;
		this.personMobilePhone = acc.PersonMobilePhone;
		this.personEmail = acc.PersonEmail;
		this.emailB2B = acc.Email_B2B__c;
		this.fax = acc.Fax;
		this.shippingStreet = acc.ShippingStreet;
		this.shippingPostalCode = acc.ShippingPostalCode;
		this.shippingCity = acc.ShippingCity;
		this.shippingStateCode = acc.ShippingStateCode;
		this.shippingCountry = acc.ShippingCountryCode;
		this.shippingTelephone = acc.Shipping_Telephone__c;
		if(acc.Address_ID__c != null) {
			System.debug('acc.Address_ID__c != null: ' + acc.Address_ID__c);
			this.addressId = acc.Address_ID__c;
		}
		else {
			System.debug('acc.Address_ID__c = null');
			if(relatedLocation != null) {
				System.debug('relatedLocation != null: ' + relatedLocation.Location_Id__c);
				this.addressId = relatedLocation.Location_Id__c;
			}
		}
		this.patientsInsuranceNumber = acc.Patients_insurance_number__pc;
		this.iban = acc.Iban__c;
		this.billingReference = acc.Billing_Reference__c;
		this.customerPurchaseOrderNumber = acc.Customer_Purchase_Order_Number__c;
		if(acc.Customer_Purchase_Order_Date__c != null) {
			String stringPurchaseOrderDate = stringifyDate(acc.Customer_Purchase_Order_Date__c);
			this.customerPurchaseOrderDate = stringPurchaseOrderDate;
		}
		this.chamberOfCommerceNumber = acc.Chamber_of_commerce_number__c;
		this.language = acc.Language__c; 
		System.debug('LANGUAGE: ' + language);
		this.description = acc.Description;
		this.transportationZone = acc.TransportationZone__c;
		this.dunningEmail = acc.Dunning_Email__c;
		this.billingEmail = acc.Billing_Email__c;
		this.bankAccountOwner = acc.Bank_Account_Owner__c;
		this.regionalGrouping = acc.Regional_Grouping__c;
    }
}