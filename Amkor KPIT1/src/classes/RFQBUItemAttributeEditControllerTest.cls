/*************************************************************************
*
* PURPOSE: Unit Tests for the RFQ BU Item Attribute Editpage
*
* CLASS: RFQBUItemAttributeEditControllerTest
* CREATED: 3/22/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/
@isTest
private class RFQBUItemAttributeEditControllerTest {
    
    private static testmethod void testConstructor() {
        
        RFQBUItemAttributeEditController rfqItemCont = setupController();
        System.assert(rfqItemCont.layout != null);
        System.assert(rfqItemCont.layout.sectionMap != null);
        System.assert(rfqItemCont.wrapper.specificRfqItem != null);
        System.assert(rfqItemCont.wrapper.wireConfigurations.size() > 0);
    }
    
    public static RFQBUItemAttributeEditController setupController() {
        
        //make sure the sections and a layout exist
        RFQAdminInstaller.install();
        PBGAInstaller.installTest();
             
        RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('PBGA');
        
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(wrapper.rfqItem);
        ApexPages.currentPage().getParameters().put('edit','1');
        RFQBUItemAttributeEditController rfqItemCont = new RFQBUItemAttributeEditController(sc);
        rfqItemCont.reloadClone();
        
        return rfqItemCont;
    }
    
    private static testmethod void testMethods() {
        RFQBUItemAttributeEditController rfqItemCont = setupController();
        rfqItemCont.wrapper.packageFamily.Sales_Requires_Pre_Approval__c = true;
        Integer initialSize = rfqItemCont.wrapper.dieConfigurations.size();

        Test.startTest();

        PageReference pg = rfqItemCont.gotoStandardApprovalWizard();
        System.assert(pg != null);
        pg = rfqItemCont.reloadClone();
        System.assert(pg == null);

        Test.stopTest();
    }

    private static testMethod void testAddDie() {

        RFQBUItemAttributeEditController rfqItemCont = setupController();
        rfqItemCont.wrapper.packageFamily.Sales_Requires_Pre_Approval__c = true;
        Integer initialSize = rfqItemCont.wrapper.dieConfigurations.size();

        Test.startTest();
        //adding die config #1
        rfqItemCont.addDieConfiguration();
        System.assert(rfqItemCont.cloneItem.dieConfigurations.size() == initialSize + 1);
        //adding die config #2
        rfqItemCont.addDieConfiguration();
        System.assert(rfqItemCont.cloneItem.dieConfigurations.size() == initialSize + 2);
        //removing die config 
        ApexPages.currentPage().getParameters().put('dieConfigId',rfqItemCont.cloneItem.dieConfigurations[0].Id);
        rfqItemCont.removeDieConfigurationById();
        System.assertEquals(initialSize + 1, rfqItemCont.cloneItem.dieConfigurations.size(), 'should be the same');
        Test.stopTest();
    }


    private static testMethod void testAddWire() {


        RFQBUItemAttributeEditController rfqItemCont = setupController();
        rfqItemCont.wrapper.packageFamily.Sales_Requires_Pre_Approval__c = true;
        Integer initialSize = rfqItemCont.cloneItem.wireConfigurations.size();

        Test.startTest();
        //adding wire config #1
        rfqItemCont.addWireConfiguration();
        System.assert(rfqItemCont.cloneItem.wireConfigurations.size() == initialSize + 1);
        //adding wire config #2
        rfqItemCont.addWireConfiguration();
        System.assert(rfqItemCont.cloneItem.wireConfigurations.size() == initialSize + 2);
        //removing wire config
        ApexPages.currentPage().getParameters().put('wireConfigId',rfqItemCont.cloneItem.wireConfigurations[0].Id);
        rfqItemCont.removeWireConfigurationById();
        System.assertEquals(initialSize + 1, rfqItemCont.cloneItem.wireConfigurations.size(), 'should be the same');
        Test.stopTest();
    }

    private static testMethod void saveItemAsBUDraft() {
        RFQBUItemAttributeEditController rfqItemCont = setupController();
        
        Test.startTest();
        //AMK-1537, should be in BU Draft out of the box now
        System.assert(rfqItemCont.cloneItem.rfqItem.Status__c == RFQItemDao.STATUS_BU_DRAFT);

        rfqItemCont.saveAsDraft();

        System.assert(rfqItemCont.cloneItem.rfqItem.Status__c == RFQItemDao.STATUS_BU_DRAFT);
        //since we saved as a BU Draft, we should be able to edit this one again
        //without creating a clone.

        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(rfqItemCont.cloneItem.rfqItem);
        ApexPages.currentPage().getParameters().put('edit','1');
        RFQBUItemAttributeEditController rfqItemCont2 = new RFQBUItemAttributeEditController(sc);
        rfqItemCont2.reloadClone();        

        //should not have created an additional item when we reloaded. So we should only
        //have the original item, the clone even though we called reloadClone with the 
        //clone loaded..
        System.assert([select Id from RFQ_Item__c].size() == 2);
        Test.stopTest();

    }

    private static testMethod void testSaveAsNew() {
        RFQBUItemAttributeEditController rfqItemCont = setupController();
        RFQAdminInstaller.installFactories();
        Factory__c fact = [Select id, Name from Factory__c where Name = 'k4' LIMIT 1];
        rfqItemCont.wrapper.packageFamily.Sales_Requires_Pre_Approval__c = true;
        rfqItemCont.cloneItem.setAttribute('Factory__c', RFQItemWrapper.PACKAGE_OBJECT, fact.Id);
        rfqItemCont.cloneItem.setAttribute('Body_Size__c', RFQItemWrapper.PACKAGE_OBJECT, '17');
        rfqItemCont.cloneItem.setAttribute('Substrate_Unit__c', RFQItemWrapper.PACKAGE_OBJECT, 5);
        //rfqItemCont.cloneItem.setAttribute('Quote_Request_Type__c', RFQItemWrapper.PACKAGE_OBJECT, 'Preliminary BOM/Routing');
        //rfqItemCont.cloneItem.setAttribute('Decision_To_Buy__c', RFQItemWrapper.PACKAGE_OBJECT, Date.today());
        rfqItemCont.cloneItem.wireConfigurations[0].put('Number_Of_Wires__c', 4);
        Test.startTest();
        PageReference pg = rfqItemCont.saveAsNewRfqItem();
        System.assert(pg != null);
        Test.stopTest();
    }

    private static testMethod void testCancel() {
        
        RFQBUItemAttributeEditController rfqItemCont = setupController();
        rfqItemCont.wrapper.packageFamily.Sales_Requires_Pre_Approval__c = true;
        Test.startTest();
        PageReference pg = rfqItemCont.cancelEditAttributes();
        System.assert(pg != null);
        Test.stopTest();
    }
}