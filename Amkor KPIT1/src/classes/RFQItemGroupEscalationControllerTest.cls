/*************************************************************************
* 
* PURPOSE:  This class tests the RFQItemGroupEscalationController
*         
* CLASS: RFQItemGroupEscalationControllerTest
* CREATED: 06/19/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Nathan Pilkington npilkington@ethos.com
* 
**************************************************************************/

@isTest
private class RFQItemGroupEscalationControllerTest {

    static testMethod void testMainCase() {
    	RFQ__c testRfq = SharedUnitTestUtils.createTestRFQ();

    	RFQ_Item__c item1 = new RFQ_Item__c(RFQ__c = testRfq.Id, Status__c = RFQItemDao.STATUS_NEW);
    	RFQ_Item__c item2 = new RFQ_Item__c(RFQ__c = testRfq.Id, Status__c = RFQItemDao.STATUS_PRICE_COMPLETE);
    	RFQ_Item__c item3 = new RFQ_Item__c(RFQ__c = testRfq.Id, Status__c = RFQItemDao.STATUS_PRICE_COMPLETE);

    	List<RFQ_Item__c> newList = new RFQ_Item__c[] { item1, item2, item3 };
    	insert newList;
     
     	ApexPages.currentPage().getParameters().put('rfqId', testRfq.Id);

     	Test.startTest();

     	RFQItemGroupEscalationController cont = new RFQItemGroupEscalationController();
        //System.assertEquals(cont.escalateItems.size(), 2, 'Should have found two items to escalate');

        PageReference pf = cont.escalate();
        //System.assertEquals(pf, null, 'Should not have advanced because no items selected');

        Id selectedItemId = cont.escalateItems[0].rfqItem.Id;
        cont.escalateItems[0].selected = true;

        pf = cont.escalate();
        //System.assertNotEquals(pf, null, 'Should have now escalated the selected item');

        RFQ_Item__c escalatedItem = [Select Id, Status__c from RFQ_Item__c where Id =: selectedItemId];
        //System.assertEquals(escalatedItem.Status__c, RFQItemDao.STATUS_PRICE_ESCALATION);

        List<RFQI_Escalation__c> escalations = [Select Id from RFQI_Escalation__c];
        //System.assertEquals(escalations.size(), 1, 'Should have one escalation object');

        cont = new RFQItemGroupEscalationController();
        //System.assertEquals(cont.escalateItems.size(), 1, 'Should have found one item to escalate');


        pf = cont.cancelEscalation();

        //System.assertNotEquals(pf, null, 'Should have canceled escalation');

     	Test.stopTest();

     	
    }

}