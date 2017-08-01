/*************************************************************************
*
* PURPOSE: 
*
* CLASS: 
* CREATED: 5/01/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
public with sharing class RFQIProcessDao extends BaseDao 
{  
    private static final RFQIProcessDao dao = new RFQIProcessDao();
    //private String additionalFields = ',Process__r.name, Process__r.Equipment_Calc__c';
     
    private RFQIProcessDao(){  
        super('RFQI_Process__c');
        addFields(new Set<String>{'Process__r.name','Process__r.Equipment_Calc__c'}); 

    }
    
    public static RFQIProcessDao getInstance() {
        return dao;
    }
    
    public RFQI_Process__c getById(String recordId) {
        return (RFQI_Process__c)getSObjectById(recordId);
    }
    
    public List<RFQI_Process__c> getByFcmId(String fcmId) {
    	return (List<RFQI_Process__c>)getSObjects('RFQI_FCM__c = ' + quote(fcmId), 'Sequence__c');
    }
}