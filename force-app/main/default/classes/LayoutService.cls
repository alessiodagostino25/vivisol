public class LayoutService {
    @AuraEnabled
    public static LayoutDTO getLayout(String recordId) {
        System.debug('----- getLayout -----');

        LayoutDTO toReturn;
        String recordTypeId = getRecordTypeId(recordId);

        if(recordTypeId != null) {
            String layoutName = getLayoutName(recordTypeId);

            if(layoutName != null) {
                List<Metadata.Metadata> layouts = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, new List<String> {layoutName});
                if(layouts != null && !layouts.isEmpty()) {
                    Metadata.Layout layoutMetadata = (Metadata.Layout)layouts.get(0);

                    if(layoutMetadata != null) {
                        toReturn = new LayoutDTO(layoutMetadata);
                    }
                }
            }
        }

        return toReturn;
    }

    public static String getRecordTypeId(Id recordId) {
        System.debug('----- getRecordTypeId -----');
        System.debug('recordId: ' + recordId);

        String recordTypeId;
        String sObjName = recordId.getSObjectType().getDescribe().getName();

        if(sObjName != null) {
            String query = 'SELECT RecordTypeId FROM ' + sObjName + ' WHERE Id =: recordId';

            SObject queriedObject = Database.query(query);
            recordTypeId = (String) queriedObject.get('RecordTypeId');
        }

        return recordTypeId;
    }

    public static String getLayoutName(String recordTypeId) {
        System.debug('----- getLayoutName -----');
        String layoutName;

        try {
            layoutName = getLayoutNameForCurrentUserProfile(recordTypeId);
        }
        catch(Exception e) {
            System.debug('EXCEPTION');
            System.debug(e.getMessage());
        }

        return layoutName;
    }

    static String restGet(String endPoint, String method/* , String sid */) {
        System.debug('----- restGet -----');

        Http h = new Http();
        HttpRequest hr = new HttpRequest();
        //hr.setHeader('Authorization', 'OAuth ' + sid);
        //hr.setHeader('Authorization', 'Bearer {!$CIPHR_Kimble.OAuthToken}'); 
        /* hr.setHeader('Content-Type', 'application/json');
        hr.setHeader('Accept', 'application/json'); */
        hr.setTimeout(60000);
        hr.setEndpoint(endPoint);
        hr.setMethod(method);
        HttpResponse r = h.send(hr);
        return r.getBody();
    }

    static String toolingAPISOQL(String query) {
        System.debug('----- toolingAPISOQL -----');

        String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
        return restGet('callout:SELF_QUERY' + 
            '/services/data/v51.0/tooling/query/?q=' + (query.replace(' ', '+')),
            'GET'/* , UserInfo.getSessionId() */
        );
    } 
    
    static String getLayoutNameForCurrentUserProfile(String recordTypeId) {
        System.debug('----- getLayoutNameForCurrentUserProfile -----');

        String body = toolingAPISOQL('SELECT Layout.FullName FROM ProfileLayout WHERE ProfileId = \'' + UserInfo.getProfileId() + '\' AND RecordTypeId = \'' + 
        recordTypeId + '\' LIMIT 1');
        System.debug(LoggingLevel.DEBUG, '@@@ v: ' + body);
        String name = body.substringBetween('"FullName":"', '"');
        System.debug(LoggingLevel.DEBUG, '@@@ v: ' + name);
        return name;
    }
}