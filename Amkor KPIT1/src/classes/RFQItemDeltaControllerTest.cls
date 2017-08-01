@isTest
private class RFQItemDeltaControllerTest {
    
    private static testmethod void testDeltasCompare() {

        RFQItemDeltaController rfqItemCont = setupController();



        RFQItemWrapper other = RFQItemDao.getInstance().createNewFromWrapper(rfqItemCont.wrapper);
        PageUtil.param('otherId',other.rfqItem.Id);

        //lets make one delta
        rfqItemCont.wrapper.setAttribute(RFQItemWrapper.PACKAGE_OBJECT,'ITAR__c',true);
        rfqItemCont.wrapper = RFQItemDao.getInstance().refresh(rfqItemCont.wrapper, true);

        Test.startTest();
        rfqitemCont.init();
        Test.stopTest();

        System.assert(rfqItemCont.delta.sames.size() > 0, 'Sames: ' + rfqItemCont.delta.sames.size());

    }

    private static testmethod void testDeltasDefault() {

        RFQItemDeltaController rfqItemCont = setupController();

        Test.startTest();
        rfqitemCont.init();
        //should delete the clone created to compare defaults
        rfqitemCont.backToItem();
        Test.stopTest();

        System.assert(rfqItemCont.delta.sames.size() > 0, 'Sames: ' + rfqItemCont.delta.sames.size());

        Integer items = [select COUNT() from RFQ_Item__c];
        System.debug('--->RFQItemDeltaControllerTest items ' + items);
        //Ashish - 09-May-2017 : Salesforce-188 : Die Processing rfqi cancel button is not working
        //As part of 188, not actual deletion will happen so commenting the assert equals & assert a Not Equals
        //System.assertequals(items, 2,'Temp clone should NOT have been deleted, but marked as inactive. There should only be two item');
        //System.assertNotEquals(items, 2,'Temp clone should have been deleted. There should not be two items.');
    }



    private static RFQItemDeltaController setupController() {
        
        ApexPages.StandardController sc = SharedUnitTestUtils.setupStandardControllerWithItem();
        RFQItemDeltaController rfqItemCont = new RFQItemDeltaController(sc);
        return rfqItemCont;
    }


}