({
    init: function(component, event, helper) {
    

    },

    handleClick : function(component, event, helper) {

        var orderId = component.get("v.recordId");
        console.log('RecordId from NavigationController: ' + orderId);
        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__orderProductionAuraWrapper',
            },
            state: {
                "c__recordId": orderId
            }
        };

    
   

        var navService = component.find("navService");
        navService.navigate(pageReference);
    }
})