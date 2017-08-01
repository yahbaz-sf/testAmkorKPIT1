/*************************************************************************
* 
* PURPOSE:  This is a Test Class for the CMMLFBUilder class
			
*         
* CLASS: CMMLFBuilderTest
* CREATED: 08/07/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Chia Yuan Chuang
* 
**************************************************************************/

@isTest
private  class CMMLFBuilderTest {

	static Integer Num_of_Wire;
	static Integer Num_of_Die;
	private static  testmethod void testPunchMLF(){

		//AMK-2064 changed unitsPerStrip calc, changed price
		//Decimal Total_Material_Cost_Expected = 0.0521;
		//Decimal Total_CLAM_Expected = 0.1594;
		//Decimal Total_Cost_of_Goods_Expected = 0.2115;
		//Decimal buPrice_Expected = 0.2938;

		//AMK-2004 changed forecast, changed price
		//Decimal Total_Material_Cost_Expected = 0.0486;
		//Decimal Total_CLAM_Expected = 0.1567;
		//Decimal Total_Cost_of_Goods_Expected = 0.2053;
		//Decimal buPrice_Expected = 0.2851;

		Decimal Total_Material_Cost_Expected = 0.0486;
		Decimal Total_CLAM_Expected = 0.1567;
		Decimal Total_Cost_of_Goods_Expected = 0.2053;
		Decimal buPrice_Expected = 0.2737;

		String packageFamily = 'Punch Single Row DFN';
		RFQItemWrapper wrapper = setupMLF(packageFamily, 3, 2);

		//setup Quote information
		setupQuoteInoformation(wrapper, '200 - 499');
		//Setup Package description
		setupPackage(wrapper, 'C3', 'Ag Plate', '03x03');
		
		//Setup wire
		
		List<String>  Wire_Configuration 	= new List<String>();
		List<String>  Wire_Material 		= new List<String>();
		List<String>  Wire_Diameter 		= new List<String>();
		List<Decimal> Number_Of_Wires 		= new List<Decimal>();
		List<Decimal> Total_2D_Wire_Length  = new List<Decimal>();
		List<Decimal> Average_2D_Wire_Length  = new List<Decimal>();
		//Add wire 1 
		
		Wire_Configuration.add('Forward Bonding'); 	
		//Lalit SF-85.
		Wire_Material.add('AuPCC'); 		
		Wire_Diameter.add('0.8'); 		
		Number_Of_Wires.add(214); 		
		Average_2D_Wire_Length.add(1.016);		

		//Add wire 2 
		
		Wire_Configuration.add('Reverse Stand off Stitch Bond (RSSB)'); 	
		//Lalit SF-85.
		Wire_Material.add('AuPCC'); 		
		Wire_Diameter.add('0.8'); 		
		Number_Of_Wires.add(100); 		
		Average_2D_Wire_Length.add(1.7272);		

		//Add wire 3
		Wire_Configuration.add('Stand off Stitch Bond (SSB)'); 	
		Wire_Material.add('Au'); 		
		Wire_Diameter.add('0.8'); 		
		Number_Of_Wires.add(12); 				
		Average_2D_Wire_Length.add(2.032);

		setupWire(wrapper, Wire_Configuration, Wire_Material, Wire_Diameter,Number_Of_Wires, Average_2D_Wire_Length);
		//Setup die
		
		List<String> Die_Attach = new List<String>();
		List<String> Wafer_Material = new List<String>();
		List<String> Wafer_Size = new List<String>();
		List<String> Wafer_Technology = new List<String>();
		List<String> Wafer_Thickness = new List<String>();
		List<Decimal> Die_Size_X = new List<Decimal>();
		List<Decimal> Die_Size_Y = new List<Decimal>();
		
		//Die 1
		Die_Attach.add('epoxy conductive');
		Wafer_Material.add('Silicon');
		Wafer_Size.add('300');
		Wafer_Technology.add('55');
		Wafer_Thickness.add('0.75');
		Die_Size_X.add(1.2);
		Die_Size_Y.add(1);

		//Die 2
		Die_Attach.add('epoxy conductive');
		Wafer_Material.add('Silicon');
		Wafer_Size.add('300');
		Wafer_Technology.add('55');
		Wafer_Thickness.add('0.75');
		Die_Size_X.add(1.5);
		Die_Size_Y.add(0.8);
		setupDie(wrapper, Die_Attach, Wafer_Material, Wafer_Size, Wafer_Technology, Wafer_Thickness, Die_Size_X, Die_Size_Y);
		
		//instantiate a wire calculator
		Type t = Type.forName(wrapper.packageFamily.Product_Group__r.Wire_Calculation_Implementation__c);		
		CMWireCalcBase wireCalculator = (CMWireCalcBase)t.newInstance();
        wireCalculator.calculate(wrapper);
        

        t = Type.forName(wrapper.packageFamily.Product_Group__r.Cost_Model_Implementation__c);				
    	CMFCMBuilderBase mlfBuilder = (CMFCMBuilderBase)t.newInstance();    	
    	
    	
    	Test.startTest();

    	mlfBuilder.calculateNew(wrapper, new CMSettings());    	    	
    	System.debug(LoggingLevel.ERROR, '###### bu margin: ' + mlfBuilder.itemFcm.Margin_Percent__c);
    	//Bom calc
    	Decimal Total_Material_Cost = mlfBuilder.itemFcm.Total_Material_Cost__c;    	
    	System.assert(Math.abs(Total_Material_Cost - Total_Material_Cost_Expected) < 0.0001, 'Total Material failed! ' + 'calculated value is ' + Total_Material_Cost.setScale(4));    	    	    	

    	//prcess calc
    	Decimal Total_CLAM_Cost = mlfBuilder.itemFcm.CLAM__c;
    	System.assert(Math.abs(Total_CLAM_Cost - Total_CLAM_Expected) < 0.0001,	'Total CLAM failed! ' 		+ 'calculated value is ' + Total_CLAM_Cost.setScale(4));
    	
    	
    	//test total cost
		Decimal Total_Cost_of_Goods = mlfBuilder.itemFcm.Total_Cost_of_Goods__c;    	
    	System.assert(Math.abs(Total_Cost_of_Goods - Total_Cost_of_Goods_Expected) < 0.0001, 'Total Cost of Goods failed! ' + ' calulated value is ' + Total_Cost_of_Goods.setScale(4));

    	//test bu Price
		Decimal buPrice = mlfBuilder.itemFcm.Total_Price__c;    	
    	System.assert(Math.abs(buPrice - buPrice_Expected) < 0.0001, 'buPrice failed! ' + ' calulated value is ' + buPrice.setScale(4));


    	//To Do: calculate all and displayResults
		
		Test.stopTest();		

	}

