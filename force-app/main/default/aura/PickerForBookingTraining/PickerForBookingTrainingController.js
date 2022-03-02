({	handleClick : function(cmp, event) {
    /*helper.navigateFlow(cmp,helper);*/
  	
    var ServiceAppointment = event.target.value;
  
    cmp.set("v.vardecisionflow",ServiceAppointment);
    
console.log("selectedAppointment" + ServiceAppointment);}
        
})