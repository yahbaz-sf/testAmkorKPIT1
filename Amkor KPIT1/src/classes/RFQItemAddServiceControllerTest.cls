/*************************************************************************
*
* PURPOSE: Tests the RFQItemAddServiceController
*
* CLASS: RFQItemAddServiceControllerTest
* CREATED: 5/2/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Nathan Pilkington
***************************************************************************/

@isTest
private class RFQItemAddServiceControllerTest {
    static testMethod void testAddService() {
        List<Product_Group__c> pgs = new List<Product_Group__c>();
        List<Package_Family__c> pfs = new List<Package_Family__c>();

        pgs.add(SharedUnitTestUtils.createProductGroupFromName('PBGA', false));
        pgs.add(SharedUnitTestUtils.createProductGroupFromName('Standalone Services', true));
        insert pgs;

        pfs.add(SharedUnitTestUtils.createPackageFamilyFromName('PBGA', pgs[0], 'RFQI_PBGA__c'));
        pfs.add(SharedUnitTestUtils.createPackageFamilyFromName('Bump', pgs[1], 'RFQI_Bump__c'));

        insert pfs;

        RFQ_Item__c lineItem = SharedUnitTestUtils.createLineItem('PBGA', 0 , 0).rfqItem;

        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('rfqItemId', lineItem.Id);
        RFQItemAddServiceController cont = new RFQItemAddServiceController();
        
        System.assertNotEquals(cont.rfqItem, null, 'Should have got the RFQ Item in the constructor');
        
        PageReference pf = cont.returnToRfqItem();
        
        System.assertNotEquals(pf, null, 'Should have returned to the RFQ Item');
        
        pf = cont.createRfqItemService();
        
        System.assertEquals(pf, null, 'No service type selected so should not have redirected');
        
        List<SelectOption> famlies = cont.getPackageFamilies();

        System.assertNotEquals(famlies.size(), 0, 'Should have got some service options');
        System.assertNotEquals(famlies[0].getValue(), null, 'Should not be null');

        cont.itemPackageFamily = famlies[1].getValue();
        pf = cont.createRfqItemService();
        
        System.assertNotEquals(pf, null, 'Service type is not selected so should have redirected to the create page');
        
        //Bhanu-L code coverage 18/07/2016
        cont.getIsFinalTestPackageFamily();
        //list<SelectOption> testoptions = getTestUOMOptions();
        cont.getTestUOMOptions();
        cont.getTestTimeOptions();
        cont.getTestTypeOptions();
        cont.setdefaultInsertionConfigs();
        cont.getHasInsertionConfiguration();
        cont.getNumberOfInsertionOptions();
        cont.getNumberOptions(1);
        cont.getWaferSizeOptions();
        Test.stopTest();
    }
}