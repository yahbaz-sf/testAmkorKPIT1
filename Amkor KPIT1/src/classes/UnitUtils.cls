/*************************************************************************
* 
* PURPOSE:  This class converts between the various units of measure
*           used in sales entry to units required for the cost models
*           or in CPN transmission. Instead of defining all possible
*           conversion factors it simply converts in and out 
*           of milimeters i.e. composition of functions to get the
*           desired result          
*
* CLASS: UnitUtilsTest
* CREATED: 05/23/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Jason Swenski
* 
**************************************************************************/
public with sharing class UnitUtils {
	
	private static final Integer CONVERSION_ACCURACY_PLACES = 7;
	
	public static final String UNIT_MM = 'mm';
	public static final String UNIT_MICROMETER = 'µm';
	public static final String UNIT_MIL = 'mil';
	public static final String UNIT_FT = 'ft';
	public static final String UNIT_INCH = 'in';

	private static Map<String,Decimal> conversions = new Map<String,Decimal>{
	    	'µm->mm' => 0.001,
	    	'mil->mm' => 0.0254,
	    	'in->mm' => 25.4,
	    	'ft->mm' => 304.8,
	    	'mm->µm' => 1000,
	    	'mm->mil' => 39.37007874015748,
	    	'mm->in' => 0.03937007874,
	    	'mm->ft' => 0.00328083989,
	    	'mm->mm' => 1.0
	};	
	
	private static final UnitUtils mInstance = new UnitUtils();
	
	private UnitUtils() {}
	
	public static UnitUtils getInstance() {
		return mInstance;
	}
	
    /**
    *  This method converts a value between any of the supported units {mm,mil,ft,in,µm} this
    *  method guarantees 7 decimal places of accuracy for conversions
    * 
    *  @param value an Object which contains the value, it can be a Decimal/Double/String
    *
    *  @param sourceUnit a unit of measure like UNIT_MM, UNIT_INCH.. etc which we are
    *         converting from
    *
    *  @param targetUnit a unit of measure like UNIT_MM, UNIT_INCH.. etc which we are
    *         converting to
    *
    **/
	public Decimal convert(Object value, String sourceUnit, String targetUnit) {
		if(value == null) return 0;
		Decimal tmpVal = Decimal.valueOf(StringUtils.TryParseDouble(String.valueOf(value)));
		
		if(sourceUnit == targetUnit) {
		    return tmpVal.setScale(CONVERSION_ACCURACY_PLACES);	
		}
		else if(conversions.containsKey(sourceUnit+'->'+targetUnit)) {
		    return (tmpVal * conversions.get(sourceUnit+'->'+targetUnit)).setScale(CONVERSION_ACCURACY_PLACES);
		}
		//what I was talking about earlier with just composing unit conversions
		//so you don't need all possible combinations
		else if(conversions.containsKey(sourceUnit+'->'+UNIT_MM) && conversions.containsKey(UNIT_MM+'->'+targetUnit) ) {
			Decimal toMM = 	conversions.get(sourceUnit+'->'+UNIT_MM);
			Decimal fromMM = conversions.get(UNIT_MM+'->'+targetUnit);
			return (tmpVal * toMM * fromMM).setScale(CONVERSION_ACCURACY_PLACES);
		} 
		else {
			throw new UnitConversionException('Could not convert between the specified units: ' + sourceUnit + '->' + targetUnit);
		}
		
	}
	
	public class UnitConversionException extends Exception {}

}