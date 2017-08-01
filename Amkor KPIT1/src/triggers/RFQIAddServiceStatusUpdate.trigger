trigger RFQIAddServiceStatusUpdate on RFQ_Item__c (before update) {

    RFQ_Item__c[] oldItems = Trigger.Old;
    RFQ_Item__c[] newItems = Trigger.New;

    List<RFQ_Item__c> rfqisToCheck = new List<RFQ_Item__c>();
    for (RFQ_Item__c addedService : newItems)
    {
        //find all RFQIs that are an added service and going into a price complete status
        if (addedService.Parent_RFQ_Item__c != null && addedService.Service__c != 'Assembly' && addedService.Status__c == RFQItemDao.STATUS_PRICE_COMPLETE)
        {
            DebugUtils.write('check item', addedService.Id);
            rfqisToCheck.add(addedService);
        }
    }

    //find the parents of the service items found
    //if the parents are not yet price complete (or past),
    //then update status of added service to "pending assembly approval"
    if (!rfqisToCheck.isEmpty())
    {

        //find all parent ids
        Set<String> parentIds = new Set<String>();
        for (RFQ_Item__c service : rfqisToCheck)
        {
            parentIds.add(service.Parent_RFQ_Item__c);
        }

        Map<Id, sObject> parentItems = new Map<Id, sObject>(RFQItemDao.getInstance().getSObjectByIdSet('Id', parentIds));


        for (RFQ_Item__c service : rfqisToCheck)
        {
            RFQ_Item__c parent = (RFQ_Item__c)parentItems.get(service.Parent_RFQ_Item__c);
            //if parent is not approved, then place service into pending status
            if (!RFQItemDao.getInstance().statusGreaterOrEqual(parent, RFQItemDao.STATUS_PRICE_COMPLETE) && !StringUtils.isJSONBlank(parent.Multi_Volume__c))
            {
                service.Status__c = RFQItemDao.STATUS_PENDING_ASSEMBLY_APPROVAL;
            }
        }
    }


}