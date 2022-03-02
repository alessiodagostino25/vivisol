({
    init: function(component, event, helper) {
        var flowName = component.get("v.flowName");

        if(flowName === 'Van_Unloading') {
            var action = component.get("c.navigateToVanUnloadingFlow");

            $A.enqueueAction(action);
        }
        else if(flowName === 'CreateExtraLoading') {
            var action = component.get("c.navigateToCreateExtraLoadingFlow");

            $A.enqueueAction(action);
        }
    },

    navigateToVanUnloadingFlow: function(component, event, helper) {
        console.log('UserId in navigateToFlow: ' + component.get("v.userId"));
        var flow = component.find("flowData");
        var inputVariables = [
            {
            name : "UserId",
            type : "String",
            value : component.get("v.userId")
            }
        ];
        // In that component, start your flow. Reference the flow's Unique Name.
        flow.startFlow("Van_Unloading", inputVariables);
    },

    navigateToCreateExtraLoadingFlow: function(component, event, helper) {
        var flow = component.find("flowData");
        var inputVariables = [
            {
            name : "UserId",
            type : "String",
            value : component.get("v.userId")
            }
        ];
        // In that component, start your flow. Reference the flow's Unique Name.
        flow.startFlow("CreateExtraLoading", inputVariables);
    },

    handleStatusChange : function (component, event) {
        if(event.getParam("status") === "FINISHED") {
            console.log('FLOW FINISHED');
            /* var compEvent = component.getEvent("flowFinishEvent");
            compEvent.fire();

            var outputVariables = event.getParam("outputVariables");
            var outputVar;
            for(var i = 0; i < outputVariables.length; i++) {
                outputVar = outputVariables[i];
                if(outputVar.name === "WorkOrderId") {
                    var urlEvent = $A.get("e.force:navigateToSObject");
                    urlEvent.setParams({
                        "recordId": outputVar.value,
                        "isredirect": "true"
                    });
                    urlEvent.fire();
                }
            } */
        }
    }
})