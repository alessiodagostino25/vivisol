({
    //S:SIDEA V4AT-182
    init: function (component, event, helper) {
        var pageReference = component.get("v.pageReference");
        var rId = pageReference.state.c__crecordId;
        component.set("v.crecordId", rId);
        console.log('rId: ' + rId);
    },

    closeTabPrescription: function(component, event, helper) {
        if(event.getParam('isSaveOK') == true) {
            console.log('Closing tab...');
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({tabId: focusedTabId});
            })
            .catch(function(error) {
                console.log(error);
            });
        }
    }
    //E:SIDEA V4AT-182
});