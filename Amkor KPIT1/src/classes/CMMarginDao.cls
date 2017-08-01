/*************************************************************************
*
* PURPOSE: Load the CM Margin Objects
*
* CLASS: 
* CREATED: 5/13/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/  
public with sharing class CMMarginDao  extends BaseDao 
{  
    private static final CMMarginDao dao = new CMMarginDao();
 
    private CMMarginDao(){  super('CM_Margin__c'); }
    
    public static CMMarginDao getInstance() {
        return dao;
    }
    
    public CM_Margin__c getById(String recordId) {
        return (CM_Margin__c)getSObjectById(recordId); 
    }
    
    public List<CM_Margin__c> getByVersion(String versionId) 
    {
    	return (List<CM_Margin__c>)getSObjects('CM_Margin_Version__c = ' + quote(versionId) , ''); 
    }
      
    public List<CM_Margin__c> getByDualCriteria(String versionId, String pfId, String leadCount, Double tier, String wireMaterial) 
    {
    	return (List<CM_Margin__c>)getSObjects('CM_Margin_Version__c = ' + quote(versionId) + ' AND Package_Family__c = ' + quote(pfId) + ' AND Lead_Count__c = ' + quote(leadCount) + ' AND Tier__c = ' +tier + ' AND Wire_Material__c = ' +quote(wireMaterial), 'Volume_Floor__c'); 
    }

    public List<CM_Margin__c> getByQuadCriteria(String versionId)
    {
        return (List<CM_Margin__c>)getSObjects('CM_Margin_Version__c = ' + quote(versionId));
    }
}