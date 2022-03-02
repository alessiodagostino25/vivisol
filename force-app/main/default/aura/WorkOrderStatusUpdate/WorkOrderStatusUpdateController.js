({
    init : function(component, event, helper) {
        // Setting values on load of the component

        helper.setStatus(component, event, helper);
        helper.setReason(component, event, helper);

        // Setting combobox options

        var options = [];

        var canceledOption = {
            "label" : "Canceled",
            "value" : "Canceled"
        };
        options.push(canceledOption);

        var completedOption = {
            "label" : "Completed",
            "value" : "Completed"
        };
        options.push(completedOption);

        var cannotCompleteOption = {
            "label" : "Cannot Complete",
            "value" : "Cannot Complete"
        };
        options.push(cannotCompleteOption);

        component.set("v.options", options);
    },

    handleSelectionChange : function(component, event, helper) {
        var selectedValue = component.find("Combobox").get("v.value");
        console.log('Selected value: ' + selectedValue);

        component.find("Status").set("v.value", selectedValue);
    },

    handleSubmit : function(component, event, helper) {
        
    },

    handleSuccess : function(component, event, helper) {
        component.set("v.isLoading", false);

        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The record has been successfully updated.",
            "type": 'success'
        });
        toastEvent.fire();
        
        if((component.find("Status").get("v.value")) === 'Completed') {
            helper.processGoodsMovement(component, event, helper);
        }
    },

    handleError : function(component, event, helper) {
        component.set("v.isLoading", false);

        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error",
            "message": "Something went wrong while updating the record.",
            "type": 'error'
        });
        toastEvent.fire();
    },

    handleFormLoad : function(component, event, helper) {
        component.set("v.isLoading", false);
    },

    handleSubmitClick : function(component, event, helper) {
        component.set("v.isLoading", true);
        console.log('Processing Submit...');
        component.find("Form").submit();
    }
})