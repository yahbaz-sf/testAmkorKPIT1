/*************************************************************************
* 
* PURPOSE:  Wrapper class for RFQI_Status_History__c in order to implement custom sorting
* CLASS: RFQILayoutAttribute
* CREATED: 03/12/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Jason Swenski
* 
**************************************************************************/
public class RFQIStatusHistoryWrapper implements Comparable {

	public RFQI_Status_History__c history {get; set;}

	public RFQIStatusHistoryWrapper(RFQI_Status_History__c hist) {
		this.history = hist;
	}

	public Integer compareTo(Object compareTo) {
		RFQIStatusHistoryWrapper statusCompareTo = (RFQIStatusHistoryWrapper) compareTo;
		//for when dates are equal - happens when automatic routing, e.g. price submit -> price pending bu approval
		if (history.Date__c == statusCompareTo.history.Date__c) return (RFQItemDao.getInstance().statusGreaterOrEqual(history.Status__c, statusCompareTo.history.Status__c)) ? 1 : -1;
		else return (history.Date__c < statusCompareTo.history.Date__c) ? -1 : 1;

	}
}