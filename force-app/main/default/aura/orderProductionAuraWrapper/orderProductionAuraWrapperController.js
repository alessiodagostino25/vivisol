({
    doInit : function(component, event, helper) {
        var pageRef = component.get("v.pageReference");
        console.log('PageReference from Wrapper: ' + pageRef);
        console.log('RecordId da pageReference.state: ' + pageRef.state.c__recordId);
        component.set("v.recordId", pageRef.state.c__recordId);
        console.log('RecordId from Wrapper: ' + component.get("v.recordId"));
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label:  $A.get("$Label.c.CustomOrderProduct_TabTitle"),

            });
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "standard:orders",
                iconAlt: "orders"
            });
            

        })

    },
    handletabClose: function(component, event) {


        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
            console.log('closed tab')
        })
        .catch(function(error) {
            console.log(error);
        });
    },
        
    

})