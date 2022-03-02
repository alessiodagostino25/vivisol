({
    init: function (cmp, event, helper) {
        var navService = cmp.find("navService");
        var currentRecordId = cmp.get("v.accountTreatmentId");
        var accountId = cmp.get("v.accountId");
        // Sets the route to /lightning/o/Account/home
        var viewPageReference = {
            "type": "standard__recordPage",
            "attributes": {
                "recordId": currentRecordId,
                "objectApiName": "Account_Treatment__c",
                "actionName": "view"
            }
        };
        var editPageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__AccountHeaderConfiguration',
            }
        };
        cmp.set("v.viewPageReference", viewPageReference);
        cmp.set("v.editPageReference", editPageReference);
        // Set the URL on the link or use the default if there's an error
    },
    handleSelect: function (cmp, event, helper) {
        // This will contain the string of the "value" attribute of the selected
        // lightning:menuItem
        var selectedMenuItemValue = event.getParam("value");
        if (selectedMenuItemValue == "Edit") {
            helper.handleclickEdit(cmp, event, helper);
        }
        if (selectedMenuItemValue == "View") {
            helper.handleclickView(cmp, event, helper);
        }
    },

    handleNameClick: function(cmp, event, helper) {
        helper.handleclickView(cmp, event, helper);
    }
})