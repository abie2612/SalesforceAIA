/*
 * Author : AnavClouds Softwares Solutions (3 Jan 2024)
 * Description : This batch is using for update zoom meeting details
*/
public class BatchUpdateZoomMeeting implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    
    Set<Id> setOfEventIds = new Set<Id>();
    
	public BatchUpdateZoomMeeting(Set<Id> eventIdList) {
        
        setOfEventIds = eventIdList;
    }
    
	public Database.QueryLocator start(Database.BatchableContext BC) {
        
        String queryString = 'SELECT Id, Subject, StartDateTime, EndDateTime, Zoom_Meeting_Details__r.Meeting_Id__c FROM Event';
        
        if(!setOfEventIds.isEmpty()) {
            queryString += ' WHERE Id IN : setOfEventIds'; 
        }
        
        return Database.getQueryLocator(queryString);
    }
    
    public void execute(Database.BatchableContext BC, List<Event> eventData) {
        
        try {
            ZoomController.updateMeetingOnZoom(eventData[0]);
        } catch(Exception exp) {
            Exception__c e = UtilityController.getExceptionData(exp, exp.getTypeName(), 'BatchUpdateZoomMeeting.execute()');
            if(e != NULL) Database.insert(e);
        }
    }
    
    public void finish(Database.BatchableContext BC) {}
}