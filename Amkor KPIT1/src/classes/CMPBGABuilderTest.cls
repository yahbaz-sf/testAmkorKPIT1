/*************************************************************************
* 
* PURPOSE:  This is a Test Class for the CMPBGABUilder class
			
*         
* CLASS: CMPBGABuilderTest
* CREATED: 06/05/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Chia Yuan Chuang
* 
**************************************************************************/

@isTest
private class CMPBGABuilderTest {
	
	private static Boolean wireCalculatorEnabled = false; 
	private static CMPBGABuilder PBGACostModelCalculator;	
	

	private static Map<Decimal, Map<String, Decimal>> values = new Map<Decimal, Map<String, Decimal>>
	{
		2 => new Map<String, Decimal> {
			'wire' => 0.254417652029591,
			'odm-other' => 0.0406119766834104,
			'odm-mold' => 0.006525,
			'total materials' => 0.831954628713001,
			'clam wb' => 0.02955,
			'clam others' => 0.368569370201563,
			'total clam' => 0.398119370201563,
			'total cost' => 1.23007399891456,
			'price' => 1.74178999819094,
			'gm' => 29.3787425469118,
			'irr' => 79.6350405474352,
			'operating cash/u' => 0.574215999276376,
			'cm' => 46.5214249576096
		},

		12 => new Map<String, Decimal> {
			'wire' => 0.0526508681794818,
			'odm-other' => 0.0406119766834104,
			'odm-mold' => 0.006525,
			'total materials' => 0.630187844862892,
			'clam wb' => 0.0221960911219081,
			'clam others' => 0.263003700827455,
			'total clam' => 0.285199791949363,
			'total cost' => 0.915387636812255,
			'price' => 1.21731272802042,
			'gm' => 24.8025905142022,
			'irr' => 49.1591798313596,
			'operating cash/u' => 0.36442509120817,
			'cm' => 42.3740689879271
		},

		26 => new Map<String, Decimal> {
			'wire' => 1.58572041269579,
			'odm-other' => 0.0406119766834104,
			'odm-mold' => 0.006525,
			'total materials' => 2.1632573893792,
			'clam wb' => 0.0210862865658127,
			'clam others' => 0.263003700827455,
			'total clam' => 0.284089987393267,
			'total cost' => 2.44734737677247,
			'price' => 3.77057896128745,
			'gm' => 35.0935916765198,
			'irr' => 100.00,
			'operating cash/u' => 1.38573158451498,
			'cm' => 40.7443814552916
		},

		40 => new Map<String, Decimal> {
			'wire' => 0.0526508681794818,
			'odm-other' => 0.230068874632925,
			'odm-mold' => 0.04575,
			'total materials' => 0.858869742812407,
			'clam wb' => 0.0311052631578947,
			'clam others' => 0.622213392533809,
			'total clam' => 0.653318655691703,
			'total cost' => 1.51218839850411,
			'price' => 2.21198066417352,
			'gm' => 31.6364549204085,
			'irr' => 100.00,
			'operating cash/u' => 0.762292265669407,
			'cm' => 53.788049629391
		},

		57 => new Map<String, Decimal> {
			'wire' => 1.58572041269579,
			'odm-other' => 0.0754252890309052,
			'odm-mold' => 0.04575,
			'total materials' => 2.2372957017267,
			'clam wb' => 0.020490892586475,
			'clam others' => 0.193022559861697,
			'total clam' => 0.213513452448172,
			'total cost' => 2.45080915417487,
			'price' => 3.77634859029145,
			'gm' => 35.1010878477794,
			'irr' => 100.00,
			'operating cash/u' => 1.38803943611658,
			'cm' => 39.3415620918102
		},

		66 => new Map<String, Decimal> {
			'wire' => 2.6350474312961,
			'odm-other' => 0.230068874632925,
			'odm-mold' => 0.04575,
			'total materials' => 3.44126630592902,
			'clam wb' => 0.0307363388797125,
			'clam others' => 0.34062804681476,
			'total clam' => 0.371364385694472,
			'total cost' => 3.8126306916235,
			'price' => 6.04605115270583,
			'gm' => 36.9401111392429,
			'irr' => 100.00,
			'operating cash/u' => 2.29592046108233,
			'cm' => 41.5468086718333
		}
	};

	private static Map<String, String> fieldMap = new Map<String, String>
	{
		'wire' => 'Materials_Wire__c',
		'odm-other' => 'Materials_ODM_Other__c',
		'odm-mold' => 'Materials_ODM_Mold__c',
		'clam wb' => 'CLAM_WB__c',
		'clam others' => 'CLAM_Others__c',
		'total clam' => 'CLAM_Total__c',
		'total cost' => 'Total_Cost_with_Substrate_New__c',
		'price' => 'BU_Price__c',
		'gm' => 'BU_Price_Perc_GM__c',
		'irr' => 'Perc_IRR_New__c',
		'operating cash/u' => 'Operating_Cash_u__c',
		'cm' => 'Perc_CM__c'
	};

	private static testMethod void testCostModel2()
	{

		//Test2
		Decimal testNum = 2;    
		Map<String, Decimal> valueMap = values.get(testNum);

		RFQItemWrapper wrapper = setupTest();
		wrapper.specificRfqItem.put('BU_Price__c', valueMap.get('price'));

		setupWrapper(wrapper, '15', 150.00, 'PGM', 'K4', false, 0.53040,
					0.02, 0.75, 'Au', 150.00, 1700.00, 525.00,
					4.31727, true, 1.8, '0.8', 2.0, 0.00,
					'Standard', 0.095, 5, 40, 673.240848553675);					
		PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());

		Decimal value, expectedValue;
		String fieldName;
		for (String valueName : fieldMap.keyset())
		{
			fieldName = fieldMap.get(valueName);
			value = (Decimal)wrapper.specificRfqItem.get(fieldName);
			System.assert(value != null, 'Value should not be null: ' + fieldName);
			expectedValue = valueMap.get(valueName);
			System.assert(Math.abs(value -  expectedValue) < 0.00001, 'Test # ' + testNum + ' - Incorrect value for ' + valueName + ', expected: ' + expectedValue + ', recieved ' + value);
		}
	}

	private static testMethod void testCostModel12()
	{

		//Test12
		Decimal testNum = 12;    
		Map<String, Decimal> valueMap = values.get(testNum);

		RFQItemWrapper wrapper = setupTest();
		wrapper.specificRfqItem.put('BU_Price__c', valueMap.get('price'));
        //Lalit SF-85
		setupWrapper(wrapper, '15', 150.00, 'PGM', 'P3', false,  0.53040,
	 				0.02, 0.75, 'AuPCC', 150.00, 1700.00, 525.00,
	 				4.31727, true, 1.8, '0.8', 2.0, 0.00,
	 				'Standard', 0.095, 5, 40, 673.240848553675);							
		PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());

		Decimal value, expectedValue;
		String fieldName;
		for (String valueName : fieldMap.keyset())
		{
			fieldName = fieldMap.get(valueName);
			value = (Decimal)wrapper.specificRfqItem.get(fieldName);
			System.assert(value != null, 'Value should not be null: ' + fieldName);
			expectedValue = valueMap.get(valueName);
			System.assert(Math.abs(value -  expectedValue) < 0.00001, 'Test # ' + testNum + ' - Incorrect value for ' + valueName + ', expected: ' + expectedValue + ', recieved ' + value);
		}
	}

	private static testMethod void testCostModel26()
	{

		//Test26
		Decimal testNum = 26;    
		Map<String, Decimal> valueMap = values.get(testNum);

		RFQItemWrapper wrapper = setupTest();
		wrapper.specificRfqItem.put('BU_Price__c', valueMap.get('price'));

		setupWrapper(wrapper, '15', 150.00, 'PGM', 'P3', false,  0.53040,
	 				0.02, 0.75, 'Au', 150.00, 1700.00, 525.00,
	 				4.31727, true, 1.8, '2.0', 2.0, 0.00,
	 				'Standard', 0.095, 5, 40, 686.444784554);							
		PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());

		Decimal value, expectedValue;
		String fieldName;
		for (String valueName : fieldMap.keyset())
		{
			fieldName = fieldMap.get(valueName);
			value = (Decimal)wrapper.specificRfqItem.get(fieldName);
			System.assert(value != null, 'Value should not be null: ' + fieldName);
			expectedValue = valueMap.get(valueName);
			System.assert(Math.abs(value -  expectedValue) < 0.00001, 'Test # ' + testNum + ' - Incorrect value for ' + valueName + ', expected: ' + expectedValue + ', recieved ' + value);
		}
	}

	private static testMethod void testCostModel40()
	{

		//Test40
		Decimal testNum = 40;    
		Map<String, Decimal> valueMap = values.get(testNum);

		RFQItemWrapper wrapper = setupTest();
		wrapper.specificRfqItem.put('BU_Price__c', valueMap.get('price'));
       //Lalit SF-85.
		setupWrapper(wrapper, '27', 150.00, 'PGM', 'K4', true,  0.53040,
					0.02, 0.75, 'AuPCC', 150.00, 1700.00, 525.00,
					4.31727, true, 1.8, '0.8', 2.0, 0.00,
					'Standard', 0.095, 5, 40, 673.240848553675);							
		PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());

		Decimal value, expectedValue;
		String fieldName;
		for (String valueName : fieldMap.keyset())
		{
			fieldName = fieldMap.get(valueName);
			value = (Decimal)wrapper.specificRfqItem.get(fieldName);
			System.assert(value != null, 'Value should not be null: ' + fieldName);
			expectedValue = valueMap.get(valueName);
			DebugUtils.write('valueName', valueName);
			DebugUtils.write('value', value);
			DebugUtils.write('expectedValue', expectedValue);
			if (Math.abs(value -  expectedValue) >= 0.00001) DebugUtils.write(testNum + ' Did not pass', fieldName);

		}


		for (String valueName : fieldMap.keyset())
		{
			fieldName = fieldMap.get(valueName);
			value = (Decimal)wrapper.specificRfqItem.get(fieldName);
			System.assert(value != null, 'Value should not be null: ' + fieldName);
			expectedValue = valueMap.get(valueName);
			System.assert(Math.abs(value -  expectedValue) < 0.00001, 'Test # ' + testNum + ' - Incorrect value for ' + valueName + ', expected: ' + expectedValue + ', recieved ' + value);
		}
	}

	private static testMethod void testCostModel57()
	{

		//Test57
		Decimal testNum = 57;    
		Map<String, Decimal> valueMap = values.get(testNum);

		RFQItemWrapper wrapper = setupTest();
		wrapper.specificRfqItem.put('BU_Price__c', valueMap.get('price'));

		setupWrapper(wrapper, '27', 150.00, 'PGM', 'P3', false,  0.53040,
					0.02, 0.75, 'Au', 150.00, 1700.00, 525.00,
					4.31727, true, 1.8, '2.0', 1.0, 0.00,
					'Standard', 0.095, 5, 40, 686.444784554);							
		PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());

		Decimal value, expectedValue;
		String fieldName;
		for (String valueName : fieldMap.keyset())
		{
			fieldName = fieldMap.get(valueName);
			value = (Decimal)wrapper.specificRfqItem.get(fieldName);
			System.assert(value != null, 'Value should not be null: ' + fieldName);
			expectedValue = valueMap.get(valueName);
			System.assert(Math.abs(value -  expectedValue) < 0.00001, 'Test # ' + testNum + ' - Incorrect value for ' + valueName + ', expected: ' + expectedValue + ', recieved ' + value);
		}
	}

	private static testMethod void testCostModel66()
	{

		//Test66
		Decimal testNum = 66;    
		Map<String, Decimal> valueMap = values.get(testNum);

		RFQItemWrapper wrapper = setupTest();
		wrapper.specificRfqItem.put('BU_Price__c', valueMap.get('price'));

		setupWrapper(wrapper, '27', 150.00, 'PGM', 'P3', true,  0.53040,
		 			0.02, 0.5, 'Au', 150.00, 3000.00, 525.00,
		 			4.31727, false, 1.8, '2.0', 1.0, 0.00,
		 			'Standard', 0.095, 5, 40, 686.444784554);							
		PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());

		Decimal value, expectedValue;
		String fieldName;

		for (String valueName : fieldMap.keyset())
		{
			fieldName = fieldMap.get(valueName);
			value = (Decimal)wrapper.specificRfqItem.get(fieldName);
			System.assert(value != null, 'Value should not be null: ' + fieldName);
			expectedValue = valueMap.get(valueName);
			DebugUtils.write('valueName', valueName);
			DebugUtils.write('value', value);
			DebugUtils.write('expectedValue', expectedValue);
			if (Math.abs(value -  expectedValue) >= 0.00001) DebugUtils.write(testNum + ' Did not pass', fieldName);

		}


		for (String valueName : fieldMap.keyset())
		{
			fieldName = fieldMap.get(valueName);
			value = (Decimal)wrapper.specificRfqItem.get(fieldName);
			System.assert(value != null, 'Value should not be null: ' + fieldName);
			expectedValue = valueMap.get(valueName);
			System.assert(Math.abs(value -  expectedValue) < 0.00001, 'Test # ' + testNum + ' - Incorrect value for ' + valueName + ', expected: ' + expectedValue + ', recieved ' + value);
		}
	}


