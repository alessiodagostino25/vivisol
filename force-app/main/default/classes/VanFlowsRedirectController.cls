public class VanFlowsRedirectController {
    
    @AuraEnabled
    public static String getCurrentUserId(){
        return UserInfo.getUserId();
    }
}