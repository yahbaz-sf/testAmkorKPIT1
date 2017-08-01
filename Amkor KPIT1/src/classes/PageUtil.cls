/*************************************************************************
* 
* PURPOSE:  Various util methods related to page parameters and page references
*          
*         
* CLASS: PageUtil
* CREATED: 8/06/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Nathan Pilkington
* 
**************************************************************************/

public class PageUtil {
	public static void putParam(String pName, String pValue) {
		ApexPages.currentPage().getParameters().put(pName, pValue);
	}

	public static String getParam(String pName) {
		return ApexPages.currentPage().getParameters().get(pName);
	}

	public static String param(String pName){
		return getParam(pName);
	}

	public static void param(String pName, String pValue) {
		putParam(pName,pValue);
	}
}