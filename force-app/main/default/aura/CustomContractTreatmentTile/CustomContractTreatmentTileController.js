({
    init: function (cmp, event, helper) {
        // Retrieving the framework status
        var action = cmp.get("c.getFrameworkStatus");
        action.setParams({
            "contractFrameworkId": cmp.get("v.contractFrameworkId")
        });
        action.setCallback(this, function(response) {
            console.log('RESPONSE: ' + response.getReturnValue());
            cmp.set("v.frameworkStatus", response.getReturnValue());
            console.log('v.frameworkStatus in Tile: ' + cmp.get("v.frameworkStatus"));
        });
        $A.enqueueAction(action);

        var currentRecordId = cmp.get("v.contractTreatmentRecordId");
        var corporateTreatmentId = cmp.get("v.corporateTreatmentId");
        // Sets the route to /lightning/o/Account/home
        var viewPageReference = {
            "type": "standard__recordPage",
            "attributes": {
                "recordId": currentRecordId,
                "objectApiName": "Contract_Treatment__c",
                "actionName": "view"
            }
        };
        var corporateTreatmentPageReference = {
            "type": "standard__recordPage",
            "attributes": {
                "recordId": corporateTreatmentId,
                "objectApiName": "Contract_Treatment__c",
                "actionName": "view"
            }
        };
        var editPageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__contractHeaderConfiguration',
            }
        };
        cmp.set("v.viewPageReference", viewPageReference);
        cmp.set("v.editPageReference", editPageReference);
        cmp.set("v.corporateTreatmentPageReference", corporateTreatmentPageReference);
        // Set the URL on the link or use the default if there's an error
    },
    handleSelect: function (cmp, event, helper) {
        // This will contain the string of the "value" attribute of the selected
        var selectedMenuItemValue = event.getParam("value");
        if (selectedMenuItemValue == "Edit") {
            helper.handleclickEdit(cmp, event, helper);
        }
        if (selectedMenuItemValue == "View") {
            helper.handleclickView(cmp, event, helper);
        }
    },
    handleClickCorporateTreatment: function (cmp, event, helper) {
        // This will contain the string of the "value" attribute of the selected
        var corporateTreatmentId = cmp.get("v.corporateTreatmentId");
        console.log(corporateTreatmentId);
        if (corporateTreatmentId != undefined){
            helper.handleClickCorporateTreatmentHelper(cmp, event, helper);
        }
        console.log('clicked!');
    },
    
})