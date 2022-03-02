({
    init: function(component, event, helper) {
        // Setting current User Id
        
        var action = component.get("c.getCurrentUserId");
        action.setCallback(this, function(response) {
            console.log('Response value: ' + response.getReturnValue());
            component.set("v.userId", response.getReturnValue());
            console.log('Current User Id: ' + component.get("v.userId"));
        });

        $A.enqueueAction(action);
    },

    handleVanUnloadingClick: function(component, event, helper) {
        // To use custom label
        component.set("v.modalTitle", "VAN Unloading");

        // Checking whether we are on a PHONE or on DESKTOP...
        var device = $A.get("$Browser.formFactor");

        if(device === 'DESKTOP') {
            var inputVariables = [
                {
                name : "UserId",
                type : "String",
                value : component.get("v.userId")
                }
            ];

            component.set("v.showModal", true);

            // Find the component whose aura:id is "flowData"
            var flow = component.find("flowData");
            // In that component, start your flow. Reference the flow's API Name.
            flow.startFlow("VanUnloading_ScreenFlow", inputVariables);
        }
        else if(device === 'PHONE') {
            component.set("v.showModal", false);

            var navService = component.find("navService");
            var pageReference = {
                
                "type": "standard__component",
                "attributes": {
                    "componentName": "c__vanUnloadingFlowContainer"    
                },    
                "state": {
                    "c__userId": component.get("v.userId")    
                }
            };
            component.set("v.pageReference", pageReference);
            var defaultUrl = "#";
            navService.generateUrl(pageReference)
            .then($A.getCallback(function(url) {
                component.set("v.url", url ? url : defaultUrl);
            }), $A.getCallback(function(error) {
                component.set("v.url", defaultUrl);
            }));

            var navService = component.find("navService");
            event.preventDefault();
            navService.navigate(pageReference);
        }
    },

    handleExtraLoadingClick: function(component, event, helper) {
        // To use custom label
        component.set("v.modalTitle", "VAN Extra Loading");

        // Checking if we are on a PHONE or on DESKTOP...
        var device = $A.get("$Browser.formFactor");

        if(device === 'DESKTOP') {
            var inputVariables = [
                {
                name : "UserId",
                type : "String",
                value : component.get("v.userId")
                }
            ];

            component.set("v.showModal", true);

            // Find the component whose aura:id is "flowData"
            var flow = component.find("flowData");
            // In that component, start your flow. Reference the flow's API Name.
            flow.startFlow("CreateExtraLoading", inputVariables);
        }
        else if(device === 'PHONE') {
            component.set("v.showModal", false);

            var navService = component.find("navService");
            var pageReference = {
                
                "type": "standard__component",
                "attributes": {
                    "componentName": "c__createExtraLoadingFlowContainer"    
                },    
                "state": {
                    "c__userId": component.get("v.userId")   
                }
            };
            component.set("v.pageReference", pageReference);
            var defaultUrl = "#";
            navService.generateUrl(pageReference)
            .then($A.getCallback(function(url) {
                component.set("v.url", url ? url : defaultUrl);
            }), $A.getCallback(function(error) {
                component.set("v.url", defaultUrl);
            }));

            var navService = component.find("navService");
            event.preventDefault();
            navService.navigate(pageReference);
        }
    },

    handleDestroyHUClick: function(component, event, helper) {
        // To use custom label
        component.set("v.modalTitle", "Destroy Handling Unit");

        // Checking if we are on a PHONE or on DESKTOP...
        var device = $A.get("$Browser.formFactor");

        if(device === 'DESKTOP') {
            var inputVariables = [
                {
                name : "UserId",
                type : "String",
                value : component.get("v.userId")
                }
            ];

            component.set("v.showModal", true);

            // Find the component whose aura:id is "flowData"
            var flow = component.find("flowData");
            // In that component, start your flow. Reference the flow's API Name.
            flow.startFlow("Destroy_HU", inputVariables);
        }
        else if(device === 'PHONE') {
            component.set("v.showModal", false);

            var navService = component.find("navService");
            var pageReference = {
                
                "type": "standard__component",
                "attributes": {
                    "componentName": "c__destroyHUFlowContainer"    
                },    
                "state": {
                    "c__userId": component.get("v.userId")   
                }
            };
            component.set("v.pageReference", pageReference);
            var defaultUrl = "#";
            navService.generateUrl(pageReference)
            .then($A.getCallback(function(url) {
                component.set("v.url", url ? url : defaultUrl);
            }), $A.getCallback(function(error) {
                component.set("v.url", defaultUrl);
            }));

            var navService = component.find("navService");
            event.preventDefault();
            navService.navigate(pageReference);
        }
    },

    handleScanPickingListClick: function(component, event, helper) {
        // To use custom label
        component.set("v.modalTitle", "Scan Picking List");

        // Checking whether we are on a PHONE or on DESKTOP...
        var device = $A.get("$Browser.formFactor");

        if(device === 'DESKTOP') {
            var inputVariables = [
                {
                name : "UserId",
                type : "String",
                value : component.get("v.userId")
                }
            ];

            component.set("v.showModal", true);

            // Find the component whose aura:id is "flowData"
            var flow = component.find("flowData");
            // In that component, start your flow. Reference the flow's API Name.
            flow.startFlow("Loading_Goods_Movement_Orchestrator", inputVariables);
        }
        else if(device === 'PHONE') {
            component.set("v.showModal", false);

            var navService = component.find("navService");
            var pageReference = {
                
                "type": "standard__component",
                "attributes": {
                    "componentName": "c__loadingGoodsMovementFlowContainer"    
                },    
                "state": {
                    "c__userId": component.get("v.userId")    
                }
            };
            component.set("v.pageReference", pageReference);
            var defaultUrl = "#";
            navService.generateUrl(pageReference)
            .then($A.getCallback(function(url) {
                component.set("v.url", url ? url : defaultUrl);
            }), $A.getCallback(function(error) {
                component.set("v.url", defaultUrl);
            }));

            var navService = component.find("navService");
            event.preventDefault();
            navService.navigate(pageReference);
        }
    },

    closeModal: function(component, event, helper) {
        component.set("v.showModal", false);
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