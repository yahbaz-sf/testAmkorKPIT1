@isTest
private class RFQStatusUpdateControllerTest {
    
    @isTest static void testConstructor() {
        RFQStatusUpdateController cont = setupTest();
        system.assertEquals(4, cont.rfqitems.size());
        system.assertEquals(4, cont.endRange);
    }
    
    @isTest static void testButtons() {
        RFQStatusUpdateController cont = setupTest();

        cont.firstPage();
        system.assertEquals(0, cont.startRange);
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        String startRange = String.valueOf(cont.startRange+1);
        String endRange = String.valueOf(cont.endRange);
        System.assert(msgList[0].getSummary().contains(startRange));
        System.assert(msgList[0].getSummary().contains(endRange));
        System.assertEquals(ApexPages.Severity.Info, msgList[0].getSeverity());

        cont.firstPage();
        system.assertEquals(0, cont.startRange);
        msgList = ApexPages.getMessages();
        startRange = String.valueOf(cont.startRange+1);
        endRange = String.valueOf(cont.endRange);
        System.assert(msgList[0].getSummary().contains(startRange));
        System.assert(msgList[0].getSummary().contains(endRange));
        System.assertEquals(ApexPages.Severity.Info, msgList[0].getSeverity());

        cont.previousPage();
        msgList = ApexPages.getMessages();
        startRange = String.valueOf(cont.startRange+1);
        endRange = String.valueOf(cont.endRange);
        system.assertEquals('Displaying first page already', msgList[1].getSummary());
        system.assertEquals(ApexPages.Severity.Error, msgList[1].getSeverity());
        System.assert(msgList[0].getSummary().contains(startRange));
        System.assert(msgList[0].getSummary().contains(endRange));
        System.assertEquals(ApexPages.Severity.Info, msgList[0].getSeverity());

        msgList.clear();

        cont.nextPage();
        msgList = ApexPages.getMessages();
        system.debug('message size: ' + msgList.size());
        startRange = String.valueOf(cont.startRange+1);
        endRange = String.valueOf(cont.endRange);
        system.assertEquals('Displaying last page already', msgList[2].getSummary());
        system.assertEquals(ApexPages.Severity.Error, msgList[2].getSeverity());
        System.assert(msgList[0].getSummary().contains(startRange));
        System.assert(msgList[0].getSummary().contains(endRange));
        System.assertEquals(ApexPages.Severity.Info, msgList[0].getSeverity());

    }

    @isTest static void testSave() {
        RFQStatusUpdateController cont = setupTest();

        cont.statusWrappers[0].rfqItem.Quoted_Status__c = RFQItemDao.STATUS_PROGRAM_LOSS;

        cont.savePage();
        String startRange = String.valueOf(cont.startRange+1);
        String endRange = String.valueOf(cont.endRange);
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        system.assertEquals(msgList[1].getSummary(),'Please specify a reason for: ' + cont.statusWrappers[0].rfqItem.Name);
        system.assertEquals(ApexPages.Severity.Error, msgList[1].getSeverity());
        System.assert(msgList[0].getSummary().contains(startRange));
        System.assert(msgList[0].getSummary().contains(endRange));
        System.assertEquals(ApexPages.Severity.Info, msgList[0].getSeverity());

        cont.statusWrappers[0].rfqItem.StatusReason__c = 'Other';

        cont.savePage();
        startRange = String.valueOf(cont.startRange+1);
        endRange = String.valueOf(cont.endRange);
        msgList = ApexPages.getMessages();
        system.assertEquals(msgList[2].getSummary(),'Please specify a comment for: ' + cont.statusWrappers[0].rfqItem.Name);
        system.assertEquals(ApexPages.Severity.Error, msgList[2].getSeverity());
        System.assert(msgList[0].getSummary().contains(startRange));
        System.assert(msgList[0].getSummary().contains(endRange));
        System.assertEquals(ApexPages.Severity.Info, msgList[0].getSeverity());

        cont.statusWrappers[0].rfqItem.Status_Comments__c = 'Other';
        cont.savePage();
        startRange = String.valueOf(cont.startRange+1);
        endRange = String.valueOf(cont.endRange);
        msgList = ApexPages.getMessages();
        system.assertEquals(msgList[3].getSummary(), 'Save complete');
        system.assertEquals(ApexPages.Severity.Info, msgList[3].getSeverity());
        System.assert(msgList[0].getSummary().contains(startRange));
        System.assert(msgList[0].getSummary().contains(endRange));
        System.assertEquals(ApexPages.Severity.Info, msgList[0].getSeverity());
        
        
    }
    
