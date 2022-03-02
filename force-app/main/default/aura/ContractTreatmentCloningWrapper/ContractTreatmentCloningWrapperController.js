({
    onInit: function(component, event, helper) {
        var action = component.get("c.assignPermSetNew");

        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.showModal", true);

            if(state === 'SUCCESS') {
                console.log('Contract_Creation permission set assigned!');
            }
            else if (state === "ERROR") {
                console.log('ERROR ASSIGNING PERMISSION SET');
                
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },

    handleClose: function(component, event, helper) {
        var action = component.get("c.removePermSet");

        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === 'SUCCESS') {
                console.log('Contract_Creation permission set removed!');
            }
            else if (state === "ERROR") {
                console.log('ERROR REMOVING PERMISSION SET');
                
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})