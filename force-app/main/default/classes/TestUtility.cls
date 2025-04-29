public class TestUtility {
    // Account
    public static Account getAccount(String accName) {
        return new Account(Name = accName);
    }
    // Contact
    public static Contact getContact(Account acc, String fName, String lName, String email) {
        return new Contact(AccountId = acc.Id, FirstName = fName, LastName = lName, Email = email);
    }
    //Event
    public static Event getEvent(String subject, DateTime startDateTime, DateTime endDateTime) {
        return new Event(Subject = subject,
                         StartDateTime = startDateTime,
                         EndDateTime = endDateTime);
    }
    //Zoom Meeting
    public static Zoom_Meeting__c getZoomMeeting(String subject, DateTime startDateTime, DateTime endDateTime, String MeetingId, String MeetingURL) {
        return new Zoom_Meeting__c(Subject__c = subject,
                                   Meeting_URL__c = MeetingURL,
                                   Meeting_Id__c = MeetingId,
                                   Start_Date_and_Time__c = startDateTime,
                                   End_Date_and_Time__c = endDateTime);
    }
    //Opportunity
    public static Opportunity getOpportunity(String name,Date closeDate,String stageName){
        return new Opportunity(Name = name,
                               CloseDate = closeDate,
                               StageName = stageName);
    }
    //Opportunity
    public static Opportunity getOpportunity(String name,Date closeDate,String stageName,String marketPlace,Id accountId){
        return new Opportunity(Name = name,
                               CloseDate = closeDate,
                               StageName = stageName,
                               Marketplace__c = marketPlace,
                               AccountId = accountId);
    }
    //Lead
    public static Lead getLead(String firstName,String lastName,String leadStatus,String company,String rating,String email){
        return new Lead(FirstName =firstName,
                        LastName = lastName,
                        Status = leadStatus,
                        Company = company,
                        Rating = rating,
                        Email = email);
    }
    //Event
    public static Event getEvent(Date activityDate,Integer durationInMinutes,Date activityDateTime){
        return new Event(ActivityDate = activityDate,
                         DurationInMinutes = durationInMinutes,
                         ActivityDateTime = activityDateTime);
    }
    //Contract
    public static Contract getContract(Id accountId,String status,Date contractStartDate,Integer contractTerm){
        return new Contract(AccountId = accountId,
                            Status = status,
                            StartDate = contractStartDate,
                            ContractTerm = contractTerm);
    }
    //Contract Content
    public static Contract_Content__c getContractContent(String name,String content){
        return new Contract_Content__c(Name = name,
                                       Content__c = content);
    }
    //DocuSign Status
    /*public static dsfs__DocuSign_Status__c getDocuSignStatus(String docuSignEnvelopeID){
return new dsfs__DocuSign_Status__c(dsfs__DocuSign_Envelope_ID__c = docuSignEnvelopeID);
}*/
    //Exception
    public static Exception__c getException(String controllerMethodName,String type,String exceptionMessage){
        return new Exception__c(Controller_Method_Name__c = controllerMethodName,
                                Type__c = type,
                                Exception_Message__c = exceptionMessage);
    }
    //Meeting Participant
    public static Meeting_Participant__c getMeetingParticipant(String regId,String meetingURL){
        return new Meeting_Participant__c(Registrant_ID__c = regId,
                                          Registrant_Meeting_URL__c = meetingURL);
    }
    
    //Task
    public static Task getTaskRecord(String sub,String descr){
        return new Task(Subject = sub,
                        Description = descr);
    }
    
    //Product
    public static Product2 getProduct(Id assetId, String name){
        return new Product2(Amazon_Asset__c = assetId, Name = name);
    }
    
    //Asset
    public static Asset getAsset(String name, Id accountId, Integer salePrice, Integer feedBack, Integer starsStoreFeedback, String brandApproved, String categoriesApproved, Integer salesHistoryAllTime, Integer salesHistoryYeartoDate, Integer overallUnitsSold, String marketplace, String additionalMarketplace, Date creationDate){
        return new Asset(Name = name,
            AccountId = accountId,
            Sale_Price__c = salePrice,
            Feedback__c = feedBack,
            Stars_Store_Feedback__c = starsStoreFeedback,
            Brands_approved__c = brandApproved,
            Categories_Approved__c = categoriesApproved,
            Sales_History_All_Time__c = salesHistoryAllTime,
            Sales_History_Year_to_Date__c = salesHistoryYeartoDate,
            Overall_Units_Sold__c = overallUnitsSold,
            Marketplace__c = marketplace,
            Additional_Marketplaces__c = additionalMarketplace,
            Creation_Date__c = creationDate);
            }
}