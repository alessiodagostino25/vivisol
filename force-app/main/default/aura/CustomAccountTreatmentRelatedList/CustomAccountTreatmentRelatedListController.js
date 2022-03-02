({
    doInit: function (component, event, helper) {
        //buiding a page reference for the component where we need to navigate

        helper.getAccountTreatmentListNumber(component, event, helper);
        helper.getAccountTreatmentList(component, event, helper);
        var newRecordpageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__AccountHeaderConfiguration',
            }
        };
        var accountId = component.get("v.recordId");
        var relatedListPageReference = {
            "type": "standard__recordRelationshipPage",
            "attributes": {
                "recordId": accountId,
                "objectApiName": "Account",
                "relationshipApiName": "Account_Treatments__r",
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
    },
    handleClickNewButton: function (component, event, helper) {
        helper.handleClickHelper(component, event, helper);
    },
    handleClickViewAll: function (component, event, helper) {
        helper.handleClickViewAllHelper(component, event, helper);
    },    
})