({
    init: function(cmp, event, helper) {
        

        var pageReference = cmp.get("v.pageReference");
        document.title = "Quote Wizard";
        cmp.set("v.recordId", pageReference.state.c__quoteId);
        cmp.set("v.quoteStatus", pageReference.state.c__quoteStatus);
        
        cmp.set("v.page1", true);
        cmp.set("v.page2", false);
        cmp.set("v.page3", false);
        
    },

    handleFilterChange: function(component, event) {
        
        var workspaceAPI = component.find("workspace");
        var focusedTabId = '';    
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            focusedTabId = response.tabId;
        })
        .catch(function(error) {
            console.log(error);
        });

        $A.get('e.force:refreshView').fire();
        workspaceAPI.closeTab({tabId: focusedTabId});  
     
    },
    
})