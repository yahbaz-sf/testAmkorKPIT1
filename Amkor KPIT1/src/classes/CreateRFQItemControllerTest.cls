/*************************************************************************
* 
* PURPOSE:  unit tests for CreateRFQItemController
*          
*         
* CLASS: CreateRFQItemControllerTest
* CREATED: 03/06/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Jason Swenski
* 
**************************************************************************/
@isTest
public class CreateRFQItemControllerTest {
    
    /**
    * Tests the constructor for the controller in CreateRFQItemController
    */
    private static testmethod void testConstructor() {
        
        Product_Group__c prodGroup = SharedUnitTestUtils.createTestProductGroup();
        RFQ__c rfq = SharedUnitTestUtils.createTestRFQ();
        ApexPages.currentPage().getParameters().put('rfqId',rfq.Id);
        CreateRFQItemController cont = new CreateRFQItemController();
        System.assert(cont.itemPackageGroup == '');
        System.assert(cont.itemPackageFamily == '');
    }
    
    /**
    * Tests the dynamic picklist for product group/package family 
    */
    private static testmethod void testDynamicPicklists() {
    
        Product_Group__c prodGroup = SharedUnitTestUtils.createTestProductGroup();
        RFQ__c rfq = SharedUnitTestUtils.createTestRFQ();
        ApexPages.currentPage().getParameters().put('rfqId',rfq.Id);
        CreateRFQItemController cont = new CreateRFQItemController();
        testDoUserSelection(cont);
    
    }
    
    public static void testDoUserSelection(CreateRFQItemController cont) {
        testDoUserSelection(cont, null);    
    }

    public static void testDoUserSelection(CreateRFQItemController cont, String packageFamilyName) {
        System.debug(LoggingLevel.ERROR, '#### in test Do user selection');
        //make sure we get some product groups since we did createTestProductGroup
        List<SelectOption> groups = cont.getProductGroups();
        System.debug(LoggingLevel.ERROR, '#### groups is ' + groups);
        System.assert(groups.size() > 1);
        
        //take the first product group (there only should be one) and put it into itemPackageGroup
        SelectOption option = groups[1];
        cont.itemPackageGroup = option.getValue();
        
        //Since we "chose" a product group, we should be able to get package families
        List<SelectOption> families = cont.getPackageFamilies();
        System.assert(families.size() > 1); 
        
        cont.itemPackageFamily = families[1].getValue();    

        if (packageFamilyName != null) {
            for (SelectOption family : families) {
                if (family.getLabel() == packageFamilyName) {
                    cont.itemPackageFamily = family.getValue();
                }
            }
        }
    }
    
    /**
    * Tests the creation of a line item
    */
    private static testmethod void testCreateLineItem() {
        
        RFQAdminInstaller.install();
        RFQAdminInstaller.installFactories();
        RFQAdminInstaller.installRFQSystemSettings();
        PBGAInstaller.installTest();
        RFQ__c rfq = SharedUnitTestUtils.createTestRFQ();

        Test.startTest();
        ApexPages.currentPage().getParameters().put('rfqId',rfq.Id);
        CreateRFQItemController cont = new CreateRFQItemController();
        PageReference pg = cont.createLineItem();
        system.assert(pg == null);
        testDoUserSelection(cont);
        cont.createLineItem();
        Test.stopTest();

        List<RFQ_Item__c> genericLineItemList 
            = [select Id from RFQ_Item__c where RFQ__c =: rfq.Id];
            
        System.assert(genericLineItemList.size() > 0);
        
    }
    
    private static testmethod void testGetNumberOfWiresDieOptions() {
        Product_Group__c prodGroup = SharedUnitTestUtils.createTestProductGroup();
        RFQ__c rfq = SharedUnitTestUtils.createTestRFQ();
        ApexPages.currentPage().getParameters().put('rfqId',rfq.Id);
        CreateRFQItemController cont = new CreateRFQItemController();
        List<SelectOption> dieList =
        cont.getNumberOfDiesOptions();
        system.assert(dieList.size() == 17);    
        List<SelectOption> wireList =
        cont.getNumberOfWiresOptions();
        system.assert(wireList.size() == 17);
        List<SelectOption> passiveList =
        cont.getNumberOfPassivesOptions();
        system.assert(passiveList.size() == 17);
        List<SelectOption> insertionList =
        cont.getNumberOfInsertionOptions();
        system.assert(insertionList.size() == 17);

    }

