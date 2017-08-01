public without sharing class RFQICreateVolumeCloneController {
    
    private RFQItemWrapper wrapper;
    private String actionUrl;
    private Integer index;
    public Integer numberRemaining {get; set;}
    List<RFQ_Item__c> addedServices;
    Map<String, RFQI_FCM__c> itemFcmMap;

    /*
    index param becomes index of service
    when processing service volumes, do something like
    newServiceItem.Parent_RFQ_Item__c = assemblyWrapper.volumeList[serviceVolumeIndex].createdRFQIId
    change FCM logic to get FCM that is stored in database relating to each volume
    figure out why saving/reloading wrappers all the time
    see if runCostModel still needed, since it runs on volume change

    get child wrappers by cloning parent, but not inserting to db - return list of SO
    loop through list using getdescribes to get rfqItem, specificRfqIte (use parentWrapper.packageFamily for that)
    once done, add all items to big update list
    do this for all volumes
    
    */
    


    public RFQICreateVolumeCloneController() {
        //Entering into constructor
        String rfqId = PageUtil.param('rfqId');
        actionUrl = PageUtil.param('completeAction');
        String sIndex = PageUtil.param('index');
        index = sIndex == null ? -1 : Integer.valueOf(sIndex);
        wrapper = RFQItemDao.getInstance().getWrapperById(rfqId);   
        system.debug('---->wrapper : '+wrapper);
        system.debug('---->index : '+index);
        addedServices = RFQItemDao.getInstance().getByParentItem(wrapper.rfqItem.Id);
        system.debug('RFQICreateVolumeCloneController(), at line number 35, addedServices : '+addedServices);
        system.debug('RFQICreateVolumeCloneController(), addedServices.size() : '+addedServices.size());
        numberRemaining = addedServices.size() - index;
        system.debug('RFQICreateVolumeCloneController(), numberRemaining : '+numberRemaining);
        system.debug('RFQICreateVolumeCloneController(), queries limit :  '+Limits.getQueries());
        //Ending from constructor
    }
    
    
    public PageReference createClones() {

        system.debug('createClones(), index : '+index);
        //if its the first time the page loads and its not an added service
        if(index == -1 ) 
        {
            if (wrapper.rfqItem.Parent_RFQ_Item__c == null)
            {
                List<RFQItemWrapper> cloneItems = processWrappers(wrapper, true);
                system.debug('cloneItems line number 45 : '+cloneItems);
                if (cloneItems != null) approveItems(cloneItems);

            }
            else
            {
                //increment index because services are
                index++;
                createServiceItems(true);
            }
        }
        else if (index >= 0 && addedServices.size() > 0)
        {
            createServiceItems(false);
        }
        else if (addedServices.size() == 0)  
        {
            return new PageReference(actionUrl);
        }
        return continueProcessing(index+1);
    }
    
    public List<RFQItemWrapper> processWrappers(RFQItemWrapper itemWrapper, Boolean saveChildItems)
    {
        system.debug('processWrappers(), line number 76 queries limit :  '+Limits.getQueries());
        //AMK-2477, update existing multivolume RFQIs when assembly is escalated
        //need map because need to know index into wrapper.volumeList for each item to make sure things match up properly
        //AMK-2488, remove functionality to update existing multivumes with changes from escalation
        //leaving map of volumesTOCreate even though it's overly complex in case they ever go back to updating MV items
        Map<Integer, RFQIVolume> volumesToCreate = new Map<Integer, RFQIVolume>();
        List<RFQItemWrapper> itemsToSave = new List<RFQItemWrapper>();

        RFQILayout layout = PFFieldDefDao.getInstance().getPackageFamilyLayout(itemWrapper.packageFamily.Id, itemWrapper.packageFamily.Layout_Version__c, itemWrapper.packageFamily.Layout_Version__c, 'BU');
        CMBuilder builder = CMBuilder.getCMBuilderByWrapper(itemWrapper);
        builder.setup(itemWrapper);
        system.debug('processWrappers(), line number 87 queries limit :  '+Limits.getQueries());
        system.debug('---->itemWrapper.volumeList.size :  '+itemWrapper.volumeList);
        for (Integer i = 0; i < itemWrapper.volumeList.size(); i++)
        {
            RFQIVolume vol = itemWrapper.volumeList[i];
            if (String.isBlank(vol.createdRFQIId)) 
                volumesToCreate.put(i, vol);
        }
        
        system.debug('processWrappers(), volumesToCreate.size :  '+volumesToCreate.size());
        if (volumesToCreate.size() > 0)
        {
            //if copying prices from parent, do not clear prices on clone
            Boolean clearPrices = !copyParentPricesToTest(wrapper);
            //pass in false for clearPostTestPrices because they are not affected by
            List<RFQItemWrapper> cloneItems = RFQItemDao.getInstance().cloneLineItems(itemWrapper, RFQItemDao.STATUS_PRICE_PENDING_BU, true, null, clearPrices, false, volumesToCreate.size());
            
            system.debug('processWrappers(), line number 104 queries limit :  '+Limits.getQueries());
            updateCloneItems(itemWrapper, layout, builder, cloneItems, volumesToCreate);
            system.debug('processWrappers(), line number 106 queries limit :  '+Limits.getQueries());
            updateParentVolumeConfigs(itemWrapper, cloneItems);
            system.debug('processWrappers(), line number 108 queries limit :  '+Limits.getQueries());
            itemsToSave.addAll(cloneItems);
            system.debug('processWrappers(), line number 110 queries limit :  '+Limits.getQueries());
        }
        //save wrapper separately because different params - children need to clear multi volume,
        //but parent does not
        RFQItemDao.getInstance().saveLineItem(itemWrapper);
        
        system.debug('processWrappers(), line number 116 queries limit :  '+Limits.getQueries());
        if (saveChildItems) 
            RFQItemDao.getInstance().saveLineItems(itemsToSave, true, false, true);
        system.debug('processWrappers(), line number 119 queries limit :  '+Limits.getQueries());
        system.debug('processWrappers(), line number 121 itemsToSave   :'+itemsToSave);
        return itemsToSave;
    }

    public void updateCloneItems(RFQItemWrapper itemWrapper, RFQILayout layout, CMBuilder builder, List<RFQItemWrapper> itemsToProcess, Map<Integer, RFQIVolume> volumesToProcess)
    {
        List<String> rfqItemIds = new List<String>();
        for (RFQItemWrapper wrap : itemsToProcess) rfqItemIds.add(wrap.rfqItem.Id);

        itemFcmMap = RFQIFCMDao.getInstance().getLatestByIds(new Set<String>(rfqItemIds));

        RFQItemWrapper cloneItem;
        List<RFQI_FCM__c> fcmUpdateList = new List<RFQI_FCM__c>();

        Integer index = 0;
        for (Integer originalListIndex : volumesToProcess.keyset())
        {
            cloneItem = itemsToProcess.get(index++);
            cloneItem.volumeList.clear();
            system.debug('updateCloneItems(), line number 140 queries limit :  '+Limits.getQueries());
            processCloneItem(itemWrapper, cloneItem, volumesToProcess.get(originalListIndex), originalListIndex, builder, layout, fcmUpdateList);
        }
        update fcmUpdateList;

        //complete any tasks that were created as re-minders
        //so the user doesn't have to. 
        TaskUtil.completeCounterProposalTasks(rfqItemIds);
        system.debug('updateCloneItems(), line number 140 queries limit :  '+Limits.getQueries());
    }
    public void processCloneItem(RFQItemWrapper wrapper, RFQItemWrapper cloneItem, RFQIVolume vol, Integer index, CMBuilder builder, RFQILayout layout, List<RFQI_FCM__c> fcmUpdateList) {
        Integer count = 0;
        String volume = vol.volume;
        Decimal price = vol.price;  
        Decimal subsMarkup = vol.subsMarkup;
        Decimal margin = vol.margin;
        Decimal marginNoSubstrate = vol.marginNoSubstrate;
        Decimal costLessSubs = vol.costLessSubs;
        Decimal othersCost = vol.othersCost;
        Decimal subsCost = vol.subsCost;
        String auAdder = vol.auAdder;
        DebugUtils.write('auAdder', auAdder);
        //recalculate baseBUPrice in case they changed multivol bu price then clicked approve without saving/recalculating
        Decimal baseBUPrice = vol.price;
        if (auAdder != 'Inclusive' && String.isNotBlank(auAdder))
        {
            baseBUPrice = price - Decimal.valueOf(auAdder);
        }
        DebugUtils.write('baseBUPrice', baseBUPrice);
        List<Decimal> subTotals = vol.subTotals;
        Boolean useParentPriceForChild = copyParentPricesToTest(cloneItem);

        Map<String, String> fieldMap = builder.getFieldMap();

        cloneItem.rfqItem.Parent_Volume_Item__c = wrapper.rfqItem.Id;
        cloneItem.rfqItem.Volume_Index__c = index;
        if (cloneItem.packageFamily.Name == 'TSV')
            cloneItem.specificRfqItem.put('Forecast__c', volume == null ? 0 : Decimal.valueOf(volume));
        //Electrical Services does not have forecast
        else if (cloneItem.packageFamily.Product_Group_Name__c != AMKVARS.PG_EGRSVC)
            cloneItem.specificRfqItem.put('Forecast__c',volume);
        //need to recalculate forecast min/max/median for cost model
        RFQItemDao.getInstance().copyFieldsToGeneric(cloneItem);

        price = (price == null) ? 0 : price;
        margin = (margin == null) ? 0 : margin;
        subsMarkup = (subsMarkup == null) ? 0 : subsMarkup;
        marginNoSubstrate = (marginNoSubstrate == null) ? 0 : marginNoSubstrate;
        subsCost = (subsCost == null) ? 0 : subsCost;
        costLessSubs = (costLessSubs == null) ? 0 : costLessSubs;
        othersCost = (othersCost == null) ? 0 : othersCost;
        Decimal totalCost = costLessSubs;
        if (CMBuilder.getHasSubstrate(cloneItem)) totalCost += subsCost;

        //copy total cost and price 
        if (fieldMap.get('price') != null) cloneItem.specificRfqItem.put(fieldMap.get('price'), price);
        if (fieldMap.get('totalCost') != null) cloneItem.specificRfqItem.put(fieldMap.get('totalCost'), totalCost);

        if (cloneItem.packageFamily.Name == AMKVARS.PF_TEST && !useParentPriceForChild)
        {
            copyFieldsToTest(cloneItem, vol);
        }
        system.debug('processCloneItem(), line number 200 queries limit :  '+Limits.getQueries());
        //calculate all to make sure that for FCM items, the processes are re-calculated
        //also for something like PBGA which recalculates IRR based on BU price
        builder.calculateAll(cloneItem, false, new CMSettings(), false);
        system.debug('processCloneItem(), line number 204 queries limit :  '+Limits.getQueries());
        RFQI_FCM__c itemFcm = itemFcmMap.get(cloneItem.rfqItem.Id);
        if (itemFcm != null)
        {
            itemFcm.Needs_Reparenting__c = false;
            itemFcm.Total_Price__c = price;
            itemFcm.Substrate_Markup_Percent__c = subsMarkup;
            itemFcm.Margin_Percent__c = margin;
            itemFcm.Margin_Less_Substrate_Percent__c = marginNoSubstrate;
            fcmUpdateList.add(itemFcm);
        }
        else DebugUtils.write('itemFcm == null xxxxx', wrapper.rfqItem.Id);
        //AMK-1601
        cloneItem.specificRfqItem.put('Au_Adder__c', auAdder);
        cloneItem.specificRfqItem.put('BU_Base_Price__c', baseBUPrice);
        if (!useParentPriceForChild)
        {
            if (cloneItem.packageFamily.Copy_Fields_To_Multivolume__c)
            {
                if (fieldMap.get('subsMarkup') != null) cloneItem.specificRfqItem.put(fieldMap.get('subsMarkup'), subsMarkup);
                if (fieldMap.get('marginNoSubstrate') != null) cloneItem.specificRfqItem.put(fieldMap.get('marginNoSubstrate'), marginNoSubstrate);
                if (fieldMap.get('subsCost') != null) cloneItem.specificRfqItem.put(fieldMap.get('subsCost'), subsCost);
                if (fieldMap.get('costLessSubs') != null) cloneItem.specificRfqItem.put(fieldMap.get('costLessSubs'), costLessSubs);
                if (fieldMap.get('othersCost') != null) cloneItem.specificRfqItem.put(fieldMap.get('othersCost'), othersCost);

                if(cloneItem.serviceConfigurations != null) {
                    if(fieldMap.get('subtotal') != null) {
                        for(Integer i = 0; i < cloneItem.serviceConfigurations.size(); i++) {
                            cloneItem.serviceConfigurations[i].put(fieldMap.get('subtotal'), subtotals[i]);
                        }
                    }
                }
            }
            else
            {
                cloneItem.clearCostAndPrice(layout);
            }
        }

        if (!useParentPriceForChild)
        {
            if (fieldMap.get('margin') != null) cloneItem.specificRfqItem.put(fieldMap.get('margin'), margin);

            cloneItem.specificRfqItem.put('Price_To_Customer__c', price);
            if (fieldMap.get('price') != null) cloneItem.specificRfqItem.put(fieldMap.get('price'), price);
            if (fieldMap.get('totalCost') != null) cloneItem.specificRfqItem.put(fieldMap.get('totalCost'), totalCost);
            //copy fields again to get cost and price fields, and set price to customer
        }

        cloneItem.copyBuPriceToCustomerPrice();
        RFQItemDao.getInstance().copyFieldsToGeneric(cloneItem);

        //CPN will always be the same on multi volumes because there are no CPN attributes on multi volume
        cloneItem.rfqItem.Configured_Part_Number__c = wrapper.rfqItem.Configured_Part_Number__c;            
        //make the approval processes skip any first steps
        cloneItem.rfqItem.Skip_BU_Review__c = true;
        system.debug('processCloneItem(), line number 260 queries limit :  '+Limits.getQueries());
    }
    
    private void  approveItems(List<RFQItemWrapper> itemsToApprove)
    {
        List<String> rfqItemIds = new List<String>();
        for (RFQItemWrapper wrap : itemsToApprove) rfqItemIds.add(wrap.rfqItem.Id);

        ApprovalUtils.startApprovals(rfqItemIds, 'Starting approval on Additional Volume Creation');

        //after initial submission, find any items that are in approval and approve them until they are through
        Set<Id> itemsUnderApproval = ApprovalUtils.getProcessInstanceWorkItems(new Set<String>(rfqItemIds));

        while (itemsUnderApproval.size() > 0)
        {
            ApprovalUtils.approveRecords(itemsUnderApproval,'Automatic approval from additional volume configuration approval 2');
            itemsUnderApproval = ApprovalUtils.getProcessInstanceWorkItems(new Set<String>(rfqItemIds));
        }

        //requery to get updated statuses
        Set<String> itemIds = new Set<String>();
        for (RFQItemWrapper wrapper : itemsToApprove) itemIds.add(wrapper.rfqItem.Id);
        List<RFQ_Item__c> rfqItems = RFQItemDao.getInstance().getSObjectByIdSet('Id', itemIds);
        //AMK-2391 prevent escalations on cloned item from auto approving,
        for (RFQ_Item__c rfqItem : rfqItems)
        {
            rfqItem.Skip_BU_Review__c = false;
            system.debug('line 288   rfqItem :  '+rfqItem);
            system.debug('line 288   rfqItem.Status__c :  '+rfqItem.Status__c);
        }
        system.debug('line 289 rfqItems :   '+rfqItems);
        update rfqItems;
    }
    
        public void createServiceItems(Boolean mainWrapperIsService)
    {
        //find the first added service with multi volumes
        RFQitemWrapper serviceWrapper = new RFQItemWrapper();
        Integer serviceIndex = 0;
        for (RFQ_Item__c addedService : addedServices)
        {
            serviceWrapper.volumeList = null;
            serviceWrapper.rfqItem = addedService;
            serviceWrapper.inflateVolume();
            system.debug('At line number 302 serviceWrapper after the inflateVolume method:    '+serviceWrapper);
            if (serviceWrapper.volumeList == null || serviceWrapper.volumeList.size() == 0)
            {
                //make sure index moves past this so the next page load doesnt start at the empty one
                index++;   
                serviceIndex++;
            }
            else
            {
                //found one to use, stop looking
                break;
            }
        }
        RFQItemWrapper wrapperToClone, parentWrapper;
        if (mainWrapperIsService) 
        {
            //the page was reached by approving an added service after the parent was approved,
            //so treat "wrapper" like an added service
            parentWrapper = RFQItemDao.getInstance().getWrapperById(wrapper.rfqItem.Parent_RFQ_Item__c);
            system.debug('At line number 321 parentWrapper:    '+parentWrapper);
            wrapperToClone = wrapper;
            system.debug('At line number 323 wrapperToClone:    '+wrapperToClone);
        }
        else
        {
            parentWrapper = wrapper;
            wrapperToClone = RFQItemDao.getInstance().getWrapperById(addedServices[serviceIndex].Id);
            system.debug('At line number 329 wrapperToClone:    '+wrapperToClone);

            //manually set to price complete because added services at this point were set to pending assy approval
            wrapperToClone.rfqItem.Status__c = RFQItemDao.STATUS_PRICE_COMPLETE;
        }
        system.debug('createServiceItems(), line 331 queries limit :  '+Limits.getQueries());
        List<RFQItemWrapper> cloneItems = processWrappers(wrapperToClone, false);
        updateServicesForVolumeConfigs(parentWrapper, cloneItems);
        RFQItemDao.getInstance().saveLineItems(cloneItems, true, false, true);
        system.debug('createServiceItems(), line 335 queries limit :  '+Limits.getQueries());
        approveItems(cloneItems);
        system.debug('createServiceItems(), line 337 queries limit :  '+Limits.getQueries());
    }

    public PageReference continueProcessing(Integer nextIndex) {
        system.debug('continueProcessing(), nextIndex :  '+nextIndex);
        PageReference pg = new PageReference('/apex/RFQICreateVolumeClone');
        pg.getParameters().put('rfqId',wrapper.rfqItem.Id);
        pg.getParameters().put('completeAction',actionURL);
        pg.getParameters().put('index',String.valueOf(nextIndex));
        pg.setRedirect(true);
        return pg;
    }

    private void updateParentVolumeConfigs(RFQItemWrapper parentWrapper, List<RFQItemWrapper> cloneItems)
    {
        for (RFQItemWrapper child : cloneItems)
        {
            DebugUtils.write('child.rfqItem.Status__c', child.rfqItem.Status__c);
            Integer listIndex = Integer.valueOf(child.rfqItem.Volume_Index__c);
            DebugUtils.write('listIndex', listIndex);
            parentWrapper.volumeList.get(listIndex).createdRFQIId = child.rfqItem.Id;
            parentWrapper.volumeList.get(listIndex).createdRFQIName = child.rfqItem.Name;
        }
        parentWrapper.rfqItem.Has_Created_Multivolume_Items__c = true;
    }

    private void updateServicesForVolumeConfigs(RFQItemWrapper parentWrapper, List<RFQItemWrapper> addedServices)
    {
        for(RFQItemWrapper addedService : addedServices)
        {
            //each cloned item relates to the item that was created for the multi volume with the same index
            addedService.rfqitem.Parent_RFQ_Item__c = null;
            if(addedService.rfqitem.Package_Family_Name__c != AMKVARS.PF_BUMP && addedService.rfqitem.Package_Family_Name__c != AMKVARS.PF_WLCSP && addedService.rfqItem.Test_Type__c != AMKVARS.TT_PROBE &&  addedService.rfqitem.Package_Family_Name__c != 'Die Processing Service (WLCSP)'  && addedService.rfqitem.Package_Family_Name__c != 'WLCSP' && addedService.rfqitem.Package_Family_Name__c != 'Die Processing Service') {
                Integer listIndex = Integer.valueOf(addedService.rfqItem.Volume_Index__c);
                addedService.rfqitem.Parent_RFQ_Item__c = parentWrapper.volumeList[listIndex].createdRFQIId;
            }
        }
    }

    private void copyFieldsToTest(RFQItemWrapper cloneItem, RFQIVolume volume)
    {
        if(cloneItem.insertionConfigurations != null)
        {
            for (Integer i = 0; i < cloneItem.insertionConfigurations.size(); i++)
            {
                sObject ins = cloneItem.insertionConfigurations[i];
                RFQIVolume.RFQITestInsertion volIns = volume.testInsertions[i];
                ins.put('Insertion_BU_Price_Per_Hour__c', volIns.buPriceHour);
                ins.put('Insertion_BU_Price_Per_Second__c', volIns.buPriceSecond);
                ins.put('BU_Price_Per_Unit_Final__c', volIns.buPriceUnit);
                ins.put('Insertion_BU_Price_Monthly_Charge__c', volIns.buPriceMonthly);
            }
        }

        sObject item = cloneItem.specificRfqItem;
        item.put('BU_Price_Per_Hour__c', volume.testInsertionsTotals.buPriceHour);
        item.put('BU_Price_per_Second__c', volume.testInsertionsTotals.buPriceSecond);
        item.put('BU_Price_per_Minute__c', volume.testInsertionsTotals.buPriceMinute);
        item.put('BU_Final_Test_Price_Unit__c', volume.testInsertionsTotals.buPriceUnit);
        item.put('BU_Price_Monthly_Charge__c', volume.testInsertionsTotals.buPriceMonthly);
    }

    
    private Boolean copyParentPricesToTest(RFQItemWrapper cloneItem)
    {
        return cloneItem.packageFamily.Name == AMKVARS.PF_TEST && (String)cloneItem.specificRfqItem.get('Test_Type__c') == AMKVARS.TT_POST;
    }
}