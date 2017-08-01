@isTest
private class RecordLockUtilsTest {

    private static testMethod void test() {
        RFQ_Item__c rfqItem1=new RFQ_Item__c();
        RFQ_Item__c rfqItem2=new RFQ_Item__c();
        RFQ_Item__c rfqItem3=new RFQ_Item__c();
        
        List<RFQ_Item__c> rfqs=new List<RFQ_Item__c>();
        insert rfqs;
        
        Test.startTest();
        RecordLockUtils.lockRelatedRFQIs(rfqs);
        
        for(Integer i=0;i<rfqs.size();i++){
            System.assertEquals(true, Approval.isLocked(rfqs[i].id));
        }
        
        RecordLockUtils.unlockRelatedRFQIs(rfqs);
        
        for(Integer i=0;i<rfqs.size();i++){
            System.assertEquals(false, Approval.isLocked(rfqs[i].id));
        }
        Test.stopTest();
    }
}