	private static  testmethod void testPunchMLFMultiVolume(){

		//AMK-2004 changed forecast, changed price
		//Decimal Total_Material_Cost_Expected = 0.0486;
		//Decimal Total_CLAM_Expected = 0.1567;
		//Decimal Total_Cost_of_Goods_Expected = 0.2053;
		//Decimal buPrice_Expected = 0.2851;

		Decimal Total_Material_Cost_Expected = 0.0486;
		Decimal Total_CLAM_Expected = 0.1567;
		Decimal Total_Cost_of_Goods_Expected = 0.2053;
		Decimal buPrice_Expected = 0.2737;

		String packageFamily = 'Punch Single Row DFN';
		RFQItemWrapper wrapper = setupMLF(packageFamily, 3, 2);

		//setup Quote information
		setupQuoteInoformation(wrapper, '500 - 749');
		//Setup Package description
		setupPackage(wrapper, 'C3', 'Ag Plate', '03x03');
		
		//Setup wire
		
		List<String>  Wire_Configuration 	= new List<String>();
		List<String>  Wire_Material 		= new List<String>();
		List<String>  Wire_Diameter 		= new List<String>();
		List<Decimal> Number_Of_Wires 		= new List<Decimal>();
		List<Decimal> Total_2D_Wire_Length  = new List<Decimal>();
		List<Decimal> Average_2D_Wire_Length  = new List<Decimal>();
		//Add wire 1 
		
		Wire_Configuration.add('Forward Bonding'); 	
		//Lalit SF-85.
		Wire_Material.add('AuPCC'); 		
		Wire_Diameter.add('0.8'); 		
		Number_Of_Wires.add(214); 		
		Average_2D_Wire_Length.add(1.016);		

		//Add wire 2 
		
		Wire_Configuration.add('Reverse Stand off Stitch Bond (RSSB)'); 	
		//Lalit SF-85.
		Wire_Material.add('AuPCC'); 		
		Wire_Diameter.add('0.8'); 		
		Number_Of_Wires.add(100); 		
		Average_2D_Wire_Length.add(1.7272);		

		//Add wire 3
		Wire_Configuration.add('Stand off Stitch Bond (SSB)'); 	
		Wire_Material.add('Au'); 		
		Wire_Diameter.add('0.8'); 		
		Number_Of_Wires.add(12); 				
		Average_2D_Wire_Length.add(2.032);

		setupWire(wrapper, Wire_Configuration, Wire_Material, Wire_Diameter,Number_Of_Wires, Average_2D_Wire_Length);
		//Setup die
		
		List<String> Die_Attach = new List<String>();
		List<String> Wafer_Material = new List<String>();
		List<String> Wafer_Size = new List<String>();
		List<String> Wafer_Technology = new List<String>();
		List<String> Wafer_Thickness = new List<String>();
		List<Decimal> Die_Size_X = new List<Decimal>();
		List<Decimal> Die_Size_Y = new List<Decimal>();
		
		//Die 1
		Die_Attach.add('epoxy conductive');
		Wafer_Material.add('Silicon');
		Wafer_Size.add('300');
		Wafer_Technology.add('55');
		Wafer_Thickness.add('0.75');
		Die_Size_X.add(1.2);
		Die_Size_Y.add(1);

		//Die 2
		Die_Attach.add('epoxy conductive');
		Wafer_Material.add('Silicon');
		Wafer_Size.add('300');
		Wafer_Technology.add('55');
		Wafer_Thickness.add('0.75');
		Die_Size_X.add(1.5);
		Die_Size_Y.add(0.8);
		setupDie(wrapper, Die_Attach, Wafer_Material, Wafer_Size, Wafer_Technology, Wafer_Thickness, Die_Size_X, Die_Size_Y);
		

		//setup multi volume
		//add new volume
		RFQMultiVolumeSectionController volumeCont = new RFQMultiVolumeSectionController();
		volumeCont.cWrapper = wrapper;
		volumeCont.addVolume();

		wrapper.volumeList[0].volume = '200 - 499';

		//instantiate a wire calculator
		Type t = Type.forName(wrapper.packageFamily.Product_Group__r.Wire_Calculation_Implementation__c);		
		CMWireCalcBase wireCalculator = (CMWireCalcBase)t.newInstance();
        wireCalculator.calculate(wrapper);
        

        t = Type.forName(wrapper.packageFamily.Product_Group__r.Cost_Model_Implementation__c);				
    	CMFCMBuilderBase mlfBuilder = (CMFCMBuilderBase)t.newInstance();    	
    	
    	
    	Test.startTest();

    	mlfBuilder.calculateNew(wrapper, new CMSettings());    	    	

    	//test bu Price
		Decimal volumePrice = wrapper.volumeList[0].price;    	
    	System.assert(Math.abs(volumePrice - buPrice_Expected) < 0.0001, 'buPrice failed! ' + ' calulated value is ' + volumePrice.setScale(4));


    	//To Do: calculate all and displayResults
		
		Test.stopTest();		

	}