    private static testMethod void testHasChildConfig() {
        RFQ__c rfq = SharedUnitTestUtils.createTestRFQ();
        ApexPages.currentPage().getParameters().put('rfqId',rfq.Id);
        CreateRFQItemController cont = new CreateRFQItemController();
        cont.itemPackageFamily = String.ValueOf(SharedUnitTestUtils.createTestPackageFamily().id);  
        boolean passive = cont.getHasPassiveConfiguration();
        system.assert(passive != true);
        boolean die = cont.getHasDieConfiguration();
        system.assert(die == true);
        boolean wire = cont.getHasWireConfiguration();
        system.assert(wire == true);
        boolean insertion = cont.getHasInsertionConfiguration();
        system.assert(insertion != true);

    }

    private static testMethod void testDefaultConfigNumbers() {
        RFQ__c rfq = SharedUnitTestUtils.createTestRFQ();
        ApexPages.currentPage().getParameters().put('rfqId',rfq.Id);
        CreateRFQItemController cont = new CreateRFQItemController();

        cont.populateDefaultConfigurationNumbers();

        Product_Group__c productGroup = SharedUnitTestUtils.createTestProductGroup();


        cont.itemPackageGroup = String.ValueOf(productGroup.id);
        cont.itemPackageFamily = String.ValueOf(PackageFamilyDao.getInstance().getFamiliesByProductGroup(productGroup.Id)[0].id);

        cont.populateDefaultConfigurationNumbers();

        //check defaults
        system.assert(cont.numberOfWires == '1');
        system.assert(cont.numberOfPassives == '0');
        system.assert(cont.numberOfDies == '1');
        system.assert(cont.numberOfInsertions == '0');

        PageReference pg = cont.autoCreateRedirect();
        system.assert(pg == null);

        ApexPages.currentPage().getParameters().put('packageFamilyId',PackageFamilyDao.getInstance().getFamiliesByProductGroup(productGroup.Id)[0].id);

        pg = cont.autoCreateRedirect();
        system.assert(pg != null);


    }


    private static testMethod void testServiceFieldsCopy() {
        RFQAdminInstaller.install();
        PBGAInstaller.installTest();
        ServiceInstaller.install();

        RFQItemWrapper parentItem = SharedUnitTestUtils.createLineItem('PBGA');

        parentItem.specificRfqItem.put('Body_Size__c', '17');
        parentItem.specificRfqItem.put('Ball_Count__c', 100);

        RFQItemDao.getInstance().saveLineItem(parentItem);

        Test.startTest();

        Package_Family__c servicePf = [Select Id, Layout_Version__c from Package_Family__c where Name =: 'Bump'];

        servicePf.Layout_Version__c = 1;
        update servicePf;

        PageUtil.putParam('packageFamilyId', servicePf.Id);
        PageUtil.putParam('serviceType', 'Bump');
        PageUtil.putParam('parentRfqItemId', parentItem.rfqItem.Id);
        PageUtil.putParam('rfqId', parentItem.rfqItem.RFQ__c);

        CreateRFQItemController c = new CreateRFQItemController();
        system.assertEquals(servicePf.Layout_Version__c, 1);
        system.assertNotEquals(c.rfqId, null);
        c.autoCreateRedirect();

        RFQ_Item__c serviceItem = [Select Id from RFQ_Item__c where Id != :parentItem.rfqItem.Id];

        RFQItemWrapper otherWrapper = RFQItemDao.getInstance().getWrapperById(serviceItem.Id);

        System.assertEquals(otherWrapper.specificRfqItem.get('Body_Size__c'),'17', 'Body size should have copied down');
        System.assertEquals(otherWrapper.specificRfqItem.get('Ball_Lead_Count__c'), '100', 'Ball count should have copied down');

    }

    private static testMethod void testAddedServiceMultiVolumes()
    {
        setupPBGA();
        Package_Family__c testPf = setupTest();

        RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('PBGA', 1, 1);
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

        RFQItemWrapper childWrapper = RFQItemDao.getInstance().getWrapperById(createCont.rfqItem.Id);

        System.assertNotEquals(wrapper.rfqItem.Id, childWrapper.rfqItem.Id, 'A new item should have been created');
        System.assertEquals(childWrapper.rfqItem.Parent_RFQ_Item__c, wrapper.rfqItem.Id, 'The original item should be the parent of the new item');
        System.assert(childWrapper.volumeList.size() > 0, 'At least one volume should have been made for the child item');
        System.assertEquals(wrapper.volumeList.size(), childWrapper.volumeList.size(), 'A volume should have been created on the child for each volume on the parent');

        Map<String, Decimal> testVolumeMap = new Map<String, Decimal>
        {
            '<5' => 5,
            '>50' => 100
        };

        for (Integer i = 0; i < childWrapper.volumeList.size(); i++)
        {
            RFQIVolume childVolume = childWrapper.volumeList[i];
            RFQIVolume parentVolume = wrapper.volumeList[i];
            System.assert(testVolumeMap.get(childVolume.volume) != null, 'Invalid test setup. Check the map against ForecastUtil');
            System.assertEquals(parentVolume.volume, childVolume.volume, 'Volumes on each item should be the same - index:' + i + ', parent volume:' + parentVolume.volume + ', child volume: ' + childVolume.volume);
        }
    }

