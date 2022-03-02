({
    init : function(cmp, event, helper) {
        
    },

    handleOrderClick : function(cmp, event, helper) {
        helper.getPrefilledOrder(cmp, event, helper);
    },

    handleQuoteClick: function(cmp, event, helper) {
        helper.getPrefilledQuote(cmp, event, helper);
    },

    handleWorkOrderClick : function(cmp, event, helper) {
        cmp.set("v.showModal", true);
    },

    closeFlowModal: function(cmp, event, helper) {
        cmp.set("v.showModal", false);
        console.log('showModal: ' + cmp.get("v.showModal"));
    },

    handleFlowFinishEvent: function(cmp, event, helper) {
        console.log('Chiudendo il flow');
        cmp.set("v.showModal", false);
    }
})