	private static  testmethod void testSawMLF(){

		//AMK-2004 changed forecast, changed price
		//Decimal Total_Material_Cost_Expected = 0.0802;
		//Decimal Total_CLAM_Expected = 0.0202;
		//Decimal Total_Cost_of_Goods_Expected = 0.1003;
		//Decimal buPrice_Expected = 0.1338;

		Decimal Total_Material_Cost_Expected = 0.0735;
		Decimal Total_CLAM_Expected = 0.0179;
		Decimal Total_Cost_of_Goods_Expected = 0.0914;
		Decimal buPrice_Expected = 0.1219;

		String packageFamily = 'Saw Single Row DFN';
		RFQItemWrapper wrapper = setupMLF(packageFamily, 1, 2);

		//setup Quote information
		setupQuoteInoformation(wrapper, '200 - 499');
		//Setup Package description
		setupPackage(wrapper, 'P3', 'Ag Plate', '05x06');
		
		//Setup wire
		
		List<String>  Wire_Configuration 	= new List<String>();
		List<String>  Wire_Material 		= new List<String>();
		List<String>  Wire_Diameter 		= new List<String>();
		List<Decimal> Number_Of_Wires 		= new List<Decimal>();
		List<Decimal> Total_2D_Wire_Length  = new List<Decimal>();
		List<Decimal> Average_2D_Wire_Length  = new List<Decimal>();
		//Add wire 1 
		
		Wire_Configuration.add('Forward Bonding'); 	
		Wire_Material.add('Au'); 		
		Wire_Diameter.add('1.2'); 		
		Number_Of_Wires.add(48); 		
		Average_2D_Wire_Length.add(1.47108);		

		
		setupWire(wrapper, Wire_Configuration, Wire_Material, Wire_Diameter,Number_Of_Wires, Average_2D_Wire_Length);
		//Setup die
		
		List<String> Die_Attach = new List<String>();
		List<String> Wafer_Material = new List<String>();
		List<String> Wafer_Size = new List<String>();
		List<String> Wafer_Technology = new List<String>();
		List<String> Wafer_Thickness = new List<String>();
		List<Decimal> Die_Size_X = new List<Decimal>();
		List<Decimal> Die_Size_Y = new List<Decimal>();
		
		//Die 1
		Die_Attach.add('epoxy conductive');
		Wafer_Material.add('Silicon');
		Wafer_Size.add('200');
		Wafer_Technology.add('55');
		Wafer_Thickness.add('0.75');
		Die_Size_X.add(2.5);
		Die_Size_Y.add(2.5);

		//Die 2
		Die_Attach.add('epoxy conductive');
		Wafer_Material.add('Silicon');
		Wafer_Size.add('200');
		Wafer_Technology.add('55');
		Wafer_Thickness.add('0.75');
		Die_Size_X.add(1.0);
		Die_Size_Y.add(1.0);
		setupDie(wrapper, Die_Attach, Wafer_Material, Wafer_Size, Wafer_Technology, Wafer_Thickness, Die_Size_X, Die_Size_Y);
		
		//instantiate a wire calculator
		Type t = Type.forName(wrapper.packageFamily.Product_Group__r.Wire_Calculation_Implementation__c);		
		CMWireCalcBase wireCalculator = (CMWireCalcBase)t.newInstance();
        wireCalculator.calculate(wrapper);
        

        t = Type.forName(wrapper.packageFamily.Product_Group__r.Cost_Model_Implementation__c);				
    	CMFCMBuilderBase mlfBuilder = (CMFCMBuilderBase)t.newInstance();    	
    	
    	
    	Test.startTest();

    	mlfBuilder.calculateAll(wrapper, true, new CMSettings());    	    	
    	System.debug(LoggingLevel.ERROR, '###### bu margin: ' + mlfBuilder.itemFcm.Margin_Percent__c);
    	//Bom calc
    	Decimal Total_Material_Cost = mlfBuilder.itemFcm.Total_Material_Cost__c;    	
    	System.assert(Math.abs(Total_Material_Cost - Total_Material_Cost_Expected) < 0.0001, 'Total Material failed! ' + 'calculated value is ' + Total_Material_Cost.setScale(4));    	    	    	

    	//prcess calc
    	Decimal Total_CLAM_Cost = mlfBuilder.itemFcm.CLAM__c;
    	System.assert(Math.abs(Total_CLAM_Cost - Total_CLAM_Expected) < 0.0001,	'Total CLAM failed! ' 		+ 'calculated value is ' + Total_CLAM_Cost.setScale(4));
    	
    	
    	//test total cost
		Decimal Total_Cost_of_Goods = mlfBuilder.itemFcm.Total_Cost_of_Goods__c;    	
    	System.assert(Math.abs(Total_Cost_of_Goods - Total_Cost_of_Goods_Expected) < 0.0001, 'Total Cost of Goods failed! ' + ' calulated value is ' + Total_Cost_of_Goods.setScale(4));

    	//test bu Price
		Decimal buPrice = mlfBuilder.itemFcm.Total_Price__c;    	
    	System.assert(Math.abs(buPrice - buPrice_Expected) < 0.0001, 'buPrice failed! ' + ' calulated value is ' + buPrice.setScale(4));


    	//To Do: calculate all and displayResults
		
		Test.stopTest();		

	}

