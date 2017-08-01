/*************************************************************************
* 
* PURPOSE:  this class seeds fresh RFQ Item Field Definition specifically
*           for the Service package families (cloned from SOIC150Installer
*           for the purposes of generalization)
*         
* CLASS: ServiceInstaller
* CREATED: 05/09/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Raghuveer Mandali
* 
**************************************************************************/
@isTest
public with sharing class CMQuadBOMCalcTest {

	public static CMQuadBuilder QuadCalc;
	public static DebugUtils debug {get {return DebugUtils.getInstance();} }

	public static testMethod void testBOM1()
	{
		RFQItemWrapper wrapper = setupQuadLineItem();
		Test.startTest();
		setupWrapper(wrapper, '7x7', '48', '', '', 
					3.1, 3.1, 
					4.0, 5.0, 
					6, 8, '0.8', 14, 'Cu',
					12, 14, '1.0', 15, 'Au');

		QuadCalc.calculateNew(wrapper, new CMSettings());

		Decimal lf, ep1, ep2, wire1, wire2, mold;
		for (RFQI_BOM__c row : [select Id, Name, Material_Cost_Per_Unit__c from RFQI_BOM__c where RFQI_FCM__r.RFQ_Item__c =: wrapper.rfqItem.Id])
		{
			debug.log('row.name', row.name);
			debug.log('row.Material_Cost_Per_Unit__c', row.Material_Cost_Per_Unit__c);
			if (row.Name == 'LF 7x7') lf = row.Material_Cost_Per_Unit__c;
			else if (row.Name == 'EP1') ep1 = row.Material_Cost_Per_Unit__c;
			else if (row.Name == 'EP2') ep2 = row.Material_Cost_Per_Unit__c;
			else if (row.Name == 'Au 1.0') wire1 = row.Material_Cost_Per_Unit__c;
			else if (row.Name == 'WU-Cu') wire2 = row.Material_Cost_Per_Unit__c;
			else if (row.Name == 'MC 7x7') mold = row.Material_Cost_Per_Unit__c;
		}
		System.assert(Math.abs(lf - 0.0227475) < 0.0000001, lf);
		System.assert(Math.abs(ep1 - 0.0016457252) < 0.0000001, ep1);
		System.assert(Math.abs(ep2 - 0.0038857923) < 0.0000001, ep2);
		System.assert(Math.abs(mold - 0.007287517) < 0.0000001, mold);
		Test.stopTest();
	}

	public static testMethod void testEpad()
	{
		RFQItemWrapper wrapper = setupQuadLineItem();
		Test.startTest();

		setupWrapper(wrapper, '7x7', '48', '', 'epad', 
					3.1, 3.1, 
					4.0, 5.0, 
					6, 8, '0.8', 14, 'Cu',
					12, 14, '1.0', 15, 'Au');

		QuadCalc.calculateNew(wrapper, new CMSettings());

		Decimal lf, ep1, ep2, wire1, wire2, mold;
		for (RFQI_BOM__c row : [select Id, Name, Material_Cost_Per_Unit__c from RFQI_BOM__c where RFQI_FCM__r.RFQ_Item__c =: wrapper.rfqItem.Id])
		{
			debug.log('row.name', row.name);
			debug.log('row.Material_Cost_Per_Unit__c', row.Material_Cost_Per_Unit__c);
			if (row.Name == 'LF 7x7') lf = row.Material_Cost_Per_Unit__c;
			else if (row.Name == 'EP1') ep1 = row.Material_Cost_Per_Unit__c;
			else if (row.Name == 'EP2') ep2 = row.Material_Cost_Per_Unit__c;
			else if (row.Name == 'Au 1.0') wire1 = row.Material_Cost_Per_Unit__c;
			else if (row.Name == 'WU-Cu') wire2 = row.Material_Cost_Per_Unit__c;
			else if (row.Name == 'MC 7x7') mold = row.Material_Cost_Per_Unit__c;
		}
		System.assert(Math.abs(lf - 0.02320245) < 0.0000001, lf);
		System.assert(Math.abs(ep1 - 0.0016457252) < 0.0000001, ep1);
		System.assert(Math.abs(ep2 - 0.0038857923) < 0.0000001, ep2);
		System.assert(Math.abs(mold - 0.007287517) < 0.0000001, mold);
		Test.stopTest();

	}

	public static testMethod void testPPF()
	{
		RFQItemWrapper wrapper = setupQuadLineItem();
		Test.startTest();

		setupWrapper(wrapper, '7x7', '48', 'Roughened PPF', '', 
					3.1, 3.1, 
					4.0, 5.0, 
					6, 8, '0.8', 14, 'Cu',
					12, 14, '1.0', 15, 'Au');

		QuadCalc.calculateNew(wrapper, new CMSettings());

		Decimal lf, ep1, ep2, wire1, wire2, mold;
		for (RFQI_BOM__c row : [select Id, Name, Material_Cost_Per_Unit__c from RFQI_BOM__c where RFQI_FCM__r.RFQ_Item__c =: wrapper.rfqItem.Id])
		{
			debug.log('row.name', row.name);
			debug.log('row.Material_Cost_Per_Unit__c', row.Material_Cost_Per_Unit__c);
			if (row.Name == 'LF 7x7') lf = row.Material_Cost_Per_Unit__c;
			else if (row.Name == 'EP1') ep1 = row.Material_Cost_Per_Unit__c;
			else if (row.Name == 'EP2') ep2 = row.Material_Cost_Per_Unit__c;
			else if (row.Name == 'Au 1.0') wire1 = row.Material_Cost_Per_Unit__c;
			else if (row.Name == 'WU-Cu') wire2 = row.Material_Cost_Per_Unit__c;
			else if (row.Name == 'MC 7x7') mold = row.Material_Cost_Per_Unit__c;
		}
		System.assert(Math.abs(lf - 0.023884875) < 0.0000001, lf);
		System.assert(Math.abs(ep1 - 0.0016457252) < 0.0000001, ep1);
		System.assert(Math.abs(ep2 - 0.0038857923) < 0.0000001, ep2);
		System.assert(Math.abs(mold - 0.007287517) < 0.0000001, mold);

		Test.stopTest();
	}

	private static RFQItemWrapper setupQuadLineItem()
	{
		RFQAdminInstaller.install();
		RFQAdminInstaller.installFactories();

		QuadLeadframeInstaller.install();
		CMQuadInstaller.install();
		CMQuadInstaller.incrementalInstall1();

		return SharedUnitTestUtils.createLineItem('TQFP', 2, 2);
	}

	private static void setupWrapper(RFQItemWrapper wrapper, String bodySize, String leadCount, String lfFinish, String lfConfig,
									Decimal die1X, Decimal die1Y, 
									Decimal die2X, Decimal die2Y, 
									Integer fwdWires1, Integer ssbWires1, String wireSize1, Decimal tot2D1, String wireMaterial1,
									Integer fwdWires2, Integer ssbWires2, String wireSize2, Decimal tot2D2, String wireMaterial2)
	{
		wrapper.setAttribute('Body_Size__c', RFQItemWrapper.PACKAGE_OBJECT, bodySize);
		wrapper.setAttribute('Lead_Count__c', RFQItemWrapper.PACKAGE_OBJECT, leadCount);
		if (lfFinish != '') wrapper.setAttribute('Leadframe_Finish__c', RFQItemWrapper.PACKAGE_OBJECT, lfFinish);
		if (lfConfig != '') wrapper.setAttribute('Leadframe_Config__c', RFQItemWrapper.PACKAGE_OBJECT, lfConfig);


		wrapper.dieConfigurations[0].put('Die_Size_X__c', die1X);
		wrapper.dieConfigurations[0].put('Die_Size_Y__c', die1Y);
		wrapper.dieConfigurations[1].put('Die_Size_X__c', die2X);
		wrapper.dieConfigurations[1].put('Die_Size_Y__c', die2Y);

		wrapper.wireConfigurations[0].put('Number_of_FWD_Wires__c', fwdWires1);
		wrapper.wireConfigurations[0].put('Number_of_SSB_Wires__c', ssbWires1);
		wrapper.wireConfigurations[0].put('Wire_Diameter__c', wireSize1);
		wrapper.wireConfigurations[0].put('Total_2D_Wire_Length__c', tot2D1);
		wrapper.wireConfigurations[0].put('Wire_Material__c', wireMaterial1);

		wrapper.wireConfigurations[1].put('Number_of_FWD_Wires__c', fwdWires2);
		wrapper.wireConfigurations[1].put('Number_of_SSB_Wires__c', ssbWires2);
		wrapper.wireConfigurations[1].put('Wire_Diameter__c', wireSize2);
		wrapper.wireConfigurations[1].put('Total_2D_Wire_Length__c', tot2D2);
		wrapper.wireConfigurations[1].put('Wire_Material__c', wireMaterial2);

		Type t = Type.forName(wrapper.productGroup.Cost_Model_Implementation__c);
    	QuadCalc = (CMQuadBuilder)t.newInstance();

	}
}