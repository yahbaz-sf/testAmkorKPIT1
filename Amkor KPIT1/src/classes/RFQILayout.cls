/*************************************************************************
* 
* PURPOSE:  this class describes the layout for the custom RFQItem* visual
*           force pages
* CLASS: RFQILayout
* CREATED: 03/12/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Jason Swenski
* 
**************************************************************************/
public class RFQILayout {
    
    public List<RFQILayoutSection> sections {get; set;}
    public Map<String,RFQILayoutSection> sectionMap {get; set;}
    public Integer bUColumns {get; set;}
    public Integer salesColumns {get; set;}
    public Map<String,Boolean> enabledSections {get; set;} 
    private Map<String,RFQISectionAttribute> fieldsWithOther;
    private List<String> hiddenFields;
    public Decimal currentLayoutVersion {get; set;}
    public Decimal itemLayoutVersion {get; set;}

    private transient List<RFQI_PF_Field_Def__c> fieldDefs;
    public String pageType;

    public DebugUtils debug {get {return DebugUtils.getInstance();} }
    
    public RFQILayout(List<RFQI_PF_Field_Def__c> fieldDefinitions, Map<String,Boolean> enabledSecs, Decimal currentLayoutVer, Decimal itemLayoutVer) {
        this(fieldDefinitions, enabledSecs, currentLayoutVer, itemLayoutVer, 'Both');
    }
    public RFQILayout(List<RFQI_PF_Field_Def__c> fieldDefinitions, Map<String,Boolean> enabledSecs, Decimal currentLayoutVer, Decimal itemLayoutVer, String pageType) {
        enabledSections = enabledSecs;
        sections = new List<RFQILayoutSection>();
        sectionMap = new Map<String,RFQILayoutSection>();
        fieldsWithOther = new Map<String,RFQISectionAttribute>();   
        hiddenFields = new List<String>();
        fieldDefs = fieldDefinitions;
        this.pageType = pageType;

        currentLayoutVersion = currentLayoutVer;
        itemLayoutVersion = itemLayoutVer == null ? currentLayoutVersion : itemLayoutVer;


        for(RFQI_PF_Field_Def__c def : fieldDefinitions) {
            //if field is deprecated, and layout is current, it goes in the deprecated fields section
            //if field is deprecated, and alyout is not current, it keeps its original position
            //this is so that in the list view, it shows up properly
            String sectionName = (def.Deprecated__c && currentLayoutVer == itemLayoutVersion) ? 'Deprecated Fields' : def.RFQI_Section__r.Name;
            if(def.Belongs_To_Section__c == 'Post Test Services Cost and Price') {
                RFQILayoutSection section = sectionMap.get('Post Test Services Cost and Price');
                if(section == null) { 
                    section = new RFQILayoutSection('Post Test Services Cost and Price');
                    sections.add(section);
                    sectionMap.put('Post Test Services Cost and Price',section);
                    enableSection('Post Test Services Cost and Price');
                }
            }
            if(def.Belongs_To_Section__c == 'NRE') {
                RFQILayoutSection section = sectionMap.get('NRE');
                if(section == null) { 
                    section = new RFQILayoutSection('NRE');
                    sections.add(section);
                    sectionMap.put('NRE',section);
                    enableSection('NRE');
                }
            }

            //only show fields from sales sections on sales screens, bu on bu screens
            if (pageType == 'Both' || def.RFQI_Section__r.Page_Type__c == pageType || def.RFQI_Section__r.Page_Type__c == 'Both' || def.RFQI_Section__c == null)
            {
                RFQILayoutSection section = sectionMap.get(sectionName);
                enableSection(sectionName);
                if(section == null) { 
                    section = new RFQILayoutSection(sectionName);
                    sections.add(section);
                    sectionMap.put(sectionName,section); 
                }
                RFQISectionAttribute attribute = section.addAttribute(def);
                if(attribute.hasOtherField) {
                    fieldsWithOther.put(attribute.fieldAPIName,attribute);
                }
            }
        }

    }

