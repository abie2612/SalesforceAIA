@isTest
public class CustomerWebToLeadRelatedToAssetTest {
    @isTest static void testCallout() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CustomerWebToLeadRelatedToAsset';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"FirstName":"test lead","LastName":"customer","Email":"testdev@anavcloudsoftwares.com","TelephoneNumber":"7654345678"');
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        String status = CustomerWebToLeadRelatedToAsset.doPost();
        System.debug('status'+status);
        Test.stopTest();
        Assert.areEqual('{"Status":"OK"}',status,'Web not converted to Lead');
    }
}