/*******************************************************
 
    Purpose: This class is created with reference to SF-204 to avoid the lock issue while updating related items
    Created Date: 10th April 2017
    Created By : KPIT Technologies
    
****************************************************/
public without sharing Class RecordLockUtils{
    
    // This method is being used to unlock related RFQIs
    public static void unlockRelatedRFQIs(List<RFQ_Item__c> rfqisToBeUnlocked){
        Approval.unlock(rfqisToBeUnlocked, false);
    }
    
    // This method is being used to lock related RFQIs
    public static void lockRelatedRFQIs(List<RFQ_Item__c> rfqisToBeLocked){
        Approval.lock(rfqisToBeLocked, false);
    }
}