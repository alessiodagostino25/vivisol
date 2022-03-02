({
  doInit: function (component, event, helper) {
    //getting page reference from pageReference attribute supplied by lightning:isUrlAddressable interface
    var myPageRef = component.get("v.pageReference");
    //get parameter from state
    var accountRecordId = myPageRef.state.c__accountRecordId;
    var accountTreatmentRecordId = myPageRef.state.c__accountTreatmentRecordId;
    var contractTreatmentRecordId = myPageRef.state.c__contractTreatmentRecordId;
    var objectName = myPageRef.state.c__objectName;
    var mode = myPageRef.state.c__mode;
    component.set("v.mode", mode);
    component.set("v.accountRecordId", accountRecordId);
    component.set("v.accountTreatmentRecordId", accountTreatmentRecordId);
    component.set("v.objectName", objectName);
    component.set("v.contractTreatmentRecordId", contractTreatmentRecordId);
    var workspaceAPI = component.find("workspace");
    workspaceAPI.getFocusedTabInfo().then(function(response) {
        var focusedTabId = response.tabId;
        workspaceAPI.setTabLabel({
            tabId: focusedTabId,
            label: $A.get("$Label.c.AT_Tabname")
        });
        workspaceAPI.setTabIcon({
          tabId: focusedTabId,
          icon: "custom:custom15",
          iconAlt: "custom15"
      });
    })
  }
})