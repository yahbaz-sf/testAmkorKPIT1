/*************************************************************************
* 
* PURPOSE:  this class describes the layout section for the custom RFQItem* visual
*           force pages
* CLASS: RFQILayoutSection
* CREATED: 03/12/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Jason Swenski
* 
**************************************************************************/
public class RFQILayoutSection {
    
    public String sectionName {get; set;}
    public List<RFQISectionAttribute> attributes {get; set;}
    
    public RFQILayoutSection(String secName) {
        sectionName = secName;
        attributes = new List<RFQISectionAttribute>();
    }

    public void hideField(String apiName) {
        for(Integer i = 0; i < attributes.size(); i++) {
            if(apiName.toLowerCase() == attributes.get(i).fieldAPIName.toLowerCase()) {
                attributes.remove(i);
            }
        }
        system.debug('RFQILayoutSection  attributes:   '+attributes);
    }
    
    //Lalit - 16-Jan-2017 : Salesforce-42 :Turnkey ATP with ultraFlex (TI)
    //method created if we want to hide multiple fields.
    public void hideFields(Set<String> apiNamesInLowerCase) {
        for(Integer i = 0; i < attributes.size(); i++) {
            system.debug('apiNamesInLowerCase: '+apiNamesInLowerCase);
            system.debug('attributes.get(i).fieldAPIName.toLowerCase(): '+attributes.get(i).fieldAPIName.toLowerCase());
            if(apiNamesInLowerCase.contains(attributes.get(i).fieldAPIName.toLowerCase())) {
                attributes.remove(i);
            }
        }
    }

    public void changeEditability(String apiName, Boolean editable) {
        for (RFQISectionAttribute attribute : attributes) {
           if (apiName.toLowerCase() == attribute.fieldAPIName.toLowerCase()) {
                attribute.isEditable = editable;
            }
        }
    }

    public void changeRendered(String apiName, Boolean rendered) {
        for (RFQISectionAttribute attribute : attributes) {
           if (apiName.toLowerCase() == attribute.fieldAPIName.toLowerCase()) {
                attribute.rendered = rendered;            
            }
        }
    }

    public void changeMer(String apiName, Boolean isMer) {
        for (RFQISectionAttribute attribute : attributes) {
           if (apiName.toLowerCase() == attribute.fieldAPIName.toLowerCase()) {
                attribute.isManualEntry = isMer;            
            }
        }
    }

    public void reRender(Boolean editable, Boolean hasParent) {
        for(RFQISectionAttribute attribute : attributes) {
            attribute.reRender(editable, hasParent);
        }
    }
    
    public RFQISectionAttribute addAttribute(RFQI_PF_Field_Def__c fieldDef) {
            RFQISectionAttribute attribute = new RFQISectionAttribute(fieldDef);
            attributes.add(attribute);
            system.debug(LoggingLevel.Info,'attributes : '+attributes);
            return attribute;
    } 

    public RFQILayoutSection copy() {
        RFQILayoutSection section = new RFQILayoutSection(this.sectionName);
        for (RFQISectionAttribute attribute : this.attributes) {
            section.attributes.add(attribute.clone());
        }
        return section;
    }
}