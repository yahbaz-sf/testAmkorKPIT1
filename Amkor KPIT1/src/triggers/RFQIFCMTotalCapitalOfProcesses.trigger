trigger RFQIFCMTotalCapitalOfProcesses on RFQI_Process__c (after insert, after update) {

    Set<Id> fcmIdSet = new Set<Id>();

    for (RFQI_Process__c row : System.Trigger.new) 
    {
        if (!fcmIdSet.contains(row.RFQI_FCM__c)) fcmIdSet.add(row.RFQI_FCM__c);
    }
    RFQIFCMDao.getInstance().bulkUpdateCalcValues(fcmIdSet);
}