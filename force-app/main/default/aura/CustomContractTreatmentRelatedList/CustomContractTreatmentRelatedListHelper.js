({
    handleClickHelper: function (cmp, event, helper) {
        var pageReference = cmp.get("v.pageReference");
        var accountRecordId = cmp.get("v.recordId");
        console.log('recordid in aura' + accountRecordId);

        pageReference.state = { "c__accountRecordId": accountRecordId, "c__objectName": "Account_Treatment__c", "c__mode": "create" };
        //navigate to component
        var navService = cmp.find("navService");
        event.preventDefault();
        //navigate function navigates to page reference
        navService.navigate(pageReference);
    },

    getContractTreatmentList: function (cmp, event, helper) {
        var action = cmp.get("c.newGetContractTreatmentList");
        var recordId = cmp.get("v.recordId");
        // Add callback behavior for when response is received
        action.setParams({
            "contractFrameworkId": recordId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                cmp.set("v.contractTreatments", response.getReturnValue());
                console.log(cmp.get("v.contractTreatments").length);
                console.log(cmp.get("v.contractTreatments"));
                if (cmp.get("v.contractTreatments").length == 0) {
                    cmp.set("v.emptyList", true);
                } else {
                    cmp.set("v.emptyList", false);
                }
                cmp.set("v.doneLoading", true);
                console.log(response.getReturnValue());
            }
        });
        // Send action off to be executed
        $A.enqueueAction(action);
    },

    handleClickViewAllHelper: function (cmp, event, helper) {
        var pageReference = cmp.get("v.relatedPageReference");
        var navService = cmp.find("navService");
        event.preventDefault();
        //navigate function navigates to page reference
        navService.navigate(pageReference);
    },

    getContractTreatmentListNumber: function (cmp, event, helper) {
        var action = cmp.get("c.newGetContractTreatmentListNumber");
        var recordId = cmp.get("v.recordId");
        // Add callback behavior for when response is received
        action.setParams({
            "contractFrameworkId": recordId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                cmp.set("v.numberOfTreatments", response.getReturnValue());
            }
        });
        // Send action off to be executed
        $A.enqueueAction(action);
    }
})