@isTest
private class RFQOpportunityTest {
    
/*
    private static testMethod void testConversion() {

        setup();
  
        //Simulate the pre-oppty RFQ/RFQs
        RFQ__c rfq = SharedUnitTestUtils.createTestRFQ();

        RFQItemWrapper wrapper1 = SharedUnitTestUtils.createLineItem('SCSP', rfq);
        wrapper1.rfqItem.Status__c = RFQItemDao.STATUS_QUOTED;
        wrapper1.rfqItem.Opportunity__c = null;
        update wrapper1.rfqItem;

        RFQItemWrapper wrapper2 = SharedUnitTestUtils.createLineItem('SCSP', rfq);
        wrapper2.rfqItem.Status__c = RFQItemDao.STATUS_PROGRAM_WIN;
        wrapper2.rfqItem.Opportunity__c = null;
        update wrapper2.rfqItem;

        RFQItemWrapper wrapper3 = SharedUnitTestUtils.createLineItem('SCSP', rfq);
        wrapper3.rfqItem.Status__c = RFQItemDao.STATUS_NEW;
        wrapper3.rfqItem.Opportunity__c = null;
        update wrapper2.rfqItem;

        rfq.Opportunity__c = null;
        update rfq;

        delete [select Id from Opportunity];

        Test.startTest();

        RFQOpportunityDao.createFromRFQ((new Map<Id,SObject>([select Id from RFQ__c where Opportunity__c =: null])).keySet(),true);
        RFQOpportunityDao.repointRFQItems();

        Test.stopTest();
        rfq = [select Id,Opportunity__c from RFQ__c where id=:rfq.Id];
        //Should take on the higest stagename/status mapping
        System.assertEquals([select StageName from Opportunity where Id =: rfq.Opportunity__c].StageName,'RFQ/Quote');
        System.assert([select Id from Opportunity].size() == 1);
        Opportunity opp = [select Id from Opportunity][0];

        for(RFQ_Item__c item : [select Id,Opportunity__c from RFQ_Item__c]) {
            System.assertEquals(item.Opportunity__c, opp.Id);
        }
        System.assertEquals(rfq.Opportunity__c, opp.Id);
    }
*/
    private static testMethod void testViewController() {
        setup();
        Opportunity opp = SharedUnitTestUtils.createTestOpportunity();
        RFQ__c rfq = null;
        RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('SCSP', rfq);
        wrapper.rfqItem.Opportunity__c = opp.Id;
        update wrapper.rfqItem;
        ApexPages.StandardController sc = new ApexPages.StandardController(wrapper.rfqItem);
        Test.startTest();
        RFQOpItemController opView = new RFQOpItemController(sc);
        System.assert(opView.editItem() != null);
        Test.stopTest();

    }

    private static testMethod void testEditController() {
        setup();
        Opportunity opp = SharedUnitTestUtils.createTestOpportunity();
        RFQ__c rfq = null;
        RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('SCSP', rfq);
        wrapper.rfqItem.Opportunity__c = opp.Id;
        update wrapper.rfqItem;
        ApexPages.StandardController sc = new ApexPages.StandardController(wrapper.rfqItem);
        Test.startTest();
        RFQOpItemEditController opView = new RFQOpItemEditController(sc);
        System.assert(opView.saveItemAsDraft() != null);
        System.assert(opView.cancelItem() != null);
        Test.stopTest();
    }


    private static testMethod void testAutoRFQCreation() {

        setup();
        Opportunity opp = SharedUnitTestUtils.createTestOpportunity();
        RFQ__c rfq = null;
        RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('SCSP', rfq);
        wrapper.rfqItem.Opportunity__c = opp.Id;
        update wrapper.rfqItem;

        Test.startTest();
        //opp.StageName = 'RFQ/Quote';
        //Bhanu - 21-June-2016 : Salesforce 69 - Opportunity Status Change
        //Updating Existing values with new value
        opp.StageName = 'RFQ/Quote';        
        update opp;
        Test.stopTest();
        System.assert([select Id from RFQ__c].size() > 0);
        wrapper = RFQItemDao.getInstance().getWrapperById(wrapper.rfqItem.Id);
        System.assert(wrapper.rfqItem.RFQ__c != null);
    }
    
