({
    invoke : function(component, event, helper) {
        var args = event.getParam("arguments") ;
       
        component.find("recordLoader").reloadRecord();

    }
})