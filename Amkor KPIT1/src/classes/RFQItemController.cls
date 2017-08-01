/*************************************************************************
*
* PURPOSE: Base Controller for the RFQ Item view/edit page
*
* CLASS: RFQItemController
* CREATED: 3/12/2012 Ethos Solutions - www.ethos.com  
* AUTHOR: Jason M. Swenski 
***************************************************************************/ 
public virtual with sharing class RFQItemController extends BaseController{
        
    public RFQItemWrapper wrapper {get; set;}
    public Boolean noCostModel {get; set;}
    public String cmType {get; private set;}
    public CMBuilder builder{get; set;} 
    public CMSettings costModelRunSettings {get; set;}
    public Boolean hasManualEntry {get; set;}
    public Boolean isNewItem {get; set;}
    public Boolean manualEntryVerified {get; set;}
    protected List<String> outputAttriuteList{get; set;}
    public Boolean isUnderApproval {get; set;}
    public RFQILayout layout {get; set;}
    public Boolean isLayoutDeprecated {get; set;}
    public String buPriceSummary {get;set;}
    public String projectDesc {get;set;}
        
    public List<RFQ_Item__c> relatedItems { get; set; }
    
    public String dieConfigMessage {get {return 'Die Configuration 1 represents the bottom die configuration on the chip'; }}
    public String insertionConfigMessage {get {return 'Time-Based Test Items are now limited to one Test Configuration'; }}

    //public Map<Id, RFQILayoutSection> childObjectSections { get; set; }
    public string debugString {get; set;}

     
    public RFQItemController(ApexPages.StandardController sc) {
        debugString = '';
        //buPriceSummary = '';
        projectDesc = 'Package Description';

        wrapper = RFQItemDao.getInstance().getWrapperById(sc.getRecord().Id);
        /***********Comment Abhay
            RFQItemDao.getInstance() will populate the fieldlist in the base dao. field list is the comma seperated value of RFQ Item fields 
            
        
        ***************/
        
        //layout = PFFieldDefDao.getInstance().getPackageFamilyLayout(wrapper.packageFamily.Id);
        layout = setupLayout();
        
        isUnderApproval = ApprovalUtils.isUnderApproval(wrapper.rfqItem.Id);
        layout.reRender(getIsAttributesEditableState(), wrapper.getHasParent()); 
        loadEditableOutputAttributes();
        layout.enabledSections.put('Cost and Price', false);
        isLayoutDeprecated = layout.currentLayoutVersion > layout.itemLayoutVersion;
            
        isNewItem = getParam('new') == '1';
        noCostModel = wrapper.packageFamily.No_Cost_Model__c || wrapper.rfqItem.Do_Not_Auto_Price__c;
        hasManualEntry = wrapper.packageFamily.Has_Manual_Entry_Fields__c;
        showMessage();
        costModelRunSettings = new CMSettings();

        Id cpnId = wrapper.rfqItem.Configured_Part_Number__c;
        if (!StringUtils.isBlank(cpnId)) {
            relatedItems = RFQItemDao.getInstance().getSimilarItems(cpnId, 10);
            
            // If some items found with same CPN, then remove from the list the one the user is currently looking at
            if (relatedItems.size() > 0) {
                for (Integer i = relatedItems.size() - 1; i >= 0; i--) {
                    if (StringUtils.isMatch(relatedItems.get(i).Id, wrapper.rfqItem.Id)) {
                        relatedItems.remove(i);
                    }
                }
            }
        }

        if (isLayoutDeprecated) addInfo('Layout of item is out of date. To see current layout, click "edit"');

        if(wrapper.packageFamily.Name == 'Final Test' || wrapper.packageFamily.Name == AMKVARS.PF_TEST) {
            buPriceSummary = 'BU Price Summary'; 
        }
        else if(wrapper.productGroup.Name == AMKVARS.PG_EGRSVC) projectDesc = 'Project Description';

        setEditabilityForPriceToCustomer();

        if (!StringUtils.isBlank(wrapper.packageFamily.Cost_Model_Implementation__c)) cmType = wrapper.packageFamily.Cost_Model_Implementation__c;
        else cmType = wrapper.productGroup.Cost_Model_Implementation__c;

    }

    public PageReference setEditabilityForPriceToCustomer() {
        if(shouldHidePriceToCustomer()) {
            layout.changeRendered('Price_To_Customer__c',false);

            if (RFQItemDao.pfsWithPriceBreakdown.contains(wrapper.packageFamily.Name) && wrapper.packageFamily.Inactive__c)
            {
                layout.changeRendered('Price_To_Customer_Hour__c',false);
                layout.changeRendered('Price_To_Customer_Minute__c',false);
            }
            else if (wrapper.packageFamily.Name == AMKVARS.PF_TEST) {
                layout.changeRendered('Post_Price_To_Customer__c',false);
            }
        }

        return null;
    }

    //Load output attributes which are editable in BU screen
    private void loadEditableOutputAttributes(){
        outputAttriuteList = new List<String>
        {
            'Total_Cost__c',
            'BU_Price_Perc_GM__c',
            'BU_Price__c',
            'BU_Price_Perc_Delta_To_Target__c',
            'Total_Perc_GM__c',
            'Assembly_GM_wo_Substrate__c',
            'BU_Margin__c',
            'Assembly__c',
            'Subs_Markup_Perc__c',
            'Substrate_Perc_Markup__c'
        };
    }

    public RFQILayout setupLayout() {
        return setupLayout(wrapper);
    }
    public RFQILayout setupLayout(RFQItemWrapper itemWrapper)
    {
        RFQILayout layout = getLayout(itemWrapper); 

        Decimal salesScreenColumns = itemWrapper.packageFamily.Product_Group__r.Sales_Screen_Columns__c;
        Decimal buScreenColumns = itemWrapper.packageFamily.Product_Group__r.BU_Screen_Columns__c;
        layout.setBUColumns(Integer.valueOf(bUScreenColumns));
        if(itemwrapper.packageFamily.Name == AMKVARS.PF_TEST){
            layout.setSalesColumns(4);
        }
        else {
            layout.setSalesColumns(Integer.valueOf(salesScreenColumns));
        }

        //setupChildObjectSections(layout);
        itemWrapper.setupChildObjectSections(layout);
        itemWrapper.calculateAttributeVisibility(layout);
        OtherFieldsChange(layout, itemWrapper);
        OtherFieldChange(layout);
        system.debug('RFQItemController layout : '+layout);
        system.debug('RFQItemController layout : '+itemWrapper);
        requiredFieldChange(layout, itemWrapper);
        return layout;
    }

    //used to get only Sales sections
    protected virtual RFQILayout getLayout(RFQItemWrapper itemWrapper){
        return PFFieldDefDao.getInstance().getPackageFamilyLayout(itemWrapper.packageFamily.Id, itemWrapper.packageFamily.Layout_Version__c, itemWrapper.rfqItem.Layout_Version__c, 'Sales');
    }

    //Loop over Other fields to check if they need to be added to the wrapper
    public void OtherFieldsChange(RFQILayout layout) {
        OtherFieldsChange(layout, wrapper);
    }
    public void OtherFieldsChange(RFQILayout layout, RFQItemWrapper itemWrapper) {
        Set<Id> objectIds = itemWrapper.childObjectSections.keySet();
        String fieldValue = null;
        Set<RFQISectionAttribute> attributeList = layout.getOtherFieldAttributes();
        for (RFQISectionAttribute attribute : attributeList) {
            fieldValue = null;
            if(attribute.objectType == RFQItemWrapper.PACKAGE_OBJECT) {
                fieldValue = String.valueOf(itemWrapper.getAttribute(attribute.fieldAPIName, RFQItemWrapper.PACKAGE_OBJECT, 0));
                addOtherField(fieldValue, attribute, layout, null);
            }
            else {
                for (Id objectId : objectIds) {
                    try{
                        fieldValue = String.valueOf(itemWrapper.getAttribute(attribute.fieldAPIName, objectId));
                        addOtherField(fieldValue, attribute, layout, objectId);
                    }
                    catch (Exception e) {
                        system.debug('Could not find field value on object Id: ' + e);
                    }  
                }
            }
        }
    }

    public void addOtherField(String fieldValue, RFQISectionAttribute attribute, RFQILayout layout, Id objectId) {
        if(fieldValue != null && attribute.otherFields.containsKey(fieldValue.toLowerCase())) {
            for (String fields : attribute.otherFields.get(fieldValue.toLowerCase())) { 
                for (RFQISectionAttribute attrib : layout.getAllAttributes()) {
                    if (attrib.fieldAPIName == fields) {
                        //attrib.changeSection();
                        if(attrib.objectType == RFQItemWrapper.PACKAGE_OBJECT){
                            layout.addAttribute(attrib, attrib.belongsToSection);
                        }
                        else{
                            layout.addChildAttribute(attrib, wrapper.childObjectSections.get(objectId));
                        }
                    }
                }
            }
        }
    }

    public void OtherFieldChange(RFQILayout layout) {
        //Loop over OtherAttributes, check if they contain other
        //if they do, add attribute 
        for(String fieldName : layout.getOtherFieldApiNames()) { 
            String fieldValue = String.valueOf(wrapper.getAttribute(fieldName, RFQItemWrapper.PACKAGE_OBJECT, 0));
            if(fieldValue != null && fieldValue.toLowerCase() == 'other') {
                layout.addAttributeForOtherField(fieldName);
            }
        }

    }

    public void requiredFieldChange(RFQILayout layout)
    {
        requiredFieldChange(layout, wrapper);
    }
    public void requiredFieldChange(RFQILayout layout, RFQItemWrapper itemWrapper)
    {
        Set<Id> objectIds = itemWrapper.childObjectSections.keySet();
        String fieldValue;
        Set<RFQISectionAttribute> attributeList = layout.getRequiredFieldAttributes();
        for (RFQISectionAttribute attribute : attributeList) 
        {
            fieldValue = null;
            if(attribute.objectType == RFQItemWrapper.PACKAGE_OBJECT) 
            {
                fieldValue = String.valueOf(itemWrapper.getAttribute(attribute.fieldAPIName, RFQItemWrapper.PACKAGE_OBJECT, 0));
                markFieldAsRequired(fieldValue, attribute, layout, null);
            }
            else 
            {
                for (Id objectId : objectIds) 
                {
                    try
                    {
                        fieldValue = String.valueOf(itemWrapper.getAttribute(attribute.fieldAPIName, objectId));
                        markFieldAsRequired(fieldValue, attribute, layout, objectId);
                    }
                    catch (Exception e) 
                    {
                        system.debug('Could not find field value on object Id: ' + e);
                    }  
                }
            }
        }
    }
    public void markFieldAsRequired(String fieldValue, RFQISectionAttribute attribute, RFQILayout layout, Id objectId) {
        if(fieldValue != null && attribute.requiredFields.containsKey(fieldValue.toLowerCase())) 
        {
            for (String field : attribute.requiredFields.get(fieldValue.toLowerCase())) 
            {

                //for parent item
                for (RFQISectionAttribute attrib : layout.getAllAttributes()) 
                {
                    if (attrib.fieldAPIName == field) 
                    {
                        attrib.isRequired = true;
                    }
                }
                
                //for child objects
                for (RFQILayoutSection section : wrapper.childObjectSections.values())
                {
                    system.debug('line number 264 section   : '+section);
                    for (RFQISectionAttribute attrib : section.attributes) 
                    {
                        system.debug('RFQItemController line 267 attrib:'+attrib);
                        if (attrib.fieldAPIName == field) 
                        {
                            attrib.isRequired = true;
                            system.debug('RFQItemController 258 attrib: ' +attrib);
                        }
                    }
                }


            }
        }
    }

    public PageReference submitItem() {
         
        try {
            //Lalit - 06-April-2017 : Salesforce-114 : Reject change to 'Return to Sales' during BU process for RFQI
            //Submit functionality will also work from the edit page if the status will be pricing declined.
            //if(getIsSubmitableState(){
            if(getIsSubmitableState() ||  wrapper.rfqItem.Status__c == 'Returned To Sales') {
               DebugUtils.write('submitItem');
               //calls hand made validation
               if(saveItem() == null) return null; 
               system.debug('wrappper.rfqitem'+wrapper.rfqItem);
               system.debug('wrappper.specificRfqItem'+wrapper.specificRfqItem);
               if(RFQItemDao.getInstance().statusLessOrEqual(wrapper.rfqItem, RFQItemDao.STATUS_PRICE_SUBMIT)) {
                   wrapper.rfqItem.Status__c = RFQItemDao.STATUS_PRICE_SUBMIT;
                   System.debug('status before:'+wrapper.rfqItem.Status__c);
                   RFQIStatusHistoryDao.getInstance().updateStatusHistory(wrapper);

                   if (!RFQItemDao.getInstance().saveLineItem(wrapper, true, true)) return null;
                }
                wrapper = RFQItemDao.getInstance().getWrapperById(wrapper.rfqItem.Id);
                calculatePrice();
                String newStatus = getNewStatusForSubmit();
                wrapper.rfqItem.Status__c = newStatus;
                 System.debug('status after:'+wrapper.rfqItem.Status__c);
                update wrapper.rfqItem;
                RFQIStatusHistoryDao.getInstance().updateStatusHistory(wrapper);
                
                ApprovalUtils.startApproval(wrapper.rfqItem.Id, Label.RFQ_MSG_0003);

                
                ////check if we need pre price approval routing
                //RFQItemApprovalRouting router = new RFQItemApprovalRouting(); 
                //RFQItemApprovalRouting.RFQItemRoute itemRoute = router.route(wrapper);
                
                //if(!itemRoute.isSuccess) { 
                //    addError(itemRoute.approvalError);
                //    return null;
                //}
                ////the wrapper will be saved in the calculatePrice()
                //if(itemRoute.itemRouteType == RFQItemApprovalRouting.RoutingType.NONE) {
                //    calculatePrice();                    
                //}
                ////check we need post price generation approval routing
                //itemRoute = router.route(wrapper);
                //if(!itemRoute.isSuccess) {
                //        addError(itemRoute.approvalError);
                //        return null;
                //}
            }

        //TODO - I think this second try catch can be removed since it would be handled
        // in saveItem
        } catch(System.Dmlexception ex){ //catch problems coming from the DAO
            if(ex.getDmlType(0)==StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
                addError(ex.getDmlMessage(0));
                return null;
            }else if(ex.getDmlType(0)==StatusCode.ENTITY_IS_LOCKED){
                addError(System.label.RFQ_ERR_0007);
                return null;
            }else{
                throw ex;
            }
        }

        //NOTE - This may cause workflow rules to execute change the status
        PageReference pg = new PageReference('/apex/RFQItemView?id=' + wrapper.rfqItem.Id);
        pg.setRedirect(true);
        return pg;
    }

    public String getNewStatusForSubmit()
    {
        return getNewStatusForSubmit(wrapper);
    }

    public static String getNewStatusForSubmit(RFQItemWrapper itemWrapper)
    {
        String newStatus;
        if (itemWrapper.packageFamily.Sales_Requires_Pre_Approval__c) 
        {
            newStatus = RFQItemDao.STATUS_SALES_REQ_PREAPPROVAL;
            if (itemWrapper.rfqItem.Package_Family_Name__c == AMKVARS.PF_TEST)
            {
                //---Pre-check if the item will go into sales or bu queue based on sales region
                //---If sales region cannot be found, then skip to bu review
                if (itemWrapper.rfqItem.RFQ__r.SBU_Name__r.Sales_Region__c == null || RFQRegionRoles.getIsInvalidRegion(itemWrapper.rfqItem.RFQ__r.SBU_Name__r.Sales_Region__c.toLowerCase()) || getSkipTPMQueues(itemWrapper))
                {
                    newStatus = RFQItemDao.STATUS_PRICE_PENDING_BU;
                }
            }
        }
        else
        {
            newStatus = RFQItemDao.STATUS_PRICE_PENDING_BU;
        }

        return newStatus;
    }

    @TestVisible private static Boolean getSkipTPMQueues(RFQItemWrapper itemWrapper) {
        Boolean skipQueue = false;
        String roleName = itemWrapper.rfqItem.Creator_Role_Name__c;
        if (roleName != null) {
            roleName = roleName.toLowerCase();
            String salesRegion = itemWrapper.rfqItem.RFQ__r.SBU_Name__r.Sales_Region__c.toLowerCase();
            skipQueue = RFQRegionRoles.getShouldSkipQueue(salesRegion, roleName);
        }

        return skipQueue;
    }

    //TODO - This is also bad, though I think the duplication has been removed
    public virtual PageReference setupCostModel() {        
        return setupCostModel(wrapper);
    }

    public PageReference setupCostModel(RFQItemWrapper itemWrapper) {        
        return setupCostModel(itemWrapper, true, true);
    }
    
    //added for situations where RFQItemWrapper name is not "wrapper"
    public PageReference setupCostModel(RFQItemWrapper itemWrapper, Boolean isUpdate){        
        return setupCostModel(itemWrapper, isUpdate, false);
    }

    public PageReference setupCostModel(RFQItemWrapper itemWrapper, Boolean isUpdate, Boolean isRerun){

        if (itemWrapper.rfqItem.Has_Amkor_Selected__c)
        {
            addError('Cannot price item if any attributes are "Amkor Selected", "Amkor Specified", or "Amkor Preferred".<br />Please reject and clone this item, and change the attributes.');
            return null;
        }

        if (itemWrapper.rfqItem.Status__c == RFQItemDao.STATUS_NEW || itemWrapper.rfqItem.Status__c == RFQItemDao.STATUS_DRAFT) 
        {
            return null;
        }
        //Check if there is any mannul entry field
        if (builder == null){
            builder = CMBuilder.getCMBuilderByWrapper(itemWrapper);
            //cmsettings is loaded for calculateAll, setupChangingOutputAtributes, and displayResults
            builder.loadSettings(itemWrapper, false);            
        }        
        




        // CalculateNew if it is the first time to calcualte the price
        if (itemWrapper.rfqItem.Status__c == RFQItemDao.STATUS_PRICE_SUBMIT) {          
            DebugUtils.write('calculateNew');                         
            builder.calculateNew(itemWrapper, costModelRunSettings);  
            return null;
        }

        Decimal adderCost = 0;
        try {
            // FIXME need to ask austin if there is a better way
            // to prevent problem where changing target price makes
            // The delta calculate off of post-adder BU price
            adderCost = (Decimal)wrapper.specificRfqItem.get('Adder_Cost__c');
            if (adderCost == null) adderCost = 0;
        } catch (Exception e) {}

        String changedAttribute = getParam('attrib');
        
        if (isOutputAttributes(changedAttribute)) {
            // calculate price for output changed -- I.E. BU Price, % Gm, and Target price Delta
            PageReference pf = setupChangingOutputAttributes(itemWrapper, changedAttribute); 

            // Add on any adder costs post-margin
            builder.processAdderCostRules(itemWrapper);

            return pf;
        }

        String marginField = builder.getFieldMap().get('margin');
        String marginNoSubs = builder.getFieldMap().get('marginNoSubstrate');
        Boolean invalidMargin = marginField != null && (Decimal)itemWrapper.specificRfqItem.get(marginField) >= 100;
        invalidMargin |= marginNoSubs != null && (Decimal)itemWrapper.specificRfqItem.get(marginNoSubs) >= 100;
        if (invalidMargin && !wrapper.packageFamily.Hide_Substrate_Multivolume__c) 
        {
            addError('Margin cannot be greater than or equal to 100. <br /> Please re-enter margin.');
            itemWrapper.clearPrices();
            return null;

        }

        if (itemWrapper.rfqItem.Has_Been_BU_Imported__c) return null;
        else if (isRerun || itemWrapper.specificRfqItem.get('BU_Price__c') == null  || itemWrapper.specificRfqItem.get('BU_Price__c') == 0 || changedAttribute == 'Adder_Cost__c' || (adderCost > 0 && builder.shouldProcessAdderCostRules())) { 
           
            DebugUtils.write('calculateAll');
            // Ashish - 17-Nov-2016 : Salesforce-107: Volume config RFQI's are not getting created and responded back to Sales
            // avoid recalculation when product group is MLF.
            if(itemwrapper.packageFamily.Product_Group_Name__c != 'MLF'){
                builder.calculateAll(itemWrapper, isUpdate, costModelRunSettings);

                // Add on any adder costs post-margin
                builder.processAdderCostRules(itemWrapper);            
            }
        }
        else if ((Decimal)itemWrapper.specificRfqItem.get('BU_Price__c') == 0) {
            DebugUtils.write('displayResults');                                           
            builder.displayResults(itemWrapper, isUpdate);
        }

        for (RFQIVolume volume : itemWrapper.volumeList)
        {
            Boolean hasSubstrate = CMBuilder.getHasSubstrate(itemWrapper);
            if (volume.needsRecalc != null && volume.needsRecalc) 
            {
                builder.calcMulti(itemWrapper, volume.index - 1, hasSubstrate);
            }
        }
        List<String> missingFields = new List<String>();
        manualEntryVerified = (wrapper.packageFamily.Has_Manual_Entry_Fields__c) ? validateManualEntryFields(itemWrapper, missingFields) : true;
        //copy to wrapper to send to process instance page
        itemWrapper.rfqItem.Manual_Entry_Verified__c = manualEntryVerified;
        
        if (hasManualEntry && !manualEntryVerified) {  
            //if sales submit price , do not add error message
            if (itemWrapper.rfqItem.Status__c != RFQItemDao.STATUS_PRICE_SUBMIT) {
                String error = getValidationErrors(itemWrapper);      
                addError(error);
            }

            //load the settings on submittal
            else if (itemWrapper.rfqItem.Status__c == RFQItemDao.STATUS_PRICE_SUBMIT) {
                builder.loadSettings(itemWrapper, true);                    
            }
            itemWrapper.clearPrices();
            return null;              
        }



        return null;
    }

    //to hide buttons 
    public Boolean getIsBUEditable() {
        if(wrapper.rfqItem.Status__c == RFQItemDao.STATUS_PRICE_COMPLETE) return false;
        if(RFQItemDao.getInstance().statusGreaterOrEqual(wrapper.rfqItem, RFQItemDao.STATUS_QUOTED)) return false;
        return true;
    }


    // TODO Should this be moved to the cost model?
    public virtual PageReference setupChangingOutputAttributes(RFQItemWrapper itemWrapper, String attributeName) {

        System.debug(LoggingLevel.ERROR, '#### output attr change: ' + attributeName);
        builder = CMBuilder.getCMBuilderByWrapper(itemWrapper);
        try {
            builder.onAttributeChange(itemWrapper, attributeName);
            itemWrapper.calculateAuPricing();
            
        }catch(Exception e){
            DebugUtils.write('cannot calculate price', e);
            DebugUtils.write('e.getStackTraceString()', e.getStackTraceString());
        }

        return null;
    }
 
    public virtual PageReference cloneItem() {
        return new PageReference('/apex/RFQItemClone?id=' + wrapper.rfqItem.Id);    
    }

    public PageReference refreshFactory() {
        return null;
    }

    /* Starts here */
    //Ashish 02-June-2017 : Salesforce 116 -Add Amkor Preferred picklist value under Factory for RFQI.
    public boolean getshowBUFactoryField(){
        return (wrapper.rfqitem.Factory__c).containsIgnoreCase('Preferred');
    }
    
    public List<SelectOption> getBUFactoryOptions(){
        System.debug('*** From BU Page');
        List<Factory__c> buFactories = getFactories();
        List<SelectOption> buFactoryOptions = getFactoryOptionsList(buFactories,true);
        return buFactoryOptions;
    }
    
    public List<SelectOption> getSalesFactoryOptions(){
        System.debug('*** From Sales Page');
        List<Factory__c> salesFactories = getFactories();
        List<SelectOption> salesFactoryOptions = getFactoryOptionsList(salesFactories,false);
        return salesFactoryOptions;
    }
    
    public List<Factory__c> getFactories(){
        List<Factory__c> allowedFactories = FactoryHelper.getAllowedFactoryList(wrapper, layout);

        if(wrapper.packageFamily.Name == 'PBGA') {
            String bodySize = String.valueOf(wrapper.getAttribute('Body_Size__c','Package',0));
            String moldProcessType = String.valueOf(wrapper.getAttribute('Mold_Process_Type__c','Package',0));
            if((bodySize == '23' || bodySize == '27' || bodySize == '31') && moldProcessType != 'CGM') {
                allowedFactories.add(FactoryDao.getInstance().getFactoryByName('P3'));
                //Lalit - 25-Jan-2017 : Salesforce-116 : Add Amkor Preferred picklist value under Factory for RFQI
                allowedFactories.add(FactoryDao.getInstance().getFactoryByName('Amkor Preferred'));
            }
            //Lalit - 25-Jan-2017 : Salesforce-116 : Add Amkor Preferred picklist value under Factory for RFQI
            else{
                allowedFactories.add(FactoryDao.getInstance().getFactoryByName('Amkor Preferred'));
            }
        }
        if(wrapper.productGroup.Name == 'Quad Leadframe') {
            String bodySize = String.valueOf(wrapper.getAttribute('Body_Size__c','Package',0));
            String leadCount = String.valueOf(wrapper.getAttribute('Lead_Count__c','Package',0));
            String packageFamilyName = wrapper.packageFamily.Name;
            FactoryUtil.getFactoryOptionsForQuad(allowedFactories, bodySize, leadCount, packageFamilyName);
        }
        return allowedFactories;
    }
    
    public List<SelectOption> getFactoryOptionsList(List<Factory__c> factories, Boolean isBUPage){
        List<SelectOption> factoryOptions = new List<SelectOption>();
        //Lalit 05-Jan-2017 Salesforce-100: Factory update changes Die Sales
        //If default factory is needed for a package family or a product group, add a condition in the below 'if' statement
        //to remove the value '--None--' and it displays the default factory. 
        if(wrapper.packageFamily.Name != 'Die Sales' && wrapper.productGroup.Name != 'MLF'){
            //List<SelectOption> results = new List<SelectOption>();
            factoryOptions.add(new SelectOption('', '--None--'));
        }
        for(Factory__c factory : factories){
            if(isBUPage && factory.Name.containsIgnoreCase('preferred')){
                continue;
            }
            else{
                factoryOptions.add(new SelectOption(factory.Id, factory.Name));
            }
        }
        return factoryOptions;
    }
    /*Ends Here */
    
    //Old Method - Deprecated.
    /*public List<SelectOption> getFactoryOptions() {
        List<Factory__c> allowedFactories = FactoryHelper.getAllowedFactoryList(wrapper, layout);
        
        if(wrapper.packageFamily.Name == 'PBGA') {
            String bodySize = String.valueOf(wrapper.getAttribute('Body_Size__c','Package',0));
            String moldProcessType = String.valueOf(wrapper.getAttribute('Mold_Process_Type__c','Package',0));
            if((bodySize == '23' || bodySize == '27' || bodySize == '31') && moldProcessType != 'CGM') {
                allowedFactories.add(FactoryDao.getInstance().getFactoryByName('P3'));
                //Lalit - 25-Jan-2017 : Salesforce-116 : Add Amkor Preferred picklist value under Factory for RFQI
                //allowedFactories.add(FactoryDao.getInstance().getFactoryByName('Amkor Preferred'));
            }
            //Lalit - 25-Jan-2017 : Salesforce-116 : Add Amkor Preferred picklist value under Factory for RFQI
            else{
                //allowedFactories.add(FactoryDao.getInstance().getFactoryByName('Amkor Preferred'));
            }
        }
        if(wrapper.productGroup.Name == 'Quad Leadframe') {
            String bodySize = String.valueOf(wrapper.getAttribute('Body_Size__c','Package',0));
            String leadCount = String.valueOf(wrapper.getAttribute('Lead_Count__c','Package',0));
            String packageFamilyName = wrapper.packageFamily.Name;
            FactoryUtil.getFactoryOptionsForQuad(allowedFactories, bodySize, leadCount, packageFamilyName);
        }
        
        //Lalit 05-Jan-2017 Salesforce-100: Factory update changes Die Sales
        //If default factory is needed for a package family or a product group, add a condition in the below 'if' statement
        //to remove the value '--None--' and it displays the default factory.
        List<SelectOption> results = new List<SelectOption>();
        if(wrapper.packageFamily.Name != 'Die Sales' && wrapper.productGroup.Name != 'MLF'){
            //List<SelectOption> results = new List<SelectOption>();
            results.add(new SelectOption('', '--None--'));
        }
        
        
        
            for (Factory__c factory : allowedFactories) {
                System.debug('*** Sales Found a factory: ' + factory.Name);
                System.debug('*** Sales Found a factory: ' + factory.Id);
                results.add(new SelectOption(factory.Id, factory.Name));
            }
            system.debug('results  : '+results);
        
        return results;
        
    }*/
    
    
    public Boolean getRenderFactorySection() {
        return wrapper.packageFamily.Has_Factory_Field__c;
    }
          
    public Boolean getIsEscalationPossible() {

        RFQItemDao itemDao = RFQItemDao.getInstance();
        if(getIsUnderApproval()) return false;
        
        //Ashish N - 24-July-2017 : Salesforce-251 : User cannot escalate an RFQI that has pricing, but in a Qual status.
        //Changed from 'STATUS_QUOTED' to 'STATUS_Qual' to increase the scope of 'escalate' button visibility.
        return itemDao.statusGreaterOrEqual(wrapper.rfqItem, RFQItemDao.STATUS_PRICE_COMPLETE) &&
        itemDao.statusLessOrEqual(wrapper.rfqItem, RFQItemDao.STATUS_Qual);
    }
    
    public Boolean getIsHybridUser() {
        return RFQSystemSettings.getIsHybridUser();
    }
     
    public Boolean getIsQuoted() {

        RFQItemDao itemDao = RFQItemDao.getInstance();
        if(wrapper.rfqItem.Status__c == RFQItemDao.STATUS_PROGRAM_WIN) return false;
        if(wrapper.rfqItem.Status__c == RFQItemDao.STATUS_NO_BID) return false;
        if(wrapper.rfqItem.Status__c == RFQItemDao.STATUS_PROGRAM_CANCELED) return false;
        return itemDao.statusGreaterOrEqual(wrapper.rfqItem, RFQItemDao.STATUS_QUOTED);
    }

    public Boolean getIsPriceComplete() {

        RFQItemDao itemDao = RFQItemDao.getInstance();
        if(wrapper.rfqItem.Status__c == RFQItemDao.STATUS_PROGRAM_WIN) return false;
        if(wrapper.rfqItem.Status__c == RFQItemDao.STATUS_NO_BID) return false;
        if(wrapper.rfqItem.Status__c == RFQItemDao.STATUS_PROGRAM_CANCELED) return false;
        return itemDao.statusGreaterOrEqual(wrapper.rfqItem, RFQItemDao.STATUS_PRICE_COMPLETE);
    }

    public Boolean getIsQual() {

        RFQItemDao itemDao = RFQItemDao.getInstance();
        //Bhanu 29 June 2016 Salesforce 69 Opportunity Stage Updation
        //return itemDao.statusGreaterOrEqual(wrapper.rfqItem, RFQItemDao.STATUS_WON_QUALIFICATION);
        return itemDao.statusGreaterOrEqual(wrapper.rfqItem, RFQItemDao.STATUS_Qual);
    }
   
    public Boolean getIsProgramCancelledPossible() {
        return wrapper.rfqItem.Status__c != RFQItemDao.STATUS_PRICE_ESCALATION &&
               wrapper.rfqItem.Status__c != RFQItemDao.STATUS_NO_BID;
    }
    
    public Boolean getIsSubmitableState() {
        if(getIsUnderApproval()) return false;
        return wrapper.rfqItem.Status__c == RFQItemDao.STATUS_NEW || 
               wrapper.rfqItem.Status__c == RFQItemDao.STATUS_DRAFT || 
               wrapper.rfqItem.Status__c == RFQItemDao.STATUS_PRICE_SUBMIT || 
               wrapper.rfqItem.Status__c == RFQItemDao.STATUS_READY_TO_PRICE || 
               wrapper.rfqItem.Status__c == RFQItemDao.STATUS_PREAPPROVAL_COMPLETE||
               //Ashish S - 26-May-2017 : Salesforce-114 : Reject change to 'Return to Sales' during BU process for RFQI
               //Buttons should be visible same as in the View of RFQI in New Status.
               wrapper.rfqItem.Status__c == RFQItemDao.STATUS_PRICE_DECLINED;
    }

    public Boolean getShowPriceToCustomerSave() {
        return (!shouldHidePriceToCustomer() || userCanApprove());
    }

    public Boolean shouldHidePriceToCustomer() {
        if(getIsUnderApproval()) return true;
        if(getIsSubmitableState()) return true;
        if(wrapper.rfqItem.Status__c == RFQItemDao.STATUS_PRICE_ESCALATION) return true;
        if(wrapper.rfqItem.Status__c == RFQItemDao.STATUS_PRICE_DECLINED) return true;
        if(wrapper.rfqItem.Status__c == RFQItemDao.STATUS_NO_BID) return true;
        if(wrapper.rfqItem.Status__c == RFQItemDao.STATUS_PROGRAM_WIN) return true; 
        if(wrapper.rfqItem.Status__c == RFQItemDao.STATUS_PRODUCTION_WIN) return true; 
        if(wrapper.rfqItem.Status__c == RFQItemDao.STATUS_PROGRAM_CANCELED) return true;
        if(wrapper.rfqItem.Status__c == RFQItemDao.STATUS_PROGRAM_LOSS) return true;
        if(wrapper.rfqItem.Status__c == RFQItemDao.STATUS_BU_DRAFT) return true; 

        return false;           
    }
    
    public Boolean getIsProgramCancelled() {
        return wrapper.rfqItem.Status__c == RFQItemDao.STATUS_PROGRAM_CANCELED;
    }

    public Boolean getIsBUDraft() {
        return wrapper.rfqItem.Status__c == RFQItemDao.STATUS_BU_DRAFT;
    }

    //this method seems to be a duplicate of IsEscalationPossible
    public Boolean getIsEscalatableState() {
        if(getIsUnderApproval()) return false;
        return wrapper.rfqItem.Status__c == RFQItemDao.STATUS_PRICE_COMPLETE;
    }

    public Boolean getIsAddServicePossible() {
        if(wrapper.rfqItem.Status__c == RFQItemDao.STATUS_NO_BID) return false;
        return wrapper.packageFamily.Name != 'Test' && wrapper.rfqItem.Service__c == 'Assembly';
    }

    public Boolean getIsReloadPossible() {
        //Ashish S - 26-May-2017 : Salesforce-114 : Reject change to 'Return to Sales' during BU process for RFQI
        //Added condition for Returned to Sales to display 'Restore Defaults' button.
        if(wrapper.rfqItem.Status__c == RFQItemDao.STATUS_NEW || wrapper.rfqItem.Status__c == RFQItemDao.STATUS_PRICE_DECLINED) return true;
        return false;
    }

    //TODO - move me to the RFQItemEditController
    public Boolean getShowEditButton() {
        if(getIsUnderApproval() && !userCanApprove()) return false;
        RFQItemDao itemDao = RFQItemDao.getInstance();
        if(itemDao.statusGreaterOrEqual(wrapper.rfqItem, RFQItemDao.STATUS_PROGRAM_LOSS)) {
            return false;
        }       
        return true;
    }

    public Boolean getIsUnderSalesApproval() {
        return wrapper.rfqItem.Status__c == RFQItemDao.STATUS_SALES_REQ_PREAPPROVAL;
    }

    public Boolean getIsUnderApproval() {
        if(isUnderApproval == null) {
             isUnderApproval = ApprovalUtils.isUnderApproval(wrapper.rfqItem.Id);
        }
        return isUnderApproval;
    }

    public Boolean getIsAttributesEditableState() {

        if(getIsUnderApproval() && !userCanApprove()) return false;
        RFQItemDao itemDao = RFQItemDao.getInstance();
        if(itemDao.statusGreaterOrEqual(wrapper.rfqItem, RFQItemDao.STATUS_PRICE_COMPLETE)) {
            return false;
        }       
        return true;
    }

    public Boolean getShowDraftButton()
    {
        RFQItemDao itemDao = RFQItemDao.getInstance();
        return (itemDao.statusLessOrEqual(wrapper.rfqItem, RFQItemDao.STATUS_READY_TO_PRICE));
    }

    public virtual Boolean getIsBuNreEditableState() {
        if (RFQItemDao.getInstance().statusGreaterOrEqual(wrapper.rfqItem, RFQItemDao.STATUS_PRICE_COMPLETE) && !RFQItemDao.getInstance().statusEqual(wrapper.rfqItem.Status__c, RFQItemDao.STATUS_PRICE_ESCALATION)) {
            return false;
        }
        return true;
    }
       
    public Boolean getIsEditableState() {
        
        if(getIsUnderApproval()) return false;
        RFQItemDao itemDao = RFQItemDao.getInstance();
        if(itemDao.statusGreaterOrEqual(wrapper.rfqItem, RFQItemDao.STATUS_PRICE_ESCALATION)) {
            return false;
        }  
        return true;
    }
    
    public PageReference buEditMode() {
        return new PageReference('/apex/RFQBUItemPriceEdit?id='+wrapper.rfqItem.Id);
    }
    
    public PageReference buViewMode() {
        return new PageReference('/apex/RFQBUItemView?id='+wrapper.rfqItem.Id);
    }
      
    public PageReference buEditRedirect() {
        if(RFQSystemSettings.getIsBUUser()) {
            return buEditMode();
        }
        return null;
    } 

     public PageReference buViewRedirect() {
        if(!StringUtils.isBlank(wrapper.rfqitem.Opportunity__c) && StringUtils.isBlank(wrapper.rfqItem.RFQ__c)) {
            return new PageReference('/apex/RFQOpItemView?id=' + wrapper.rfqItem.Id);
        }


        if(RFQSystemSettings.getIsBUUser()) {
            return buViewMode();
        }
        return null;
    }
     
    

    public Boolean canhandleException(Exception e) {
        if(e.getDmlType(0)==StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION) {
            addError(e.getDmlMessage(0));
            return true;
        }
        else if(e.getDmlType(0)==StatusCode.ENTITY_IS_LOCKED) {
            addError(System.label.RFQ_ERR_0007);
            return true;
        }
        return false;
    }

    public virtual void calculatePrice() {
        try {
            
            System.debug(LoggingLevel.ERROR, '##### call calculatePrice');
            setupCostModel();     
            //wrapper.rfqItem.Status__c = RFQItemDao.STATUS_PRICE_COMPLETE;        
            RFQItemDao.getInstance().saveLineItem(wrapper);
            
        }catch(Exception e) {
            addError('This item is marked as having a cost model in the system but something went wrong with the auto calculation. Is the cost model set on the Product Group?');
        }
    }

    public Boolean getIsCounterComparePossible() {
        return wrapper.rfqItem.Original_RFQ_Item__c != null;
    }

    public PageReference counterCompare() {
        return new PageReference('/apex/RFQItemDelta?id=' + wrapper.rfqItem.Id + '&otherId=' + wrapper.rfqItem.Original_RFQ_Item__c);
    }

    public PageReference defaultCompare() {
        return new PageReference('/apex/RFQItemDelta?id=' + wrapper.rfqItem.Id);
    }
    
    public PageReference addService() {
        String isSiP = (wrapper.rfqItem.SiP__c) ? '1' : '0';
        system.debug('inside the addService method : '+isSiP);
        return new PageReference('/apex/RFQItemAddService?rfqItemId=' + wrapper.rfqItem.Id + '&SiP=' + isSiP);
    }
   
    @TestVisible private Boolean pricesFieldsValid() {
        
        try { 
            if ((Decimal)wrapper.specificRfqItem.get('BU_Price__c') - (Decimal)wrapper.specificRfqItem.get('Price_To_Customer__c') > .00001) {
                    addError('You cannot save an RFQ Item with Price To Customer less than the BU Price');
                    return false;
            }
            }catch(Exception e){}
            
        try {

            if ((Decimal)wrapper.specificRfqItem.get('BU_Price_Unit__c') > (Decimal)wrapper.specificRfqItem.get('Unit_Price_To_Customer__c')) {
                    addError('You cannot save an RFQ Item with Unit Price To Customer less than the BU Price per Unit');
                    return false;
            }
            
        }catch(Exception e){}
            
        try {
            if ((Decimal)wrapper.specificRfqItem.get('BU_Price_Per_Hour__c') > (Decimal)wrapper.specificRfqItem.get('Per_Hour_Price_to_Customer__c')) {
                    addError('You cannot save an RFQ Item with Per Hour Price To Customer less than the BU Price per Hour');
                    return false;
            }
        }catch(Exception e){}
            
        try {
            if ((Decimal)wrapper.specificRfqItem.get('BU_Price_per_Minute__c') > (Decimal)wrapper.specificRfqItem.get('Per_Minute_Price_to_Customer__c')) {
                    addError('You cannot save an RFQ Item with Per Minute Price To Customer less than the BU Price per Minute');
                    return false;
            }
        
        } catch(Exception e){}

        try {
            if ((Decimal)wrapper.specificRfqItem.get('BU_Price_per_Minute__c') > (Decimal)wrapper.specificRfqItem.get('Price_To_Customer_Minute__c')) {
                    addError('You cannot save an RFQ Item with Price To Customer Minute less than the BU Price per Minute');
                    return false;
            }
        
        } catch(Exception e){}

        try {
            if ((Decimal)wrapper.specificRfqItem.get('BU_Price_per_Hour__c') > (Decimal)wrapper.specificRfqItem.get('Price_To_Customer_Hour__c')) {
                    addError('You cannot save an RFQ Item with Per Minute Price To Customer less than the BU Price per Hour');
                    return false;
            }
        
        } catch(Exception e){}
        
        return true;
    }
    
    
    //Ashish: SF-139:18-APRIL-2017. Validation for substrate desciption section to give error message for package family 'MEMS'
    private Boolean substrateValidate(){
     try{
        if ((wrapper.specificRfqItem.get('Substrate_Leadframe_type__c')=='Laminate'||wrapper.specificRfqItem.get('Substrate_Leadframe_type__c')=='Ceramic' || wrapper.specificRfqItem.get('Substrate_Leadframe_type__c')=='L2L') && (wrapper.packageFamily.Name=='MEMS') && (wrapper.specificRfqItem.get('Total_layer_count__c')==NULL)){
        addError('Select value for Total Layer Count in Substrate Description');
        return false;
        }
      } catch(Exception e){} 
        
        return true;
    
    }
    

    /**
    * This method is the underlying action for the Save button.
    * Moved here to centralize use and allow exception handling
    * @returns PageReference the RFQItemView
    */
    public PageReference saveItem() {
        
        //make sure we validate the BU price
        if(!pricesFieldsValid()) return null;
        
        //Ashish: SF-139:18-APRIL-2017. Validation for substrate desciption section to give error message for package family 'MEMS'
        if(!substrateValidate()) return null;
        List<String> missingFields = new List<String>();
        String error;
        if (!validateRequiredFields(wrapper, missingFields)) 
        {
            error = getValidationErrors(wrapper);
            addError(error);
            DebugUtils.write('Validation Error', error);
            return null;  
        }
        wrapper.rfqItem.Has_Amkor_Selected__c = validateAmkorSelected(wrapper);

        try{
            if (!RFQItemDao.getInstance().saveLineItem(wrapper)) return null;
            
        } catch (System.Dmlexception e){
            if(e.getDmlType(0)==StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
                addError(e.getDmlMessage(0));
                return null;
            }else if(e.getDmlType(0)==StatusCode.ENTITY_IS_LOCKED){
                addError(System.label.RFQ_ERR_0007);
                return null;
            }else{
                throw e;
            }
        }

        return new PageReference('/apex/RFQItemView?id=' + wrapper.rfqItem.Id);
    }

    //-- Per AMK-1314 the NRE Inclusion picklist must be set based on Product Group
   public void setNREInclusionDefaults(RFQItemWrapper itemWrapper){
        if(itemWrapper.rfqItem.NRE_Inclusion__c == null){
            if(itemWrapper.rfqItem.Product_Group_Name__c.equals('Dual Leadframe')){
                itemWrapper.rfqItem.NRE_Inclusion__c = 'If Applicable';
            }else{
                itemWrapper.rfqItem.NRE_Inclusion__c = 'Not Applicable'; 
            }
        }
    }

    public Boolean validateRequiredFields(RFQItemWrapper itemWrapper, List<String> missingFields) {
        return itemWrapper.validateRequiredFields(missingFields, layout);
    }

    public Boolean validateManualEntryFields(RFQItemWrapper itemWrapper, List<String> missingFields)
    {
        return itemWrapper.validateManualEntryFields(missingFields, layout);
    }

    public Boolean validateVolumeConfigurations(RFQItemWrapper itemWrapper)
    {
        return itemWrapper.validateVolumeConfigurations(layout);
    }

    public Boolean validateCostAndPriceSection(RFQitemWrapper itemWrapper, List<String> missingFields)
    {
        return itemWrapper.validateCostAndPriceSection(missingFields, layout);
    }

    private boolean isOutputAttributes(String attributeName){
        for(String s: outputAttriuteList)
            if(attributeName == s) return true;
        return false;
    }
    public String getValidationErrors(RFQItemWrapper itemWrapper)
    {
        return itemWrapper.getValidationErrors();
    }

    public Boolean validateAmkorSelected(RFQItemWrapper itemWrapper)
    {
        return itemWrapper.validateAmkorSelected();
    }

    public String getAmkorSelectedErrors(RFQItemWrapper itemWrapper)
    {
        return itemWrapper.getAmkorSelectedErrors();
    }

    public String getAutoPriceErrors(RFQItemWrapper itemWrapper)
    {
        return itemWrapper.getAutoPriceErrors();
    }

    public String getVolumeConfigurationErrors(RFQItemWrapper itemWrapper)
    {
        return itemWrapper.getVolumeConfigurationErrors();
    }

    public Boolean validateObject(RFQItemWrapper itemWrapper)
    {
        system.debug(LoggingLevel.Info,'itemWrapper.validateObject(new List<String>(), layout) : '+itemWrapper.validateObject(new List<String>(), layout));
        return itemWrapper.validateObject(new List<String>(), layout);
    }

    public String getAllValidationErrors(RFQItemWrapper itemWrapper)
    {
        return itemWrapper.getAllValidationErrors();
    }

    public PageReference viewRelatedItems() {
        return viewSimilarItems('simple');
    }
    
    public PageReference viewRelatedItemsAdvanced() {
        return viewSimilarItems('advanced');
    }
    
    public PageReference viewSimilarItems(String mode) {
        return new PageReference('/apex/RFQItemViewRelated?mode=' + mode + '&cpnId=' + wrapper.rfqItem.Configured_Part_Number__c + '&rfqItemId=' + wrapper.rfqItem.Id);
    }
    
    public Boolean getRelatedItemsVisible() {
        return relatedItems != null && relatedItems.size() > 0;
    }

    public virtual Boolean getShowNREAttributes()
    {
        return wrapper.rfqItem.Include_NRE_On_Quote__c || wrapper.rfqItem.NRE_Inclusion__c == 'If Applicable' || wrapper.rfqItem.NRE_Inclusion__c == 'Required';
    }

    public Boolean getIsWaferTestType(){
        Boolean isWafer = false;

        if(wrapper.packageFamily.Name == AMKVARS.PF_TEST && wrapper.specificRfqItem.get('Test_Type__c') != null){
            isWafer = wrapper.specificRfqItem.get('Test_Type__c') == AMKVARS.TT_PROBE ? true : false;
        }

        return isWafer;
    }

    public Boolean getPostTestServiceOnlyTestType(){
        Boolean postTestOnly = false;

        if(wrapper.packageFamily.Name == AMKVARS.PF_TEST && wrapper.specificRfqItem.get('Test_Type__c') != null){
            postTestOnly = wrapper.specificRfqItem.get('Test_Type__c') == AMKVARS.TT_POST ? true : false;
        }

        return postTestOnly;
    }
    //---Moved to this class in AMK-2144, sales approval
    public virtual PageReference gotoStandardApprovalWizard() {

        if (!userCanApprove()) 
        {
            addError(System.label.RFQ_ERR_0008);
            return null;
        }

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
            DebugUtils.write('errors', error);
            return null;
        }

         //Abhay- 19-Apr-17 SF-204-RFQI Test flow changes - Probe and Final Test 
        //Added an or condition for pricing escalation for SF-204 19F
        if(wrapper.packageFamily.Name == AMKVARS.PF_TEST && (wrapper.rfqItem.Status__c == RFQItemDao.STATUS_PRICE_PENDING_BU || wrapper.rfqItem.Status__c == RFQItemDao.STATUS_PRICE_ESCALATION)) {
            //hacks to preserve the volumes for test because they are overwritten by setupCostModel
            String volumesToPreserve = JSON.serialize(wrapper.volumeList);
            setupCostModel();
            if(!getIsTestAddedServicePostTestOnly()) {
                wrapper.rfqItem.Multi_Volume__c = volumesToPreserve;
                wrapper.inflateVolume();
            }
           
        }

        missingFields = new List<String>();
        manualEntryVerified = (wrapper.packageFamily.Has_Manual_Entry_Fields__c) ? validateManualEntryFields(wrapper, missingFields) : true;
        //copy to wrapper to send to process instance page
        wrapper.rfqItem.Manual_Entry_Verified__c = manualEntryVerified;
        
        if (hasManualEntry && !manualEntryVerified) {  
            //if sales submit price , do not add error message
            if (wrapper.rfqItem.Status__c != RFQItemDao.STATUS_PRICE_SUBMIT) {
                String error = getValidationErrors(wrapper);      
                addError(error);
            }
        }

        try {
            wrapper.clearPriceToCustomerIfRequired();
            if (!RFQItemDao.getInstance().saveLineItem(wrapper)) return null;
        }
        catch(Exception e) {

            if(canhandleException(e)) {
                addError(String.valueOf(e));
                return null;
            }
            else throw e;
        }

        
        PageReference pg =  ApprovalUtils.getStandardApprovalWizard(wrapper.rfqItem.Id);
        
        if(pg == null) {
            addError('This item is not currently being reviewed and therefore cannot be approved or rejected.');
        }

        return pg;
    }
    // Ashish - 10-Nov-2016 : Salesforce-107: Volume config RFQI's are not getting created and responded back to Sales
    // populate total cost in volume configs with total cost of RFQ item.
     public void populateTotalCostinVolumeconfig(){
       
        for(RFQIVolume volume : wrapper.volumeList){
            volume.costLessSubs = (Decimal)wrapper.specificRfqItem.get('Total_Cost__c');
           // system.debug(logginglevel.ERROR, 'volume.costLessSubs######### '+volume.costLessSubs);
           // system.debug(logginglevel.ERROR, 'wrapper.specificRfqItem.get(Total_Cost__c)######### '+wrapper.specificRfqItem.get('Total_Cost__c'));
        }
    }
    public void getAutoCostErrors()
    {
        //messages for when item cannot be auto submitted for some reason
        //added AMK-2064, MLF only when added
        List<String> missingFields = new List<String>();
        String error;
        validateRequiredFields(wrapper, missingFields);
        error = getAutoPriceErrors(wrapper);
        if (error != null && error != '' )
        {
            addInfo(error);
        }
    }

    public Boolean getSalesCanApprove()
    {
        return wrapper.packageFamily.Sales_Requires_Pre_Approval__c || wrapper.productGroup.Sales_Requires_Pre_Approval__c;
    }

    public Boolean userCanApprove()
    {
        return ApprovalUtils.getUserCanApprove(wrapper.rfqItem.Id);
    }
    
    public Boolean getIsSalesApprove()
    {
        return wrapper.rfqItem.Status__c == RFQItemDao.STATUS_SALES_REQ_PREAPPROVAL;
    }

    public Boolean getIsSalesUser()
    {
        return !RFQSystemSettings.getIsBUUser();
    }

    public Boolean getIsEngineeringService()
    {   
        return wrapper.packageFamily.Product_Group_Name__c == AMKVARS.PG_EGRSVC;
    }

    public Boolean getIsTestAddedServicePostTestOnly()
    {
        return wrapper.packageFamily.Name == AMKVARS.PF_TEST && wrapper.rfqItem.Service__c != 'Assembly' && (String)wrapper.specificRfqItem.get('Test_Type__c') == AMKVARS.TT_POST;
    }

    public Boolean getShowPostTestServiceCostAndPrice()
    {
        return RFQItemDao.getInstance().statusGreaterOrEqual(wrapper.rfqItem, RFQItemDao.STATUS_PRICE_COMPLETE);
    }
}