    //Bhanu 14 June 2016 Opportunity Stage Updation
    /*Not Required
    private static testMethod void testStageUpdation() {

        setup();
        Opportunity opp = SharedUnitTestUtils.createTestOpportunity();
        RFQ__c rfq = SharedUnitTestUtils.createTestRFQ();
        RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('SCSP', rfq);
        wrapper.rfqItem.Opportunity__c = opp.Id;
        update wrapper.rfqItem;
        
        Test.startTest();
        List<RFQ_Item__c> rfqItemsOnOppty = [Select Name from RFQ_Item__c where Opportunity__c =: opp.id];
        System.assertNotEquals(0, rfqItemsOnOppty.size());
        try{
            opp.StageName = 'Product/Service Selection';
            opp.RFQ__c = rfq.id;
            update opp;    
        }
        catch(Exception e){
            //System.Assert(e.getMessage().contains('You are receiving this error since there are RFQ Items that must be dispositioned to WIN/LOSS/CANCEL and once updates are made, this Opportunity Status field will be automatically updated.   As a reminder!  If you are attempting to record incremental/increased business that is driven by a Campaign or Upside, please create a NEW Opportunity for tracking purposes'));
        }
        Test.stopTest();
    }
    */
    //Bhanu 14 June 2016 Opportunity Stage Updation ends ------------
    
    /*
    private static testMethod void testSetStatusToClosed() {
    
        setup();
        Opportunity opp = SharedUnitTestUtils.createTestOpportunity();
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        RFQOpportunityController cont = new RFQOpportunityController(sc);
        RFQ__c rfq = null;
        RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('SCSP', rfq);
        wrapper.rfqItem.Opportunity__c = opp.Id;
        update wrapper.rfqItem;
        PageReference pg = cont.setStatusToClosed();
        opp = [select Id, Opportunity_Status__c from Opportunity where Id =: opp.Id];
        system.assertEquals(opp.Opportunity_Status__c, 'Open');
        wrapper.rfqItem.Status__c = 'Pricing Declined';
        update wrapper.rfqItem;
        pg = cont.setStatusToClosed();
        opp = [select Id, Opportunity_Status__c from Opportunity where Id =: opp.Id];
        system.assertEquals(opp.Opportunity_Status__c, 'Closed');

    }*/

    private static testMethod void testOpAddItem() {
    
        setup();
        Opportunity opp = SharedUnitTestUtils.createTestOpportunity();
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        RFQOpportunityController cont = new RFQOpportunityController(sc);
        Test.startTest();
        PageReference pg = cont.addItem();
        Test.stopTest();
        System.assert(pg.getParameters().get('oppId') == opp.Id);
    }

    //private static testMethod void testOpValidation() {
    //  setup();
    //  Opportunity opp = SharedUnitTestUtils.createTestOpportunity();
 //       RFQ__c rfq = null;
 //       RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('SCSP', rfq);
 //       wrapper.rfqItem.Opportunity__c = opp.Id;
 //       update wrapper.rfqItem;
 //       opp.StageName = 'RFQ/Quote';
 //       update opp;

 //       Test.startTest();
 //       opp = [select RFQ__c,StageName from Opportunity where Id =: opp.Id];
 //       System.assert(opp.RFQ__c != null);
 //       Boolean hasException = false;
 //       try {
 //         opp.StageName = 'Closed Won';
 //           update opp;
 //           hasException = false;
 //       }
 //       catch(System.DmlException e) {
 //           hasException = true;
 //       }
 //       Test.stopTest();

 //       System.assert(hasException,'Should not have allowed update');

    //}

    private static testMethod void testAutoOpCreation() {
        
        setup();
        Test.startTest();
        SharedUnitTestUtils.createTestRFQ();
        Test.stopTest();
        System.assert([select Id from Opportunity].size() > 0);

    }

    private static void setup() {
        
        RFQAdminInstaller.install();
        RFQAdminInstaller.installFactories();
        SCSPInstaller.install();
    }


    
}