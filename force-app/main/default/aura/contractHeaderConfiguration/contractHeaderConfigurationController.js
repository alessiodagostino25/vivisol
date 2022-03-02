({
	doInit: function(component, event, helper) {
        //getting page reference from pageReference attribute supplied by lightning:isUrlAddressable interface
        var myPageRef = component.get("v.pageReference");
        document.title = "Contract Treatment Configuration";
        //get parameter from state
        var contractFrameworkId = myPageRef.state.c__recordId;
        var objectName = myPageRef.state.c__objectName;
        var contractTreatmentRecordId = myPageRef.state.c__contractTreatmentRecordId;
        var corporateTreatmentId = myPageRef.state.c__corporateTreatmentId;
        var mode = myPageRef.state.c__mode;
        var status = myPageRef.state.c__status;
        component.set("v.recordId", contractFrameworkId);
        component.set("v.objectName", objectName);
        component.set("v.contractTreatmentRecordId", contractTreatmentRecordId);
        component.set("v.corporateTreatmentId", corporateTreatmentId);
        component.set("v.status", status);
        component.set("v.mode", mode);

        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: "Treatment"
            });
        })
        .catch(function(error) {
            console.log(error);
        });
    }
})