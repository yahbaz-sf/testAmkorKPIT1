/*************************************************************************
*
* PURPOSE: Test for RFQIStatusHistoryUpdated trigger and RFQIStatusHistoryDao
*
* CLASS: RFQIStatusHistoryUpdatedTest
* CREATED: 12/16/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Austin Delorme
***************************************************************************/
@isTest
public class RFQIStatusHistoryUpdatedTest 
{
	private static List<String> statuses = new List<String>
	{
		RFQItemDao.STATUS_PRICE_SUBMIT,
		RFQItemDao.STATUS_PRICE_PENDING_BU,
		RFQItemDao.STATUS_PRICE_COMPLETE,
		RFQItemDao.STATUS_PRICE_ESCALATION,
		RFQItemDao.STATUS_QUOTED,
		RFQItemDao.STATUS_PROGRAM_WIN
	};
	private static testMethod void testDates()
	{
		RFQItemWrapper wrapper = SharedUnitTestUtils.createPfAndLineItem();
		String itemId = wrapper.rfqItem.Id;

		RFQI_Status_History__c[] histList = new RFQI_Status_History__c[statuses.size()];

		RFQIStatusHistoryDao.getInstance().newStatusHistory(wrapper.rfqItem);

		for (String status : statuses)
		{
			wrapper.rfqItem.Status__c = status;
			RFQIStatusHistoryDao.getInstance().updateStatusHistory(wrapper);
		}

		Test.startTest();

		List<RFQI_Status_History__c> histories = [SELECT Id, Name, Date__c, Previous_Status__c, Previous_Status__r.Status__c, RFQ_Item__c, Status__c, User_Role__c, Time_From_Created__c, Time_From_Submitted__c, Time_From_BU_Returned__c, Time_From_Quoted__c, Time_From_Program_Status__c, Time_From_Production_Status__c, Time_From_Escalated__c, Time_From_Escalated_BU_Response__c FROM RFQI_Status_History__c WHERE RFQ_Item__r.Id=: itemId];

		Map<String, RFQI_Status_History__c> statusMap = new Map<String, RFQI_Status_History__c>();

		for (RFQI_Status_History__c hist : histories) statusMap.put(hist.Status__c, hist);

		Decimal timeDiff;
		RFQI_Status_History__c currentHistory;
		RFQI_Status_History__c oldHistory;

		for (String oldStatus : statuses)
		{
			oldHistory = statusMap.get(oldStatus);
			for (String status : statuses)
			{
				if (RFQItemDao.getInstance().statusGreaterOrEqual(status, oldStatus))
				{
					currentHistory = statusMap.get(status);
					timeDiff = (currentHistory.Date__c.getTime() - oldHistory.Date__c.getTime())/1000.0/60/60/24;
					System.assert((timeDiff - currentHistory.Time_From_Created__c) < 0.00000000001, 'OldStatus: ' + oldStatus + ', Status: ' + status + ', Expected: ' + timeDiff + ', Recieved: ' + currentHistory.Time_From_Created__c);
				}	
			}
		}

		Test.stopTest();
	}
}