//==========================================
//	private static testmethod void testNonCostModel1(){

//		Decimal bu_price_1 = 0.28103;

//		RFQItemWrapper wrapper = setupTest();			
//		wrapper.packageFamily.No_Cost_Model__c = true;


//// setupWrapperNoCostModel(RFQItemWrapper wrapper, Decimal materials_substrate, Decimal materials_wire, Decimal materials_odm_other, Decimal materials_odm_mold, Decimal assembly, Decimal capacity_ue_rate, 
//// 												Decimal clam_wb, Decimal clam_others, Decimal substrate_perc_markup, Decimal substrate_unit, Decimal substrate_waste, Decimal base_customer_au_price, 
//// 												Decimal complex_adder, Decimal mold_Wastage, Boolean apply_3d_factor, Decimal lgp_market_price)
//		setupWrapperNoCostModel(wrapper, 0.159120, 0.020000, 0.010000, 0.010000, 40.0, 0.75, 
//								0.01, 0.015, 5.0, 0.15, 0.02, 1000.0,
//								0.0, 0.095, true, 1609.0);
//		//test calculateNew
//		PBGACostModelCalculator.calculateNew(wrapper, new CMSettings());		
//		System.assert(Math.abs((Decimal)wrapper.specificRfqItem.get('BU_Price__c') - bu_price_1) < 0.00001, '#### test none cost model failed: BU_Price__c is ' + wrapper.specificRfqItem.get('BU_Price__c'));
	

