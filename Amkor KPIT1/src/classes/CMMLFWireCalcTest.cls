/*************************************************************************
* 
* PURPOSE: Wire calculation test methods for Dual Leadframe product group. 
* The whole test is based on Dual Leadframe Cost Model Excel Sheet
*          
* CLASS: CMMLFWireCalcTest
* CREATED: 06/27/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Chia Yuan Chuang
* 
**************************************************************************/
@isTest
private class CMMLFWireCalcTest {

	private static RFQItemWrapper setupWireCalcTest(){
		String productGroup = 'MLF';
		RFQAdminInstaller.install();
		MLFInstaller.install();
		
		CMMLFInstaller.install();

		//get wrapper
		//To Do: Pass the correct pacakge family
		RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('Punch Single Row DFN', 1, 1);
		

		//Setup CMVersion	
		//setupCMVersion(String productGroup, Decimal Wire_Ball_Ratio,  Decimal Wire_Die_Thickness, Decimal Wire_Loop_Height, Decimal Wire_DA_Thickness, Decimal Wire_Paddle_Down) 
		SharedUnitTestUtils.setupCMVersion(productGroup, 1.8, 200.0, 5.0, 1.0, 0.0);
		return wrapper;

	}
	
	private static testmethod void testWireCalculation2DOnly() {

		
		
		RFQItemWrapper wrapper = setupWireCalcTest();
		
		wrapper.wireConfigurations[0].put('Total_3D_Wire_Length__c', 0);
		wrapper.wireConfigurations[0].put('Total_2D_Wire_Length__c', 0);
		wrapper.wireConfigurations[0].put('Average_2D_Wire_Length__c', 2.032);
		wrapper.wireConfigurations[0].put('Wire_Diameter__c','0.8');
		wrapper.wireConfigurations[0].put('Number_Of_Wires__c',12);
		wrapper.wireConfigurations[0].put('Wire_Material__c', 'Au');
		
     	Type t = Type.forName(wrapper.packageFamily.Product_Group__r.Wire_Calculation_Implementation__c);
     	CMWireCalcBase wireCalculator = (CMWireCalcBase)t.newInstance();
        wireCalculator.calculate(wrapper);

        //measurement unit of length is mm
		Test.startTest();
		Decimal wire3dLength = (Decimal)wrapper.wireConfigurations[0].get('Total_3D_Wire_Length__c');
		Decimal total2Dlength = (Decimal)wrapper.wireConfigurations[0].get('Total_2D_Wire_Length__c');
		Decimal auFactor = (Decimal)wrapper.wireConfigurations[0].get('Au_Factor__c');

		System.assert(Math.abs(wire3dLength - 27.2200237) < 0.000001);
		System.assert(Math.abs(total2Dlength - 24.3840000) < 0.000001);		
		System.assert(Math.abs(auFactor - 0.0054837) < 0.000001);
	
		Test.stopTest();
	}


	private static testmethod void testWireCalculation3DOnly() {
		
		RFQItemWrapper wrapper = setupWireCalcTest();
		
		wrapper.wireConfigurations[0].put('Average_2D_Wire_Length__c', 0);
		wrapper.wireConfigurations[0].put('Total_2D_Wire_Length__c', 0);
		wrapper.wireConfigurations[0].put('Total_3D_Wire_Length__c', 27.2200237);
		wrapper.wireConfigurations[0].put('Wire_Diameter__c','0.8');
		wrapper.wireConfigurations[0].put('Number_Of_Wires__c',12);
		wrapper.wireConfigurations[0].put('Wire_Material__c', 'Au');
		
     	Type t = Type.forName(wrapper.packageFamily.Product_Group__r.Wire_Calculation_Implementation__c);
     	CMWireCalcBase wireCalculator = (CMWireCalcBase)t.newInstance();
        wireCalculator.calculate(wrapper);

		Test.startTest();
		//Decimal wire3dLength = (Decimal)wrapper.wireConfigurations[0].get('Total_3D_Wire_Length__c');
		Decimal total2Dlength = (Decimal)wrapper.wireConfigurations[0].get('Total_2D_Wire_Length__c');
		Decimal average2Dlength = (Decimal)wrapper.wireConfigurations[0].get('Average_2D_Wire_Length__c');
		Decimal auFactor = (Decimal)wrapper.wireConfigurations[0].get('Au_Factor__c');

		
		System.assert(Math.abs(total2Dlength - 24.3840000) < 0.000001);
		System.assert(Math.abs(average2Dlength - 2.032) < 0.000001);		
		System.assert(Math.abs(auFactor - 0.0054837) < 0.000001);
	
		Test.stopTest();
	}
}