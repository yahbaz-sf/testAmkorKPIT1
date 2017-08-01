/*************************************************************************
*
* PURPOSE: Tests Controller for the RFQ Item view page
*
* CLASS: RFQItemViewControllerTest
* CREATED: 3/21/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/

@isTest
private class RFQItemViewControllerTest {
    
    private static testmethod void testConstructor() {
        
        RFQItemViewController rfqItemCont = setupController();
        System.assert(rfqItemCont.layout != null);
        System.assert(rfqItemCont.layout.sectionMap != null);
        System.assert(rfqItemCont.wrapper.specificRfqItem != null);
        System.assert(rfqItemCont.wrapper.wireConfigurations.size() > 0);
        
        
    }

    public static testmethod void testRecall() {
        RFQItemViewController rfqItemCont = setupController();

        rfqItemCont.wrapper.rfqItem.Status__c = RFQItemDao.STATUS_PRICE_PENDING_BU;
        RFQItemDao.getInstance().saveLineItem(rfqItemCont.wrapper);
        
        Test.startTest();
        ApprovalUtils.startApproval(rfqItemCont.wrapper.rfqItem.Id,'test');
        
        //Now you see it
        Id processInstanceId = ApprovalUtils.getProcessInstanceWorkItem(rfqItemCont.wrapper.rfqItem.Id);
        System.assert(processInstanceId != null);

        rfqItemCont.recallApproval();

        //Now you don't 
        processInstanceId = ApprovalUtils.getProcessInstanceWorkItem(rfqItemCont.wrapper.rfqItem.Id);
        System.assert(processInstanceId == null);
        
        RFQItemWrapper wrapper = RFQItemDao.getInstance().getWrapperById(rfqItemCont.wrapper.rfqItem.Id);
        System.assert(wrapper.rfqItem.Status__c == RFQItemDao.STATUS_NEW);
        Test.stopTest();

    }
    
    public static testmethod void testPF() {
         
        RFQItemViewController rfqItemCont = setupController();
        
        PageReference pg = rfqItemCont.editMode();
        System.assert(pg != null);
        System.assert(pg.getUrl().contains('RFQItemEdit'));
        
        pg = rfqItemCont.cloneItem();
        System.assert(pg != null);
        System.assert(pg.getUrl().contains('RFQItemClone'));
        
        pg = rfqItemCont.requestEscalation();
        System.assert(pg != null);
        System.assert(pg.getUrl().contains('RFQItemEscalation'));

        rfqItemCont.wrapper.setAttribute('BU_Price__c', 'Package', 1);
        rfqItemCont.wrapper.setAttribute('Price_To_Customer__c', 'Package', 2);

        pg = rfqItemCont.requestEscalation();
        System.assert(pg==null);

        pg = rfqItemCont.viewRelatedItems();
        System.assert(pg != null);
        System.assert(pg.getUrl().contains('simple'));

        pg = rfqItemCont.viewRelatedItemsAdvanced();
        System.assert(pg != null);
        System.assert(pg.getUrl().contains('advanced'));

        boolean bool = rfqItemCont.getRelatedItemsVisible();
        System.assert(!bool);

    }
    
    public static testmethod void testStatus() {
        Test.startTest();
        RFQItemViewController rfqItemCont = setupController();
        //rfqItemCont.clickedButton;
        //Abhay-A:SF-195:26-May-17:Win / Loss / Cancel Reason Enhancement
        rfqItemCont.wrapper.rfqItem.StatusReason__c='Other';
        rfqItemCont.wrapper.rfqItem.Status_Comments__c='ok';
        
        rfqItemCont.clickedButton='qualified';
        rfqItemCont.submit();
        Test.stopTest();

        System.assert(rfqItemCont.wrapper.rfqItem.Status__c == RFQItemDao.STATUS_Qual);

        rfqItemCont.clickedButton='won';
        rfqItemCont.submit();
        System.assert(rfqItemCont.wrapper.rfqItem.Status__c == RFQItemDao.STATUS_PROGRAM_WIN);

        rfqItemCont.clickedButton='lost';
        rfqItemCont.submit();
        System.assert(rfqItemCont.wrapper.rfqItem.Status__c == RFQItemDao.STATUS_PROGRAM_LOSS);

        rfqItemCont.clickedButton='canceled';
        rfqItemCont.submit();
        System.assert(rfqItemCont.wrapper.rfqItem.Status__c == RFQItemDao.STATUS_PROGRAM_CANCELED);
        
        rfqItemCont.status='Qual';
        rfqItemCont.showPopup();
        System.assert(rfqItemCont.displayPopup==true);

        rfqItemCont.closePopup();
        System.assert(rfqItemCont.displayPopup==false);

        
    /*  rfqItemCont.setAsProgramCancelled();
        Test.stopTest();
        System.assert(rfqItemCont.wrapper.rfqItem.Status__c == RFQItemDao.STATUS_PROGRAM_CANCELED);
        
        rfqItemCont.setAsProgramLoss();
        System.assert(rfqItemCont.wrapper.rfqItem.Status__c == RFQItemDao.STATUS_PROGRAM_LOSS);
        
        rfqItemCont.setAsProgramWin();
        System.assert(rfqItemCont.wrapper.rfqItem.Status__c == RFQItemDao.STATUS_PROGRAM_WIN);
*/

    }
    
    public static RFQItemViewController setupController() {
        
        //make sure the sections and a layout exist
        RFQAdminInstaller.install();
        PBGAInstaller.installTest();
        //RFQ__c rfq = SharedUnitTestUtils.createTestRFQ();
        //ApexPages.currentPage().getParameters().put('rfqId',rfq.Id);
        
        RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('PBGA');
        CPN cpn = CPNDao.getInstance().getCPN(wrapper);
        wrapper.rfqItem.Configured_Part_Number__c = cpn.cpnId;            
        RFQItemDao.getInstance().saveLineItem(wrapper);

        RFQ_Item__c rfqItem = wrapper.rfqItem;

        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(rfqItem);
        ApexPages.currentPage().getParameters().put('edit','1');
        RFQItemViewController rfqItemCont = new RFQItemViewController(sc);


        //system.assertequals(CPN.id,rfqItemCont.wrapper.rfqitem.Configured_Part_Number__c, 'should be the same'); 

        return rfqItemCont;
    }
    

}