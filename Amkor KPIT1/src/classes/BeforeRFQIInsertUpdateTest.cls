@isTest
private class BeforeRFQIInsertUpdateTest {
  
    public static RFQ__c rfq;
    public static Opportunity opp;
    public static List<RFQ_Item__c> rfqItemList;
    
    public static void setup(){

        //dummy opp creation
        opp = SharedUnitTestUtils.createTestOpportunity();
        
        //dummy rfq creation
        rfq = new RFQ__c(RFQ_Name__c ='Unit Test RFQ Name', Projected_Revenue__c = 1234);
        rfq.opportunity__c = opp.id;
        rfq.SBU_Name__c = SharedUnitTestUtils.createTestSBU().Id;
        insert rfq;
        
        //dummy rfqItemCreation
        RFQ_Item__c rfqi = new RFQ_Item__c(RFQ__c=rfq.id);
        rfqItemList = new List<RFQ_Item__c>{rfqi};
        
    }
   
     private static testMethod void testMethod1() {
        //setting up test data
        setup();
        
        Test.startTest();
        
            insert rfqItemList;
            update rfqItemList;
        
        Test.stopTest();
    }
   

  
}