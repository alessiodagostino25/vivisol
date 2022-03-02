({
    init : function(component, event, helper) {
        // Getting pageReference and setting caseId
        /* var pageReference = component.get("v.pageReference");
        console.log('PageReference: ' + pageReference);
        console.log('caseId da pageReference: ' + pageReference.state.c__caseId);
        component.set("v.caseId", pageReference.state.c__caseId);

        console.log('CaseId: ' + component.get("v.caseId")); */
        // Find the component whose aura:id is "flowData"
        var flow = component.find("flowData");
        var inputVariables = [
            {
            name : "recordId",
            type : "String",
            value : component.get("v.caseId")
            }
        ];
        // In that component, start your flow. Reference the flow's Unique Name.
        flow.startFlow("WorkOrderCreationFromCaseOrchestrator", inputVariables);
    },

    handleStatusChange : function (component, event) {
        if(event.getParam("status") === "FINISHED") {
            var compEvent = component.getEvent("flowFinishEvent");
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
            }
        }
    }
})