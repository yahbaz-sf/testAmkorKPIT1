@isTest
private class RFQItemDaoTest {
    
    private static testmethod void testCopyFieldsToGeneric() {
        RFQ_Item__c item = new RFQ_Item__c();
        RFQI_PBGA__c pbga = new RFQI_PBGA__c();
        RFQIWC_PBGA__c pbgaWc = new RFQIWC_PBGA__c();
        Product_Group__c pbgaPG = new Product_Group__c(Name = 'PBGA');
        insert pbgaPG;
        Package_Family__c pbgapf = new Package_Family__c(Name = 'PBGA', Product_Group__c = pbgaPG.Id, Specific_RFQ_Item_Object__c = 'RFQI_PBGA__c');


        RFQItemWrapper wrapper = new RFQItemWrapper();
        wrapper.rfqItem = item;
        wrapper.specificRfqItem = pbga;
        wrapper.packageFamily = pbgapf;
        wrapper.wireConfigurations = new List<sObject> { pbgaWc };

        pbga.BU_Price__c = 5;
        pbga.Customer_Target_Price__c = 6;
        pbga.Lead_Count__c = '10';
        pbga.Body_Size__c = '17';
        pbgaWc.Wire_Material__c = 'Au';
        pbgaWc.Wire_Diameter__c = '0.5';

        pbga.Customer_Device_Name__c = 'device';
        pbga.Customer_Project_Name__c = 'project';

        RFQItemDao.getInstance().copyFieldsToGeneric(wrapper);

        System.assertEquals(item.BU_Price__c, 5);
        System.assertEquals(item.Customer_Target_Price__c, 6);
        System.assertEquals(item.Leads__c, '10');
        System.assertEquals(item.Body_Size__c, '17');
        System.assertEquals(item.Wire_Type_And_Diameter__c, 'Au/0.5');

        System.assertEquals(item.Project_Device__c, 'project / device', 'Project device should now have a slash');
    }

    private static testmethod void testgetByRfqAndPgId() {
        Product_Group__c testProdGroup = SharedUnitTestUtils.createTestProductGroup();
        RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('Unit Test Package Family');
        List<RFQ_Item__c> items = RFQItemDao.getInstance().getByRfqAndPgId(wrapper.rfqItem.RFQ__r.Id, wrapper.productGroup.Id);
        system.assert(items.size() == 1);
        system.assert(wrapper.rfqItem.Id == items[0].Id);
    }

    //Bhanu - 13-Mar-2016 : Salesforce 69 Opportunity Stage
    //Increasing Code Coverage
    private static testmethod void testgetByRfqAndPfId() {
        Package_Family__c testPackageFamily = SharedUnitTestUtils.createTestPackageFamily();
        RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('Unit Test Package Family');
        List<RFQ_Item__c> items = RFQItemDao.getInstance().getByRfqAndPfId(wrapper.rfqItem.RFQ__r.Id, wrapper.packageFamily.Id);
    }
    
    private static testmethod void testrefresh() {
        Package_Family__c testPackageFamily = SharedUnitTestUtils.createTestPackageFamily();
        RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('Unit Test Package Family');
        RFQItemDao.getInstance().refresh(wrapper);
        RFQItemDao.getInstance().refresh(wrapper, false);
        RFQItemDao.getInstance().refresh(wrapper, false, false);
    }
    
    /*Method does not exist or incorrect signature: [RFQItemDao].refreshForDD(RFQItemWrapper, String, String, Package_Family__c, Id)
    private static testmethod void testrefreshForDD() {
        Package_Family__c testPackageFamily = SharedUnitTestUtils.createTestPackageFamily();
        RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('Unit Test Package Family');
        RFQItemWrapper returnedwrapper = RFQItemDao.getInstance().refreshForDD(wrapper, 'test', 'test',testPackageFamily, wrapper.rfqItem.id);
    }*/
    
   //Bhanu - 13-Mar-2016 : Salesforce 69 Opportunity Stage ends--------
    
