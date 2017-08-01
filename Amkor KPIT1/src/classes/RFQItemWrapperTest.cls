/*************************************************************************
*
* PURPOSE: Tests Controller for the RFQItemWrapper Class
*
* CLASS: RFQItemWrapperTest
* CREATED: 08/20/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Raghuveer Mandali
***************************************************************************/
@isTest
private class RFQItemWrapperTest {


    private static testMethod void testFactoryName() {
        RFQAdminInstaller.install();
        RFQAdminInstaller.installFactories();
        PBGAInstaller.installTest();
        Test.startTest();

        RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('PBGA');

        wrapper.specificRfqItem.put('Factory__c', [Select Id from Factory__c where Name =: 'K1'].Id);

        Map<Id, Factory__c> factories = new Map<Id, Factory__c>([Select Id, Name from Factory__c]);

        wrapper.applyFactoryName(factories);
        Test.stopTest();

        System.assertEquals(wrapper.factoryName, 'K1', 'Factory name on the wrapper should be K1');
    }


    private static testMethod void testClearingOutPriceToCustomer() {
        RFQItemWrapper wrapper = new RFQItemWrapper();
        wrapper.rfqItem = new RFQ_Item__c();
        wrapper.specificRfqItem = new RFQI_PBGA__c();

        wrapper.rfqItem.Status__c = RFQItemDao.STATUS_PRICE_COMPLETE;
        wrapper.rfqItem.Price_To_Customer__c = 5;

        wrapper.clearPriceToCustomerIfRequired();

        System.assertNotEquals(wrapper.rfqItem.Price_To_Customer__c, null, 'Should not have cleared out price to customer because status is price complete');

        wrapper.rfqItem.Status__c = RFQItemDao.STATUS_BU_DRAFT;
        wrapper.rfqItem.Price_To_Customer__c = 5;
        wrapper.clearPriceToCustomerIfRequired();
        System.assertEquals(wrapper.rfqItem.Price_To_Customer__c, null);

        wrapper.rfqItem.Status__c = RFQItemDao.STATUS_NO_BID;
        wrapper.rfqItem.Price_To_Customer__c = 5;
        wrapper.clearPriceToCustomerIfRequired();
        System.assertEquals(wrapper.rfqItem.Price_To_Customer__c, null);

        wrapper.rfqItem.Status__c = RFQItemDao.STATUS_PRICE_DECLINED;
        wrapper.rfqItem.Price_To_Customer__c = 5;
        wrapper.clearPriceToCustomerIfRequired();
        System.assertEquals(wrapper.rfqItem.Price_To_Customer__c, null);

        wrapper.rfqItem.Status__c = RFQItemDao.STATUS_PRICE_PENDING_BU;
        wrapper.rfqItem.Price_To_Customer__c = 5;
        wrapper.clearPriceToCustomerIfRequired();
        System.assertEquals(wrapper.rfqItem.Price_To_Customer__c, null);


    }

}