/*************************************************************************
*
* PURPOSE: Creates a new RFQI Status History record when an RFQ Item status changes
*
* TRIGGER: RFQStatusHistory
* CREATED: 7/2/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Austin Delorme
***************************************************************************/
trigger RFQStatusHistory on RFQ_Item__c (after update) 
{

    RFQ_Item__c[] oldItems = Trigger.Old;
    RFQ_Item__c[] newItems = Trigger.New;

    List<RFQI_Status_History__c> deleteList = new List<RFQI_Status_History__c>();
    List<RFQI_Status_History__c> insertList = new List<RFQI_Status_History__c>();

    Map<Id, RFQItemWrapper> result = new Map<Id, RFQItemWrapper>();
    Map<Id, Package_Family__c> pfMap = new Map<Id, Package_Family__c>(PackageFamilyDao.getInstance().getAllPackageFamilies());

    Set<String> rfqitemIds = new Set<String>();
    for (RFQ_Item__c item : newItems) rfqitemIds.add(item.Id);
    
    //Lalit - 30-Mar-2017 : Salesforce-68 : BU View for BU Price on volume config RFQI's on escalation is incorrect
    //update the multivolume field of parent RFQI in case of escalation of Child RFQI'S.
    if(Trigger.isAfter && Trigger.isUpdate) {
        List<RFQ_Item__c> listToUpdate = new List<RFQ_Item__c>();
        for(RFQ_Item__c rfqItem : [SELECT Parent_Volume_Item__r.Multi_Volume__c,Status__c,BU_Price__c,Name FROM RFQ_Item__c WHERE ID IN : newItems]){
            if((rfqItem.Parent_Volume_Item__c != null) && (rfqItem.Status__c == RFQItemDao.STATUS_PRICE_COMPLETE) && (Trigger.Oldmap.get(rfqItem.id).Status__c ==RFQItemDao.STATUS_PRICE_ESCALATION )){
                String multiVolumeJSON = rfqItem.Parent_Volume_Item__r.Multi_Volume__c;
                List<RFQIVolume> volumeList = (List<RFQIVolume>)JSON.deserialize(multiVolumeJSON, List<RFQIVolume>.class);
                Map<String,RFQIVolume> volumeMap =  new  Map<String,RFQIVolume>();
                For (RFQIVolume rfqiVar : volumeList){
                   volumeMap.put(rfqiVar.createdRFQIName,rfqiVar);
                }  
                volumeMap.get(rfqItem.name).price = rfqItem.BU_Price__c;
                rfqItem.Parent_Volume_Item__r.Multi_Volume__c = JSON.serialize(volumeList);
                listToUpdate.add(rfqItem.Parent_Volume_Item__r);
            }
        }
        update listToUpdate;
    }
    
    List<RFQI_Status_History__c> statusHistories = RFQIStatusHistoryDao.getInstance().getByRfqItems(rfqitemIds);
    system.debug('RFQStatusHistory at line number 25 statusHistories'+statusHistories);
    Map<Id, List<RFQI_Status_History__c>> statusMap = new Map<Id, List<RFQI_Status_History__c>>();

    List<RFQI_Status_History__c> histList;
    for (RFQI_Status_History__c history : statusHistories) 
    {
        system.debug('RFQStatusHistory at line number 25 history : '+history);
        if (statusMap.containsKey(history.RFQ_Item__c))
        {
            statusMap.get(history.RFQ_Item__c).add(history);
        }
        else
        {
            histList = new List<RFQI_Status_History__c>();
            histList.add(history);
            statusMap.put(history.RFQ_Item__c, histList);
        }
    }
    system.debug('RFQStatusHistory at line number 43 statusMap : '+statusMap);
    for (RFQ_Item__c rfqItem : newItems) {
        
            RFQItemWrapper wrapper = new RFQItemWrapper();
            wrapper.rfqItem = rfqItem;
            wrapper.statusHistories = statusMap.get(rfqItem.Id);
            result.put(rfqItem.Id, wrapper);
    }


    // Go through all the items and see if any statuses have changed, if so then make a new status history
    for (Integer i = 0; i < oldItems.size(); i++) 
    {
        if (!(StringUtils.isMatch(oldItems[i].Status__c, newItems[i].Status__c) ))
        {
            RFQItemWrapper wrapper = result.get(newItems[i].Id);
            if (RFQItemDao.reportableStatuses.contains(newItems[i].Status__c))
            {
                //add new status if should report on it 
                RFQIStatusHistoryDao.getInstance().updateStatusHistory(wrapper, insertList);
            }
            else if (RFQItemDao.getInstance().statusLessOrEqual(newItems[i].Status__c, oldItems[i].Status__c))
            {
                RFQIStatusHistoryDao.getInstance().deleteStatusHistory(wrapper, deleteList);
            }
        }
    }

    if(!insertList.isEmpty()) insert insertList;
    if(!deleteList.isEmpty()) delete deleteList;

}