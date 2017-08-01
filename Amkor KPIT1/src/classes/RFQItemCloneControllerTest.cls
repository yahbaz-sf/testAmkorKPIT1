@isTest
private class RFQItemCloneControllerTest {
	
	private static testmethod void testClone() {
		RFQItemCloneController cont = setupController();
	 
	    Test.startTest();
		PageReference pf = cont.cloneToCurrent();
		System.assert(pf != null);

        List<RFQ_Item__c> clonedItems = [select Id from RFQ_Item__c];

        RFQItemWrapper wrapper0 = RFQItemDao.getInstance().getWrapperById(clonedItems[0].Id);
        RFQItemWrapper wrapper1 = RFQItemDao.getInstance().getWrapperById(clonedItems[1].Id);

        //Set<String> fields = wrapper0.getFieldsForObject(RFQItemWrapper.PACKAGE_OBJECT);
        

        Test.stopTest();
       
        List<RFQISectionAttribute> attributes = new List<RFQISectionAttribute>();

        attributes.addAll(cont.layout.sectionMap.get('Package Description').attributes);

        for(RFQISectionAttribute attrib : cont.layout.sectionMap.get('Quote Information').attributes) {
        	if(attrib.fieldAPIName != 'Sales_Target_Price__c' && attrib.fieldAPIName != 'Customer_Target_Price__c' && attrib.fieldAPIName != 'Competitor_Au_Inclusive_Price__c' && attrib.fieldAPIName != 'Competitor__c') {
        		attributes.add(attrib);
        	}
        }

        for(RFQISectionAttribute attribute : attributes) {
        	
           
        	try {

                if(!'systemmodstamp,lastmodifieddate,createddate,rfq_item__c,id'.contains(attribute.fieldAPIName.toLowerCase())) {
	                String val0 = String.valueOf(wrapper0.specificRfqItem.get(attribute.fieldAPIName));
	                String val1 = String.valueOf(wrapper1.specificRfqItem.get(attribute.fieldAPIName));
	                //We clear all pricing fields when a RFQ Item is cloned
	                System.assert(val0 == val1, 'field: ' + attribute.fieldAPIName + ' wrapper0 value: ' + val0 + ' wrapper1 value: ' + val1);
                } 
        	}
        	catch(System.SObjectException e){}
        	
        }
        
        //AMK-1631
        System.assert(wrapper0.rfqItem.Consigned__c == wrapper1.rfqItem.Consigned__c);

	}

	public static RFQItemCloneController setupController() {
		
		//make sure the sections and a layout exist
	    RFQAdminInstaller.install();
	    PBGAInstaller.installTest();
	    //RFQ__c rfq = SharedUnitTestUtils.createTestRFQ();
	    //ApexPages.currentPage().getParameters().put('rfqId',rfq.Id);
		
	    RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('PBGA');

        wrapper.setAttribute('Sales_Target_Price__c',RFQItemWrapper.PACKAGE_OBJECT, 1.00);
        wrapper.setAttribute('Customer_Target_Price__c',RFQItemWrapper.PACKAGE_OBJECT, 1.00);
        wrapper.setAttribute('Competitor_Au_Inclusive_Price__c',RFQItemWrapper.PACKAGE_OBJECT, 1.00);
        wrapper.setAttribute('Competitor__c',RFQItemWrapper.PACKAGE_OBJECT, 'Some competitor');

	    wrapper.rfqItem.Consigned__c = 'Assembly plus Substrate';
	    CPN cpn = CPNDao.getInstance().getCPN(wrapper);
	    wrapper.rfqItem.Configured_Part_Number__c = cpn.cpnId;            
	    RFQItemDao.getInstance().saveLineItem(wrapper);

	    RFQ_Item__c rfqItem = wrapper.rfqItem;

	    ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(rfqItem);
	    ApexPages.currentPage().getParameters().put('edit','1');
	    RFQItemCloneController rfqItemCont = new RFQItemCloneController(sc);


		//system.assertequals(CPN.id,rfqItemCont.wrapper.rfqitem.Configured_Part_Number__c, 'should be the same'); 

	    return rfqItemCont;
	}
}