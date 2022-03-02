({
    getPrefilledOrder : function(cmp, event, helper) {
        //Preparing variables to be set in the Callback
        var AccountId;
        var ShipToContactId;
        var AccountSoldTo;
        var ContractTreatment;
        var ShippingAddress;
        var BillingAddress;
        var CustomerRequestCode;
        var CustomerPON;
        var CustomerPOD;
        var PaymentTerms;
        var ShippingStreet;
        var ShippingPostalCode;
        var ShippingCity;
        var ShippingStateCode;
        var ShippingCountryCode;
        var BillingStreet;
        var BillingPostalCode;
        var BillingCity;
        var BillingStateCode;
        var BillingCountryCode;
        var CaseId;

        //This is the recordId of the Case of the page I'm on
        var recordId = cmp.get("v.recordId");
        console.log('RecordId: ' + recordId);

        //Calling getPrefilledOrder with parameter
        var action = cmp.get("c.getPrefilledOrder");
        if(recordId != undefined) {
            action.setParams({
                "caseId": recordId
            });
        }
        else {
            action.setParams({
                "caseId": null
            })
        }
        //If response comes, I set the variables to be used as defaultFieldValues
        action.setCallback(this, function (response) {
            var state = response.getState();
            if(cmp.isValid() && state === "SUCCESS") {
                var returnValue = response.getReturnValue();

                //Assigning returned DTO's attributes to variables
                if(returnValue.AccountId != null) {
                    AccountId = returnValue.AccountId;
                }
                else {
                    AccountId = null;
                }
                if(returnValue.ShipToContactId != null) {
                    ShipToContactId = returnValue.ShipToContactId;
                }
                else {
                    ShipToContactId = null;
                }
                if(returnValue.AccountSoldTo != null) {
                    AccountSoldTo = returnValue.AccountSoldTo;
                }
                else {
                    AccountSoldTo = null;
                }
                if(returnValue.ContractTreatment != null) {
                    ContractTreatment = returnValue.ContractTreatment;
                }
                else {
                    ContractTreatment = null;
                }
                if(returnValue.ShippingAddress != null) {
                    ShippingAddress = returnValue.ShippingAddress;
                }
                else {
                    ShippingAddress = null;
                }
                if(returnValue.BillingAddress != null) {
                    BillingAddress = returnValue.BillingAddress;
                }
                else {
                    BillingAddress = null;
                }
                if(returnValue.CustomerRequestCode != null) {
                    CustomerRequestCode = returnValue.CustomerRequestCode;
                }
                else {
                    CustomerRequestCode = null;
                }
                if(returnValue.CustomerPON != null) {
                    CustomerPON = returnValue.CustomerPON;
                }
                else {
                    CustomerPON = null;
                }
                if(returnValue.CustomerPOD != null) {
                    CustomerPOD = returnValue.CustomerPOD;
                }
                else {
                    CustomerPOD = null;
                }
                if(returnValue.PaymentTerms != null) {
                    PaymentTerms = returnValue.PaymentTerms;
                }
                else {
                    PaymentTerms = null;
                }
                if(returnValue.ShippingStreet != null) {
                    ShippingStreet = returnValue.ShippingStreet;
                }
                else {
                    ShippingStreet = null;
                }
                if(returnValue.ShippingPostalCode != null) {
                    ShippingPostalCode = returnValue.ShippingPostalCode;
                }
                else {
                    ShippingPostalCode = null;
                }
                if(returnValue.ShippingCity != null) {
                    ShippingCity = returnValue.ShippingCity;
                }
                else {
                    ShippingCity = null;
                }
                if(returnValue.ShippingStateCode != null) {
                    ShippingStateCode = returnValue.ShippingStateCode;
                }
                else {
                    ShippingStateCode = null;
                }
                if(returnValue.ShippingCountryCode != null) {
                    ShippingCountryCode = returnValue.ShippingCountryCode;
                }
                else {
                    ShippingCountryCode = null;
                }
                if(returnValue.BillingStreet != null) {
                    BillingStreet = returnValue.BillingStreet;
                }
                else {
                    BillingStreet = null;
                }
                if(returnValue.BillingPostalCode != null) {
                    BillingPostalCode = returnValue.BillingPostalCode;
                }
                else {
                    BillingPostalCode = null;
                }
                if(returnValue.BillingCity != null) {
                    BillingCity = returnValue.BillingCity;
                }
                else {
                    BillingCity = null;
                }
                if(returnValue.BillingStateCode != null) {
                    BillingStateCode = returnValue.BillingStateCode;
                }
                else {
                    BillingStateCode = null;
                }
                if(returnValue.BillingCountryCode != null) {
                    BillingCountryCode = returnValue.BillingCountryCode;
                }
                else {
                    BillingCountryCode = null;
                }
                if(recordId != undefined) {
                    CaseId = recordId;
                }
                else {
                    CaseId = null;
                }
                
                console.log('AccountId: ' + AccountId);
                console.log('ShiptToContactId: ' + ShipToContactId);
                console.log('ShippingAddress: ' + ShippingAddress);
                
                var navService = cmp.find("navService");
                var pageRef = {
                type: "standard__objectPage",
                attributes: {
                    objectApiName: "Order",
                    actionName: "new"
                },
                state: {
                }
                }
                var defaultFieldValues = {
                    AccountId: AccountId,
                    Shipping_Address__c: ShippingAddress,
                    ShippingStreet: ShippingStreet,
                    ShippingPostalCode: ShippingPostalCode,
                    ShippingCity: ShippingCity,
                    ShippingStateCode: ShippingStateCode,      
                    ShippingCountryCode: ShippingCountryCode, 
                    BillingStreet: BillingStreet,
                    BillingPostalCode: BillingPostalCode,
                    BillingCity: BillingCity,
                    BillingStateCode: BillingStateCode,
                    BillingCountryCode: BillingCountryCode,
                    ShipToContactId: ShipToContactId,
                    Account_Sold_To__c: AccountSoldTo,
                    Contract_Treatment__c: ContractTreatment,
                    Billing_Address__c: BillingAddress,
                    Customer_Request_Code__c: CustomerRequestCode,
                    Customer_Purchase_Order_Number__c: CustomerPON,
                    Customer_Purchase_Order_Date__c: CustomerPOD,
                    Payment_Terms__c: PaymentTerms,
                    Case__c: CaseId
                    
                };

                //Set pre-filled values
                pageRef.state.defaultFieldValues = cmp.find("pageRefUtils").encodeDefaultFieldValues(defaultFieldValues);
                cmp.set("v.pageReference", pageRef);
                var defaultUrl = "#";
                navService.generateUrl(pageRef)
                .then($A.getCallback(function(url) {
                    console.log('URL: ' + url);
                    cmp.set("v.url", url ? url : defaultUrl);
                }), $A.getCallback(function(error) {
                    cmp.set("v.url", defaultUrl);
                }));

                //Handle navigation to Order creation page
                console.log('pageRef: ' + pageRef);
                event.preventDefault();
                navService.navigate(pageRef);
            }
        });
        //Send action to be executed
        $A.enqueueAction(action);
    }
})