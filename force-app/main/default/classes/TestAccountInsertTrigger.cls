@isTest
private class TestAccountInsertTrigger {
	@isTest
	static void testAccountInsert() {
		Account a = new Account(
			Name = 'TestAccount',
			Shipping_Address_Type__c = 'XXDEFAULT',
			ShippingCity = 'Milan',
			ShippingStreet = 'TestStreet',
			ShippingStateCode = 'PV',
			ShippingCountryCode = 'IT',
			ShippingPostalCode = '27029'
		);
		Test.startTest();
		insert a;
		Test.stopTest();
		List<Account> accounts = [
			SELECT
				Id,
				Name,
				Shipping_Address_Type__c,
				ShippingCity,
				ShippingStreet,
				ShippingStateCode,
				ShippingCountryCode,
				ShippingPostalCode,
				AutoNumber__c,
				Account_External_Id__c
			FROM Account
		];
		List<Schema.Location> locations = [
			SELECT
				Id,
				Name,
				Account__c,
				IsInventoryLocation,
				LocationType,
				VisitorAddressId,
				LocationNumber__c,
				Location_Id__c
			FROM Location
		];
		List<Schema.Address> addresses = [
			SELECT
				Id,
				AddressType,
				LocationType,
				ParentId,
				City,
				Street,
				StateCode,
				CountryCode,
				PostalCode
			FROM Address
		];
		System.assert(!accounts.isEmpty(), 'no accounts found!');
		System.assert(!locations.isEmpty(), 'no location found');
		System.assert(!addresses.isEmpty(), 'no location found');
		System.assertEquals(accounts[0].AutoNumber__c,accounts[0].Account_External_Id__c, 'Account autonumber is different from the external id');
		System.assertEquals(accounts[0].Id, locations[0].Account__c, 'location is not correctly linked to the account');
		System.assertEquals(true, locations[0].IsInventoryLocation, 'The location is not an inventory location');
		System.assertEquals('Site', locations[0].LocationType, 'The location is not Site location');
		System.assertEquals(addresses[0].Id, locations[0].VisitorAddressId, 'visitor address is not correctly filled');
		//System.assertEquals(locations[0].LocationNumber__c,locations[0].Location_Id__c);
		System.assertEquals(accounts[0].Shipping_Address_Type__c,addresses[0].AddressType, 'Shipping_Address_Type__c has not correctly been replicated on address');
		System.assertEquals('Site', addresses[0].LocationType, 'The address is not Site location');
		System.assertEquals(locations[0].Id, addresses[0].ParentId, 'The location is not correctly linked to the address');
		System.assertEquals(accounts[0].ShippingCity, addresses[0].City, 'Account city is different from address city');
		System.assertEquals(accounts[0].ShippingStreet, addresses[0].Street, 'Account street is different from address street');
		System.assertEquals(accounts[0].ShippingStateCode,addresses[0].StateCode, 'Account state code is different from address state code');
		System.assertEquals(accounts[0].ShippingCountryCode,addresses[0].CountryCode, 'Account country code is different from address country code');
		System.assertEquals(accounts[0].ShippingPostalCode,addresses[0].PostalCode, 'Account postal code is different from address postal code');
	}

