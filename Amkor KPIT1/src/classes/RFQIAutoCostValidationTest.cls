/*************************************************************************
*
* PURPOSE: Test class for RFQIAutoCostValidation
*
* CLASS: RFQIAutoCostValidationTest
* CREATED: 4/16/2014 Ethos Solutions - www.ethos.com  
* AUTHOR: Austin Delorme
***************************************************************************/ 
@isTest
public with sharing class RFQIAutoCostValidationTest {

	public static testMethod void testPBGA()
	{
		RFQAdminInstaller.install();
		PBGAInstaller.installTest();
		RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('PBGA');

		ApexPages.StandardController sc2 = new ApexPages.StandardController(wrapper.rfqItem);
		RFQItemEditController editController = new RFQItemEditController(sc2);
		
		editController.addWireConfiguration();

		Test.startTest();

		//---Wire Configuration
		wrapper = editController.wrapper;
		editController.validateRequiredFields(wrapper, new List<String>());

		//fails because of 2 wires
		System.assert(wrapper.rfqItem.Do_Not_Auto_Price__c, 'PBGA Cannot have more than 1 wire config');

		//reset item
		//resetItem(editController, wrapper.wireConfigurations, wrapper);
		delete wrapper.wireConfigurations;
		wrapper.wireConfigurations = new List<sObject>();
		editController.validateRequiredFields(wrapper, new List<String>());
		System.assert(!wrapper.rfqItem.Do_Not_Auto_Price__c);

		//---Die Configuration
		editController.addDieConfiguration();
		editController.addDieConfiguration();
		wrapper = editController.wrapper;
		editController.validateRequiredFields(wrapper, new List<String>());

		//fails because of 1 die
		System.assert(wrapper.rfqItem.Do_Not_Auto_Price__c, 'PBGA Cannot have more than 1 die config');

		//reset item
		delete wrapper.dieConfigurations;
		wrapper.dieConfigurations = new List<sObject>();
		editController.validateRequiredFields(wrapper, new List<String>());
		System.assert(!wrapper.rfqItem.Do_Not_Auto_Price__c);

		//---Adders
		wrapper.specificRfqItem.put('Passives__c', true);
		editController.validateRequiredFields(wrapper, new List<String>());

		//fails because one adder is true
		System.assert(wrapper.rfqItem.Do_Not_Auto_Price__c, 'PBGA Cannot have any adders');

		Test.stopTest();
	}

	public static testMethod void testQuad()
	{
		RFQAdminInstaller.install();
		QuadLeadframeInstaller.install();
		RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('TQFP');

		ApexPages.StandardController sc2 = new ApexPages.StandardController(wrapper.rfqItem);
		RFQItemEditController editController = new RFQItemEditController(sc2);
		
		Test.startTest();

		//---Die Configuration
		editController.addDieConfiguration();
		editController.addDieConfiguration();
		editController.addDieConfiguration();
		wrapper = editController.wrapper;
		editController.validateRequiredFields(wrapper, new List<String>());

		//fails because of 3 die
		System.assert(wrapper.rfqItem.Do_Not_Auto_Price__c, 'Quad Cannot have more than 2 die configs');

		//reset item
		delete wrapper.dieConfigurations;
		wrapper.dieConfigurations = new List<sObject>();
		editController.validateRequiredFields(wrapper, new List<String>());
		System.assert(!wrapper.rfqItem.Do_Not_Auto_Price__c);

		//---Adders
		wrapper.specificRfqItem.put('Bake__c', true);
		editController.validateRequiredFields(wrapper, new List<String>());

		//fails because one adder is true
		System.assert(wrapper.rfqItem.Do_Not_Auto_Price__c, 'Quad Cannot have any adders');

		Test.stopTest();
	}

	public static testMethod void testDual()
	{
		RFQAdminInstaller.install();
		DualLeadframeInstaller.installTest();
		RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('SOIC 150mil Body');

		ApexPages.StandardController sc2 = new ApexPages.StandardController(wrapper.rfqItem);
		RFQItemEditController editController = new RFQItemEditController(sc2);
		
		Test.startTest();
		wrapper = editController.wrapper;
		//---Adders
		wrapper.specificRfqItem.put('Bake__c', true);
		editController.validateRequiredFields(wrapper, new List<String>());

		//fails because one adder is true
		System.assert(wrapper.rfqItem.Do_Not_Auto_Price__c, 'Quad Cannot have any adders');

		Test.stopTest();
	}

	public static testMethod void testMLF()
	{
		RFQAdminInstaller.install();
		MLFInstaller.install();
		RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('Punch Single Row DFN');

		ApexPages.StandardController sc2 = new ApexPages.StandardController(wrapper.rfqItem);
		RFQItemEditController editController = new RFQItemEditController(sc2);
		
		Test.startTest();

		//---Die Configuration
		editController.addDieConfiguration();
		editController.addDieConfiguration();
		editController.addDieConfiguration();
		wrapper = editController.wrapper;
		editController.validateRequiredFields(wrapper, new List<String>());

		//fails because of 3 die
		System.assert(wrapper.rfqItem.Do_Not_Auto_Price__c, 'MLF Cannot have more than 2 die configs');

		//Remove last die
		delete wrapper.removeDieConfiguration(wrapper.dieConfigurations[2].Id);
		editController.validateRequiredFields(wrapper, new List<String>());
		System.assert(!wrapper.rfqItem.Do_Not_Auto_Price__c);

		//---Die X 2 too large
		wrapper.dieConfigurations[0].put('Die_Size_X__c', 1);
		wrapper.dieConfigurations[0].put('Die_Size_Y__c', 1);
		wrapper.dieConfigurations[1].put('Die_Size_X__c', 2);
		wrapper.dieConfigurations[1].put('Die_Size_Y__c', 1);
		editController.validateRequiredFields(wrapper, new List<String>());
		//Die X 2 cannot be more than .5 above die X 1
		System.assert(wrapper.rfqItem.Do_Not_Auto_Price__c, 'Die X-2 cannot be more than .5 above Die X-1');

		//---Reset item
		wrapper.dieConfigurations[1].put('Die_Size_X__c', 1);
		editController.validateRequiredFields(wrapper, new List<String>());
		System.assert(!wrapper.rfqItem.Do_Not_Auto_Price__c);

		//---Die Y 2 too large
		wrapper.dieConfigurations[1].put('Die_Size_Y__c', 2);
		editController.validateRequiredFields(wrapper, new List<String>());
		//Die Y 2 cannot be more than .5 above die Y 1
		System.assert(wrapper.rfqItem.Do_Not_Auto_Price__c, 'Die Y-2 cannot be more than .5 above Die Y-1');

		//---Reset item
		wrapper.dieConfigurations[1].put('Die_Size_Y__c', 1);
		editController.validateRequiredFields(wrapper, new List<String>());
		System.assert(!wrapper.rfqItem.Do_Not_Auto_Price__c);

		//--Test Forecast validation
		wrapper.specificRfqItem.put('Forecast__c', '0 - 9');
		editController.validateRequiredFields(wrapper, new List<String>());
		System.assert(wrapper.rfqItem.Do_Not_Auto_Price__c, 'Cannot auto-price with this forecast');

		//---Reset item
		wrapper.specificRfqItem.put('Forecast__c', '500 - 749');
		editController.validateRequiredFields(wrapper, new List<String>());
		System.assert(!wrapper.rfqItem.Do_Not_Auto_Price__c);

		//---Adders
		wrapper.specificRfqItem.put('Bake__c', true);
		editController.validateRequiredFields(wrapper, new List<String>());

		//fails because one adder is true
		System.assert(wrapper.rfqItem.Do_Not_Auto_Price__c, 'MLF Cannot have any adders');

		Test.stopTest();
	}



}