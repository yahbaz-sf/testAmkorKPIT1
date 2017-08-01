/*************************************************************************
THIS IS TEMPORARY CLASS FOR TESTING PURPOSES
KPIT1 COPY minus Static Boolean + Many Experiemtns
**************************************************************************/

@isTest
private class RFQPdfExportControllerTest3 {

    //private static boolean run = true;

    /*static testMethod void testAccountManager() {
        createDataForTest();
        Test.startTest();
        RFQ__c rfq = [Select Id, SBU_Name__c from RFQ__c][0];
        List<RFQ_Item__c> rfqItem = [Select Id from RFQ_Item__c where RFQ__c = :rfq.Id];

        String rfqItemIds;
        List<String> tempId = new List<String>();

        for (RFQ_Item__c r : rfqItem) {
            tempId.add(r.Id);
        }

        rfqItemIds = String.join(tempId, ',');

        User user = SharedUnitTestUtils.createTestUser();
        User user2 = SharedUnitTestUtils.createTestUser();

        Account a = [Select Id from Account where Id =: rfq.SBU_Name__c];
        a.OwnerId = user2.Id;
        update a;

        System.runAs(user) {
            PageUtil.putParam('rfqId', rfq.Id);
            PageUtil.putParam('selectedRfqItems', rfqItemIds);
            PageUtil.putParam('comments', '');

            RFQPdfExportController c = new RFQPdfExportController();

            System.assertEquals(c.accountRep.Id, user2.Id, 'Account rep on quote page should be owner on account');

        }
        Test.stopTest();
    }

    static testMethod void testSelectController() {
        createDataForTest();
        
        RFQ__c rfq = [Select Id from RFQ__c][0];
        
        
        User user = SharedUnitTestUtils.createTestUser();
        
        Test.startTest();
        
        System.runAs(user) {
            ApexPages.currentPage().getParameters().put('rfqId',rfq.Id);
            
            RFQPdfExportSelectController cont = new RFQPdfExportSelectController();
            
            System.assertNotEquals(cont.allItemsList.size(), 0, 'Should have some items available to select.');
            
            cont.selectAllItems();
            cont.deselectAllItems();
            for (RFQPdfExportSelectController.RFQItemHolder holder : cont.allItemsList) {
                System.assert(!holder.selected, 'All items should be de-selected');
            }

            cont.selectAllItems();
            cont.selectAllBreakout();
            cont.selectAllLotCharge();
            
            for (RFQPdfExportSelectController.RFQItemHolder holder : cont.allItemsList) {
                System.assert(holder.selected, 'All items should be selected');
                System.assert(holder.adderBreakout, 'All selected items should have breakout selected');
                System.assert(holder.lotCharge, 'All select items should have lot charge selected');
            }
            
            PageReference pf = cont.itemsSelected();
            PageReference pf2 = cont.generatePDF();

            List<attachment> a = [Select Id from Attachment];

            System.assertNotEquals(a.size(), 0, 'Should now be at least one attachment');
            System.assertNotEquals(pf2, null, 'Should have created a PDF attachment and redirected to the attach page');
        }
        
        Test.stopTest();
    }

     static testMethod void testSelectControllerAMK1374() {
        createDataForTest();
        
        RFQ__c rfq = [Select Id from RFQ__c][0];
        
        
        User user = SharedUnitTestUtils.createTestBUUser();
        
        Test.startTest();
        
        System.runAs(user) {
            ApexPages.currentPage().getParameters().put('rfqId',rfq.Id);
            
            RFQPdfExportSelectController cont = new RFQPdfExportSelectController();
            System.assert(cont.allItemsList.size() == 0, 'BU Should not be able to genrate quotes.');
    
        }
        
        Test.stopTest();
    }*/


    
    static testMethod void testExportController() {
        createDataForTest();
        
        RFQ__c rfq = [Select Id from RFQ__c];
        List<RFQ_Item__c> rfqItem = [Select Id from RFQ_Item__c where RFQ__c = :rfq.Id];

        String rfqItemIds;
        List<String> tempId = new List<String>();

        for (RFQ_Item__c r : rfqItem) {
            tempId.add(r.Id);
        }

        rfqItemIds = String.join(tempId, ',');

        User user = SharedUnitTestUtils.createTestUser();
        
        Test.startTest();
        
        System.runAs(user) {
            ApexPages.currentPage().getParameters().put('rfqId',rfq.Id);
            ApexPages.currentPage().getParameters().put('selectedRfqItems', rfqItemIds);
            ApexPages.currentPage().getParameters().put('adderBreakoutItems', rfqItemIds);
        
            RFQPdfExportController cont = new RFQPdfExportController();
            
            System.assertNotEquals(cont.rfq, null, 'Should have gotten the RFQ');
            System.assertNotEquals(cont.rfqAccount, null, 'Should have gotten the account');
            System.assertNotEquals(cont.packageFamilies.size(), 0, 'Should have some package families');
            System.assertNotEquals(cont.wrappers.size(), 0, 'Should have got some RFQ Item wrappers');
            System.assertNotEquals(cont.pfWrappers.keySet().size(), 0, 'Should have some package families and their items set up');
            System.assertNotEquals(cont.accountRep, null, 'Should have set up the current user');
            
            
            for (ID pfId : cont.pfWrappers.keySet()) {
                List<RFQItemWrapper> rfqItems = cont.pfWrappers.get(pfId);
                System.assertNotEquals(rfqItems.size(), 0, 'Each package family should have some items');
            }

            List<Factory__c> allFactories = [Select Id from Factory__c];

            System.assertEquals(allFactories.size(), cont.factories.keySet().size(), 'Should have all factories');
        }
        
        Test.stopTest();
        
    }

