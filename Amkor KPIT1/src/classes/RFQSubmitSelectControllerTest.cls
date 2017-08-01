/*************************************************************************
*
* PURPOSE: Test the methods in RFQSubmitSelectController.cls
*
* CLASS: RFQSubmitSelectController
* CREATED: 19/07/2016 KPIT Tech - www.Kpit.com
* AUTHOR: Bhanu Suthar
***************************************************************************/
@isTest
public class RFQSubmitSelectControllerTest{
    public static testMethod void testSubmitSelect(){
    
        RFQ__c rfq = new RFQ__c();
        rfq = SharedUnitTestUtils.createTestRFQ();
        
        PageReference pageRef = Page.RFQSubmitSelect;
        Test.setCurrentPage(pageRef);   
        pageRef.getParameters().put('rfqId', rfq.Id);
   
        RFQSubmitSelectController rfqSubmitSelectInstance = new RFQSubmitSelectController();
        rfqSubmitSelectInstance.submitItems();
        rfqSubmitSelectInstance.getExportOptions();
    }
    
    public static testMethod void testForSelectOptions(){
        RFQ__c rfq = new RFQ__c();
        rfq = SharedUnitTestUtils.createTestRFQ();
        
        PageReference pageRef = Page.RFQSubmitSelect;
        Test.setCurrentPage(pageRef);   
        pageRef.getParameters().put('rfqId', rfq.Id);
        
        RFQSubmitSelectController rfqSubmitSelectInstance = new RFQSubmitSelectController();
        rfqSubmitSelectInstance.selectionMode = 'Selected';
        rfqSubmitSelectInstance.submitItems();
        rfqSubmitSelectInstance.selectionMode = 'ALL';
        rfqSubmitSelectInstance.submitItems();
        
    }
}