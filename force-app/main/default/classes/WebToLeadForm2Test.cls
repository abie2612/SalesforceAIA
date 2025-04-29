@isTest
public class WebToLeadForm2Test {
    @isTest static void testCallout() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/WebToLeadForm2';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"your-first-name":"test AIA lead 9 april","your-last-name":"testing","your-email":"testing10@anavcloudsoftwares.com","your-phone":"9876545678","dat":"2008-03-09","your-sss":"FD324567","your-marketplace":["Amazon.com","Amazon.UK","Amazon.EU"],"radio-433":["Yes"],"radio-43":["Yes"],"radio-4":["Yes"],"add":"testing the form 5","acceptance-504":[],"submitted_from":133,"submit_time":"2024-04-09 09:29:18","User_IP":"27.58.64.85"}');
        req.addParameter('your-marketplace', '["Amazon.com","Amazon.UK","Amazon.EU"]');
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        String status = WebToLeadForm2.doPost();
        Test.stopTest();
        Assert.areEqual('{"Status":"OK"}',status,'Web not converted to Lead');
    }
}