	@isTest
	static void updateOperatingHoursAndAddressTest() {
		OperatingHours operatingHours = TestDataFactory.createOperatingHours();
		insert operatingHours;

		OperatingHours operatingHours2 = TestDataFactory.createOperatingHours();
		insert operatingHours2;

		String correlationId = 'externalId';

		Schema.Location location = TestDataFactory.createLocation();
		insert location;

		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, true, correlationId));

		Account a = TestDataFactory.createPersonAccount();
		a.Shipping_Address_Type__c = 'XXDEFAULT';
		a.Account_External_Id__c = 'externalId';
		a.OperatingHoursId = operatingHours.Id;
		a.Location__c = location.Id;
		a.ShippingCountryCode = 'IT';
		a.ShippingStateCode = null;
		a.ShippingStreet = 'via Vigevano';
		a.ShippingCity = 'Vigevano';
		a.ShippingCountry = 'Italy';
		a.ShippingPostalCode = '27029';
		insert a;

		location.Account__c = a.Id;
		update location;

		Schema.Address address = TestDataFactory.createDefaultAddress(a, location);
		insert address;

		a.OperatingHoursId = operatingHours2.Id;
		a.ShippingCity = 'Shipping City 2';
		a.ShippingPostalCode = '27029';
		a.ShippingCountryCode = 'IT';
		a.ShippingStateCode = 'PV';
		a.ShippingStreet = 'Shipping Street 2';

		Test.startTest();

		Database.SaveResult result = Database.update(a);

		Test.stopTest();

		System.assert(result.isSuccess());
	}

	@isTest
	static void updateCalloutSuccessTest() {
		String correlationId = 'externalId';

		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, true, correlationId));

		Account a = TestDataFactory.createPersonAccount();
		a.Account_External_Id__c = 'externalId';
		a.IsCreatedSAP__c = true;
		insert a;

		//Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(202, false, correlationId));

		a.Description = 'Test Description';

		Test.startTest();

		Database.SaveResult result = Database.update(a);

		Test.stopTest();

		List<Account> accounts = [SELECT IsCreatedSAP__c, IsSyncSAP__c FROM Account];
		Account queriedAccount = accounts[0];

		System.assert(result.isSuccess());
		System.assertEquals(true, queriedAccount.IsCreatedSAP__c);
		System.assertEquals('Sync', queriedAccount.IsSyncSAP__c);
	}

	@isTest
	static void updateCalloutFailTest() {
		String correlationId = 'externalId';

		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(202, false, correlationId));

		Account a = TestDataFactory.createPersonAccount();
		a.Account_External_Id__c = 'externalId';
		a.IsCreatedSAP__c = true;
		insert a;

		//Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(202, false, correlationId));

		a.Description = 'Test Description';

		Test.startTest();

		Database.SaveResult result = Database.update(a);

		Test.stopTest();

		List<Account> accounts = [SELECT IsCreatedSAP__c, IsSyncSAP__c FROM Account];
		Account queriedAccount = accounts[0];

		System.assert(result.isSuccess());
		System.assertEquals(true, queriedAccount.IsCreatedSAP__c);
		System.assertEquals('NotSync', queriedAccount.IsSyncSAP__c);
	}

	@isTest
	static void updateForCreationCalloutFailTest() {
		String correlationId = 'externalId';

		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(202, false, correlationId));

		Account a = TestDataFactory.createPersonAccount();
		a.Account_External_Id__c = 'externalId';
		a.IsCreatedSAP__c = false;
		insert a;

		//Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(202, false, correlationId));

		a.Description = 'Test Description';

		Test.startTest();

		Database.SaveResult result = Database.update(a);

		Test.stopTest();

		List<Account> accounts = [SELECT IsCreatedSAP__c, IsSyncSAP__c FROM Account];
		Account queriedAccount = accounts[0];

		System.assert(result.isSuccess());
		System.assertEquals(false, queriedAccount.IsCreatedSAP__c);
	}

	@isTest
	static void companySalesDataCreationTest() {
		String correlationId = 'externalId';

		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, true, correlationId));

		Sales_Organization__c salesOrg = TestDataFactory.createSalesOrganization();
		salesOrg.Code__c = '6300';
		insert salesOrg;

		Account_Sales_Organization__c aso = new Account_Sales_Organization__c(
			Sales_Organization__c = salesOrg.Id,
			AccountRecordType__c = 'Account_Patient',
			EntityType__c = 'ZPATIE'
		);
		insert aso;

		Account_Tax_Classification__c atc = TestDataFactory.createAccountTaxClassification(aso);
		insert atc;

		Account_Company__c accountCompany = TestDataFactory.createAccountCompany();
		accountCompany.Company_Code__c = '6300';
		accountCompany.Account__c = null;
		accountCompany.AccountRecordType__c = 'Account_Patient';
		accountCompany.EntityType__c = 'ZPATIE';
		insert accountCompany;

		Account a = TestDataFactory.createPersonAccount();
		a.AutoCreateCompanyData__c = '6300';
		a.AutoCreateSalesData__c = '6300';

		Test.startTest();

		Database.SaveResult result = Database.insert(a);

		Test.stopTest();

		/* List<Account_Sales_Organization__c> queriedASOs = [SELECT Id, Sales_Organization__r.Code__c FROM Account_Sales_Organization__c WHERE Account__c =: a.Id];
		List<Account_Tax_Classification__c> queriedATCs = [SELECT Id, Account_Sales_Organization__c FROM Account_Tax_Classification__c WHERE Account_Sales_Organization__c =: aso.Id];
		List<Account_Company__c> queriedACs = [SELECT Id, Company_Code__c FROM Account_Company__c WHERE Account__c =: a.Id]; */

		System.assert(result.isSuccess());
		/* System.assertEquals(1, queriedASOs.size());
		System.assertEquals(1, queriedATCs.size());
		System.assertEquals(1, queriedACs.size());
		System.assertEquals(accountCompany.Company_Code__c, queriedACs[0].Company_Code__c);
		System.assertEquals(salesOrg.Code__c, queriedASOs[0].Sales_Organization__r.Code__c); */
	}

	public class MockHttpResponseGenerator implements HttpCalloutMock {
       
        Integer responseStatusCode;
        Boolean success;
        String correlationId;

        public  MockHttpResponseGenerator(Integer status, Boolean success, String correlationId){
            responseStatusCode = status;
            this.success = success;
            this.correlationId = correlationId;
        }
     
        public HTTPResponse respond(HTTPRequest req) {
            Integer statusCode = 200;
            if(req.getEndpoint() != 'callout:MC_Login') {
                statusCode = responseStatusCode;
            } 
            // Create a response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');

            if(success == false) {
                res.setBody('{"resultList": [{"success": false,"correlationID": "' + correlationId + '","log_event": {"warningList": [{"uuid_Flow": "afbb1641-abb0-4994-a4d3-8f0a89be14a6","recordId": "abc1234","errorType": "Error","error_Description": "Counter reading smaller than in previous document 66","operationType": "BAPI","operation_Name": "ZFM_IF018_MEASUREMENT_CREATE","originSystem": "Salesforce","objectName": null,"service": "equipment-measurement-sfdc-sap-test","status": "fail","targetSystem": "SAP"}],"errorList": [{"uuid_Flow": "afbb1641-abb0-4994-a4d3-8f0a89be14a6","recordId": "abc1234","errorType": "Error","error_Description": "Counter reading smaller than in previous document 66","operationType": "BAPI","operation_Name": "ZFM_IF018_MEASUREMENT_CREATE","originSystem": "Salesforce","objectName": null,"service": "equipment-measurement-sfdc-sap-test","status": "fail","targetSystem": "SAP"}]}}]}');
            }
            else {
                res.setBody('{"resultList": [{"success": true,"correlationID": "' + correlationId + '","log_event": {"warningList": [],"errorList": []}}]}');
            }
            res.setStatusCode(statusCode);
            res.setStatus('Complete');
            return res;
        }

    }

}