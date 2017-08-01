/*************************************************************************
* 
* PURPOSE:  This class tests all permutations of conversions between
*           the various units that are used in sales attribute entry
*           cpn transmission and cost models. These tests gurantee
*           conversion within 7 decimal places.               
*
* CLASS: UnitUtilsTest
* CREATED: 05/23/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Jason Swenski
* 
**************************************************************************/
@isTest
private class UnitUtilsTest {
   
    private static Decimal MAX_TOLERANCE = 0.0000001;

    private static testmethod void mmToMilsTest() {
    	Decimal value = UnitUtils.getInstance().convert(1, UnitUtils.UNIT_MM, UnitUtils.UNIT_MIL);
    	System.assert(isAcceptableDelta(value,39.3700787,MAX_TOLERANCE));
    }
    
    private static testmethod void mmToInchesTest() {
    	Decimal value = UnitUtils.getInstance().convert(1, UnitUtils.UNIT_MM, UnitUtils.UNIT_INCH);
    	System.assert(isAcceptableDelta(value,0.0393701,MAX_TOLERANCE));
    }
    
    private static testmethod void mmToMicrometersTest() {
    	Decimal value = UnitUtils.getInstance().convert(1, UnitUtils.UNIT_MM, UnitUtils.UNIT_MICROMETER);
    	System.assert(isAcceptableDelta(value,1000,MAX_TOLERANCE));
    }
    
    private static testmethod void mmToFeetTest() {
    	Decimal value = UnitUtils.getInstance().convert(1, UnitUtils.UNIT_MM, UnitUtils.UNIT_FT);
    	System.assert(isAcceptableDelta(value,0.00328084,MAX_TOLERANCE));
    }
    
    private static testmethod void milsToMMTest() {
    	Decimal value = UnitUtils.getInstance().convert(1, UnitUtils.UNIT_MIL, UnitUtils.UNIT_MM);
    	System.assert(isAcceptableDelta(value,0.0254,MAX_TOLERANCE));
    }
    
    private static testmethod void milsToInchesTest() {
    	Decimal value = UnitUtils.getInstance().convert(1, UnitUtils.UNIT_MIL, UnitUtils.UNIT_INCH);
    	System.assert(isAcceptableDelta(value,0.001,MAX_TOLERANCE));
    }
    
    private static testmethod void milsToMicroMetersTest() {
    	Decimal value = UnitUtils.getInstance().convert(1, UnitUtils.UNIT_MIL, UnitUtils.UNIT_MICROMETER);
    	System.assert(isAcceptableDelta(value,25.4,MAX_TOLERANCE));
    }
    
    private static testmethod void milsToFeetTest() {
    	Decimal value = UnitUtils.getInstance().convert(1, UnitUtils.UNIT_MIL, UnitUtils.UNIT_FT);
    	System.assert(isAcceptableDelta(value,0.0000833333333,MAX_TOLERANCE));
    }
    
    private static testmethod void inchesToMMTest() {
    	Decimal value = UnitUtils.getInstance().convert(1, UnitUtils.UNIT_INCH, UnitUtils.UNIT_MM);
    	System.assert(isAcceptableDelta(value,25.4,MAX_TOLERANCE));
    }
    
    private static testmethod void inchesToMilsTest() {
    	Decimal value = UnitUtils.getInstance().convert(1, UnitUtils.UNIT_INCH, UnitUtils.UNIT_MIL);
    	System.assert(isAcceptableDelta(value,1000,MAX_TOLERANCE));
    }
    
    private static testmethod void inchesToMicrometersTest() {
    	Decimal value = UnitUtils.getInstance().convert(1, UnitUtils.UNIT_INCH, UnitUtils.UNIT_MICROMETER);
    	System.assert(isAcceptableDelta(value,25400,MAX_TOLERANCE));
    }
    
    private static testmethod void inchesToFeetTest() {
    	Decimal value = UnitUtils.getInstance().convert(1, UnitUtils.UNIT_INCH, UnitUtils.UNIT_FT);
    	System.assert(isAcceptableDelta(value,0.0833333,MAX_TOLERANCE));
    }
    
