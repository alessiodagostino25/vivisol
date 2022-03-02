({
    init : function(cmp, event, helper) {
        //helper.getPrefilledOrder(cmp, event, helper);
    },

    handleClick : function(cmp, event, helper) {
        helper.getPrefilledOrder(cmp, event, helper);
        /* var navService = cmp.find("navService");
        var pageRef = cmp.get("v.pageReference");
        console.log('pageRef: ' + pageRef);
        event.preventDefault();
        navService.navigate(pageRef);*/
    }
})