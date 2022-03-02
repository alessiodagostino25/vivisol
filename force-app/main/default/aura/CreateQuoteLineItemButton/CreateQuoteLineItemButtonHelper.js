({
    
    getQuoteStatus: function(component, event, helper) {        
        var action = component.get("c.getQuoteStatus");
        var recordId = component.get("v.recordId");
        action.setParams({
            "quoteId": recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();     
            component.set("v.quoteStatus", response.getReturnValue());

            var quoteStatus = component.get("v.quoteStatus");

            var isPhone = $A.get("$Browser.isPhone");            

            if(isPhone){
                var navService = component.find("navService");
                var pageReference = {
                    type: "standard__component",
                    attributes: {
                        "componentName": "c__quoteLineItemsEdit" 
                    },    
                    state: {
                        "c__quoteId": recordId,
                        "c__quoteStatus": quoteStatus
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
                
                var pageReference = component.get("v.pageReference");
                event.preventDefault();
                navService.navigate(pageReference);
            } else {
                var labelTab = $A.get("$Label.c.createQuoteLineItem_TabLabel");
                var workspaceAPI = component.find("workspace");
                workspaceAPI.getEnclosingTabId().then(function(enclosingTabId) {                    
                    workspaceAPI.openSubtab({
                        parentTabId: enclosingTabId,
                        pageReference: {
                            "type": "standard__component",
                            "attributes": {
                            "componentName": "c__quoteLineItemsEdit"
                            },
                            "state": {
                                "c__quoteId": recordId,
                                "c__quoteStatus": quoteStatus
                            }
                        },
                        focus: true
                    }).then(function(subtabId) {
                        workspaceAPI.setTabLabel({
                            tabId: subtabId,
                            label: labelTab
                        });
                        workspaceAPI.setTabIcon({
                            tabId: subtabId,
                            icon: "custom:custom82",
                            iconAlt: labelTab
                        });
                       // workspaceAPI.focusTab({tabId : enclosingTabId});
                        workspaceAPI.focusTab({tabId : subtabId}); 
                    }).catch(function(error) {
                        console.log("error");
                    });
                });
            }
        });
        $A.enqueueAction(action);
    },

})