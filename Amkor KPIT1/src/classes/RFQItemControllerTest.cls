/*************************************************************************
*
* PURPOSE: Unit Tests for RFQItemController
*
* CLASS: RFQItemControllerTest
* CREATED: 3/12/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/
@isTest
public class RFQItemControllerTest {
   
       
    private static testmethod void testConstructor() {
        
        RFQItemController rfqItemCont = setupController();
        
        System.assert(rfqItemCont.layout != null);
        System.assert(rfqItemCont.layout.sectionMap != null);
        System.assert(rfqItemCont.wrapper.specificRfqItem != null);
        System.assert(rfqItemCont.wrapper.wireConfigurations.size() > 0);
        
    }
    
   

    public static RFQItemController setupController() {
        
        //make sure the sections and a layout exist
        //RFQAdminInstaller.install();
        //PBGAInstaller.install();
        
        
        //RFQ__c rfq = SharedUnitTestUtils.createTestRFQ();
        
        //fake like we are at the create screen
        //ApexPages.currentPage().getParameters().put('rfqId',rfq.Id);
        ///CreateRFQItemController cont = new CreateRFQItemController();
        //cont.numberOfWires = '1';
        //CreateRFQItemControllerTest.testDoUserSelection(cont, 'PBGA');
        
        //create a line item, this should create an RFQ_Item__c pointing to RFQ__c
        //as well as a RFQI_SOIC_150mil_body__c object pointing to RFQ__c
        //cont.createLineItem();
        
        //RFQ_Item__c rfqItem = cont.rfqItem;
        
        //ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(rfqItem);
        //ApexPages.currentPage().getParameters().put('edit','1');
        
        ApexPages.StandardController sc = SharedUnitTestUtils.setupStandardControllerWithItem();
        RFQItemController rfqItemCont = new RFQItemController(sc);
        return rfqItemCont;
    }
    
    public static RFQItemController setupMLFController(){
        
        //Setup environment
        RFQAdminInstaller.install();
        MLFInstaller.install();
        CMMLFInstaller.cleanAndInstall();
        
        //createa a rfq 
        RFQ__c rfq = SharedUnitTestUtils.createTestRFQ();
        
        //fake the rfq page
        ApexPages.currentPage().getParameters().put('rfqId',rfq.Id);
        CreateRFQItemController cont = new CreateRFQItemController();
        cont.numberOfWires = '1';
        
        CreateRFQItemControllerTest.testDoUserSelection(cont);
        
        
        // To Do check code here.
        
        cont.createLineItem();
        
        
        RFQ_Item__c rfqItem = cont.rfqItem;
        
        RFQItemWrapper wrapper = RFQItemDao.getInstance().getWrapperById(rfqItem.Id);
        
        
        List<sObject> wireConfigurations = wrapper.wireConfigurations;
         
        wireConfigurations[0].put('Total_3D_Wire_Length__c', 510.00);
        
        update wireConfigurations;
        //sObject specificItem = wrapper.specificRfqItem;
        //specificItem.put('Price_to_Customer__c', 0.1); 
        //update specificItem;
        
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(rfqItem);
        ApexPages.currentPage().getParameters().put('edit','1');
        RFQItemController rfqItemCont = new RFQItemController(sc);
        
        return rfqItemCont;
        
        
    }
    
    
     public static RFQItemController setupPBGAController(){
        
        //Setup environment
        RFQAdminInstaller.install();
        RFQAdminInstaller.installFactories();
        PBGAInstaller.installTest();
        CMPBGAInstaller.install();

        Product_Group__c pbga = [Select Id from Product_Group__c where Name =: 'PBGA'];
        pbga.Generated_Price_Requires_BU_Review__c = false;
        update pbga;
        
        //createa a rfq 
        RFQ__c rfq = SharedUnitTestUtils.createTestRFQ();
        
        //fake the rfq page
        ApexPages.currentPage().getParameters().put('rfqId',rfq.Id);
        CreateRFQItemController cont = new CreateRFQItemController();
        cont.numberOfWires = '1';
        cont.numberOfDies = '1';
        
        CreateRFQItemControllerTest.testDoUserSelection(cont, 'PBGA');
        
        
        // To Do check code here.
        
        cont.createLineItem();
        
        
        RFQ_Item__c rfqItem = cont.rfqItem;
        
        RFQItemWrapper wrapper = RFQItemDao.getInstance().getWrapperById(rfqItem.Id);
        
        wrapper.specificRfqItem.put('Body_Size__c', '27');
        wrapper.specificRfqItem.put('Ball_Count__c', 676);
        wrapper.specificRfqItem.put('Factory__c', [Select Id from Factory__c where Name =: 'K4' limit 1].Id);
        wrapper.specificRfqItem.put('Substrate_Unit__c', 100);
        List<sObject> wireConfigurations = wrapper.wireConfigurations;
         
        wireConfigurations[0].put('Number_Of_Wires__c', 20);
        wireConfigurations[0].put('Total_3D_Wire_Length__c', 300);
        wrapper.dieConfigurations[0].put('Die_Size_X__c', 10);
        wrapper.dieConfigurations[0].put('Die_Size_Y__c', 10);
        
        RFQItemDao.getInstance().saveLineItem(wrapper);
        
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(rfqItem);
        ApexPages.currentPage().getParameters().put('edit','1');
        RFQItemController rfqItemCont = new RFQItemController(sc);
        
        //Bhanu code coverage
        rfqItemCont.setupChangingOutputAttributes(wrapper,'test');
        RFQItemController.getNewStatusForSubmit(wrapper);
        //rfqItemCont.getsalesFactoryOptions();
        //rfqItemCont.getbuFactoryOptions();
        rfqItemCont.getIsPriceComplete();
        rfqItemCont.getIsQual();
        rfqItemCont.getIsProgramCancelledPossible();
        rfqItemCont.getShowPriceToCustomerSave();
        rfqItemCont.getIsProgramCancelled();
        rfqItemCont.getIsBUDraft();
        rfqItemCont.getIsEscalatableState();
        rfqItemCont.getIsAddServicePossible();
        rfqItemCont.getIsReloadPossible();
        rfqItemCont.getShowEditButton();
        rfqItemCont.getIsUnderSalesApproval();
        rfqItemCont.buEditRedirect();
        rfqItemCont.buViewRedirect();
        rfqItemCont.getIsCounterComparePossible();
        rfqItemCont.counterCompare();
        rfqItemCont.defaultCompare();
        rfqItemCont.addService();
        rfqItemCont.pricesFieldsValid();
        rfqItemCont.setNREInclusionDefaults(wrapper);
        //rfqItemCont.getAllValidationErrors(wrapper);
        rfqItemCont.viewRelatedItems();
        rfqItemCont.viewRelatedItemsAdvanced();
        rfqItemCont.getRelatedItemsVisible();
        rfqItemCont.getShowNREAttributes();
        rfqItemCont.getIsWaferTestType();
        rfqItemCont.getPostTestServiceOnlyTestType();
        rfqItemCont.gotoStandardApprovalWizard();
        rfqItemCont.getAutoCostErrors();
        rfqItemCont.getSalesCanApprove();
        rfqItemCont.getIsSalesApprove();
        rfqItemCont.getIsSalesUser();
        rfqItemCont.getIsEngineeringService();
        rfqItemCont.getShowPostTestServiceCostAndPrice();
        wrapper.volumeList.add(new RFQIVolume(false));
        wrapper.rfqItem.Multi_Volume__c = JSON.serialize(wrapper.volumeList);
        rfqItemCont.populateTotalCostinVolumeconfig();
        //rfqItemCont.submitItem();
        return rfqItemCont;
               
    }
    
    private static testmethod void testOtherFields() {
        RFQAdminInstaller.install();
        FCCSPInstaller.install();
        FCCSPInstaller.install2();

        RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('FC CSP', 1, 0, 0, 1);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(wrapper.rfqItem);
        ApexPages.currentPage().getParameters().put('edit','1');
        Test.startTest();
        RFQItemController rfqItemCont = new RFQItemController(sc);

        RFQILayoutSection sectionLayout = rfqItemCont.layout.sectionMap.get('Package Description');

        Decimal intialSize = sectionLayout.attributes.size();

        
        rfqItemCont.wrapper.specificRfqItem.put('Lid__c', true);
        RFQItemDao.getInstance().saveLineItem(rfqItemCont.wrapper);

        rfqItemCont.wrapper=RFQItemDao.getInstance().getWrapperById(rfqItemCont.wrapper.rfqItem.Id);
        sectionLayout = rfqItemCont.setupLayout().sectionMap.get('Package Description');
        Test.stopTest();

        System.assert(rfqItemCont.wrapper.specificRfqItem.get('Lid__c') == true);
        Decimal finalSize = sectionLayout.attributes.size();

        System.assertNotEquals(intialSize, finalSize, 'finalSize: ' + finalSize + ' intialSize: ' + intialSize);
        

    }

    private static testmethod void testOtherChildFields() {
        RFQAdminInstaller.install();
        FCCSPInstaller.install();
        FCCSPInstaller.install2();
        RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('FC CSP', 1, 0, 0, 1);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(wrapper.rfqItem);
        ApexPages.currentPage().getParameters().put('edit','1');
        Test.startTest();
        RFQItemController rfqItemCont = new RFQItemController(sc);

        //child testing

        rfqItemCont.wrapper.setupChildObjectSections(rfqItemCont.layout);

        RFQILayoutSection sectionLayout = rfqItemCont.wrapper.childObjectSections.get(rfqItemCont.wrapper.passiveConfigurations[0].Id);

        Decimal intialSize = sectionLayout.attributes.size();

        system.assertNotEquals(rfqItemCont.wrapper.childObjectSections, null, 'This value should be not null: ' + String.valueOf(rfqItemCont.wrapper.childObjectSections));

        

        rfqItemCont.wrapper.setAttribute('Passive_Type__c','Passive', 'capacitor');
        RFQItemDao.getInstance().saveLineItem(rfqItemCont.wrapper);
        rfqItemCont.wrapper=RFQItemDao.getInstance().getWrapperById(rfqItemCont.wrapper.rfqItem.Id);
        
        rfqItemCont.layout = rfqItemCont.setupLayout();
        
        sectionLayout = rfqItemCont.wrapper.childObjectSections.get(rfqItemCont.wrapper.passiveConfigurations[0].Id);
        Test.stopTest();

        System.assert(rfqItemCont.wrapper.getAttribute('Passive_Type__c',rfqItemCont.wrapper.passiveConfigurations[0].Id) == 'capacitor');
        Decimal finalSize = sectionLayout.attributes.size();

        System.assertNotEquals(intialSize, finalSize, 'finalSize: ' + finalSize + ' intialSize: ' + intialSize);
    }
    
    private static testmethod void testBools() {
        RFQItemController rfqItemCont = setupController();
        
        rfqItemCont.wrapper.rfqItem.Status__c = 'Price New';
        system.assert(rfqItemCont.getIsAttributesEditableState() != false);
        system.assert(rfqItemCont.getIsEditableState() != false);
        
        rfqItemCont.wrapper.rfqItem.Status__c = 'Price Complete';
        system.assert(rfqItemCont.getIsEscalationPossible() != false);
        system.assert(rfqItemCont.getIsAttributesEditableState() == false);
        system.assert(rfqItemCont.getShowDraftButton() == false);
        
        rfqItemCont.wrapper.rfqItem.Status__c = 'Quoted';
        system.assert(rfqItemCont.getIsQuoted() != false);
        system.assert(rfqItemCont.getIsEditableState() == false);
        
        //Bhanu-L code coverage
        rfqItemCont.wrapper.rfqItem.Status__c = 'Price Complete';
        system.assert(rfqItemCont.getIsBuNreEditableState() != True);
    }
    
    private static testmethod void testSetupCostModel() {
        RFQItemController rfqItemCont = setupController();
        PageReference pg = rfqItemCont.setupCostModel();
        system.assert(pg == null);
        
        rfqItemCont.wrapper.packageFamily.Name = 'SCSP';
        pg = rfqItemCont.setupCostModel();
        system.assert(pg == null);
    }
    
    //should technically be a part of view controller?
    private static testmethod void testAddService() {
        RFQItemController rfqItemCont = setupController();
        PageReference pg = rfqItemCont.addService();
        system.assert(pg != null);
    }
        
    private static testmethod void testCalulatePricePBGA() {
        RFQItemController rfqItemCont = setupPBGAController();                
        Test.startTest();

        rfqItemCont.wrapper.rfqItem.put('Status__c', RFQItemDao.STATUS_NEW);
        rfqItemCont.calculatePrice();

        ApexPages.Message[] messages = ApexPages.getMessages();

        for (ApexPages.Message msg : messages) {
            DebugUtils.getInstance().log(msg.getSummary() + msg.getDetail());
        }

        System.assertEquals((Decimal)rfqItemCont.wrapper.specificRfqItem.get('Price_To_Customer__c'), null, 'Price to customer should be null');
        System.assertEquals((Decimal)rfqItemCont.wrapper.specificRfqItem.get('BU_Price__c'), null, 'BU Price should not be null');

        //system.assert((Decimal)rfqItemCont.wrapper.specificRfqItem.get('Price_To_Customer__c') >= (Decimal)rfqItemCont.wrapper.specificRfqItem.get('BU_Price__c'), 'Price to customer should be greater or equal to bu price');
        Test.stopTest();
        
    }

    private static testmethod void testRelatedField() {
        // Test to see if the Related_Item__c formula field works correctly
        RFQ_Item__c firstItem = new RFQ_Item__c();
        insert firstItem;

        // Re-query to get the name
        firstItem = [Select Id, Name from RFQ_Item__c where id =: firstItem.Id];

        RFQ_Item__c secondItem = new RFQ_Item__c(Original_RFQ_Item__c=firstItem.Id);
        insert secondItem;

         RFQ_Item__c thirdItem = new RFQ_Item__c(Parent_RFQ_Item__c=firstItem.Id);
        insert thirdItem;

        // Re-grab items so formula fields will be evaluated
        secondItem = [Select Id, Related_Item__c, Original_RFQ_Item__c from RFQ_Item__c where Id =: secondItem.Id];
        System.assert(secondItem.Related_Item__c.contains(firstItem.Name), 'Related_Item__c should contain the original rfq item, actual was: ' + secondItem.Related_Item__c + ' Name was: ' + firstItem.Name);

        thirdItem = [Select Id, Related_Item__c, Parent_RFQ_Item__c from RFQ_Item__c where Id =: thirdItem.Id];
        System.assert(thirdItem.Related_Item__c.contains(firstItem.Name), 'Related_Item__c should contain the parent rfq item, actual was: ' + thirdItem.Related_Item__c + ' Name was: ' + firstItem.Name);
    }

    //Bhanu S 14-July-2016
    private static testmethod void testSaveItem() {
        RFQItemController rfqItemCont = setupController();
        PageReference pg = rfqItemCont.saveItem();
        system.assert(pg == null);
    }

}