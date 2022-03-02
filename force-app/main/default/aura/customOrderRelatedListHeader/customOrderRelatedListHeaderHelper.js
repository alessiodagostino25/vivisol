({
    helperMethod : function() {

    },
    handleClickViewAllHelper: function (cmp, event, helper) {
        var pageReference = cmp.get("v.relatedPageReference");
        var navService = cmp.find("navService");
        event.preventDefault();
        //navigate function navigates to page reference
        navService.navigate(pageReference);
    }
})