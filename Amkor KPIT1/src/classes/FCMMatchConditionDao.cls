/*************************************************************************
*
* PURPOSE: 
*
* CLASS: 
* CREATED: 5/01/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
public with sharing class FCMMatchConditionDao  extends BaseDao 
{  
    private static final FCMMatchConditionDao dao = new FCMMatchConditionDao();
    //private String additionalFields = ',RFQI_Field_Def__r.name,FCM_Process__r.Name,FCM_BOM__r.Name';
 
    private FCMMatchConditionDao(){  
        super('FCM_Match_Condition__c'); 
        addFields(new Set<String>{'RFQI_Field_Def__r.name','FCM_Process__r.Name','FCM_BOM__r.Name'});

    }
    
    public static FCMMatchConditionDao getInstance() {
        return dao;
    }
    
    public FCM_Match_Condition__c getById(String recordId) {
        return (FCM_Match_Condition__c)getSObjectById(recordId); 
    }
    
    public List<FCM_Match_Condition__c> getAllByBom(String bomId) 
    {
        return (List<FCM_Match_Condition__c>)getSObjects('FCM_BOM__c = ' + quote(bomId));
    }
    
    public List<FCM_Match_Condition__c> getAllByProcess(String processId) 
    {
    	return (List<FCM_Match_Condition__c>)getSObjects('FCM_Process__c = ' + quote(processId));
    }
    
    public List<FCM_Match_Condition__c> getAllByBomVersion(String versionId) 
    {
    	return (List<FCM_Match_Condition__c>)getSObjects('FCM_BOM__r.CM_Version__c = ' + quote(versionId));
    }
    
    public List<FCM_Match_Condition__c> getAllByProcessVersion(String versionId) 
    {
    	return (List<FCM_Match_Condition__c>)getSObjects('FCM_Process__r.CM_Version__c = ' + quote(versionId));
    }
}