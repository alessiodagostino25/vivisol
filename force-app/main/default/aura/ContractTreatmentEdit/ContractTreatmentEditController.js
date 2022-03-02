({
    doInit: function(component, event, helper) {
        // Assigning the Create Permission Set when editing a Contract Treatment, but first clearing all the previously given ones
        var clearPermSet = component.get("c.removePermSet");
        clearPermSet.setCallback(this, function() {
            console.log('Permission sets cleared');
            var action = component.get("c.assignPermSetNew");

            action.setCallback(this, function() {
                console.log('Permission set assigned');
            })
            $A.enqueueAction(action);
        });
        $A.enqueueAction(clearPermSet);

        //getting page reference from pageReference attribute supplied by lightning:isUrlAddressable interface
        /*var myPageRef = component.get("v.pageReference");
        document.title = "Contract Treatment Edit";

        var newRecordPageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__contractTreatmentEdit',
            }
        };

        //get parameter from state
        //myPageRef.state = { "c__recordId": contractTreatmentRecordId, "c__objectName": "Contract_Treatment__c", "c__contractFrameworkId": contractFrameworkId,"c__mode": "edit"};
        
        var contractTreatmentRecordId = component.get("v.recordId");
        var contractFrameworkId = myPageRef.state.c__contractFrameworkId;
        var objectName = myPageRef.state.c__objectName;
        var mode = myPageRef.state.c__mode;
        
        component.set("v.objectName", objectName);
        component.set("v.recordId", contractTreatmentRecordId);
        component.set("v.contractFrameworkId", contractFrameworkId);
        component.set("v.pageReference", newRecordPageReference);
        component.set("v.mode", mode);*/
        
        console.log('ContractTreatmentId in ContractTreatmentEdit:::: ' + component.get("v.recordId"));

        var action = component.get("c.getContractTreatment");
        action.setParams({
            "contractTreatmentId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            console.log('status: ' + response.getReturnValue().Contract_Framework__r.Status__c);
            console.log('corporateTreatmentId: ' + response.getReturnValue().Corporate_Treatment__c);
            console.log('contractFrameworkId: ' + response.getReturnValue().Contract_Framework__c);
            
            component.set("v.corporateTreatmentId", response.getReturnValue().Corporate_Treatment__c);
            component.set("v.contractFrameworkId", response.getReturnValue().Contract_Framework__c);
            component.set("v.status", response.getReturnValue().Contract_Framework__r.Status__c);

            component.set("v.paramsOk", true);
        });
        $A.enqueueAction(action);
        
    }
})