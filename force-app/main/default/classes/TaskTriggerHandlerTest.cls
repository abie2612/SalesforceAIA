@isTest
public class TaskTriggerHandlerTest {
    @isTest static void testBeforeInsert() {
        
        Lead lead = TestUtility.getLead('Test','Lead 1','New','TestCompany','Warm','test1@gmail.com');
        lead.Lead_Stage__c = 'Apollo';
        lead.LeadSource = 'Web';
        INSERT lead;
        
        Task newTask = new Task(Subject = '[Apollo] [Email] [<<] Re: Unlock Your Amazon Potential New',Description='From: test1@gmail.com To: test2@gmail.com Subject: Re: Unlock Your Amazon Potential Body:"test mail body !@#$%^&*()(*&^%$#@!@#$%^&*UYTRSASDFGHJKLJHFDSASDERT&*()OLKVGNJKL:"}|{}":><MNBVCXZqwertyuiokjhgfdsaSDFGHJKL><?><>:{P{_+_)(*&^%$#W@Q"');
        INSERT newTask;
        
    }
    
}