public class ProfilePermissionManagement {
    public static void assignEmailTemplateManagement() {
        System.debug('----- assignEmailTemplateManagement -----');

        List<String> profileQueryFields = new List<String>{'PermissionsEmailTemplateManagement'};
        List<String> profileNames = new List<String>{'Admin', 'Commercial_Support_NL', 'Contract_Manager_HQ', 'Contract_Manager_NL', 'Customer_Service_NL', 'Field_NL', 
        'FSL Optimization', 'Planning_NL', 'Read_Only_NL', 'Sales_NL', 'System_Admin_Mulesoft', 'SystemAdministrator_NL'};

        List<Profile> profilesToUpdate = ProfileDAO.getProfilesWithoutEmailManagFromNames(profileQueryFields, profileNames);
        String orgURL = URL.getOrgDomainUrl().toExternalForm();

        if(profilesToUpdate != null && !profilesToUpdate.isEmpty()) {
            for(Profile p : profilesToUpdate) {
                HttpRequest req = new HttpRequest();

                req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
                req.setHeader('Content-Type', 'application/json');
                req.setEndpoint(orgURL + '/services/data/v51.0/sobjects/Profile/' + p.Id);
                req.setMethod('PATCH');
                req.setBody('{"PermissionsEmailTemplateManagement" : "true"}');

                Http h = new Http();
                
                try {
                    HttpResponse res = h.send(req);

                    System.debug('----- Response (no response = ok!) -----');
                    System.debug(res.getBody());
                }
                catch(Exception e) {
                    System.debug('EXCEPTION');
                    System.debug(e.getMessage());
                }
            }
        }
    }
}