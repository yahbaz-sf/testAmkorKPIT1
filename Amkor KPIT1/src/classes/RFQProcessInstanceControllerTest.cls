/*************************************************************************
*
* PURPOSE: 
*
* CLASS: RFQProcessInstanceControllerTest
* CREATED: 8/08/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Chia Yuan Chuang
***************************************************************************/
@isTest
public class RFQProcessInstanceControllerTest {


    private static testmethod void testConstructor1() {
        
        // RFQProcessInstanceController rfqProcCont = setupController(false);
        // ApexPages.Message[] messageList = ApexPages.getMessages();
        //System.assert(messageList[0].getDetail() == 'Cannot approve item without all required Cost Model Inputs');  
    }

    private static testmethod void testConstructor2() {
        

        //RFQProcessInstanceController rfqProcCont = setupController(true);
        //ApexPages.Message[] messageList = ApexPages.getMessages();

        //System.assert(messageList.size() == 0);
        
    }

    private static testmethod void testApproveItem() {
        

        RFQProcessInstanceController rfqProcCont = setupController(true);
        rfqProcCont.wrapper.specificRfqItem.put('BU_Price__c', 100.0);

        // Populate price to customer to ensure BU Price will overwrite it after the approval
        rfqProcCont.wrapper.specificRfqItem.put('Price_To_Customer__c', 112.0);
        rfqProcCont.wrapper.rfqItem.Price_To_Customer__c = 112.0;


        PageReference approvePage = rfqProcCont.approveItem();

        //check if wrapper saved
        RFQItemWrapper itemWrapper = RFQItemDao.getInstance().getWrapperById(rfqProcCont.wrapper.rfqItem.Id);
        System.assert(itemWrapper.specificRfqItem.get('BU_Price__c') == 100.0);
        System.assert(itemWrapper.specificRfqItem.get('Price_To_Customer__c') == 100.0);
        
    }
    
    
    
    private static testmethod void testRejectItem() {
        

        RFQProcessInstanceController rfqProcCont = setupController(true);
        Test.startTest();
        rfqProcCont.wrapper.rfqItem.Status__c = RFQItemDao.STATUS_PRICE_PENDING_BU;
        PageReference rejectPage = rfqProcCont.rejectItem();

        RFQItemWrapper itemWrapper = RFQItemDao.getInstance().getWrapperById(rfqProcCont.wrapper.rfqItem.Id);
        Test.stopTest();
        System.assert(itemWrapper.rfqItem.Status__c == RFQItemDao.STATUS_PRICE_DECLINED);
        //System.assert(messageList.size() == 0);
        
    }

    private static testmethod void testNoBid() {

        RFQProcessInstanceController rfqProcCont = setupController(true);

        Test.startTest();
        rfqProcCont.wrapper.rfqItem.Status__c = RFQItemDao.STATUS_PRICE_ESCALATION;
        System.assert(!rfqProcCont.getIsNoBidPossible()); //No bid shouldn't be possible on escalations
        rfqProcCont.wrapper.rfqItem.Status__c = RFQItemDao.STATUS_PRICE_PENDING_BU;
        rfqProcCont.noBid();
        Test.stopTest();

        RFQItemWrapper itemWrapper = RFQItemDao.getInstance().getWrapperById(rfqProcCont.wrapper.rfqItem.Id);
        
        System.assert(itemWrapper.rfqItem.Status__c == RFQItemDao.STATUS_NO_BID);
        //System.assert(messageList.size() == 0);
    }

    //bhanu 20-07-2016 Increasing code coverage starts
    public static testmethod void testIndividualMethods(){
        RFQAdminInstaller.install();
        RFQAdminInstaller.installFactories();
        PBGAInstaller.installTest();
        //CMPBGAInstaller.install();
        

        RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('PBGA');
        ApprovalUtils.startApproval(wrapper.rfqItem.Id, 'test 123');

        
        wrapper.rfqItem.Manual_Entry_Verified__c = false;
        update wrapper.rfqItem;

        ApexPages.currentPage().getParameters().put('id',wrapper.rfqItem.Id);
        RFQProcessInstanceController rfqProcContInvidual = new RFQProcessInstanceController();
        rfqProcContInvidual.cancelApproval();
        //rfqProcContInvidual.getIsPerTime();
        //rfqProcContInvidual.copyParentPricesToVolumes();
    }
    
    /*
    public static testmethod void testBUUser(){
        RFQAdminInstaller.install();
        RFQAdminInstaller.installFactories();
        //bhanu 20-07-2016 Increasing code coverage starts
        RFQAdminInstaller.installRFQSystemSettings();
        //bhanu 20-07-2016 Increasing code coverage starts
        PBGAInstaller.installTest();
        //CMPBGAInstaller.install();
        RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('PBGA');
        wrapper.rfqItem.Status__c = RFQItemdao.STATUS_PRICE_PENDING_BU;
        update wrapper.rfqitem;
        //User BUUser = SharedUnitTestUtils.createTestUser(false, true);
        //Duplicate value found: SetupOwnerId duplicates value on record with id
        User BUUser = SharedUnitTestUtils.createTestUser(false, false);
        ApexPages.currentPage().getParameters().put('id',wrapper.rfqItem.Id);        
        System.RunAs(BUUser){
            RFQProcessInstanceController rfqProcCont = new RFQProcessInstanceController();
        }
    }
    */
    //bhanu 20-07-2016 Increasing code coverage ends

    //Create a controller 
    public static RFQProcessInstanceController setupController(Boolean manualEntry) {


        RFQAdminInstaller.install();
        RFQAdminInstaller.installFactories();
        //bhanu 20-07-2016 Increasing code coverage starts
        RFQAdminInstaller.installRFQSystemSettings();
        //bhanu 20-07-2016 Increasing code coverage starts
        PBGAInstaller.installTest();
        //CMPBGAInstaller.install();
        

        RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('PBGA');
        ApprovalUtils.startApproval(wrapper.rfqItem.Id, 'test 123');

        
        wrapper.rfqItem.Manual_Entry_Verified__c = manualEntry;
        //Bhanu 19 July increasing code coverage starts
        wrapper.volumeList.add(new RFQIVolume(false));
        wrapper.rfqItem.Multi_Volume__c = JSON.serialize(wrapper.volumeList);
        //Bhanu 19 July increasing code coverage  ends
        update wrapper.rfqItem;

        ApexPages.currentPage().getParameters().put('id',wrapper.rfqItem.Id);        
        RFQProcessInstanceController rfqProcCont = new RFQProcessInstanceController();
        rfqProcCont.approvalComments = 'a';
        return rfqProcCont;
    }


}