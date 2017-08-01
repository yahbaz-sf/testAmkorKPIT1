/*************************************************************************
* 
* PURPOSE: Wire calculation test methods for Quad Leadframe product group. 
* The whole test is based on Dual Leadframe Cost Model Excel Sheet,
* Also based on AMK-915, change quad wire calc
*          
* CLASS: CMQuadWireCalcTest
* CREATED: 06/27/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Chia Yuan Chuang
* 
**************************************************************************/
@isTest
private class CMQuadWireCalcTest {

	static String productGroup = 'Quad Leadframe';
	static String packageFamily = 'TQFP';
	private static void setupWireCalcTest(){
		
		RFQAdminInstaller.install();
		QuadLeadframeInstaller.install();
	}
	
	private static testmethod void testWireCalculation2DOnly() {

		setupWireCalcTest();
		

		//MLFInstaller has a lot of SOQL queries
		//Need clean up here
		Test.startTest();
		CMQuadInstaller.install();

		//get wrapper
		RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('TQFP', 1, 1);
		//RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem(productGroup);

		//Setup CMVersion	
		//setupCMVersion(String productGroup, Decimal Wire_Ball_Ratio,  Decimal Wire_Die_Thickness, Decimal Wire_Loop_Height, Decimal Wire_DA_Thickness, Decimal Wire_Paddle_Down) 
		SharedUnitTestUtils.setupCMVersion(productGroup, 1.8, 200.0, 5.0, 1.0, 0.0);
		
		wrapper.wireConfigurations[0].put('Average_2D_Wire_Length__c', 0);
		wrapper.wireConfigurations[0].put('Total_2D_Wire_Length__c', 0);
		wrapper.wireConfigurations[0].put('Total_2D_Wire_Length__c', 18.00);
		wrapper.wireConfigurations[0].put('Wire_Diameter__c','1.0');
		wrapper.wireConfigurations[0].put('Number_Of_Wires__c',16);
		wrapper.wireConfigurations[0].put('Wire_Material__c', 'Au');
		
     	Type t = Type.forName(wrapper.packageFamily.Product_Group__r.Wire_Calculation_Implementation__c);
     	CMWireCalcBase wireCalculator = (CMWireCalcBase)t.newInstance();
        wireCalculator.calculate(wrapper);

        //measurement unit of length is mm
		
		Decimal wire3dLength = (Decimal)wrapper.wireConfigurations[0].get('Total_3D_Wire_Length__c');
		Decimal average2Dlength = (Decimal)wrapper.wireConfigurations[0].get('Average_2D_Wire_Length__c');
		Decimal auFactor = (Decimal)wrapper.wireConfigurations[0].get('Au_Factor__c');

		System.debug(LoggingLevel.ERROR, '##### Aufactor 2D to 3D' + auFactor);
		System.assert(Math.abs(wire3dLength - 22.4745209) < 0.000001);
		System.assert(Math.abs(average2Dlength - 1.1250000) < 0.000001);		
		System.assert(Math.abs(auFactor - 0.0070745) < 0.000001);

	
		Test.stopTest();
	}


	private static testmethod void testWireCalculation3DOnly() {

		setupWireCalcTest();
		
		//MLFInstaller has a lot of SOQL querie
		//Need clean up here
		Test.startTest();
		CMQuadInstaller.install();

		//get wrapper
		RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('TQFP', 1, 1);
		//RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem(productGroup);

		//Setup CMVersion	
		//setupCMVersion(String productGroup, Decimal Wire_Ball_Ratio,  Decimal Wire_Die_Thickness, Decimal Wire_Loop_Height, Decimal Wire_DA_Thickness, Decimal Wire_Paddle_Down) 
		SharedUnitTestUtils.setupCMVersion(productGroup, 1.8, 200.0, 5.0, 1.0, 0.0);

		wrapper.wireConfigurations[0].put('Average_2D_Wire_Length__c', 0);
		wrapper.wireConfigurations[0].put('Total_2D_Wire_Length__c', 0);
		wrapper.wireConfigurations[0].put('Total_3D_Wire_Length__c', 22.4745209);
		wrapper.wireConfigurations[0].put('Wire_Diameter__c','1.0');
		wrapper.wireConfigurations[0].put('Number_Of_Wires__c',16);
		wrapper.wireConfigurations[0].put('Wire_Material__c', 'Au');
		
     	Type t = Type.forName(wrapper.packageFamily.Product_Group__r.Wire_Calculation_Implementation__c);
     	CMWireCalcBase wireCalculator = (CMWireCalcBase)t.newInstance();
        wireCalculator.calculate(wrapper);

		
		//Decimal wire3dLength = (Decimal)wrapper.wireConfigurations[0].get('Total_3D_Wire_Length__c');
		Decimal total2Dlength = (Decimal)wrapper.wireConfigurations[0].get('Total_2D_Wire_Length__c');
		Decimal average2Dlength = (Decimal)wrapper.wireConfigurations[0].get('Average_2D_Wire_Length__c');
		Decimal auFactor = (Decimal)wrapper.wireConfigurations[0].get('Au_Factor__c');

		System.debug(LoggingLevel.ERROR, '##### Aufactor 2D to 3D' + auFactor);
		System.assert(Math.abs(total2Dlength - 18.00) < 0.000001);
		System.assert(Math.abs(average2Dlength - 1.125) < 0.000001);		
		System.assert(Math.abs(auFactor - 0.0070745) < 0.000001);
	
		Test.stopTest();
	}
}