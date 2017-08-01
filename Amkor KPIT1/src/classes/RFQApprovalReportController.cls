public with sharing class RFQApprovalReportController {
	
    public class RFQApprovalHolder {

    	public String actorName {get; set;}
    	public String itemName {get; set;}
    	public String createdDate {get; set;}
    	public String packageFamily {get; set;}
    	public String productGroup {get; set;}
    	public String approvalComments {get; set;}
    	public String itemStatus {get; set;}
    	public String approvalStatus {get; set;}


    }

    public List<RFQApprovalHolder> approvals {get; set;}

	public RFQApprovalReportController() {
 
        Schema.DescribeSObjectResult dsr = RFQ_Item__c.SObjectType.getDescribe();
        String keyPrefix = dsr.getKeyPrefix();

        approvals = new List<RFQApprovalHolder>();
        Map<Id,ProcessInstanceStep> steps = new Map<Id,ProcessInstanceStep>();

        Map<Id,RFQ_Item__c> itemMap = new Map<Id,RFQ_Item__c>();
        List<ProcessInstanceStep> stepList = new List<ProcessInstanceStep>();
        for(ProcessInstanceStep step : [select Actor.Name,CreatedDate,Comments,StepStatus,ProcessInstance.TargetObject.Id from ProcessInstanceStep where StepStatus =: 'Approved' OR StepStatus=: 'Rejected']) {
            steps.put(step.ProcessInstance.TargetObject.Id,step);
            stepList.add(step);
        }

        itemMap = new Map<Id,RFQ_Item__c>([select Id,Name,Product_Group_Name__c,Package_Family__r.Name,Status__c from RFQ_Item__c where Id in: steps.keySet()]);

        for(ProcessInstanceStep step : stepList) {
            
            if(step.ProcessInstance != null && step.ProcessInstance.TargetObjectId != null && String.valueOf(step.ProcessInstance.TargetObject.Id).startsWithIgnoreCase(keyPrefix)) {
                RFQApprovalHolder holder = new RFQApprovalHolder();
                holder.actorName = step.Actor.Name;
                holder.approvalStatus = step.StepStatus;
                holder.approvalComments = step.Comments;
                holder.createdDate = step.CreatedDate.format();
                holder.itemName = itemMap.get(step.ProcessInstance.TargetObject.Id).Name;
                holder.itemStatus = step.StepStatus == 'Started' ? 'Price Pending BU Approval' : itemMap.get(step.ProcessInstance.TargetObject.Id).Status__c;
                holder.productGroup = itemMap.get(step.ProcessInstance.TargetObject.Id).Product_Group_Name__c;
                holder.packageFamily = itemMap.get(step.ProcessInstance.TargetObject.Id).Package_Family__r.Name;
                approvals.add(holder);
            }
            

		
        }
        
		
	}
}