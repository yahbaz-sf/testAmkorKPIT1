/*************************************************************************
*
* PURPOSE: Load FCM Assumption
*
* CLASS: FCMAssumptionDao
* CREATED: 5/13/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
public with sharing class FCMAssumptionDao  extends BaseDao 
{  
    private static final FCMAssumptionDao dao = new FCMAssumptionDao();
 
    private FCMAssumptionDao(){  super('FCM_Assumption__c'); }
    
    public static FCMAssumptionDao getInstance() {
        return dao;
    }
    
    public FCM_Assumption__c getById(String recordId) {
        return (FCM_Assumption__c)getSObjectById(recordId); 
    }

    public List<FCM_Assumption__c> getByPG(String pgId) 
    {
        return (List<FCM_Assumption__c>)getSObjects('Product_Group__c = ' + quote(pgId) , ''); 
    }

    public List<FCM_Assumption__c> getByVersion(String versionId) 
    {
    	return (List<FCM_Assumption__c>)getSObjects('CM_Version__c = ' + quote(versionId) , ''); 
    }
       
    public List<FCM_Assumption__c> getByPF(String pfId) 
    {
    	return (List<FCM_Assumption__c>)getSObjects('Package_Family__c = ' + quote(pfId) , ''); 
    }

    public List<FCM_Assumption__c> getByPFAndVersion(String pfId, String versionId) 
    {
        return (List<FCM_Assumption__c>)getSObjects('Package_Family__c = ' + quote(pfId) + 'AND CM_Version__c = ' + quote(versionId), ''); 
    }

    public List<FCM_Assumption__c> getByFactoryPFAndVersion(String factory, String pfId, String versionId) 
    {
        return (List<FCM_Assumption__c>)getSObjects('Factory__c = ' + quote(factory) + 'AND Package_Family__c = ' + quote(pfId) + 'AND CM_Version__c = ' + quote(versionId), ''); 
    }

    public List<FCM_Assumption__c> getByFactoryAndVersion(String factory, String versionId) 
    {
        return (List<FCM_Assumption__c>)getSObjects('Factory__c = ' + quote(factory) + 'AND CM_Version__c = ' + quote(versionId), ''); 
    }
}