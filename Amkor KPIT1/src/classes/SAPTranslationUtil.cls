public with sharing class SAPTranslationUtil {
	
	private static final SAPTranslationUtil mInstance = new SAPTranslationUtil();
	//TODO - move transform and loadTranslationMap out into a Util class  
	private static Map<String,String> transValue;
	
	private SAPTranslationUtil() {
		transValue = new Map<String,String>();
     	for(SAP_Translation__c t : [select Id,Code__c,Value__c from SAP_Translation__c]) {
	  	    transValue.put(t.Code__c,t.Value__c);
	    }
	}
	
	public static SAPTranslationUtil getInstance() {
		return mInstance;
	}
	
	public String transform(String prefix, String value) {
		String key = prefix + (value == null ? '' : value);
		//look for a transformation 
		if(transValue.containsKey(key)){
			return transValue.get(key);
		}
		//if a translation couldn't be found just return the value
		if(key.length() > key.lastIndexOf('.')) {
		    return key.substring(key.lastIndexOf('.'));
		}
		//else return nothing
		return '';
	}
}