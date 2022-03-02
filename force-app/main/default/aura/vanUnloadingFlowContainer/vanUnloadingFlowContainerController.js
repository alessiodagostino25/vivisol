({
    init : function(component, event, helper) {
        var pageReference = component.get("v.pageReference");
        component.set("v.userId", pageReference.state.c__userId);

        var inputVariables = [
            {
            name : "UserId",
            type : "String",
            value : component.get("v.userId")
            }
        ];

        // Find the component whose aura:id is "flowData"
        var flow = component.find("flowData");
        // In that component, start your flow. Reference the flow's API Name.
        flow.startFlow("VanUnloading_ScreenFlow", inputVariables);
    },

    handleStatusChange : function (component, event) {
        if(event.getParam("status") === "FINISHED") {
            console.log('FLOW FINISHED');

            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "message": "Process successfully completed.",
                "type": 'success'
            });
            toastEvent.fire();
        }
    }
})