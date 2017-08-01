/*************************************************************************
*
* PURPOSE: 
*
* CLASS: 
* CREATED: 5/13/2013 Ethos Solutions - www.ethos.com  
* AUTHOR: Steve Simpson
***************************************************************************/
public with sharing class CMDualBridge extends CMFCMBridgeBase 
{
	public override List<CM_Margin__c> getMarginList()
	{
		String leadCount = (String)wrapper.specificRfqItem.get('Lead_Count__c');
		Double tier = getAccountTier();
		
		//---Read Wire Material.  Take first value found, unless Gold is anywhere, then use it 
		String wireMaterial = null;
		for(SObject row : wrapper.wireConfigurations)
		{
			String fieldVal = (String)row.get('Wire_Material__c');
			
			if (fieldVal != null)
			{
				if (wireMaterial == null || fieldVal == 'Au') wireMaterial = fieldVal;
			}
		}
		
		return CMMarginDao.getInstance().getByDualCriteria(mVer.id, wrapper.packageFamily.id, leadCount, tier, wireMaterial);
	}
}