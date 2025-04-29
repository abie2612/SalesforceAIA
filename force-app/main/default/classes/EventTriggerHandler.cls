public class EventTriggerHandler {
    
    // On After Insert
    public static void onAfterInsert(List<Event> newEventList) {
        
        Set<Id> setOfEventIds = new Set<Id>();
        
        for(Event evt : newEventList) {
            
            if(evt.StartDateTime != NULL && evt.EndDateTime != NULL && String.isNotBlank(evt.Subject)) {
                setOfEventIds.add(evt.Id);
            }
        }
        
        // Creating Zoom Meeting
        if(!setOfEventIds.isEmpty()) {
            Database.executeBatch(new BatchCreateZoomMeeting(setOfEventIds), 1);
        }
    }
    
    // On After Update
    public static void onAfterUpdate(List<Event> newEventList, Map<Id,Event> oldMap) {
        
        Set<Id> setOfEventIds = new Set<Id>();
        for(Event evt : newEventList) {
            if(evt.StartDateTime != NULL && evt.EndDateTime != NULL && String.isNotBlank(evt.Subject) && 
               (
                   evt.StartDateTime != oldMap.get(evt.Id).StartDateTime || 
                   evt.EndDateTime != oldMap.get(evt.Id).EndDateTime ||
                   evt.Subject != oldMap.get(evt.Id).Subject
               )
              ) {
                  setOfEventIds.add(evt.Id);
              }
        }
        
        // Updating Zoom Meeting
        if(!setOfEventIds.isEmpty()) {
            Database.executeBatch(new BatchUpdateZoomMeeting(setOfEventIds), 1);   
        }
    }
    
    // On After Delete
    public static void onBeforeDelete(List<Event> EventList){
        Set<Id> setOfZoomMeetingIds = new Set<Id>();
        for(Event evt : EventList) {
            if(evt != null && evt.Zoom_Meeting_Details__c != NULL)
            {
                setOfZoomMeetingIds.add(evt.Zoom_Meeting_Details__c);
            }
        }
        // Deleting Zoom Meeting
        if(!setOfZoomMeetingIds.isEmpty()) {
            Database.executeBatch(new BatchDeleteZoomMeeting(setOfZoomMeetingIds), 1);   
        }
    }
}