/*************************************************************************
*
* PURPOSE: modifies CPN values
*
* CLASS: <CPNAttribute>
* CREATED: 03/18/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Various
*
***************************************************************************/
global class CPNAttribute implements Comparable {

    public static final String CPN_ATTRIBUTE_WIRE = 'W';
    public static final String CPN_ATTRIBUTE_PACKAGE = 'P';
    public static final String CPN_ATTRIBUTE_DIE = 'D';
    public static final String CPN_ATTRIBUTE_SUBSTRATE = 'S';
    public static final String BUCKET_EQUAL_INTERVALS = 'Equal Intervals';
   
    public String attributeIndex {get; set;}
    public String fieldName {get; set;} 
    public String value {get; set;}
    public String attributeType {get; set;}
    public String unitOfMeasure {get; set;}
    
    /**
    *  Constuctor for CPN Attribute 
    * 
    *  @param lineItem a specific line item or wire configuration object e.g. a RFQI_SOIC_150 object
    *  @param a field definition for this object e.g. a field def for Lead_Count__c
    * 
    **/
    public CPNAttribute(RFQI_PF_Field_Def__c def, Object fieldValue, Integer index) {
        
        attributeIndex = String.valueOf(index); 
        unitOfMeasure = def.CPN_Units__c;
        if(def.Sales_Units__c != def.CPN_Units__c) {
            Decimal tmpVal = UnitUtils.getInstance().convert(fieldValue, def.Sales_Units__c, def.CPN_Units__c);
            value = String.valueOf(tmpVal);
        }
        else{
            value = String.valueOf(fieldValue);
        }
        
        if(value ==  null) {
            value = '';
        }
        else {
            value = value.toUpperCase();
        }
        fieldName = def.SAP_Name__c; //TODO -- this should go to CPN Name..
        
        if (StringUtils.isBlank(fieldName)) {
        	System.debug(LoggingLevel.WARN, 'No SAP name found for attribute: ' + def.RFQI_Field_Def__r.Name);
        	 fieldName = def.RFQI_Field_Def__r.Name;
        }
        
        Integer sapIndex = index == null ? 1 : index + 1;
        
        attributeType = StringUtils.charAt(def.RFQI_Field_Def__r.Object__c,0)  + sapIndex;
        if(def.RFQI_Field_Def__r.Object__c == 'Package') attributeType = 'A' + sapIndex ;
      
        if(def.Bucket_Strategy__c == BUCKET_EQUAL_INTERVALS) {
        	computeHighLowEqualInterval(def.Equal_Interval_Start__c,def.Equal_Interval_Length__c);
        }
    }
    
    global Integer compareTo(Object o){
        CPNAttribute otherAttribute = (CPNAttribute) o;
        
        Integer comp = attributeIndex.compareTo(otherAttribute.attributeIndex);
        if(comp != 0) return comp;
        comp = attributeType.compareTo(otherAttribute.attributeType);
        if(comp != 0) return comp;
        comp = fieldName.compareTo(otherAttribute.fieldName);
        if(comp != 0) return comp;
        comp = value.compareTo(otherAttribute.value);	
        return comp;
    }   
     
    /**
    * Computes the intervals for the CPN bucketing
    *
    * @param  start start value
    * @param length length value
    **/
    private void computeHighLowEqualInterval(Decimal start, Decimal length) {
    	
    	Decimal val = Decimal.valueOf(value);
    	Decimal lVal = start;
    	Decimal hVal = start + length;
    	
    	while(val > hVal) { 
    		hVal += length;
    		lVal += length;
    	}
        //Per Chandan, If a CPN Attribute "XYZ" has a bucketed value 
        //of "100 to 200", then send 100-200
    	value = lVal + '-' + hVal;
    } 
    
   
}