/*************************************************************************
*
* PURPOSE: A controller for a VF page to restrict reassignments to BU users only
*
* CLASS: RFQReassignController
* CREATED: 8/19/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Alex Molina
***************************************************************************/
public with sharing class RFQReassignController 
{
    public String comments {get; set;}
    public List<ProcessInstanceWorkItem> workItemList {get; set;}
    public ProcessInstanceWorkItem workItem {get; set;}
    public Boolean isApproverUser {get; set;}
    public String isUserStr {get; set;}
    private String retURL {get; set;}
    private String objectId {get; set;}
    private String assigner {get; set;}

    public RFQReassignController()
    {
        isApproverUser = true;
        objectId = ApexPages.currentPage().getParameters().get('id');
        retURL = ApexPages.currentPage().getParameters().get('retURL');
    }

    public PageReference loadAction()
    {
        workItemList = [Select p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId,p.ProcessInstance.TargetObject.Type,p.ProcessInstanceId,p.OriginalActorId,p.Id,p.ActorId, p.OriginalActor.Name, p.Actor.Name From ProcessInstanceWorkitem p where p.ProcessInstance.TargetObjectId =: objectId limit 1];
        if (workItemList != null && !workItemList.IsEmpty())
        {
            workItem = workItemList.get(0);
            assigner = workItem.Actor.Name; //-- Set the original Actor as assigner
        }
        
        return null;
    }

    public PageReference Reassign()
    { 
        if(workItem.ProcessInstance.TargetObject.Type == 'RFQ_Item__c')
        {
             
            if(isApproverUser) //We only care if the approve is a user (any queues can be assigned to)
            {
                List<User> userList = [select ProfileId from User where Id =: workItem.ActorId];
                if (userList != null && !userList.IsEmpty())
                {
                    User u = userList.get(0);
                    if(!RFQSystemSettings.getIsBUUser(u.ProfileId) && !RFQSystemSettings.getIsHybridUser(u.ProfileId)) //Only BU & Hybrid users can be assigned to
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'User is not a BU profile and cannot approve this RFQI'));
                        return null;
                    }
                }
            }
            RFQ_Item__c item = [select Id,SiP__c from RFQ_ITem__c where Id =: workItem.ProcessInstance.TargetObject.Id]; 
            //Salesforce 105 lalit singh 19/09/2016: Set SiP field to true when RFQi enters the SiP queue
            Set<Id> sipQueueIds = getSIPQueuesIds();
            if(sipQueueIds != null && sipQueueIds.contains(workItem.ActorId)){
                item.SiP__c = true;
            }              
            item.Reassigned__c = true;
            update item;
        }

        update workItem;            

        //-- Repeat the query to get the updated workItem / new Actor name (page only updates ActorId so we must perform query again)
        workItem = [Select p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId,p.ProcessInstance.TargetObject.Type,p.ProcessInstanceId, p.Actor.Name From ProcessInstanceWorkitem p where p.ProcessInstance.TargetObjectId =: objectId limit 1];

        if(workItem.ProcessInstance.TargetObject.Type == 'RFQ_Item__c'){ //-- Only need reporting on RFQ Items
            insert new RFQI_Reassignment__c(From__c = assigner, To__c = workItem.Actor.Name, RFQ_Item__c = workItem.ProcessInstance.TargetObjectId);
        }

        return new PageReference(retURL);
    }
    
    //Salesforce 105 lalit singh 19/09/2016: Set SiP field to true when RFQi enters the SiP queue
    public set<Id> getSIPQueuesIds(){
        set<Id> queueids = new set<Id>();
        string sipQueuestname = Label.Sip_Queues_names;
        list<string> queuenames = sipQueuestname.split(';');
        List<Group> lstOfQueues = [select Id from Group where Name in :queuenames  and Type = 'Queue'];
        system.debug('lstOfQueues####'+lstOfQueues);
        if(lstOfQueues!=null && lstOfQueues.size()>0){
            for(Group objGroup:lstOfQueues){
                queueids.add(objGroup.id);
            }
        }
        return queueids;
        
    }
    
    
    public PageReference Cancel()
    {
        return new PageReference(retURL);
    }

    public List<SelectOption> getQueuesList()
    {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new selectOption('', '-- None --'));
        for (QueueSobject  q : [Select q.Queue.Name, q.Queue.Id From QueueSobject q order by q.Queue.Name])
        {
            options.add(new SelectOption(q.Queue.Id,q.Queue.Name)); 
        }
        return options;
    }

    public PageReference updateIsUser()
    {
        if(isUserStr == 'User')
        {
            isApproverUser = true;
        }
        else 
            isApproverUser = false;
        return null;
    }
}