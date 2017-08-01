public with sharing class FieldLabelHelper {
	private static FieldLabelHelper instance;
	
	// Map of Object API Names -> (Map of Field API Name -> Label)
	private Map<String, Map<String, String>> fieldLabelMap = new Map<String, Map<String, String>>();


	private Map<String, Map<String, Schema.SObjectField>> fieldDescribeCache = new Map<String, Map<String, Schema.SObjectField>>();
	
	private FieldLabelHelper() {}
	
	public static FieldLabelHelper getInstance() {
		if (instance == null) {
			instance = new FieldLabelHelper();
		}
		
		return instance;
	}

	public Map<String, Schema.SObjectField> getFieldList(SObject targetObj)
	{
		Schema.DescribeSObjectResult descr = targetObj.getSObjectType().getDescribe();
		if (!fieldDescribeCache.containsKey(descr.getName()))
		{
			fieldDescribeCache.put(descr.getName(), descr.fields.getMap());
		}
		
		return fieldDescribeCache.get(descr.getName());
	}

	public Schema.DescribeFieldResult getFieldInfo(SObject targetObj, String fieldName)
	{
		Map<String, Schema.SObjectField> fieldList = getFieldList(targetObj);
		Schema.SObjectField field = fieldList.get(fieldName);
		return field == null ? null : field.getDescribe();
	}
	
	// TODO This could probably use the fieldDescribeCache at some point
	public String getLabel(String objectName, String labelApiName) {
		labelApiName = labelApiName.toLowerCase();

		if (!fieldLabelMap.containsKey(objectName)) {
			Map<String, String> fieldMap = new Map<String, String>();
			fieldLabelMap.put(objectName, fieldMap);
			
			Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
			
			for (String fieldName : objectFields.keySet()) {
				Schema.SObjectField field = objectFields.get(fieldName);
				Schema.DescribeFieldResult fieldInfo = field.getDescribe();
				
				fieldMap.put(fieldInfo.getName().toLowerCase(), fieldInfo.getLabel());
			}
		}
		
		Map<String, String> labelsMap = fieldLabelMap.get(objectName);
		if (labelsMap.containsKey(labelApiName)) {
			return labelsMap.get(labelApiName);
		}
		
		// If not found for some reason then just return labelApiName rather than throwing an exception
		return labelApiName;
	}


}