    private static testmethod void testDesignItem()
    {
        Product_Group__c svcPg = SharedUnitTestUtils.createProductGroupFromName('Engineering Services', true);
        insert svcPg;

        Package_family__c svcPf = SharedUnitTestUtils.createPackageFamilyFromName('Design', svcPg, 'RFQI_Design__c');
        insert svcPf;


        RFQ__c rfq = SharedUnitTestUtils.createTestRFQ();
        ApexPages.currentPage().getParameters().put('rfqId',rfq.Id);

        PageReference pr;
        CreateRFQItemController cont = new CreateRFQItemController();
        pr = cont.createLineItem();
        System.assert(pr == null, 'Must select Package Family');
        System.assert(messagesContains('Please select a Product Group and Package Family'));
        cont.itemPackageFamily = svcPf.Id;

        pr = cont.createLineItem();
        System.assert(pr == null, 'Must select service type');
        System.assert(messagesContains('Please select a Service Type for the Design Service'));

        cont.getServiceTypeOptions();
        cont.serviceDesignType = 'New Design';
        pr = cont.createLineItem();
        System.assert(pr == null, 'Must select Package Type');
        System.assert(messagesContains('Please select a Package Type for the Design Service'));

        cont.packageType = cont.getPackageTypeOptions()[2].getValue();
        pr = cont.createLineItem();
        System.assert(pr != null, 'Item should have been created');

        List<RFQ_Item__c> genericLineItemList = [select Id from RFQ_Item__c where RFQ__c =: rfq.Id];
            
        System.assert(genericLineItemList.size() > 0);

        System.assert(cont.getIsDesign());
        System.assert(cont.getIsDesignPackageFamilies());

    }
    private static testmethod void testDesignItemOther()
    {
        Product_Group__c svcPg = SharedUnitTestUtils.createProductGroupFromName('Engineering Services', true);
        insert svcPg;

        Package_family__c svcPf = SharedUnitTestUtils.createPackageFamilyFromName('Design', svcPg, 'RFQI_Design__c');
        insert svcPf;

        RFQ__c rfq = SharedUnitTestUtils.createTestRFQ();
        ApexPages.currentPage().getParameters().put('rfqId',rfq.Id);

        PageReference pr;
        CreateRFQItemController cont = new CreateRFQItemController();
        cont.itemPackageFamily = svcPf.Id;
        cont.serviceDesignType = 'Other';
        cont.packageType = cont.getPackageTypeOptions()[2].getValue();
        pr = cont.createLineItem();

        System.assert(pr != null, 'Item should have been created');

        List<RFQ_Item__c> genericLineItemList = [select Id from RFQ_Item__c where RFQ__c =: rfq.Id];
            
        System.assert(genericLineItemList.size() > 0);

    }

    private static testmethod void testTestItem()
    {
        Package_Family__c pf = setupTest();

        RFQ__c rfq = SharedUnitTestUtils.createTestRFQ();
        ApexPages.currentPage().getParameters().put('rfqId',rfq.Id);

        PageReference pr;
        CreateRFQItemController cont = new CreateRFQItemController();
        pr = cont.createLineItem();
        System.assert(pr == null);
        System.assert(messagesContains('Please select a Product Group and Package Family'));
        cont.itemPackageFamily = pf.Id;

        pr = cont.createLineItem();
        System.assert(pr == null);
        System.assert(messagesContains('Please select a Test Quote Unit of Measure'));
        cont.testUOM = '/Time';

        pr = cont.createLineItem();
        System.assert(pr == null);
        System.assert(messagesContains('Please select a Package Type for the Test Service'));
        cont.finalTestPackageFamily = 'PBGA';

        pr = cont.createLineItem();
        System.assert(pr == null);
        System.assert(messagesContains('Please select a Time Unit of Measure'));
        cont.testUOM = '/Unit';

        pr = cont.createLineItem();
        System.assert(pr == null);
        System.assert(messagesContains('Please select a Test Type'));
        cont.testType = AMKVARS.TT_FINAL;

        pr = cont.createLineItem();

        List<RFQ_Item__c> genericLineItemList = [select Id from RFQ_Item__c where RFQ__c =: rfq.Id];
            
        System.assert(genericLineItemList.size() > 0);

    }

