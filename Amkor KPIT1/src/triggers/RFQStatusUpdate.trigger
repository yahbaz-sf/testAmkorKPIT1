/*************************************************************************
*
* PURPOSE: Updates the status of the Parent RFQ when an RFQ Item status changes
*
* TRIGGER: RFQStatusUpdate
* CREATED: 7/2/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Nathan Pilkington
***************************************************************************/

trigger RFQStatusUpdate on RFQ_Item__c (after insert, after update) {
    
    RFQ_Item__c[] newItems = Trigger.New;
    Set<Id> rfqIds = new Set<Id>();

    if(Trigger.isAfter && Trigger.isUpdate) {
        //get all of the various RFQ for the updated RFQIs
        for(RFQ_Item__c r : newItems) {
            rfqIds.add(r.RFQ__c);
        }
        //Get a list of all the RFQItems for the RFQ reason is a single RFQItem could be updated on an RFQ that has multiple RFQItems
        //SALESFORCE-107 lalit singh : Volume config RFQI's are not getting created and responded back to Sales  Start
        system.debug('RFQStatusUpdate trigger line number 23 queries limit :  '+Limits.getQueries());
        List<RFQ_Item__c> rfqItems = [select Id, Status__c, RFQ__c, Opportunity__c from RFQ_Item__c where RFQ__c in: rfqIds];
              //Check if the RFQ should be opened or closed
        Set<Id> rfqsToClose = new Set<Id>(); 
        Set<Id> rfqsToOpen = new Set<Id>();
        //for all the RFQItems, check their current Status, if an RFQI is in a Status that is considered closed
        //then the RFQ as a whole should be closed so build tow lists, one that has all of the RFQs to close
        //and one that has all the RFQs to open
        for(RFQ_Item__c newItem :rfqItems) {
            

            if(RFQItemDao.STATUS_CLOSED.contains(newItem.Status__c)) {
                rfqsToClose.add(newItem.RFQ__c);
            }
            system.debug(RFQItemDao.STATUS_OPEN.contains(newItem.Status__c));
            if(RFQItemDao.STATUS_OPEN.contains(newItem.Status__c)) {
                rfqsToOpen.add(newItem.RFQ__c);
            }
        }
        //Do not close an RFQ if any of the RFQItems has a status considered to be open
        rfqsToClose.removeAll(rfqsToOpen);
        
        System.debug('rfqclose size:'+rfqsToClose);
        System.debug('rfqopen size:'+rfqsToOpen);
        
        if(rfqsToClose.size() > 0) RFQDao.closeRFQs(rfqsToClose);
        if(rfqsToOpen.size() > 0) RFQDao.openRFQs(rfqsToOpen);
        


        
        if (rfqIds.Size() > 0)
        {
            Map<String, Opportunity> opportunityMap = new Map<String, Opportunity>();
            Map<Id, List<RFQ_Item__c>> itemsByOpportunity = new Map<Id, List<RFQ_Item__c>>();
            for (RFQ_Item__c item :rfqItems) {
                system.debug('RFQStatusUpdate trigger line number 58 queries limit :  '+Limits.getQueries());
                //Populate the itemsByOpportunity basically re-build the Opportinity RFQItem related list
                //why not just query it Who konws, maybe SFDC limitation or query limiter Really no telling
                if (itemsByOpportunity.containsKey(item.Opportunity__c)) {
                    //if the map already conatins the opportunity then add this RFQItem to it's list
                    itemsByOpportunity.get(item.Opportunity__c).add(item);
                }
                else {
                    //Opportunity is not currently in the map, so add it and add the RFQItem to the list
                    itemsByOpportunity.put(item.Opportunity__c, new List<RFQ_Item__c>{item});
                }
                //Build a map of Opportunity objects withe their Ids?
                //Again I'm really not sure why we are building a map
                if (!opportunityMap.containsKey(item.Opportunity__c)) {
                    //if the current RFQItem is not related to the Opportunity then add it to the map
                    Opportunity o = new Opportunity();
                    o.Id = item.Opportunity__c;
                    opportunityMap.put(o.Id, o);
                }
            }
             system.debug('---->Trigger:RFQStatusUpdate (after update),test : ' + opportunityMap.Values());
            for (Opportunity o : opportunityMap.Values()) {
                RFQ_Item__c higestStatusedItem = RFQOpportunityDao.getHighestStatusItem(itemsByOpportunity.get(o.Id));
                o.StageName = RFQOpportunityDao.mapStatusToStage(higestStatusedItem);
                System.debug('---->in trigger #77 StageName:: '+o.StageName);
                o.Opportunity_Status__c = RFQOpportunityDao.mapRFQStatusToOpportunityStatus(higestStatusedItem);
                //Added debug for testing. 
                system.debug('---->>Check Opportunity Status'+o.Opportunity_Status__c);
            }

            if (opportunityMap.size() > 0) {
                try {
                    system.debug('---->Trigger:RFQStatusUpdate (after update), opp before update call : ' + opportunityMap.Values());
                    //SALESFORCE-107 lalit singh : Volume config RFQI's are not getting created and responded back to Sales  Start
                    //Commenting below update statement temprarily for the testin purpose, we may comment permanently after discussion with Adam.
                    update opportunityMap.Values();
                }
                catch (Exception e) {
                    // do nothing, still allow the item to update and the rfq to update
                }
            }
        }
    }
    // Test update
    //SALESFORCE-118 abhay  : Sales ability to update RFQI Status from Cancel to Win/Loss.
    /*if(Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert || Trigger.IsDelete )) {
    
        
        list<RFQ__c> lstRFQToUpdate = new list<RFQ__c>();
        list<string> rfqId = new list<string>();
        
        if(Trigger.isUpdate || Trigger.isInsert){
            for(RFQ_Item__c r : newItems) {
                rfqId .add(r.RFQ__c);
            }
        }else if(Trigger.IsDelete){
            for(RFQ_Item__c r : Trigger.old) {
                rfqId .add(r.RFQ__c);
            }
        }
        
        List<RFQ__c> lstRFQ = [Select Id,Status2__c,(select Id, Status__c, RFQ__c, Opportunity__c from RFQ_Items__r) FROM RFQ__c where ID in: rfqId ];
        
        for(RFQ__c objRFQ : lstRFQ){
            if(objRFQ.RFQ_Items__r.size() >0){
            RFQ_Item__c RFQItemWithHighestVal = RFQItemDao.getinstance().getHighestStatusItem(objRFQ.RFQ_Items__r);
            If(objRFQ.Status2__c != RFQItemWithHighestVal.Status__c ){
                objRFQ.Status2__c = RFQItemWithHighestVal.Status__c;
                lstRFQToUpdate.add(objRFQ);
            }
            }
        }
        system.debug(lstRFQToUpdate);
        update lstRFQToUpdate;
        
        
    }
    */
}