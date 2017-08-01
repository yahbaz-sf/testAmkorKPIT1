@isTest
public class RFQMassReassignControllerTest{
    public static testMethod void testRFQMassReassignController(){
    
        PageReference pgRef = Page.RFQMassReassign;
        Test.setCurrentPage(pgRef);
        
         RFQ__c rfq = SharedUnitTestUtils.createTestRFQ();
        Package_Family__c pf = SharedUnitTestUtils.createTestPackageFamily();
        String pfString = pf.Name;
        
        RFQ_Item__c rfqItem = new RFQ_Item__c(RFQ__c = rfq.Id,
                                               Package_Family__c = pf.Id,
                                               OwnerId = SharedUnitTestUtils.createTestUser().Id);                            
        insert rfqItem;
        
        RFQMassReassignController rfqCtrlr = new RFQMassReassignController();
        
       
        rfqCtrlr.dummyRFQI = rfqItem;
        rfqCtrlr.reassign();
        rfqCtrlr.doReassignmentUpdate();
        rfqCtrlr.goHome();
    }
}