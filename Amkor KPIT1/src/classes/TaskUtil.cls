/*************************************************************************
*
* PURPOSE: Utility class with some methods for creating tasks related to RFQ 
*          
*
* TRIGGER: RFQStatusUpdate
* CREATED: 7/2/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Nathan Pilkington
***************************************************************************/
public class TaskUtil {

    private static final String COUNTER_PROPOSAL_TYPE = 'Counter Proposal Follow Up';
    private static final String COUNTER_PROPOSAL_SUBJECT = 'Counter Proposal Follow Up';

	public static Task assignFollowUpForCounter(RFQ_Item__c item, Id userId) {

        RFQ__c rfq = RFQDao.getInstance().getRfqById(item.RFQ__c);       
        Task task = new Task();
        task.OwnerId = userId;
        task.WhatId = item.Id;
        task.Subject = COUNTER_PROPOSAL_SUBJECT;
        task.Type = COUNTER_PROPOSAL_TYPE;
        task.Description = 'You have a pending item that needs to be completed: ' + item.Name + ' for ' + rfq.Name;
        insert task;
        return task; 
    }

    public static Boolean hasCounterProposalTask(RFQ_Item__c item) {
        List<Task> taskList = [select Id,Subject from Task where WhatId =: item.Id and Type =: COUNTER_PROPOSAL_TYPE];
        return taskList.size() > 0;
    }

    public static void completeCounterProposalTasks(RFQ_Item__c item) {
    	List<Task> taskList = [select Id,Subject,Type from Task where WhatId =: item.Id and Type =: COUNTER_PROPOSAL_TYPE];
        for(Task t : taskList) {
        	t.Status = 'Completed';
        }
        update taskList; 
    }

    public static void completeCounterProposalTasks(List<String> itemIds) {
        List<Task> taskList = [select Id,Subject,Type from Task where WhatId in :itemIds and Type =: COUNTER_PROPOSAL_TYPE];
        for(Task t : taskList) {
            t.Status = 'Completed';
        }
        update taskList; 
    }

	

}