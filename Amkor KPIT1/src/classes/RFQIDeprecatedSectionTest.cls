/*************************************************************************
*
* PURPOSE: Test deprecated fields fuctionality on all pages
*
* CLASS: RFQIDeprecatedSectionTest
* CREATED: 9/20/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Austin Delorme
***************************************************************************/
@isTest
public with sharing class RFQIDeprecatedSectionTest {

	public static DebugUtils debug = DebugUtils.getInstance();

	public static testMethod void testViewPage()
	{
		setupInstaller();

		Package_Family__c pf = [select id, Layout_Version__c from Package_Family__c where Name='FC CSP'];
        RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('FC CSP');

      
        wrapper.rfqItem.Layout_Version__c = 1;
        update wrapper.rfqItem;


        //set a field which gets marked as deprecated
        wrapper.setAttribute('CLAM_OCOGS__c', RFQItemWrapper.PACKAGE_OBJECT, 1.0);
        wrapper.setAttribute('Lid__c', RFQItemWrapper.PACKAGE_OBJECT, true);
         
        Test.startTest();



        ApexPages.StandardController sc = new ApexPages.StandardController(wrapper.rfqItem);
		RFQItemController controller = new RFQItemController(sc);

        Test.stopTest();

		//deprecated component displays when this is true
		System.assert(controller.isLayoutDeprecated);
		System.assert(pf.Layout_Version__c > 1, 'pf.Layout_Version__c: ' + pf.Layout_Version__c);

		
	}

	public static testMethod void testEditPage()
	{

		setupInstaller();

		Package_Family__c pf = [select id, Layout_Version__c from Package_Family__c where Name='FC CSP'];
        RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('FC CSP');
        wrapper.rfqItem.Layout_Version__c = 1;
        String rfqItemId = wrapper.rfqItem.Id;

        //set a field which gets marked as depreciated
        wrapper.setAttribute('CLAM_OCOGS__c', RFQItemWrapper.PACKAGE_OBJECT, 1.0);
        wrapper.setAttribute('Lid__c', RFQItemWrapper.PACKAGE_OBJECT, true);
        RFQItemDao.getInstance().saveLineItem(wrapper);
        wrapper = RFQItemDao.getInstance().getWrapperById(rfqItemId);
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(wrapper.rfqItem);
		RFQItemEditController controller = new RFQItemEditController(sc);

		List<RFQISectionAttribute> attributes = controller.layout.sectionMap.get('Deprecated Fields').attributes;
		/*RFQILayout lay = controller.layout;
		Map<String, RFQILayoutSection> layMap = lay.sectionMap;
		debug.log('layMap', layMap);
		RFQILayoutSection sec = layMap.get('Deprecated Fields');

		List<RFQISectionAttribute> attributes = sec.attributes;*/
		RFQItemDao.getInstance().saveLineItem(wrapper);
		wrapper = RFQItemDao.getInstance().getWrapperById(rfqItemId);
		Test.stopTest();
		//there should be some fields in the deprecated section
		System.assert(attributes.size() > 0, 'attributes.size(): ' + attributes.size());
		System.assert(pf.Layout_Version__c > 1, 'pf.Layout_Version__c: ' + pf.Layout_Version__c);

		//upon edit, layout is brought up to current layout
		System.assert(!controller.isLayoutDeprecated);
		//System.assert(wrapper.rfqItem.Layout_Version__c == pf.Layout_Version__c, 'wrapper.rfqItem.Layout_Version__c: ' + wrapper.rfqItem.Layout_Version__c);

	}




	private static void setupInstaller(){
		RFQAdminInstaller.install();
		//RFQAdminInstaller.installAccounts();
		//RFQAdminInstaller.installFactories();
		//RFQAdminInstaller.installRFQSystemSettings();
		FCCSPInstaller.install();
		FCCSPInstaller.AMK1432();
		//CMFCCSPInstaller.install();

		RFQAdminInstaller.AMK1432();

		RFQI_PF_Field_Def__c def = [select Id, Name, Deprecated__c from RFQI_PF_Field_Def__c where RFQI_Field_Def__r.Name='Lid__c' and Package_Family__r.Name='FC CSP'];
		def.Deprecated__c = true;
		update def;
	}

}