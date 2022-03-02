({
    handleclickView: function (cmp, event, helper) {
        var navService = cmp.find("navService");
        // Uses the pageReference definition in the init handler
        var pageReference = cmp.get("v.viewPageReference");
        event.preventDefault();
        navService.navigate(pageReference);
    },

    handleclickEdit: function (cmp, event, helper) {
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
        var navService = cmp.find("navService");
        // Uses the pageReference definition in the init handler
        var pageReference = cmp.get("v.editPageReference");
        var accountRecordId = cmp.get("v.accountId");
        var accountTreatmentId = cmp.get("v.accountTreatmentId");
        var contractTreatmentRecordId = cmp.get("v.contractTreatmentRecordId");
        pageReference.state = {
            "c__accountRecordId": accountRecordId, "c__objectName": "Account_Treatment__c",
            "c__mode": "edit", "c__accountTreatmentRecordId": accountTreatmentId, "c__contractTreatmentRecordId": contractTreatmentRecordId
        };
        event.preventDefault();
        navService.navigate(pageReference);
    }
})