/*************************************************************************
*
* PURPOSE: Misc. utils for working with RFQILayouts
*          TODO:  Right now this logic is duplicated a lot from the item screens
*                 The item screens should eventually be cleaned up so they can
*                 use this util class if possible, to reduce code duplication
* 
* CLASS: LayoutUtil
* CREATED: 10/24/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Nathan Pilkington
***************************************************************************/
public class LayoutUtil {

	// TODO De-duplicate all of this stuff, right now it is too entangled with the item screens to do so

	public static void setupLayoutForBuEditScreen(RFQItemWrapper wrapper, RFQILayout itemLayout) {
		if (wrapper.packageFamily.No_Cost_Model__c || wrapper.rfqItem.Do_Not_Auto_Price__c) {
            RFQILayoutSection section = itemLayout.sectionMap.get('Cost and Price');

            if (section != null) {
                enableAllEditability(itemLayout, section);
            }

            CMBUilder builder = CMBuilder.getCMBuilderByWrapper(wrapper);                  
            builder.setEditabilityforNoCostModel(itemLayout);
        }
        else {
            itemLayout.reRender(true, wrapper.getHasParent());
        }
	}

	public static void enableAllEditability(RFQILayout itemLayout, RFQILayoutSection section) {
        List<RFQISectionAttribute>  attributes = section.attributes;
        for(RFQISectionAttribute attribute : attributes){            
            itemLayout.changeEditability(attribute.fieldAPIName,true);            
        }        
    }
	
    public static void runOtherFieldsChange(RFQItemWrapper wrapper, RFQILayout layout){
        Set<Id> objectIds = wrapper.childObjectSections.keySet();
        String fieldValue = null;
        Set<RFQISectionAttribute> attributeList = layout.getOtherFieldAttributes();
        for (RFQISectionAttribute attribute : attributeList) {
            fieldValue = null;
            if(attribute.objectType == RFQItemWrapper.PACKAGE_OBJECT) {
                fieldValue = String.valueOf(wrapper.getAttribute(attribute.fieldAPIName, RFQItemWrapper.PACKAGE_OBJECT, 0));
                addOtherField(fieldValue, attribute, layout, null, wrapper);
            }
            else {
                for (Id objectId : objectIds) {
                    try{
                        fieldValue = String.valueOf(wrapper.getAttribute(attribute.fieldAPIName, objectId));
                            addOtherField(fieldValue, attribute, layout, objectId, wrapper);
                    }
                    catch (Exception e) {
                        system.debug('Could not find field value on object Id: ' + e);
                    }  
                }
            }
        }
    }

    public static void addOtherField(String fieldValue, RFQISectionAttribute attribute, RFQILayout layout, Id objectId, RFQItemWrapper wrapper) {
    if(fieldValue != null && attribute.otherFields.containsKey(fieldValue.toLowerCase())) {
        for (String fields : attribute.otherFields.get(fieldValue.toLowerCase())) {
            for (RFQISectionAttribute attrib : layout.getAllAttributes()) {
                if (attrib.fieldAPIName == fields) {
                    attrib.changeSection();
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
	
}