    public void hideField(String apiName) {
        for(RFQILayoutSection section : sections) {
            section.hideField(apiName);            
        }
    }

    public void changeEditability(String apiName, Boolean editable) {
        for(RFQILayoutSection section : sections) {
            section.changeEditability(apiName,editable);
        }
    }

    public void changeRendered(String apiName, Boolean rendered) {
        for(RFQILayoutSection section : sections) {
            section.changeRendered(apiName,rendered);            
        }
    }

    public void changeEditabilityForChild(String apiName, Boolean editable, List<RFQILayoutSection> childSections) {
        for(RFQILayoutSection section : childSections) {
            section.changeEditability(apiName,editable);            
        } 
    }

    public void reRender(Boolean editable, Boolean hasParent) {
        for(RFQILayoutSection section : sections) {
            section.reRender(editable, hasParent);          
        }
    } 
 
    public Boolean hasOtherField(String apiName) {
        return fieldsWithOther.containsKey(apiName);
    }
   
    private RFQISectionAttribute getFieldWithOther(String apiName) {
        if(hasOtherField(apiName)) {
            return fieldsWithOther.get(apiName);
        }
        return null;
    }

    public Set<String> getOtherFieldAPINames() {
        return fieldsWithOther.keySet();
    }

    public List<RFQISectionAttribute> getAllAttributes() {
    List<RFQISectionAttribute> results = new List<RFQISectionAttribute>();
    for (RFQILayoutSection section : sections) {
        results.addAll(section.attributes);
    } 
    return results;
    }

    public List<RFQISectionAttribute> getFactoryAttributes() {
        List<RFQISectionAttribute> results = new List<RFQISectionAttribute>();
    for (RFQISectionAttribute attribute : getAllAttributes()) {
        if (attribute.controlsFactory) results.add(attribute);
    }
    System.debug('results : '+results);
    return results;
    }

    public Set<RFQISectionAttribute> getOtherFieldAttributes() {
        Set<RFQISectionAttribute> results = new Set<RFQISectionAttribute>();
        system.debug('Size: ' + getAllAttributes().size());
    for (RFQISectionAttribute attribute : getAllAttributes()) {
        if (attribute.hasOtherFields) results.add(attribute);
    }
    return results;
    }

    public Set<String> getOtherFieldAttributesAPINames() {
        Set<String> results = new Set<String>();
    for (RFQISectionAttribute attribute : getAllAttributes()) {
        if (attribute.hasOtherFields) results.add(attribute.fieldAPIName);
    }
    return results;
    }
     
    public Set<RFQISectionAttribute> getRequiredFieldAttributes() {
        Set<RFQISectionAttribute> results = new Set<RFQISectionAttribute>();
        for (RFQISectionAttribute attribute : getAllAttributes()) {
            if (attribute.hasRequiredFields) results.add(attribute);
        }
        system.debug('RFQILayout 169 results:'+results);
        return results;
    }

    public void setBUColumns(Integer buCol) {
        buColumns = buCol != null & buCol  > 0 ? buCol : 4;
        // if layout is deprecated, have only one column
        //buColumns = itemLayoutVersion < currentLayoutVersion ? 1 : buColumns;
    }
    
    public void setSalesColumns(Integer salesCol) {
        salesColumns = salesCol != null & salesCol  > 0 ? salesCol : 3; 
        // if layout is deprecated, have only one column
        //salesColumns = itemLayoutVersion < currentLayoutVersion ? 1 : salesColumns;
    }

    public List<RFQISectionAttribute> getAttributesForObject(String objectType) {
    List<RFQISectionAttribute> attribs = new List<RFQISectionAttribute>();
        for(RFQISectionAttribute attribute : getAllAttributes()) {
            if(attribute.objectType == objectType) attribs.add(attribute);
        } 
        return attribs;
    }

