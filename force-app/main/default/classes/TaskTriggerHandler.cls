public class TaskTriggerHandler {
    public static void beforeInsert(List<Task> taskList){
        Set<String> setOfLeadEmails = new Set<String>();
        for(Task task : taskList){
            String email = getEmailFromDescription(task);
            if(String.isNotBlank(email)){
                setOfLeadEmails.add(email);
            }
        }
        
        if(setOfLeadEmails.isEmpty()){
            return;
        }
        Map<String, Id> mapOfEmailAndLeadId = leadUpdate(setOfLeadEmails);
        if(!mapOfEmailAndLeadId.keySet().isEmpty()){
            for(Task task : taskList){
                String email = getEmailFromDescription(task);
                if(String.isNotBlank(email) && mapOfEmailAndLeadId != null && mapOfEmailAndLeadId.containsKey(email)){
                    task.WhoId = mapOfEmailAndLeadId.get(email);
                }
                task.OwnerId = UserInfo.getUserId();
            }
        }  
    }
    
    // Fetching lead emails from task Subject
    private static String getEmailFromDescription(Task task){
        if(String.isNotBlank(task.Subject) && task.Subject.contains('Apollo') && task.Subject.contains('<<') 
           && String.isNotBlank(task.Description) && task.Description.startsWith('From: ') && task.Description.contains('To: ')
           && String.isNotBlank(task.Description.substringBetween('From: ','To: '))){
               String email = task.Description.substringBetween('From: ','To: ').trim();
               return email;
           }
        return null;
    }
    
    // Lead Updates
    static Map<String, Id> leadUpdate(Set<String> setOfLeadEmails) {
        Map<String, Id> mapOfEmailAndLeadId = new Map<String, Id>();
        List<Lead> updateLeads = new List<Lead>();
        for(Lead ld : [SELECT Id, Name, Email, Lead_Stage__c, LeadSource FROM Lead WHERE Email IN: setOfLeadEmails AND IsConverted = false ORDER BY CreatedDate DESC]) {
            if(mapOfEmailAndLeadId != null && !mapOfEmailAndLeadId.containsKey(ld.Email) && String.isNotBlank(ld.LeadSource) && (ld.LeadSource == 'Web' ||ld.LeadSource == 'Plan B') && (ld.Lead_Stage__c== 'Apollo' || ld.Lead_Stage__c == null)){
                mapOfEmailAndLeadId.put(ld.Email, ld.Id);
                updateLeads.add(new Lead(Id = ld.Id, Lead_Stage__c = 'Lead Responded'));
            }
        }
        if(!updateLeads.isEmpty()) {
            UPDATE updateLeads;
        }
        return mapOfEmailAndLeadId;
    }
}