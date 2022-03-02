({
    doInit: function(component, event, helper) {
        helper.doInitHelper(component, event);
    },
    searchKeyChange : function(component, event, helper) {
        var searchKey = component.find("searchKey").get("v.value");

        console.log('searchKey:::::'+searchKey);
        component.set("v.searchText", searchKey);
        if(searchKey.length > 3 || searchKey.length == 0  ){
        var allproducts = component.get("v.listOfAllproducts");
        console.log('values of prodivhcs'+JSON.stringify(allproducts));
        var PreselectedProducts = [];
        for (var i = 0; i < allproducts.length; i++) {
            if (allproducts[i].isChecked) {
                PreselectedProducts.push(allproducts[i].Id);
            }
        }

        component.set("v.PreselectedProducts",PreselectedProducts );

        helper.doInitHelper(component, event);
    }
},
    checkboxSelect: function(component, event, helper) {
      
        
    },
    handleClick : function(component, event, helper){

        
    }
   
})