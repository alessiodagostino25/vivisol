({
    doInitHelper : function(component,event){ 
        var action = component.get("c.getorderproducts");
        var recordId = component.get("v.recordId");
        var searchKey = component.get("v.searchText");
        var preselectedproducts = component.get("v.PreselectedProducts");
        console.log('preselected product ids'+preselectedproducts)
        console.log('values for the search'+searchKey) ;
        action.setParams({
            "orderId": recordId ,
            "searchKey" : searchKey ,
            "preselectedproducts" : preselectedproducts 
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var oRes = response.getReturnValue();
                console.log('data in ores'+JSON.stringify(oRes));
             
                    console.log('passed into if loop of size ') ;
                  /*   component.set("v.listOfAllproducts", oRes);
                    console.log(component.get("v.listOfAllproducts").length);
                    console.log(component.get("v.listOfAllproducts")); */
                    var updatedAllproducts = [];
                    var listOfAllproducts = oRes ;

                    for (var i=0 ; i < listOfAllproducts.length ; i ++){

                    if(preselectedproducts.includes( listOfAllproducts[i].Id )){

                        listOfAllproducts[i].isChecked = true;
                       }
                       updatedAllproducts.push(listOfAllproducts[i]);
                    }

                       component.set("v.listOfAllproducts", updatedAllproducts);
                   
                  
                    
                    //use Math.ceil() to Round a number upward to its nearest integer   
                }
            
            
        });
        $A.enqueueAction(action);  
    } 

})