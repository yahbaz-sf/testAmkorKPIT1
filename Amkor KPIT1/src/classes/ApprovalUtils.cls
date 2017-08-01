/*************************************************************************
*
* PURPOSE: Methods for programatically working with approvals
*
* CLASS: ApprovalUtils
* CREATED: 3/12/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/
public class ApprovalUtils {

    public static String ACTION_APPROVE = 'Approve';
    public static String ACTION_REJECT = 'Reject';
    public static String ACTION_RECALL = 'Removed';

    /**
    * This method starts an approval process on any sObject an approval
    * process must exist in the system for this to work correctly
    * 
    */
	public static void startApproval(String objectId, String comment){
		Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
		app.setObjectId(objectId);
		app.setComments(comment);		
		Approval.ProcessResult result = Approval.process(app);
	}

    public static void startApprovals(List<String> objectIds, String comment)
    {
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
        for (String objectId : objectIds)
        {
            Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
            app.setObjectId(objectId);
            app.setComments(comment);   
            requests.add(app);
        }
        Approval.ProcessResult[] results = Approval.process(requests);
    }
	
	/**
         * This method gets the page reference to the standard approval wizard
         */
	public static PageReference getStandardApprovalWizard(String objectId) {
		
		/**List<ProcessInstanceWorkitem> wiList 
		   = [Select Id, ProcessInstance.Status, ProcessInstance.TargetObjectId, ProcessInstanceId 
		      From ProcessInstanceWorkitem where ProcessInstance.TargetObjectId = :objectId];

                if(wiList.size() == 0) return null; 
		Id piId = wiList[0].Id;**/
		return new PageReference('/apex/RFQProcessInstance?id='+objectId);
	}

    public static void approveRecord(Id workItemId, String approvalText) {
        processRecord(workItemId,approvalText,ACTION_APPROVE);
    }

    public static void approveRecords(Set<Id> workItemIds, String approvalText) {
        processRecords(workItemIds,approvalText,ACTION_APPROVE);
    }

    public static void rejectRecord(Id workItemId, String rejectionText) {
        processRecord(workItemId,rejectionText,ACTION_REJECT);
    }

    public static void recall(Id objectId) {
        Id workItemId = getProcessInstanceWorkItem(objectId);
        recallProcessInstanceRecord(workItemId);
    }

    public static void recallProcessInstanceRecord(Id workItemId) {
        recallProcessInstanceRecord(workItemId, 'recalled');
    }
    public static void recallProcessInstanceRecord(Id workItemId, String approvalText) {
        processRecord(workItemId,approvalText,ACTION_RECALL);
    }

    private static void processRecord(Id workItemId, String approvalText, String action) {
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments(approvalText);
        req.setAction(action); //This is the action that is approve in your case, you can set it to Reject also
        req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        system.debug('workItemId line number 83 ApprovalUtils class'+workItemId);
        req.setWorkitemId(workItemId);
        Approval.ProcessResult result =  Approval.process(req);
        System.debug('line number 86 ApprovalUtils class result: '+result);
    }

    private static void processRecords(Set<Id> workItemIds, String approvalText, String action) {
        List<Approval.ProcessWorkitemRequest> reqList = new List<Approval.ProcessWorkitemRequest>();
        for (Id workItemId : workItemIds)
        {
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments(approvalText);
            req.setAction(action); //This is the action that is approve in your case, you can set it to Reject also
            req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req.setWorkitemId(workItemId);
            reqList.add(req);
        }
        Approval.ProcessResult[] result =  Approval.process(reqList);

    }

    public static void recallItems(Set<String> ids, String approvalText)
    {
        Set<Id> workItemIds = getProcessInstanceWorkItems(ids);
        for (Id itemId : workItemIds)
        {
            recallProcessInstanceRecord(itemId, approvalText);
        }
    }

	public static Boolean isUnderApproval(String objectId) {
		
	    List<ProcessInstanceWorkitem> wiList 
		    = [Select Id, ProcessInstance.Status, ProcessInstance.TargetObjectId, ProcessInstanceId 
		       From ProcessInstanceWorkitem where ProcessInstance.TargetObjectId = :objectId];

            return wiList.size() != 0;
		
	}

    public static Map<String, Boolean> bulkIsUnderApproval (Set<String> objectIds)
    {
        List<ProcessInstanceWorkitem> wiList 
            = [Select Id, ProcessInstance.Status, ProcessInstance.TargetObjectId, ProcessInstanceId 
               From ProcessInstanceWorkitem where ProcessInstance.TargetObjectId in :objectIds];   
        Map<String, String> wiMap = new Map<String, String>();
        Map<String, Boolean> isUnderApprovalMap = new Map<String, Boolean>();
        for (ProcessInstanceWorkitem wi : wiList)
        {
            wiMap.put(wi.ProcessInstance.TargetObjectId, wi.Id);
        }

        for (String objId : objectIds)
        {
            isUnderApprovalMap.put(objId, wiMap.get(objId) != null);
        }
        return isUnderApprovalMap;
    }

    public static Id getProcessInstanceWorkItem(String objectId){
        List<ProcessInstanceWorkitem> wiList 
            = [Select Id, ProcessInstance.Status, ProcessInstance.TargetObjectId, ProcessInstanceId 
               From ProcessInstanceWorkitem where ProcessInstance.TargetObjectId = :objectId];

            if(wiList.size() != 0){
                return wiList[0].Id;  
            }
            return null;
    }

    public static Set<Id> getProcessInstanceWorkItems(Set<String> objectIds)
    {
        Map<Id, sObject> wiList 
            = new Map<Id, sObject>([Select Id, ProcessInstance.Status, ProcessInstance.TargetObjectId, ProcessInstanceId 
               From ProcessInstanceWorkitem where ProcessInstance.TargetObjectId in :objectIds]);

        return wiList.keySet();
    }

    public static Id getPendingProcessInstanceAssignee(String objectId){
        List<ProcessInstanceWorkitem> wiList 
            = [Select Id, ProcessInstance.Status, ProcessInstance.TargetObjectId, ProcessInstanceId, ActorId 
               From ProcessInstanceWorkitem where ProcessInstance.TargetObjectId = :objectId AND ProcessInstance.Status='Pending'];

            if(wiList.size() != 0){
                return wiList[0].ActorId;  
            }
            return null;
    }

    public static Boolean getUserCanApprove(String objectId)
    {
        Id assId = getPendingProcessInstanceAssignee(objectId);

        if (assId == null) return false; 

        Id userId = UserInfo.getUserId();

        return assId == userId || [SELECT UserOrGroupId FROM GroupMember WHERE GroupId=: assId AND UserOrGroupId =: userId].size() > 0;
        
    }

    public static List<ApprovalItemWrapper> getItemsToApprove() {
        
        List<ApprovalItemWrapper> itemsToApprove = new List<ApprovalItemWrapper>();

        List<GroupMember> groupIds = [select GroupId From GroupMember where UserOrGroupId =:UserInfo.getUserId()];
    
        List<String> actorIds = new List<String>();
        for(GroupMember gp : groupIds) {
            actorIds.add(gp.GroupId);
        }
        actorIds.add(UserInfo.getUserId());
    
        List<ProcessInstanceWorkItem> procItems = [select processinstance.targetobjectid,
                                                          processinstance.targetobject.name,
                                                          processinstance.targetobject.type,
                                                          CreatedDate,actorId,actor.Name 
                                                          from processinstanceworkitem where actorid  
                                                          in: actorIds order by 
                                                          processinstance.targetobject.name desc];

        List<Id> rfqItemIds = new List<Id>();
        for(ProcessInstanceWorkItem workItem : procItems) {
            if(workItem.processinstance.targetobject.type == 'RFQ_Item__c') {
                itemsToApprove.add(new ApprovalItemWrapper(workItem,workItem.processinstance ));
                rfqItemIds.Add(workItem.processinstance.targetobjectid);
            }
        }
        
        Map<Id,RFQ_Item__c> rfqItemsMap = new Map<Id,RFQ_Item__c>([select Id,Product_Group_Name__c,Package_Family__r.Name,Volume__c,
                                                                          Customer_Target_Price__c,OwnerId, Status__c,RFQ__r.Name,
                                                                          RFQ__r.SBU_Name__r.Name, Project_Device__c, Volume_Per_Week__c, 
                                                                          BU_Price__c, Dim_XY__c, Leads__c, Wire_Type_And_Diameter__c, 
                                                                          Total_Perc_GM__c, Factory__c, Mold_Type__c, Number_Of_Die__c,
                                                                          Number_Of_Wires__c, Total_Wire_Length__c, 
                                                                          RFQ__r.SBU_Name__r.Customer_AU_Base_fml__c, Heatspreader__c, Forecast__c
                                                                   from RFQ_Item__c where Id in:rfqItemIds]);
 
       for(ApprovalItemWrapper item : itemsToApprove) {
           item.rfqItem = rfqItemsMap.get(item.pInst.targetobjectid);
       }

       return itemsToApprove;
    } 
}