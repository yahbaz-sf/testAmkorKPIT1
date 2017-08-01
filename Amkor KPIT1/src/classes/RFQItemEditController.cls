/*************************************************************************
*
* PURPOSE: Controller for the RFQ Item view/edit page
* 
* CLASS: RFQItemController
* CREATED: 3/12/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/
public virtual with sharing class RFQItemEditController extends RFQItemController{
    
    public static final Integer MAX_WIRE_CONFIGURATIONS = 16;
    public static final Integer MAX_PASSIVE_CONFIGURATIONS = 16;
    public static final Integer MAX_INSERTION_CONFIGURATIONS = 16;
    public static final Integer MAX_DIE_CONFIGURATIONS = 16;   
    public static final Integer MAX_NRE_CONFIGURATIONS = 16;
    //Ashish - 13-Apr-2017: SF-139: Creating variables to rename the section, Command Button, and Command Link of passive section for package family 'MEMS'. 
    public string sectionTitle {set;get;}
    public string passiveSectionButton {set;get;}
    public string passiveSectionLink {set;get;}
    
    public static final Set<String> CHILD_READ_ONLY_FIELDS = new Set<String>{
        'Tester_Avaliable__c',
        'Handler_Avaliable__c'
    };

    public static final Set<String> SPECIFICITEM_READ_ONLY_FIELDS = new Set<String> {
        'Test_Quote_Unit_of_Measure__c',
        'Test_Type__c',
        'Au_Adder__c', 
        'BU_Base_Price__c'
    };

    protected Map<String,List<RFQI_Default_Driver__c>> ddMap; 
    
    public RFQItemEditController(ApexPages.StandardController sc) {
        super(sc);
        //Ashish - 13-Apr-2017: SF-139: Assigning values to the variables to reflect in the section, Command Button, and Command Link of passive section for package families other than 'MEMS'. 
        sectionTitle='Passive Description';
        passiveSectionButton='Add Passive Configuration';
        passiveSectionLink='Remove Passive Configuration';

        ddMap = DefaultDriverDao.getDefaultDriversNameMap(wrapper.packageFamily.Id);
        
        system.debug('---->wrapper.specificRfqItem.Sales_BU_Price__c : ' + wrapper.specificRfqItem.get('Sales_BU_Price__c'));
        
        setEditabilityForChildFields(wrapper);
        
        //if edit, set layout to newest version
        if (wrapper.packageFamily.Layout_Version__c > wrapper.rfqItem.Layout_Version__c) {
            wrapper.rfqItem.Layout_Version__c = wrapper.packageFamily.Layout_Version__c;
            isLayoutDeprecated = false;
            layout = setupLayout(); 
        }
        
        //Ashish - 13-Apr-2017: SF-139: Assigning values to the variables to reflect in the section, Command Button, and Command Link of passive section for package familiy 'MEMS'. 
        if(wrapper.packageFamily.Name=='MEMS'){
            sectionTitle='Other Components';
            passiveSectionButton='Add Component Configuration';
            passiveSectionLink='Remove Component Configuration';            
        }
        
        

    }

    

    public void setEditabilityForChildFields(RFQItemWrapper itemWrapper) {
        if(wrapper.rfqItem.Test_Package_Type__c != null) {
            SPECIFICITEM_READ_ONLY_FIELDS.add('Assembly_Package_Name__c');
        }
        for(String fieldAPIName : CHILD_READ_ONLY_FIELDS) {
            layout.changeEditabilityForChild(fieldAPIName, false, itemWrapper.childObjectSections.values());
        }
        for(String fieldAPIName : SPECIFICITEM_READ_ONLY_FIELDS) {
            layout.changeEditability(fieldAPIName,false);
        }
    }

    //check if this user can even edit the record. If not, send them to the view screen
    public virtual PageReference loadAction(){
        system.debug('Inside the RFQItemEditController class loadAction method');
        if(!StringUtils.isBlank(wrapper.rfqitem.Opportunity__c) && StringUtils.isBlank(wrapper.rfqItem.RFQ__c)) {
            Opportunity o = [select Name,Id,AccountId,Projected_Revenue__c, RFQ__c, (SELECT Id FROM RFQ_Items__r) from Opportunity where Id =: wrapper.rfqItem.Opportunity__c];
            system.debug('---->RFQItemEditController.loadAction(), Opportunity : ' + o);
            RFQDao.createFromOpportunity(o);
            return new PageReference('/apex/RFQItemEdit?id=' + wrapper.rfqItem.Id);
        }
        
        //simply calling buEditRedirect() won't actually redirect
        //the page, checking the return value and redirecting 
        //the user if the pg is non-null..
        PageReference pg = buEditRedirect();//redirect if BU user
        if(pg != null) return pg;
        
        if(getIsProgramCancelled() || getIsBUDraft()){
            return new PageReference('/apex/RFQItemView?id=' + wrapper.rfqItem.Id+'&message=RFQ_MSG_0006');
        }

        setNREInclusionDefaults(wrapper);
        
        for(RFQISectionAttribute att : layout.sectionMap.get('Quote Information').attributes) {
            System.debug('\n Attribute : ' + att);
        }    
        //Lalit - 17-Jan-2017 : Salesforce-42 :Turnkey ATP with ultraFlex (TI)
        //calling the showOrHideFields method on the page load to hide/show the fields.
        showOrHideFields();
        return null;
    }

    //Lalit - 17-Jan-2017 : Salesforce-42 :Turnkey ATP with ultraFlex (TI)
    //Condition to show/Hide the (Insertion_Index_Time__c , Index_Time_Sec_Die_to_Die__c , Index_Time_Sec_Wafer_to_Wafer__c) values.
    public void showOrHideFields(){
        if(wrapper.packageFamily.Name == 'Test'){
            Id configObjectId;
            set<String> apiNamesInLowerCase;
            string val1 ='Index_Time_Sec_Die_to_Die__c' ;
            string val2= 'Index_Time_Sec_Wafer_to_Wafer__c';
            if(wrapper.wpInsertConfs != null && wrapper.wpInsertConfs.size() == 1) {
                configObjectId = wrapper.wpInsertConfs[0].conf.Id;
            }
            System.debug('configObjectId : '+configObjectId);
            if(wrapper.rfqItem.Test_Type__c == 'Wafer probe'){
                if(wrapper.childObjectSections.get(configObjectId) != null) {
                    wrapper.childObjectSections.get(configObjectId).hidefield('Insertion_Index_Time__c');
                }
            }else{
                if(wrapper.childObjectSections.get(configObjectId) != null) {
                    apiNamesInLowerCase = new set<String> {val1.toLowerCase(), val2.toLowerCase()};
                    system.debug('apiNamesInLowerCase : '+apiNamesInLowerCase);
                   wrapper.childObjectSections.get(configObjectId).hidefields(apiNamesInLowerCase); 
                }
            }
        }
    }
        public virtual PageReference reloadOriginal() {

        if(wrapper.rfqItem.Status__c == RFQItemDao.STATUS_NEW) {
            RFQItemDao iDao = RFQItemDao.getInstance();
            RFQItemWrapper newWrapper = iDao.createNewFromWrapper(wrapper);
            if(!iDao.deleteLineItem(wrapper)){
                addError('There was a problem deleting the line item. Please try again.');
            }            
            PageReference pg = new PageReference('/apex/RFQItemEdit?id=' + newWrapper.rfqItem.Id);
            pg.setRedirect(true);
            return pg;
        }
        return null;

    }
         
    public virtual PageReference saveItemAsDraft() {
        //validate multi volume configs
        system.debug('---->wrapper.rfqItem.Automotive__c : ' + wrapper.rfqItem.Automotive__c);
        system.debug('---->wrapper.rfqItem.End_Market_Segment__c : ' + wrapper.rfqItem.End_Market_Segment__c);
        //system.debug('---->wrapper.specificRfqItem.Automotive__c : ' + wrapper.specificRfqItem.get('Automotive__c'));
        system.debug('---->wrapper.specificRfqItem.End_Market_Segment__c : ' + wrapper.specificRfqItem.get('End_Market_Segment__c'));
        if (!validateVolumeConfigurations(wrapper))
        {
            String error = getVolumeConfigurationErrors(wrapper);
            if (!StringUtils.isBlank(error))
            {
                addError(error + '<br>');
            }
            return null;
        }
        
        wrapper.rfqItem.Status__c = RFQItemDao.STATUS_DRAFT;
        if (!RFQItemDao.getInstance().saveLineItem(wrapper)) return null;
        
        
        return new PageReference('/apex/RFQItemView?id='+ wrapper.rfqItem.Id);
        //return saveItem();
    }


    /**
    * This method is the underlying action for the Save and Clone button 
    * RFQ on the RFQ Item View page
    *
    * @returns PageReference TBD
    */
    public PageReference saveItemAsReady() {
        wrapper.rfqItem.Status__c = RFQItemDao.STATUS_READY_TO_PRICE;
        return saveItem();
    }
    
    /**
    * This method is the underlying action for the Save and Clone button 
    * RFQ on the RFQ Item View page
    *
    * @returns PageReference TBD
    */
    public PageReference saveItemAndClone() {
        wrapper.rfqItem.Status__c = RFQItemDao.STATUS_READY_TO_PRICE;
        PageReference pf = saveItem();

        // If saveItem does not validate then it should return null
        if (pf != null) {
            return cloneItem();    
        }
        
        return null;
    }
      
    /**
    * This method is the underlying action for cancel button on the RFQ Item 
    * Edit page.
    * 
    */
    public virtual PageReference cancelItem() {

        //if this is a new item we want to clean up
        //and go back to the rfq, else we just want to
        //hop out of edit mode
        if(isNewItem) {
            String rfqId = wrapper.rfqItem.RFQ__c;
            //clean up anything that was created
            RFQItemDao.getInstance().deleteLineItem(wrapper);
            //go back to RFQ view page.
            return new PageReference('/' + rfqId);
        }
        //if no redirection need return null
        return new PageReference('/apex/RFQItemView?id=' + wrapper.rfqItem.Id);
    }
    
    public PageReference onOtherFieldChange() {
        layout = setupLayout();
        return null;
    }

    public PageReference onDefaultDriverChange() {
        //AMK-2289 - need to save before running DD because multi volume configs were getting erased
        //when DDs were being run
        //Ashish - 03-May-2017 : Salesforce-190 :MLF Body Size Limitation Criteria Needed at RFQ Item Entry
        RFQItemWrapper temp = wrapper;
        wrapper = RFQItemDao.getInstance().refresh(wrapper);
        RFQItemWrapper tempWrapper = onDefaultDriverChange(wrapper);
        if(tempWrapper != null) {
            wrapper = RFQItemDao.getInstance().refresh(tempWrapper, true, true);
            wrapper = temp; // Overriding the value in wrapper with temp after saving for the entered values to be visible even after a wrong data entry.
            layout = setupLayout(wrapper);
            setEditabilityForPriceToCustomer();
            setEditabilityForChildFields(wrapper);
        }
        //Lalit - 17-Jan-2017 : Salesforce-42 :Turnkey ATP with ultraFlex (TI)
        //calling the showOrHideFields method on the page load to hide/show the fields on field change Event.
        showOrHideFields();
        return null;
    }
    public RFQItemWrapper onDefaultDriverChange(RFQItemWrapper itemWrapper) {
        DebugUtils.write('Before Limits', Limits.getQueries());
        
        String fieldName = getParam('fieldName');
        String objectId = getParam('objectId');
        String fieldValue = String.valueOf(itemWrapper.getAttribute(fieldName, objectId));
        String rfqItemId = itemWrapper.rfqitem.Id;
        system.debug('RFQItemEditController rfqItemId : '+rfqItemId);
        List<RFQI_Default_Driver__c> defaultDrivers = new  List<RFQI_Default_Driver__c>();

        if(ddMap.containsKey(fieldName)) {
            defaultDrivers = ddMap.get(fieldName);
        }

        //[select Child__r.Name,Child__r.Type__c,Child__r.Object__c,Child_Value__c,Driver__r.Name,
        //Driver_Value__c,Driver__r.Type__c,Driver__r.Object__c, Package_Family__r.Name,
        //Match_Def__r.Type__c,Read__c from RFQI_Default_Driver__c
        //where Package_Family__r.Name =: itemWrapper.packageFamily.Name and Driver__r.Name =: fieldName];

        for(RFQI_Default_Driver__c driver : defaultDrivers) {
            if(fieldName == driver.Driver__r.Name) {
                Object val = null;
                String childVal = driver.Child_Value__c;
                if(driver.Read__c) {
                    itemWrapper = RFQItemDao.getInstance().refreshForDD(itemWrapper, driver.Driver__r.Object__c, driver.Child__r.Object__c, driver.Package_Family__c, rfqItemId);
                    if(itemWrapper == null) break;
                    if(driver.Driver_Value__c != null){
                         
                        Object rawVal = itemWrapper.getAttribute(driver.Driver_Value__c, objectId);
                        
                        if(rawVal != null){
                            
                            String strVal = String.valueOf(rawVal);
                            if(!StringUtils.isBlank(strVal)) {
                                val = DataUtils.convert(strVal,driver.Child__r.Type__c);
                                if(driver.Driver__r.Object__c == RFQItemWrapper.PACKAGE_OBJECT) {
                                    itemWrapper.setAttribute(driver.Child__r.Name,driver.Child__r.Object__c,val);
                                    system.debug('line number 228 package object'+itemWrapper);
                                }
                                else{
                                    itemWrapper.setAttributeToSpecificObject(driver.Child__r.Name, val, objectId);
                                }
                            }
                        }
                    }
                }else if(driver.Apex__c){
                    itemWrapper = RFQItemDao.getInstance().refresh(itemWrapper, false, false);
                    
                    Type t = Type.forName(driver.Apex_Implementation__c);               
                    ApexDefaultDriver ApexDD = (ApexDefaultDriver)t.newInstance(); 
                    ApexDD.run(itemWrapper, objectId);
                }
                else if(fieldValue == driver.Driver_Value__c) {
                    val = DataUtils.convert(childVal,driver.Child__r.Type__c);
                    if(driver.Driver__r.Object__c == RFQItemWrapper.PACKAGE_OBJECT) {
                        itemWrapper.setAttribute(driver.Child__r.Name,driver.Child__r.Object__c,val);
                        system.debug('line number 247 package object'+itemWrapper);
                    }
                    else{
                        itemWrapper.setAttributeToSpecificObject(driver.Child__r.Name, val, objectId);
                    }
                }
            }
        }
        RFQItemDao.getInstance().simpleSaveForDD(itemWrapper);
        system.debug('RFQItemEditController rfqItemId   : '+rfqItemId);
        return RFQItemDao.getInstance().getWrapperById(rfqItemId);
    //    wrapper = RFQItemDao.getInstance().refresh(itemWrapper, true, true);
    //    layout = setupLayout(wrapper);
    //    return null;
    }

    public Boolean validateManualEntryFields(List<String> missingFields) {
        return wrapper.validateManualEntryFields(missingFields, layout);
    }

    //Adding wrapper methods so we can use the same functionality
    //in RFQBUItemAttributeEditController but operate on the cloned item
    //instead of the original wrapper object
    public virtual PageReference addWireConfiguration() {
        return addWireConfiguration(wrapper);
    }

    public virtual PageReference addPassiveConfiguration() {
        return addPassiveConfiguration(wrapper);
    }
    
    public virtual PageReference addDieConfiguration() {
        return addDieConfiguration(wrapper);
    }

    public virtual PageReference addInsertionConfiguration() {
        return addInsertionConfiguration(wrapper);
    }

    public virtual PageReference cloneInsertionConfiguration() {
        return cloneInsertionConfiguration(wrapper);
    }

    public virtual PageReference addServiceConfiguration() {
        return addServiceConfiguration(wrapper);
    }

    public virtual PageReference addNREConfiguration() {
        return addNREConfiguration(wrapper);
    }

    public virtual PageReference removeWireConfigurationById() {
         return removeWireConfigurationById(wrapper);
    }

    public virtual PageReference saveWireConfigurationById() {
         return saveWireConfigurationById(wrapper);
    }

    public virtual PageReference removeDieConfigurationById() {
         return removeDieConfigurationById(wrapper);
    }

    public virtual PageReference removeInsertionConfigurationById() {
         return removeInsertionConfigurationById(wrapper);
    }
   
    public virtual PageReference removePassiveConfigurationById() {
         return removePassiveConfigurationById(wrapper);
    }

    public virtual PageReference removeServiceConfigurationById() {
         return removeServiceConfigurationById(wrapper);
    }

    public virtual PageReference removeNREConfigurationById() {
         return removeNREConfigurationById(wrapper);
    }
    
    protected PageReference addDieConfiguration(RFQItemWrapper itemWrapper) {
        //Abhay 17-Jul-17 : SF-244 : Wire and Die config fields, must carry at least one[Making the local variable dieSectionError = null for rendering of the page].
        dieSectionError = null;
        //catching exception that validation rule will throw if user tries to add new die config
        try{
                //Add a new method to simplify this
            if (!RFQItemDao.getInstance().saveLineItem(itemWrapper)) return null;
            
            //AMK-670
            if(itemWrapper.dieConfigurations.size() == MAX_DIE_CONFIGURATIONS) {
                addError('Max number of die configurations added');
                return null;
                }
                 
            RFQItemDao.createDieObject(itemWrapper.packageFamily, itemWrapper.specificRfqItem.Id,1);
            BaseDao packageFamilyDieDao = new BaseDao(itemWrapper.packageFamily.Specific_Die_Configuration_Object__c);
            itemWrapper.dieConfigurations = packageFamilyDieDao.getSObjects('Parent__c = ' 
                                                                     + BaseDao.quote(itemWrapper.specificRfqItem.Id), 'CreatedDate');
            //itemWrapper.setupChildObjectSections(layout);
            layout = setupLayout();
        } 
        catch(System.Dmlexception ex){ //catch problems coming from the DAO
             if(canHandleException(ex)) return null;
             else throw ex;  
        }
     
        return null;  
    }
          
    /**
    * This method is the underlying action for the Add Wire Configuration button
    * RFQ Item View/Edit page. This method determines the particular wire config object
    * Instansiates one and links it up to the specific item object. 
    */
    protected PageReference addWireConfiguration(RFQItemWrapper itemWrapper) {
        //Abhay 17-Jul-17 : SF-244 : Wire and Die config fields, must carry at least one[Assigning the local variable wireSectionError = null for rendering the page].
        wireSectionError = null;
        try {
            if (!RFQItemDao.getInstance().saveLineItem(itemWrapper)) return null;

            //AMK-670     
            if(itemWrapper.wireConfigurations.size() == MAX_WIRE_CONFIGURATIONS) {
                addError('Max number of wire configurations added');
                return null;
            }

            RFQItemDao.createWireObject(itemWrapper.packageFamily, itemWrapper.specificRfqItem.Id,1);
            BaseDao packageFamilyWireDao = new BaseDao(itemWrapper.packageFamily.Specific_Wire_Configuration_Object__c);
            itemWrapper.wireConfigurations = packageFamilyWireDao.getSObjects( 'Parent__c = ' + BaseDao.quote(itemWrapper.specificRfqItem.Id), 'CreatedDate');
            itemWrapper.setupChildObjectSections(layout);
            layout = setupLayout();
        }
        catch (System.Dmlexception e) {
            if(canHandleException(e)) return null;
            else throw e;
        }
        return null;  
    }

    @TestVisible protected PageReference addPassiveConfiguration(RFQItemWrapper itemWrapper) {
        try {
            if (!RFQItemDao.getInstance().saveLineItem(itemWrapper)) return null;

            //AMK-670     
            if(itemWrapper.passiveConfigurations.size() == MAX_PASSIVE_CONFIGURATIONS) {
                addError('Max number of passive configurations added');
                return null;
            }

            RFQItemDao.createPassiveObject(itemWrapper.packageFamily, itemWrapper.specificRfqItem.Id,1);

            BaseDao packageFamilyWireDao = new BaseDao(itemWrapper.packageFamily.Specific_Passive_Configuration_Object__c);
            itemWrapper.passiveConfigurations = packageFamilyWireDao.getSObjects('Parent__c = ' + BaseDao.quote(itemWrapper.specificRfqItem.Id), 'CreatedDate');
            //itemWrapper.setupChildObjectSections(layout);
            layout = setupLayout();
        }
        catch (System.Dmlexception e) {
            if(canHandleException(e)) return null;
            else throw e;
        }
        return null;  
    }
    
    @TestVisible protected PageReference addInsertionConfiguration(RFQItemWrapper itemWrapper) {
        try {
            if (!RFQItemDao.getInstance().saveLineItem(itemWrapper)) return null;
            if(CreateRFQItemController.testTimeUOMs.contains((String)itemWrapper.specificRfqItem.get('Test_Quote_Unit_of_Measure__c')) && itemWrapper.insertionConfigurations.size() >= 1) {
                addError(insertionConfigMessage);
                return null;
            }

            //AMK-670     
            if(itemWrapper.insertionConfigurations.size() == MAX_INSERTION_CONFIGURATIONS) {
                addError('Max number of insertion configurations added');
                return null;
            }

            RFQItemDao.createInsertionObject(itemWrapper.packageFamily, itemWrapper.specificRfqItem.Id,1);
            BaseDao packageFamilyWireDao = new BaseDao(itemWrapper.packageFamily.Specific_Insertion_Configuration_Object__c);
            itemWrapper.insertionConfigurations = packageFamilyWireDao.getSObjects('Parent__c = ' + BaseDao.quote(itemWrapper.specificRfqItem.Id), 'CreatedDate');
            system.debug('itemWrapper RFQITmeEditController  line number 422 '+itemWrapper);
            //itemWrapper.setupChildObjectSections(layout);
            layout = setupLayout();
            system.debug('layout RFQITmeEditController  line number 425 '+layout);
            itemWrapper.indexConfigurations();
            system.debug('itemWrapper RFQITmeEditController  line number 427 '+itemWrapper);
            setEditabilityForChildFields(itemWrapper);

        }
        catch (System.Dmlexception e) {
            if(canHandleException(e)) return null;
            else throw e;
        }
        return null;  
    }

    @TestVisible protected PageReference cloneInsertionConfiguration(RFQItemWrapper itemWrapper) {
        try {
            if (!RFQItemDao.getInstance().saveLineItem(itemWrapper)) return null;

            //AMK-670     
            if(itemWrapper.insertionConfigurations.size() == MAX_INSERTION_CONFIGURATIONS) {
                addError('Max number of insertion configurations added');
                return null;
            }

            String insertionConfigId = getParam('insertionConfigId');

            if(itemWrapper.insertionConfigurations.size() < 1) {
                addError('You must have at least 1 Insertion to perform a clone');
                return null;
            }

            if(CreateRFQItemController.testTimeUOMs.contains((String)itemWrapper.specificRfqItem.get('Test_Quote_Unit_of_Measure__c')) && itemWrapper.insertionConfigurations.size() >= 1) {
                addError(insertionConfigMessage);
                return null;
            }

            sObject cloneConfig = null;

            for(sObject config : itemWrapper.insertionConfigurations){
                if(config.Id == insertionConfigId){
                     cloneConfig = config;
                }
            }

            if(cloneConfig == null){
                addError('Unable to perform clone. Please try again');
                return null;
            }
            
            RFQItemDao.cloneInsertionObject(itemWrapper.packageFamily, itemWrapper.specificRfqItem.Id, 1 , cloneConfig);
            BaseDao packageFamilyWireDao = new BaseDao(itemWrapper.packageFamily.Specific_Insertion_Configuration_Object__c);
            itemWrapper.insertionConfigurations = packageFamilyWireDao.getSObjects('Parent__c = ' + BaseDao.quote(itemWrapper.specificRfqItem.Id), 'CreatedDate');
            layout = setupLayout();
            itemWrapper.indexConfigurations();
            setEditabilityForChildFields(itemWrapper);
            return null;

        }
        catch (System.Dmlexception e) {
            if(canHandleException(e)) return null;
            else throw e;
        }
        return null;  
    }

    @TestVisible protected PageReference addServiceConfiguration(RFQItemWrapper itemWrapper) {
        try {
            if (!RFQItemDao.getInstance().saveLineItem(itemWrapper)) return null;

            //AMK-670     
            if(itemWrapper.serviceConfigurations.size() == MAX_INSERTION_CONFIGURATIONS) {
                addError('Max number of service configurations added');
                return null;
            }

            RFQItemDao.createServiceObject(itemWrapper.packageFamily, itemWrapper.specificRfqItem.Id,1);
            BaseDao packageFamilyWireDao = new BaseDao(itemWrapper.packageFamily.Specific_Service_Configuration_Object__c);
            itemWrapper.serviceConfigurations = packageFamilyWireDao.getSObjects('Parent__c = ' + BaseDao.quote(itemWrapper.specificRfqItem.Id), 'CreatedDate');
            //itemWrapper.setupChildObjectSections(layout);
            layout = setupLayout();
        }
        catch (System.Dmlexception e) {
            if(canHandleException(e)) return null;
            else throw e;
        }
        return null;  
    }

    @TestVisible protected PageReference addNREConfiguration(RFQItemWrapper itemWrapper) {
        try {
            if (!RFQItemDao.getInstance().saveLineItem(itemWrapper)) return null;

            //AMK-670     
            if(itemWrapper.serviceConfigurations.size() == MAX_NRE_CONFIGURATIONS) {
                addError('Max number of NRE configurations added');
                return null;
            }

            RFQItemDao.createNREObject(itemWrapper.packageFamily, itemWrapper.rfqItem.Id,1);
            BaseDao packageFamilyNREDao = new BaseDao('RFQI_NRE__c');
            itemWrapper.nreConfigurations = packageFamilyNREDao.getSObjects('Parent__c = ' + BaseDao.quote(itemWrapper.rfqItem.Id), 'CreatedDate');
            itemWrapper.setupChildObjectSections(layout);
            layout = setupLayout();
        }
        catch (System.Dmlexception e) {
            if(canHandleException(e)) return null;
            else throw e;
        }
        return null;  
    }

    //Abhay 17-Jul-17 : SF-244 : Wire and Die config fields, must carry at least one[Creating the local variable wireSectionError for handling the error message(Label.RFQ_ERR_0001) and for rendering the wire section].
    public String wireSectionError{get;set;}
    @TestVisible protected PageReference removeWireConfigurationById(RFQItemWrapper itemWrapper) {
        
        String wireConfigId = getParam('wireConfigId');
        //keep at least one wire configuration
        if(itemWrapper.wireConfigurations.size() == 1) {
              //Abhay 17-Jul-17 : SF-244 : Wire and Die config fields, must carry at least one[Assigning the local variable wireSectionError = Label.RFQ_ERR_0001 so that the error message 'You must have at least one Wire Configuration for an RFQ Item' is displayed].
			  wireSectionError = Label.RFQ_ERR_0001;
			  // addError(Label.RFQ_ERR_0001);
               return null;
        }else{
            //Abhay 17-Jul-17 : SF-244 : Wire and Die config fields, must carry at least one[Assigning the local variable wireSectionError = null so that the wire section renders the section null when there is more than one wire configuration].
            wireSectionError = null;
        }
        sObject removeConfig = itemWrapper.removeWireConfiguration(wireConfigId);
        RFQItemDao.deleteConfig(removeConfig);
        return null;
    } 


    @TestVisible protected PageReference removePassiveConfigurationById(RFQItemWrapper itemWrapper) {
        
        String passiveConfigId = getParam('passiveConfigId');
        if(itemWrapper.passiveConfigurations.size() < 1) {
            addError('You must have at least 1 Passive');
            return null;
        }
        sObject removeConfig = itemWrapper.removePassiveConfiguration(passiveConfigId);
        RFQItemDao.deleteConfig(removeConfig);
        return null;
    } 

    @TestVisible protected PageReference removeInsertionConfigurationById(RFQItemWrapper itemWrapper) {
        String insertionConfigId = getParam('insertionConfigId');
        if(itemWrapper.insertionConfigurations.size() < 1) {
            addError('You must have at least 1 Insertion');
            return null;
        }
        sObject removeConfig = itemWrapper.removeInsertionConfiguration(insertionConfigId);
        RFQItemDao.deleteConfig(removeConfig);
        itemWrapper.indexConfigurations();
        return null;
    } 
    
    /*
    This is the redesigned version of removeDieConfiguration. In this case,
    configurations are deleted by ID instead of index (more reliable) and the logic
    behind how this is done is hidden from controller in the ItemWrapper class.
    */
    
    //Abhay 17-Jul-17 : SF-244 : Wire and Die config fields, must carry at least one[Creating the local variable dieSectionError for handling the error label(Label.RFQ_ERR_00012) and rendering the page with the updated value].
    public String dieSectionError{get;set;}
    protected PageReference removeDieConfigurationById(RFQItemWrapper itemWrapper) {
        
        String dieConfigId = getParam('dieConfigId');       
        //keep at least one wire configuration
        if(itemWrapper.dieConfigurations.size() == 1) {
                //addError(Label.RFQ_ERR_0001);
                //Abhay 17-Jul-17 : SF-244 : Wire and Die config fields, must carry at least one[Assigning the local variable dieSectionError = Label.RFQ_ERR_00012 so that the error message 'You must have at least one Die Configuration for an RFQ Item' is displayed].
                dieSectionError = Label.RFQ_ERR_00012;
                return null;
        }else{
            //Abhay 17-Jul-17 : SF-244 : Wire and Die config fields, must carry at least one[Assigning the local variable dieSectionError = null so that the die section renders the section null when there is more than one die configuration].
            dieSectionError= null;
        }
        
        sObject removeConfig = itemWrapper.removeDieConfiguration(dieConfigId);   
        RFQItemDao.deleteConfig(removeConfig);
        return null;
    } 

    @TestVisible protected PageReference removeServiceConfigurationById(RFQItemWrapper itemWrapper) {
        
        String serviceConfigId = getParam('serviceConfigId');       
        //keep at least one wire configuration
        if(itemWrapper.serviceConfigurations.size() < 1) {
                addError('No Services to remove');
                return null;
        }
        
        sObject removeConfig = itemWrapper.removeServiceConfiguration(serviceConfigId);   
        RFQItemDao.deleteConfig(removeConfig);
        return null;
    } 

    protected PageReference removeNREConfigurationById(RFQItemWrapper itemWrapper) {
        
        String nreConfigId = getParam('nreConfigId');       
        //keep at least one wire configuration
        if(itemWrapper.nreConfigurations.size() < 1) {
                addError('No NREs to remove');
                return null;
        }
        
        sObject removeConfig = itemWrapper.removeNREConfiguration(nreConfigId);   
        RFQItemDao.deleteConfig(removeConfig);
        return null;
    } 
    /*
    This is based on removeWireConfigurationById. This method re-calculates the wire length fields
    for a specific wire configuration and the logic
    behind how this is done is hidden from controller in the ItemWrapper class.
    */
    protected PageReference saveWireConfigurationById(RFQItemWrapper itemWrapper) {
        
        try {
            String wireConfigId = getParam('saveWireConfigId');
            RFQItemDao.getInstance().saveWireConfigurationById(itemWrapper, wireConfigId);
        }
        catch (System.Dmlexception e) {
            if(canHandleException(e)) return null;
            else throw e;
        }
        
        return null;
    } 

    public Boolean getEditDualLeadframeWireMaterial()
    {
        return wrapper.productGroup.Name == 'Dual Leadframe';
    }

    public Boolean getCanEditFlipChipSubstrate()
    {
        return (wrapper.packageFamily.Name != 'FC CSP' && wrapper.packageFamily.Name != 'FC SCSP');
    }
}