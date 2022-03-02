({
    handleclickView: function (cmp, event, helper) {
        var navService = cmp.find("navService");
        // Uses the pageReference definition in the init handler
        var pageReference = cmp.get("v.viewPageReference");
        event.preventDefault();
        navService.navigate(pageReference);
    },

    handleClickCorporateTreatmentHelper: function (cmp, event, helper) {
        var navService = cmp.find("navService");
        // Uses the pageReference definition in the init handler
        var pageReference = cmp.get("v.corporateTreatmentPageReference");
        event.preventDefault();
        navService.navigate(pageReference);
    },

    handleclickEdit: function (cmp, event, helper) {
        // Assigning the Create Permission Set when editing a Contract Treatment, but first clearing all the previously given ones
        var clearPermSet = cmp.get("c.removePermSet");
        clearPermSet.setCallback(this, function(response) {
            console.log('Permission sets cleared');
            var action = cmp.get("c.assignPermSetNew");
            /*action.setParams({
                frameworkStatus: cmp.get("v.frameworkStatus")
            });*/
            action.setCallback(this, function(response) {
                console.log('Permission set assigned');
            })
            $A.enqueueAction(action);
        });
        $A.enqueueAction(clearPermSet);

        var navService = cmp.find("navService");
        // Uses the pageReference definition in the init handler
        var pageReference = cmp.get("v.editPageReference");
        var contractFrameworkId = cmp.get("v.contractFrameworkId");
        var contractTreatmentRecordId = cmp.get("v.contractTreatmentRecordId");
        var corporateTreatmentId = cmp.get("v.corporateTreatmentId");
        var status = cmp.get("v.status");
        pageReference.state = {
            "c__recordId": contractFrameworkId, "c__objectName": "Contract_Treatment__c",
            "c__mode": "edit", "c__contractTreatmentRecordId": contractTreatmentRecordId, "c__corporateTreatmentId": corporateTreatmentId, "c__status": status
        };
        event.preventDefault();
        navService.navigate(pageReference);
    }
})