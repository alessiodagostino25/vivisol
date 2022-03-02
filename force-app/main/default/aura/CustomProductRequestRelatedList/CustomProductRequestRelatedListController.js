({
    doInit: function (component, event, helper) {
        //buiding a page reference for the component where we need to navigate

        helper.getProductRequests(component, event, helper);
        /* var newRecordpageReference = {
            
        };
        
        component.set("v.pageReference", newRecordpageReference); */
    },
    handleClickNewButton: function (component, event, helper) {
        helper.handleClickNewHelper(component, event, helper);
    },
    handleClickViewAll: function (component, event, helper) {
        helper.handleClickViewAllHelper(component, event, helper);
    },    
})