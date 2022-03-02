({
    invoke : function (component, event, helper) {
        var inputToastType = component.get("v.toastType");
        var inputToastMessage = component.get("v.toastMessage")
        if (inputToastType == "success") {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                message: inputToastMessage,
                duration: ' 5000',
                type: 'success',
                mode: 'dismissible'
            });
            toastEvent.fire();
        }
        if (inputToastType == "error") {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                message: inputToastMessage,
                duration: ' 5000',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
        }
        if (inputToastType == "warning") {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                message: inputToastMessage,
                duration: ' 5000',
                type: 'Warning',
                mode: 'dismissible'
            });
            toastEvent.fire();
        }

    }
})