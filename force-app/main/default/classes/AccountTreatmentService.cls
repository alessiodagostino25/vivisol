public  class AccountTreatmentService {
    public static void assignPermSetNew() { 
        final String sessionId;
        if(!Test.isRunningTest()) {
            Map<String, String> sessionManagement = Auth.SessionManagement.getCurrentSession();

            if(sessionManagement.get('ParentId') != null) {
                sessionId = sessionManagement.get('ParentId');
            }
            else {
                sessionId = sessionManagement.get('SessionId');
            }
        }
      
        List<PermissionSet> permissionSetIdList = [SELECT Id FROM PermissionSet WHERE Name = 'Account_Treatment_Create'] ;
        List<Id> permissionSetIdsList = new List<Id>();

        for(Integer i =0;i<permissionSetIdList.size();i++){
			permissionSetIdsList.add(permissionSetIdList[i].Id);
        }

        SessionPermSetActivation activation = new SessionPermSetActivation();
        activation.AuthSessionId = sessionId;
        System.debug('AuthSessionId: ' + activation.AuthSessionId);
        activation.PermissionSetId = permissionSetIdsList[0] ;
        activation.Description = 'created by SessionPermSetActivationController';
        if(!Test.isRunningTest()) {
            insert activation;
            System.debug('Activation Id: ' + activation.Id);
        }

    }

    public static void removePermSet() {
        Id userId = UserInfo.getUserId();
        
        List<PermissionSet> permissionSetIdList = [SELECT Id FROM PermissionSet WHERE Name = 'Account_Treatment_Create'] ;
        List<Id> permissionSetIdsList = new List<Id>();
        for(Integer i =0;i<permissionSetIdList.size();i++){
			permissionSetIdsList.add(permissionSetIdList[i].Id);
		}

        // Needed?
        if(!Test.isRunningTest()) {
            Map<String, String> sessionManagement = Auth.SessionManagement.getCurrentSession();
            final String sessionId;
            if(sessionManagement.get('ParentId') != null) {
                sessionId = sessionManagement.get('ParentId');
            }
            else {
                sessionId = sessionManagement.get('SessionId');
            }
        }

        List<SessionPermSetActivation> activations = [SELECT Id FROM SessionPermSetActivation WHERE UserId =: userId AND PermissionSetId IN: permissionSetIdsList];
        System.debug('Activations to remove: ' + activations.size());

        if(activations.size() > 0) {
            delete activations;
        }
    }
}