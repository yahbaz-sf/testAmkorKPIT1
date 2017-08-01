/*************************************************************************
*
* PURPOSE: 
*
* CLASS: 
* CREATED: 5/01/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
public with sharing class FCMLayeredField 
{
	public FCMLayeredField(String fieldName, String plabel)
	{
		label = pLabel;
		
		localName = fieldName + '__c';
		orName = fieldName + '_OR__c';
		calcName = fieldName + '_Calc__c';
		
		isSelected = false;
	}
	
	public String label {get; set;}
	public String localName {get; set;}
	public String orName {get; set;}
	public String calcName {get; set;}
	
	public Boolean isSelected {get; set;}	
}