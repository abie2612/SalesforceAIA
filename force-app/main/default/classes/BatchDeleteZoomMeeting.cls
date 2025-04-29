/*
 * Author : AnavClouds Softwares Solutions (3 Jan 2024)
 * Description : This batch is using for delete zoom meeting details
*/
public class BatchDeleteZoomMeeting implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
	
    Set<Id> setOfZoomMeetingIds = new Set<Id>();
    List<Zoom_Meeting__c> zoomMeetingsToBeDeleted = new List<Zoom_Meeting__c>();
    
	public BatchDeleteZoomMeeting(Set<Id> zoomMeetingIdList) {
        
        setOfZoomMeetingIds = zoomMeetingIdList;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        String queryString = 'SELECT Id, Name, Meeting_URL__c, Meeting_Id__c FROM Zoom_Meeting__c';
        
        if(!setOfZoomMeetingIds.isEmpty()) {
            queryString += ' WHERE Id IN : setOfZoomMeetingIds'; 
        }
        //queryString += ' LIMIT 49999';
        
        return Database.getQueryLocator(queryString);
    }
    
    public void execute(Database.BatchableContext BC, List<Zoom_Meeting__c> zoomMeetingData) {
        
        try {
            ZoomController.deleteMeetingOnZoom(zoomMeetingData[0]);
            zoomMeetingsToBeDeleted.add(zoomMeetingData[0]);
        } catch(Exception exp) {
            Exception__c e = UtilityController.getExceptionData(exp, exp.getTypeName(), 'BatchDeleteZoomMeeting.execute()');
            if(e != NULL) Database.insert(e);
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        if(!zoomMeetingsToBeDeleted.isEmpty()){
            DELETE zoomMeetingsToBeDeleted;
        }
    }
    
}