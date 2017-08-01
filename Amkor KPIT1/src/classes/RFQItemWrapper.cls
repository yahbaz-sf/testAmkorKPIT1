public class RFQItemWrapper implements Comparable{
    
    public static final String PACKAGE_OBJECT = 'Package';
    public static final String WIRE_OBJECT = 'Wire';
    public static final String DIE_OBJECT = 'Die';
    public static final String INSERTION_OBJECT = 'Insertion';
    public static final String PASSIVE_OBJECT = 'Passive';
    public static final String SERVICE_OBJECT = 'Service';
    public static final String NRE_OBJECT = 'NRE';
    
    public RFQ_Item__c rfqItem {get; set;}
    public sObject specificRfqItem {get; set;}
    public List<sObject> wireConfigurations {get; set;}
    public List<sObject> dieConfigurations {get; set;}
    public List<sObject> passiveConfigurations {get; set;}
    public List<sObject> insertionConfigurations {get; set;}
    public List<sObject> serviceConfigurations {get; set;}
    public List<sObject> nreConfigurations {get; set;}


    public List<RFQIConfigWrapper> wpInsertConfs {get; set;}

    //public RFQILayout layout {get; set;}
    public Package_Family__c packageFamily {get; set;}
    public Product_Group__c productGroup {get; set;}
    public Boolean noCostModel {get {return packageFamily.No_Cost_Model__c || rfqItem.Do_Not_Auto_Price__c;}}
    public List<AdderCharge> adderCharges { get; set; }
    public List<AdderCharge> lotCharges { get; set; }
    private transient RFQIValidation validator; 
    public Boolean manualEntryVerified {get; set;}
    private transient Map<String, Set<String>> fieldMap; 
    public List<RFQIVolume> volumeList {get; set;}
    public List<RFQI_Status_History__c> statusHistories {get; set;}

    public String factoryName { get; set; }

    public Map<Id, RFQILayoutSection> childObjectSections { get; set; }


    public Decimal basePrice { get; set; }
    public Decimal forecastMedian {get;set;}
    public Id parentVolId {get;set;}

    public DebugUtils debug {get {return DebugUtils.getInstance();} }
    
    public RFQItemWrapper() {}
    
    public RFQItemWrapper(RFQ_Item__c item, sObject specItem, List<sObject> wireConfigs,Package_Family__c packageFam, RFQILayout itemLayout) {
        
        this(item,specItem,wireConfigs,new List<sObject>(),packageFam,new Product_Group__c());
        //setLayout(itemLayout);
    }
    public RFQItemWrapper(RFQ_Item__c item, sObject specItem, List<sObject> wireConfigs,List<sObject> dieConfigs,List<sObject> passiveConfigs, 
                               List<sObject> insertionConfigs, List<sObject> serviceConfigs, Package_Family__c packageFam, Product_Group__c prodGroup) {

        this(item, specItem, wireConfigs, dieConfigs, passiveConfigs, insertionConfigs, serviceConfigs, packageFam, prodGroup, new List<RFQI_Status_History__c>());
    }   

    public RFQItemWrapper(RFQ_Item__c item, sObject specItem, List<sObject> wireConfigs,List<sObject> dieConfigs,List<sObject> passiveConfigs, 
                               List<sObject> insertionConfigs, List<sObject> serviceConfigs, Package_Family__c packageFam, Product_Group__c prodGroup, List<RFQI_Status_History__c> statusHists) {
        this(item, specItem, wireConfigs, dieConfigs, passiveConfigs, insertionConfigs, serviceConfigs, packageFam, prodGroup, statusHists, new List<sObject>());

    }

    public RFQItemWrapper(RFQ_Item__c item, sObject specItem, List<sObject> wireConfigs,List<sObject> dieConfigs,List<sObject> passiveConfigs, 
                               List<sObject> insertionConfigs, List<sObject> serviceConfigs, Package_Family__c packageFam, Product_Group__c prodGroup, List<RFQI_Status_History__c> statusHists, List<sObject> nreConfigs) {

        this(item,specItem,wireConfigs,dieConfigs,packageFam,prodGroup);
        passiveConfigurations = passiveConfigs;
        insertionConfigurations = insertionConfigs;
        system.debug('RFQItemWrapper  at line number 71  : '+insertionConfigurations);
        serviceConfigurations = serviceConfigs;
        statusHistories = statusHists;
        nreConfigurations = nreConfigs;


    }

    public RFQItemWrapper(RFQ_Item__c item, sObject specItem, List<sObject> wireConfigs,List<sObject> dieConfigs,
                                 Package_Family__c packageFam, Product_Group__c prodGroup) {
        
        rfqItem = item;
        specificRfqItem = specItem;
        wireConfigurations = wireConfigs; 
        dieConfigurations = dieConfigs;
        packageFamily = packageFam;
        productGroup = prodGroup;
    }
    
    public void inflateVolume() {
        system.debug('inflateVolume method  RFQItemWrapper class  #91'+rfqItem.Multi_Volume__c);
        if(StringUtils.isBlank(rfqItem.Multi_Volume__c)) {
            volumeList = new List<RFQIVolume>();
            system.debug('Inside if condition RFQItemWrapper #93');
        }
        else {
            system.debug('RFQItemWrapper #95 rfqItem.Multi_Volume__c  : '+rfqItem.Multi_Volume__c);
            volumeList = (List<RFQIVolume>)JSON.deserialize(rfqItem.Multi_Volume__c, List<RFQIVolume>.class);
            system.debug('RFQItemWrapper #97 volumeList  : '+volumeList);
        }
        //extra null check to be safe
        //this list could be null if the Multi_Volume__c field
        //is equal to the string 'null' (not the value null)
        //which could happen on a JSON.serialize of a null list
        if (volumeList == null)
        {
            volumeList = new List<RFQIVolume>();
        }
    }

    public void indexConfigurations() {
        wpInsertConfs = new List<RFQIConfigWrapper>();
        Integer i = 1;
        if(insertionConfigurations != null) {
            for(sObject s : insertionConfigurations) {
                wpInsertConfs.add(new RFQIConfigWrapper(i,s));
                i++;
            }
        }
        
    }


    public Set<String> getFieldsForObject(String objType) {
        if(fieldMap == null) return null;
        return fieldMap.get(objType);
    }

    public void setFieldMap(Map<String, Set<String>> fieldMap) {
        this.fieldMap = fieldMap;
    }

    public String getObjectAPIName(String objectType) {
        if(objectType == PACKAGE_OBJECT) return packageFamily.Specific_RFQ_Item_Object__c;
        if(objectType == WIRE_OBJECT) return packageFamily.Specific_Wire_Configuration_Object__c;
        if(objectType == DIE_OBJECT) return packageFamily.Specific_Die_Configuration_Object__c;
        if(objectType == PASSIVE_OBJECT) return packageFamily.Specific_Passive_Configuration_Object__c;
        if(objectType == INSERTION_OBJECT) return packageFamily.Specific_Insertion_Configuration_Object__c;
        if(objectType == NRE_OBJECT) return 'RFQI_NRE__c';
        return '';
    }

    public void calculateAuPricing() {
        DebugUtils.write('call au pricing');

        Decimal auPricing = 0;
        RFQ_Item__c tempRFQI = (RFQ_Item__c)specificRfqItem.getsObject('RFQ_Item__r');
        String billingFlag = (String)tempRFQI.RFQ__r.getsObject('SBU_Name__r').get('Gold_Billing_Flag__c');
        
        if ((billingFlag == 'Transactionally' || billingFlag == null) && specificRfqItem.get('BU_Price__c') != null) {
            try {
                Decimal prodAuPrice = (Decimal)productGroup.Au_Cost__c;
                Decimal baseAuPrice = (Decimal)tempRFQI.RFQ__r.SBU_Name__r.Customer_AU_Base_fml__c;
                for(sObject wireConfiguration : wireConfigurations) {
                    try{
                        auPricing += ((prodAuPrice - baseAuPrice)*(Decimal)wireConfiguration.get('Au_Factor__c')/1000).setScale(6);
                    }
                    catch(Exception e) {}
                }

                specificRfqItem.put('Au_Adder__c', String.valueOf(auPricing));
                Decimal baseBUPrice = (Decimal)specificRfqItem.get('BU_Price__c') - auPricing;
                specificRfqItem.put('BU_Base_Price__c', baseBUPrice);

            }
            catch(Exception e) {
                DebugUtils.write('broke au pricing', e);
                DebugUtils.write('e.getStackTraceString()', e.getStackTraceString());
            }
        }
        else if (billingFlag == 'Inclusive') {
            specificRfqItem.put('Au_Adder__c', 'Inclusive');
            specificRfqItem.put('BU_Base_Price__c', (Decimal)specificRfqItem.get('BU_Price__c'));
        }
    }
    
    //method called by controller to perform wrapper-specific
    //logic and return the sObject we want deleted by the DAO
    //(controller makes DAO request)
    public sObject removeWireConfiguration(String wireConfigId){
        sObject removeConfig = null;
        for(Integer i=0;i<wireConfigurations.size();i++){
            if(String.valueOf(wireConfigurations[i].Id).equals(wireConfigId)){
            removeConfig = wireConfigurations.remove(i);
            break;
        }
            }
        return removeConfig;
    }
    
    //method called by controller to perform wrapper-specific
    //logic and return the sObject we want deleted by the DAO
    //(controller makes DAO request)
    public sObject removeDieConfiguration(String dieConfigId){
        
        sObject removeConfig = null;
        for(Integer i=0;i<dieConfigurations.size();i++){
        if(String.valueOf(dieConfigurations[i].Id).equals(dieConfigId)){
            removeConfig = dieConfigurations.remove(i);
            break;
        }
        }
        return removeConfig;
    }

    public sObject removeInsertionConfiguration(String insertionConfigId){
        
        sObject removeConfig = null;
        for(Integer i=0;i<insertionConfigurations.size();i++){
            if(String.valueOf(insertionConfigurations[i].Id).equals(insertionConfigId)){
                removeConfig = insertionConfigurations.remove(i);
                break;
            }
        }

        return removeConfig;
    }

    public sObject removePassiveConfiguration(String passiveConfigId){
        
        sObject removeConfig = null;
        for(Integer i=0;i<passiveConfigurations.size();i++){
        if(String.valueOf(passiveConfigurations[i].Id).equals(passiveConfigId)){
            removeConfig = passiveConfigurations.remove(i);
            break;
        }
        }
        return removeConfig;
        }

    public sObject removeServiceConfiguration(String serviceConfigId){
        
        sObject removeConfig = null;
        for(Integer i=0;i<serviceConfigurations.size();i++){
            if(String.valueOf(serviceConfigurations[i].Id).equals(serviceConfigId)){
                removeConfig = serviceConfigurations.remove(i);
                break;
            }
        }
        return removeConfig;
    }

    public sObject removeNREConfiguration(String nreConfigId){
        
        sObject removeConfig = null;
        for(Integer i=0;i<nreConfigurations.size();i++){
            if(String.valueOf(nreConfigurations[i].Id).equals(nreConfigId)){
                removeConfig = nreConfigurations.remove(i);
                break;
            }
        }
        return removeConfig;
    }

    public Integer getNumberOfWireConfigurations() {
        return (wireConfigurations == null) ? 0 : wireConfigurations.size();
    }

    public Integer getNumberOfDieConfigurations() {
        return (dieConfigurations == null) ? 0 : dieConfigurations.size();
    }

    public Integer getNumberOfPassiveConfigurations() {
        return (passiveConfigurations == null) ? 0 : passiveConfigurations.size();
    }

    public Integer getNumberOfInsertionConfigurations() {
        return (insertionConfigurations == null) ? 0 : insertionConfigurations.size();
    }

    public Integer getNumberOfServiceConfigurations() {
        return (serviceConfigurations == null) ? 0 : serviceConfigurations.size();
    }

    public Integer getNumberOfNREConfigurations() {
        return (nreConfigurations == null) ? 0 : nreConfigurations.size();
    }
       
    public void setLayout(RFQILayout itemLayout) {
        //layout = itemLayout;
        
    }

    public void setForecastMedian() {
        if(rfqItem.Forecast_Median__c != null) forecastMedian = rfqItem.Forecast_Median__c;
        else forecastMedian = 0;
    }

    public Object getAttribute(String fieldName, String objectId) {
        List<sObject> objectsList = new List<sObject>(); 
        objectsList.add(specificRfqItem);
        system.debug('objectsList  : '+objectsList);
        objectsList.addAll(dieConfigurations);
        objectsList.addAll(wireConfigurations);            
        objectsList.addAll(passiveConfigurations);            
        objectsList.addAll(insertionConfigurations);
        objectsList.addAll(serviceConfigurations);
        objectsList.addAll(nreConfigurations);
        for(sObject obj : objectsList) {
            if(obj.get('Id') == objectId) {
                return obj.get(fieldName);
            }
        }          
        return null;  
    }

    public Object getAttribute(String fieldName,String objectType,Integer index) {
   
            if(objectType == PACKAGE_OBJECT) {
                return specificRfqItem.get(fieldName);  
            }
            else if(objectType == DIE_OBJECT) {
                return dieConfigurations[index].get(fieldName);
            } 
            else if(objectType == WIRE_OBJECT) {
                return wireConfigurations[index].get(fieldName);
            }
            else if(objectType == PASSIVE_OBJECT) {
                return passiveConfigurations[index].get(fieldName);
            }
            else if(objectType == INSERTION_OBJECT) {
                return insertionConfigurations[index].get(fieldName);
            }
            else if(objectType == SERVICE_OBJECT) {
                return serviceConfigurations[index].get(fieldName);
            }
            else if(objectType == NRE_OBJECT) {
                return nreConfigurations[index].get(fieldName);
            }
            return null;
    }

    public void setAttributeToSpecificObject(String fieldName, Object fieldValue, String objectId) {
        List<sObject> objectsList = new List<sObject>(); 
        objectsList.add(specificRfqItem);
        system.debug('specificRfqItem at line number 336  :'+specificRfqItem);
        objectsList.addAll(dieConfigurations);
        objectsList.addAll(wireConfigurations);            
        objectsList.addAll(passiveConfigurations);            
        objectsList.addAll(insertionConfigurations);
        objectsList.addAll(serviceConfigurations);
        objectsList.addAll(nreConfigurations);

        for(sObject obj : objectsList) {
            if(obj.get('Id') == objectId) {
                obj.put(fieldName, fieldValue);
            }
        }
    }

    /* Step 1: Get cost and price RFQSectionLayout from layout section map
    * Step 2: For that section layout, we loop over the attributes
    * Step 3: Call setAttribute using the field API name for each attribute
    * Step 4: Set each value to null
    */
    public void clearCostAndPrice(RFQILayout layout){

        RFQILayoutSection costAttributes = layout.sectionMap.get('Cost and Price');

        if (costAttributes != null) {
            for (RFQISectionAttribute row : costAttributes.attributes) {
                if (!row.preserveOnClone && row.fieldAPIName != 'BLANK' && row.fieldAPIName != 'Forecast__c')
                {
                    try {
                        Schema.DescribeFieldResult fieldInfo = FieldLabelHelper.getInstance().getFieldInfo(specificRfqItem, row.fieldAPIName);
                        Schema.DisplayType fieldType = fieldInfo.getType();

                        // Don't set to null if the field is a checkbox, as it will cause an exception when trying to save the object for PBGA
                        Object newVal = (fieldType == Schema.DisplayType.Boolean) ? false : null;
                        setAttribute(row.fieldAPIName, PACKAGE_OBJECT, newVal);
                    }
                    catch (Exception e) {
                        DebugUtils.Write('Error while clearing cost and price section: ' + e);
                        DebugUtils.write('e.getStackTraceString()', e.getStackTraceString());
                    }
                }
            }
        }
    }

    public void setAttribute(String fieldName,String objectType, Object value) {
        setAttribute(fieldName, objectType, value, true);
    }

    public void setAttribute(String fieldName,String objectType, Object value, Boolean overwriteVal) {
        if (objectType == PACKAGE_OBJECT) {
            Object prevVal = specificRfqItem.get(fieldName);
            if (prevVal == null || prevVal == 0 || overwriteVal) specificRfqItem.put(fieldName,value);
        }
        else if(objectType == DIE_OBJECT) {
            for (sObject dieConfig : dieConfigurations) {
                Object prevVal = dieConfig.get(fieldName);
                if (prevVal == null || prevVal == 0 || overwriteVal) dieConfig.put(fieldName,value);
            }
        }    
        else if(objectType == WIRE_OBJECT) {
            for (sObject wireConfig : wireConfigurations) {
                Object prevVal = wireConfig.get(fieldName);
                if (prevVal == null || prevVal == 0 || overwriteVal) wireConfig.put(fieldName,value);
            }
        }
        else if(objectType == PASSIVE_OBJECT) {
            for (sObject passiveConfig : passiveConfigurations) {
                Object prevVal = passiveConfig.get(fieldName);
                if (prevVal == null || prevVal == 0 || overwriteVal) passiveConfig.put(fieldName,value);
            }
        }
        else if(objectType == INSERTION_OBJECT) {
            for (sObject insertionConfig : insertionConfigurations) {
                Object prevVal = insertionConfig.get(fieldName);
                if (prevVal == null || prevVal == 0 || overwriteVal) insertionConfig.put(fieldName,value);
            }
        }
        else if(objectType == SERVICE_OBJECT) {
            for (sObject serviceConfig : serviceConfigurations) {
                Object prevVal = serviceConfig.get(fieldName);
                if (prevVal == null || prevVal == 0 || overwriteVal) serviceConfig.put(fieldName,value);
            }
        }
        else if(objectType == NRE_OBJECT) {
            for (sObject nreConfig : nreConfigurations) {
                Object prevVal = nreConfig.get(fieldName);
                if (prevVal == null || prevVal == 0 || overwriteVal) nreConfig.put(fieldName,value);
            }
        }
    }

    //returns true if object is valid
    public Boolean validateObject(List<String> missingFields, RFQILayout layout)
    {
        validator = new RFQIValidation(this, layout);
        return validator.validateRequiredFields(missingFields) && validator.validateManualEntryFields(missingFields) && !validator.hasAmkorSelected;
    }

    public boolean validateRequiredFields(List<String> missingFields, RFQILayout layout) 
    {   
        //setupChildObjectSections(layout);
        validator = new RFQIValidation(this, layout);
        system.debug('RFQItemWrapper validator : '+validator);
        system.debug('RFQItemWrapper validator.validateRequiredFields(missingFields) : '+validator.validateRequiredFields(missingFields));
        return validator.validateRequiredFields(missingFields);
    }

    public boolean validateManualEntryFields(List<String> missingFields, RFQILayout layout)
    {
        //setupChildObjectSections(layout);
        validator = new RFQIValidation(this, layout);
        return validator.validateManualEntryFields(missingFields);
    }

    public boolean validateVolumeConfigurations(RFQILayout layout)
    {
        //setupChildObjectSections(layout);
        validator = new RFQIValidation(this, layout);
        return validator.validateVolumeConfigurations();
    }

    public Boolean validateCostAndPriceSection(List<String> missingFields, RFQILayout layout)
    {
        validator = new RFQIValidation(this, layout);
        return validator.validateCostAndPriceSection(missingFields);
    }

    public String getAllValidationErrors()
    {
        String error = validator.getValidationErrors();
        if (error != null && error != '') error += '<br />';
        if(validator.hasAmkorSelected) {
            error += validator.amkorSelectedFields;
        }
        return error;
    }

    public String getValidationErrors()
    {
        return validator.getValidationErrors();
    }

    public Boolean validateAmkorSelected()
    {
        return validator.hasAmkorSelected;
    }

    public String getAmkorSelectedErrors()
    {
        return validator.amkorSelectedFields;
    }

    public String getAutoPriceErrors()
    {
        return validator.getAutoPriceErrors();
    }

    public String getVolumeConfigurationErrors()
    {
        return validator.getVolumeConfigurationErrors();
    }

    // For now, this method is only used for the sales NRE section
    public void calculateAttributeVisibility(RFQILayout layout) {
        if (layout != null && layout.enabledSections != null && layout.enabledSections.containsKey('NRE') && layout.enabledSections.get('NRE') && layout.sectionMap != null && layout.sectionMap.containsKey('NRE')) {
            for (RFQISectionAttribute nreAttribute : layout.sectionMap.get('NRE').attributes) {
                Object val = specificRfqItem.get(nreAttribute.fieldAPIName);
                nreAttribute.showOnSalesScreen = false;
                if (val != null && val instanceof Double && (Double)val > 0) {
                    //Double dVal = (Double)val;
                    //nreAttribute.showOnSalesScreen = dVal > 0;
                    nreAttribute.showOnSalesScreen = true;
                }
            }
            for (sObject nreConfig : nreConfigurations)
            {
                for (RFQISectionAttribute nreAttribute : childObjectSections.get(nreConfig.Id).attributes)
                {
                    nreAttribute.showOnSalesScreen = true;
                }
            }
        }
    }

    // FIXME Stole this from RFQItemController for a hotfix, we need to de-duplicate this method 
    // as well as the SetupLayout() method
    public void renderOtherFields(RFQILayout layout) {
        for(String fieldName : layout.getOtherFieldApiNames()) { 
            String fieldValue = String.valueOf(getAttribute(fieldName, RFQItemWrapper.PACKAGE_OBJECT, 0));
            if(fieldValue != null && fieldValue.toLowerCase() == 'other') {
                layout.addAttributeForOtherField(fieldName);
            }
        }
    }

    public void OtherFieldsChange(RFQILayout layout) {
        setupChildObjectSections(layout);
        Set<Id> objectIds = childObjectSections.keySet();
        String fieldValue = null;
        Set<RFQISectionAttribute> attributeList = layout.getOtherFieldAttributes();
        for (RFQISectionAttribute attribute : attributeList) {
            fieldValue = null;
            if(attribute.objectType == RFQItemWrapper.PACKAGE_OBJECT) {
                fieldValue = String.valueOf(getAttribute(attribute.fieldAPIName, RFQItemWrapper.PACKAGE_OBJECT, 0));
                addOtherField(fieldValue, attribute, layout, null);
            }
            else {
                for (Id objectId : objectIds) {
                    try{
                        fieldValue = String.valueOf(getAttribute(attribute.fieldAPIName, objectId));
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
                            layout.addChildAttribute(attrib, childObjectSections.get(objectId));
                        }
                    }
                }
            }
        }
    }

    public void clearPriceToCustomerIfRequired() {
        // Price to customer should never be populated if the item is pending BU review

        try {
            if (rfqItem.Status__c != null && RFQItemDao.STATUS_NO_COPY_PRICE_TO_CUSTOMER.contains(rfqItem.Status__c)) {
                rfqItem.Price_To_Customer__c = null;
                specificRfqItem.put('Price_To_Customer__c', null);              
            }
        }
        catch (Exception e) {
            System.debug('Exception while clearing price to customer: ' + e);
        }
    }
    
    public void clearPrices() {
        clearPrices(true);
    }

    public void clearPrices(Boolean clearPostTestPrices) {
        
        try {

            rfqItem.Price_To_Customer__c = null;
            rfqItem.BU_Price__c = null;
            specificRfqItem.put('Price_To_Customer__c', null); 
            specificRfqItem.put('BU_Price__c', null);
            specificRfqItem.put('Au_Adder__c', null);   
            specificRfqItem.put('BU_Base_Price__c', null);


            if (RFQItemDao.pfsWithPriceBreakdown.contains(packageFamily.Name) && packageFamily.Inactive__c)
            {

                specificRfqItem.put('Price_To_Customer_Hour__c', null); 
                specificRfqItem.put('BU_Price_Per_Hour__c', null);  
                specificRfqItem.put('BU_Price_per_Minute__c', null);    
                specificRfqItem.put('Price_To_Customer_Minute__c', null);
                specificRfqItem.put('CPU_Price_Second__c', null);
                specificRfqItem.put('Unit_Price_per_Test_Time__c', null);

                setAttribute('CPU_Price_Second__c', INSERTION_OBJECT, null); 

            }

            if(packageFamily.Name == AMKVARS.PF_TEST) {
                if(insertionConfigurations != null && insertionConfigurations.size() > 0) {
                    List<String> insertFields = new List<String>{'Insertion_Tester_Value__c', 'Insertion_Handler_Value__c', 'Insertion_BU_Cost__c', 'Equipment_Availability__c', 'Insertion_BU_Price_Monthly_Charge__c', 
                                                             'Insertion_BU_Price_Per_Hour__c', 'Insertion_BU_Price_Per_Second__c', 'BU_Price_Per_Unit_Final__c'};
                    for(sObject i : insertionConfigurations) {
                        for(String s : insertFields) {
                            setsObjectField(i, null, s);
                        }
                        setsObjectField(i, false, 'Insertion_Additional_CAPEX__c');             
                    }
                }

                if (clearPostTestPrices)
                {
                    if (specificRfqItem.get('Test_Type__c') != AMKVARS.TT_PROBE)
                    {
                        specificRfqItem.put('BU_Price_Lead_Scan__c', null);
                        specificRfqItem.put('BU_Price_Tape_and_Reel__c', null);
                        specificRfqItem.put('BU_Price_Ink_Mark__c', null);
                        specificRfqItem.put('BU_Price_Laser_Mark__c', null);
                        specificRfqItem.put('BU_Price_Other__c', null);
                        specificRfqItem.put('BU_Price_Pack__c', null);
                        specificRfqItem.put('BU_Price_Bake__c', null);
                        specificRfqItem.put('BU_Price_Drop_Ship__c', null);
                        specificRfqItem.put('BU_Price_De_Tape__c', null);
                        specificRfqItem.put('BU_Price_Burn_In__c', null);
                    }
                    else
                    {
                        specificRfqItem.put('BU_Price_Offline_Ink_Mark__c', null);
                        specificRfqItem.put('BU_Price_Wafer_Bake__c', null);
                        specificRfqItem.put('BU_Price_Wafer_Packing__c', null);
                    }
                    specificRfqItem.put('Post_Price_To_Customer__c', null);
                }

            }
        }

        catch (Exception e) {
            DebugUtils.write('Exception while clearing price to customer / BU Price: ' + e);
        }
    }

    public void setsObjectField(SObject obj, Object val, String fieldName) {
        try {
            obj.put(fieldName, val);
        }
        catch(Exception e) {
            System.debug('Could not set field: ' + e);
        }
    }



    public void setRejectedState() {
     
        clearPrices();
        rfqItem.Status__c = RFQItemDao.STATUS_PRICE_DECLINED;
    }

    /* - commenting out yet another instance of getDecimal...
    public Decimal getDecimal(sObject obj, String fieldName, Decimal defVal) 
    {
        if(obj.get(fieldName) == null) return defVal;
        return Decimal.valueOf(String.valueOf(obj.get(fieldName)));
            
    }*/

    public void copyBuPriceToCustomerPrice() {
        try {

            if (RFQItemDao.pfsWithPriceBreakdown.contains(packageFamily.Name) && packageFamily.Inactive__c)
            {
                Decimal priceCustomer = 0;
                specificRfqItem.put('Price_To_Customer_Hour__c',specificRfqItem.get('BU_Price_Per_Hour__c'));
                specificRfqItem.put('Price_To_Customer_Minute__c',specificRfqItem.get('BU_Price_per_Minute__c'));
                specificRfqItem.put('Price_To_Customer__c',specificRfqItem.get('BU_Price__c'));   

                if (specificRfqItem.get('BU_Price_Per_Hour__c') != null && (Decimal)specificRfqItem.get('BU_Price_Per_Hour__c') > 0)
                {
                    priceCustomer = (Decimal)specificRfqItem.get('Price_To_Customer_Hour__c');
                    DebugUtils.write('Price_To_Customer_Hour__c priceCustomer', priceCustomer);
                }
                else if(specificRfqItem.get('BU_Price_per_Minute__c') != null && (Decimal)specificRfqItem.get('BU_Price_per_Minute__c') > 0)
                {
                    priceCustomer = (Decimal)specificRfqItem.get('Price_To_Customer_Minute__c');
                    DebugUtils.write('Price_To_Customer_Minute__c priceCustomer', priceCustomer);
                }
                else if(specificRfqItem.get('BU_Price__c') != null && (Decimal)specificRfqItem.get('BU_Price__c') > 0)
                {
                    priceCustomer = (Decimal)specificRfqItem.get('Price_To_Customer__c');
                    DebugUtils.write('Price_To_Customer__c priceCustomer', priceCustomer);
                }
                rfqItem.Price_To_Customer__c = priceCustomer;

            }
            else
            {
                system.debug('RFQItemWrapper  BU_Price__c   : '+specificRfqItem.get('BU_Price__c'));
                specificRfqItem.put('Price_To_Customer__c', specificRfqItem.get('BU_Price__c'));
                system.debug('RFQItemWrapper  specificRfqItem' +specificRfqItem.get('Price_To_Customer__c'));
                rfqItem.Price_To_Customer__c = (Decimal)specificRfqItem.get('Price_To_Customer__c');
                if(packageFamily.Name == AMKVARS.PF_TEST) {
                    try{
                        system.debug('RFQItemWrapper  specificRfqItem' +specificRfqItem.get('BU_Post_Test_Price_Unit__c'));
                        specificRfqItem.put('Post_Price_To_Customer__c', specificRfqItem.get('BU_Post_Test_Price_Unit__c'));
                        system.debug('RFQItemWrapper  specificRfqItem' +specificRfqItem.get('Post_Price_To_Customer__c'));
                    }
                    catch(Exception e){}
                }
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.Error, 'Could not copy price to customer: ' + e);
        }
    }


    // FIXME This method really needs to be cleaned up
    public void setupBasePriceFromAdders(List<RFQ_Account_Adder_Cost__c> adderCosts, Map<Id, List<RFQ_Acct_Adder_Match_Crit__c>> additionalCriteria) {
        adderCharges = new List<AdderCharge>();

        Decimal newBasePrice = rfqItem.Price_To_Customer__c;
        if (newBasePrice == null) newBasePrice = 0;
        
        for (RFQ_Account_Adder_Cost__c adder : adderCosts) {
            Boolean addChargeItem = false;

            try {
                // If adder is an "Other" adder name, or the adder checkbox is checked on that item, then add the charge line
                addChargeItem = (adder.Is_Other_Adder__c || (Boolean)specificRfqItem.get(adder.Adder__r.RFQI_Field_Def__r.Name));
            }
            catch (Exception e) {
                System.debug(LoggingLevel.Error, '### Caught exception while setting up adder charge: ' + e);
            }

            if (addChargeItem) {
                Decimal chargeAmount = adder.Charge_Amount__c;

                if (additionalCriteria.containsKey(adder.Id)) {
                    List<RFQ_Acct_Adder_Match_Crit__c> overrides = additionalCriteria.get(adder.Id);

                    for (RFQ_Acct_Adder_Match_Crit__c ovRide : overrides) {
                        Boolean isMatch = false;

                        // Sigh... The things we have to do when dealing with generic objects...
                        try { 
                            // Try match based on one dimensional body size (ie. just "19")
                            String bodySize = String.valueOf(specificRfqItem.get('Body_Size__c')); 
                            if (ovRide.Body_Size__c.contains(bodySize)) isMatch = true;
                        } catch (Exception e) {}

                        try {
                            // Try match based on two dimensional body size (i.e. "19x19")
                            String bodySize = StringUtils.sanitize(String.valueOf(specificRfqItem.get('Body_X__c'))) + 'x' + StringUtils.sanitize(String.valueOf(specificRfqItem.get('Body_Y__c')));
                            if (StringUtils.isMatch(ovRide.Body_Size__c, bodySize)) isMatch = true;
                        } catch (Exception e) {}

                        try {
                            String bodySize = StringUtils.sanitize(String.valueOf(specificRfqItem.get('Body_Size_X__c'))) + 'x' + StringUtils.sanitize(String.valueOf(specificRfqItem.get('Body_Size_Y__c')));
                            if (StringUtils.IsMatch(ovRide.Body_Size__c, bodySize)) isMatch = true;
                        } catch (Exception e) {}

                        try {
                            String leadCount = String.valueOf(specificRfqItem.get('Lead_Count__c'));
                            if (StringUtils.IsMatch(String.valueOf(ovRide.Lead_Ball_Count__c), leadCount)) isMatch = true;
                        } catch (Exception e) {}

                        try {
                            String ballCount = String.valueOf(specificRfqItem.get('Ball_Count__c'));
                            if (StringUtils.IsMatch(String.valueOf(ovRide.Lead_Ball_Count__c), ballCount)) isMatch = true;
                        } catch (Exception e) {}

                        try {
                            String deviceName = String.valueOf(specificRfqItem.get('Customer_Device_Name__c'));
                            if (StringUtils.IsMatch(String.valueOf(ovRide.Customer_Device_Name__c), deviceName)) isMatch = true;
                        } catch (Exception e) {}

                        if (isMatch) {
                            chargeAmount = ovRide.Charge_Amount__c;
                        }
                    }
                }

                String fieldName = null;

                if (adder.Is_Other_Adder__c) {
                    fieldName = adder.Other_Name__c;
                }
                else {
                    String pfName = adder.Adder__r.Package_Family__r.Specific_RFQ_Item_Object__c;
                    fieldName = FieldLabelHelper.getInstance().getLabel(pfName, adder.Adder__r.RFQI_Field_Def__r.Name);
                }

                newBasePrice -= chargeAmount;

                adderCharges.add(new AdderCharge(fieldName, chargeAmount));
            }
        }


        basePrice = newBasePrice;
    }

    /**
     *  This method is for copying Opp fields to the wrapper
     */
     public void copyOppFieldsToWrapper(Opportunity opp) {
        try{
            specificRfqItem.put('Decision_To_Buy__c', opp.CloseDate);
        } catch (Exception e) {
            System.Debug(LoggingLevel.Error, 'Could not copy field Customer Decision To Buy Date: ' + e);
        }
        try{
            specificRfqItem.put('Forecast__c', opp.Weekly_K_Units__c);
        } catch (Exception e) {
            System.Debug(LoggingLevel.Error, 'Could not copy field Forecast: ' + e);
        }
     }

    /**
     *  This method is for service items, if there is a parent then copy the fields down from it
     */
    public void copyServiceFieldsFromParent(RFQItemWrapper parent) {
        try {
            specificRfqItem.put('Assembly_Package_Name__c', parent.packageFamily.Name);
        } catch (Exception e) {
            System.Debug(LoggingLevel.Error, 'Could not copy field assembly name: ' + e);
        }

        try {
            specificRfqItem.put('Body_Size__c', parent.getBodySize());
        } catch (Exception e) {
            System.debug(LoggingLevel.Error, 'Could not copy field Body_Size__c from parent: ' + e);
        }

        try {
            specificRfqItem.put('Ball_Lead_Count__c', parent.getBallLeadCount());
        } catch (Exception e) {
            System.debug(LoggingLevel.Error, 'Could not copy field Ball_Lead_Count__c: ' + e);
        }

        try {
            rfqItem.put('HVP_Anticipated_Start_Date__c', parent.rfqItem.get('HVP_Anticipated_Start_Date__c'));
        } catch (Exception e) {
            System.debug(LoggingLevel.Error, 'Could not copy field HVP_Anticipated_Start_Date__c:' + e);
        }
    }

    public void copyServiceFieldsFromParentNew(RFQItemWrapper parent) {
        try {
            specificRfqItem.put('Assembly_Package_Name__c', parent.packageFamily.Name);
        } catch (Exception e) {
            System.Debug(LoggingLevel.Error, 'Could not copy field assembly name: ' + e);
        }
        try {
            specificRfqItem.put('Ball_Lead_Count__c', parent.getBallLeadCount());
        } catch (Exception e) {
            System.debug(LoggingLevel.Error, 'Could not copy field Ball_Lead_Count__c: ' + e);
        }
        try {
            rfqItem.put('HVP_Anticipated_Start_Date__c', parent.rfqItem.get('HVP_Anticipated_Start_Date__c'));
        } catch (Exception e) {
            System.debug(LoggingLevel.Error, 'Could not copy field HVP_Anticipated_Start_Date__c:' + e);
        }
        try {
            specificRfqItem.put('Body_Size__c', parent.getBodySize());
        } catch (Exception e) {
            System.debug(LoggingLevel.Error, 'Could not copy field Body_Size__c from parent: ' + e);
        }
        try {
            specificRfqItem.put('Body_Size_X__c', parent.getBodySizeX());
        } catch (Exception e) {
            System.debug(LoggingLevel.Error, 'Could not copy field Body_Size__c from parent: ' + e);
        }
        try {
            specificRfqItem.put('Body_Size_Y__c', parent.getBodySizeY());
        } catch (Exception e) {
            System.debug(LoggingLevel.Error, 'Could not copy field Body_Size__c from parent: ' + e);
        }
        try {
            specificRfqItem.put('Body_Size_Z__c', parent.getBodySizeZ());
        } catch (Exception e) {
            System.debug(LoggingLevel.Error, 'Could not copy field Body_Size__c from parent: ' + e);
        }
        try {
            specificRfqItem.put('Body_Size_Z__c', parent.getBodySizeZ());
        } catch (Exception e) {
            System.debug(LoggingLevel.Error, 'Could not copy field Body_Size__c from parent: ' + e);
        }
        try {
            specificRfqItem.put('Assembly_Plant__c', (String)parent.specificRfqItem.getSobject('Factory__r').get('Name'));
        } catch (Exception e) {
            System.debug(LoggingLevel.Error, 'Could not copy field Factory field from parent: ' + e);
        }
        try {
            if(packageFamily.Name != AMKVARS.PF_BUMP && rfqItem.Test_Type__c != AMKVARS.TT_PROBE && packageFamily.Name != 'Die Processing Service (WLCSP)' &&  packageFamily.Name != 'WLCSP' && packageFamily.Name != 'Die Processing Service' && packageFamily.Name != AMKVARS.PF_WLCSP) {
                specificRfqItem.put('Forecast__c', (String)parent.specificRfqItem.get('Forecast__c'));  
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.Error, 'Could not copy field Forecast field from parent: ' + e);
        }
        try {
            specificRfqItem.put('Customer_Project_Name__c', (String)parent.specificRfqItem.get('Customer_Project_Name__c'));
        } catch (Exception e) {
            System.debug(LoggingLevel.Error, 'Could not copy field Customer Project Name field from parent: ' + e);
        }
        try {
            specificRfqItem.put('Customer_Device_Name__c', (String)parent.specificRfqItem.get('Customer_Device_Name__c'));
        } catch (Exception e) {
            System.debug(LoggingLevel.Error, 'Could not copy field Customer Device Name field from parent: ' + e);
        }
        try {
            specificRfqItem.put('Competitor__c', (String)parent.specificRfqItem.get('Competitor__c'));
        } catch (Exception e) {
            System.debug(LoggingLevel.Error, 'Could not copy field Competitor field from parent: ' + e);
        }
        try {
            specificRfqItem.put('Decision_To_Buy__c', (Date)parent.specificRfqItem.get('Decision_To_Buy__c'));
        } catch (Exception e) {
            System.debug(LoggingLevel.Error, 'Could not copy field Competitor field from parent: ' + e);
        }
        try {
            specificRfqItem.put('End_Market_Segment__c', (String)parent.specificRfqItem.get('End_Market_Segment__c'));
        } catch (Exception e) {
            System.debug(LoggingLevel.Error, 'Could not copy field Competitor field from parent: ' + e);
        }
    }

    public Decimal getBodySizeX() {
        String tempBody = '';
        try {

         String [] tempBodyX = StringUtils.sanitize(String.valueOf(specificRfqItem.get('Body_Size__c'))).split('x');
         tempBody = tempBodyX[0];

       } catch(Exception e) {}
        try {
            tempBody = StringUtils.sanitize(String.valueOf(specificRfqItem.get('Body_Size__c')));
       } catch(Exception e) {}
       try {
           if (StringUtils.isBlank(tempBody)) tempBody = StringUtils.sanitize(String.valueOf(specificRfqItem.get('Body_X__c')));
        }catch(Exception e){}
         try {
           if (StringUtils.isBlank(tempBody)) tempBody = StringUtils.sanitize(String.valueOf(specificRfqItem.get('Body_Size_X__c')));
        }catch(Exception e){}
        try {
            return Decimal.ValueOf(tempBody);
        }catch(Exception e){}
        return null;

    } 
    public Decimal getBodySizeY() {
        String tempBody = '';
        try {

         String [] tempBodyX = StringUtils.sanitize(String.valueOf(specificRfqItem.get('Body_Size__c'))).split('x');
         tempBody = tempBodyX[1];

       } catch(Exception e) {}
        try {
            tempBody = StringUtils.sanitize(String.valueOf(specificRfqItem.get('Body_Size__c')));
       } catch(Exception e) {}
       try {
           if (StringUtils.isBlank(tempBody)) tempBody = StringUtils.sanitize(String.valueOf(specificRfqItem.get('Body_Y__c')));
        }catch(Exception e){}
         try {
           if (StringUtils.isBlank(tempBody)) tempBody = StringUtils.sanitize(String.valueOf(specificRfqItem.get('Body_Size_Y__c')));
        }catch(Exception e){}
        try {
            return Decimal.ValueOf(tempBody);
        }catch(Exception e){}
        return null;
    }
    public String getBodySizeZ() {
        String tempBody = '';
        try {
           if (StringUtils.isBlank(tempBody)) tempBody = StringUtils.sanitize(String.valueOf(specificRfqItem.get('Body_Z__c')));
        }catch(Exception e){}
         try {
           if (StringUtils.isBlank(tempBody)) tempBody = StringUtils.sanitize(String.valueOf(specificRfqItem.get('Body_Size_Z__c')));
        }catch(Exception e){}
        
            return tempBody;
    }  

    public void defaultFactory() {
        if (productGroup.Name == 'Dual Leadframe') {
            try {
                specificRfqItem.put('Factory__c', FactoryDao.getInstance().getFactoryByName('P1').Id);
            } catch (Exception e) {
                System.debug(LoggingLevel.Error, 'Could not put in default for package family: ' + e);
            }
        }
    }

    public String getBodySize() { 
        String tempBody = '';

        try {
            tempBody = StringUtils.sanitize(String.valueOf(specificRfqItem.get('Body_Size__c')));
       } catch(Exception e) {}

        if(packageFamily != null && !packageFamily.Name.contains('Saw')) {
           try {
               if (StringUtils.isBlank(tempBody)) tempBody = StringUtils.sanitize(String.valueOf(specificRfqItem.get('Body_X__c'))) + ' x ' +
                           StringUtils.sanitize(String.valueOf(specificRfqItem.get('Body_Y__c')));
           }catch(Exception e){}
       }
        
       try {
           if (StringUtils.isBlank(tempBody) || packageFamily.Name == 'SCSP') tempBody = StringUtils.sanitize(String.valueOf(specificRfqItem.get('Body_Size_X__c'))) + ' x ' +
                      StringUtils.sanitize(String.valueOf(specificRfqItem.get('Body_Size_Y__c')));
       }catch(Exception e){}

       return tempBody;
    }

    public Decimal getPercGM() {
        Decimal percGM = 0;
        percGM = DataUtils.getDecimal(specificRfqItem, 'Gross_Margin_Perc__c', 0);
        percGM = DataUtils.getDecimal(specificRfqItem, 'BU_Price_Perc_GM__c', percGM);
        percGM = DataUtils.getDecimal(specificRfqItem, 'Total_Perc_GM__c', percGM);

        return percGM;
    }

    public String getBallLeadCount() {
        String tempLeads = '';

        try {
           if (StringUtils.isBlank(tempLeads)) tempLeads = StringUtils.sanitize(String.valueOf(specificRfqItem.get('Lead_Count__c'))); 
       } catch(Exception e) {}

       try {
           if (StringUtils.isBlank(tempLeads)) tempLeads = StringUtils.sanitize(String.valueOf(specificRfqItem.get('Lead_Count_Entry__c'))); 
       } catch(Exception e) {}

       try {
           if (StringUtils.isBlank(tempLeads)) tempLeads = StringUtils.sanitize(String.valueOf(specificRfqItem.get('Ball_Count__c'))); 
       } catch(Exception e) {}

       try {
           if (StringUtils.isBlank(tempLeads)) tempLeads = StringUtils.sanitize(String.valueOf(specificRfqItem.get('Ball_Lead_Count__c'))); 
       } catch(Exception e) {}

       return tempLeads;
    }

    public Decimal getNumberOfWiresTotal() {
        Decimal total = 0;

        if (wireConfigurations != null) {
            for (sObject wc : wireConfigurations) {
                total += DataUtils.getDecimal(wc,'Number_Of_Wires__c',0);
            }
        }
        
        return total;
    }

    public Decimal getNumberOfTotal3dWireLength() {
        Decimal total = 0;

        if (wireConfigurations != null) {
            for (sObject wc : wireConfigurations) {
                total += DataUtils.getDecimal(wc,'Total_3D_Wire_Length__c',0);
            }
        }
        
        return total;
    }

    public Boolean getHasParent() {
        return !StringUtils.isBlank(rfqItem.Parent_RFQ_Item__c);
    }


    // This method is currently only used on the PDF quote, it tries to get the factory ID
    // And places it in a class property
    public void applyFactoryName(Map<ID, Factory__c> factories) { 
        String name = '';

        try {
            Id factoryId = (Id)specificRfqItem.get('Factory__c');
            name = factories.get(factoryId).Name;
        } catch (Exception e) {} 

        //Final Test
        try {
            if (StringUtils.isBlank(name))
            {
                name = (String)specificRfqItem.get('Factory_Selection__c');
            }
        } catch (Exception e) {} 

        try {
            if (StringUtils.isBlank(name))
            {
                name = (String)insertionConfigurations[0].get('Factory_Selected__c');
            }
        } catch (Exception e) {} 

        try {
            if (StringUtils.isBlank(name)) {
                name = (String)specificRfqItem.get('Post_Test_Factory__c');
            }
        } catch (Exception e) {} 

        this.factoryName = name;
    }

    public Integer compareTo(Object compareTo){
        RFQItemWrapper compareItem = (RFQItemWrapper)compareTo;

        if(packageFamily.Name == compareItem.packageFamily.Name) {
            if(forecastMedian > compareItem.forecastMedian) return 1;
            else if(forecastMedian == compareItem.forecastMedian) {
                if(rfqItem.Test_Type__c == compareItem.rfqItem.Test_Type__c) {
                    return rfqItem.Name.compareTo(compareItem.rfqItem.Name);
                }
                else return rfqItem.Test_Type__c.compareTo(compareItem.rfqItem.Test_Type__c);
            }
            else return -1;
        }

        return packageFamily.Name.compareTo(compareItem.packageFamily.Name);
    }

    public void setupChildParentIds() {
        if (specificRfqItem.get('RFQ_Item__c') == null) specificRfqItem.put('RFQ_Item__c', rfqItem.Id);

        if (specificRfqItem.Id != null) {
            if (wireConfigurations != null) {
                for (sObject row : wireConfigurations) {
                    if (row.get('Parent__c') == null) row.put('Parent__c', specificRfqItem.Id);
                }
            }

            if (dieConfigurations != null) {
                for (sObject row : dieConfigurations) {
                    if (row.get('Parent__c') == null) row.put('Parent__c', specificRfqItem.Id);
                }
            }

            if (passiveConfigurations != null) {
                for (sObject row : passiveConfigurations) {
                    if (row.get('Parent__c') == null) row.put('Parent__c', specificRfqItem.Id);
                }
            }

            if (insertionConfigurations != null) {
                for (sObject row : insertionConfigurations) {
                    if (row.get('Parent__c') == null) row.put('Parent__c', specificRfqItem.Id);
                }
            }

            if (serviceConfigurations != null) {
                for (sObject row : serviceConfigurations) {
                    if (row.get('Parent__c') == null) row.put('Parent__c', specificRfqItem.Id);
                }
            }
            if (nreConfigurations != null) {
                for (sObject row : nreConfigurations) {
                    //currently all NREs are the same object, so it is master detail to rfqItem
                    if (row.get('Parent__c') == null) row.put('Parent__c', rfqItem.Id);
                }
            }
        }
    }

    public void inflateSpecificObjectsFromJson() {
        wireConfigurations = new List<sObject>();
        dieConfigurations = new List<sObject>();
        passiveConfigurations = new List<sObject>();
        insertionConfigurations = new List<sObject>();
        serviceConfigurations = new List<sObject>();
        nreConfigurations = new List<sObject>();

        if (!StringUtils.isBlank(rfqItem.RFQI_JSON__c)) {
            specificRfqItem = (sObject)System.JSON.deserialize(rfqItem.RFQI_JSON__c, SObject.class);
        }
        

        if (!StringUtils.isBlank(rfqItem.RFQIWC_JSON__c)) {
            wireConfigurations = (List<sObject>)System.JSON.deserialize(rfqItem.RFQIWC_JSON__c, List<sObject>.class);
        }

        if (!StringUtils.isBlank(rfqItem.RFQIDC_JSON__c)) {
            dieConfigurations = (List<sObject>)System.JSON.deserialize(rfqItem.RFQIDC_JSON__c, List<sObject>.class);
        }

        if (!StringUtils.isBlank(rfqItem.RFQIPC_JSON__c)) {
            passiveConfigurations = (List<sObject>)System.JSON.deserialize(rfqItem.RFQIPC_JSON__c, List<sObject>.class);
        }

        if (!StringUtils.isBlank(rfqItem.RFQIIC_JSON__c)) {
            insertionConfigurations = (List<sObject>)System.JSON.deserialize(rfqItem.RFQIIC_JSON__c, List<sObject>.class);
        }

        if (!StringUtils.isBlank(rfqItem.RFQISC_JSON__c)) {
            serviceConfigurations = (List<sObject>)System.JSON.deserialize(rfqItem.RFQISC_JSON__c, List<sObject>.class);
        }
        if (!StringUtils.isBlank(rfqItem.RFQINC_JSON__c)) {
            nreConfigurations = (List<RFQI_NRE__c>)System.JSON.deserialize(rfqItem.RFQINC_JSON__c, List<RFQI_NRE__c>.class);
        }
    }

        /**
     * This method is used on the PDF quote, as per AMK-1332
     * if any checkbox fields are unchecked then they should not 
     * appear on the PDF quote
     */ 
    public void determineAttributeQuoteVisibility(RFQILayout layout) {
        setupChildObjectSections(layout);

        for (RFQILayoutSection section : layout.sectionMap.values()) {
            String sectionName = section.sectionName;

            if (!StringUtils.isMatch(sectionName,'Die Description') && 
                !StringUtils.isMatch(sectionName,'Passive Description') && 
                !StringUtils.isMatch(sectionName,'Insertion Description') && 
                !StringUtils.isMatch(sectionName,'Wire Description') && 
                !StringUtils.isMatch(sectionName,'Service Description') && 
                !StringUtils.isMatch(sectionName,'NRE Description') && 
                layout.enabledSections.get(sectionName) == true) {
                
                hideUncheckedFieldsInSection(specificRfqItem, section);
            }
        }

        List<sObject> childObjects = new List<sObject>();
        if (wireConfigurations != null) childObjects.addAll(wireConfigurations);
        if (dieConfigurations != null) childObjects.addAll(dieConfigurations);
        if (passiveConfigurations != null) childObjects.addAll(passiveConfigurations);
        if (insertionConfigurations != null) childObjects.addAll(insertionConfigurations);
        if (serviceConfigurations != null) childObjects.addAll(serviceConfigurations);
        if (nreConfigurations != null) childObjects.addAll(nreConfigurations);

        for (sObject obj : childObjects) {
            if (childObjectSections.containsKey(obj.Id)) {
                hideUncheckedFieldsInSection(obj, childObjectSections.get(obj.Id));
            }
        }

    }

    private void hideUncheckedFieldsInSection(sObject targetObj, RFQILayoutSection section) {
        for (Integer i = section.attributes.size() - 1; i >= 0; i--) {
            RFQISectionAttribute attribute = section.attributes.get(i);

            if (!attribute.fieldAPIName.contains('__r')) {
                Schema.DescribeFieldResult fieldInfo = FieldLabelHelper.getInstance().getFieldInfo(targetObj, attribute.fieldAPIName);

                if (fieldInfo != null) {
                    Schema.DisplayType fieldType = fieldInfo.getType();

                    if (fieldType == Schema.DisplayType.Boolean && targetObj.get(attribute.fieldAPIName) != true) {
                        section.hideField(attribute.fieldAPIName);
                    }
                }
            }
        }
    }

    

    /**
     * This method is specific to MLF right now as per AMK-1455
     * If any adders are selected, then the "adder cost" field needs
     * to be marked as manual entry required.
     */
    public void setupManualEntryOverrides(RFQILayout layout) {

        if (productGroup != null && productGroup.Name == 'MLF' && layout.sectionMap != null) {

            RFQILayoutSection adderSection = layout.sectionMap.get('Adders');
            if (adderSection != null && adderSection.attributes != null) {

                Boolean foundAdder = false;

                for (RFQISectionAttribute attribute : adderSection.attributes) {
                    Object oVal = specificRfqItem.get(attribute.fieldAPIName);
                    System.debug('Found an adder attribute');
                    if (oVal != null && oVal instanceof Boolean && (Boolean)oVal == true) {
                        // Sales checked one of the "Adder" boxes

                        foundAdder = true;
                    }
                }

                if (foundAdder) {

                    RFQILayoutSection priceSection = layout.sectionMap.get('Cost and Price');
                    if (priceSection != null && priceSection.attributes != null) {
                        // Mark the adder cost field editable and Manual Entry Required
                        
                        // Per AMK-2684 - Addeds will be summed up in the cost of the BU Price, whichever the BU's set.
                        priceSection.changeEditability('Adder_Cost__c', false);
                        priceSection.changeMer('Adder_Cost__c', false);
                    }
                }

            }
        }
    }

    /**
     * This method creates a cloned layout section for each child object (wire, die, etc)
     * so fields can be shown/hidden for each specific child individually.
     * Right now this is only used on the PDF pages
     */
    public void setupChildObjectSections(RFQILayout layout) {
        childObjectSections = new Map<Id, RFQILayoutSection>();

        setupChildObjectSections(childObjectSections, wireConfigurations, 'Wire Description', layout);
        setupChildObjectSections(childObjectSections, dieConfigurations, 'Die Description', layout);
        setupChildObjectSections(childObjectSections, passiveConfigurations, 'Passive Description', layout);
        setupChildObjectSections(childObjectSections, insertionConfigurations, 'Insertion Description', layout);
        setupChildObjectSections(childObjectSections, serviceConfigurations, 'Service Description', layout);
        setupChildObjectSections(childObjectSections, nreConfigurations, 'NRE Configurations', layout);
    }

    /**
     * This method creates a cloned layout section for only the NRE section
     * because only the NRE child objects should be rendered n
     */
    //public void setupChildObjectSectionsForNRE(RFQILayout layout) {
    //  if(childObjectSections == null) childObjectSections = new Map<Id, RFQILayoutSection>();
    //  setupChildObjectSections(childObjectSections, nreConfigurations, 'NRE Configurations', layout);

    //}


    private void setupChildObjectSections(Map<Id, RFQILayoutSection> target, List<sObject> childList, String sectionName, RFQILayout layout) {
        if (childList != null && childList.size() > 0) {
            system.debug('layout.sectionMap.get(sectionName) : '+layout.sectionMap.get(sectionName));
            system.debug('childList : '+childList);
            if (layout.sectionMap.get(sectionName) != null) {
                for (sObject obj : childList) {
                    target.put(obj.Id, layout.sectionMap.get(sectionName).copy());
                }
                system.debug('target : '+target);
            }
        }
    }

    public Integer wireLen() {
        if(wireConfigurations == null) return 0;
        else return wireConfigurations.size();
    }

    public Integer dieLen() {
        if(dieConfigurations == null) return 0;
        else return dieConfigurations.size();
    }

    public Integer passiveLen() {
        if(passiveConfigurations == null) return 0;
        else return passiveConfigurations.size();
    }

    public Integer insertionLen() {
        if(insertionConfigurations == null) return 0;
        else return insertionConfigurations.size();
    }

    public Integer serviceLen() {
        if(serviceConfigurations == null) return 0;
        else return serviceConfigurations.size();
    }

    public Integer nreLen() {
        if(nreConfigurations == null) return 0;
        else return nreConfigurations.size();
    }

    /***
     * This class acts as a holder item for adder charge sub-line items (TODO: Break out into seperate class?)
     */
    public class AdderCharge {
        
        public AdderCharge(String name, Decimal amount) {
            this(name, amount, null);
        }

        public AdderCharge(String name, Decimal amount, Decimal quantity) {
            this.name = name;
            this.amount = amount;
            this.quantity = quantity;
        }

        public String name { get; set; }
        public Decimal amount { get; set; }
        public Decimal quantity { get; set; }
    }

    public class RFQIFieldDelta implements Comparable {
        public String fieldName {get; set;}
        public String objectName {get; set;}
        public sObject obj1 {get; set;}
        public sObject obj2 {get; set;}
        public Integer index {get; set;}
        public String objectType {get; set;}

        public RFQIFieldDelta(String oType, String oName, String fName, sObject o1, sObject o2) {
            objectName = oName;
            fieldName = fName;
            objectType = oType;
            obj1 = o1;
            obj2 = o2;
            index = 0;
        }

        public RFQIFieldDelta(String oType, String oName, String fName, sObject o1, sObject o2, Integer i) {
            this(oType,oName,fName,o1,o2);
            setIndex(i);
        }

        public void setIndex(Integer i) {
            index = i;
        }

        public String getSuffix() {
            if(objectType == PACKAGE_OBJECT) return '';
            else {
                return ' - ' + objectType + '(' + (index + 1) + ')';
            }
        }

        public Boolean areEqual() {
            return DataUtils.getString(obj1,fieldName,null) == DataUtils.getString(obj2,fieldName,null);
        }

        public Integer compareTo(Object compareTo) {
            RFQIFieldDelta compareToDel = (RFQIFieldDelta)compareTo;

            Integer compVal = -1*objectName.compareTo(compareToDel.objectName);
            if(compVal == 0){
                compVal = fieldName.compareTo(compareToDel.fieldName);
                if(compVal == 0){
                    if(index > compareToDel.index) compVal = 1;
                    else if(index < compareToDel.index) compVal = -1;
                    else compVal = 0;
                }
            }
            
            return compVal;
        }


        
    }

    public class RFQIDelta {

        public List<RFQIFieldDelta> deltas {get; set;}
        public List<RFQIFieldDelta> sames {get; set;}
        private List<String> messages;
        
        public RFQIDelta() {
            deltas = new List<RFQIFieldDelta>();
            sames = new List<RFQIFieldDelta>();
            messages = new List<String>();
        }

        public void add(RFQIFieldDelta d) {
            
            if(!d.fieldName.toLowerCase().contains('__r.') 
                && d.fieldName.toLowerCase().contains('__c')
                && d.fieldName != 'Parent__c') {
                if(d.areEqual()) sames.add(d);
                else deltas.add(d);
            }
            
        }
 
        public void addMessage(String message) {
            messages.add(message);
        }

        public void removeNotInLayout(RFQILayout layout) {

            List<RFQIFieldDelta> newDeltas = new List<RFQIFieldDelta>();
            for(Integer i = 0; i < deltas.size(); i++) {
                String fieldName = deltas.get(i).fieldName;
                if(layout.containsField(fieldName,false)){
                    newDeltas.add(deltas.get(i));
                }
            }
            deltas = newDeltas;

            List<RFQIFieldDelta> newSames = new List<RFQIFieldDelta>();

            for(Integer i = 0; i < sames.size(); i++) {
                String fieldName = sames.get(i).fieldName;
                if(layout.containsField(fieldName,false)) {
                    newSames.add(sames.get(i));
                }
            }
            sames = newSames;

            sort();
        }

        public void sort() {
            deltas.sort();
            sames.sort();
        }
   
    }

    public RFQIDelta compareRFQI(RFQItemWrapper other) {

        RFQIDelta delta = new RFQIDelta();

        //if the package fams are different don't compare


        if(this.packageFamily != other.packageFamily) {
            delta.addMessage('These items are not the same Package Family and cannot be compared');
            return delta;
        }
        
        //check the fieldMap and compare package objects 
        String objName = getObjectAPIName(PACKAGE_OBJECT);
        for(String field : fieldMap.get(PACKAGE_OBJECT)) {
            delta.add(new RFQIFieldDelta(PACKAGE_OBJECT,objName,field,this.specificRfqItem,other.specificRfqItem));
        }
        
        //check the sizes of wires
        if(this.wireLen() != other.wireLen()) {
            delta.addMessage('RFQIs have different number of wire configurations');
        }
        else {
            objName = getObjectAPIName(WIRE_OBJECT);
            //check the fieldMap and compare
            for(Integer i = 0; i < this.wireLen(); i++) {
                for(String field : fieldMap.get(WIRE_OBJECT)) {
                    delta.add(new RFQIFieldDelta(WIRE_OBJECT,objName,field,this.wireConfigurations[i],other.wireConfigurations[i],i));
                }
            }
        }

        if(this.dieLen() != other.dieLen()) {
            delta.addMessage('RFQIs have different number of die configurations');
        }
        else {
            //check the fieldMap and compare
            objName = getObjectAPIName(DIE_OBJECT);
            for(Integer i = 0; i < this.dieLen(); i++) {
                for(String field : fieldMap.get(DIE_OBJECT)) {
                    delta.add(new RFQIFieldDelta(DIE_OBJECT,objName,field,this.dieConfigurations[i],other.dieConfigurations[i],i));
                }
            }
        }

        if(this.insertionLen() != other.insertionLen()) {
            delta.addMessage('RFQIs have different number of insertion configurations');
        }
        else {
            //check the fieldMap and compare
            objName = getObjectAPIName(INSERTION_OBJECT);
            for(Integer i = 0; i < this.insertionLen(); i++) {
                for(String field : fieldMap.get(INSERTION_OBJECT)) {
                    delta.add(new RFQIFieldDelta(INSERTION_OBJECT,objName,field,this.insertionConfigurations[i],other.insertionConfigurations[i],i));
                }
            }
        }

        if(this.passiveLen() != other.passiveLen()) {
            delta.addMessage('RFQIs have different number of passive configurations');
        }
        else {
            //check the fieldMap and compare
            objName = getObjectAPIName(PASSIVE_OBJECT);
            for(Integer i = 0; i < this.passiveLen(); i++) {
                for(String field : fieldMap.get(PASSIVE_OBJECT)) {
                    delta.add(new RFQIFieldDelta(PASSIVE_OBJECT,objName,field,this.passiveConfigurations[i],other.passiveConfigurations[i],i));
                }
            }
        }

        if(this.serviceLen() != other.serviceLen()) {
            delta.addMessage('RFQIs have different number of service configurations');
        }
        else {
            //check the fieldMap and compare
            objName = getObjectAPIName(SERVICE_OBJECT);
            for(Integer i = 0; i < this.serviceLen(); i++) {
                for(String field : fieldMap.get(SERVICE_OBJECT)) {
                    delta.add(new RFQIFieldDelta(SERVICE_OBJECT,objName,field,this.serviceConfigurations[i],other.serviceConfigurations[i],i));
                }
            }
        }
        if(this.nreLen() != other.nreLen()) {
            delta.addMessage('RFQIs have different number of NRE configurations');
        }
        else {
            //check the fieldMap and compare
            objName = getObjectAPIName(NRE_OBJECT);
            for(Integer i = 0; i < this.nreLen(); i++) {
                for(String field : fieldMap.get(NRE_OBJECT)) {
                    delta.add(new RFQIFieldDelta(NRE_OBJECT,objName,field,this.nreConfigurations[i],other.nreConfigurations[i],i));
                }
            }
        }

        return delta;
    }

    public static Integer getMaximumWireConfigurations(List<RFQItemWrapper> wrappers) {
        Integer max = 0;

        for (RFQItemWrapper wrapper : wrappers) {
            if (wrapper.getNumberOfWireConfigurations() > max) max = wrapper.getNumberOfWireConfigurations();
        } 

        return max;     
    }

    public static Integer getMaximumDieConfigurations(List<RFQItemWrapper> wrappers) {
        Integer max = 0;

        for (RFQItemWrapper wrapper : wrappers) {
            if (wrapper.getNumberOfDieConfigurations() > max) max = wrapper.getNumberOfDieConfigurations();
        } 

        return max;     
    }

    public static Integer getMaximumInsertionConfigurations(List<RFQItemWrapper> wrappers) {
        Integer max = 0;

        for (RFQItemWrapper wrapper : wrappers) {
            if (wrapper.getNumberOfInsertionConfigurations() > max) max = wrapper.getNumberOfInsertionConfigurations();
        } 

        return max;     
    }

    public static Integer getMaximumPassiveConfigurations(List<RFQItemWrapper> wrappers) {
        Integer max = 0;

        for (RFQItemWrapper wrapper : wrappers) {
            if (wrapper.getNumberOfPassiveConfigurations() > max) max = wrapper.getNumberOfPassiveConfigurations();
        } 

        return max;     
    }

    public static Integer getMaximumServiceConfigurations(List<RFQItemWrapper> wrappers) {
        Integer max = 0;

        for (RFQItemWrapper wrapper : wrappers) {
            if (wrapper.getNumberOfServiceConfigurations() > max) max = wrapper.getNumberOfServiceConfigurations();
        } 

        return max;     
    }

    public static Integer getMaximumNREConfigurations(List<RFQItemWrapper> wrappers) {
        Integer max = 0;

        for (RFQItemWrapper wrapper : wrappers) {
            if (wrapper.getNumberOfNREConfigurations() > max) max = wrapper.getNumberOfNREConfigurations();
        } 

        return max;     
    }

    public Boolean getAreMultivolumesEditableInEscalation()
    {
        //editible if the status is in pending bu,
        //or if it is in escalation, then only if the multivolume items have not been created
        Boolean itemInEscalation = RFQItemDao.getInstance().statusGreaterOrEqual(rfqItem, RFQItemDao.STATUS_PRICE_ESCALATION);
        return !itemInEscalation || !rfqItem.Has_Created_Multivolume_Items__c;
    }
    
    
}