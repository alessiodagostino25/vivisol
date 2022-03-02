({
    setStatus : function(component, event, helper) {
        var action = component.get("c.getStatus");
        
        action.setParams({
            "workOrderId": component.get("v.recordId")
        });

        action.setCallback(this, function (response) {
            if(response.getReturnValue() != null && response.getReturnValue() != undefined) {
                component.find("Combobox").set("v.value", response.getReturnValue());
            }
        });

        $A.enqueueAction(action);
    },

    setReason : function(component, event, helper) {
        var action = component.get("c.getReason");
        
        action.setParams({
            "workOrderId": component.get("v.recordId")
        });

        action.setCallback(this, function (response) {
            if(response.getReturnValue() != null && response.getReturnValue() != undefined) {
                component.find("Reason").set("v.value", response.getReturnValue());
            }
        });

        $A.enqueueAction(action);
    },

    processGoodsMovement : function(component, event, helper) {
        var recordId = component.get("v.recordId");

        var action = component.get("c.processGoodsMovement");

        action.setParams({
            "workOrderId": recordId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state == "SUCCESS") {
                console.log('SUCCESS!');
            }
            else if(state == "ERROR") {
                console.log('ERROR');

                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    }
})