    /*static testMethod void testAttributeVisibility() {
        RFQAdminInstaller.install();
        PBGAInstaller.installTest();

        RFQItemWrapper w = SharedUnitTestUtils.createLineItem('PBGA');

        w.specificRfqItem.put('Backgrinding_Required__c', true);

        RFQItemDao.getInstance().saveLineItem(w);

        w = RFQItemDao.getInstance().getWrapperById(w.rfqItem.Id);
        RFQILayout layout = setupLayout(w);
        w.determineAttributeQuoteVisibility(layout);

        RFQILayoutSection s = layout.sectionMap.get('Package Description');

        Boolean foundBackgrind = false;
        Boolean foundHeatspreader = false;

        for (RFQISectionAttribute a : s.attributes) {
            if (a.fieldAPIName == 'Backgrinding_Required__c') {
                foundBackgrind = true;
            }
            if (a.fieldAPIName == 'Heatspreader__c') {
                foundHeatspreader = true;
            }
        }

        System.assert(foundBackgrind, 'Should have the backgrind field in the layout because the checkbox is checked');
        System.assert(!foundHeatspreader, 'Should not have the heatspreader field because the checkbox is not checked');
    }*/
    
    
    static void createDataForTest() {
    
        //if(run){
            RFQAdminInstaller.installFactories();

            List<Product_Group__c> pgs = new List<Product_Group__c>();

            pgs.add(new Product_Group__c(Name = 'Standalone Services'));
            pgs.add(new Product_Group__c(Name = 'Engineering Services'));
            pgs.add(new Product_Group__c(Name = 'Unit Test Product Group'));

            insert pgs;

            List<Package_Family__c> pfs = new List<Package_Family__c>();

            pfs.add(new Package_Family__c(Name = 'Test', 
                                        Specific_RFQ_Item_Object__c = 'RFQI_TESTS__c',
                                        Product_Group__c = pgs[0].Id));
            pfs.add(new Package_Family__c(Name = 'Component Level Reliability', 
                                        Specific_RFQ_Item_Object__c = 'RFQI_Component_Reliability__c',
                                        Product_Group__c = pgs[1].Id));
            pfs.add(new Package_Family__c(Name = 'Unit Test Package Family', 
                                        Specific_RFQ_Item_Object__c = 'RFQI_SOIC_150mil_body__c',
                                        Product_Group__c = pgs[2].Id));

            insert pfs;

            
            RFQ__c r = SharedUnitTestUtils.createTestRFQ();
            RFQItemWrapper item = SharedUnitTestUtils.createLineItem('Unit Test Package Family', r.Id);
            RFQItemWrapper item2 = SharedUnitTestUtils.createLineItem('Component Level Reliability', r.Id);
            RFQItemWrapper item3 = SharedUnitTestUtils.createLineItem('Test', r.Id);
            RFQItemWrapper item4 = SharedUnitTestUtils.createLineItem('Test', r.Id);
            item3.rfqItem.Parent_RFQ_Item__c = item.rfqItem.Id;

            List<RFQI_Field_Def__c> def = new List<RFQI_Field_Def__c>();
            def.add(new RFQI_Field_Def__c(Name = 'Plasma_Before_Die_Attach__c', Type__c = 'Boolean'));
            def.add(new RFQI_Field_Def__c(Name = 'Dry_Pack__c', Type__c = 'Boolean'));
            def.add(new RFQI_Field_Def__c(Name = 'Offline_Ink_Mark__c', Type__c = 'Boolean'));
            insert def;

            List<RFQI_Section__c> section = new List<RFQI_Section__c>();
            section.add(new RFQI_Section__c(Name = 'NRE'));
            section.add(new RFQI_Section__c(Name = 'Post Test Services'));
            section.add(new RFQI_Section__c(Name = 'Post Test Services - Wafer Probe'));
            insert section;

            List<RFQI_PF_Field_Def__c> pfdef = new List<RFQI_PF_Field_Def__c>();
            pfdef.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = def[0].Id, Package_Family__c = item.packageFamily.Id, RFQI_Section__c = section[0].Id));
            pfdef.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = def[1].Id, Package_Family__c = item3.packageFamily.Id, RFQI_Section__c = section[1].Id));
            pfdef.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = def[2].Id, Package_Family__c = item3.packageFamily.Id, RFQI_Section__c = section[2].Id));
            insert pfdef;

            insert new RFQ_Account_Adder_Cost__c(Account__c = (Id)r.get('SBU_Name__c'), Adder__c = pfdef[0].Id, Charge_Amount__c = 2000, Package_Family__c = item.packageFamily.Id, Product_Group__c = item.productGroup.Id, Status__c = 'Active');

            insert new Contact(LastName = 'a', email = 'fake@fake.com');
            
            //List<RFQ_Item__c> rfqItems = [Select Id, Package_Family_Name__c from RFQ_Item__c];

            item.rfqItem.Status__c = RFQItemDao.STATUS_PRICE_COMPLETE;
            item.rfqItem.Include_NRE_On_Quote__c = true;

            item2.rfqItem.Status__c = RFQItemDao.STATUS_PRICE_COMPLETE;
            item2.rfqItem.Parent_RFQ_Item__c = item.rfqItem.Id;

            item3.rfqItem.Status__c = RFQItemDao.STATUS_PRICE_COMPLETE;
            item4.rfqItem.Status__c = RFQItemDao.STATUS_PRICE_COMPLETE;
            
            item.specificRfqItem.put('Plasma_Before_Die_Attach__c', true);
            item3.specificRfqItem.put('Dry_Pack__c', true);
            item3.specificRfqItem.put('Test_Type__c', 'Final Test');
            item4.specificRfqItem.put('Test_Type__c', AMKVARS.TT_PROBE);
            item4.specificRfqItem.put('Offline_Ink_Mark__c', true);
            RFQItemDao.getInstance().saveLineItem(item);
            RFQItemDao.getInstance().saveLineItem(item2);
            RFQItemDao.getInstance().saveLineItem(item3);
            RFQItemDao.getInstance().saveLineItem(item4);
        
            //run = false;
        //}
    }

    /*private static RFQILayout setupLayout(RFQItemWrapper wrapper)
    {
        RFQILayout layout = PFFieldDefDao.getInstance().getPackageFamilyLayout(wrapper.packageFamily.Id, wrapper.packageFamily.Layout_Version__c, (Decimal)wrapper.rfqItem.get('Layout_Version__c'));

        //Loop over OtherAttributes, check if they contain other
        //if they do, add attribute 
        for(String fieldName : layout.getOtherFieldApiNames()) { 
            String fieldValue = String.valueOf(wrapper.getAttribute(fieldName, RFQItemWrapper.PACKAGE_OBJECT, 0));
            if(fieldValue != null && fieldValue.toLowerCase() == 'other') {
                layout.addAttributeForOtherField(fieldName);
            }
        }

        Decimal salesScreenColumns = wrapper.packageFamily.Product_Group__r.Sales_Screen_Columns__c;
        Decimal buScreenColumns = wrapper.packageFamily.Product_Group__r.BU_Screen_Columns__c;
        layout.setBUColumns(Integer.valueOf(bUScreenColumns));
        layout.setSalesColumns(Integer.valueOf(salesScreenColumns));

        wrapper.calculateAttributeVisibility(layout);
        return layout;
    }*/
}