//	}

	//private static testmethod void testNonCostModel2(){

	//	Decimal bu_price_2 = 0.28103;

	//	RFQItemWrapper wrapper = setupTest();			
	//	wrapper.packageFamily.No_Cost_Model__c = true;


	//	setupWrapperNoCostModel(wrapper, 0.159120, 0.020000, 0.010000, 0.010000, 40.0, 0.75, 
	//							0.01, 0.015, 5.0, 0.15, 0.02, 1000.0,
	//							0.0, 0.095, true, 1609.0);
		
	//	//test calculateAll
	//	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());		
	//	System.assert(Math.abs((Decimal)wrapper.specificRfqItem.get('BU_Price__c') - bu_price_2) < 0.00001, '#### test none cost model failed: BU_Price__c is ' + wrapper.specificRfqItem.get('BU_Price__c'));
		
		

	//}

	//private static testmethod void testNonCostModel3(){

	//	Decimal bu_price_3 = 0.28103;

	//	RFQItemWrapper wrapper = setupTest();			
	//	wrapper.packageFamily.No_Cost_Model__c = true;


	//	setupWrapperNoCostModel(wrapper, 0.159120, 0.020000, 0.010000, 0.010000, 40.0, 0.75, 
	//							0.01, 0.015, 5.0, 0.15, 0.02, 1000.0,
	//							0.0, 0.095, true, 1609.0);
		
	//	//test displayResults
	//	PBGACostModelCalculator.displayResults(wrapper, true);		
	//	System.assert(Math.abs((Decimal)wrapper.specificRfqItem.get('BU_Price__c') - bu_price_3) < 0.00001, '#### test none cost model failed: BU_Price__c is ' + wrapper.specificRfqItem.get('BU_Price__c'));

	//}

	////run 8 cases at one time
	//private static testMethod void testCostModelGroup1(){
	//	RFQItemWrapper wrapper = setupTest();				
								
    	
    	
 //   	//Expected test results from AMK282 excel sheet
	//	Decimal test1_expected  = 1.070;
	//	Decimal test2_expected  = 1.248;
	//	Decimal test3_expected  = 0.869;
	//	Decimal test4_expected  = 1.047;
	//	Decimal test5_expected  = 1.262;
	//	Decimal test6_expected  = 1.471;
	//	Decimal test7_expected  = 1.061;
	//	Decimal test8_expected  = 1.270;




    	
    	
 //   	 //setupWrapper(RFQItemWrapper wrapper, String Body_Size, Decimal Ball_Count, String Mold_Process_Type, String location, Boolean Heatspreader, Decimal Substrate_Unit, 
	//	//             Decimal Substrate_Waste, Decimal Capacity_UE_Rate, String Wire_Material, Decimal Number_Of_Wires, Decimal LGP_Market_Price, Decimal Base_Customer_Au_Price, 
	//	//			Decimal AVG_2D_Wirelength, Boolean Apply_3D_Factor, Decimal Ball_WireSize_Ratio, String Wire_Diameter, Decimal Number_of_Chips_per_Package, Decimal Complex_Adder, 
	//	// 			String Mold_Type, Decimal Mold_Wastage, Decimal Substrate_Perc_Markup, Decimal Assembly, Decimal Total_3D_Wire_Length)
		
	//	Map<String, Decimal> costModelResults;
	//	Decimal costModel_I22;
		
		
	//	//Test1
	//	setupWrapper(wrapper, '17', 150.00, 'PGM', 'K4', false,  0.5,
	//				0.02, 0.75, 'Au', 150.00, 1700.00, 525.00,
	//				4.31727, true, 1.8, '0.8', 1.0, 0.00,
	//				'Standard', 0.095, 5, 40, 673.24085);			
					
	//	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());		
	//	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
	//	costModel_I22 = costModelResults.get('costModel_I22');
	//	Decimal test1Price = costModelResults.get('costModel_I24');

	//	Test.startTest();
	//	tesCostModelDetails(costModelResults);
	//	System.assert(Math.abs(costModel_I22 -  test1_expected) < 0.001, 'Test 1 failed' + ' costModel_I22 calulated value is ' + costModel_I22);		                                                                     				
		                                                                      
	//	//Multivolume for Test1
	//	setupWrapper(wrapper, '17', 150.00, 'PGM', 'K4', false,  0.5,
	//				0.02, 0.75, 'Au', 150.00, 1700.00, 525.00,
	//				4.31727, true, 1.8, '0.8', 1.0, 0.00,
	//				'Standard', 0.095, 5, 40, 673.24085);
	//	wrapper.setAttribute('Forecast__c', RFQItemWrapper.PACKAGE_OBJECT, '<5');
	//	//add new volume
	//	RFQMultiVolumeSectionController volumeCont = new RFQMultiVolumeSectionController();
	//	volumeCont.cWrapper = wrapper;
	//	volumeCont.addVolume();

	//	wrapper.volumeList[0].volume = '< 500';

	//	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());		
	//	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
	//	Decimal multivolume1Price = costModelResults.get('costModel_I24');

	//	System.assert(Math.abs(multivolume1Price -  test1Price) < 0.001, 'Test 1 multivolume failed' + ' multivolume calulated price is ' + multivolume1Price + ', expected ' + test1Price);		                                                                     				

	//	//Test2                                                               
	//	setupWrapper(wrapper, '17', 150.00, 'PGM', 'K4', false,  0.5,
	//				0.02, 0.75, 'Au', 150.00, 1700.00, 525.00,
	//				4.31727, true, 1.8, '0.8', 2.0, 0.00,
	//				'Standard', 0.095, 5, 40, 673.24085);					
	//	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	//	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	//	costModel_I22  = costModelResults.get('costModel_I22' );
	//	System.assert(Math.abs(costModel_I22 -  test2_expected) < 0.001, 'Test 2 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
		
		
	//	//Test3
	//	setupWrapper(wrapper, '17', 150.00, 'PGM', 'K4', false,  0.5,
	//				0.02, 0.75, 'PCC', 150.00, 1700.00, 525.00,
	//				4.31727, true, 1.8, '0.8', 1.0, 0.00,
	//				'Standard', 0.095, 5, 40, 673.24085);					
	//	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	//	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	//	costModel_I22  = costModelResults.get('costModel_I22' );
	//	System.assert(Math.abs(costModel_I22 -  test3_expected) < 0.001, 'Test 3 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
	//	//Test4
	//	setupWrapper(wrapper, '17', 150.00, 'PGM', 'K4', false,  0.5,
	//				0.02, 0.75, 'PCC', 150.00, 1700.00, 525.00,
	//				4.31727, true, 1.8, '0.8', 2.0, 0.00,
	//				'Standard', 0.095, 5, 40, 673.24085);					
	//	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	//	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	//	costModel_I22  = costModelResults.get('costModel_I22' );
	//	System.assert(Math.abs(costModel_I22 -  test4_expected) < 0.001, 'Test 4 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
	//	//Test5 now
	//	setupWrapper(wrapper, '17', 150.00, 'PGM', 'K4', true,  0.5,
	//				0.02, 0.75, 'Au', 150.00, 1700.00, 525.00,
	//				4.31727, true, 1.8, '0.8', 1.0, 0.00,
	//				'Standard', 0.095, 5, 40, 673.24085);					
	//	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	//	costModelResults = PBGACostModelCalculator.getCostModelResults();
	//	costModel_I22 = costModelResults.get('costModel_I22' ); 
	//	System.assert(Math.abs(costModel_I22 - test5_expected) < 0.001, 'Test 5 failed' + ' costModel_I22 calulated value is ' + costModel_I22);		
														
	//	//Test6
	//	setupWrapper(wrapper, '17', 150.00, 'PGM', 'K4', true,  0.5,
	//				0.02, 0.75, 'Au', 150.00, 1700.00, 525.00,
	//				4.31727, true, 1.8, '0.8', 2.0, 0.00,
	//				'Standard', 0.095, 5, 40, 673.24085);					
	//	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	//	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	//	costModel_I22  = costModelResults.get('costModel_I22' );
	//	System.assert(Math.abs(costModel_I22 -  test6_expected) < 0.001, 'Test 6 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
	//	//Test7
	//	setupWrapper(wrapper, '17', 150.00, 'PGM', 'K4', true,  0.5,
	//				0.02, 0.75, 'PCC', 150.00, 1700.00, 525.00,
	//				4.31727, true, 1.8, '0.8', 1.0, 0.00,
	//				'Standard', 0.095, 5, 40, 673.24085);					
	//	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	//	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	//	costModel_I22  = costModelResults.get('costModel_I22' );
	//	System.assert(Math.abs(costModel_I22 -  test7_expected) < 0.001, 'Test 7 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
	//	//Test8
	//	setupWrapper(wrapper, '17', 150.00, 'PGM', 'K4', true,  0.5,
	//				0.02, 0.75, 'PCC', 150.00, 1700.00, 525.00,
	//				4.31727, true, 1.8, '0.8', 2.0, 0.00,
	//				'Standard', 0.095, 5, 40, 673.24085);					
	//	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	//	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	//	costModel_I22  = costModelResults.get('costModel_I22' );
	//	System.assert(Math.abs(costModel_I22 -  test8_expected) < 0.001, 'Test 8 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
	//	Test.stopTest();
	
    	
	//}

	//We Don't have Factory 'P3'
	
	// private static testMethod void  testCostModelGroup2(){
	// 	RFQItemWrapper wrapper = setupTest();				
								
    	
    	
 //    	//Expected test results from AMK282 excel sheet
	// 	Decimal test9_expected  = 0.991;
	// 	Decimal test10_expected = 1.116;
	// 	Decimal test11_expected = 0.791;
	// 	Decimal test12_expected = 0.915;
	// 	Decimal test13_expected = 1.110;
	// 	Decimal test14_expected = 1.257;
	// 	Decimal test15_expected = 0.909;
	// 	Decimal test16_expected = 1.056;
    	
    	
 //    	 //setupWrapper(RFQItemWrapper wrapper, String Body_Size, Decimal Ball_Count, String Mold_Process_Type, String location, Boolean Heatspreader, Decimal Substrate_Unit, 
	// 	//             Decimal Substrate_Waste, Decimal Capacity_UE_Rate, String Wire_Material, Decimal Number_Of_Wires, Decimal LGP_Market_Price, Decimal Base_Customer_Au_Price, 
	// 	//			Decimal AVG_2D_Wirelength, Boolean Apply_3D_Factor, Decimal Ball_WireSize_Ratio, String Wire_Diameter, Decimal Number_of_Chips_per_Package, Decimal Complex_Adder, 
	// 	// 			String Mold_Type, Decimal Mold_Wastage, Decimal Substrate_Perc_Markup, Decimal Assembly, Decimal Total_3D_Wire_Length)
		
	// 	Map<String, Decimal> costModelResults;
	// 	Decimal costModel_I22;
		
		
	// 	//Test9
	// 	setupWrapper(wrapper, '15', 150.00, 'PGM', 'P3', false,  0.5,
	// 				0.02, 0.75, 'Au', 150.00, 1700.00, 525.00,
	// 				4.31727, true, 1.8, '0.8', 1.0, 0.00,
	// 				'Standard', 0.095, 5, 40, 673.24085);					
	// 	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	// 	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	// 	costModel_I22  = costModelResults.get('costModel_I22' );
	// 	Test.startTest();
	// 	System.assert(Math.abs(costModel_I22 -  test9_expected) < 0.001, 'Test 9 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
		
	// 	//Test10
	// 	setupWrapper(wrapper, '15', 150.00, 'PGM', 'P3', false,  0.5,
	// 				0.02, 0.75, 'Au', 150.00, 1700.00, 525.00,
	// 				4.31727, true, 1.8, '0.8', 2.0, 0.00,
	// 				'Standard', 0.095, 5, 40, 673.24085);					
	// 	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	// 	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	// 	costModel_I22  = costModelResults.get('costModel_I22' );
	// 	System.assert(Math.abs(costModel_I22 - test10_expected) < 0.001, 'Test 10 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
	// 	//Test11
	// 	setupWrapper(wrapper, '15', 150.00, 'PGM', 'P3', false,  0.5,
	// 				0.02, 0.75, 'PCC', 150.00, 1700.00, 525.00,
	// 				4.31727, true, 1.8, '0.8', 1.0, 0.00,
	// 				'Standard', 0.095, 5, 40, 673.24085);					
	// 	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	// 	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	// 	costModel_I22  = costModelResults.get('costModel_I22' );
	// 	System.assert(Math.abs(costModel_I22 - test11_expected) < 0.001, 'Test 11 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
	// 	//Test12
	// 	setupWrapper(wrapper, '15', 150.00, 'PGM', 'P3', false,  0.5,
	// 				0.02, 0.75, 'PCC', 150.00, 1700.00, 525.00,
	// 				4.31727, true, 1.8, '0.8', 2.0, 0.00,
	// 				'Standard', 0.095, 5, 40, 673.24085);					
	// 	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	// 	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	// 	costModel_I22  = costModelResults.get('costModel_I22' );
	// 	System.assert(Math.abs(costModel_I22 - test12_expected) < 0.001, 'Test 12 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
		
	// 	//Test13
	// 	setupWrapper(wrapper, '15', 150.00, 'PGM', 'P3', true,  0.5,
	// 				0.02, 0.75, 'Au', 150.00, 1700.00, 525.00,
	// 				4.31727, true, 1.8, '0.8', 1.0, 0.00,
	// 				'Standard', 0.095, 5, 40, 673.24085);					
	// 	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	// 	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	// 	costModel_I22  = costModelResults.get('costModel_I22' );
	// 	System.assert(Math.abs(costModel_I22 - test13_expected) < 0.001, 'Test 13 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
		
	// 	//Test14
	// 	setupWrapper(wrapper, '15', 150.00, 'PGM', 'P3', true,  0.5,
	// 				0.02, 0.75, 'Au', 150.00, 1700.00, 525.00,
	// 				4.31727, true, 1.8, '0.8', 2.0, 0.00,
	// 				'Standard', 0.095, 5, 40, 673.24085);					
	// 	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	// 	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	// 	costModel_I22  = costModelResults.get('costModel_I22' );
	// 	System.assert(Math.abs(costModel_I22 - test14_expected) < 0.001, 'Test 14 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
	// 	//Test15
	// 	setupWrapper(wrapper, '15', 150.00, 'PGM', 'P3', true,  0.5,
	// 				0.02, 0.75, 'PCC', 150.00, 1700.00, 525.00,
	// 				4.31727, true, 1.8, '0.8', 1.0, 0.00,
	// 				'Standard', 0.095, 5, 40, 673.24085);					
	// 	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	// 	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	// 	costModel_I22  = costModelResults.get('costModel_I22' );
	// 	System.assert(Math.abs(costModel_I22 - test15_expected) < 0.001, 'Test 15 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
	// 	//Test16
	// 	setupWrapper(wrapper, '15', 150.00, 'PGM', 'P3', true,  0.5,
	// 				0.02, 0.75, 'PCC', 150.00, 1700.00, 525.00,
	// 				4.31727, true, 1.8, '0.8', 2.0, 0.00,
	// 				'Standard', 0.095, 5, 40, 673.24085);					
	// 	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	// 	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	// 	costModel_I22  = costModelResults.get('costModel_I22' );
	// 	System.assert(Math.abs(costModel_I22 - test16_expected) < 0.001, 'Test 16 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
	// 	Test.stopTest();
	
    	
	// }
	
	//private static testMethod void  testCostModelGroup3(){
	//	RFQItemWrapper wrapper = setupTest();				
								
    		
 //   	 //setupWrapper(RFQItemWrapper wrapper, String Body_Size, Decimal Ball_Count, String Mold_Process_Type, String location, Boolean Heatspreader, Decimal Substrate_Unit, 
	//	//             Decimal Substrate_Waste, Decimal Capacity_UE_Rate, String Wire_Material, Decimal Number_Of_Wires, Decimal LGP_Market_Price, Decimal Base_Customer_Au_Price, 
	//	//			Decimal AVG_2D_Wirelength, Boolean Apply_3D_Factor, Decimal Ball_WireSize_Ratio, String Wire_Diameter, Decimal Number_of_Chips_per_Package, Decimal Complex_Adder, 
	//	// 			String Mold_Type, Decimal Mold_Wastage, Decimal Substrate_Perc_Markup, Decimal Assembly, Decimal Total_3D_Wire_Length)
		
	//	Map<String, Decimal> costModelResults;
	//	Decimal costModel_I22;
	//	//Expected value from AMK282 Excel sheet
	//	Decimal test17_expected = 2.418;
	//	Decimal test18_expected = 2.596;
	//	Decimal test19_expected = 0.894;
	//	Decimal test20_expected = 1.072;
	//	Decimal test21_expected = 2.610;
	//	Decimal test22_expected = 2.819;
	//	Decimal test23_expected = 1.086;
	//	Decimal test24_expected = 1.295;
		
	//	//Test17
	//	setupWrapper(wrapper, '17', 150.00, 'PGM', 'K4', false,  0.5,
	//				0.02, 0.75, 'Au', 150.00, 1700.00, 525.00,
	//				4.31727, true, 1.8, '2', 1.0, 0.00,
	//				'Standard', 0.095, 5, 40, 686.44478);					
	//	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());		
	//	costModelResults = PBGACostModelCalculator.getCostModelResults(); 		
		
	//	costModel_I22 = costModelResults.get('costModel_I22');
		
	//	Test.startTest();
	//	System.assert(Math.abs(costModel_I22 - test17_expected) < 0.001, 'Test 17 failed' + ' costModel_I22 calulated value is ' + costModel_I22);		                                                                     				
		                                                                      
		                                                                    
	//	//Test18                                                               
	//	setupWrapper(wrapper, '17', 150.00, 'PGM', 'K4', false,  0.5,
	//				0.02, 0.75, 'Au', 150.00, 1700.00, 525.00,
	//				4.31727, true, 1.8, '2', 2.0, 0.00,
	//				'Standard', 0.095, 5, 40, 686.44478);					
	//	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	//	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	//	costModel_I22  = costModelResults.get('costModel_I22' );
	//	System.assert(Math.abs(costModel_I22 - test18_expected) < 0.001, 'Test 18 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
		
		
	//	//Test19
	//	setupWrapper(wrapper, '17', 150.00, 'PGM', 'K4', false,  0.5,
	//				0.02, 0.75, 'PCC', 150.00, 1700.00, 525.00,
	//				4.31727, true, 1.8, '2', 1.0, 0.00,
	//				'Standard', 0.095, 5, 40, 686.44478);					
	//	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	//	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	//	costModel_I22  = costModelResults.get('costModel_I22' );
	//	System.assert(Math.abs(costModel_I22 - test19_expected) < 0.001, 'Test 19 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
	//	//Test20
	//	setupWrapper(wrapper, '17', 150.00, 'PGM', 'K4', false,  0.5,
	//				0.02, 0.75, 'PCC', 150.00, 1700.00, 525.00,
	//				4.31727, true, 1.8, '2', 2.0, 0.00,
	//				'Standard', 0.095, 5, 40, 686.44478);					
	//	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	//	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	//	costModel_I22  = costModelResults.get('costModel_I22' );
	//	System.assert(Math.abs(costModel_I22 - test20_expected) < 0.001, 'Test 20 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
	//	//Test21
	//	setupWrapper(wrapper, '17', 150.00, 'PGM', 'K4', true,  0.5,
	//				0.02, 0.75, 'Au', 150.00, 1700.00, 525.00,
	//				4.31727, true, 1.8, '2', 1.0, 0.00,
	//				'Standard', 0.095, 5, 40, 686.44478);					
	//	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	//	costModelResults = PBGACostModelCalculator.getCostModelResults();
	//	costModel_I22 = costModelResults.get('costModel_I22' ); 
	//	System.assert(Math.abs(costModel_I22 - test21_expected) < 0.001, 'Test 21 failed' + ' costModel_I22 calulated value is ' + costModel_I22);		
														
	//	//Test22
	//	setupWrapper(wrapper, '17', 150.00, 'PGM', 'K4', true,  0.5,
	//				0.02, 0.75, 'Au', 150.00, 1700.00, 525.00,
	//				4.31727, true, 1.8, '2', 2.0, 0.00,
	//				'Standard', 0.095, 5, 40, 686.44478);					
	//	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	//	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	//	costModel_I22  = costModelResults.get('costModel_I22' );
	//	System.assert(Math.abs(costModel_I22 - test22_expected) < 0.001, 'Test 22 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
	//	//Test23
	//	setupWrapper(wrapper, '17', 150.00, 'PGM', 'K4', true,  0.5,
	//				0.02, 0.75, 'PCC', 150.00, 1700.00, 525.00,
	//				4.31727, true, 1.8, '2', 1.0, 0.00,
	//				'Standard', 0.095, 5, 40, 686.44478);					
	//	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	//	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	//	costModel_I22  = costModelResults.get('costModel_I22' );
	//	System.assert(Math.abs(costModel_I22 - test23_expected) < 0.001, 'Test 23 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
	//	//Test24
	//	setupWrapper(wrapper, '17', 150.00, 'PGM', 'K4', true,  0.5,
	//				0.02, 0.75, 'PCC', 150.00, 1700.00, 525.00,
	//				4.31727, true, 1.8, '2', 2.0, 0.00,
	//				'Standard', 0.095, 5, 40, 686.44478);					
	//	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	//	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	//	costModel_I22  = costModelResults.get('costModel_I22' );
	//	System.assert(Math.abs(costModel_I22 - test24_expected) < 0.001, 'Test 24 failed' + ' costModel_I22 calulated value is ' + costModel_I22);		
		
		
	//	Test.stopTest();
	
    	
	//}
	
	// private static testMethod void  testCostModelGroup4(){
	// 	RFQItemWrapper wrapper = setupTest();				
								
    	
    	
 //    	//Expected test results from AMK282 excel sheet
	// 	Decimal test25_expected = 2.323;
	// 	Decimal test26_expected = 2.447;
	// 	Decimal test27_expected = 0.815;
	// 	Decimal test28_expected = 0.940;
	// 	Decimal test29_expected = 2.441;
	// 	Decimal test30_expected = 2.588;		
	// 	Decimal test31_expected = 0.933;
	// 	Decimal test32_expected = 1.080;
    	
    	
 //    	 //setupWrapper(RFQItemWrapper wrapper, String Body_Size, Decimal Ball_Count, String Mold_Process_Type, String location, Boolean Heatspreader, Decimal Substrate_Unit, 
	// 	//             Decimal Substrate_Waste, Decimal Capacity_UE_Rate, String Wire_Material, Decimal Number_Of_Wires, Decimal LGP_Market_Price, Decimal Base_Customer_Au_Price, 
	// 	//			Decimal AVG_2D_Wirelength, Boolean Apply_3D_Factor, Decimal Ball_WireSize_Ratio, String Wire_Diameter, Decimal Number_of_Chips_per_Package, Decimal Complex_Adder, 
	// 	// 			String Mold_Type, Decimal Mold_Wastage, Decimal Substrate_Perc_Markup, Decimal Assembly, Decimal Total_3D_Wire_Length)
		
	// 	Map<String, Decimal> costModelResults;
	// 	Decimal costModel_I22;
		
	// 	//Test25
	// 	setupWrapper(wrapper, '15', 150.00, 'PGM', 'P3', false,  0.5,
	// 				0.02, 0.75, 'Au', 150.00, 1700.00, 525.00,
	// 				4.31727, true, 1.8, '2', 1.0, 0.00,
	// 				'Standard', 0.095, 5, 40, 686.44478);					
	// 	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	// 	test.startTest();
	// 	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	// 	costModel_I22  = costModelResults.get('costModel_I22' );
	// 	System.assert(Math.abs(costModel_I22 - test25_expected) < 0.001, 'Test 25 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
		
	// 	//Test26
	// 	setupWrapper(wrapper, '15', 150.00, 'PGM', 'P3', false,  0.5,
	// 				0.02, 0.75, 'Au', 150.00, 1700.00, 525.00,
	// 				4.31727, true, 1.8, '2.0', 2.0, 0.00,
	// 				'Standard', 0.095, 5, 40, 686.44478);					
	// 	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	// 	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	// 	costModel_I22  = costModelResults.get('costModel_I22' );
	// 	System.assert(Math.abs(costModel_I22 - test26_expected) < 0.001, 'Test 26 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
	// 	//Test27
	// 	setupWrapper(wrapper, '15', 150.00, 'PGM', 'P3', false,  0.5,
	// 				0.02, 0.75, 'PCC', 150.00, 1700.00, 525.00,
	// 				4.31727, true, 1.8, '2.0', 1.0, 0.00,
	// 				'Standard', 0.095, 5, 40, 686.44478);					
	// 	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	// 	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	// 	costModel_I22  = costModelResults.get('costModel_I22' );
	// 	System.assert(Math.abs(costModel_I22 - test27_expected) < 0.001, 'Test 27 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
	// 	//Test28
	// 	setupWrapper(wrapper, '15', 150.00, 'PGM', 'P3', false,  0.5,
	// 				0.02, 0.75, 'PCC', 150.00, 1700.00, 525.00,
	// 				4.31727, true, 1.8, '2.0', 2.0, 0.00,
	// 				'Standard', 0.095, 5, 40, 686.44478);					
	// 	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	// 	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	// 	costModel_I22  = costModelResults.get('costModel_I22' );
	// 	System.assert(Math.abs(costModel_I22 - test28_expected) < 0.001, 'Test 28 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
		
	// 	//Test29
	// 	setupWrapper(wrapper, '15', 150.00, 'PGM', 'P3', true,  0.5,
	// 				0.02, 0.75, 'Au', 150.00, 1700.00, 525.00,
	// 				4.31727, true, 1.8, '2.0', 1.0, 0.00,
	// 				'Standard', 0.095, 5, 40, 686.44478);					
	// 	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	// 	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	// 	costModel_I22  = costModelResults.get('costModel_I22' );
	// 	System.assert(Math.abs(costModel_I22 - test29_expected) < 0.001, 'Test 29 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
		
	// 	//Test30
	// 	setupWrapper(wrapper, '15', 150.00, 'PGM', 'P3', true,  0.5,
	// 				0.02, 0.75, 'Au', 150.00, 1700.00, 525.00,
	// 				4.31727, true, 1.8, '2.0', 2.0, 0.00,
	// 				'Standard', 0.095, 5, 40, 686.44478);					
	// 	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	// 	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	// 	costModel_I22  = costModelResults.get('costModel_I22' );
	// 	System.assert(Math.abs(costModel_I22 - test30_expected) < 0.001, 'Test 30 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
	// 	//Test31
	// 	setupWrapper(wrapper, '15', 150.00, 'PGM', 'P3', true,  0.5,
	// 				0.02, 0.75, 'PCC', 150.00, 1700.00, 525.00,
	// 				4.31727, true, 1.8, '2.0', 1.0, 0.00,
	// 				'Standard', 0.095, 5, 40, 686.44478);					
	// 	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	// 	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	// 	costModel_I22  = costModelResults.get('costModel_I22' );
	// 	System.assert(Math.abs(costModel_I22 - test31_expected) < 0.001, 'Test 31 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
	// 	//Test32
	// 	setupWrapper(wrapper, '15', 150.00, 'PGM', 'P3', true,  0.5,
	// 				0.02, 0.75, 'PCC', 150.00, 1700.00, 525.00,
	// 				4.31727, true, 1.8, '2.0', 2.0, 0.00,
	// 				'Standard', 0.095, 5, 40, 686.44478);					
	// 	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	// 	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	// 	costModel_I22  = costModelResults.get('costModel_I22' );
	// 	System.assert(Math.abs(costModel_I22 - test32_expected) < 0.001, 'Test 32 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
		
	// 	Test.stopTest();
	
    	
	// }
	
	//private static testMethod void  testCostModelGroup5(){
	//	RFQItemWrapper wrapper = setupTest();				
								
    	
    	
 //   	//Expected test results from AMK282 excel sheet
	//	Decimal test33_expected = 1.215;
	//	Decimal test34_expected = 1.466;
	//	Decimal test35_expected = 1.014;
	//	Decimal test36_expected = 1.264;
	//	Decimal test37_expected = 1.419;
	//	Decimal test38_expected = 1.714;
	//	Decimal test39_expected = 1.218;
	//	Decimal test40_expected = 1.512;		
    	
    	
 //   	 //setupWrapper(RFQItemWrapper wrapper, String Body_Size, Decimal Ball_Count, String Mold_Process_Type, String location, Boolean Heatspreader, Decimal Substrate_Unit, 
	//	//             Decimal Substrate_Waste, Decimal Capacity_UE_Rate, String Wire_Material, Decimal Number_Of_Wires, Decimal LGP_Market_Price, Decimal Base_Customer_Au_Price, 
	//	//			Decimal AVG_2D_Wirelength, Boolean Apply_3D_Factor, Decimal Ball_WireSize_Ratio, String Wire_Diameter, Decimal Number_of_Chips_per_Package, Decimal Complex_Adder, 
	//	// 			String Mold_Type, Decimal Mold_Wastage, Decimal Substrate_Perc_Markup, Decimal Assembly, Decimal Total_3D_Wire_Length)
		
	//	Map<String, Decimal> costModelResults;
	//	Decimal costModel_I22;
		
	//	//Test33
	//	setupWrapper(wrapper, '27', 150.00, 'PGM', 'K4', false,  0.5,
	//				0.02, 0.75, 'Au', 150.00, 1700.00, 525.00,
	//				4.31727, true, 1.8, '0.8', 1.0, 0.00,
	//				'Standard', 0.095, 5, 40, 673.24085);					
	//	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());		
	//	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
	//	costModel_I22 = costModelResults.get('costModel_I22');
	//	Test.startTest();
	//	System.assert(Math.abs(costModel_I22 - test33_expected) < 0.001, 'Test 33 failed' + ' costModel_I22 calulated value is ' + costModel_I22);		                                                                     				
		                                                                      
		                                                                    
	//	//Test34                                                               
	//	setupWrapper(wrapper, '27', 150.00, 'PGM', 'K4', false,  0.5,
	//				0.02, 0.75, 'Au', 150.00, 1700.00, 525.00,
	//				4.31727, true, 1.8, '0.8', 2.0, 0.00,
	//				'Standard', 0.095, 5, 40, 673.24085);					
	//	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	//	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	//	costModel_I22  = costModelResults.get('costModel_I22' );
	//	System.assert(Math.abs(costModel_I22 - test34_expected) < 0.001, 'Test 34 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
		
		
	//	//Test35
	//	setupWrapper(wrapper, '27', 150.00, 'PGM', 'K4', false,  0.5,
	//				0.02, 0.75, 'PCC', 150.00, 1700.00, 525.00,
	//				4.31727, true, 1.8, '0.8', 1.0, 0.00,
	//				'Standard', 0.095, 5, 40, 673.24085);					
	//	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	//	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	//	costModel_I22  = costModelResults.get('costModel_I22' );
	//	System.assert(Math.abs(costModel_I22 - test35_expected) < 0.001, 'Test 35 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
	//	//Test36
	//	setupWrapper(wrapper, '27', 150.00, 'PGM', 'K4', false,  0.5,
	//				0.02, 0.75, 'PCC', 150.00, 1700.00, 525.00,
	//				4.31727, true, 1.8, '0.8', 2.0, 0.00,
	//				'Standard', 0.095, 5, 40, 673.24085);					
	//	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	//	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	//	costModel_I22  = costModelResults.get('costModel_I22' );
	//	System.assert(Math.abs(costModel_I22 - test36_expected) < 0.001, 'Test 36 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
	//	//Test37
	//	setupWrapper(wrapper, '27', 150.00, 'PGM', 'K4', true,  0.5,
	//				0.02, 0.75, 'Au', 150.00, 1700.00, 525.00,
	//				4.31727, true, 1.8, '0.8', 1.0, 0.00,
	//				'Standard', 0.095, 5, 40, 673.24085);					
	//	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	//	costModelResults = PBGACostModelCalculator.getCostModelResults();
	//	costModel_I22 = costModelResults.get('costModel_I22' ); 
	//	System.assert(Math.abs(costModel_I22 - test37_expected) < 0.001, 'Test 37 failed' + ' costModel_I22 calulated value is ' + costModel_I22);		
														
	//	//Test38
	//	setupWrapper(wrapper, '27', 150.00, 'PGM', 'K4', true,  0.5,
	//				0.02, 0.75, 'Au', 150.00, 1700.00, 525.00,
	//				4.31727, true, 1.8, '0.8', 2.0, 0.00,
	//				'Standard', 0.095, 5, 40, 673.24085);					
	//	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	//	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	//	costModel_I22  = costModelResults.get('costModel_I22' );
	//	System.assert(Math.abs(costModel_I22 - test38_expected) < 0.001, 'Test 38 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
	//	//Test39
	//	setupWrapper(wrapper, '27', 150.00, 'PGM', 'K4', true,  0.5,
	//				0.02, 0.75, 'PCC', 150.00, 1700.00, 525.00,
	//				4.31727, true, 1.8, '0.8', 1.0, 0.00,
	//				'Standard', 0.095, 5, 40, 673.24085);					
	//	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	//	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	//	costModel_I22  = costModelResults.get('costModel_I22' );
	//	System.assert(Math.abs(costModel_I22 - test39_expected) < 0.001, 'Test 39 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
	//	//Test40
	//	setupWrapper(wrapper, '27', 150.00, 'PGM', 'K4', true,  0.5,
	//				0.02, 0.75, 'PCC', 150.00, 1700.00, 525.00,
	//				4.31727, true, 1.8, '0.8', 2.0, 0.00,
	//				'Standard', 0.095, 5, 40, 673.24085);					
	//	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	//	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	//	costModel_I22  = costModelResults.get('costModel_I22' );
	//	System.assert(Math.abs(costModel_I22 - test40_expected) < 0.001, 'Test 40 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
					
	//	Test.stopTest();
	
    	
	//}
	
	// private static testMethod void  testCostModelGroup6(){
	// 	RFQItemWrapper wrapper = setupTest();				
								    	
    	
 //    	//Expected test results from AMK282 excel sheet
	// 	Decimal test41_expected = 1.120;
	// 	Decimal test42_expected = 1.293;
	// 	Decimal test43_expected = 0.919;
	// 	Decimal test44_expected = 1.093;
	// 	Decimal test45_expected = 1.308;
	// 	Decimal test46_expected = 1.513;
	// 	Decimal test47_expected = 1.108;
	// 	Decimal test48_expected = 1.312;
    	
    	
 //    	 //setupWrapper(RFQItemWrapper wrapper, String Body_Size, Decimal Ball_Count, String Mold_Process_Type, String location, Boolean Heatspreader, Decimal Substrate_Unit, 
	// 	//             Decimal Substrate_Waste, Decimal Capacity_UE_Rate, String Wire_Material, Decimal Number_Of_Wires, Decimal LGP_Market_Price, Decimal Base_Customer_Au_Price, 
	// 	//			Decimal AVG_2D_Wirelength, Boolean Apply_3D_Factor, Decimal Ball_WireSize_Ratio, String Wire_Diameter, Decimal Number_of_Chips_per_Package, Decimal Complex_Adder, 
	// 	// 			String Mold_Type, Decimal Mold_Wastage, Decimal Substrate_Perc_Markup, Decimal Assembly, Decimal Total_3D_Wire_Length)
		
	// 	Map<String, Decimal> costModelResults;
	// 	Decimal costModel_I22;
		
	// 	//Test41
	// 	setupWrapper(wrapper, '27', 150.00, 'PGM', 'P3', false,  0.5,
	// 				0.02, 0.75, 'Au', 150.00, 1700.00, 525.00,
	// 				4.31727, true, 1.8, '0.8', 1.0, 0.00,
	// 				'Standard', 0.095, 5, 40, 673.24085);					
	// 	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	// 	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	// 	costModel_I22  = costModelResults.get('costModel_I22' );
	// 	Test.startTest();
	// 	System.assert(Math.abs(costModel_I22 - test41_expected) < 0.001, 'Test 41 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
		
	// 	//Test42
	// 	setupWrapper(wrapper, '27', 150.00, 'PGM', 'P3', false,  0.5,
	// 				0.02, 0.75, 'Au', 150.00, 1700.00, 525.00,
	// 				4.31727, true, 1.8, '0.8', 2.0, 0.00,
	// 				'Standard', 0.095, 5, 40, 673.24085);					
	// 	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	// 	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	// 	costModel_I22  = costModelResults.get('costModel_I22' );
	// 	System.assert(Math.abs(costModel_I22 - test42_expected) < 0.001, 'Test 42 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
	// 	//Test43
	// 	setupWrapper(wrapper, '27', 150.00, 'PGM', 'P3', false,  0.5,
	// 				0.02, 0.75, 'PCC', 150.00, 1700.00, 525.00,
	// 				4.31727, true, 1.8, '0.8', 1.0, 0.00,
	// 				'Standard', 0.095, 5, 40, 673.24085);					
	// 	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	// 	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	// 	costModel_I22  = costModelResults.get('costModel_I22' );
	// 	System.assert(Math.abs(costModel_I22 - test43_expected) < 0.001, 'Test 43 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
	// 	//Test44
	// 	setupWrapper(wrapper, '27', 150.00, 'PGM', 'P3', false,  0.5,
	// 				0.02, 0.75, 'PCC', 150.00, 1700.00, 525.00,
	// 				4.31727, true, 1.8, '0.8', 2.0, 0.00,
	// 				'Standard', 0.095, 5, 40, 673.24085);					
	// 	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	// 	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	// 	costModel_I22  = costModelResults.get('costModel_I22' );
	// 	System.assert(Math.abs(costModel_I22 - test44_expected) < 0.001, 'Test 44 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
		
	// 	//Test45
	// 	setupWrapper(wrapper, '27', 150.00, 'PGM', 'P3', true,  0.5,
	// 				0.02, 0.75, 'Au', 150.00, 1700.00, 525.00,
	// 				4.31727, true, 1.8, '0.8', 1.0, 0.00,
	// 				'Standard', 0.095, 5, 40, 673.24085);					
	// 	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	// 	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	// 	costModel_I22  = costModelResults.get('costModel_I22' );
	// 	System.assert(Math.abs(costModel_I22 - test45_expected) < 0.001, 'Test 45 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
		
	// 	//Test46
	// 	setupWrapper(wrapper, '27', 150.00, 'PGM', 'P3', true,  0.5,
	// 				0.02, 0.75, 'Au', 150.00, 1700.00, 525.00,
	// 				4.31727, true, 1.8, '0.8', 2.0, 0.00,
	// 				'Standard', 0.095, 5, 40, 673.24085);					
	// 	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	// 	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	// 	costModel_I22  = costModelResults.get('costModel_I22' );
	// 	System.assert(Math.abs(costModel_I22 - test46_expected) < 0.001, 'Test 46 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
	// 	//Test47
	// 	setupWrapper(wrapper, '27', 150.00, 'PGM', 'P3', true,  0.5,
	// 				0.02, 0.75, 'PCC', 150.00, 1700.00, 525.00,
	// 				4.31727, true, 1.8, '0.8', 1.0, 0.00,
	// 				'Standard', 0.095, 5, 40, 673.24085);					
	// 	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	// 	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	// 	costModel_I22  = costModelResults.get('costModel_I22' );
	// 	System.assert(Math.abs(costModel_I22 - test47_expected) < 0.001, 'Test 47 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
		
	// 	//Test48
	// 	setupWrapper(wrapper, '27', 150.00, 'PGM', 'P3', true,  0.5,
	// 				0.02, 0.75, 'PCC', 150.00, 1700.00, 525.00,
	// 				4.31727, true, 1.8, '0.8', 2.0, 0.00,
	// 				'Standard', 0.095, 5, 40, 673.24085);					
	// 	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	// 	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	// 	costModel_I22  = costModelResults.get('costModel_I22' );
	// 	System.assert(Math.abs(costModel_I22 - test48_expected) < 0.001, 'Test 48 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
					
	// 	Test.stopTest();
	
    	
	// }
	
	//private static testMethod void  testCostModelGroup7(){
	//	RFQItemWrapper wrapper = setupTest();				
								    	
    	
 //   	//Expected test results from AMK282 excel sheet
	//	Decimal test49_expected = 2.563;
	//	Decimal test50_expected = 2.813;
	//	Decimal test51_expected = 1.039;
	//	Decimal test52_expected = 1.289;
	//	Decimal test53_expected = 2.767;
	//	Decimal test54_expected = 3.061;
	//	Decimal test55_expected = 1.242;
	//	Decimal test56_expected = 1.537;
    	
    	
 //   	 //setupWrapper(RFQItemWrapper wrapper, String Body_Size, Decimal Ball_Count, String Mold_Process_Type, String location, Boolean Heatspreader, Decimal Substrate_Unit, 
	//	//             Decimal Substrate_Waste, Decimal Capacity_UE_Rate, String Wire_Material, Decimal Number_Of_Wires, Decimal LGP_Market_Price, Decimal Base_Customer_Au_Price, 
	//	//			Decimal AVG_2D_Wirelength, Boolean Apply_3D_Factor, Decimal Ball_WireSize_Ratio, String Wire_Diameter, Decimal Number_of_Chips_per_Package, Decimal Complex_Adder, 
	//	// 			String Mold_Type, Decimal Mold_Wastage, Decimal Substrate_Perc_Markup, Decimal Assembly, Decimal Total_3D_Wire_Length)
		
	//	Map<String, Decimal> costModelResults;
	//	Decimal costModel_I22;
		
	//	//Test49
	//	setupWrapper(wrapper, '27', 150.00, 'PGM', 'K4', false,  0.5,
	//				0.02, 0.75, 'Au', 150.00, 1700.00, 525.00,
	//				4.31727, true, 1.8, '2', 1.0, 0.00,
	//				'Standard', 0.095, 5, 40, 686.44478);					
	//	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());		
	//	costModelResults = PBGACostModelCalculator.getCostModelResults(); 		
		
	//	costModel_I22 = costModelResults.get('costModel_I22');
	//	Test.startTest();
	//	System.assert(Math.abs(costModel_I22 - test49_expected) < 0.001, 'Test 49 failed' + ' costModel_I22 calulated value is ' + costModel_I22);		                                                                     				
		                                                                      
		                                                                    
	//	//Test50                                                               
	//	setupWrapper(wrapper, '27', 150.00, 'PGM', 'K4', false,  0.5,
	//				0.02, 0.75, 'Au', 150.00, 1700.00, 525.00,
	//				4.31727, true, 1.8, '2', 2.0, 0.00,
	//				'Standard', 0.095, 5, 40, 686.44478);					
	//	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	//	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
		
	//	costModel_I22  = costModelResults.get('costModel_I22' );
	//	System.assert(Math.abs(costModel_I22 - test50_expected) < 0.001, 'Test 50 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
		
		
	//	//Test51
	//	setupWrapper(wrapper, '27', 150.00, 'PGM', 'K4', false,  0.5,
	//				0.02, 0.75, 'PCC', 150.00, 1700.00, 525.00,
	//				4.31727, true, 1.8, '2', 1.0, 0.00,
	//				'Standard', 0.095, 5, 40, 686.44478);					
	//	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	//	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	//	costModel_I22  = costModelResults.get('costModel_I22' );
	//	System.assert(Math.abs(costModel_I22 - test51_expected) < 0.001, 'Test 51 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
	//	//Test52
	//	setupWrapper(wrapper, '27', 150.00, 'PGM', 'K4', false,  0.5,
	//				0.02, 0.75, 'PCC', 150.00, 1700.00, 525.00,
	//				4.31727, true, 1.8, '2', 2.0, 0.00,
	//				'Standard', 0.095, 5, 40, 686.44478);					
	//	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	//	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	//	costModel_I22  = costModelResults.get('costModel_I22' );
	//	System.assert(Math.abs(costModel_I22 - test52_expected) < 0.001, 'Test 52 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
	//	//Test53
	//	setupWrapper(wrapper, '27', 150.00, 'PGM', 'K4', true,  0.5,
	//				0.02, 0.75, 'Au', 150.00, 1700.00, 525.00,
	//				4.31727, true, 1.8, '2', 1.0, 0.00,
	//				'Standard', 0.095, 5, 40, 686.44478);					
	//	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	//	costModelResults = PBGACostModelCalculator.getCostModelResults();
	//	costModel_I22 = costModelResults.get('costModel_I22' ); 
	//	System.assert(Math.abs(costModel_I22 - test53_expected) < 0.001, 'Test 53 failed' + ' costModel_I22 calulated value is ' + costModel_I22);		
														
	//	//Test54
	//	setupWrapper(wrapper, '27', 150.00, 'PGM', 'K4', true,  0.5,
	//				0.02, 0.75, 'Au', 150.00, 1700.00, 525.00,
	//				4.31727, true, 1.8, '2', 2.0, 0.00,
	//				'Standard', 0.095, 5, 40, 686.44478);					
	//	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	//	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	//	costModel_I22  = costModelResults.get('costModel_I22' );
	//	System.assert(Math.abs(costModel_I22 - test54_expected) < 0.001, 'Test 54 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
	//	//Test55
	//	setupWrapper(wrapper, '27', 150.00, 'PGM', 'K4', true,  0.5,
	//				0.02, 0.75, 'PCC', 150.00, 1700.00, 525.00,
	//				4.31727, true, 1.8, '2', 1.0, 0.00,
	//				'Standard', 0.095, 5, 40, 686.44478);					
	//	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	//	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	//	costModel_I22  = costModelResults.get('costModel_I22' );
	//	System.assert(Math.abs(costModel_I22 - test55_expected) < 0.001, 'Test 55 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
		
	//	//Test56
	//	setupWrapper(wrapper, '27', 150.00, 'PGM', 'K4', true,  0.5,
	//				0.02, 0.75, 'PCC', 150.00, 1700.00, 525.00,
	//				4.31727, true, 1.8, '2', 2.0, 0.00,
	//				'Standard', 0.095, 5, 40, 686.44478);					
	//	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	//	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	//	costModel_I22  = costModelResults.get('costModel_I22' );
	//	System.assert(Math.abs(costModel_I22 - test56_expected) < 0.001, 'Test 56 failed' + ' costModel_I22 calulated value is ' + costModel_I22);		
		

	
    	
	//}
	
	// private static testMethod void  testCostModelGroup8(){
	// 	RFQItemWrapper wrapper = setupTest();				
								    	
    	
 //    	//Expected test results from AMK282 excel sheet
	// 	Decimal test57_expected = 2.451;
	// 	Decimal test58_expected = 2.625;
	// 	Decimal test59_expected = 0.943;
	// 	Decimal test60_expected = 1.117;		
	// 	Decimal test61_expected = 2.640;
	// 	Decimal test62_expected = 2.844;
	// 	Decimal test63_expected = 1.132;
	// 	Decimal test64_expected = 1.336;
    	
    	
 //    	 //setupWrapper(RFQItemWrapper wrapper, String Body_Size, Decimal Ball_Count, String Mold_Process_Type, String location, Boolean Heatspreader, Decimal Substrate_Unit, 
	// 	//             Decimal Substrate_Waste, Decimal Capacity_UE_Rate, String Wire_Material, Decimal Number_Of_Wires, Decimal LGP_Market_Price, Decimal Base_Customer_Au_Price, 
	// 	//			Decimal AVG_2D_Wirelength, Boolean Apply_3D_Factor, Decimal Ball_WireSize_Ratio, String Wire_Diameter, Decimal Number_of_Chips_per_Package, Decimal Complex_Adder, 
	// 	// 			String Mold_Type, Decimal Mold_Wastage, Decimal Substrate_Perc_Markup, Decimal Assembly, Decimal Total_3D_Wire_Length)
		
	// 	Map<String, Decimal> costModelResults;
	// 	Decimal costModel_I22;
		
	// 	//Test57
	// 	setupWrapper(wrapper, '27', 150.00, 'PGM', 'P3', false,  0.5,
	// 				0.02, 0.75, 'Au', 150.00, 1700.00, 525.00,
	// 				4.31727, true, 1.8, '2', 1.0, 0.00,
	// 				'Standard', 0.095, 5, 40, 686.44478);					
	// 	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	// 	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	// 	costModel_I22  = costModelResults.get('costModel_I22' );
	// 	Test.startTest();
	// 	System.assert(Math.abs(costModel_I22 - test57_expected) < 0.001, 'Test 57 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
		
	// 	//Test58
	// 	setupWrapper(wrapper, '27', 150.00, 'PGM', 'P3', false,  0.5,
	// 				0.02, 0.75, 'Au', 150.00, 1700.00, 525.00,
	// 				4.31727, true, 1.8, '2.0', 2.0, 0.00,
	// 				'Standard', 0.095, 5, 40, 686.44478);					
	// 	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	// 	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	// 	costModel_I22  = costModelResults.get('costModel_I22' );
	// 	System.assert(Math.abs(costModel_I22 - test58_expected) < 0.001, 'Test 58 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
	// 	//Test59
	// 	setupWrapper(wrapper, '27', 150.00, 'PGM', 'P3', false,  0.5,
	// 				0.02, 0.75, 'PCC', 150.00, 1700.00, 525.00,
	// 				4.31727, true, 1.8, '2.0', 1.0, 0.00,
	// 				'Standard', 0.095, 5, 40, 686.44478);					
	// 	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	// 	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	// 	costModel_I22  = costModelResults.get('costModel_I22' );
	// 	System.assert(Math.abs(costModel_I22 - test59_expected) < 0.001, 'Test 59 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
	// 	//Test60
	// 	setupWrapper(wrapper, '27', 150.00, 'PGM', 'P3', false,  0.5,
	// 				0.02, 0.75, 'PCC', 150.00, 1700.00, 525.00,
	// 				4.31727, true, 1.8, '2.0', 2.0, 0.00,
	// 				'Standard', 0.095, 5, 40, 686.44478);					
	// 	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	// 	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	// 	costModel_I22  = costModelResults.get('costModel_I22' );
	// 	System.assert(Math.abs(costModel_I22 - test60_expected) < 0.001, 'Test 60 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
		
	// 	//Test61
	// 	setupWrapper(wrapper, '27', 150.00, 'PGM', 'P3', true,  0.5,
	// 				0.02, 0.75, 'Au', 150.00, 1700.00, 525.00,
	// 				4.31727, true, 1.8, '2.0', 1.0, 0.00,
	// 				'Standard', 0.095, 5, 40, 686.44478);					
	// 	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	// 	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	// 	costModel_I22  = costModelResults.get('costModel_I22' );
	// 	System.assert(Math.abs(costModel_I22 - test61_expected) < 0.001, 'Test 61 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
		
	// 	//Test62
	// 	setupWrapper(wrapper, '27', 150.00, 'PGM', 'P3', true,  0.5,
	// 				0.02, 0.75, 'Au', 150.00, 1700.00, 525.00,
	// 				4.31727, true, 1.8, '2.0', 2.0, 0.00,
	// 				'Standard', 0.095, 5, 40, 686.44478);					
	// 	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	// 	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	// 	costModel_I22  = costModelResults.get('costModel_I22' );
	// 	System.assert(Math.abs(costModel_I22 - test62_expected) < 0.001, 'Test 62 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
	// 	//Test63
	// 	setupWrapper(wrapper, '27', 150.00, 'PGM', 'P3', true,  0.5,
	// 				0.02, 0.75, 'PCC', 150.00, 1700.00, 525.00,
	// 				4.31727, true, 1.8, '2.0', 1.0, 0.00,
	// 				'Standard', 0.095, 5, 40, 686.44478);					
	// 	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	// 	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	// 	costModel_I22  = costModelResults.get('costModel_I22' );
	// 	System.assert(Math.abs(costModel_I22 - test63_expected) < 0.001, 'Test 63 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
	// 	//Test64
	// 	setupWrapper(wrapper, '27', 150.00, 'PGM', 'P3', true,  0.5,
	// 				0.02, 0.75, 'PCC', 150.00, 1700.00, 525.00,
	// 				4.31727, true, 1.8, '2.0', 2.0, 0.00,
	// 				'Standard', 0.095, 5, 40, 686.44478);					
	// 	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	// 	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	// 	costModel_I22  = costModelResults.get('costModel_I22' );
	// 	System.assert(Math.abs(costModel_I22 - test64_expected) < 0.001, 'Test 64 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
		
					
	// 	Test.stopTest();
	
    	
	// }
	
	
	//private static testMethod void  testCostModelGroup9(){
	//	RFQItemWrapper wrapper = setupTest();				
								    	
    	
 //   	//Expected test results from AMK282 excel sheet
	//	// Decimal test65_expected = 3.893;
	//	// Decimal test66_expected = 3.813;
	//	Decimal test67_expected = 3.977;	
    	
    	
 //   	 //setupWrapper(RFQItemWrapper wrapper, String Body_Size, Decimal Ball_Count, String Mold_Process_Type, String location, Boolean Heatspreader, Decimal Substrate_Unit, 
	//	//             Decimal Substrate_Waste, Decimal Capacity_UE_Rate, String Wire_Material, Decimal Number_Of_Wires, Decimal LGP_Market_Price, Decimal Base_Customer_Au_Price, 
	//	//			Decimal AVG_2D_Wirelength, Boolean Apply_3D_Factor, Decimal Ball_WireSize_Ratio, String Wire_Diameter, Decimal Number_of_Chips_per_Package, Decimal Complex_Adder, 
	//	// 			String Mold_Type, Decimal Mold_Wastage, Decimal Substrate_Perc_Markup, Decimal Assembly, Decimal Total_3D_Wire_Length)
		
	//	Map<String, Decimal> costModelResults;
	//	Decimal costModel_I22;
		
	//	// //Test65
	//	// setupWrapper(wrapper, '27', 150.00, 'PGM', 'P3', true,  0.5,
	//	// 			0.02, 0.75, 'Au', 150.00, 3000.00, 525.00,
	//	// 			4.31727, false, 1.8, '2.0', 2.0, 0.00,
	//	// 			'Standard', 0.095, 5, 40, 686.44478);					
	//	// PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	//	// costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	//	// costModel_I22  = costModelResults.get('costModel_I22' );
	//	 Test.startTest();
	//	// System.assert(Math.abs(costModel_I22 - test65_expected) < 0.001, 'Test 65 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
	//	// //Test66
	//	// setupWrapper(wrapper, '27', 150.00, 'PGM', 'P3', true,  0.5,
	//	// 			0.02, 0.5, 'Au', 150.00, 3000.00, 525.00,
	//	// 			4.31727, false, 1.8, '2.0', 1.0, 0.00,
	//	// 			'Standard', 0.095, 5, 40, 686.44478);					
	//	// PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	//	// costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	//	// costModel_I22  = costModelResults.get('costModel_I22' );
	//	// System.assert(Math.abs(costModel_I22 - test66_expected) < 0.001, 'Test 66 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
	//	//Test67
	//	setupWrapper(wrapper, '27', 150.00, 'PGM', 'K4', true,  0.5,
	//				0.02, 0.5, 'Au', 150.00, 3000.00, 525.00,
	//				4.31727, false, 1.8, '2.0', 1.0, 0.00,
	//				'Standard', 0.095, 5, 40, 686.44478);					
	//	PBGACostModelCalculator.calculateAll(wrapper, true, new CMSettings());
	//	costModelResults = PBGACostModelCalculator.getCostModelResults(); 
		
	//	costModel_I22  = costModelResults.get('costModel_I22' );
	//	System.assert(Math.abs(costModel_I22 - test67_expected) < 0.001, 'Test 67 failed' + ' costModel_I22 calulated value is ' + costModel_I22);
		
		
					
	//	Test.stopTest();
	
    	
	//}

	//public static testMethod void testDieXDieYCost()
	//{
	//	RFQItemWrapper wrapper = setupTest();
	//	ApexPages.StandardController sc = new ApexPages.StandardController(wrapper.rfqItem);
	//	RFQItemEditController controller = new RFQItemEditController(sc);
	//	Test.startTest();
	//	//Test Die size x/y equals 0, still get price
	//	setupWrapper(wrapper, '27', 150.00, 'PGM', 'K4', true,  0.5,
	//				0.02, 0.75, 'PCC', 150.00, 1700.00, 525.00,
	//				4.31727, true, 1.8, '2', 2.0, 0.00,
	//				'Standard', 0.095, 5, 40, 686.44478);	


	//	controller.submitItem();
	//	controller.wrapper.specificRfqItem.put('Substrate_Unit__c', 3);
	//	controller.wrapper.rfqItem.put('Status__c', RFQItemDao.STATUS_NEW);
	//	controller.calculatePrice();
	//	//RFQBUItemPriceEditController buController = new RFQBUItemPriceEditController(sc);
	//	Decimal buPrice = (Decimal)controller.wrapper.specificRfqItem.get('BU_Price__c');

	//	controller.wrapper.rfqItem.put('Status__c', RFQItemDao.STATUS_PRICE_PENDING_BU);
	//	controller.calculatePrice();
	//	//RFQBUItemPriceEditController buController = new RFQBUItemPriceEditController(sc);
	//	Decimal buPrice2 = (Decimal)controller.wrapper.specificRfqItem.get('BU_Price__c');
		
	//	Test.stopTest();
		
	//	System.assertEquals(buPrice, null, 'BU Price should be null');
	//	System.assert(buPrice2 > 0, 'No BU Price without Die X and Die Y');
	//}

	//private static testMethod void  testFieldEditibility(){
	//	RFQItemWrapper wrapper = setupTest();
	//	RFQILayout layout = setupLayout(wrapper);			

	//	Test.startTest();

	//	setupWrapper(wrapper, '27', 150.00, 'PGM', 'K4', true,  0.5,
	//				0.02, 0.5, 'Au', 150.00, 3000.00, 525.00,
	//				4.31727, false, 1.8, '2.0', 1.0, 0.00,
	//				'Standard', 0.095, 5, 40, 686.44478);

	//	PBGACostModelCalculator.setEditabilityforNoCostModel(layout);

	//	List<RFQISectionAttribute>  attributes = layout.sectionMap.get('Cost and Price').attributes;
 //       for(RFQISectionAttribute attribute : attributes){
 //           if(attribute.fieldAPIName == 'CLAM_Total__c')
 //                System.assert(attribute.isEditable == false);
 //            if(attribute.fieldAPIName == 'Total_Materials__c')
 //                System.assert(attribute.isEditable == false);
 //            //if(attribute.fieldAPIName == 'BU_Price__c')
 //            //    System.assert(attribute.isEditable == false);
 //            if(attribute.fieldAPIName == 'BU_Price_Perc_GM__c')
 //                System.assert(attribute.isEditable == false);
 //            if(attribute.fieldAPIName == 'Perc_IRR_New__c')
 //                System.assert(attribute.isEditable == false);
 //            if(attribute.fieldAPIName == 'Perc_CM__c')
 //                System.assert(attribute.isEditable == false);             
 //            if(attribute.fieldAPIName == 'Operating_Cash_u__c')
 //                System.assert(attribute.isEditable == false);             
 //            if(attribute.fieldAPIName == 'Customer_Target_Price__c')
 //                System.assert(attribute.isEditable == false);             
 //            if(attribute.fieldAPIName == 'Sales_Target_Price__c')
 //                System.assert(attribute.isEditable == false);                         
 //       }			
	//	Test.stopTest();
	
    	
	//}
	
	//Use this function to test detail if there are error in your cost model
	private static void tesCostModelDetails(Map<String, Decimal> costModelResults){
			
		// for testing details
		
		Decimal costModel_I6  = costModelResults.get('costModel_I6' );
		Decimal costModel_I7  = costModelResults.get('costModel_I7');
		Decimal costModel_I8  = costModelResults.get('costModel_I8');
		Decimal costModel_I9  = costModelResults.get('costModel_I9');
		Decimal costModel_I12 = costModelResults.get('costModel_I12');
		Decimal costModel_I13 = costModelResults.get('costModel_I13');
		Decimal costModel_I14 = costModelResults.get('costModel_I14');
		Decimal costModel_I15 = costModelResults.get('costModel_I15');
		Decimal costModel_I16 = costModelResults.get('costModel_I16');
		Decimal costModel_I18 = costModelResults.get('costModel_I18');
		Decimal costModel_I19 = costModelResults.get('costModel_I19');
		Decimal costModel_I20 = costModelResults.get('costModel_I20');
		Decimal costModel_I24 = costModelResults.get('costModel_I24');
		
		System.assert(Math.abs(costModel_I6  - 4.509  ) < 0.001 ,'Test 17 failed' + ' costModel_I6 calulated value is '  + costModel_I6);
		System.assert(Math.abs(costModel_I7  - 676.289) < 0.001 ,'Test 17 failed' + ' costModel_I7 calulated value is '  + costModel_I7);
		System.assert(Math.abs(costModel_I8  - 0.136  ) < 0.001 ,'Test 17 failed' + ' costModel_I8 calulated value is '  + costModel_I8);
		System.assert(Math.abs(costModel_I9  - 0.160  ) < 0.001 ,'Test 17 failed' + ' costModel_I9 calulated value is '  + costModel_I9);
		System.assert(Math.abs(costModel_I12 - 0.53   ) < 0.001 ,'Test 17 failed' + ' costModel_I12 calulated value is ' + costModel_I12);
		System.assert(Math.abs(costModel_I13 - 0.256  ) < 0.001 ,'Test 17 failed' + ' costModel_I13 calulated value is ' + costModel_I13);
		System.assert(Math.abs(costModel_I14 - 0.045  ) < 0.001 ,'Test 17 failed' + ' costModel_I14 calulated value is ' + costModel_I14);
		System.assert(Math.abs(costModel_I15 - 0.012  ) < 0.001 ,'Test 17 failed' + ' costModel_I15 calulated value is ' + costModel_I15);
		System.assert(Math.abs(costModel_I16 - 0.844  ) < 0.001 ,'Test 17 failed' + ' costModel_I16 calulated value is ' + costModel_I16);
		System.assert(Math.abs(costModel_I18 - 0.03   ) < 0.001 ,'Test 17 failed' + ' costModel_I18 calulated value is ' + costModel_I18);
		System.assert(Math.abs(costModel_I19 - 0.197  ) < 0.001 ,'Test 17 failed' + ' costModel_I19 calulated value is ' + costModel_I19);
		System.assert(Math.abs(costModel_I20 - 0.227  ) < 0.001 ,'Test 17 failed' + ' costModel_I20 calulated value is ' + costModel_I20);
		System.assert(Math.abs(costModel_I24 - 1.476  ) < 0.001 ,'Test 17 failed' + ' costModel_I24 calulated value is ' + costModel_I24);
		
				
	}
	
	static private RFQItemWrapper setupTest(){
		
		//Delete items if having duplicated values
		// delete [select Id from RFQI_Field_Def__c];
		// delete [select Id from RFQ__c];
		// delete [select Id from RFQ_Item__c];
		//RFQAdminInstaller.cleanFactories();
		RFQAdminInstaller.install();
		RFQAdminInstaller.installFactories();
		PBGAInstaller.installTest();
		CMPBGAInstaller.install();
		RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('PBGA');
		
		Type t = Type.forName(wrapper.packageFamily.Product_Group__r.Cost_Model_Implementation__c);
    	PBGACostModelCalculator = (CMPBGABuilder)t.newInstance();
    	PBGACostModelCalculator.costModelTestMapInstall();
		
		return wrapper;
		
	}
	
	static private void setupWrapper(RFQItemWrapper wrapper, String Body_Size, Decimal Ball_Count, String Mold_Process_Type, String location, Boolean Heatspreader, Decimal Substrate_Unit, Decimal Substrate_Waste, Decimal Capacity_UE_Rate, String Wire_Material, Decimal Number_Of_Wires, Decimal LGP_Market_Price, Decimal Base_Customer_Au_Price, Decimal AVG_2D_Wirelength, Boolean Apply_3D_Factor, Decimal Ball_WireSize_Ratio, String Wire_Diameter, Decimal Number_of_Chips_per_Package, Decimal Complex_Adder, String Mold_Type, Decimal Mold_Wastage, Decimal Substrate_Perc_Markup, Decimal Assembly, Decimal Total_3D_Wire_Length){
		
		wrapper.setAttribute('Body_Size__c', 'Package', Body_Size);
		wrapper.setAttribute('Ball_Count__c', 'Package', Ball_Count);		
		wrapper.setAttribute('Mold_Process_Type__c', 'Package', Mold_Process_Type);
		Factory__c factory = [Select Name, id From Factory__c where Name =: location];
		wrapper.setAttribute('Factory__c', 'Package', factory.Id);
		wrapper.setAttribute('Heatspreader__c', 'Package', Heatspreader);
		wrapper.setAttribute('Materials_Substrate__c', 'Package', Substrate_Unit); 
		wrapper.setAttribute('Substrate_Waste__c', 'Package', Substrate_Waste);
		wrapper.setAttribute('Capacity_UE_Rate__c', 'Package', Capacity_UE_Rate);							
		wrapper.wireConfigurations[0].put('Wire_Material__c',Wire_Material);
		wrapper.wireConfigurations[0].put('Number_Of_Wires__c',Number_Of_Wires);	
		wrapper.productGroup.Au_Cost__c = LGP_Market_Price;
		wrapper.setAttribute('Base_Customer_Au_Price__c', 'Package', Base_Customer_Au_Price);
		wrapper.setAttribute('Apply_3D_Factor__c', 'Package', Apply_3D_Factor);
		wrapper.wireConfigurations[0].put('Average_2D_Wire_Length__c',AVG_2D_Wirelength);
		wrapper.wireConfigurations[0].put('Wire_Diameter__c',  Wire_Diameter);
		//Ball_WireSize_Ration__c is not used
		wrapper.setAttribute('Number_of_Chips_per_Package__c', 'Package', Number_of_Chips_per_Package);
		wrapper.setAttribute('Complex_Adder__c', 'Package', Complex_Adder);
		
		//To Do: Do we need them passing into wrapper because CMPBGABuilder has code to set these attribute. 
		//Not in the 67 test cases
		wrapper.setAttribute('Mold_Type__c', 'Package', Mold_Type);			
		wrapper.setAttribute('Mold_Wastage__c', 'Package', Mold_Wastage);
		wrapper.setAttribute('Substrate_Perc_Markup__c', 'Package', Substrate_Perc_Markup);
		wrapper.setAttribute('Assembly__c', 'Package', Assembly);
		
				
		if(wireCalculatorEnabled){
			
									
			//instantiate a cluculator
    		Type t = Type.forName(wrapper.packageFamily.Product_Group__r.Wire_Calculation_Implementation__c);
    		//CMPBGAWireCalc wireCalculator = (CMPBGAWireCalc)t.newInstance();
    		CMWireCalcBase wireCalculator = (CMWireCalcBase)t.newInstance();
        	wireCalculator.calculate(wrapper);
        	System.debug(LoggingLevel.ERROR, '#### enable calculator');					
			
		}
		else{
			wrapper.wireConfigurations[0].put('Total_2D_Wire_Length__c',  AVG_2D_Wirelength * Number_Of_Wires);
			wrapper.wireConfigurations[0].put('Total_3D_Wire_Length__c',  Total_3D_Wire_Length);
		}	
		
	}

	static private void setupWrapperNoCostModel(RFQItemWrapper wrapper, Decimal materials_substrate, Decimal materials_wire, Decimal materials_odm_other, Decimal materials_odm_mold, Decimal assembly, Decimal capacity_ue_rate, 
												Decimal clam_wb, Decimal clam_others, Decimal substrate_perc_markup, Decimal substrate_unit, Decimal substrate_waste, Decimal base_customer_au_price, 
												Decimal complex_adder, Decimal mold_Wastage, Boolean apply_3d_factor, Decimal lgp_market_price){

		//Column one
		wrapper.specificRfqItem.put('Materials_Substrate__c', materials_substrate);
		wrapper.specificRfqItem.put('Materials_Wire__c', materials_wire);
		wrapper.specificRfqItem.put('Materials_ODM_Other__c', materials_odm_other);
		wrapper.specificRfqItem.put('Materials_ODM_Mold__c', materials_odm_mold);
		wrapper.specificRfqItem.put('Assembly__c', assembly);
		wrapper.specificRfqItem.put('Capacity_UE_Rate__c', capacity_ue_rate);

		//Column two
		wrapper.specificRfqItem.put('CLAM_WB__c', clam_wb);
		wrapper.specificRfqItem.put('CLAM_Others__c', clam_others);
		wrapper.specificRfqItem.put('Substrate_Perc_Markup__c', substrate_perc_markup);
		wrapper.specificRfqItem.put('Substrate_Unit__c', substrate_unit);
		wrapper.specificRfqItem.put('Substrate_Waste__c', substrate_waste);
		wrapper.specificRfqItem.put('Base_Customer_Au_Price__c', base_customer_au_price);

		//Column three and four
		wrapper.specificRfqItem.put('Complex_Adder__c', complex_adder);
		wrapper.specificRfqItem.put('Mold_Wastage__c', mold_Wastage);
		wrapper.specificRfqItem.put('Apply_3D_Factor__c', apply_3d_factor);
		wrapper.specificRfqItem.put('LGP_Market_Price__c', lgp_market_price);


	}

	private static RFQILayout setupLayout(RFQItemWrapper wrapper)
    {
        RFQILayout layout = PFFieldDefDao.getInstance().getPackageFamilyLayout(wrapper.packageFamily.Id, wrapper.packageFamily.Layout_Version__c, (Decimal)wrapper.rfqItem.get('Layout_Version__c'));

        //Loop over OtherAttributes, check if they contain other
        //if they do, add attribute 
        for(String fieldName : layout.getOtherFieldApiNames()) { 
            String fieldValue = String.valueOf(wrapper.getAttribute(fieldName, RFQItemWrapper.PACKAGE_OBJECT, 0));
            if(fieldValue != null && fieldValue.toLowerCase() == 'other') {
                layout.addAttributeForOtherField(fieldName);
            }
        }

        Decimal salesScreenColumns = wrapper.packageFamily.Product_Group__r.Sales_Screen_Columns__c;
        Decimal buScreenColumns = wrapper.packageFamily.Product_Group__r.BU_Screen_Columns__c;
        layout.setBUColumns(Integer.valueOf(bUScreenColumns));
        layout.setSalesColumns(Integer.valueOf(salesScreenColumns));

        wrapper.calculateAttributeVisibility(layout);
        return layout;
    }


}