    //Bhanu-L 26/07/2016 code coverage change.
    @isTest static void testOtherMethods() {
        RFQStatusUpdateController cont = setupTest();
        cont.statusWrappers[0].rfqItem.Quoted_Status__c = RFQItemDao.STATUS_PROGRAM_LOSS;
        //cont.sortColumn();
        Test.StartTest();
        /*RFQItemWrapper wrapObj = SharedUnitTestUtils.createPfAndLineItem();
        RFQStatusUpdateController.StatusWrapper wrap = new RFQStatusUpdateController.StatusWrapper(wrapObj);*/
        //wrap.compareTo(wrap);
        cont.lastPage();
        list<SelectOption> testoptionsLeft =cont.GetLeftOptions();
        
        RFQStatusUpdateController.SortCriteria contWrapper = new RFQStatusUpdateController.SortCriteria();
        
        list<SelectOption> testoptionsStatus = contWrapper.getStatusList();
        list<SelectOption> testoptionsYears = contWrapper.getYears();
        Test.StopTest();   
    }
    private static RFQStatusUpdateController setupTest() {
        List<RFQ_Item__c> items = new List<RFQ_Item__c>();
        List<sObject> specificItems = new List<sObject>();
        User u = SharedUnitTestUtils.createTestUser(false, false);
        Package_Family__c p = SharedUnitTestUtils.createTestPackageFamily();

        //Bhanu - 3-Mar-2016 : 597492 Missing NRE on EXCEL + "Projected_Revenue__c" is now mandatory
        //Providing Mandatory field "Projected_Revenue__c" on RFQ Object in TestSetup 
        //RFQ__c rfq = new RFQ__c(RFQ_Name__c ='Unit Test RFQ Name');
        RFQ__c rfq = new RFQ__c(RFQ_Name__c ='Unit Test RFQ Name', Projected_Revenue__c = 1234);
        rfq.SBU_Name__c = SharedUnitTestUtils.createTestSBU().Id;
        rfq.OwnerId = u.Id;
        insert rfq;

        items.add(new RFQ_Item__c(Package_Family__c = p.Id, RFQ__c = rfq.Id, Status__c = 'Price Complete'));
        items.add(new RFQ_Item__c(Package_Family__c = p.Id, RFQ__c = rfq.Id, Status__c = 'Price Complete'));
        items.add(new RFQ_Item__c(Package_Family__c = p.Id, RFQ__c = rfq.Id, Status__c = 'Price Complete'));
        items.add(new RFQ_Item__c(Package_Family__c = p.Id, RFQ__c = rfq.Id, Status__c = 'Price Complete'));

        insert items;
        List<RFQI_SOIC_150mil_body__c> soics = new List<RFQI_SOIC_150mil_body__c>();

        soics.add(new RFQI_SOIC_150mil_body__c(RFQ_Item__c = items[0].Id));
        soics.add(new RFQI_SOIC_150mil_body__c(RFQ_Item__c = items[1].Id));
        soics.add(new RFQI_SOIC_150mil_body__c(RFQ_Item__c = items[2].Id));
        soics.add(new RFQI_SOIC_150mil_body__c(RFQ_Item__c = items[3].Id));

        insert soics;

        for(RFQ_Item__c item : items) {
            item.Status__c = 'Quoted';
        }

        update items;

        System.runAs(u) {
            RFQStatusUpdateController cont = new RFQStatusUpdateController();
            for(RFQStatusUpdateController.SortCriteria s : cont.sortCrit) {
                if(s.column == 'Package Family') {
                    s.selected = true;
                    s.filterCriteria = p.Name;
                }
            }
            cont.searchItems();
            return cont;
        }

        return null;
        
    }
    
}