    private static testMethod void testChangeMultiVolumeOfAddedServiceParent()
    {
        List<RFQItemWrapper> wrappers = setupWrappers();
        RFQItemWrapper wrapper = wrappers[0];
        RFQItemWrapper childWrapper = wrappers[1];
        Integer initialSize = childWrapper.volumeList.size();

        Test.startTest();
        RFQMultiVolumeSectionController volCont = new RFQMultiVolumeSectionController();
        volCont.cWrapper = wrapper;
        volCont.addVolume();

        wrapper.volumeList[wrapper.volumeList.size() - 1].volume = '>100';
        RFQItemDao.getInstance().saveLineItem(wrapper);
        
        //make sure volume was added to child
        childWrapper = RFQItemDao.getInstance().getWrapperById(childWrapper.rfqItem.Id);
        System.assertEquals(childWrapper.volumeList.size(), initialSize + 1, 'A multi volume should have been added to child item');
        RFQIVolume newVolume = childWrapper.volumeList[childWrapper.volumeList.size() - 1];
        System.assertEquals(newVolume.volume, '>100', 'New volume should have same volume as parent');

        //make sure volume was removed from child
        String volumeToRemove = wrapper.volumeList[0].volume;
        wrapper.volumeList.remove(0);
        RFQItemDao.getInstance().saveLineItem(wrapper);

        childWrapper = RFQItemDao.getInstance().getWrapperById(childWrapper.rfqItem.Id);
        Boolean found = false;
        for (RFQIVolume childVol : childWrapper.volumeList)
        {
            if (childVol.volume == volumeToRemove) found = true;
        }

        System.assert(!found, 'Volume should have been removed from child');

        Test.stopTest();
    }

    private static testMethod void testAddedServiceApprovalProcessChange()
    {
        
        List<RFQItemWrapper> wrappers = setupWrappers(3);
        RFQItemWrapper wrapper = wrappers[0];
        //RFQItemWrapper childWrapper = wrappers[1];
        RFQItemWrapper childWrapper2 = wrappers[2];
        RFQItemWrapper childWrapper3 = wrappers[3];
        
        Test.startTest();
        RFQMultiVolumeSectionController volCont = new RFQMultiVolumeSectionController();
        volCont.cWrapper = wrapper;
        volCont.addVolume();
		
        
        RFQItemDao.getInstance().saveLineItem(wrapper);
        List<RFQItemWrapper> addedServices = new List<RFQItemWrapper>{childWrapper2, childWrapper3};
        //childWrapper.rfqItem.Status__c = RFQItemDao.STATUS_PENDING_ASSEMBLY_APPROVAL;
        childWrapper2.rfqItem.Status__c = RFQItemDao.STATUS_PRICE_PENDING_BU;
        childWrapper3.rfqItem.Status__c = RFQItemDao.STATUS_PRICE_ESCALATION;
        
        update new List<RFQ_Item__c>{childWrapper2.rfqItem, childWrapper3.rfqItem};
        
        //List<String> addedServiceIds = new List<String>{childWrapper.rfqItem.Id, childWrapper2.rfqItem.Id, childWrapper3.rfqItem.Id};
        List<String> addedServiceIds = new List<String>{childWrapper2.rfqItem.Id, childWrapper3.rfqItem.Id};
        
        //change the volume list so escalations will fire
        wrapper.volumeList.remove(0);
        RFQItemDao.getInstance().saveLineItem(wrapper);

        addedServices = RFQItemDao.getInstance().getWrappersByIds(addedServiceIds);

        //map the refreshed wrappers to the old variables
        for (RFQItemWrapper service : addedServices)
        {
            //if (service.rfqItem.Id == childWrapper.rfqItem.Id) childWrapper = service;
            //else 
            if (service.rfqItem.Id == childWrapper2.rfqItem.Id) childWrapper2 = service;
            else if (service.rfqItem.Id == childWrapper3.rfqItem.Id) childWrapper3 = service;
        }

        List<RFQI_Escalation__c> escalations = [SELECT Id FROM RFQI_Escalation__c];
        System.assert(escalations.size() == 1, 'Exactly one item should have been escalated - ' + escalations.size());

        Map<String, Boolean> approvalMap = ApprovalUtils.bulkIsUnderApproval(new Set<String>(addedServiceIds));
        //System.assert(approvalMap.get(childWrapper.rfqItem.Id), 'First added service should be in approval');
        System.assert(approvalMap.get(childWrapper2.rfqItem.Id), 'Second added service should be in approval');
        System.assert(approvalMap.get(childWrapper3.rfqItem.Id), 'Third added service should be in approval');

        Test.stopTest();
    }

