({
    handleclickView: function (cmp, event, helper) {
        var navService = cmp.find("navService");
        // Uses the pageReference definition in the init handler
        var pageReference = cmp.get("v.viewPageReference");
        event.preventDefault();
        navService.navigate(pageReference);
    }
})