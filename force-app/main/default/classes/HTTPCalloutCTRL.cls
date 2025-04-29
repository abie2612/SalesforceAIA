public class HTTPCalloutCTRL
{
    Map<String,String> mapOfHeader = new Map<String,String>{'Content-Type' => 'application/json'};
    String method = 'GET';
    String body;
    String endPoint;
    
    //how to call
    //new HTTPCalloutCTRL().setEndPoint('').setMethod().setBody().makeCallout();
    public HttpResponse makeCallout()
    {
        HttpRequest req = new HttpRequest();
        // End Point
        req.setEndpoint(endPoint);
        // HTTP Method
        req.setMethod(method);
        // HTTP Body
        if(String.isNotBlank(body)) {
            req.setBody(body);
        }
        // Header
        if(!mapOfHeader.isEmpty()) {
            for(String hdr : mapOfHeader.keySet()) {
                req.setHeader(hdr, mapOfHeader.get(hdr));
            }
        }
        return new Http().send(req);
    }
    public HTTPCalloutCTRL setHeader(Map<String,String> headers) {
        mapOfHeader.putAll(headers);
        return this;
    }
    public HTTPCalloutCTRL setMethod(String method) {
        this.method = method;
        return this;
    }
    public HTTPCalloutCTRL setBody(String body) {
        this.body = body;
        return this;
    }
    public HTTPCalloutCTRL setEndPoint(String endPoint){
        this.endPoint = endPoint;
        return this;
    }
}