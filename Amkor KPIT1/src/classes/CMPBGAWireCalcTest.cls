/*************************************************************************
* 
* PURPOSE: Wire calculation test methods for PBGA product group. 
* The whole test is based on PBGA Cost Model Excel Sheet
*          
* CLASS: CMPBGAWireCalcTest
* CREATED: 06/27/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Chia Yuan Chuang
* 
**************************************************************************/
@isTest
private class CMPBGAWireCalcTest {

	private static RFQItemWrapper setupWireCalcTest(){
		String productGroup = 'PBGA';
		RFQAdminInstaller.install();
		PBGAInstaller.install();
		RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem(productGroup);

		//Setup CMVersion	
		//setupCMVersion(String productGroup, Decimal Wire_Ball_Ratio,  Decimal Wire_Die_Thickness, Decimal Wire_Loop_Height, Decimal Wire_DA_Thickness, Decimal Wire_Paddle_Down) 
		SharedUnitTestUtils.setupCMVersion(productGroup, 1.8, 180.0, 4.0, 0.9, 0.0);
		return wrapper;

	}
	
	private static testmethod void testWireCalculation2DOnly() {

		
		
		RFQItemWrapper wrapper = setupWireCalcTest();
		
		wrapper.wireConfigurations[0].put('Average_2D_Wire_Length__c', 4.32);
		wrapper.wireConfigurations[0].put('Total_3D_Wire_Length__c', 0);
		wrapper.wireConfigurations[0].put('Total_2D_Wire_Length__c', 0);
		wrapper.wireConfigurations[0].put('Wire_Diameter__c','0.8');
		wrapper.wireConfigurations[0].put('Number_Of_Wires__c',150);
		wrapper.wireConfigurations[0].put('Wire_Material__c', 'Au');
		
     	Type t = Type.forName(wrapper.packageFamily.Product_Group__r.Wire_Calculation_Implementation__c);
     	DebugUtils.getInstance().log('pbga wireCalcImplementation', wrapper.packageFamily.Product_Group__r.Wire_Calculation_Implementation__c);
     	CMWireCalcBase wireCalculator = (CMWireCalcBase)t.newInstance();
        wireCalculator.calculate(wrapper);

		Test.startTest();
		Decimal wire3dLength = (Decimal)wrapper.wireConfigurations[0].get('Total_3D_Wire_Length__c');
		Decimal total2Dlength = (Decimal)wrapper.wireConfigurations[0].get('Total_2D_Wire_Length__c');
		Decimal auFactor = (Decimal)wrapper.wireConfigurations[0].get('Au_Factor__c');

		System.assert(Math.abs(wire3dLength - 676.6979342) < 0.000001);
		System.assert(Math.abs(total2Dlength - 648.0000000) < 0.000001);
		System.assert(Math.abs(auFactor - 0.136325941) < 0.000001);
	
		Test.stopTest();
	}


	private static testmethod void testWireCalculation3DOnly() {
		
		RFQItemWrapper wrapper = setupWireCalcTest();
		
		wrapper.wireConfigurations[0].put('Average_2D_Wire_Length__c', 0);
		wrapper.wireConfigurations[0].put('Total_2D_Wire_Length__c', 0);
		wrapper.wireConfigurations[0].put('Total_3D_Wire_Length__c', 676.6979342);
		wrapper.wireConfigurations[0].put('Wire_Diameter__c','0.8');
		wrapper.wireConfigurations[0].put('Number_Of_Wires__c',150);
		wrapper.wireConfigurations[0].put('Wire_Material__c', 'Au');
		
     	Type t = Type.forName(wrapper.packageFamily.Product_Group__r.Wire_Calculation_Implementation__c);
     	CMWireCalcBase wireCalculator = (CMWireCalcBase)t.newInstance();
        wireCalculator.calculate(wrapper);

		Test.startTest();
		//Decimal wire3dLength = (Decimal)wrapper.wireConfigurations[0].get('Total_3D_Wire_Length__c');
		Decimal total2Dlength = (Decimal)wrapper.wireConfigurations[0].get('Total_2D_Wire_Length__c');
		Decimal average2Dlength = (Decimal)wrapper.wireConfigurations[0].get('Average_2D_Wire_Length__c');
		Decimal auFactor = (Decimal)wrapper.wireConfigurations[0].get('Au_Factor__c');

		
		System.assert(Math.abs(total2Dlength - 648.0000000) < 0.000001, total2Dlength);
		System.assert(Math.abs(average2Dlength - 4.32) < 0.000001, average2Dlength);
		System.assert(Math.abs(auFactor - 0.136325941) < 0.000001, auFactor);
	
		Test.stopTest();
	}
}