@isTest
public class CustomerWebToLeadTest {
    @isTest static void testCallout() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CustomerWebToLead';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"FirstName":"test lead","LastName":"customer","Email":"testdev@anavcloudsoftwares.com","TelephoneNumber":"7654345678","FBAorFBM":["FBA"],"StoreReviews":["10-100"],"HearAboutAIA":["Facebook"],"TypeOfAccount":["No Reserve (funds can be withdrawn immediately)"],"MonthlyTurnover":["$1000 - $4999"],"ExpertiseOnAmazon":["Beginner (0-2 yrs)"],"Budget":["$5000 - $10,000"],"WhatDoYouSell":["Branded"],"AdditionalInformation":"Additional_information__c"');
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        String status = CustomerWebToLead.doPost();
        System.debug('status'+status);
        Test.stopTest();
        Assert.areEqual('{"Status":"OK"}',status,'Web not converted to Lead');
    }
}