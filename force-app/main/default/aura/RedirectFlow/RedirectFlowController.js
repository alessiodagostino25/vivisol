({

   invoke: function (component, event, helper) {
        // Get the record ID attribute
        var record = component.get("v.recordId");

        if(record != null) {
            // Get the Lightning event that opens a record in a new tab
            var redirect = $A.get("e.force:navigateToSObject");

            // Pass the record ID to the event
            redirect.setParams({
                "recordId": record
            });
            // Open the record
            redirect.fire();
        }
        else {
            var objectPageName = component.get("v.objectPageName");
            var appPageName = component.get("v.appPageName");
            var pageReference;

            console.log('appPageName: ' + appPageName);
            console.log('objectPageName: ' + objectPageName);
            
            if(objectPageName != null) {
                pageReference = {
                    type: 'standard__objectPage',
                    attributes: {
                        objectApiName: objectPageName,
                        actionName: 'home'
                    }
                };
            }
            else if(appPageName != null) {
                var pageReference = {
                    type: "standard__navItemPage",
                    attributes: {
                        apiName: appPageName,
                    }
                }
            }

            if(pageReference != null) {
                var navService = component.find("navService");

                // Set the URL on the link or use the default if there's an error
                /* var defaultUrl = "#";
                navService.generateUrl(pageReference).then($A.getCallback(function(url) {
                    cmp.set("v.url", url ? url : defaultUrl);
                }), $A.getCallback(function(error) {
                    cmp.set("v.url", defaultUrl);
                }));  */

                navService.navigate(pageReference);
            }
        }
   }
})