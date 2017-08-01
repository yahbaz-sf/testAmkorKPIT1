public virtual with sharing class RFQIValidation 
{
    public transient RFQILayout layout; 
    public transient Package_Family__c packageFamily;
    public transient Product_Group__c productGroup;
    public transient RFQ_Item__c rfqItem;
    public transient sObject specificRfqItem;
    public transient List<sObject> wireConfigurations;
    public transient List<sObject> dieConfigurations;
    public transient List<sObject> insertionConfigurations;
    public transient List<sObject> passiveConfigurations;
    public transient List<sObject> serviceConfigurations;
    public transient List<RFQIVolume> volumeConfigurations;
    public DebugUtils debug {get {return DebugUtils.getInstance();} }
    public transient String error;
    public transient String doNotPriceError;
    public transient String volumeConfigurationError;
    public Boolean hasAmkorSelected {get; set;}
    public String amkorSelectedFields {get; set;}
    public transient Map<Id, RFQILayoutSection> childObjectSections;
    public transient RFQIAutoCostValidation autoCostValidator;

    public RFQIValidation(RFQItemWrapper itemWrapper, RFQILayout itemLayout) 
    {
        layout = itemLayout;
        packageFamily = itemWrapper.packageFamily;
        productGroup = itemWrapper.productGroup;
        specificRfqItem = itemWrapper.specificRfqItem;
        rfqItem = itemWrapper.rfqItem;
        wireConfigurations = itemWrapper.wireConfigurations;
        dieConfigurations = itemWrapper.dieConfigurations;
        insertionConfigurations = itemWrapper.insertionConfigurations;
        passiveConfigurations = itemWrapper.passiveConfigurations;
        serviceConfigurations = itemWrapper.serviceConfigurations;
        volumeConfigurations = itemWrapper.volumeList;
        error = '';
        doNotPriceError = '';
        volumeConfigurationError = '';
        hasAmkorSelected = false;
        amkorSelectedFields = '<strong>Cannot approve item if any attributes are "Amkor Selected", "Amkor Specified", "Amkor Recommended", or "Amkor Preferred":</strong><br/>';
        childObjectSections = itemWrapper.childObjectSections;
    }

    public Boolean validateRequiredFields(List<String> missingFields) {

        // Validate main object
            Boolean isValid = true;
            Integer position;

            for (RFQILayoutSection section : layout.sectionMap.values()) {
                String sectionName = section.sectionName;
                system.debug(LoggingLevel.Info,'sectionName : '+sectionName);
                //debug.log('About to validate section', sectionName);

                if (!StringUtils.isMatch(sectionName,'Cost and Price') && 
                    !StringUtils.isMatch(sectionName,'Die Description') && 
                    !StringUtils.isMatch(sectionName,'Passive Description') && 
                    !StringUtils.isMatch(sectionName,'Insertion Description') && 
                    !StringUtils.isMatch(sectionName,'Wire Description') &&
                    //these attributes' page type is not BU only because they need to show on sales page (non editable)
                    !StringUtils.isMatch(sectionName,'Post Test Services Cost and Price') &&
                    !StringUtils.isMatch(sectionName,'Service Description') && 
                    !String.isEmpty(sectionName) &&
                    layout.enabledSections.get(sectionName)) {
                    if (!validateObjectFromSection(specificRfqItem, section, packageFamily.Specific_RFQ_Item_Object__c, missingFields)) isValid = false;  
                
                    
                }
            }

            if (layout.enabledSections.get('Cost and Price') != null && layout.enabledSections.get('Cost and Price') && !validateCostAndPriceSection(missingFields)) isValid = false;

            if (packageFamily.Specific_RFQ_Item_Object__c == AMKVARS.OBJ_BUMP && !validateBump(specificRfqItem, packageFamily.Specific_RFQ_Item_Object__c, missingFields)) isValid = false;
            if (productGroup.Name == AMKVARS.PG_SCSP && !validateSCSPObject(specificRfqItem, packageFamily.Specific_RFQ_Item_Object__c, missingFields)) isValid = false;
            //if (packageFamily.Name == AMKVARS.PF_TEST && !validateTest(specificRfqItem, packageFamily.Specific_RFQ_Item_Object__c, missingFields)) isValid = false;
            // Validate Wire objects
            if (wireConfigurations != null && layout.sectionMap.containsKey('Wire Description') && layout.enabledSections.get('Wire Description')) 
            {
                position = 0;
                //RFQILayoutSection section = layout.sectionMap.get('Wire Description');
                for (sObject wireConfig : wireConfigurations) 
                {
                    RFQILayoutSection section = childObjectSections.get(wireConfig.Id);
                    position++;
                    if (!validateObjectFromSection(wireConfig, section, packageFamily.Specific_Wire_Configuration_Object__c, missingFields, ' -- Wire Configuration ' + position) ||
                        !validateWireConfigs(wireConfig, packageFamily.Specific_Wire_Configuration_Object__c, position, missingFields)) isValid = false;

                    if (productGroup.Name == AMKVARS.PG_QUAD && !validateQuadWireConfigs(wireConfig, packageFamily.Specific_Wire_Configuration_Object__c, position, missingFields)) isValid = false;
                }
            }

            // Validate die objects
            if (dieConfigurations != null && layout.sectionMap.containsKey('Die Description') && layout.enabledSections.get('Die Description')) 
            {
                position = 0;
                //RFQILayoutSection section = layout.sectionMap.get('Die Description');
                for (sObject dieConfig : dieConfigurations) 
                {   
                    system.debug('Object Id :' + String.valueOf(dieConfig.Id));
                    RFQILayoutSection section = childObjectSections.get(dieConfig.Id);
                    position++;
                    if (!validateObjectFromSection(dieConfig, section, packageFamily.Specific_Die_Configuration_Object__c, missingFields, ' -- Die Configuration ' + position)) isValid = false;

                    if (productGroup.Name == AMKVARS.PG_MLF && !validateMLFDieObjects(dieConfig, packageFamily.Specific_Die_Configuration_Object__c, position, missingFields)) isValid = false;

                    if (packageFamily.Specific_RFQ_Item_Object__c == AMKVARS.OBJ_FCBGA && !validatefcBGADieBumpPitch(dieConfig, packageFamily.Specific_Die_Configuration_Object__c, position, missingFields)) isValid = false;
                }

                if (productGroup.Name == AMKVARS.PG_MLF && !validateAllMLFDieObjects(packageFamily.Specific_Die_Configuration_Object__c, missingFields)) isValid = false;
            }

            if (insertionConfigurations != null && layout.sectionMap.containsKey('Insertion Description') && layout.enabledSections.get('Insertion Description')) 
            {
                position = 0;
                //RFQILayoutSection section = layout.sectionMap.get('Insertion Description');
                for (sObject insertionConfig : insertionConfigurations) 
                {
                    RFQILayoutSection section = childObjectSections.get(insertionConfig.Id);
                    system.debug(LoggingLevel.Info,'section : '+section);
                    position++;
                    if (!validateObjectFromSection(insertionConfig, section, packageFamily.Specific_Insertion_Configuration_Object__c, missingFields, ' -- Insertion Configuration ' + position)) isValid = false;
                }
            }

            if (passiveConfigurations != null && layout.sectionMap.containsKey('Passive Description') && layout.enabledSections.get('Passive Description')) 
            {
                position = 0;
                //RFQILayoutSection section = layout.sectionMap.get('Passive Description');
                for (sObject passiveConfig : passiveConfigurations) 
                {
                    RFQILayoutSection section = childObjectSections.get(passiveConfig.Id);
                    position++;
                    if (!validateObjectFromSection(passiveConfig, section, packageFamily.Specific_Passive_Configuration_Object__c, missingFields, ' -- Passive Configuration ' + position)) isValid = false;
                }
            }

            if (serviceConfigurations != null && layout.sectionMap.containsKey('Service Description') && layout.enabledSections.get('Service Description')) 
            {
                position = 0;
                //RFQILayoutSection section = layout.sectionMap.get('Passive Description');
                for (sObject serviceConfig : serviceConfigurations) 
                {
                    RFQILayoutSection section = childObjectSections.get(serviceConfig.Id);
                    position++;
                    if (!validateObjectFromSection(serviceConfig, section, packageFamily.Specific_Service_Configuration_Object__c, missingFields, ' -- Service Configuration ' + position)) isValid = false;
                }
            }

            if (!validateVolumeConfigurations()) isValid = false;
            missingFields.add(volumeConfigurationError);

            //reenabled this because the factory pf field def was being validated while it was in a section that doesn't get displayed
            if (packageFamily.Has_Factory_Field__c && specificRfqItem.get('Factory__c') == null) 
            {
                missingFields.add('Factory');
                isValid = false;
            }

            if (missingFields.size() > 0) error += 'Please fill out all required fields or fix errors before saving:<br />';
            for (String field : missingFields) 
            {
                error += field + '<br />';
            }

            //reset do not auto price
            rfqItem.Do_Not_Auto_Price__c = false;
            List<String> autoCostErrors = new List<String>();
            autoCostValidator = new RFQIAutoCostValidation(this, autoCostErrors);

            if (autoCostErrors.size() > 0) doNotPriceError += 'Cannot auto-price this item:<br />';
            for (String message : autoCostErrors) 
            {
                doNotPriceError += message + '<br />';
            }

            return isValid;
    }

    public String getValidationErrors()
    {
        return error;
    }

    public String getAutoPriceErrors()
    {
        return doNotPriceError;
    }

    public String getVolumeConfigurationErrors()
    {
        return volumeConfigurationError;
    }

    //Split into its own method so BUPriceEditPage can call this separately
    public Boolean validateCostAndPriceSection(List<String> missingFields)
    {
        Boolean isValid = true;
        System.debug('--->validateCostAndPriceSection, missingFields : ' + missingFields);
        System.debug('--->validateCostAndPriceSection, specificRfqItem : ' + specificRfqItem);
        
        if (!validateObjectFromSection(specificRfqItem, layout.sectionMap.get('Cost and Price'), 
                                       packageFamily.Specific_RFQ_Item_Object__c, missingFields)) 
            isValid = false;
        if (packageFamily.Name == AMKVARS.PF_TEST && layout.pageType == 'BU' && 
            layout.enabledSections.get('Post Test Services Cost and Price') && 
            !validateObjectFromSection(specificRfqItem, layout.sectionMap.get('Post Test Services Cost and Price'), 
                                        packageFamily.Specific_RFQ_Item_Object__c, missingFields))
            isValid = false;
        if (packageFamily.Name == 'FC BGA')
        {
            Decimal totalCost = DataUtils.getDecimal(specificRfqItem, 'Total_Cost_With_Substrate_New__c', 0);
            Decimal subs = DataUtils.getDecimal(specificRfqItem, 'Materials_Substrate__c', 0);
            Decimal odm = DataUtils.getDecimal(specificRfqItem, 'Materials_ODM__c', 0);
            Decimal clam = DataUtils.getDecimal(specificRfqItem, 'CLAM_Subtotal_New__c', 0);
            Decimal others = DataUtils.getDecimal(specificRfqItem, 'Others_Cost__c', 0);

            //check components of total cost in case there is a total cost already, 
            //but they clear the values before save w/o recalculating
            
            //Lalit-22-Nov-2016 :Salesforce -122: Adv Products Flip Chip and Unlisted Recalc Issue - Simply BU Price entry.
            //Removed the mandatory error for Clam ODM and Subs.
            //if (totalCost == null || totalCost <= 0 || ((subs + odm + clam + others) == 0))            
            if (totalCost == null || totalCost <= 0)
            {
                String error = 'Total Cost cannot be less than 0. Please fill out one of the following fields - ';
                String objName = packageFamily.Specific_RFQ_Item_Object__c;
                error += FieldLabelHelper.getInstance().getLabel(objName, 'Total_Cost_With_Substrate_New__c');
                /*error += FieldLabelHelper.getInstance().getLabel(objName, 'Materials_Substrate__c') + ', ';
                error += FieldLabelHelper.getInstance().getLabel(objName, 'Materials_ODM__c') + ', ';
                error += FieldLabelHelper.getInstance().getLabel(objName, 'CLAM_Subtotal_New__c') + ' or ';
                error += FieldLabelHelper.getInstance().getLabel(objName, 'Others_Cost__c') + ' and click "Reprice Item"';*/
                missingFields.add(error);
                isValid = false;
            }
        }
        System.debug('--->validateCostAndPriceSection, returning isValid : ' + isValid);
        return isValid;
    }

    protected Boolean validateObjectFromSection(sObject obj, RFQILayoutSection section, String objName, List<String> missingFields) {
        return validateObjectFromSection(obj, section, objName, missingFields, '');
    }

    protected Boolean validateObjectFromSection(sObject obj, RFQILayoutSection section, String objName, List<String> missingFields, String location) {
        Boolean isValid = true;

        Boolean applyHack = Date.today() < Date.newInstance(2013,11,1);

        for (RFQISectionAttribute attribute : section.attributes) {
            System.debug('--->validateObjectFromSection, objName : ' + objName + ', attribute.objectAPIName : ' + attribute.objectAPIName + 
                         ', attribute.fieldAPIName : ' + attribute.fieldAPIName + 
                         ', attribute.isRequired : ' + attribute.isRequired + ', attribute.hasAmkorSelected : ' + attribute.hasAmkorSelected);
            if(attribute.objectAPIName == objName){
                if (attribute.isRequired) {
                    //Throwing a hack in here to allow pre-decision to buy RFQIs to go through this should
                    //be removed eventually
                    if(attribute.fieldAPIName == 'Decision_To_Buy__c' && applyHack) {
                        if(RFQItemDao.getInstance().statusGreaterOrEqual(rfqItem,RFQItemDao.STATUS_PRICE_SUBMIT)) {
                            continue;
                        }
                    }
                    System.debug('--->validateObjectFromSection, obj.get(attribute.fieldAPIName) : ' + obj.get(attribute.fieldAPIName));
                    if (obj.get(attribute.fieldAPIName) == null) {
                        System.debug('### Validating field: ' + attribute.fieldAPIName + ' -- section: ' + section.sectionName + ' -- object name: ' + objName);

                        try {
                            missingFields.add(FieldLabelHelper.getInstance().getLabel(objName, attribute.fieldAPIName) + location );
                        }
                        catch (Exception e) {
                            // In case getting the label failed for some reason
                            System.debug('### Error while adding required field label: ' + e);
                        }
                        isValid = false;
                    }

                }

                if (attribute.hasAmkorSelected) {
                    //check section, for case of other fields that are dynamically added
                    if ((!(attribute.sectionName == 'Substrate Description')) && attribute.sectionName != null) {
                        //use .contains() because of multi-select picklists on BU Attribute Edit page
                        String value = DataUtils.getString(obj, attribute.fieldAPIName, '').toLowerCase();
                        if (value.contains('amkor selected') || value.contains('amkor preferred')|| value.contains('amkor recommended')){
                            amkorSelectedFields += '<br />' + FieldLabelHelper.getInstance().getLabel(objName, attribute.fieldAPIName);
                            hasAmkorSelected = true;
                            debug.log('attribute.fieldAPIName hasAmkorSelected: ', attribute.fieldAPIName);
                        }
                    }
                }

            } 
            else if (attribute.objectAPIName == 'RFQ_Item__c')
            {
                if (attribute.isRequired) {

                    if (rfqItem.get(attribute.fieldAPIName) == null) {
                        System.debug('### Validating field: ' + attribute.fieldAPIName + ' -- section: ' + section.sectionName + ' -- object name: ' + objName);

                        try {
                            missingFields.add(FieldLabelHelper.getInstance().getLabel('RFQ_Item__c', attribute.fieldAPIName) + location );
                        }
                        catch (Exception e) {
                            // In case getting the label failed for some reason
                            System.debug('### Error while adding required field label: ' + e);
                        }
                        isValid = false;
                    }

                } 
            }
        }
        System.debug('--->validateObjectFromSection, returning isValid : ' + isValid);
        System.debug('--->validateObjectFromSection, returning missingFields : ' + missingFields);
        return isValid;
    }

    public Boolean validateVolumeConfigurations()
    {
        Boolean isValid = true;
        if (packageFamily.Product_Group_Name__c != AMKVARS.PG_EGRSVC)
        {
            Map<String, List<Integer>> itemsWithSameForecast = new Map<String, List<Integer>>();
            List<Integer> indexList;
            String specificRfqItemForecast;
            if(packageFamily.Name == 'Die Processing Service (WLCSP)') {
                specificRfqItemForecast = (String)specificRfqItem.get('Die_per_Month__c');
            }
            else if (packageFamily.Product_Group_Name__c != AMKVARS.PG_EGRSVC)
            {
                //Use String.valueOf instead of typecast to string for TSV pf which is a decimal
                specificRfqItemForecast = String.valueOf(specificRfqItem.get('Forecast__c'));
                if (specificRfqItemForecast == null) specificRfqItemForecast = '0';
            }
            
            itemsWithSameForecast.put(specificRfqItemForecast, new List<Integer>{0});
            for (RFQIVolume volume : volumeConfigurations)
            {
                //if item is test and added service, use test volume field
                String volumeEntered = volume.volume;
                if (volumeEntered == null) volumeEntered = '0';
                if (volumeEntered == '0')
                {
                    isValid = false;
                    volumeConfigurationError += 'Volume configuration ' + volume.index + ' cannot have a volume of 0';
                }
                indexList = itemsWithSameForecast.get(volumeEntered);
                if (indexList == null)
                {
                    itemsWithSameForecast.put(volumeEntered, new List<Integer>{volume.index});
                }
                else
                {
                    //a config with the same volume exists (and has created the list already) so
                    //the item is not valid
                    indexList.add(volume.index);
                    isValid = false;
                }
            }

            if (!isValid)
            {
                for (List<Integer> indexes : itemsWithSameForecast.values())
                {
                    if (indexes.size() > 1)
                    {
                        String lastItem = '';
                        volumeConfigurationError += 'The following volume configurations cannot have the same volume - Configurations: ';
                        if(indexes[0] == 0) {
                            lastItem = 'The Original RFQ Item';
                            indexes.remove(0);
                        }
                        else {
                            lastItem = String.valueOf(indexes.remove(indexes.size() - 1));
                        }
                        volumeConfigurationError += String.join(indexes, ', ') + ' and ' + lastItem;
                        volumeConfigurationError += '.<br />';
                    }
                }
            }
        }

        return isValid;
    }

    @TestVisible private Boolean validateWireConfigs(sObject wireConfig, String objName, Integer position, List<String> missingFields)
    {
        Boolean isValid = true;
        Decimal average2DLength = getDecimal(wireConfig,'Average_2D_Wire_Length__c',0);
        Decimal total2DLength = getDecimal(wireConfig,'Total_2D_Wire_Length__c',0);
        Decimal total3DLength = getDecimal(wireConfig, 'Total_3D_Wire_Length__c', 0);

        //one field must have a value
        //Bharat-05-July-2017 :Salesforce-139: Cavity MEMS Sales RFQ Item Create screens.
        //Total 2D Wire Length can be zero for MEMS package family.
        if ( !(average2DLength > 0 || total2DLength > 0 || total3DLength > 0) && objName!='RFQIWC_MEMS__c')
        {
            try
            {
                missingFields.add('One of: ' + FieldLabelHelper.getInstance().getLabel(objName, 'Average_2D_Wire_Length__c') + ' or ' + 
                                               FieldLabelHelper.getInstance().getLabel(objName, 'Total_2D_Wire_Length__c') + ' or ' +
                                               FieldLabelHelper.getInstance().getLabel(objName, 'Total_3D_Wire_Length__c') + 
                                               ' -- Wire Configuration ' + position );
            }
            catch (Exception e) 
            {
                // In case getting the label failed for some reason
                System.debug('### Error while adding required field label: ' + e);
            }
            isValid = false;
        }
        return isValid; 
    }

    @TestVisible private Boolean validateQuadWireConfigs(sObject wireConfig, String objName, Integer position, List<String> missingFields)
    {
        Boolean isValid;
        //two of three fields need to be filled out
        //if (wireConfig.get('Number_of_Wires__c') != null) isValid = wireConfig.get('Number_of_FWD_Wires__c') != null || wireConfig.get('Number_of_SSB_Wires__c') != null;
        //else isValid = wireConfig.get('Number_of_FWD_Wires__c') != null && wireConfig.get('Number_of_SSB_Wires__c') != null;

        if (getDecimal(wireConfig, 'Number_of_Wires__c', 0) > 0) isValid = getDecimal(wireConfig, 'Number_of_FWD_Wires__c', 0) > 0 || getDecimal(wireConfig, 'Number_of_SSB_Wires__c', 0) > 0;
        else isValid = getDecimal(wireConfig, 'Number_of_FWD_Wires__c', 0) > 0 && getDecimal(wireConfig, 'Number_of_SSB_Wires__c', 0) > 0;

        //one field must have a value
        if (!isValid)
        {
            try
            {
                missingFields.add('Two of: ' + FieldLabelHelper.getInstance().getLabel(objName, 'Number_of_Wires__c') + ' or ' + 
                                               FieldLabelHelper.getInstance().getLabel(objName, 'Number_of_FWD_Wires__c') + ' or ' +
                                               FieldLabelHelper.getInstance().getLabel(objName, 'Number_of_SSB_Wires__c') + 
                                               ' -- Wire Configuration ' + position );
            }
            catch (Exception e) 
            {
                // In case getting the label failed for some reason
                System.debug('### Error while adding required field label: ' + e);
            }
        }
        isValid = getDecimal(wireConfig, 'Number_of_Wires__c', 0) >= getDecimal(wireConfig, 'Number_of_FWD_Wires__c', 0) + getDecimal(wireConfig, 'Number_of_SSB_Wires__c', 0);
        if (!isValid)
        {
            missingFields.add('Number of Wires cannot be less than FWD Wires plus SSB Wires -- Wire configuration ' + position);
        }
        return isValid;
    }

    private Boolean validateMLFDieObjects(sObject dieConfig, String objName, Integer position, List<String> missingFields)
    {
        Boolean isValid = true;
        if (DataUtils.getString(dieConfig, 'Max_Die_Size__c', '') != 'INVALID')
        {
            if (getDecimal(dieConfig, 'Die_Size_X__c', 0) > getDecimal(dieConfig, 'Max_Die_Size__c', 0))
            {
                missingFields.add(FieldLabelHelper.getInstance().getLabel(objName, 'Die_Size_X__c')+ ' cannot be greater than Max Die -- Die Configuration ' + position);
                isValid = false;
            }

            if (getDecimal(dieConfig, 'Die_Size_Y__c', 0) > getDecimal(dieConfig, 'Max_Die_Size__c', 0))
            {
                missingFields.add(FieldLabelHelper.getInstance().getLabel(objName, 'Die_Size_Y__c')+ ' cannot be greater than Max Die -- Die Configuration ' + position);
                isValid = false;
            }
        }
        //AMK-2363 - only punch will reject body sizes below 3x3
        else if (DataUtils.getString(specificRfqItem, 'PF_Sub_Class_1__c', '') == 'PMLF')
        {
            missingFields.add('Invalid body sizes for this package family');
            isValid = false;
        }

        if (!DataUtils.getString(dieConfig, 'Die_Attach__c', '').toLowerCase().contains('epoxy')) rfqItem.Do_Not_Auto_Price__c = true;

        return isValid;
    }

    @TestVisible private Boolean validateAllMLFDieObjects(String objName, List<String> missingFields)
    {
        Boolean isValid = true;
        //---AMK-2064
        //---If there are two dies and the top die is larger than the bottom die by 500 microns 
        //---in either the x or y dimension, then sales can submit but it will not auto-price 
        //---If side by side config, sum of dies must be less than max die
        if (dieConfigurations.size() == 2)
        {
            Decimal die1X = DataUtils.getDecimal(dieConfigurations[0], 'Die_Size_X__c', 0);
            Decimal die1Y = DataUtils.getDecimal(dieConfigurations[0], 'Die_Size_Y__c', 0);
            Decimal die2X = DataUtils.getDecimal(dieConfigurations[1], 'Die_Size_X__c', 0);
            Decimal die2Y = DataUtils.getDecimal(dieConfigurations[1], 'Die_Size_Y__c', 0);

            String dieXLabel = FieldLabelHelper.getInstance().getLabel(objName, 'Die_Size_X__c');
            String dieYLabel = FieldLabelHelper.getInstance().getLabel(objName, 'Die_Size_Y__c');

            //they specified that a side by side configuration has different rules, but there is currently no way to check for a side by side
            Boolean sideBySideConfiguration = false;
            if (sideBySideConfiguration)
            {
                Decimal totalX = die1X + die2X;
                Decimal totalY = die1Y + die2Y;

                Decimal maxDie = getDecimal(dieConfigurations[0], 'Max_Die_Size__c', 0);

                if (totalX > maxDie)
                {
                    isValid = false;
                    missingFields.add('The sum of ' + dieXLabel + ' for all die configurations cannot be greater than the max die in a side by side configuration');
                }

                if (totalY > maxDie)
                {
                    isValid = false;
                    missingFields.add('The sum of ' + dieYLabel + ' for all die configurations cannot be greater than the max die in a side by side configuration');
                }

            }

            if (die2X - die1X > .5)
            {
                rfqItem.Do_Not_Auto_Price__c = true;
                doNotPriceError += dieXLabel + ' for die 2 cannot be more than 500 microns greater than ' + dieXLabel + ' for die 1' + '<br />';
            } 
            if (die2Y - die1Y > .5) 
            {
                rfqItem.Do_Not_Auto_Price__c = true;
                doNotPriceError += dieYLabel + ' for die 2 cannot be more than 500 microns greater than ' + dieYLabel + ' for die 1' + '<br />';
            }
        }
        else if (dieConfigurations.size() > 2)
        {
            rfqItem.Do_Not_Auto_Price__c = true;
            doNotPriceError += 'Cannot auto price if there are more than two die configurations' + '<br />';
        }

        return isValid;
    }


    @TestVisible private Boolean validatefcBGADieBumpPitch(sObject dieConfig, String objName, Integer position, List<String> missingFields)
    {
        Boolean isValid = true;
        Decimal bump = getDecimal(dieConfig, 'Bump_Pad_Pitch__c', 0);

        if (bump > 300) 
        {
            missingFields.add(FieldLabelHelper.getInstance().getLabel(objName, 'Bump_Pad_Pitch__c') + ' cannot be greater than 300 -- Die Configuration ' + position);
            isValid = false;
        }
        /*if (bump < 50)
        {
            missingFields.add(FieldLabelHelper.getInstance().getLabel(objName, 'Bump_Pad_Pitch__c') + ' cannot be less than 50 -- Die Configuration ' + position);
            isValid = false;
        }*/

        return isValid;
    }

    @TestVisible private Boolean validateSCSPObject(sObject specificRfqItem, String objName, List<String> missingFields)
    {
      //Ashish-15-May-2017 :Salesforce -81: JDevice Plant Quoting capability in SFDC. The validations are not required for new package family SCSP-JDev.
      //Start
      if(objName !='RFQI_SCSP_JDev__c'){
      
      //End   
        Boolean isValid = true;
        Decimal bodyZ = getDecimal(specificRfqItem, 'Body_Z__c', 0);

        if (bodyZ > 2.0)
        {
            missingFields.add(FieldLabelHelper.getInstance().getLabel(objName, 'Body_Z__c') + ' cannot be greater than 2.0');
            isValid = false;
        }

        if (bodyZ < .02)
        {
            missingFields.add(FieldLabelHelper.getInstance().getLabel(objName, 'Body_Z__c') + ' cannot be less than 0.02');
            isValid = false;
        }

        return isValid;
      } //Ashish-15-May-2017 : Salesforce-81: Ending If condition
        
        return true; //Ashish-15-May-2017 : Salesforce-81:Returning boolean.
        
    }

    @TestVisible private Boolean validateTest(sObject specificRfqItem, String objName, List<String> missingFields) {
        Boolean isValid = true;
        Decimal forecast = getDecimal(specificRfqItem, 'Forecast__c', 0);
        Decimal forecastMin = getDecimal(specificRfqItem, 'Forecast_Min__c', null);
        Decimal forecastMax = getDecimal(specificRfqItem, 'Forecast_Max__c', null);

        if(forecastMin != null || forecastMax != null) {
            if(forecastMin == forecastMax) {
                if(forecast < forecastMin) {
                    missingFields.add(FieldLabelHelper.getInstance().getLabel(objName, 'Forecast__c') + ' must be above ' + forecastMin.stripTrailingZeros().toPlainString());
                    isValid = false;
                }
            }
            else if (forecast < forecastMin || forecast > forecastMax) {
                missingFields.add(FieldLabelHelper.getInstance().getLabel(objName, 'Forecast__c') + ' must be between ' + forecastMin.stripTrailingZeros().toPlainString() + ' and ' + forecastMax.stripTrailingZeros().toPlainString());
                isValid = false;
            }
        }
        return isValid;
    }

    public Boolean validateManualEntryFields(List<String> missingFields)
    {
       // Validate main object
            Boolean isValid = true;
            Integer position;

            for (RFQILayoutSection section : layout.sectionMap.values()) {
                String sectionName = section.sectionName;
                System.debug('### About to validate section: ' + sectionName);

                if (!StringUtils.isMatch(sectionName,'Die Description') && 
                    !StringUtils.isMatch(sectionName,'Passive Description') && 
                    !StringUtils.isMatch(sectionName,'Insertion Description') && 
                    !StringUtils.isMatch(sectionName,'Insertion Cost and Price') && 
                    !StringUtils.isMatch(sectionName,'Minimum Tester Configuration') && 
                    !StringUtils.isMatch(sectionName,'Wire Description') && 
                    !String.isEmpty(sectionName) &&
                    !StringUtils.isMatch(sectionName,'Service Description') && layout.enabledSections.get(sectionName) && !packageFamily.No_Cost_Model__c) {
                    if (!validateManualEntryFieldsFromSection(specificRfqItem, section, packageFamily.Specific_RFQ_Item_Object__c, missingFields)) isValid = false;                  
                }
            }
            if (wireConfigurations != null && layout.sectionMap.containsKey('Wire Description') && layout.enabledSections.get('Wire Description')) 
            {
                position = 0;
                //RFQILayoutSection section = layout.sectionMap.get('Wire Description');
                for (sObject wireConfig : wireConfigurations) 
                {
                    RFQILayoutSection section = childObjectSections.get(wireConfig.Id);
                    position++;
                    if (!validateManualEntryFieldsFromSection(wireConfig, section, packageFamily.Specific_Wire_Configuration_Object__c, missingFields, ' -- Wire Configuration ' + position)) isValid = false;
                }
            }

            // Validate die objects
            if (dieConfigurations != null && layout.sectionMap.containsKey('Die Description') && layout.enabledSections.get('Die Description')) 
            {
                //RFQILayoutSection section = layout.sectionMap.get('Die Description');
                position = 0;
                for (sObject dieConfig : dieConfigurations) 
                {
                    RFQILayoutSection section = childObjectSections.get(dieConfig.Id);
                    position++;
                    if (!validateManualEntryFieldsFromSection(dieConfig, section, packageFamily.Specific_Die_Configuration_Object__c, missingFields, ' -- Die Configuration ' + position)) isValid = false;
                }
            }

            if (insertionConfigurations != null && (layout.sectionMap.containsKey('Insertion Description') && layout.enabledSections.get('Insertion Description')) || (layout.sectionMap.containsKey('Insertion Cost and Price') && layout.enabledSections.get('Insertion Cost and Price')) || (layout.sectionMap.containsKey('Minimum Tester Configuration') && layout.enabledSections.get('Minimum Tester Configuration'))) 
            {
                //RFQILayoutSection section = layout.sectionMap.get('Insertion Description');
                position = 0;
                for (sObject insertionConfig : insertionConfigurations) 
                {
                    RFQILayoutSection section = childObjectSections.get(insertionConfig.Id);
                    position++;
                    if (!validateManualEntryFieldsFromSection(insertionConfig, section, packageFamily.Specific_Insertion_Configuration_Object__c, missingFields, ' -- Insertion Configuration ' + position)) isValid = false;
                }
            }

            if (passiveConfigurations != null && layout.sectionMap.containsKey('Passive Description') && layout.enabledSections.get('Passive Description')) 
            {
                //RFQILayoutSection section = layout.sectionMap.get('Passive Description');
                position = 0;
                for (sObject passiveConfig : passiveConfigurations) 
                {
                    RFQILayoutSection section = childObjectSections.get(passiveConfig.Id);
                    position++;
                    if (!validateManualEntryFieldsFromSection(passiveConfig, section, packageFamily.Specific_Passive_Configuration_Object__c, missingFields, ' -- Passive Configuration ' + position)) isValid = false;
                }
            }

            if (serviceConfigurations != null && layout.sectionMap.containsKey('Service Description') && layout.enabledSections.get('Service Description')) 
            {
                //RFQILayoutSection section = layout.sectionMap.get('Passive Description');
                position = 0;
                for (sObject serviceConfig : serviceConfigurations) 
                {
                    RFQILayoutSection section = childObjectSections.get(serviceConfig.Id);
                    position++;
                    if (!validateManualEntryFieldsFromSection(serviceConfig, section, packageFamily.Specific_Service_Configuration_Object__c, missingFields, ' -- Service Configuration ' + position)) isValid = false;
                }
            }

            error = '<strong>Cannot price without manual entry fields:</strong><br />';

            Boolean isTestManualEntryRequired = true;
            
            for (String field : missingFields) 
            {
                    error += '<br />' + field;
            }

            if(hasAmkorSelected){
                error += '<br/><br/>'+amkorSelectedFields;
            }

            return isValid;
    }
    @TestVisible protected Boolean validateManualEntryFieldsFromSection(sObject obj, RFQILayoutSection section, String objName, List<String> missingFields) {
        return validateManualEntryFieldsFromSection(obj, section, objName, missingFields, '');
    }

    @TestVisible protected Boolean validateManualEntryFieldsFromSection(sObject obj, RFQILayoutSection section, String objName, List<String> missingFields, String location)
    {
        Boolean isValid = true;

        for (RFQISectionAttribute attribute : section.attributes) 
        {
            if (attribute.isManualEntry && attribute.fieldAPIName != 'Sub_Total__c')
            {
                if (obj.get(attribute.fieldAPIName) == null || (attribute.dataType == 'Decimal' && (Decimal)obj.get(attribute.fieldAPIName) <= 0)) 
                {
                    //Abhay N- 3-May-2017 : SF-204- 24.1, 24.2 - RFQI Test flow changes - Probe and Final Test
                    //Added the if-condition to check the package family and Is_BU_Price_Mandatory__c, to skip the error of 'manual entry fields' before 4th level of approval process. 
                    if( !((rfqItem.Package_Family_Name__c =='Test' && rfqItem.Is_BU_Price_Mandatory__c != True) 
                        && 
                        (FieldLabelHelper.getInstance().getLabel(objName, attribute.fieldAPIName) + location == 'BU Price/unit - Lead Scan' ||
                         FieldLabelHelper.getInstance().getLabel(objName, attribute.fieldAPIName) + location == 'BU Price/unit - Tape and Reel' || 
                         FieldLabelHelper.getInstance().getLabel(objName, attribute.fieldAPIName) + location == 'BU Price/unit - Ink Mark' ||
                         FieldLabelHelper.getInstance().getLabel(objName, attribute.fieldAPIName) + location == 'BU Price/unit - Laser Mark' ||
                         FieldLabelHelper.getInstance().getLabel(objName, attribute.fieldAPIName) + location == 'BU Price/unit - Other' ||
                         FieldLabelHelper.getInstance().getLabel(objName, attribute.fieldAPIName) + location == 'BU Price/unit - Bake' ||
                         FieldLabelHelper.getInstance().getLabel(objName, attribute.fieldAPIName) + location == 'BU Price/unit - Drop Ship' ||
                         FieldLabelHelper.getInstance().getLabel(objName, attribute.fieldAPIName) + location == 'BU Price/unit - De-Tape' ||
                         FieldLabelHelper.getInstance().getLabel(objName, attribute.fieldAPIName) + location == 'BU Price/unit - Dry Pack'
                        ))){ 
                            
                            try 
                            {
                                missingFields.add(FieldLabelHelper.getInstance().getLabel(objName, attribute.fieldAPIName) + location);

                            }
                            catch (Exception e) 

                            {
                                // In case getting the label failed for some reason
                                debug.log('Error while adding required field label: ' + e);
                            }
                            isValid = false;
                    }

                }
            }
        }

        return isValid;

    }

    public Decimal getDecimal(sObject obj, String fieldName, Decimal defVal) 
    {
        if(obj.get(fieldName) == null) return defVal;
        return Decimal.valueOf(String.valueOf(obj.get(fieldName)));
    }

    @TestVisible private Boolean validateBump(sObject specificRfqItem, String objName, List<String> missingFields)
    {
        Boolean isValid = true;
        String structure = String.valueOf(specificRfqItem.get('Structure__c'));
        if (structure == 'RDL = Bump + 2L Repass + RDL' && String.valueOf(specificRfqItem.get('RDL_Thickness__c')) == null)
        {
            missingFields.add(FieldLabelHelper.getInstance().getLabel(objName, 'RDL_Thickness__c')+ ' is required if RDL is selected for Structure');
            isValid = false;
        }
        String typeOfBump = String.valueOf(specificRfqItem.get('Type_of_Bump__c'));
        if (!StringUtils.isBlank(structure) && !StringUtils.isBlank(typeOfBump) && !(structure == 'BOP = Bump only (no repass, no RDL)' || typeOfBump  == 'RDL Only, No Bump') && String.valueOf(specificRfqItem.get('Passivation__c')) == null ) 
        {
            missingFields.add(FieldLabelHelper.getInstance().getLabel(objName, 'Passivation__c')+ ' is required if Structure is not BOP or Type of Bump is not RDL Only, No Bump');
            isValid = false;
        }
        if (!StringUtils.isBlank(typeOfBump) && !(typeOfBump == 'Plated' || typeOfBump  == 'RDL Only, No Bump') && (String.valueOf(specificRfqItem.get('Bump_Pitch__c'))) == null)
        {
            missingFields.add(FieldLabelHelper.getInstance().getLabel(objName, 'Bump_Pitch__c')+ ' is required if Type of Bump is not Plated or not RDL Only, No Bump');
            isValid = false;
        }
        return isValid;
    }

}