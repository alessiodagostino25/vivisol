public class customOrderProductPagecardController {

    @AuraEnabled
    public static List<customordercalloutDTO> customordercalloutDTO() {
   
        List<customordercalloutDTO> calloutresponse = new List<customordercalloutDTO>() ;
        customordercalloutDTO beta = new customordercalloutDTO();
        calloutresponse.add(beta);
    
        System.debug(calloutresponse);
        return calloutresponse;
    }
    @AuraEnabled
    public static String customorderitemsapcallout(String orderitemid) {
        String calloutresponse  = customorderitemcallout.CustomOrderItemCalloutmethod(orderitemid);

        return calloutresponse;
    }
}