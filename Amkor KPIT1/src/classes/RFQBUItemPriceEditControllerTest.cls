/*************************************************************************
*
* PURPOSE: Unit Tests for the RFQ BU Item Price Editpage
*
* CLASS: RFQBUItemPriceEditControllerTest
* CREATED: 3/22/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/
@isTest
private class RFQBUItemPriceEditControllerTest {
	
	private static testmethod void testConstructor() { 
	    
	    RFQBUItemPriceEditController rfqItemCont = setupController();
	    System.assert(rfqItemCont.layout != null);
	    System.assert(rfqItemCont.layout.sectionMap != null);
	    System.assert(rfqItemCont.wrapper.specificRfqItem != null);
	    System.assert(rfqItemCont.wrapper.wireConfigurations.size() > 0);
	    
	} 
	
	private static testmethod void testButtons() {
		RFQBUItemPriceEditController rfqItemCont = setupController();
		
        Test.startTest();
		PageReference pf = rfqItemCont.editAttributes();
		system.assert(pf != null);
		
		pf = rfqItemCont.cancelEditPrice();
		system.assert(pf != null);
		
		pf = rfqItemCont.saveItemOnly();
		system.assert(pf != null);
		
		pf = rfqItemCont.reloadOriginal();
		system.assert(pf != null);
		Test.stopTest();

	}

	//This is for AMK-1330, CMFCMBuilderBase
	private static testmethod void testSetupCostModelAfterSaving1(){
		//create a MLF and save a line item

		RFQAdminInstaller.install();
		RFQAdminInstaller.installFactories();
		
		MLFInstaller.install();
		CMMLFInstaller.install();	

		RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('Saw Single Row DFN', 1, 1);
		//setup Quote information
		setupQuoteInoformation(wrapper, '> 400', '38');
		//Setup Package description
		setupPackage(wrapper, 'P3', 'Ag Plate', '05x06');
		update wrapper.specificRfqItem;		
		//load page
		ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(wrapper.rfqItem);
		ApexPages.currentPage().getParameters().put('edit','1');
		RFQBUItemPriceEditController rfqItemCont = new RFQBUItemPriceEditController(sc);
		rfqItemCont.loadAction();	
		
		Test.startTest();
		//wrapper = RFQItemDao.getInstance().getWrapperById(wrapperId);
		RFQItemWrapper rfqItemPricecEidtWrapper = rfqItemCont.wrapper;
		Decimal buPrice1a = (Decimal)rfqItemPricecEidtWrapper.specificRfqItem.get('BU_Price_Perc_GM__c');

		rfqItemPricecEidtWrapper.specificRfqItem.put('BU_Price_Perc_GM__c', 66.7789);

		//Save an item and go to the RFQBUItemViewController
		PageReference pf = rfqItemCont.saveItemOnly();		
		sc = new ApexPages.Standardcontroller(rfqItemCont.wrapper.rfqItem);		
		RFQBUItemViewController rfqBUItemViewCont = new RFQBUItemViewController(sc);
		rfqBUItemViewCont.setupCostModel();
		RFQItemWrapper rfqBUViewwrapper = rfqBUItemViewCont.wrapper;
		Decimal buPrice1b = (Decimal)rfqBUViewwrapper.specificRfqItem.get('BU_Price_Perc_GM__c');
		

		rfqItemCont.wrapper.rfqItem.put('Status__c', RFQItemDao.STATUS_PRICE_PENDING_BU);
		rfqItemPricecEidtWrapper = rfqItemCont.wrapper;
		Decimal buPrice2a = (Decimal)rfqItemPricecEidtWrapper.specificRfqItem.get('BU_Price_Perc_GM__c');

		rfqItemPricecEidtWrapper.specificRfqItem.put('BU_Price_Perc_GM__c', 66.7789);

		//Save an item and go to the RFQBUItemViewController
		pf = rfqItemCont.saveItemOnly();		
		sc = new ApexPages.Standardcontroller(rfqItemCont.wrapper.rfqItem);		
		rfqBUItemViewCont = new RFQBUItemViewController(sc);
		//rfqBUItemViewCont.setupCostModel();
		rfqBUViewwrapper = rfqBUItemViewCont.wrapper;
		Decimal buPrice2b = (Decimal)rfqBUViewwrapper.specificRfqItem.get('BU_Price_Perc_GM__c');

		Test.stopTest();
		
		System.assert( buPrice1a == null, 'BU_Price_Perc_GM__c test 1a-1: ' + buPrice1a);
		System.assert(buPrice1b == 66.7789, 'BU_Price_Perc_GM__c test 1b-2: ' + buPrice1b);
		System.assert( buPrice2a != null, 'BU_Price_Perc_GM__c test 1c-1: ' + buPrice2a);
		System.assert(buPrice2b == 66.7789, 'BU_Price_Perc_GM__c test 1d-2: ' + buPrice2b);

	}


	//This is for AMK-1393 for CMPBGA
	private static testmethod void testSetupCostModelAfterSaving2(){
		//create a MLF and save a line item

		RFQAdminInstaller.install();
		RFQAdminInstaller.installFactories();
		
		PBGAInstaller.install();
		CMPBGAInstaller.install();	

		RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('PBGA', 1, 1);
		//setup Quote information
		setupQuoteInoformation(wrapper, '> 400', null);
		//Setup Package description
		setupPackage(wrapper, 'P3', null, '05x06');
		update wrapper.specificRfqItem;		
		//load page
		ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(wrapper.rfqItem);
		ApexPages.currentPage().getParameters().put('edit','1');
		RFQBUItemPriceEditController rfqItemCont = new RFQBUItemPriceEditController(sc);
		rfqItemCont.loadAction();	
		
		Test.startTest();
		//wrapper = RFQItemDao.getInstance().getWrapperById(wrapperId);
		RFQItemWrapper rfqItemPricecEidtWrapper = rfqItemCont.wrapper;
		Decimal assembly1a = (Decimal)rfqItemPricecEidtWrapper.specificRfqItem.get('Assembly__c');
		Decimal baseAU1a = (Decimal)rfqItemPricecEidtWrapper.specificRfqItem.get('Base_Customer_Au_Price__c');

		rfqItemPricecEidtWrapper.specificRfqItem.put('Assembly__c', 66.7789);
		rfqItemPricecEidtWrapper.specificRfqItem.put('Substrate_Unit__c', 0.085);

		//Save an item and go to the RFQBUItemViewController
		PageReference pf = rfqItemCont.saveItemOnly();		
		sc = new ApexPages.Standardcontroller(rfqItemCont.wrapper.rfqItem);		
		RFQBUItemViewController rfqBUItemViewCont = new RFQBUItemViewController(sc);
		rfqBUItemViewCont.setupCostModel();
		RFQItemWrapper rfqBUViewwrapper = rfqBUItemViewCont.wrapper;
		Decimal assembly1c = (Decimal)rfqBUViewwrapper.specificRfqItem.get('Assembly__c');
		
		//-- Test with a different status that should not have a null BU Price
		rfqItemCont.wrapper.rfqItem.put('Status__c', RFQItemDao.STATUS_PRICE_PENDING_BU);
		rfqItemPricecEidtWrapper = rfqItemCont.wrapper;
		Decimal assembly2a = (Decimal)rfqItemPricecEidtWrapper.specificRfqItem.get('Assembly__c');
		Decimal baseAU2a = (Decimal)rfqItemPricecEidtWrapper.specificRfqItem.get('Base_Customer_Au_Price__c');

		rfqItemPricecEidtWrapper.specificRfqItem.put('Assembly__c', 66.7789);
		rfqItemPricecEidtWrapper.specificRfqItem.put('Substrate_Unit__c', 0.085);

		//Save an item and go to the RFQBUItemViewController
		pf = rfqItemCont.saveItemOnly();		
		sc = new ApexPages.Standardcontroller(rfqItemCont.wrapper.rfqItem);		
		rfqBUItemViewCont = new RFQBUItemViewController(sc);
		rfqBUItemViewCont.setupCostModel();
		rfqBUViewwrapper = rfqBUItemViewCont.wrapper;
		Decimal assembly2c = (Decimal)rfqBUViewwrapper.specificRfqItem.get('Assembly__c');

		Test.stopTest();

		//-- with a new status the values should be null
		System.assert( assembly1a == null, 'Assembly__c test 2-1: ' + assembly1a);
		System.assert( baseAU1a == 525, 'Base_Customer_Au_Price__c test 2-1: ' + baseAU1a);
		System.assert(assembly1c == 66.7789, 'Assembly__c test 2-2: ' + assembly1c);

		// make sure it is not null at the first time
		System.assert( assembly2a != null, 'Assembly__c test 2-1: ' + assembly2a);
		System.assert( baseAU2a != null, 'Base_Customer_Au_Price__c test 2-1: ' + baseAU2a);
		System.assert(assembly2c == 66.7789, 'Assembly__c test 2-2: ' + assembly2c);

	}

	static private void setupQuoteInoformation(RFQItemWrapper wrapper, String forecast, String annualVolume){
		
		if(forecast != null)
			wrapper.setAttribute('Forecast__c', 'Package', forecast);
		if(annualVolume != null)
			wrapper.setAttribute('Annual_Volume__c', 'Package', annualVolume);
		
		
	}


	static private void setupPackage(RFQItemWrapper wrapper, String location, String Frame_Finish, String Body_Size){
		
		System.debug(LoggingLevel.ERROR, '#### start config package');
		
		if(location != null){
			Factory__c factory = [Select Name, id From Factory__c where Name =: location];
			wrapper.setAttribute('Factory__c', 'Package', factory.Id);
		}
		if(Frame_Finish != null)
			wrapper.setAttribute('Frame_Finish__c', 'Package', Frame_Finish);
		if(Body_Size != null)						
			wrapper.setAttribute('Body_Size__c', 'Package', Body_Size);		
				
		//wrapper.setAttribute('Standard_Rough_Leadframe__c', 'Package', Standard_Rough_Leadframe);		
		//wrapper.setAttribute('Additional_Components_In_Package__c', 'Package', Additional_Components_In_Package);
		
		System.debug(LoggingLevel.ERROR, '#### end config package');					
		
	}

	public static testmethod void testMerValidationThrowingException() {
		// Make sure the controller does not throw an exception when some of the MER fields are not filled out
		RFQAdminInstaller.install();
		CABGAInstaller.install();

		RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('CABGA', 1, 1);
		wrapper.specificRfqItem.put('Body_X__c', 10);
		wrapper.specificRfqItem.put('Body_Y__c', 10);
		wrapper.specificRfqItem.put('Number_of_BGA_Balls__c', 100);
		wrapper.wireConfigurations[0].put('Number_of_Wires__c', 10);

		RFQItemDao.getInstance().saveLineItem(wrapper);

		try {
			ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(wrapper.rfqItem);
		    ApexPages.currentPage().getParameters().put('edit','1');
		    RFQBUItemPriceEditController rfqItemCont = new RFQBUItemPriceEditController(sc);
		    rfqItemCont.loadAction();
		} catch (Exception e) {
			System.assert(false, 'Caught exception while loading with no MER fields: ' + e);
		}

	}
	
	//Lalit Salesforce-124 Test class code coverage.
	public static testmethod void testpagereferencesmethods()
    {
        RFQAdminInstaller.install();
		RFQAdminInstaller.installFactories();
		
		PBGAInstaller.install();
		CMPBGAInstaller.install();	

		RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('PBGA', 1, 1);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(wrapper.rfqItem);
		ApexPages.currentPage().getParameters().put('edit','1');
        test.startTest();
        PageReference pageRef = Page.RFQBuImport;
        Test.setCurrentPage(pageRef);
        RFQBUItemPriceEditController controller = new RFQBUItemPriceEditController(sc);
        controller.importItem();
        //test.stopTest();
        
        //test.startTest();
        PageReference pageRef1 = Page.RFQReassign;
        Test.setCurrentPage(pageRef1);
        RFQBUItemPriceEditController controller1 = new RFQBUItemPriceEditController(sc);
        controller1.reAssign();
        test.stopTest();
        
        /*test.startTest();
        //PageReference pageRef1 = Page.RFQReassign;
        Test.setCurrentPage(pageRef1);
        RFQBUItemPriceEditController controller1 = new RFQBUItemPriceEditController(sc);
        controller1.repriceItem();
        test.stopTest();*/
        
    }

	public static testmethod void testNREConfigurations()
	{

		//make sure the sections and a layout exist
	    RFQAdminInstaller.install();
	    PBGAInstaller.install();
	    RFQAdminInstaller.AMK1708();
	         
	    RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('PBGA');
	    
	    Test.startTest();
	    ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(wrapper.rfqItem);
	    ApexPages.currentPage().getParameters().put('edit','1');
	    RFQBUItemPriceEditController rfqItemCont = new RFQBUItemPriceEditController(sc);
	    rfqItemCont.loadAction();

	    System.assert(rfqItemCont.wrapper.nreConfigurations.size() == 0, 'Should be no nreConfigurations for the wrapper yet');

	    rfqItemCont.addNREConfiguration();
	    rfqItemCont.addNREConfiguration();
	    rfqItemCont.addNREConfiguration();

	    System.assert(rfqItemCont.wrapper.nreConfigurations.size() == 3, 'Should be 3 nreConfigurations in the wrapper');

	    ApexPages.currentPage().getParameters().put('nreConfigId',rfqItemCont.wrapper.nreConfigurations[0].Id);
		rfqItemCont.removeNreConfigurationById();

	    System.assert(rfqItemCont.wrapper.nreConfigurations.size() == 2, 'Page should have removed one nreConfiguration');

	    RFQItemDao.getInstance().saveLineItem(wrapper);

	    sc = new ApexPages.Standardcontroller(wrapper.rfqItem);
	    RFQBUItemEditController buRfqItemCont = new RFQBUItemEditController(sc);
	    System.assert(buRfqItemCont.wrapper.nreConfigurations.size() == 2, '2 nreConfigurations should have been saved to the database');

		Test.stopTest();


	}

	

	public static RFQBUItemPriceEditController setupController() {
		return setupController('PBGA');
	}
	
	public static RFQBUItemPriceEditController setupController(String packageFamily) {
		
		//make sure the sections and a layout exist
	    RFQAdminInstaller.install();
	    PBGAInstaller.install();
	    CABGAInstaller.install();
	         
	    RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem(packageFamily);
	    
	    ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(wrapper.rfqItem);
	    ApexPages.currentPage().getParameters().put('edit','1');
	    RFQBUItemPriceEditController rfqItemCont = new RFQBUItemPriceEditController(sc);
	    rfqItemCont.loadAction();
	    return rfqItemCont;
	}

}