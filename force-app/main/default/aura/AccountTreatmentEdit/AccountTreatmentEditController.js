({
    doInit: function (component, event, helper) { 
      // Getting the related Account Id
      var getAccountId = component.get("c.getAccountId");
      getAccountId.setParams({
        accountTreatmentId : component.get("v.recordId")
      });

      getAccountId.setCallback(this, function(response) {
        var result = response.getReturnValue();
        console.log('AURA:: result: ' + result);
        component.set("v.accountId", result);
      });

      $A.enqueueAction(getAccountId);

 // Assigning the Create Permission Set when editing a Account Treatment, but first clearing all the previously given ones
      var clearPermSet = component.get("c.removePermSet");
        clearPermSet.setCallback(this, function() {
            console.log('Permission sets cleared');
            var action = component.get("c.assignPermSetNew");

            action.setCallback(this, function() {
                console.log('Permission set assigned');
            })
            $A.enqueueAction(action);
        });
        $A.enqueueAction(clearPermSet);
      //getting page reference from pageReference attribute supplied by lightning:isUrlAddressable interface
      var myPageRef = component.get("v.pageReference");
      //get parameter from state

      var newRecordPageReference = {
        type: 'standard__component',
        attributes: {
            componentName: 'c__AccountTreatmentEdit',
        }
    };

      var accountTreatmentRecordId = component.get("v.recordId");



      myPageRef.state = { "c__accountTreatmentRecordId": accountTreatmentRecordId, "c__objectName": "Account_Treatment", "c__mode": "edit" };

    
      var objectName = myPageRef.state.c__objectName;
      var mode = myPageRef.state.c__mode;
      component.set("v.mode", mode);
  
      component.set("v.accountTreatmentRecordId", accountTreatmentRecordId);
      component.set("v.objectName", objectName);
 
      console.log('mode'+mode);
     
      console.log('accountTreatmentRecordId'+accountTreatmentRecordId);
      console.log('mode'+objectName);
  
    }
  })