public with sharing class RFQIDeprecatedSectionEditController {

	public List<RFQISectionAttribute> packageFields {get; set;}
	public List<RFQISectionAttribute> wireFields {get; set;}
	public List<RFQISectionAttribute> dieFields {get; set;}
	public List<RFQISectionAttribute> passiveFields {get; set;}
	public List<RFQISectionAttribute> insertionFields {get; set;}	
	public RFQILayout lay {get; set{
			lay = value;
			packageFields = new List<RFQISectionAttribute>();
			wireFields = new List<RFQISectionAttribute>();
			dieFields = new List<RFQISectionAttribute>();
			passiveFields = new List<RFQISectionAttribute>();
			insertionFields = new List<RFQISectionAttribute>();

			Map<String, Boolean> depMap = new Map<String, Boolean>();
			List<RFQISectionAttribute> depFields = lay.sectionMap.get('Deprecated Fields').attributes;
			for (RFQISectionAttribute att : depFields) depMap.put(att.fieldAPIName, true);
			for (RFQILayoutSection section : lay.sections)
			{
				for (RFQISectionAttribute attrib : section.attributes)
				{
					if (depMap.containsKey(attrib.fieldAPIName) && depMap.get(attrib.fieldAPIName)  )
					{
						if (attrib.objectType == 'Package') packageFields.add(attrib);
						else if(attrib.objectType == 'Wire') wireFields.add(attrib);
						else if(attrib.objectType == 'Die') dieFields.add(attrib);
						else if(attrib.objectType == 'Passive') passiveFields.add(attrib);
						else if(attrib.objectType == 'Insertion') insertionFields.add(attrib);

					}
				}
			}
		}
	}
	public RFQIDeprecatedSectionEditController() {}
}