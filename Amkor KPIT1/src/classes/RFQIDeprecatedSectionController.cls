/*************************************************************************
*
* PURPOSE: used to build a map of deprecated fields 
*
* CLASS: RFQIDeprecatedSectionController
* CREATED: 9/20/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Austin Delorme
***************************************************************************/
public with sharing class RFQIDeprecatedSectionController {

	public Map<String, Boolean> deprecatedFields {get; set;}
	public RFQILayout lay {get; set{

			deprecatedFields = new Map<String, Boolean>();
			for (RFQILayoutSection section : value.sections)
			{
				for (RFQISectionAttribute attrib : section.attributes)
				{
					if (section.sectionName == 'Deprecated Fields') deprecatedFields.put(attrib.fieldAPIName, true);
					else deprecatedFields.put(attrib.fieldAPIName, false);
				}
			}
			
			lay = value;
		}
	}
}