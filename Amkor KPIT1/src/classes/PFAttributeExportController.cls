public with sharing class PFAttributeExportController extends BaseController {

	public List<FieldHolder> attributes { get; set; }

	public String fileName { get; set; }

	public PFAttributeExportController() {
		String pfId = getParam('packageFamilyId');
		Boolean cpnOnly = getParam('showCpnOnly') == 'true';
		Package_Family__c packageFamily = PackageFamilyDao.getInstance().getById(pfId);
		Set<String> fieldNames = new Set<String>();

		fileName = packageFamily.Name + (cpnOnly ? '_CPN_Attributes' : '_Attributes');
		attributes = new List<FieldHolder>();

		List<RFQI_PF_Field_Def__c> fieldDefs;
		if (cpnOnly) fieldDefs = PFFieldDefDao.getInstance().getCPNAttributeFields(pfId);
		else fieldDefs = PFFieldDefDao.getInstance().getFieldsForPackageFamily(packageFamily.Id);

		// Remove relationship and duplicate attributes
		for (Integer i = fieldDefs.size() - 1; i >= 0; i--) {

			RFQI_PF_Field_Def__c fieldDef = fieldDefs[i];

			if (StringUtils.isBlank(fieldDef.RFQI_Field_Def__r.Name) || fieldDef.RFQI_Field_Def__r.Name.contains('__r') || fieldNames.contains(fieldDef.RFQI_Field_Def__r.Name)) {
				fieldDefs.remove(i);
			} 
			else {
				fieldNames.add(fieldDef.RFQI_Field_Def__r.Name);
			}
		}

		for (RFQI_PF_Field_Def__c fieldDef : fieldDefs) {
			attributes.add(new FieldHolder(fieldDef));
		}

	}

	private static Map<String, Map<String, Schema.SObjectField>> fieldDescribeCache = new Map<String, Map<String, Schema.SObjectField>>();
	
	private static Schema.DescribeFieldResult getFieldInfoForField(RFQI_PF_Field_Def__c fieldDef) {
		String objectName = fieldDef.Object_API_Name__c;

		if (!fieldDescribeCache.containsKey(objectName)) {
			Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
			fieldDescribeCache.put(objectName, fields);
		}

		Map<String, Schema.SObjectField> fieldMap = fieldDescribeCache.get(objectName);

		if (fieldMap.containsKey(fieldDef.RFQI_Field_Def__r.Name)) {
			return fieldMap.get(fieldDef.RFQI_Field_Def__r.Name).getDescribe();
		}
		
		return null;
	}


	public class FieldHolder {
		public String fieldLabel { get; set; }
		public String dataType { get; set; }
		public List<String> picklistValues { get; set; }
		public String defaultValue { get; set; }
		public Boolean isCpnAttribute { get; set; }
		public String sapName {get; set;}
		public String sectionType {get; set;}

		public FieldHolder(RFQI_PF_Field_Def__c fieldDef) {
			Schema.DescribeFieldResult field = getFieldInfoForField(fieldDef);

			if (field != null) {
				fieldLabel = field.getLabel();
				sapName = fieldDef.SAP_Name__c;
				sectionType = fieldDef.RFQI_Section__r.Name;
				//This logic was copied from CPNAttribute.cls, should probably be made
				//standard somehow
				if (StringUtils.isBlank(sapName)) {
        	        System.debug(LoggingLevel.WARN, 'No SAP name found for attribute: ' + fieldDef.RFQI_Field_Def__r.Name);
        	        sapName = fieldDef.RFQI_Field_Def__r.Name;
                }
				defaultValue = String.valueOf(field.getDefaultValue());
				isCpnAttribute = fieldDef.CPN_Attribute__c;
				picklistValues = new List<String>();
				defaultValue = String.valueOf(field.getDefaultValueFormula());


				Schema.DisplayType type = field.getType();
				if (friendlyTypeNames.containsKey(type)) dataType = friendlyTypeNames.get(type);
				else dataType = String.valueOf(type);

				if (type == Schema.DisplayType.Picklist) {
					for (Schema.PicklistEntry option : field.getPicklistValues()) {
						picklistValues.add(option.getLabel());
						if (option.isDefaultValue()) defaultValue = option.getLabel();
					}
				}
			}
		}

		private Map<Schema.DisplayType, String> friendlyTypeNames = new Map<Schema.DisplayType, String>
		{
			Schema.DisplayType.Boolean => 'Checkbox',
			Schema.DisplayType.Currency => 'Currency',
			Schema.DisplayType.Date => 'Date',
			Schema.DisplayType.DateTime => 'Date/Time',
			Schema.DisplayType.Double => 'Number',
			Schema.DisplayType.Email => 'Email',
			Schema.DisplayType.Integer => 'Integer',
			Schema.DisplayType.Percent => 'Percent',
			Schema.DisplayType.Phone => 'Phone',
			Schema.DisplayType.Picklist => 'Picklist',
			Schema.DisplayType.String => 'Text',
			Schema.DisplayType.TextArea => 'Text Area',
			Schema.DisplayType.Reference => 'Lookup'
		};


	}
}