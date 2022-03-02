({
    getPrefilledQuote : function(cmp, event, helper) {
        //Preparing variables to be set in the Callback
        var AccountName;
        var Contact;
        var ContractTreatment;
        var Location;
        var PaymentTerms;
        var ShippingStreet;
        var ShippingPostalCode;
        var ShippingCity;
        var ShippingStateCode;
        var ShippingCountryCode;
        var CaseId;

        //This is the recordId of the Case of the page I'm on
        var recordId = cmp.get("v.recordId");

        //Calling getPrefilledQuote with parameter
        var action = cmp.get("c.getPrefilledQuote");
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
                if(returnValue.AccountName != null) {
                    AccountName = returnValue.AccountName;
                }
                else {
                    AccountName = null;
                }
                if(returnValue.Contact != null) {
                    Contact = returnValue.Contact;
                }
                else {
                    Contact = null;
                }
                if(returnValue.ContractTreatment != null) {
                    ContractTreatment = returnValue.ContractTreatment;
                }
                else {
                    ContractTreatment = null;
                }
                if(returnValue.Location != null) {
                    Location = returnValue.Location;
                }
                else {
                    Location = null;
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
                if(recordId != undefined) {
                    CaseId = recordId;
                }
                else {
                    CaseId = null;
                }
                
                var navService = cmp.find("navService");
                var pageRef = {
                type: "standard__objectPage",
                attributes: {
                    objectApiName: "Quote__c",
                    actionName: "new"
                },
                state: {
                }
                }
                var defaultFieldValues = {
                    Account_Name__c: AccountName,
                    Contact__c: Contact,
                    Contract_Treatment__c: ContractTreatment,
                    Location__c: Location,
                    Payment_Terms__c: PaymentTerms,
                    Street__c: ShippingStreet,
                    PostalCode__c: ShippingPostalCode,
                    City__c: ShippingCity,
                    StateCode__c: ShippingStateCode,
                    CountryCode__c: ShippingCountryCode,
                    Case__c: CaseId
                };

                //Set pre-filled values
                pageRef.state.defaultFieldValues = cmp.find("pageRefUtils").encodeDefaultFieldValues(defaultFieldValues);
                cmp.set("v.pageReference", pageRef);
                var defaultUrl = "#";
                navService.generateUrl(pageRef)
                .then($A.getCallback(function(url) {
                    cmp.set("v.url", url ? url : defaultUrl);
                }), $A.getCallback(function(error) {
                    cmp.set("v.url", defaultUrl);
                }));

                //Handle navigation to Quote__c creation page
                console.log('pageRef: ' + pageRef);
                event.preventDefault();
                navService.navigate(pageRef);
            }
        });
        //Send action to be executed
        $A.enqueueAction(action);
    }
})