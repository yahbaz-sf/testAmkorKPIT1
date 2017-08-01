/*************************************************************************
*
* PURPOSE: Test for Quad Builder
*
* CLASS: CMQuadBuilderTest
* CREATED: 8/7/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Austin Delorme
***************************************************************************/
@isTest
public with sharing class CMQuadBuilderTest {
	private static  testmethod void testPackageValue(){
		
		Decimal buPriceExpected = 0.169824194228;
		Decimal packageValueExpected = 63.6840728356233;
		 
		
		RFQItemWrapper wrapper = setUpQuadLeadframe();
		
		
		//setup Quote information
		setupQuoteInformation(wrapper, '< 500');
		//Setup Package description
		setupPackage(wrapper, 'P1', '7x7', '48');
		//Setup wire
		setupWire(wrapper, 'Au', '0.8', 48.0, 48.0, 1.6);
		//Setup die
	
		List<Decimal> dieX = new List<Decimal>();
		List<Decimal> dieY = new List<Decimal>();
		
		dieX.add(3.1);
		dieY.add(3.1);
		setupDie(wrapper, 1, dieX, dieY);
		
		//instantiate a wire calculator
		Type t = Type.forName(wrapper.productGroup.Wire_Calculation_Implementation__c);		
		CMWireCalcBase wireCalculator = (CMWireCalcBase)t.newInstance();
        wireCalculator.calculate(wrapper);
		
		//instantiate a cost model
		t = Type.forName(wrapper.productGroup.Cost_Model_Implementation__c);				
    	CMFCMBuilderBase QuadLeadframeCM = (CMFCMBuilderBase)t.newInstance();    	
    	    	
    	Test.startTest();
    	QuadLeadframeCM.calculateNew(wrapper, new CMSettings());    	    	

    	Decimal buPrice = (Decimal)wrapper.specificRfqItem.get('BU_Price__c');
    	Decimal packageValue = (Decimal)wrapper.specificRfqItem.get('Package_Item_Value__c');


		System.assert(Math.abs(buPrice - buPriceExpected) < 0.0000001, buPrice);
		System.assert(Math.abs(packageValue - packageValueExpected) < 0.0000001, packageValue);
		Test.stopTest();		
	}

	private static  testmethod void testMultiVolume(){
		
		Decimal buPriceExpected = 0.169824194228;
		
		RFQItemWrapper wrapper = setUpQuadLeadframe();
		
		
		//setup Quote information
		setupQuoteInformation(wrapper, '< 100');
		//Setup Package description
		setupPackage(wrapper, 'P1', '7x7', '48');
		//Setup wire
		setupWire(wrapper, 'Au', '0.8', 48.0, 48.0, 1.6);
		//Setup die
	
		List<Decimal> dieX = new List<Decimal>();
		List<Decimal> dieY = new List<Decimal>();
		
		dieX.add(3.1);
		dieY.add(3.1);
		setupDie(wrapper, 1, dieX, dieY);

		//add new volume
		RFQMultiVolumeSectionController volumeCont = new RFQMultiVolumeSectionController();
		volumeCont.cWrapper = wrapper;
		volumeCont.addVolume();

		wrapper.volumeList[0].volume = '< 500';
		
		//instantiate a wire calculator
		Type t = Type.forName(wrapper.productGroup.Wire_Calculation_Implementation__c);		
		CMWireCalcBase wireCalculator = (CMWireCalcBase)t.newInstance();
        wireCalculator.calculate(wrapper);
		
		//instantiate a cost model
		t = Type.forName(wrapper.productGroup.Cost_Model_Implementation__c);				
    	CMFCMBuilderBase QuadLeadframeCM = (CMFCMBuilderBase)t.newInstance();    	
    	    	
    	Test.startTest();
    	QuadLeadframeCM.calculateNew(wrapper, new CMSettings());    	    	

    	Decimal buPrice = (Decimal)wrapper.volumeList[0].price;

		System.assert(buPrice.setScale(6) - buPriceExpected.setScale(6) == 0, buPrice);
		Test.stopTest();		
	}

	static private RFQItemWrapper setUpQuadLeadframe(){
		
		RFQAdminInstaller.install();
		RFQAdminInstaller.installFactories();
		RFQAdminInstaller.installAccounts();
		
		QuadLeadframeInstaller.install();				
		CMQuadInstaller.install();
		
		//get wrapper
		RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('TQFP', 1, 1);
		wrapper.packageFamily.Copy_Fields_To_multivolume__c = true;
		
				
		return wrapper;
	}

	static private void setupQuoteInformation(RFQItemWrapper wrapper, String Forecast){
		wrapper.setAttribute('Forecast__c', 'Package', Forecast);
	}

	static private void setupPackage(RFQItemWrapper wrapper, String location, String bodySize, String Lead_Count){
		
		System.debug(LoggingLevel.ERROR, '#### start config package');
		
		if(location != null){
			Factory__c factory = [Select Name, id From Factory__c where Name =: location];
			wrapper.setAttribute('Factory__c', 'Package', factory.Id);
		}
		
		wrapper.setAttribute('Body_Size__c', 'Package', bodySize);
		wrapper.setAttribute('Lead_Count__c', 'Package', Lead_Count);					
	}
	
	static private void setupDie(RFQItemWrapper wrapper, Integer Num_of_Die, List<Decimal> dieX, List<Decimal> dieY){
			
		for(Integer i = 0; i < Num_of_Die; i++){
			wrapper.dieConfigurations[i].put('Die_Size_X__c', dieX[i]);
			wrapper.dieConfigurations[i].put('Die_Size_Y__c', dieY[i]);
		}
	}
	
	static private void setupWire(RFQItemWrapper wrapper, String Wire_Material, String Wire_Diameter, Decimal Number_Of_Wires, Decimal numberFwdWires, Decimal Total_2D_Wire_Length){
		
		wrapper.wireConfigurations[0].put('Wire_Material__c',Wire_Material);
		wrapper.wireConfigurations[0].put('Wire_Diameter__c',  Wire_Diameter);
		wrapper.wireConfigurations[0].put('Number_Of_Wires__c',Number_Of_Wires);
		wrapper.wireConfigurations[0].put('Number_Of_FWD_Wires__c',numberFwdWires);
		wrapper.wireConfigurations[0].put('Total_2D_Wire_Length__c',Total_2D_Wire_Length);
		
	}
}