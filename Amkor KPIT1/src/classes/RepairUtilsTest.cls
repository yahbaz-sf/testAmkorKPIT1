@isTest
public with sharing class RepairUtilsTest {

	static private testMethod void test1()
	{
		RFQItemWrapper wrapper = setupWrapper();

		Type t = Type.forName(wrapper.productGroup.Cost_Model_Implementation__c);				
    	CMPBGABuilder builder = (CMPBGABuilder)t.newInstance();
		builder.calculateNew(wrapper, new CMSettings());

		String rfqId = wrapper.rfqItem.Id;
		Decimal expectedPrice = 20;
		wrapper.specificRfqItem.put('BU_Price__c', expectedPrice);
		RFQItemDao.getInstance().saveLineItem(wrapper);

		wrapper.specificRfqItem.put('BU_Price__c', 30);
		update wrapper.specificRfqItem;

		RepairUtils repair = new RepairUtils('RFQI_PBGA__c');
		repair.repair();
		wrapper = RFQItemDao.getInstance().getWrapperById(rfqId);
		System.assert(wrapper.specificRfqItem.get('BU_Price__c') == expectedPrice, wrapper.specificRfqItem.get('BU_Price__c'));

	}

	static private RFQItemWrapper setupWrapper(){
		
		RFQAdminInstaller.install();
		RFQAdminInstaller.installFactories();
		RFQAdminInstaller.installAccounts();
		
		PBGAInstaller.installTest();				
		CMPBGAInstaller.install();
		
		//get wrapper
		RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('PBGA');
		
				
		return wrapper;
	}
}