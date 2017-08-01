/*************************************************************************
* 
* PURPOSE:  Unit Tests for StringUtils
*          
*         
* CLASS: StringUtilsTest
* CREATED: 03/07/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Jason Swenski
* 
**************************************************************************/
@isTest
private class StringUtilsTest {

    /**
    * Tests StringUtils.isBlank
    */
    private static testmethod void testIsBlank() {
    	system.assert(StringUtils.isBlank(' '));
    	system.assert(!StringUtils.isBlank(' a '));
    }
    
    /**
    * Tests StringUtils.isNotBlank
    */
    private static testmethod void testIsNotBlank() {
    	system.assert(!StringUtils.isNotBlank(' '));
    	system.assert(StringUtils.isNotBlank(' a '));
    }
    
    /**
    * Tests StringUtils.isEmpty
    */
    private static testmethod void testIsEmpty() {
    	system.assert(StringUtils.isEmpty(''));
    	system.assert(StringUtils.isEmpty(null));
    	system.assert(!StringUtils.isEmpty(' a '));
    }
    
    /**
    * Tests StringUtils.isNotEmpty
    */
    private static testmethod void testIsNotEmpty() {
    	system.assert(!StringUtils.isNotEmpty(''));
    	system.assert(!StringUtils.isNotEmpty(null));
    	system.assert(StringUtils.isNotEmpty(' a '));
    }
    
    /**
    * Tests StringUtils.isMatch
    */
    private static testmethod void testEquals() {
    	String str1 = null;
    	String str2 = null;
    	
    	system.assert(StringUtils.isMatch(str1, str2));
    	
    	str1 = 'hello';
    	
    	system.assert(!StringUtils.isMatch(str1, str2));
    	
    	str2 = 'hello';
    	
    	system.assert(StringUtils.isMatch(str1, str2));
    }
    
    /**
    * Tests StringUtils.TryParseDouble
    */
    private static testmethod void testParseDouble() {
    	String sVal = '0.6';
    	
    	Double dVal = StringUtils.TryParseDouble(sVal);
    	
    	system.assert(dVal > 0);
    	
    	sVal = 'abcdefg';
    	
    	dVal = StringUtils.TryParseDouble(sVal);
    	
    	system.assert(dVal == 0);
    }


    private static testmethod void testGuidGeneration() {
        // Generate a bunch of GUIDs and make sure that we don't come across any duplicates
        // TODO: This method is randomized, is this test a good idea since theoretically it could 
        //        fail non-deterministically

        Set<String> guidSet = new Set<String>();

        for (Integer i = 0; i < 200; i++) {
            String guid = StringUtils.newGuid();
            System.assert(!guidSet.contains(guid));
            guidSet.add(guid);
        }
    }
    
    

}