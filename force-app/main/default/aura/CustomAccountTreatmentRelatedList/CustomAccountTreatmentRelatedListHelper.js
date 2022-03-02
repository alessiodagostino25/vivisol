({
    handleClickHelper: function (cmp, event, helper) {
        var clearPermSet = cmp.get("c.removePermSet");
        clearPermSet.setCallback(this, function() {
            console.log('Permission sets cleared');
            var action = cmp.get("c.assignPermSetNew");

            action.setCallback(this, function() {
                console.log('Permission set assigned');
            })
            $A.enqueueAction(action);
        });
        $A.enqueueAction(clearPermSet);
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

    handleClickViewAllHelper: function (cmp, event, helper) {
        var pageReference = cmp.get("v.relatedPageReference");
        var navService = cmp.find("navService");
        event.preventDefault();
        //navigate function navigates to page reference
        navService.navigate(pageReference);
    },

    getAccountTreatmentList: function (cmp, event, helper) {
        var action = cmp.get("c.newGetAccountTreatmentList");
        var recordId = cmp.get("v.recordId");
        // Add callback behavior for when response is received
        action.setParams({
            "accountId": recordId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                cmp.set("v.accountTreatments", response.getReturnValue());
                console.log(cmp.get("v.accountTreatments").length);
                console.log(cmp.get("v.accountTreatments"));
                if (cmp.get("v.accountTreatments").length == 0) {
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

    getAccountTreatmentListNumber: function (cmp, event, helper) {
        var action = cmp.get("c.newGetAccountTreatmentListNumber");
        var recordId = cmp.get("v.recordId");
        // Add callback behavior for when response is received
        action.setParams({
            "accountId": recordId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                cmp.set("v.numberOfTreatments", response.getReturnValue());
                if (response.getReturnValue() == 0){
                    cmp.set("v.emptyList", true);
                }
            }
        });
        // Send action off to be executed
        $A.enqueueAction(action);
    }
})