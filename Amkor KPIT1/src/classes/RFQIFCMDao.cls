/*************************************************************************
*
* PURPOSE: 
*
* CLASS: 
* CREATED: 5/01/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
public with sharing class RFQIFCMDao extends BaseDao 
{  
    private static final RFQIFCMDao dao = new RFQIFCMDao();
 
    private RFQIFCMDao(){  super('RFQI_FCM__c'); }
    
    public static RFQIFCMDao getInstance() {
        return dao;
    }
    
    public RFQI_FCM__c getById(String recordId) {
        return (RFQI_FCM__c)getSObjectById(recordId);
    }
    
    public RFQI_FCM__c getLatest(String itemId)
    {
    	List<RFQI_FCM__c> fcmList = (List<RFQI_FCM__c>)getSObjects('RFQ_Item__c = ' + quote(itemId) + 'AND Needs_Reparenting__c = false', 'CreatedDate desc');
    	return fcmList != null && fcmList.size() > 0 ? fcmList[0] : null;
    }

    public Map<String, RFQI_FCM__c> getLatestByIds(Set<String> itemIds)
    {
        List<RFQI_FCM__c> fcmList = (List<RFQI_FCM__c>)getSObjectByIdSet('RFQ_Item__c', itemIds, 'Needs_Reparenting__c = false', 'RFQ_Item__c, CreatedDate desc');
        Map<String, List<RFQI_FCM__c>> fcmsByRFQI = new Map<String, List<RFQI_FCM__c>>();
        for (RFQI_FCM__c fcm : fcmList)
        {
            List<RFQI_FCM__c> tempList = fcmsByRFQI.get(fcm.RFQ_Item__c);
            if (tempList == null)
            {
                fcmsByRFQI.put(fcm.RFQ_Item__c, new List<RFQI_FCM__c>{fcm});
            }
            else
            {
                //keep track of the newest one at position 0
                if (fcm.CreatedDate > tempList[0].CreatedDate)
                {
                    tempList.add(0, fcm);
                }
                else
                {
                    tempList.add(fcm);
                }
            }
        }

        Map<String, RFQI_FCM__c> fcmsToKeep = new Map<String, RFQI_FCM__c>();
        for (List<RFQI_FCM__c> tempList : fcmsByRFQI.values())
        {
            fcmsToKeep.put(tempList[0].RFQ_Item__c, tempList[0]);
        }

        return fcmsToKeep;
    }

    public RFQI_FCM__c getByRfqAndRFQIVolume(String itemId, String volumeKey)
    {
        List<RFQI_FCM__c> fcmList = (List<RFQI_FCM__c>)getSObjects('RFQ_Item__c = ' + quote(itemId) + 'AND Needs_Reparenting__c = true AND RFQI_Volume_Key__c = ' + quote(volumeKey), 'CreatedDate desc');
        return fcmList != null && fcmList.size() > 0 ? fcmList[0] : null;
    }

    public List<RFQI_FCM__c> getByIds(Set<String> fcmIds)
    {
        return (List<RFQI_FCM__c>)getSObjectByIdSet('Id', fcmIds);
    }

    //---This method is called by Triggers on bulk updates of Calcuated data
    //---Performs the function of a roll-up summary, but we have used 10/10 on RFQI_FCM so needed to do it in code
    public void bulkUpdateCalcValues(Set<Id> fcmIdSet)
    {
        Map<Id, RFQI_FCM__c> fcmMap = new Map<Id, RFQI_FCM__c>([Select Id From RFQI_FCM__c Where Id IN :fcmIdSet]);
        for(RFQI_FCM__c fcmRow :fcmMap.values())
        {
            fcmRow.Total_Capital__c = 0;
        }
        
        for( AggregateResult agRow : [Select RFQI_FCM__c, sum(Total_Capital__c) total From RFQI_Process__c Where RFQI_FCM__c IN :fcmIdSet Group by RFQI_FCM__c])
        {
            Id rowId = (Id)agRow.get('RFQI_FCM__c'); 
            Decimal rowTotal = (Decimal)agRow.get('total');
            RFQI_FCM__c boObj = fcmMap.get(rowId);
            if (boObj != null) boObj.Total_Capital__c = rowTotal;
            //---Update Total Capital
        }
        update fcmMap.values();
    }

}