/*************************************************************************
*
* PURPOSE: Process holder object for selection
*
* CLASS: CMProcessItemSelect
* CREATED: 5/01/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
public with sharing class CMProcessItemSelect 
{
	public FCM_Process__c proc {get; set;}
	public Map<String, FCM_Process__c> variantMap {get; set;}
	public List<SelectOption> variantSelectList {get; set;}
	
	public CMProcessItemSelect()
	{
		variantMap = new Map<String, FCM_Process__c>();
		variantSelectList = new List<SelectOption>();
	}
}