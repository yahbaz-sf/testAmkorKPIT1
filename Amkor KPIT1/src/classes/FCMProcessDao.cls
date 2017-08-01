/*************************************************************************
*
* PURPOSE: 
*
* CLASS: 
* CREATED: 5/01/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
public with sharing class FCMProcessDao  extends BaseDao 
{  
    private static final FCMProcessDao dao = new FCMProcessDao();
 
    private FCMProcessDao(){  super('FCM_Process__c'); }
    
    public static FCMProcessDao getInstance() {
        return dao;
    }
    
    public FCM_Process__c getById(String recordId) {
        return (FCM_Process__c)getSObjectById(recordId); 
    }
    
    public List<FCM_Process__c> getByVersion(String versionId) 
    {
    	return (List<FCM_Process__c>)getSObjects('CM_Version__c = ' + quote(versionId) , 'Sequence__c'); 
    }
    
    public List<FCM_Process__c> getAll() 
    {
    	return (List<FCM_Process__c>)getSObjects('' , 'Sequence__c'); 
    }
    
    public List<FCM_Process__c> getByParentId(String parentId) 
    {
    	return (List<FCM_Process__c>)getSObjects('Parent_Process__c = ' + quote(parentId), 'Sequence__c');
    }
}