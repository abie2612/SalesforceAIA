public class GetGoogleDriveRefreshToken  implements Schedulable{
    public void execute(SchedulableContext sc) {        
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        
        req.setEndpoint(System.Label.GoogleDriveEndpoint);
        req.setMethod('POST');
        
        String body = 'client_id=' + EncodingUtil.urlEncode(System.Label.googleDriveClientId, 'UTF-8')
            + '&client_secret=' + EncodingUtil.urlEncode(System.Label.googleDriveClientSecret, 'UTF-8')
            + '&code=' + EncodingUtil.urlEncode(System.Label.googleDriveCode, 'UTF-8')
            + '&grant_type=' + EncodingUtil.urlEncode(System.Label.googleDrivegrantTypeAutharization, 'UTF-8')
            + '&redirect_uri=' + EncodingUtil.urlEncode(System.Label.googleDriveRedirectUri, 'UTF-8');
        
        req.setBody(body);  // Set the body of the request
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Content-Length', String.valueOf(body.length())); 
        
        HttpResponse res = http.send(req);
        
        if(res.getStatusCode() == 200){
            Map<String,Object> results =(Map<String,Object>) System.JSON.deserializeUntyped(res.getBody());
            System.debug('results'+results);
        } else {
            System.debug('Error: ' + res.getStatus() + ' - ' + res.getBody());
        }
    }
}