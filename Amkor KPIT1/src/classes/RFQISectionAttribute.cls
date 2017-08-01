/*************************************************************************
* 
* PURPOSE:  this class describes the layout attribute for the custom RFQItem* visual
*           force pages
* CLASS: RFQILayoutAttribute
* CREATED: 03/12/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Jason Swenski
* 
**************************************************************************/
global class RFQISectionAttribute implements Comparable{
    
    public Boolean isRequired {get; set;}
    public Boolean isGenerated {get; set;}
    public Boolean isCpnAttribute { get; set; }
    public Boolean isDefaultDriver {get; set;}
    public Boolean includeOnQuote { get; set; }
    public Boolean isLotCharge { get; set; }
    public Boolean controlsFactory { get; set; }
    public Boolean hasOtherField {get; set;}
    public String otherFieldName {get; set;}
    public Boolean hasOtherFields {get; set;}
    public Map<String, List<String>> otherFields {get; set;}
    public Boolean hasRequiredFields {get; set;}
    public Map<String, List<String>> requiredFields {get; set;}
    public String belongsToSection {get; set;}
    public Decimal sequenceNumber {get; set;}
    public Map<String, Set<String>> factoryValuesMap { get; set; }
    public String fieldAPIName {get; set;}
    public String objectAPIName {get; set;}
    public String objectType {get; set;}       
    public String dataType {get; set;}
    public Boolean rendered {get; set;}
    public Boolean isEditable {get; set;}
    public Boolean isBlank {get; set;}
    public String  onChangeScript {get; set;}
    public Boolean doCallback {get; set;}
    public Boolean isManualEntry {get; set;}
    public Boolean readOnlyIfParent { get; set; }
    public Boolean hasAmkorSelected {get; set;}
    public Boolean preserveOnClone {get; set;}
    public String belongsToSubSection {get;set;}
    public String sectionName {get; set;}

    // For now, this field is only used for the NRE section
    public Boolean showOnSalesScreen { get; set; }

    public RFQISectionAttribute() {}
       
    public RFQISectionAttribute(RFQI_PF_Field_Def__c def) {
        fieldAPIName = def.RFQI_Field_Def__r.Name;
        system.debug('fieldAPIName : '+fieldAPIName);
        objectType = def.RFQI_Field_Def__r.Object__c;
        system.debug('objectType  : '+objectType);
        dataType = def.RFQI_Field_Def__r.Type__c;
        isCpnAttribute = def.CPN_Attribute__c;
        isGenerated = def.Generated__c;
        isRequired = def.Required__c;
        system.debug('setting the field Required  : '+isRequired);
        hasOtherField = def.Other_Field__c != null;
        hasOtherFields = def.Other_Fields__c != null;
        system.debug('def.Required_Fields__c'+def.Required_Fields__c);
        hasRequiredFields = def.Required_Fields__c != null;
        system.debug('hasRequiredFields : '+hasRequiredFields);
        otherFieldName = def.Other_Field__c;
        sectionName = def.RFQI_Section__r.Name;
        system.debug('sectionName : '+sectionName);
        belongsToSection = def.Belongs_To_Section__c;
        sequenceNumber = def.Sequence__c;
        isManualEntry = def.Is_Manual_entry__c;
        objectAPIName = def.Object_API_Name__c;
        system.debug('objectAPIName : '+objectAPIName);
        isDefaultDriver = def.Default_Driver__c;
        rendered = true;
        isEditable = true;
        includeOnQuote = def.Include_on_Quote__c;
        isLotCharge = def.Is_Lot_Charge__c;
        controlsFactory = def.Controls_Factory__c;
        System.debug('controlsFactory : '+controlsFactory);
        readOnlyIfParent = def.Read_Only_If_Parent__c;
        isBlank = fieldAPIName == 'BLANK';
        hasAmkorSelected = def.Has_Amkor_Selected__c;
        onChangeScript = def.On_Change__c;
        preserveOnClone = def.Preserve_On_Clone__c;
        belongsToSubSection = def.Belongs_To_Section__c;
        system.debug(LoggingLevel.Info,'belongsToSubSection : '+belongsToSubSection);

        if (controlsFactory && !StringUtils.isBlank(def.Factory_Values__c)) {
            setupFactoryVals(def.Factory_Values__c);
        }

        if (hasOtherFields && !StringUtils.isBlank(def.Other_Fields__c)) {
            setupOtherFields(def.Other_Fields__c);
        }

        if (hasRequiredFields && !StringUtils.isBlank(def.Required_Fields__c)) {
            system.debug('def  : '+def);
            system.debug('def.Required_Fields__c : '+def.Required_Fields__c);
            setupRequiredFields(def.Required_Fields__c);
        }

        doCallBack = hasOtherField || isDefaultDriver || controlsFactory || hasOtherFields || hasRequiredFields;
    }

    public void reRender(Boolean editable, Boolean hasParent) {
        isEditable = editable && !isGenerated;
        if(fieldAPIName == 'Price_To_Customer__c' || fieldAPIName == 'Price_To_Customer_Minute__c' || fieldAPIName == 'Price_To_Customer_Hour__c' || fieldAPIName == 'Post_Price_To_Customer__c') {
           isEditable = true; //this was in conditional VF, baking it in here for now
        }

        if (readOnlyIfParent && hasParent) {
            isEditable = false;
        }
    }

    public String getLabelStyleClass() {
        if(isRequired) return ' customRequiredField';
        else if (isManualEntry || fieldAPIName == 'Insertion_BU_Price_Per_Hour__c') return ' customMERField';
        else return '';
    }

    public String getStyleClass() {
        return isDefaultDriver ? ' defaultDriver' : '';
    }
    
    public RFQISectionAttribute getOtherField() {
        RFQISectionAttribute newObj = this.clone();
        newObj.fieldAPIName = otherFieldName;
        newObj.dataType = 'String';
        newObj.isCpnAttribute = false;
        newObj.isGenerated = false;
        newObj.isRequired = true;
        newObj.isDefaultDriver = false;
        newObj.includeOnQuote = false;
        newObj.isLotCharge = false;
        newObj.controlsFactory = false;
        newObj.hasOtherField = false;
        newObj.otherFieldName = '';
        newObj.sequenceNumber += 0.1;
        return newObj;
    }

    //Don't know if this is still used, might be need to be deprecated 
    public RFQISectionAttribute getOtherFields(string fieldNameOther) {
        RFQI_PF_Field_Def__c def = null;
        RFQISectionAttribute newObj = null;
        try {
        def = [select Id,RFQI_Field_Def__r.Name,RFQI_Field_Def__r.Object__c,RFQI_Section__r.Name,Belongs_To_Section__c,RFQI_Field_Def__r.Type__c, CPN_Attribute__c,Factory_Values__c,Generated__c,Required__c, Other_Field__c, Other_Fields__c,Sequence__c,Is_Manual_entry__c, Object_API_Name__c, Default_Driver__c, Include_on_Quote__c, Is_Lot_Charge__c, Controls_Factory__c,Read_Only_If_Parent__c from RFQI_PF_Field_Def__c where RFQI_Field_Def__r.Name =: fieldNameOther and Object_API_Name__c =: this.objectAPIName];
        }
        catch (Exception e) {
            system.debug('Could not find PF Field Def: ' + fieldNameOther);
        }    
        if (def == null){
            newObj = this.clone();
            newObj.fieldAPIName = fieldNameOther;
            newObj.dataType = 'String';
            newObj.isCpnAttribute = false;
            newObj.isGenerated = false;
            newObj.isRequired = false;
            newObj.isDefaultDriver = false;
            newObj.includeOnQuote = false;
            newObj.isLotCharge = false;
            newObj.controlsFactory = false;
            newObj.hasOtherField = false;
            newObj.otherFieldName = '';
            newObj.sequenceNumber += 0.1;
            newObj.belongsToSection = 'Package Description';
            system.debug('Name for new field: ' + newObj.fieldAPIName);
            return newObj;
        }
        else {
            newObj = this.clone();
            newObj.fieldAPIName = def.RFQI_Field_Def__r.Name;
            newObj.objectType = def.RFQI_Field_Def__r.Object__c;
            newObj.dataType = def.RFQI_Field_Def__r.Type__c;
            newObj.isCpnAttribute = def.CPN_Attribute__c;
            newObj.isGenerated = def.Generated__c;
            if(def.RFQI_Field_Def__r.Object__c != RFQItemWrapper.PASSIVE_OBJECT) {newObj.isRequired = true;}
            newObj.hasOtherField = def.Other_Field__c != null;
            newObj.hasOtherFields = def.Other_Fields__c != null;
            newObj.otherFieldName = def.Other_Field__c;
            newObj.belongsToSection = def.Belongs_To_Section__c;
            newObj.sequenceNumber = def.Sequence__c;
            newObj.isManualEntry = def.Is_Manual_entry__c;
            newObj.objectAPIName = def.Object_API_Name__c;
            newObj.isDefaultDriver = def.Default_Driver__c;
            newObj.rendered = true;
            newObj.isEditable = true;
            newObj.includeOnQuote = def.Include_on_Quote__c;
            newObj.isLotCharge = def.Is_Lot_Charge__c;
            newObj.controlsFactory = def.Controls_Factory__c;
            newObj.readOnlyIfParent = def.Read_Only_If_Parent__c;

            if (newObj.controlsFactory && !StringUtils.isBlank(def.Factory_Values__c)) {
                setupFactoryVals(def.Factory_Values__c);
            }

            if (newObj.hasOtherFields && !StringUtils.isBlank(def.Other_Fields__c)) {
                setupOtherFields(def.Other_Fields__c);
            }
            newObj.doCallBack = newObj.hasOtherField || newObj.isDefaultDriver || newObj.controlsFactory || newObj.hasOtherFields;
            system.debug('Name for old field: ' + newObj.fieldAPIName);
            return newObj;

        }
        
    }

    public void changeSection() {
        RFQI_PF_Field_Def__c def = null;
        System.debug('Calling changeSection with field def name matching: '+this.fieldAPIName+' and Object API name matching: '+this.objectAPIName);
        try {
            def = [select Id,RFQI_Field_Def__r.Name,RFQI_Field_Def__r.Object__c,RFQI_Section__r.Name,
                          Belongs_To_Section__c,RFQI_Field_Def__r.Type__c, CPN_Attribute__c,Factory_Values__c,
                          Generated__c,Required__c, Other_Field__c, Other_Fields__c,Sequence__c,Is_Manual_entry__c, 
                          Object_API_Name__c, Default_Driver__c, Include_on_Quote__c, Is_Lot_Charge__c, 
                          Controls_Factory__c,Read_Only_If_Parent__c, Package_Family__r.Name from RFQI_PF_Field_Def__c 
                          where RFQI_Field_Def__r.Name =: this.fieldAPIName 
                          and Object_API_Name__c =: this.objectAPIName];
        }
        catch (Exception e) {
            DebugUtils.write('Could not find PF Field Def: ' + this.fieldAPIName);
        }    
        this.belongsToSection = def.Belongs_To_Section__c;
        if(def.RFQI_Field_Def__r.Object__c != RFQItemWrapper.PASSIVE_OBJECT && def.RFQI_Field_Def__r.Name !='Ground_Lid_Adhesive__c' && def.RFQI_Field_Def__r.Name !='HS_Adhesive__c' && def.RFQI_Field_Def__r.Name !='Stiffener_Adhesive__c' && def.Package_Family__r.Name != 'Electrical Services' && def.RFQI_Field_Def__r.Type__c !='Boolean' && def.RFQI_Field_Def__r.Name !='Wafer_Size_PK__c' && def.RFQI_Field_Def__r.Name !='GDPW_PK__c')
        {this.isRequired = true;}
    }

    private void setupFactoryVals(String factoryValues) {
        try {
            factoryValuesMap = new Map<String, Set<String>>();
            Map<String, Object> rawMap = (Map<String, Object>)System.JSON.deserializeUntyped(factoryValues);

        for (String key : rawMap.keySet()) {
            Set<String> stringVals = new Set<String>();

            List<Object> rawVals = (List<Object>)rawMap.get(key);
            for (Object rawVal : rawVals) {
                stringVals.add(String.valueOf(rawVal));
            }

            factoryValuesMap.put(key, stringVals);
        }
       }
       catch (Exception e) {
           System.debug('### Could not set up factory map: ' + e);
       }
   }

   private void setupOtherFields(String otherFieldValues) {
        otherFields = new Map<String, List<String>>();
        setupMapFromJSON(otherFields, otherFieldValues, 'other');
   }

   private void setupRequiredFields(String requiredFieldValues) {
        requiredFields = new Map<String, List<String>>();
        system.debug('RFQISectionAttribute requiredFields : '+requiredFields);
        system.debug('RFQISectionAttribute requiredFieldValues : '+requiredFieldValues);
        setupMapFromJSON(requiredFields, requiredFieldValues, 'required');
   }

   private void setupMapFromJSON(Map<String, List<String>> fieldMap, String jsonString, String type)
   {
       system.debug('RFQISectionAttribute fieldMap : '+fieldMap);
       system.debug('RFQISectionAttribute jsonString : '+jsonString);
       system.debug('RFQISectionAttribute type : '+type);
        try {
            Map<String, Object> rawMap = (Map<String, Object>)System.JSON.deserializeUntyped(jsonString);

            for (String key : rawMap.keySet()) {
                List<String> stringVals = new List<String>();

                List<Object> rawVals = (List<Object>)rawMap.get(key);
                for (Object rawVal : rawVals) {
                    stringVals.add(String.valueOf(rawVal));
                    system.debug('line number 267 stringVals  : '+stringVals);
                }
                fieldMap.put(key,stringVals);
                system.debug('line number 270 fieldMap  : '+fieldMap);
            }
        }
        catch (Exception e) {
            System.debug('### Could not set up ' + type + ' fields: ' + e);
        }
   }

   global Integer compareTo(Object compareTo) {
        RFQISectionAttribute compareToAtt = (RFQISectionAttribute)compareTo;
        if (sequenceNumber == compareToAtt.sequenceNumber) return 0;
        if (sequenceNumber > compareToAtt.sequenceNumber) return 1;
        return -1;        
   }
}