/*************************************************************************
*
* PURPOSE: Data access and manipulation for RFQI_Status_History__c
*
* CLASS: RFQIStatusHistoryDao
* CREATED: 11/11/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Austin Delorme
***************************************************************************/
public with sharing class RFQIStatusHistoryDao extends BaseDao
{
    
    private static final RFQIStatusHistoryDao rfqiStatusHistoryDao = new RFQIStatusHistoryDao();

    private static final Set<String> programStatuses = new Set<String>
    {
        RFQItemDao.STATUS_PROGRAM_WIN,
        RFQItemDao.STATUS_PROGRAM_LOSS,
        RFQItemDao.STATUS_PROGRAM_CANCELED,
        'Program Win',
        'Program Loss',
        'Program Cancelled'
    };

    private RFQIStatusHistoryDao() 
    {
        super('RFQI_Status_History__c'); 
    }

    public static RFQIStatusHistoryDao getInstance() 
    {
        return rfqiStatusHistoryDao;
    }

    public RFQI_Status_History__c newStatusHistory(RFQ_Item__c rfqItem)
    {
        return newStatusHistory(rfqItem, true);
    }

    public RFQI_Status_History__c newStatusHistory(RFQ_Item__c rfqItem, Boolean shouldInsert)
    {
        RFQI_Status_History__c hist = new RFQI_Status_History__c(RFQ_Item__c=rfqItem.Id, Status__c=RFQItemDao.STATUS_NEW, Date__c=DateTime.now().addHours(-7), User__c=UserInfo.getUserId());
        if (shouldInsert) insert hist;
        return hist;
    }

    public void updateStatusHistory(RFQItemWrapper wrapper)
    {
        List<RFQI_Status_History__c> insertList = new List<RFQI_Status_History__c>();
        updateStatusHistory(wrapper, insertList);
        insert insertList;

    }

    public void updateStatusHistory(RFQItemWrapper wrapper, List<RFQI_Status_History__c> insertList)
    {
        //do not create another history if the new status is equal to the current one (e.g. when recall)
        if (wrapper.statusHistories != null) 
        {
            if(wrapper.statusHistories.size() > 0)
            {
                RFQI_Status_History__c prevHist = wrapper.statusHistories[wrapper.statusHistories.size() - 1];
                if (wrapper.rfqItem.Status__c != prevHist.Status__c)
                {
                    RFQI_Status_History__c hist = new RFQI_Status_History__c(RFQ_Item__c=wrapper.rfqItem.Id, Status__c=wrapper.rfqItem.Status__c, Date__c=DateTime.now().addHours(-7), User__c=UserInfo.getUserId());
                    hist.Previous_Status__c = prevHist.Id;
                    insertList.add(hist);
                    wrapper.statusHistories.add(hist);
                }
            }
        }
        //RFQStatusHistory.trigger may pass in null liists if the wrapper has no status histories
        else
        {
            wrapper.statusHistories = new List<RFQI_Status_History__c>();
            RFQI_Status_History__c hist = new RFQI_Status_History__c(RFQ_Item__c=wrapper.rfqItem.Id, Status__c=wrapper.rfqItem.Status__c, Date__c=DateTime.now().addHours(-7), User__c=UserInfo.getUserId());
            insertList.add(hist);
            wrapper.statusHistories.add(hist);
        }
    }

    public void deleteStatusHistory(RFQItemWrapper wrapper, List<RFQI_Status_History__c> deleteList)
    {

        if (wrapper.statusHistories != null && wrapper.statusHistories.size() > 0)
        {
            //delete all status histories that are after the wrapper's status
            //used  when recalling, to delete excess records
            Integer i = wrapper.statusHistories.size() - 1;
            RFQI_Status_History__c hist = wrapper.statusHistories[i];
            while (i > 0 && wrapper.rfqItem.Status__c != hist.Status__c)
            {
                deleteList.add(wrapper.statusHistories[i]);
                hist = wrapper.statusHistories[--i]; 
            }
        }
    }

    public void deleteStatusHistoryWhenRecalled(RFQItemWrapper wrapper)
    {
        delete wrapper.statusHistories[wrapper.statusHistories.size() - 1];
    }

    public List<RFQI_Status_History__c> getByRfqItemIds(Set<String> rfqItemIds)
    {
        return (List<RFQI_Status_History__c>) getSObjectByIdSet('RFQ_Item__c', rfqItemIds, null, 'Date__c ASC');

    }

    public List<RFQI_Status_History__c> getByRfqItems(Set<String> rfqItemIds)
    {

        return (List<RFQI_Status_History__c>) getSObjectByIdSet('RFQ_Item__c', rfqItemIds);

    }

    public void bulkUpdateTimes(Set<Id> rfqItemSet, Boolean isInsert)
    {

        //Dynamic soql here to use rfqItemSet
        String soql = 'SELECT Id, Name, Date__c, RFQ_Item__r.Package_Family__r.Sales_Requires_Pre_Approval__c, RFQ_Item__r.Package_Family__r.Product_Group__r.Sales_Requires_Pre_Approval__c, Previous_Status__c, Previous_Status__r.Status__c, RFQ_Item__c, Status__c, User_Role__c, Time_From_Created__c, Time_From_Submitted__c, Time_From_Sales_Approve__c, Time_From_BU_Returned__c, Time_From_Quoted__c, Time_From_Program_Status__c, Time_From_Production_Status__c, Time_From_Escalated__c, Time_From_Escalated_BU_Response__c FROM RFQI_Status_History__c WHERE RFQ_Item__r.Id IN :rfqItemSet ORDER BY RFQ_Item__c ASC';
        List<RFQI_Status_History__c> historyList = (List<RFQI_Status_History__c>)Database.query(soql);
        
        Map<Id, List<RFQIStatusHistoryWrapper>> itemMap = new Map<Id, List<RFQIStatusHistoryWrapper>>();
        for (Id row : rfqItemSet) itemMap.put(row, new List<RFQIStatusHistoryWrapper>());
        Map<Id, Map<String, String>> itemStatusMap = new Map<Id, Map<String, String>>();

        for (RFQI_Status_History__c history : historyList)
        {
            itemMap.get(history.RFQ_Item__c).add(new RFQIStatusHistoryWrapper(history));
            
            if (itemStatusMap.get(history.RFQ_Item__c) == null)
            {
                itemStatusMap.put(history.RFQ_Item__c, 
                new Map<String, String> 
                {
                    RFQItemDao.STATUS_NEW => 'Time_From_Created__c',
                    RFQItemDao.STATUS_DRAFT => 'Time_From_Created__c',
                    RFQItemDao.STATUS_PRICE_SUBMIT => 'Time_From_Created__c',
                    RFQItemDao.STATUS_SALES_REQ_PREAPPROVAL => 'Time_From_Submitted__c',
                    RFQItemDao.STATUS_PRICE_COMPLETE => 'Time_From_Submitted__c',
                    RFQItemDao.STATUS_PRICE_DECLINED => 'Time_From_Submitted__c',
                    RFQItemDao.STATUS_QUOTED => 'Time_From_BU_Returned__c',
                    //Bhanu - 29-June-2016 : Salesforce 69 - New Opportunity STAGE changes, Adding Set as Qual button and removing obsolete Status
                    //Mapped newly created field 'Time_From_Qual__c', for QUAL status
                    RFQItemDao.STATUS_Qual => 'Time_From_Qual__c',
                    
                    /* RFQItemDao.STATUS_WON_PROTOTYPE => 'Time_From_Quoted__c',
                    RFQItemDao.STATUS_WON_QUALIFICATION => 'Time_From_Won_Prototype__c', */
                    RFQItemDao.STATUS_PROGRAM_WIN => 'Time_From_Quoted__c',
                    RFQItemDao.STATUS_PROGRAM_LOSS => 'Time_From_Quoted__c',
                    RFQItemDao.STATUS_PROGRAM_CANCELED => 'Time_From_Quoted__c',
                    'Program Win' => 'Time_From_Quoted__c',
                    'Program Loss' => 'Time_From_Quoted__c',
                    'Program Canceled' => 'Time_From_Quoted__c',
                    RFQItemDao.STATUS_PRODUCTION_WIN => 'Time_From_Production_Status__c',
                    RFQItemDao.STATUS_PRICE_ESCALATION => 'Time_From_BU_Returned__c'
                });
                
                if (history.RFQ_Item__r.Package_Family__r.Sales_Requires_Pre_Approval__c || history.RFQ_Item__r.Package_Family__r.Product_Group__r.Sales_Requires_Pre_Approval__c)
                {
                    itemStatusMap.get(history.RFQ_Item__c).put(RFQItemDao.STATUS_PRICE_PENDING_BU, 'Time_From_Sales_Approve__c');
                }
                else 
                {
                    itemStatusMap.get(history.RFQ_Item__c).put(RFQItemDao.STATUS_PRICE_PENDING_BU, 'Time_From_Submitted__c');
                }
            }
        }
        for (Id rfqId : rfqItemSet)
        {
            List<RFQIStatusHistoryWrapper> histList = itemMap.get(rfqId);
            if (histList.size() > 0)
            {
                //RFQIStatusHistoryWrapper is used so this can be sorted here by status
                histList.sort();

                RFQIStatusHistoryWrapper histWrapper;
                RFQIStatusHistoryWrapper oldHistWrapper;
                Map<String, String> statusMap = itemStatusMap.get(rfqId);
                //each index keeps track of how long it has been since a specific status (e.g. it maps to a field like Time_from_Created__c)
                Decimal[] allTotals = new Decimal[statusMap.size()];
                allTotals[0] = null;

                //loop through all histories in the list
                for (Integer i = 1; i < histList.size(); i++)
                {
                    oldHistWrapper = histList[i - 1];
                    histWrapper = histList[i];
                    Decimal timeDiff =  (histWrapper.history.Date__c.getTime() - oldHistWrapper.history.Date__c.getTime())/1000.0/60/60/24;

                    //set to make sure that only the reportable statuses in the array have indexes
                    Set<String> calculatedFields = new Set<String>();

                    //add the first field manually because it will always be the "new"s status, and loop depends on having the previous history
                    String field = statusMap.get(histList[0].history.Status__c);
                    calculatedFields.add(field);
                    //set first index in array to timeDiff
                    allTotals[0] = ((allTotals[0] == null) ? 0 : allTotals[0]) + timeDiff;
                    //record value to correct field on record
                    histWrapper.history.put(field, allTotals[0]);

                    //loop through all previous histories to get values for fields
                    for (Integer j = 1; j <= i; j++)
                    {
                        
                        field = getStatusField(histList[j], histList[j - 1], statusMap);
                        if (!calculatedFields.contains(field))
                        {
                            calculatedFields.add(field);
                            allTotals[calculatedFields.size()] = ((allTotals[calculatedFields.size()] == null) ? 0 : allTotals[calculatedFields.size()]) + timeDiff;
                            //Salesforce-136 :(RFQi 00057111 status will change will not save) Lalit : adding null check.
                            if(String.isNotBlank(field)){
                                histWrapper.history.put(field, allTotals[calculatedFields.size()]);
                            }
                        }
                        else
                        {
                            //if previous status maps to same field, then add value in that field
                            if (j > 1)
                            {
                                String prevfield = getStatusField(histList[j - 1], histList[j - 2], statusMap);

                                //put the value in the appropriate field if the statuses are equal (e.g. program win/loss)
                                if (RFQItemDao.getInstance().statusEqual(histList[j].history.Status__c, histList[j - 1].history.Status__c))
                                {
                                    field =  getStatusField(histWrapper, oldHistWrapper, statusMap);
                                    //Salesforce-136 :(RFQi 00057111 status will change will not save) Lalit : adding null check.
                                    if(String.isNotBlank(field)){
                                        histWrapper.history.put(field, timeDiff);
                                    }
                                }
                                else if (field == prevfield)
                                {
                                    //update the array index with the amount of time it took to get to this status record
                                    allTotals[calculatedFields.size()] = (allTotals[calculatedFields.size()] == null ? 0 : allTotals[calculatedFields.size()]) + (Decimal)histList[j - 1].history.get(prevfield);
                                    timeDiff += (Decimal)histList[j - 1].history.get(prevfield);
                                }
                            }
                        } 
                    }   
                }
            }
        }
        if (isInsert) 
        {
            //afterInsert is needed on trigger because IDs are needed
            //so update items if inserted
            update historyList;
        }

    }

    private String getStatusField(RFQIStatusHistoryWrapper histWrapper, RFQIStatusHistoryWrapper oldHistWrapper, Map<String, String> statusMap)
    {
        String field = statusMap.get(histWrapper.history.Status__c);


        if (oldHistWrapper != null)
        {

            if (histWrapper.history.Status__c == RFQItemDao.STATUS_QUOTED && oldHistWrapper.history.Previous_Status__r.Status__c == RFQItemDao.STATUS_PRICE_ESCALATION) field = 'Time_From_Escalated_BU_Response__c';
            else if (histWrapper.history.Status__c == RFQItemDao.STATUS_PRICE_COMPLETE && oldHistWrapper.history.Status__c == RFQItemDao.STATUS_PRICE_ESCALATION) field = 'Time_From_Escalated__c';
            else if (programStatuses.contains(histWrapper.history.Status__c))
            {   
                //Bhanu 29-June-2016 Salesforce - 69
                /* if (oldHistWrapper.history.Status__c == RFQItemDao.STATUS_WON_PROTOTYPE) field = 'Time_From_Won_Prototype__c';
                else if (oldHistWrapper.history.Status__c == RFQItemDao.STATUS_WON_QUALIFICATION) field = 'Time_From_Won_Qualification__c'; */
                
                if (oldHistWrapper.history.Status__c == RFQItemDao.STATUS_Qual) field = 'Time_From_Qual__c';
                
                //if the previous and current status are the program statuses
                else if (programStatuses.contains(oldHistWrapper.history.Status__c)) field = 'Time_From_Program_Status__c';
                //AMK-2539, statuses can go from price complete to program statuses
                else if (oldHistWrapper.history.Status__c == 'Price Complete') field = 'Time_From_BU_Returned__c';
            }
            else if (oldHistWrapper.history.Status__c == 'Price Complete')
            {
                //AMK-2539, statuses can go from price complete to program statuses
                //Bhanu 29-June-2016 Salesforce - 69
                /* if (histWrapper.history.Status__c == RFQItemDao.STATUS_WON_PROTOTYPE) field = 'Time_From_BU_Returned__c';
                else if (histWrapper.history.Status__c == RFQItemDao.STATUS_WON_QUALIFICATION) field = 'Time_From_BU_Returned__c'; */
                
                if (histWrapper.history.Status__c == RFQItemDao.STATUS_Qual) field = 'Time_From_Qual__c';
            }
        }

        return field;
    }

    public static void AMK1719()
    {
        Map<Id, RFQ_Item__c> itemMap = new Map<Id, RFQ_Item__c>([Select Id from RFQ_Item__c]);
        Set<Id> idList = itemMap.keySet();
        List<ProcessInstanceStep> processSteps = [Select Id, ProcessInstance.TargetObjectId, StepStatus, Comments, CreatedDate FROM ProcessInstanceStep WHERE ProcessInstance.TargetObjectId in :idList ORDER BY ProcessInstance.TargetObjectId];

        Map<Id, List<ProcessInstanceStep>> instanceMap = new Map<Id, List<ProcessInstanceStep>>();

        for (Id rfqId : idList) instanceMap.put(rfqId, new List<ProcessInstanceStep>());

        for (ProcessInstanceStep processStep : processSteps)
        {
            instanceMap.get(processStep.ProcessInstance.TargetObjectId).add(processStep);
        }

        List<RFQI_Status_History__c> histList = new List<RFQI_Status_History__c>();
        RFQI_Status_History__c submitStatus, approveStatus;
        Boolean hasApproved = false;
        for (Id itemId : instanceMap.keySet())
        {
            List<ProcessInstanceStep> procList = instanceMap.get(itemId);
            for (ProcessInstanceStep proc : procList)
            {
                if (proc.StepStatus == 'Approved')
                {
                    //get the earliest ProcessInstance (there may be multiple, e.g. escalations)
                    if (approveStatus == null || (proc.CreatedDate < approveStatus.Date__c))
                    {
                        approveStatus = new RFQI_Status_History__c(RFQ_Item__c=itemId, Status__c=RFQItemDao.STATUS_PRICE_COMPLETE, Date__c=proc.CreatedDate);
                    }
                    hasApproved = true;
                }
                else if (proc.StepStatus == 'Started' || proc.StepStatus == 'Submitted') 
                {
                    if (submitStatus == null || (proc.CreatedDate < submitStatus.Date__c))
                    {
                        submitStatus = new RFQI_Status_History__c(RFQ_Item__c=itemId, Status__c=RFQItemDao.STATUS_PRICE_PENDING_BU, Date__c=proc.CreatedDate);
                    }
                }
            }
            if (hasApproved)
            {
                histList.add(approveStatus);
                histList.add(submitStatus);
            }

            submitStatus = null;
            approveStatus = null;
            hasApproved = false;
        }

        insert histList;
    }

    public static void AMK1842()
    {
        Map<Id, RFQI_Status_History__c> histMap = new Map<Id, RFQI_Status_History__c>([SELECT Id, User__c, RFQ_Item__c FROM RFQI_Status_History__c WHERE User__c='' AND Status__c=:RFQItemDao.STATUS_PRICE_COMPLETE]);
        Set<Id> itemIds = new Set<Id>();

        for (RFQI_Status_History__c hist : histMap.values()) itemIds.add(hist.RFQ_Item__c);

        List<ProcessInstanceStep> processSteps = [Select Id, ProcessInstance.TargetObjectId, ActorId, OriginalActorId, StepStatus, Comments, CreatedDate FROM ProcessInstanceStep WHERE ProcessInstance.TargetObjectId in :itemIds and StepStatus='Approved' ORDER BY ProcessInstance.TargetObjectId];

        Map<Id, Id> itemUserMap = new Map<Id, Id>();
        for (ProcessInstanceStep proc : processSteps) itemUserMap.put(proc.ProcessInstance.TargetObjectId, proc.ActorId);


        for (RFQI_Status_History__c hist : histMap.values())
        {
            hist.User__c = itemUserMap.get(hist.RFQ_Item__c);
        }

        update histMap.values();

    }

    public static void AMK1843()
    {
        Map<Id, RFQ_Item__c> itemMap = new Map<Id, RFQ_Item__c>([SELECT Id, Status__c, LastModifiedDate, LastModifiedById FROM RFQ_Item__c WHERE Status__c=:RFQItemDao.STATUS_QUOTED]);
        List<RFQI_Status_History__c> insertList = new List<RFQI_Status_History__c>();


        List<RFQI_Status_History__c> histories = [SELECT Id, Status__c, RFQ_Item__c FROM RFQI_Status_History__c WHERE RFQ_Item__c in :itemMap.keySet() ORDER BY RFQ_Item__c];

        Set<Id> ignoreSet = new Set<Id>();
        Map<Id, Id> prevStatusMap = new Map<Id, Id>();

        for (RFQI_Status_History__c hist : histories)
        {
            //do not add quoted records if the item already contains one
            if (hist.Status__c == RFQItemDao.STATUS_QUOTED)
            {
                ignoreSet.add(hist.RFQ_Item__c);
            }
            //set the previous history as the price complete record
            else if (hist.Status__c == RFQItemDao.STATUS_PRICE_COMPLETE)
            {
                prevStatusMap.put(hist.RFQ_Item__c, hist.Id);
            }
        }

        //add a new history with quoted status if the item does not have a quoted status already
        for (RFQ_Item__c item : itemMap.values())
        {
            if (!ignoreSet.contains(item.Id)) insertList.add(new RFQI_Status_History__c(RFQ_Item__c=item.Id, Status__c=RFQItemDao.STATUS_QUOTED, Date__c=item.LastModifiedDate, User__c=item.LastModifiedById, Previous_Status__c=prevStatusMap.get(item.Id)));
        }

        insert insertList;
        for (RFQI_Status_History__c hist : insertList) DebugUtils.write('hist.Id', hist.Id);
    }

    public static void AMK1846()
    {
        Map<Id, RFQ_Item__c> itemMap = new Map<Id, RFQ_Item__c>([SELECT Id, Status__c, CreatedDate, CreatedById FROM RFQ_Item__c ]);
        List<RFQI_Status_History__c> insertList = new List<RFQI_Status_History__c>();
        List<RFQI_Status_History__c> updateList = new List<RFQI_Status_History__c>();
        Map<Id, RFQI_Status_History__c> prevStatusMap = new Map<Id, RFQI_Status_History__c>();


        List<RFQI_Status_History__c> histories = [SELECT Id, Status__c, RFQ_Item__c FROM RFQI_Status_History__c WHERE RFQ_Item__c in :itemMap.keySet() ORDER BY RFQ_Item__c];
        Set<Id> ignoreSet = new Set<Id>();

        for (RFQI_Status_History__c hist : histories)
        {
            //do not add quoted records if the item already contains one
            if (hist.Status__c == RFQItemDao.STATUS_NEW)
            {
                ignoreSet.add(hist.RFQ_Item__c);
            }
            else if (hist.Status__c == RFQItemDao.STATUS_PRICE_PENDING_BU)
            {
                prevStatusMap.put(hist.RFQ_Item__c, hist);
            }
        }

        for (RFQ_Item__c item : itemMap.values())
        {
            if (!ignoreSet.contains(item.Id))
            {
                insertList.add(new RFQI_Status_History__c(RFQ_Item__c=item.Id, Status__c=RFQItemDao.STATUS_NEW, Date__c=item.CreatedDate, User__c=item.CreatedById, Time_From_Created__c=0));
            }
        }

        insert insertList;

        RFQI_Status_History__c oldHist;
        for (RFQI_Status_History__c hist : insertList)
        {
            DebugUtils.write('insertHist.Id', hist.Id);
            if (prevStatusMap.containsKey(hist.RFQ_Item__c))
            {
                oldHist = prevStatusMap.get(hist.RFQ_Item__c);
                oldHist.Previous_Status__c = hist.Id;
                DebugUtils.write('updateHist.Id', oldHist.Id);
                updateList.add(oldHist);
            }
        }

        update updateList;
    }
}