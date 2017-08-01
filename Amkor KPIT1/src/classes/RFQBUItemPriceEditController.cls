/*************************************************************************
*
* PURPOSE: Controller for the RFQ Item view/edit page
*
* CLASS: RFQBUItemPriceEditController
* CREATED: 3/21/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/
public virtual with sharing class RFQBUItemPriceEditController extends RFQBUItemEditController {
    
    //Ashish: 13-Apr-2017: SF-139: Renaming the section of passive Description for package family 'MEMS'.
    public string sectionTitle {set;get;}
    
    public RFQBUItemPriceEditController(ApexPages.StandardController sc) {
        super(sc);
        //Ashish: 13-Apr-2017: SF-139: Assigning value to the section of passive Description for package families other than 'MEMS'.
        sectionTitle='Passive Description';
        layout.enabledSections.put('Cost and Price', true);

        //to disable editibality from certain Cost/Price fields for BU when noCostModel     
        if (noCostModel || wrapper.rfqItem.Do_Not_Auto_Price__c) {
            RFQILayoutSection section = layout.sectionMap.get('Cost and Price');
             

            if (section != null) {
                enableAllEditability(section, SPECIFICITEM_READ_ONLY_FIELDS);
            }

            builder = CMBuilder.getCMBuilderByWrapper(wrapper);                  
            builder.setEditabilityforNoCostModel(layout);
        }
        else {
            layout.reRender(true, wrapper.getHasParent());
        }

        if (wrapper.packageFamily.Name == 'FC BGA') enableAllEditability(layout.sectionMap.get('BU Attributes'), new Set<String>());
        
        //Lalit-19-Oct-2016:Salesforce-37:Cavity MEMS BU price response screen.Making Cost and Price section editable for package family 'CAVITY-MEMS'
        //Bharat - 26-Apr-2017: SF-139: Cavity MEMS Sales RFQ Item Create screens.
        //Re-naming 'Cavity MEMS' to 'MEMS' package family.
        if(wrapper.packageFamily.Name == 'MEMS')enableAllEditability(layout.sectionMap.get('Cost and Price'), new Set<String>());
        
        //Lalit-16-Nov-2016 : Salesforce-124 : BUMP/WLCSP (Wafer Services) Recalc Issue.Making Cost and Price section editable for package family 'BUMP/WLCSP (Wafer Services)'.
        //Bharat-07-July-2016 : Salesforce-81 : JDevice Plant Quoting capability in SFDC.Making Cost and Price section editable for package families LQFP-JDev, MQFP-JDev and TQFP-JDev.
        if(wrapper.packageFamily.Name == 'BUMP/WLCSP (Wafer Services)' || wrapper.packageFamily.Name == 'LQFP-JDev' || wrapper.packageFamily.Name == 'MQFP-JDev' || wrapper.packageFamily.Name == 'TQFP-JDev')enableAllEditability(layout.sectionMap.get('Cost and Price'), new Set<String>());
        
        //Ashish - 27-Oct-2016 : Salesforce-107 : Volume config RFQI's are not getting created and responded back to Sales
        //Making Cost and Price section editable for all package families under MLF product group.
        //Ashish - 4-Nov-2016 : Salesforce-122 : Adv Products Flip Chip and Unlisted Recalc Issue - Simply BU Price entry
        //Making Cost and Price section editable for all package families under Advanced Product Development, FlipChip and Unlisted product groups.
        if(wrapper.productGroup.Name == 'MLF' || wrapper.productGroup.Name == 'Advanced Product Development'|| wrapper.productGroup.Name == 'Flip Chip' || wrapper.productGroup.Name == 'Unlisted')enableAllEditability(layout.sectionMap.get('Cost and Price'), new Set<String>());
       
        // TODO the purpose of this method call is vague and the method name seems backwards
        disableAllEditabilityExcept(layout.sectionMap.get('BU Header'));

        if(wrapper.packageFamily.Name == AMKVARS.PF_TEST)
        {
            if (wrapper.specificRfqItem.get('Test_Type__c') == AMKVARS.TT_FINAL || wrapper.specificRfqItem.get('Test_Type__c') == AMKVARS.TT_PROBE)
            {
                layout.changeEditability('BU_Price_Per_Unit_Final__c', false);
            }
            else if(wrapper.specificRfqItem.get('Test_Type__c') == AMKVARS.TT_STRIP)
            {
                layout.changeEditability('BU_Price_Per_Unit_Final__c', true);
            }
        } 

        wrapper.setupManualEntryOverrides(layout);

        //AMK-2350, hacks to change the cost and price editibility to false
        //it is changed to editable by disableAllEditibilityExcept method, used for attributeedit page
        for (RFQISectionAttribute attrib : layout.sectionMap.get('Cost and Price').attributes)
        {
            if (attrib.fieldAPIName == 'Forecast__c')
            {
                attrib.isEditable = false;
                break;
            }
        }
        //Ashish: 13-Apr-2017: SF-139: Renaming the section of passive Description for package family 'MEMS'.
        if(wrapper.packageFamily.Name=='MEMS'){
            sectionTitle='Other Components';            
        }
    }

    public PageReference importItem() {

        if (!RFQItemDao.getInstance().saveLineItem(wrapper)) return null;
        return new PageReference('/apex/RFQBUImport?edit=1&rfqItemId='+wrapper.rfqItem.Id);
    }

    //used to get only BU sections
    protected override RFQILayout getLayout(RFQItemWrapper itemWrapper)
    {
        return PFFieldDefDao.getInstance().getPackageFamilyLayout(itemWrapper.packageFamily.Id, itemWrapper.packageFamily.Layout_Version__c, itemWrapper.rfqItem.Layout_Version__c, 'BU');
    } 

    public override PageReference loadAction() {
        system.debug('Inside the RFQBUItemPriceEditController class loadAction method');
        if(wrapper.rfqItem.Status__c == RFQItemDao.STATUS_BU_DRAFT) {
            return new PageReference('/apex/RFQBUItemAttributeEdit?id='+wrapper.rfqItem.Id);
        }

        if(!getIsBUEditable()) {
            return new PageReference('/apex/RFQBUItemView?id='+wrapper.rfqItem.Id);
        }

        setNREInclusionDefaults(wrapper);
        
        return setupCostModel(wrapper, true, false);
        
    }
        
    //reload the previous saved item
    public override PageReference reloadOriginal() {
        PageReference pg = new PageReference('/apex/RFQBUItemPriceEdit?id='+wrapper.rfqItem.Id);
        pg.setRedirect(true);
        return pg;
    }

    //public PageReference importItem() {
    //    return new PageReference('/apex/RFQBUImport?rfqItemId='+wrapper.rfqItem.Id);
    //}

    public PageReference reAssign() {
        if(ApprovalUtils.isUnderApproval(wrapper.rfqItem.Id)){
            //Id workItemId = ApprovalUtils.getProcessInstanceWorkItem(wrapper.rfqItem.Id);      
            return new PageReference('/apex/RFQReassign?id=' + wrapper.rfqItem.Id + '&retURL=%2Fhome%2Fhome.jsp');
        }
        addError('This item is not under approval');
        return null;
    }

    public Boolean getCanEditAttributes() {
        return wrapper.rfqItem.Status__c == RFQItemDao.STATUS_BU_DRAFT;
    }

    public PageReference editAttributes() {
        return new PageReference('/apex/RFQBUItemAttributeEdit?id='+wrapper.rfqItem.Id);
    }
    
    public PageReference cancelEditPrice() {
        return new PageReference('/apex/RFQBUItemView?id=' + wrapper.rfqItem.Id);
    }
    
    public PageReference saveItemOnly() {
        //wrapper.rfqItem.BU_Price_Manually_Changed__c = true;

        List<String> missingFields = new List<String>();
        if (!validateVolumeConfigurations(wrapper))
        {
            String error = getVolumeConfigurationErrors(wrapper);
            if (!StringUtils.isBlank(error))
            {
                addError(error + '<br>');
            }
            if (missingFields.size() > 0)
            {
                error += 'Please fill out all required fields or fix errors before saving:<br />';
                for (String field : missingFields) 
                {
                    error += field + '<br />';
                }
                addError(error);
            }
            return null;
        }
        if(wrapper.packageFamily.Name == AMKVARS.PF_TEST) {
            //hacks to preserve the volumes for test because they are overwritten by setupCostModel
            String volumesToPreserve = JSON.serialize(wrapper.volumeList);
            setupCostModel();
            wrapper.rfqItem.Multi_Volume__c = volumesToPreserve;
            wrapper.inflateVolume();
        }
        else {
            system.debug('Yipeee i am FCBGA and in Else part ');
            setupCostModel(wrapper, false, false);
        }
        try{
            
            if (!RFQItemDao.getInstance().saveLineItem(wrapper, true, false)) return null;
            
        } catch (System.Dmlexception e){
            if(e.getDmlType(0)==StatusCode.ENTITY_IS_LOCKED){
                addError(System.label.RFQ_ERR_0007 + ' You may not have permission to edit this item.');
                return null;
            }else{
                throw e;
            }
        }
        DebugUtils.write('Refreshing Page');
        return new PageReference('/apex/RFQBUItemView?id=' + wrapper.rfqItem.Id);
    }    

    public PageReference repriceItem()
    {
        //uncheck the flag for the cost model to run again
        wrapper.rfqItem.Has_Been_BU_Imported__c = false;

       getAutoCostErrors();

        return setupCostModel();
    }

    public String getAmkorSelectedValues(){
        return 'Amkor Selected, Amkor Preferred, Amkor Specified, Amkor Recommended';
    }
}