	static private RFQItemWrapper setupMLF(String packageFamily, Integer numWires, Integer numDies){
		
		RFQAdminInstaller.install();
		RFQAdminInstaller.installFactories();
		
		MLFInstaller.install();
		CMMLFInstaller.install();				

		//get wrapper
		Num_of_Wire = numWires;
		Num_of_Die = numDies;	
		RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem(packageFamily, Num_of_Wire, Num_of_Die);
		wrapper.packageFamily.Copy_Fields_To_multivolume__c = true;
		
		return wrapper;
		
	}



	static private void setupPackage(RFQItemWrapper wrapper, String location, String Frame_Finish, String Body_Size){
		
		System.debug(LoggingLevel.ERROR, '#### start config package');
		
		if(location != null){
			Factory__c factory = [Select Name, id From Factory__c where Name =: location];
			wrapper.setAttribute('Factory__c', 'Package', factory.Id);
		}
		wrapper.setAttribute('Frame_Finish__c', 'Package', Frame_Finish);						
		wrapper.setAttribute('Body_Size__c', 'Package', Body_Size);		
				
		//wrapper.setAttribute('Standard_Rough_Leadframe__c', 'Package', Standard_Rough_Leadframe);		
		//wrapper.setAttribute('Additional_Components_In_Package__c', 'Package', Additional_Components_In_Package);
		
		System.debug(LoggingLevel.ERROR, '#### end config package');					
		
	}
	
