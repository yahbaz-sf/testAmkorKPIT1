/*************************************************************************
*
* PURPOSE: 
*
* CLASS: 
* CREATED: 5/01/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
public with sharing class FCMBOMDao  extends BaseDao 
{  
    private static final FCMBOMDao dao = new FCMBOMDao();
 
    private FCMBOMDao(){  super('FCM_BOM__c'); }
    
    public static FCMBOMDao getInstance() {
        return dao;
    }
    
    public FCM_BOM__c getById(String recordId) {
        return (FCM_BOM__c)getSObjectById(recordId); 
    }
    
    public List<FCM_BOM__c> getAll() 
    {
    	return (List<FCM_BOM__c>)getSObjects('' , 'name'); 
    }
    
    public List<FCM_BOM__c> getByVersion(String versionId) 
    {
    	return (List<FCM_BOM__c>)getSObjects('CM_Version__c = ' + quote(versionId) , 'Sequence__c'); 
    }
   
    public List<FCM_BOM__c> getByParentId(String parentId) 
    {
    	return (List<FCM_BOM__c>)getSObjects('Parent_BOM__c = ' + quote(parentId), 'Sequence__c');
    }
}