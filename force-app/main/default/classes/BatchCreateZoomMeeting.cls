/*
 * Author : AnavClouds Softwares Solutions (3 Jan 2024)
 * Description : This batch is using for create zoom meeting 
*/

public class BatchCreateZoomMeeting implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful
{
    Set<Id> setOfEventIds = new Set<Id>();
    
	public BatchCreateZoomMeeting(Set<Id> eventIds) {
        
        setOfEventIds = eventIds;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        String queryString = 'SELECT Id, Subject, StartDateTime, EndDateTime,WhoId, Zoom_Meeting_Details__r.Meeting_Id__c FROM Event';
        
        if(!setOfEventIds.isEmpty()) {
            queryString += ' WHERE Id IN : setOfEventIds'; 
        }        
        return Database.getQueryLocator(queryString);
    }
    
    public void execute(Database.BatchableContext BC, List<Event> eventData) {
        
        try {
            ZoomController.createZoomMeeting(eventData[0]);
        } catch(Exception exp) {
            Exception__c e = UtilityController.getExceptionData(exp, exp.getTypeName(), 'BatchCreateZoomMeeting.execute()');
            if(e != NULL) Database.insert(e);
        }
    }
    
    public void finish(Database.BatchableContext BC) {}
}