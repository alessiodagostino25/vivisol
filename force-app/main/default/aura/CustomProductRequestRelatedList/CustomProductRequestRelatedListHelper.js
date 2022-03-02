({
    handleClickNewHelper: function (cmp, event, helper) {
        
    },

    handleClickViewAllHelper: function (cmp, event, helper) {
        
    },

    getProductRequests: function (cmp, event, helper) {
        var action = cmp.get("c.getProductRequests");
        // Add callback behavior for when response is received
        action.setParams({
            "queryLimit": 10
        });
        action.setCallback(this, function (response) {
            console.log('RESPONSE: ' + JSON.stringify(response));
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                cmp.set("v.productRequests", response.getReturnValue());
                console.log(cmp.get("v.productRequests").length);
                console.log(cmp.get("v.productRequests"));
                if (cmp.get("v.productRequests").length == 0) {
                    cmp.set("v.emptyList", true);
                } else {
                    if(cmp.get("v.productRequests").length < 4) {
                        cmp.set("v.productRequestNumber", cmp.get("v.productRequests").length);
                    }
                    else if(cmp.get("v.productRequests").length >= 4) {
                        cmp.set("v.productRequestNumber", '3+');
                    }

                    cmp.set("v.emptyList", false);
                }
                cmp.set("v.doneLoading", true);
                console.log(response.getReturnValue());
            }
        });
        // Send action off to be executed
        $A.enqueueAction(action);
    }
})