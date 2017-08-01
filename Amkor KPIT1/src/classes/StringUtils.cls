/*************************************************************************
* 
* PURPOSE:  Utility class for string methods
*          
*         
* CLASS: StringUtils
* CREATED: 03/07/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Jason Swenski
* 
**************************************************************************/
global class StringUtils {
	
	/**
    * This method check to see if a String is blank
    *
    * @param str the string to check
    * @returns true if the string is whitespace, null or has length 0
    */
	global static boolean isBlank(String str) {
        return str == null || str.trim() == null || str.trim().length() == 0;
    }
    /**
    * This method check to see if a String is blank
    *
    * @param str the string to check
    * @returns true if the string is whitespace, null or has length 0
    */
    global static boolean isJSONBlank(String str) {
        return str == null || str.trim() == null || str.trim().length() == 0 || str == '[]';
    }

    
    /**
    * This method check to see if a String is not blank
    *
    * @param str the string to check
    * @returns false if the string is whitespace, null or has length 0
    */
    global static boolean isNotBlank(String str) {
        return !isBlank(str);
    }
    
    /**
    * This method check to see if a String is empty
    *
    * @param str the string to check
    * @returns true if the string is null or has length 0
    */
    global static boolean isEmpty(String str) {
        return str == null || str.length() == 0;
    }
    
    global static String sanitize(String str) {
        if(isEmpty(str)) return '';
        return str;
    }

    /**
    * This method check to see if a String is non empty
    *
    * @param str the string to check
    * @returns false if the string is null or has length 0
    */
    global static boolean isNotEmpty(String str) {
        return !isEmpty(str);
    }
    
    /**
    * This method checks to see if two strings are equal (with null safety checking)
    *
    * @param str the string to check
    * @returns true if the strings match
    */
    global static boolean isMatch(String str1, String str2) {
    	if (str1 == null && str2 == null) return true;
    	if ((str1 == null && str2 != null) || (str1 != null && str2 == null)) return false;
    	
    	return str1.equals(str2);
    }
    
    /**
    * This method checks to see if string 1 contains string 2 (with null checking, because apex has no static string method to do this)
    * 
    * @param str1 the string to search in
    * @param str2 the string to search for
    */
    global static boolean contains(String str1, String str2) {
    	if (str1 == null || str2 == null) return false;
    	return str1.contains(str2);
    }
    
    /**
    * This method attempts to convert a string value into a double
    *
    * @param val - The string to convert
    * @returns The double value (0 if not able to parse)
    */
    global static Double TryParseDouble(String val)
	{
		if (String.isBlank(val)) return 0;
		String cleanVal = val.replaceAll('[^\\d.]', '');
		if (String.isBlank(cleanVal)) return 0;
		
		try
		{
			return Double.valueOf(cleanVal);
		}
		catch (Exception e)
		{
			System.debug('Caught error while trying to parse value into double: ' + val);
		}
		
		return 0;
		
	}
	
	/**
    * This method shortens the original string to a specified length,
    * basically a substring method that you can safetly call with any length
    *
    * @param target - The string to chomp
    * @param length - How long should the resultant string be
    * @returns a string with @param length characters
    */
	global static String chomp(String target, Integer length) {
		if(target == null) return target;
		if(target.length() <= length || length > target.length()) return target;
		return target.substring(0,length - 1);
	}
	
	/**
    * This method returns a single charater from a String at a specified index
    *
    * @param str a String
    * @param index  the index of the charater to get
    *
    * @returns a single charater String at the specified index of str
    */
    global static String charAt(String str, Integer index) {
        if(str == null){
            return null;
        }
        if(str.length() <= 0){
            return str;
        }
        if(index < 0 || index >= str.length()){
            return null;
        }
        return str.substring(index, index+1);
    }
    
    /**
    * This method takes a date and returns a string that can be used in a dynamic SOQL where clause
    *
    * @param dateVal A Date Value
    *
    * @returns A SOQL Safe string representation of the date
    */
    global static String getSqlStringForDate(Date dateVal) {
    	DateTime dtVal = DateTime.newInstance(dateVal, Time.newInstance(0, 0, 0, 0));
    	return dtVal.formatGMT('yyyy-MM-dd') + 'T' + dtVal.formatGMT('HH:mm:ss.SSS') + 'Z';
    }


    /**
     * This method generates a GUID (Global unique identifier)
     * Borrowed from http://salesforce.stackexchange.com/questions/4073/how-to-generate-a-guid-uuid
     * 
     * @returns A new GUID
     */
    global static String newGuid() {
        String kHexChars = '0123456789abcdef';

        String returnValue = '';
        Integer nextByte = 0;

        for (Integer i=0; i<16; i++) {

            if (i==4 || i==6 || i==8 || i==10) 
                returnValue += '-';

            nextByte = (Math.round(Math.random() * 255)-128) & 255;

            if (i==6) {
                nextByte = nextByte & 15;
                nextByte = nextByte | (4 << 4);
            }

            if (i==8) {
                nextByte = nextByte & 63;
                nextByte = nextByte | 128;
            }

            returnValue += StringUtils.getCharAtIndex(kHexChars, nextByte >> 4);
            returnValue += StringUtils.getCharAtIndex(kHexChars, nextByte & 15);
        }

        return returnValue;
    }

    global static String getCharAtIndex(String str, Integer index) {

        if (str == null) return null;

        if (str.length() <= 0) return str;    

        if (index == str.length()) return null;    

        return str.substring(index, index+1);
    }

    /**
     * This method checks if a string matches the Salesforce standard ID pattern
     * Borrowed from http://developer.force.com/cookbook/recipe/validating-an-id
     *
     * @returns True if the string is formatted as an ID, else false
     */
    global static Boolean getIsId(String Idparam) {
        String id = String.escapeSingleQuotes(Idparam);
        Boolean isId = false;
        if((id.length() == 15 || id.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', id)) {
            isId = true;
        }
        return isId;
    }
}