    public void addAttributeForOtherField(String apiName) {
        RFQISectionAttribute attribute = getFieldWithOther(apiName);
        if(attribute != null) {
            RFQISectionAttribute otherAttribute = attribute.getOtherField();
            otherAttribute.includeOnQuote = true; // Hotfix -- can go away once Raghu's other field change goes in
            addAttribute(otherAttribute, otherAttribute.belongsToSection);            
            //Create other field and add it to the layout here 
        }        
    } 

    public void addAttribute(RFQISectionAttribute attribute, String sectionName) {

        if(sectionMap != null && sectionMap.containsKey(sectionName)) {
            RFQILayoutSection section = sectionMap.get(sectionName);
            //throw new FieldBuilderHelperException(String.valueOf(section.attributes.size()));
            section.attributes.add(attribute);
            //throw new FieldBuilderHelperException(String.valueOf(section.attributes.size()));
            section.attributes.sort();
            //throw new FieldBuilderHelperException(String.valueOf(section.sectionName));
        }
    }

    public void addAttributeToSection (RFQISectionAttribute attribute, String sectionName) {
        
        if (sectionMap != null && sectionMap.containsKey(sectionName)) {
            RFQILayoutSection section = sectionMap.get(sectionName);
            system.debug('section : '+section);
            for (RFQISectionAttribute attrib : section.attributes){
                if (attrib.fieldAPIName == attribute.fieldAPIName) {
                    attrib.belongsToSection = attribute.belongsToSection;
                    system.debug('attrib : '+attrib);
                }
            }
        }
    }

    public void addChildAttribute(RFQISectionAttribute attribute, RFQILayoutSection section) {
        if (section != null) {
            section.attributes.add(attribute);
            section.attributes.sort();
        }
    }

    public void removeOtherAttribute(String fieldAPIName) {
        RFQISectionAttribute attribute = getFieldWithOther(fieldAPIName);
        if(attribute != null) {
            removeAttributeFromSection(attribute.otherFieldName, attribute.belongsToSection);
        }
    }

    public void removeAttributeFromSection(String fieldAPIName, String sectionName) {
        if(sectionMap != null && sectionMap.containsKey(sectionName)) {
            RFQILayoutSection section = sectionMap.get(sectionName);
            for(Integer i = 0; i < section.attributes.size(); i++) {
                RFQISectionAttribute attribute = section.attributes.get(i);
                if(attribute.fieldAPIName == fieldAPIName) {
                    section.attributes.remove(i);
                }
            }
            section.attributes.sort();
        }
    }
    
    public List<RFQISectionAttribute> getNonWireAttributes() {
        return getAttributesForObject('Package');
    }
    
    public void enableSection(String sectionName) {
        setSectionEnabled(sectionName, true);
    }
    
    public void disableSection(String sectionName) {
        setSectionEnabled(sectionName, false);
    }
    
    private void setSectionEnabled(String sectionName, Boolean isEnabled) {
        enabledSections.put(sectionName,isEnabled);
    }
    
    public void removeNonCpnAttributes() {
        for (RFQILayoutSection section : sections) {
    // Go through attributes and remove each one that is not CPN flagged
            for (Integer i = section.attributes.size() - 1; i >= 0; i--) {
                RFQISectionAttribute attrib = section.attributes.get(i);
                if (!attrib.isCpnAttribute) {
                    section.attributes.remove(i);
             }
            }
            
            // If no more attributes, then disable the section
            if (section.attributes.size() == 0) {
                disableSection(section.sectionName);
            }
        }
    }

    public RFQILayout copy() {
        RFQILayout layout = new RFQILayout(fieldDefs, enabledSections, currentLayoutVersion, itemLayoutVersion, pageType);
        return layout;
    }

    public Boolean containsField(String fieldAPIName, Boolean includeBUFields) {
        
        for(String sectionName : sectionMap.keyset()) {

            for(RFQISectionAttribute attribute : sectionMap.get(sectionName).attributes) {
                if(fieldAPIName == attribute.fieldAPIName) {
                    if(sectionName == 'Cost and Price') return false;
                    else return true;
                }
            }
        }

        return false; 
    }
}