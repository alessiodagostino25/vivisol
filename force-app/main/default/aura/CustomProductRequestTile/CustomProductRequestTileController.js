({
    init: function (cmp, event, helper) {
        var navService = cmp.find("navService");
        var currentRecordId = cmp.get("v.productRequestId");
        // Sets the route to /lightning/o/Account/home
        var viewPageReference = {
            "type": "standard__recordPage",
            "attributes": {
                "recordId": currentRecordId,
                "objectApiName": "ProductRequest",
                "actionName": "view"
            }
        };

        cmp.set("v.viewPageReference", viewPageReference);
    },

    handleSelect: function (cmp, event, helper) {
        // This will contain the string of the "value" attribute of the selected
        // lightning:menuItem
        var selectedMenuItemValue = event.getParam("value");
        if (selectedMenuItemValue == "View") {
            helper.handleclickView(cmp, event, helper);
        }
    },

    handleNameClick: function(cmp, event, helper) {
        helper.handleclickView(cmp, event, helper);
    }
})