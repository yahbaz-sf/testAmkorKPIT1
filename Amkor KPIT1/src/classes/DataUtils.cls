public with sharing class DataUtils {
 
    public static final String DT_STRING = 'String';
    public static final String DT_BOOLEAN = 'Boolean';
    public static final String DT_DECIMAL = 'Decimal';

    public static Object get(sObject obj, String fieldName) {

        Object retVal = null;
        try { 
          retVal = obj.get(fieldName);
          system.debug('DataUtils.get  retval : '+retVal);
        }
        catch(Exception e) {
          System.debug(e);
        }
        system.debug('retVal'+retVal);
        return retVal;
    }

    public static Object get(sObject obj, String fieldName, String dataType) {
      
        Object val = null;
        if(dataType == DT_STRING) val = getString(obj,fieldname,null);
        if(dataType == DT_BOOLEAN) val = getBoolean(obj,fieldname,null);
        if(dataType == DT_DECIMAL) val = getDecimal(obj,fieldname,null);
        return val;
    }

    public static Boolean getBoolean(sObject obj, String fieldName, Boolean def) {
        Object val = get(obj,fieldName);
        if(val == null) return def;
        return Boolean.valueOf(val);
    }

    public static Decimal getDecimal(sObject obj, String fieldName, Decimal def) {
        system.debug('obj at line number 38 obj : '+obj);
        system.debug('obj at line number 39 fieldName : '+fieldName);
        system.debug('obj at line number 39 def: '+def);
        Object val = get(obj,fieldName);
        system.debug('val :  '+val);
        if(val == null) return def;
        return Decimal.valueOf(String.valueOf(val));
    }

    public static String getString(sObject obj, String fieldName, String def) {
        Object val = get(obj,fieldName);
        if(val == null) return def;
        return String.valueOf(val);
    }

    public static Date getDate(sObject obj, String fieldName, Date def) {
        Object val = get(obj,fieldName);
        if(val == null) return def;
        return Date.valueOf(val);
    }

    public static Object convert(Object input, String dataType) {
        Object val = null;
        if(dataType == DT_STRING) val = String.valueOf(input);
        if(dataType == DT_BOOLEAN) val = Boolean.valueOf(input);
        if(dataType == DT_DECIMAL) val = Decimal.valueOf(String.valueOf(input));
        return val;
    }

    //Ashish - 10-April-2017 : Salesforce-207 : Update Mark Berry Price Complete notifications to include Europe
    //Created new method to add key value to map
    public static void addStringKeyValueToMap(String key, String value, map<String, List<String>> keyValMap) {
        
        if(keyValMap != null && String.isNotBlank(key) && String.isNotBlank(value)) {
            if (keyValMap.containsKey(key))
            {
                keyValMap.get(key).add(value);
            }
            else
            {
                List<String> valueList = new List<String>();
                valueList.add(value);
                keyValMap.put(key, valueList);
            }
        }
    }
       
}