    private static testmethod void micrometersToMMTest() {
    	Decimal value = UnitUtils.getInstance().convert(1, UnitUtils.UNIT_MICROMETER, UnitUtils.UNIT_MM);
    	System.assert(isAcceptableDelta(value,0.001,MAX_TOLERANCE));
    }
    
    private static testmethod void micrometersToMilsTest() {
        Decimal value = UnitUtils.getInstance().convert(1, UnitUtils.UNIT_MICROMETER, UnitUtils.UNIT_MIL);
    	System.assert(isAcceptableDelta(value,0.0393700787,MAX_TOLERANCE));
    }
    
    private static testmethod void micrometersToInchesTest() {
    	Decimal value = UnitUtils.getInstance().convert(1, UnitUtils.UNIT_MICROMETER, UnitUtils.UNIT_INCH);
    	System.assert(isAcceptableDelta(value,0.0000393700787,MAX_TOLERANCE));
    }
    
    private static testmethod void micrometersToFeetTest() {
    	Decimal value = UnitUtils.getInstance().convert(1, UnitUtils.UNIT_MICROMETER, UnitUtils.UNIT_FT);
    	System.assert(isAcceptableDelta(value,0.0000032808399,MAX_TOLERANCE));
    }
    
    private static testmethod void feetToMMTest(){
    	Decimal value = UnitUtils.getInstance().convert(1, UnitUtils.UNIT_FT, UnitUtils.UNIT_MM);
    	System.assert(isAcceptableDelta(value,304.8,MAX_TOLERANCE));
    }   
    
    private static testmethod void feetToMilsTest() {
    	Decimal value = UnitUtils.getInstance().convert(1, UnitUtils.UNIT_FT, UnitUtils.UNIT_MIL);
    	System.assert(isAcceptableDelta(value,12000,MAX_TOLERANCE));
    } 
    
    private static testmethod void feetToInchesTest() {
    	Decimal value = UnitUtils.getInstance().convert(1, UnitUtils.UNIT_FT, UnitUtils.UNIT_INCH);
    	System.assert(isAcceptableDelta(value,12,MAX_TOLERANCE));
    }
    
    private static testmethod void feetToMicroMetersTest() {
    	Decimal value = UnitUtils.getInstance().convert(1, UnitUtils.UNIT_FT, UnitUtils.UNIT_MICROMETER);
    	System.assert(isAcceptableDelta(value,304800,MAX_TOLERANCE));
    }
    
    private static testmethod void mmToMMTest() {
    	Decimal value = UnitUtils.getInstance().convert(1, UnitUtils.UNIT_MM, UnitUtils.UNIT_MM);
    	System.assert(isAcceptableDelta(value,1,MAX_TOLERANCE));
    }
    
    private static testmethod void milsToMilsTest() {
    	Decimal value = UnitUtils.getInstance().convert(1, UnitUtils.UNIT_MIL, UnitUtils.UNIT_MIL);
    	System.assert(isAcceptableDelta(value,1,MAX_TOLERANCE));
    }
    
    private static testmethod void inchesToInchesTest() {
    	Decimal value = UnitUtils.getInstance().convert(1, UnitUtils.UNIT_INCH, UnitUtils.UNIT_INCH);
    	System.assert(isAcceptableDelta(value,1,MAX_TOLERANCE));
    }
    
    private static testmethod void micrometersToMicroMetersTest() {
    	Decimal value = UnitUtils.getInstance().convert(1, UnitUtils.UNIT_MICROMETER, UnitUtils.UNIT_MICROMETER);
    	System.assert(isAcceptableDelta(value,1,MAX_TOLERANCE));
    }
    
    private static testmethod void feetToFeetTest() {
    	Decimal value = UnitUtils.getInstance().convert(1, UnitUtils.UNIT_FT, UnitUtils.UNIT_FT);
    	System.assert(isAcceptableDelta(value,1,MAX_TOLERANCE));
    }
    
    private static testmethod void inchesToFishTest() {
    	try {
    		Decimal value = UnitUtils.getInstance().convert(1, UnitUtils.UNIT_FT, 'Fish :)');
    		System.assert(false);
    	}
    	catch(UnitUtils.UnitConversionException uce) {
    		System.assert(true);
    	}
    }
    
    private static Boolean isAcceptableDelta(Decimal value, Decimal target, Decimal tolerance) {
    	return Math.abs(value - target) < tolerance;
    }


}