	static private void setupDie(RFQItemWrapper wrapper, List<String> Die_Attach,List<String> Wafer_Material,List<String> Wafer_Size, List<String> Wafer_Technology,List<String> Wafer_Thickness, List<Decimal> Die_Size_X, List<Decimal> Die_Size_Y){
			
		
		for(Integer i = 0; i < Num_of_Die; i++){
			wrapper.dieConfigurations[i].put('Die_Attach__c', Die_Attach[i]);
			wrapper.dieConfigurations[i].put('Wafer_Material__c', Wafer_Material[i]);
			wrapper.dieConfigurations[i].put('Wafer_Size__c', Wafer_Size[i]);
			wrapper.dieConfigurations[i].put('Wafer_Technology__c', Wafer_Technology[i]);
			wrapper.dieConfigurations[i].put('Wafer_Thickness__c', Wafer_Thickness[i]);
			wrapper.dieConfigurations[i].put('Die_Size_X__c', Die_Size_X[i]);
			wrapper.dieConfigurations[i].put('Die_Size_Y__c', Die_Size_Y[i]);			
		}
		
	}
	
	static private void setupWire(RFQItemWrapper wrapper, List<String> Wire_Configuration, List<String> Wire_Material, List<String>  Wire_Diameter, List<Decimal> Number_Of_Wires, List<Decimal> Average_2D_Wire_Length){
		for(Integer i = 0; i < Num_of_Wire; i++){
			wrapper.wireConfigurations[i].put('Wire_Configuration__c',Wire_Configuration[i]);									
			wrapper.wireConfigurations[i].put('Wire_Material__c',Wire_Material[i]);
			wrapper.wireConfigurations[i].put('Wire_Diameter__c',  Wire_Diameter[i]);
			wrapper.wireConfigurations[i].put('Number_Of_Wires__c',Number_Of_Wires[i]);			
			wrapper.wireConfigurations[i].put('Average_2D_Wire_Length__c',Average_2D_Wire_Length[i]);

		}		
	}

	static private void setupQuoteInoformation(RFQItemWrapper wrapper, String forecast){
		wrapper.setAttribute('Forecast__c', 'Package', forecast);
		
	}
	
}