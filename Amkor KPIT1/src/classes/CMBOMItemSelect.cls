/*************************************************************************
*
* PURPOSE: Holder object for selected BOM items
*
* CLASS: CMBOMItemSelect
* CREATED: 5/01/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
public with sharing class CMBOMItemSelect 
{
	public FCM_BOM__c bom {get; set;}
	public Map<String, FCM_BOM__c> variantMap {get; set;}
	public List<SelectOption> variantSelectList {get; set;}
	
	public CMBOMItemSelect()
	{
		variantMap = new Map<String, FCM_BOM__c>();
		variantSelectList = new List<SelectOption>();
	}
}