    private static List<RFQItemWrapper> setupWrappers()
    {
        return setupWrappers(1);
    }
    private static List<RFQItemWrapper> setupWrappers(Integer additionalChildren)
    {
        List<RFQItemWrapper> wrappers = new List<RFQItemWrapper>();
        setupPBGA();
        Package_Family__c testPf = setupTest();

        RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('PBGA', 1, 1);
        wrappers.add(wrapper);
        RFQMultiVolumeSectionController volCont = new RFQMultiVolumeSectionController();
        volCont.cWrapper = wrapper;
        System.assert(volCont.getShowForecastAsPicklist(), 'PBGA\'s forecast should be a picklist');
        wrapper.specificRfqItem.put('Forecast__c', '<50');

        volCont.addAllVolumes();
        System.assert(wrapper.volumeList.size() > 0, 'At least one volume should have been added');

        RFQItemDao.getInstance().saveLineItem(wrapper);

        ApexPages.currentPage().getParameters().put('rfqItemId', wrapper.rfqitem.Id);
        RFQItemAddServiceController cont = new RFQItemAddServiceController();
        cont.itemPackageFamily = testPf.Id;
        cont.testUOM = '/Unit';
        cont.testType = AMKVARS.TT_FINAL;
        cont.isFinalTestAddedService = 'true';

        PageReference pr = cont.createRfqItemService();

        for (String paramKey : pr.getParameters().keyset())
        {
            ApexPages.currentPage().getParameters().put(paramKey, pr.getParameters().get(paramKey));
        }
        CreateRFQItemController createCont = new CreateRFQItemController();
        createCont.autoCreateRedirect();
        RFQItemWrapper firstChild = RFQItemDao.getInstance().getWrapperById(createCont.rfqItem.Id);
        wrappers.add(firstChild);
        if ((additionalChildren - 1) > 0)
        {
            wrappers.addAll(RFQItemDao.getInstance().cloneLineItems(firstChild, '', true, null, true, true, additionalChildren - 1));
        }


        return wrappers;
    }

    private static void setupPBGA()
    {
        Product_Group__c pg = new Product_Group__c(Name='PBGA');
        pg.Cost_Model_Implementation__c = 'CMPBGABuilder';
        pg.Wire_Calculation_Implementation__c = 'CMWireCalcBase';
        pg.Generated_Price_Requires_BU_Review__c = true;
        insert pg;

        List<Package_Family__c> families = new List<Package_Family__c>();
        FieldBuilderHelper.addPf('PBGA', pg, 'RFQI_PBGA__c', 'RFQIWC_PBGA__c', 'RFQIDC_PBGA__c', families, true);
        insert families;

    }

    private static Package_Family__c setupTest()
    {

        Product_Group__c pg = SharedUnitTestUtils.createProductGroupFromName('Standalone Services', false);
        insert pg;

        Package_Family__c pf = SharedUnitTestUtils.createPackageFamilyFromName('Test', pg, 'RFQI_TESTS__c');
        pf.Default_Number_Of_Insertions__c = 1;
        pf.Specific_Insertion_Configuration_Object__c = 'RFQIIC_TESTS__c';
        pf.Cost_Model_Implementation__c = 'CMTestBuilder';

        insert pf;
        return pf;

    }
    
    //Bhanu - 10-08-2016 : Salesforce 110 : Pricing Complete email is no longer being sent to Test Super Users
    
    private static testMethod void salesRegionTest()
    {
        Test.startTest();
        //RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('Unit Test Package Family');
        List<RFQ_Item__c> lstRfqItem =  new List<RFQ_Item__c>();
        RFQ_Item__c item = new RFQ_Item__c();
        lstRfqItem.add(item);
        RFQItemDao obj = new RFQItemDao();
        obj.getSuperUserEmails(lstRfqItem);
        Test.stopTest();
        
    }
    
    
}