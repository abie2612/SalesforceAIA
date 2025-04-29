public class GetGoogleDriveAccessToken implements Schedulable {
    public void execute(SchedulableContext sc){
       GetGoogleDriveAccessToken.makecallout();
    }
    @future(callout = true)
    public static void makecallout(){
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        
        // Set the correct endpoint without query parameters
        req.setEndpoint(System.Label.GoogleDriveEndpoint);
        req.setMethod('POST');
        
        String body = 'client_id=' + EncodingUtil.urlEncode(System.Label.googleDriveClientId, 'UTF-8')
            + '&client_secret=' + EncodingUtil.urlEncode(System.Label.googleDriveClientSecret, 'UTF-8')
            + '&grant_type=' + EncodingUtil.urlEncode(System.Label.googleDrivegrantTypeRefresh, 'UTF-8')
            + '&refresh_token=' + EncodingUtil.urlEncode(System.Label.googleDriveRefreshToken, 'UTF-8');
        
        req.setBody(body);  // Set the body of the request
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Content-Length', String.valueOf(body.length()));  // Set the Content-Length header
        
        HttpResponse res = http.send(req);
        
        if(res != NULL && res.getStatusCode() != NULL && res.getStatusCode() == 200){
            List<Google_Drive__c> updateGoogleDriveList = new List<Google_Drive__c>();
            Map<String,Object> results =(Map<String,Object>) System.JSON.deserializeUntyped(res.getBody());
            System.debug('results'+String.valueOf(results.get('access_token')));
            Google_Drive__c updateToken = new Google_Drive__c ();
            updateToken.Token_Name__c = 'AccessToken';
            updateToken.GoogleDriveAccessToken__c = String.valueOf(results.get('access_token')) ;
            updateGoogleDriveList.add(updateToken);
            if( updateGoogleDriveList != null && updateGoogleDriveList.size()>0){
                UPSERT updateGoogleDriveList Token_Name__c;
            }
            
        }
        
        else {
            System.debug('Error: ' + res.getStatus() + ' - ' + res.getBody());
        }
    }
    
}