/*************************************************************************
*
* PURPOSE: 
*
* CLASS: 
* CREATED: 5/01/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
public with sharing class RFQIBOMDao extends BaseDao 
{  
    private static final RFQIBOMDao dao = new RFQIBOMDao(); 
    //private String additionalFields = ',BOM__r.name,BOM__r.Description__c,BOM__r.Parent_BOM__r.name';
     
    private RFQIBOMDao(){  
        super('RFQI_BOM__c');
        addFields(new Set<String>{'BOM__r.name','BOM__r.Description__c','BOM__r.Parent_BOM__r.name'}); 

    }
    
    public static RFQIBOMDao getInstance() {
        return dao;
    }
    
    public RFQI_BOM__c getById(String recordId) {
        return (RFQI_BOM__c)getSObjectById(recordId);
    }
    
    public List<RFQI_BOM__c> getByFcmId(String fcmId) 
    {
    	return (List<RFQI_BOM__c>)getSObjects('RFQI_FCM__c = ' + quote(fcmId), 'Sequence__c'); 
    }
}