    private static testmethod void testTestItemPerTime()
    {
        Package_Family__c pf = setupTest();

        RFQ__c rfq = SharedUnitTestUtils.createTestRFQ();
        ApexPages.currentPage().getParameters().put('rfqId',rfq.Id);

        PageReference pr;
        CreateRFQItemController cont = new CreateRFQItemController();
        pr = cont.createLineItem();
        System.assert(pr == null);
        System.assert(messagesContains('Please select a Product Group and Package Family'));
        cont.itemPackageFamily = pf.Id;
        cont.testUOM = '/Time';
        cont.testType = AMKVARS.TT_FINAL;
        cont.finalTestPackageFamily = 'PBGA';
        cont.testTimeUOM = '/Hr';

        pr = cont.createLineItem();

        List<RFQ_Item__c> genericLineItemList = [select Id from RFQ_Item__c where RFQ__c =: rfq.Id];
            
        System.assert(genericLineItemList.size() > 0);

    }

    private static testmethod void testGetters()
    {
        setupPBGA();
        Package_Family__c testPf = setupTest();
        Product_Group__c svcPg = SharedUnitTestUtils.createProductGroupFromName('Engineering Services', true);
        Product_Group__c svcPg2 = SharedUnitTestUtils.createProductGroupFromName('Advanced Product Development', true);
        insert new List<sObject>{svcPg, svcPg2};

        Package_family__c svcPf = SharedUnitTestUtils.createPackageFamilyFromName('Design', svcPg, 'RFQI_Design__c');
        Package_family__c svcPf2 = SharedUnitTestUtils.createPackageFamilyFromName('Emerging', svcPg2, 'RFQI_Emerging__c');
        insert new List<sObject>{svcPf, svcPf2};

        CreateRFQItemController cont = new CreateRFQItemController();
        System.assert(cont.getAllPackageFamilies().size() > 0);

        cont.itemPackageGroup = 'Other Services';
        //more than the '--None--' option
        System.assert(cont.getOtherServices().size() > 1);


        cont.otherService = 'Engineering Services';
        //more than the '--None--' option
        System.assert(cont.getEngineeringServices().size() > 1);


        cont.otherService = 'Advanced Product Development';
        System.assert(cont.getAdvProducts().size() > 1);

        cont.testType = 'Test';
        System.assert(cont.getTestUOMOptions().size() > 1);
        System.assert(cont.getTestTimeOptions().size() > 1);
        System.assert(cont.getTestTypeOptions().size() > 1);
        System.assert(cont.getWaferSizeOptions().size() > 1);

        cont.finalTestProductGroup = testPf.Product_Group__c;
        System.assert(cont.getPackageFamiliesForTest().size() > 1);


        cont.setupAssemblyPfFieldDefs();
        cont.getAssemblyPfFieldDefs();

    }

    private static testmethod void testCancel() {
        CreateRFQItemController cont = new CreateRFQItemController();
        PageReference pg = cont.cancel();
        system.assert(pg != null);
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

    private static Boolean messagesContains(String check)
    {
        List<ApexPages.Message> messages = ApexPages.getMessages();
        Boolean contains = false;
        for (ApexPages.Message message : messages)
        {
            if (message.getSummary().contains(check))
            {
                contains = true;
                break;
            }
        }
        return contains;
    }
    //Bhanu S 10-Aug-2016 SF-111
     private static testMethod void testCampaignSamurai(){
        Opportunity op = SharedUnitTestUtils.createTestOpportunity();
        Campaign campaign = new Campaign(Name = 'Samurai');
        insert campaign;
        //op.StageName = 'RFQ/Quote';
        op.CampaignId = campaign.Id;
        RFQ__c rfq = SharedUnitTestUtils.createTestRFQ();
        //op.RFQ__c = rfq.Id;
        update op;
        ApexPages.currentPage().getParameters().put('oppId',op.Id);
        CreateRFQItemController createItemController = new CreateRFQItemController();
        PageReference pg = Page.CreateRFQItem;
        Test.setCurrentPage(pg);
        
        if((StringUtils.isNotBlank(op.Campaign.Name))&&(op.Campaign.Name).equalsIgnoreCase('Samurai')){
            try{
                RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem(setupTest().Name,rfq);
            }
            catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.AddItemError) ? true : false;
                system.assertEquals(expectedExceptionThrown,true);
            }
        }
        else{
            try{
                System.Debug('--->'+op);
                RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem(setupTest().Name,rfq);
            }
            catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.AddItemError) ? true : false;
                system.assertEquals(expectedExceptionThrown,false);
            }
        }
        
    }
}