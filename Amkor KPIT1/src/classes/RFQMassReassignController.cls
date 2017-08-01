/*************************************************************************
* 
* PURPOSE: Controller for Mass Re-Assignment page
*          
* CLASS: RFQMassReassignController
* CREATED: 10/10/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/
public with sharing class RFQMassReassignController extends RFQItemsToApproveController {
    
    public String comments {get; set;}
    public List<ProcessInstanceWorkItem> workItemList {get; set;}
    public ProcessInstanceWorkItem workItem {get; set;}
    public Boolean isApproverUser {get; set;}
    public String isUserStr {get; set;}
    public RFQ_Item__c dummyRFQI {get; set;}
    private String retURL {get; set;}
    private String objectId {get; set;}
    private String assigner {get; set;}
    private String userKey;

    public RFQMassReassignController() {
        super();
        dummyRFQI = new RFQ_Item__c();
        userKey = User.SObjectType.getDescribe().getKeyPrefix();
    }

    public PageReference reassign() {
        
        if(!canReassignTouser()) {
            ApexPages.addmessage(
                                 new ApexPages.message(
                                 ApexPages.severity.ERROR, 'User is not a BU profile and cannot approve this RFQI')
                                 );
            return null;
        }
        doReassignmentUpdate();
        return goHome();
    }

    public void doReassignmentUpdate() {

        String newAssigneeName = getNewAssigneeName();

        List<ProcessInstanceWorkItem> workItems = new List<ProcessInstanceWorkItem>();
        List<RFQI_Reassignment__c> reAssignments = new List<RFQI_Reassignment__c>();
        for(ApprovalItemWrapper item : itemsToApprove) {
            
            if(item.isSelected) {
                if(item.workItem.ProcessInstance.TargetObject.Type == 'RFQ_Item__c') {
                    reAssignments.add(new RFQI_Reassignment__c(From__c = item.workItem.Actor.Name,To__c = newAssigneeName, RFQ_Item__c = item.workItem.ProcessInstance.TargetObjectId));
                }

                item.workItem.actorId = dummyRFQI.OwnerId;
                workItems.add(item.workItem);
            }
        }

        insert reAssignments;
        update workItems;
    }

    public PageReference goHome() {
        return new PageReference('/home/home.jsp');
    }

    private String getNewAssigneeName() {
        if(String.valueOf(dummyRFQI.OwnerId).toLowerCase().startsWith(userKey)) {
            User u = [select Name from User where Id =: dummyRFQI.OwnerId];
            return u.Name;
        }
        else {
            QueueSobject q = [select Queue.Name, Queue.Id from QueueSobject where Queue.Id =: dummyRFQI.OwnerId];
            return q.Queue.Name;
        }
        return '';
    }

    private Boolean canReassignTouser() {
        if(String.valueOf(dummyRFQI.OwnerId).toLowerCase().startsWith(userKey)) {
            User u = [select ProfileId from User where Id =: dummyRFQI.OwnerId];
            if(!RFQSystemSettings.getIsBUUser(u.ProfileId) && !RFQSystemSettings.getIsHybridUser(u.ProfileId)) {
                return false;
            }
        }
        return true;
    }

    
}