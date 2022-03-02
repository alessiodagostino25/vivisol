({
    doInit: function (component, event, helper) {
        //buiding a page reference for the component where we need to navigate
        helper.getContractTreatmentListNumber(component, event, helper);
        helper.getContractTreatmentList(component, event, helper);
        var newRecordpageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__contractHeaderConfiguration',
            }
        };
        var contractFrameworkId = component.get("v.recordId");
        var relatedListPageReference = {
            "type": "standard__recordRelationshipPage",
            "attributes": {
                "recordId": contractFrameworkId,
                "objectApiName": "Contract_Framework__c",
                "relationshipApiName": "Contract_Treatments__r",
                "actionName": "view"
            }
        };
        var navService = component.find("navService");
        component.set("v.pageReference", newRecordpageReference);
        component.set("v.relatedPageReference", relatedListPageReference);
        var defaultUrl = "#";
        navService.generateUrl(relatedListPageReference)
            .then($A.getCallback(function (url) {
                component.set("v.url", url ? url : defaultUrl);
            }), $A.getCallback(function (error) {
                component.set("v.url", defaultUrl);
            }));
        
        // Using the Framework Status to conditionally display the New button
        var action = component.get("c.getFrameworkStatus");
        action.setParams({
            "contractFrameworkId": contractFrameworkId
        });
        action.setCallback(this, function(response) {
            console.log('RESPONSE: ' + response.getReturnValue());
            component.set("v.frameworkStatus", response.getReturnValue());
            console.log('v.frameworkStatus: ' + component.get("v.frameworkStatus"));
            // Conditionally hiding the New button
            if(response.getReturnValue() === 'Inactive') {
                component.set("v.hideNewButton", true);
            }
            if(response.getReturnValue() !== 'Inactive' && component.get("v.hideNewButton") === true) {
                component.set("v.hideNewButton", false);
            } 
        });
        $A.enqueueAction(action);
        
    },
    handleClickNewButton: function (component, event, helper) {
        // Assigning the Create Permission Set when creating a new Account Treatment, but first clearing all the previously given ones
        var clearPermSet = component.get("c.removePermSet");
        clearPermSet.setCallback(this, function(response) {
            console.log('Permission sets cleared');
            var action = component.get("c.assignPermSetNew");
            action.setCallback(this, function(response) {
                console.log('Permission set for Create assigned');
            })
            $A.enqueueAction(action);
        });
        $A.enqueueAction(clearPermSet);
        
        var pageReference = component.get("v.pageReference");
        var contractFrameworkId = component.get("v.recordId");
        pageReference.state = { "c__recordId": contractFrameworkId, "c__objectName": "Contract_Framework__c", "c__mode": "create" };
        //navigate to component
        var navService = component.find("navService");
        event.preventDefault();
        //navigate function navigates to page reference
        navService.navigate(pageReference);
    },
    handleClickViewAll: function (component, event, helper) {
        helper.handleClickViewAllHelper(component, event, helper);
    },

    // If the Contract Framework is Updated, reload the related list component to hide/show the New button
    recordUpdated: function(component, event, helper) {
        var changeType = event.getParams().changeType;
        if(changeType === "CHANGED") {
            var action = component.get("c.doInit");
            $A.enqueueAction(action);
        }
    }
})