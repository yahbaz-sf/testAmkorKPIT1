/*************************************************************************
*
* PURPOSE: Controller for the Attribute Edit page which allows BU users to clone
*          an item and tweak it.
*
* TRIGGER: RFQItemAttributeEditController
* CREATED: 7/2/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/
public virtual with sharing class RFQBUItemAttributeEditController extends RFQBUItemEditController {
	
    public RFQItemWrapper cloneItem {get; set;} 
	
    public RFQBUItemAttributeEditController(ApexPages.StandardController sc) {
	    super(sc);
        layout.enabledSections.put('Cost and Price', true);
        List<String> missingFields = new List<String>();
        String error;
        if (!validateRequiredFields(wrapper, missingFields)) 
        {
            error = getValidationErrors(wrapper);
            addError(error);
            DebugUtils.write('Validation Error', error);
        }
    }

    //used to get only BU sections
    protected override RFQILayout getLayout(RFQItemWrapper itemWrapper)
    {
        return PFFieldDefDao.getInstance().getPackageFamilyLayout(itemWrapper.packageFamily.Id, itemWrapper.packageFamily.Layout_Version__c, itemWrapper.rfqItem.Layout_Version__c, 'BU');
    } 
	
    public override PageReference gotoStandardApprovalWizard() {
    	if (!RFQItemDao.getInstance().saveLineItem(wrapper)) return null;
        PageReference pg = ApprovalUtils.getStandardApprovalWizard(wrapper.rfqItem.Id);
        if(pg == null) {
    	    addError('This item is not currently review and therefore cannot be approved or rejected.');
        }
    	return pg;
    }
    
    public override Pagereference reloadOriginal() {
        ApexPages.currentPage().getParameters().put('cloneId', null);
        return reloadClone();
    }

    public void setupChildObjectSectionsForClone(RFQILayout layout) {
        //childObjectSections = new Map<Id, RFQILayoutSection>();
        cloneItem.setupChildObjectSections(layout);
    }
    
    public PageReference reloadClone() {
        String cloneItemId = ApexPages.currentPage().getParameters().get('cloneId');

        //AMK-1398
        if(wrapper.rfqItem.Status__c == RFQItemDao.STATUS_BU_DRAFT) {
            cloneItemId = wrapper.rfqItem.Id;
        }

        if(cloneItemId == null) {
            if(cloneItem != null){
                if(!RFQItemDao.getInstance().deleteLineItem(cloneItem)){
                    addError('There was a problem deleting the line item. Please try again.');
                }
            }
            cloneItem = RFQItemDao.getInstance().cloneLineItem(wrapper,RFQItemDao.STATUS_BU_DRAFT,true,layout);
        }
        else {
            cloneItem = RFQItemDao.getInstance().getWrapperById(cloneItemId);
        }
        setupChildObjectSectionsForClone(layout);
        layout = otherfieldsForClone();        
        setupCostModel(cloneItem);

        disableAllEditabilityExcept(layout.sectionMap.get('BU Header'));
        setEditabilityForChildFields(cloneItem);

        if(cloneItem.packageFamily.Name == AMKVARS.PF_TEST || cloneItem.packageFamily.Name == 'Final Test') {
            buPriceSummary = 'BU Price Summary';
        }
        else buPriceSummary = null;
        


        setNREInclusionDefaults(cloneItem);

        if(cloneItem.packageFamily.Name == AMKVARS.PF_TEST && cloneItem.specificRfqItem.get('Test_Type__c') == AMKVARS.TT_FINAL){
            layout.changeEditability('BU_Price_Per_Unit_Final__c', false);
        }

    	return null;
    }

    private RFQILayout otherfieldsForClone() {
        RFQILayout otherLayout = getLayout(cloneItem);
        Decimal salesScreenColumns = cloneItem.packageFamily.Product_Group__r.Sales_Screen_Columns__c;
        Decimal buScreenColumns = cloneItem.packageFamily.Product_Group__r.BU_Screen_Columns__c;
        otherLayout.setBUColumns(Integer.valueOf(bUScreenColumns));
        otherLayout.setSalesColumns(Integer.valueOf(salesScreenColumns));
        cloneItem.OtherFieldsChange(otherLayout);

        //AMK-2586 editablity needs to get set when layout gets rerendered 
        if(noCostModel) {
            RFQILayoutSection section = otherLayout.sectionMap.get('Cost and Price');
            if (section != null)
            {
                enableAllEditability(section, SPECIFICITEM_READ_ONLY_FIELDS);
            }
            builder = CMBuilder.getCMBuilderByWrapper(wrapper);                  
            builder.setEditabilityforNoCostModel(otherLayout);
        }
        else {
            otherLayout.reRender(true, wrapper.getHasParent());
        }

        return otherLayout;
    }

    public PageReference onDefaultDriverChangeClone() {

        RFQItemWrapper tempWrapper = onDefaultDriverChange(cloneItem);
        cloneItem = RFQItemDao.getInstance().refresh(tempWrapper, true, true);
        setupChildObjectSectionsForClone(layout);
        layout = otherfieldsForClone();
        setEditabilityForChildFields(cloneItem);

        if(wrapper.packageFamily.Name == AMKVARS.PF_TEST && wrapper.specificRfqItem.get('Test_Type__c') == AMKVARS.TT_FINAL){
            layout.changeEditability('BU_Price_Per_Unit_Final__c', false);
        }
        
        return null;
    }

    public virtual Pagereference resetPrice() {
        cloneItem.rfqItem.put('BU_Price_Manually_Changed__c', false);
        if (!RFQItemDao.getInstance().saveLineItem(cloneItem)) return null;
        PageReference pg = new PageReference('/apex/RFQBUItemAttributeEdit?id='+wrapper.rfqItem.Id);
        pg.setRedirect(true);
        pg.getParameters().put('cloneId', cloneItem.rfqItem.Id);
        return pg;
    }

    public override PageReference addWireConfiguration() {
        addWireConfiguration(cloneItem);
        setupChildObjectSectionsForClone(layout);
        return null;
    }

    public override PageReference addInsertionConfiguration() {
        addInsertionConfiguration(cloneItem);
        setupChildObjectSectionsForClone(layout);
        setEditabilityForChildFields(cloneItem);
        return null;
    }

    public override PageReference cloneInsertionConfiguration() {
        cloneInsertionConfiguration(cloneItem);
        setupChildObjectSectionsForClone(layout);
        setEditabilityForChildFields(cloneItem);
        return null;
    }

    public override PageReference addPassiveConfiguration() {
        addPassiveConfiguration(cloneItem);
        setupChildObjectSectionsForClone(layout);
        return null;
    }

    public override PageReference addDieConfiguration() {
        addDieConfiguration(cloneItem);
        setupChildObjectSectionsForClone(layout);
        return null;
    }

    public override PageReference addServiceConfiguration() {
        addServiceConfiguration(cloneItem);
        setupChildObjectSectionsForClone(layout);
        return null;
    }

    public override PageReference addNREConfiguration() {
        addNREConfiguration(cloneItem);
        setupChildObjectSectionsForClone(layout);
        return null;
    }
	
    public override PageReference removePassiveConfigurationById() {
        removeWireConfigurationById(cloneItem);
        setupChildObjectSectionsForClone(layout);
        return null;
    }
	
    public override PageReference removeInsertionConfigurationById() {
        removeInsertionConfigurationById(cloneItem);
        setupChildObjectSectionsForClone(layout);
        setEditabilityForChildFields(cloneItem);
        return null;
    }

    public override PageReference removeWireConfigurationById() {
        removeWireConfigurationById(cloneItem);
        setupChildObjectSectionsForClone(layout);
        return null;
    }

    public override PageReference removeDieConfigurationById() {
        removeDieConfigurationById(cloneItem);
        setupChildObjectSectionsForClone(layout);
        return null;
    }
    
    public override PageReference removeServiceConfigurationById() {
        removeServiceConfigurationById(cloneItem);
        setupChildObjectSectionsForClone(layout);
        return null;
    }

    public override PageReference removeNREConfigurationById() {
        removeNREConfigurationById(cloneItem);
        setupChildObjectSectionsForClone(layout);
        return null;
    }

    public override PageReference saveWireConfigurationById() {
        saveWireConfigurationById(cloneItem);
        setupChildObjectSectionsForClone(layout);
        return null;
    }

    public override PageReference reCalculatePriceById(){
        return reCalculatePrice(cloneItem);
    }

    public  PageReference reCalculatePriceWithRerun() {
        getAutoCostErrors();
        return reCalculatePrice(cloneItem, true);
    }

    public PageReference saveAsDraft() {
        cloneItem.rfqItem.Status__c = RFQItemDao.STATUS_BU_DRAFT;
        if (!RFQItemDao.getInstance().saveLineItem(cloneItem)) return null;
        if(!TaskUtil.hasCounterProposalTask(cloneItem.rfqItem)) {
            TaskUtil.assignFollowUpForCounter(cloneItem.rfqItem, UserInfo.getUserId());
        }

        return new PageReference('/apex/RFQBUItemView?id=' + cloneItem.rfqItem.Id);
    }
 
    public PageReference saveAsNewRfqItem() {
        if(wrapper.rfqItem.Id != cloneItem.rfqItem.Id) {
            cloneItem.rfqItem.Original_RFQ_Item__c = wrapper.rfqItem.Id;
        }
    	
        List<String> missingFields = new List<String>();
        String error;
        if (!validateObject(cloneItem)) 
        {
            addError(getAllValidationErrors(cloneItem));
            return null;  
        }

        //cloneItem.rfqItem.Original_RFQ_Item__c = wrapper.rfqItem.Id;

        //Note that if the status here can be set to Price Complete
        //then you will need to create a CPN (see ProcessInstance controller)
        cloneItem.rfqItem.Status__c = RFQItemDao.STATUS_PRICE_PENDING_BU; 

         if(cloneItem.packageFamily.Name == AMKVARS.PF_TEST && cloneItem.rfqItem.Status__c == RFQItemDao.STATUS_PRICE_PENDING_BU) {
            //hacks to preserve the volumes for test because they are overwritten by setupCostModel
            String volumesToPreserve = JSON.serialize(cloneItem.volumeList);
            setupCostModel(cloneItem);
            if(!getIsTestAddedServicePostTestOnly()) {
                cloneItem.rfqItem.Multi_Volume__c = volumesToPreserve;
                cloneItem.inflateVolume();
            }
           
        }

        cloneItem.copyBuPriceToCustomerPrice();
        //make the approval processes skip any first steps
        cloneItem.rfqItem.Skip_BU_Review__c = true;

        try
        {
            if (!RFQItemDao.getInstance().saveLineItem(cloneItem)) return null;
            cloneItem = RFQItemDao.getInstance().getWrapperById(cloneItem.rfqItem.Id);
            
            CPN cpn = CPNDao.getInstance().getCPN(cloneItem);
            cloneItem.rfqItem.Configured_Part_Number__c = cpn.cpnId;            
            if (!RFQItemDao.getInstance().saveLineItem(cloneItem)) return null;
            
        } 
        catch (System.Dmlexception e)
        {
            if(e.getDmlType(0)==StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION)
            {
                addError(e.getDmlMessage(0));
                return null;
            }
            else if(e.getDmlType(0)==StatusCode.ENTITY_IS_LOCKED)
            {
                addError(System.label.RFQ_ERR_0007);
                return null;
            }
            else
            {
                throw e;
            }
        }
        
        //For second level approvals
        ApprovalUtils.startApproval(cloneItem.rfqItem.Id, 'Starting approval on BU clone');

        //AMK-2391 prevent escalations on cloned item from auto approving,
        //dont need saveLineItem as it was just called
        //requery to get updated status from approval
        RFQ_Item__c item = RFQItemDao.getInstance().getById(cloneItem.rfqItem.Id);
        item.Skip_BU_Review__c = false;
        update item;

        //complete any tasks that were created as re-minders
        //so the user doesn't have to. 
        TaskUtil.completeCounterProposalTasks(cloneItem.rfqItem);
        String actionURL = '/apex/RFQBUItemView?id='+cloneItem.rfqItem.Id+'&clone=true';

        if(cloneItem.volumeList != null && cloneItem.volumeList.size() > 0) {
            String status = [select Status__c from RFQ_Item__c where Id =: cloneItem.rfqItem.Id].Status__c;
            if(status == RFQItemDao.STATUS_PRICE_COMPLETE) {
                PageReference pg = new PageReference('/apex/RFQICreateVolumeClone');
                pg.getParameters().put('rfqId',cloneItem.rfqItem.Id);
                pg.getParameters().put('completeAction',actionURL);

                return pg;
            }
        }

    	return new PageReference(actionURL);
    }

    public PageReference saveAsNewRfqItemAndClone() {
        Pagereference temppg = saveAsNewRfqItem(); 
        if(temppg != null) {

            String actionURL = '/apex/RFQBUItemAttributeEdit?id='+wrapper.rfqItem.Id;
        
            if(cloneItem.volumeList != null && cloneItem.volumeList.size() > 0) {
                String status = [select Status__c from RFQ_Item__c where Id =: cloneItem.rfqItem.Id].Status__c;
                if(status == RFQItemDao.STATUS_PRICE_COMPLETE) {
                    PageReference pg = new PageReference('/apex/RFQICreateVolumeClone');
                    pg.getParameters().put('rfqId',cloneItem.rfqItem.Id);
                    pg.getParameters().put('completeAction',actionURL);

                    return pg;
                }
            }

    	    Pagereference pg = new PageReference(actionURL);
            pg.setRedirect(true);
            return pg;
        }
        return null;
    }
	
    public PageReference cancelEditAttributes() {
    	//AMK-1537, no longer deleting the cloned item on cancel
        //if(cloneItem != null) RFQItemDao.getInstance().deleteLineItem(cloneItem);
    	return new PageReference('/apex/RFQBUItemView?id=' + wrapper.rfqItem.Id);
    }

    public override Boolean getIsBuNreEditableState() {
        if (RFQItemDao.getInstance().statusGreaterOrEqual(cloneItem.rfqItem, RFQItemDao.STATUS_PRICE_COMPLETE)) {
            return false;
        }
        return true;
    }

    public override Boolean getShowNREAttributes()
    {
        return cloneItem.rfqItem.Include_NRE_On_Quote__c || cloneItem.rfqItem.NRE_Inclusion__c == 'If Applicable' || cloneItem.rfqItem.NRE_Inclusion__c == 'Required';
    }
}