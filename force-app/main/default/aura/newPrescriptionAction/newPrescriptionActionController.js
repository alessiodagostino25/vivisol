({
    //S:SIDEA V4AT-182
    init:function(component, event)
    {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openSubtab({
            pageReference: {
                "type": "standard__component",
                "attributes": {
                    "componentName": "c__newPrescriptionComponentWrapper"
    //second aura component
                },
                    "state": {
                            c__crecordId: component.get("v.parentFieldId")
                }
            },
            focus: true
        }).then(function(subtabId){
            workspaceAPI.setTabLabel({
                tabId: subtabId,
                label: "New Prescription"
            });
            workspaceAPI.setTabIcon({
                tabId: subtabId,
                icon: "custom:custom33",
                iconAlt: "New Prescription"
            });
        }).catch(function(error) {
            console.log(error);
        });
    },
    //E:SIDEA V4AT-182
})