/*************************************************************************
*
* PURPOSE: fcBGA Installer
*
* CLASS: CMfcBGAInstaller
* CREATED: 7/29/2013 Ethos Solutions - www.ethos.com 
* AUTHOR: Austin Delorme
***************************************************************************/ 
global class CMfcBGAInstaller extends CMFCMInstaller
{
	global static void cleanAndInstall() 
	{
		clean();
		CMfcBGAInstaller installer = new CMfcBGAInstaller();
		//installer.cleanAll();
		installer.installFCM(); 
	}
	
	global static void install() 
	{
		CMfcBGAInstaller installer = new CMfcBGAInstaller();
		installer.installFCM();
	}
	
	global static void clean() 
	{
		CMfcBGAInstaller installer = new CMfcBGAInstaller();
		installer.clean('FC BGA');
	}
	
	public override void installFCM()
	{

		pgName = 'Flip Chip';
		setupInstaller();
		
		pg.Au_Cost__c = 1690;
		update pg;
		loadPfMap();


		List<Package_Family__c> families = pfMap.values();

        CM_PF_Value__c pfValue;
        List<CM_PF_Value__c> pfValueList = new List<CM_PF_Value__c>();
        for (Package_Family__c family : families)
        {
            pfValue = new CM_PF_Value__c(CM_Version__c=cmVersion.Id, Package_Family__c=family.Id, Subs_Markup_Perc__c=5, Base_Customer_Au_Price__c=1000, Assembly_GM_wo_Substrate__c=30);
            if (family.Name == 'FC BGA') {
            	pfValue.Cutting_Speed__c = 7874;
            	pfValue.Good_Die_Density__c = 0.6;
            	pfValue.GDPW_Die_Yield__c = 0.9;
				pfValue.EMC_Cost_Per_Gram__c = 0.0722;
				pfValue.Groove_Width__c = 3;
				pfValue.Mold_Cap_Taper__c = 0;
				pfValue.Substrate_Perimeter_Clearance__c = 1;
				pfValue.DA_Thickness__c = 0.06;
				pfValue.Pellet_Volume__c = 1.935;
				pfValue.Capacitor_UPH_Adder__c = 1.79149091;
				pfValue.Capacitor_UPH_Multiplier__c = 0.00689091;
            }
            pfValueList.add(pfValue);
        }
        insert pfValueList;


		
		fieldMap = new Map<String, RFQI_Field_Def__c>();
		List<RFQI_Field_Def__c> fieldList = [select id, name from RFQI_Field_Def__c];
		for(RFQI_Field_Def__c row : fieldList) fieldMap.put(row.name, row);
		
		loadAssumptions();
		loadBoms();
		loadProcs();
		loadMatches();
		loadFactoryValues();

		postInstall();
	}
	
	private void loadAssumptions()
	{
		Map<String, String> factoryMap = new Map<String, String>();
		for (Factory__c row : FactoryDao.getInstance().getAllFactories()) factoryMap.put(row.name, row.Id);

		List<FCM_Assumption__c> assumptionList = new List<FCM_Assumption__c>();
		
		FCM_Assumption__c fcmA = new FCM_Assumption__c(CM_Version__c=cmVersion.id, Product_Group__c=pgId);
		fcmA.Factory__c = factoryMap.get('T3');
		fcmA.Cum_Yield_Percent__c = 100;
		fcmA.Utilization_Efficiency_Percent__c = 85.0;
		fcmA.Manuf_OH_To_Process_Cost__c = 0.163936996556778;
		fcmA.QA_Cost_To_Process_Cost__c = 0.08010322732;
		fcmA.Service_Cost_To_Process_Cost__c = 0.04607093132;
		fcmA.Available_Hours_Per_Week__c = 168;
		fcmA.Direct_Labor_Rate__c = 8.53524788047;
		fcmA.Off_Equipment_Direct_To_Direct__c =  0.154628048575977;
		fcmA.Equipment_Life__c = 7;
		fcmA.Work_Weeks_Year__c = 50;
		fcmA.Annual_Fac_Cost_Sqft__c = 101.51147586230;
		fcmA.Material_Freight_Percent__c = 2;
		fcmA.Substrate_Freight_Percent__c = 1;
		fcmA.Material_Tooling_Percent__c = 0;
		fcmA.Material_Brokerage_Percent__c = 0;
		fcmA.Forecast_Factor_1__c = 1.12000000000;
		fcmA.Forecast_Factor_2__c = 1.12000000000;
		fcmA.Forecast_Factor_3__c = 1.12000000000;
		fcmA.FCM_Is_Dedicated__c = false;

		fcma.Utilization_Efficiency_Percent_T1__c = 40.0; 
		fcma.Utilization_Efficiency_Percent_T2__c = 50.0; 
		fcma.Utilization_Efficiency_Percent_T3__c = 50.0; 
		fcma.Utilization_Efficiency_Percent_T4__c = 60.0; 
		fcma.Utilization_Efficiency_Percent_T5__c = 70.0; 
		fcma.Utilization_Efficiency_Percent_T6__c = 80.0; 
		fcma.Utilization_Efficiency_Percent_T7__c = 85.0; 
		fcma.Utilization_Efficiency_Percent_T7__c = 85.0; 
		assumptionList.add( fcmA);

		fcmA = new FCM_Assumption__c(CM_Version__c=cmVersion.id, Product_Group__c=pgId);
		fcmA.Factory__c = factoryMap.get('P3');
		fcmA.Cum_Yield_Percent__c = 100;
		fcmA.Utilization_Efficiency_Percent__c = 85.0;
		fcmA.Manuf_OH_To_Process_Cost__c = 0.208042420828615;
		fcmA.Available_Hours_Per_Week__c = 168;
		fcmA.Work_Weeks_Year__c = 50;
		fcmA.Direct_Labor_Rate__c = 1.805742538723900;
		fcmA.Equipment_Life__c = 7;
		fcmA.Annual_Fac_Cost_Sqft__c = 167.330064780887000;
		fcmA.QA_Cost_To_Process_Cost__c = 0.040633285318089;
		fcmA.Service_Cost_To_Process_Cost__c = 0.065338322791487;
		fcmA.Off_Equipment_Direct_To_Direct__c = 0.258584652134966;

		fcmA.Material_Freight_Percent__c = 2;
		fcmA.Substrate_Freight_Percent__c = 1;
		fcmA.Material_Tooling_Percent__c = 0;
		fcmA.Forecast_Factor_1__c = 3.78691836510631;
		fcmA.FCM_Is_Dedicated__c = false;

		fcma.Utilization_Efficiency_Percent_T1__c = 40.0; 
		fcma.Utilization_Efficiency_Percent_T2__c = 50.0; 
		fcma.Utilization_Efficiency_Percent_T3__c = 50.0; 
		fcma.Utilization_Efficiency_Percent_T4__c = 60.0; 
		fcma.Utilization_Efficiency_Percent_T5__c = 70.0; 
		fcma.Utilization_Efficiency_Percent_T6__c = 80.0; 
		fcma.Utilization_Efficiency_Percent_T7__c = 85.0; 
		fcma.Utilization_Efficiency_Percent_T7__c = 85.0; 
		assumptionList.add( fcmA);

		fcmA = new FCM_Assumption__c(CM_Version__c=cmVersion.id, Product_Group__c=pgId);
		fcmA.Factory__c = factoryMap.get('K4');
		fcmA.Cum_Yield_Percent__c = 100;
		fcmA.Utilization_Efficiency_Percent__c = 85.0;
		fcmA.Manuf_OH_To_Process_Cost__c = 0.289749069566146;
		fcmA.QA_Cost_To_Process_Cost__c = 0.0583154278811361;
		fcmA.Service_Cost_To_Process_Cost__c = 0.0608747256564837;
		fcmA.Available_Hours_Per_Week__c = 168;
		fcmA.Direct_Labor_Rate__c = 14.76922;
		fcmA.Off_Equipment_Direct_To_Direct__c = 0;
		fcmA.Equipment_Life__c = 7;
		fcmA.Work_Weeks_Year__c = 50;
		fcmA.Annual_Fac_Cost_Sqft__c = 105.891055272221;
		fcmA.Material_Freight_Percent__c = 2;
		fcmA.Substrate_Freight_Percent__c = 1;
		fcmA.Material_Tooling_Percent__c = 0;
		fcmA.Material_Brokerage_Percent__c = 0;
		fcmA.Forecast_Factor_1__c = 1.4577391304348;
		fcmA.Forecast_Factor_2__c = 1.4577391304348;
		fcmA.Forecast_Factor_3__c = 1.4577391304348;
		fcmA.FCM_Is_Dedicated__c = false;

		fcma.Utilization_Efficiency_Percent_T1__c = 40.0; 
		fcma.Utilization_Efficiency_Percent_T2__c = 50.0; 
		fcma.Utilization_Efficiency_Percent_T3__c = 50.0; 
		fcma.Utilization_Efficiency_Percent_T4__c = 60.0; 
		fcma.Utilization_Efficiency_Percent_T5__c = 70.0; 
		fcma.Utilization_Efficiency_Percent_T6__c = 80.0; 
		fcma.Utilization_Efficiency_Percent_T7__c = 85.0; 
		fcma.Utilization_Efficiency_Percent_T7__c = 85.0; 
		assumptionList.add( fcmA);
		
		insert assumptionList;
	}
	
	private void loadBoms()
	{
		//public void loadBom(String name, String typeVal,String seq, String pg,string pf, String catVal, String leadCount, String hasVariants, string uom, String decription, String parent, String sid, String costUnit, String usageScrap, String baseQty, String column, String mfgCost, String purchasePrice, String row, String stdUsage, String stripSublot, String troyOz, String groupName, String usageRate, String index, String timePerWire)


		//=CONCATENATE("loadBom('", C67 ,"','Item','", Z67 ,"','Flip Chip','','Leadframe','','TRUE','", E67, "','", D67, "','','','','", H67,"','','','','", F67, "','','','','','Leadframe','','','');")

		//adBom name	 				typeVal seq	 	pg 			 pf		catVal	 			leadCount	hasVariants		uom		decription			parent		sid	costUnit	usageScrap	baseQty	column	mfgCost	purchasePrice	row	stdUsage			stripSublot	troyOz	groupName	usageRate	index	timePerWire)
		loadBom('Substrate',			'Item',	'0',	'Flip Chip', '',	'Substrate',		'',			'FALSE',		'KPC',		'',					'',		'',	'',			'1.0035',	'',		'',		'',		'',				'',	'1000',				'',			'',		'Substrate','',			'',		'');
		loadBom('Flux',					'Item',	'100',	'Flip Chip', '',	'Flux',				'',			'TRUE',			'gram',		'',					'',		'',	'',			'1.2',		'',		'',		'',		'0.253',		'',	'', 				'',			'',		'ODM',		'',			'',		'');
		loadBom('Capacitor Paste/Flux',	'Item',	'200',	'Flip Chip', '',	'Paste/Flux',		'',			'TRUE',			'gram',		'',					'',		'',	'',			'1.3',		'',		'',		'',		'',				'',	'', 				'',			'',		'ODM',		'',			'',		'');
		loadBom('Capacitor',			'Item',	'300',	'Flip Chip', '',	'Capacitor',		'',			'FALSE',		'KPC',		'402',				'',		'',	'',			'1.01',		'',		'',		'',		'', 			'',	'', 				'',			'',		'ODM',		'',			'',		'');
		//loadBom('Capacitor B',			'Item',	'400',	'Flip Chip', '',	'',					'',			'FALSE',		'KPC',		'402',				'',		'',	'',			'1.01',		'',		'',		'',		'', 			'',	'', 				'',			'',		'ODM',		'',			'',		'');
		loadBom('Underfill',			'Item',	'500',	'Flip Chip', '',	'Underfill',		'',			'TRUE',			'gram',		'',					'',		'',	'',			'1.3',		'',		'',		'',		'',				'',	'', 				'',			'',		'ODM',		'',			'',		'');
		loadBom('Stiffener 0.5mm',		'Item',	'600',	'Flip Chip', '',	'',					'',			'TRUE',			'KPC',		'14mm',				'',		'',	'',			'1.003',	'',		'',		'',		'0.120924',		'',	'1000', 			'',			'',		'ODM',		'',			'',		'');
		loadBom('Stiffener 1.0mm',		'Item',	'600',	'Flip Chip', '',	'',					'',			'TRUE',			'KPC',		'14mm',				'',		'',	'',			'1.003',	'',		'',		'',		'0.120924',		'',	'1000', 			'',			'',		'ODM',		'',			'',		'');
		loadBom('Stiffener Adhesive',	'Item',	'700',	'Flip Chip', '',	'Adhesive',			'',			'TRUE',			'gram',		'',					'',		'',	'',			'1.2',		'',		'',		'',		'',				'',	'',					'',			'',		'ODM',		'',			'',		'');
		loadBom('Heatspreader 0.5mm',	'Item',	'800',	'Flip Chip', '',	'',					'',			'TRUE',			'KPC',		'0.5mm',			'',		'',	'',			'1.003',	'',		'',		'',		'',				'',	'1000',				'',			'',		'ODM',		'',			'',		'');
		loadBom('Heatspreader 1.0mm',	'Item',	'800',	'Flip Chip', '',	'',					'',			'TRUE',			'KPC',		'1.0mm',			'',		'',	'',			'1.003',	'',		'',		'',		'',				'',	'1000',				'',			'',		'ODM',		'',			'',		'');
		loadBom('H/S Adhesive',			'Item',	'900',	'Flip Chip', '',	'Adhesive',			'',			'TRUE',			'gram',		'',					'',		'',	'',			'1.2',		'',		'',		'',		'',				'',	'',					'',			'',		'ODM',		'',			'',		'');
		loadBom('TIM',					'Item',	'1000',	'Flip Chip', '',	'TIM',				'',			'TRUE',			'gram',		'SHA-1',			'',		'',	'',			'1.3',		'',		'',		'',		'1.55',			'',	'',					'',			'',		'ODM',		'',			'',		'');
		loadBom('Solder Balls',			'Item',	'1100',	'Flip Chip', '',	'Solder Balls',		'',			'TRUE',			'K Pieces',	'0.4MM',			'',		'',	'',			'1.05',		'',		'',		'',		'0.023',		'',	'',					'',			'',		'ODM',		'',			'',		'');
		loadBom('Solder Ball Flux',		'Item',	'1200',	'Flip Chip', '',	'',					'',			'TRUE',			'gram',		'',					'',		'',	'',			'1.2',		'',		'',		'',		'0.195',		'',	'10.000',			'',			'',		'ODM',		'',			'',		'');
		loadBom('Tray',					'Item',	'1300',	'Flip Chip', '',	'Tray',				'',			'FALSE',		'Ea',		'Std',				'',		'',	'',			'1.01',		'',		'',		'',		'1',			'',	'',					'',			'',		'ODM',		'',			'',		'');
		loadBom('WBG Tape',				'Item',	'1400',	'Flip Chip', '',	'WBG Tape',			'',			'FALSE',		'',			'$6.7/wafer',		'',		'',	'',			'',			'',		'',		'',		'6.7',			'',	'',					'',			'',		'ODM',		'',			'',		'');
		loadBom('OverMold',				'Item',	'1500',	'Flip Chip', '',	'OverMold',			'',			'FALSE',		'KG',		'8.5g Pellet Size',	'',		'',	'',			'',			'',		'',		'',		'72.2',			'',	'',					'',			'',		'ODM',		'',			'',		'');
		loadBom('OverMold Softec',		'Item',	'1600',	'Flip Chip', '',	'OverMold Softec',	'',			'TRUE',			'KPC',		'Softec',			'',		'',	'',			'1.05',		'',		'',		'',		'4',			'',	'',					'',			'',		'ODM',		'',			'',		'');
		
		//---Save current list and load into map (For parent matching) 
		insert bomList;
		bomMap = new Map<String, FCM_BOM__c>();
		for(FCM_BOM__c row : bomList) bomMap.put(row.name, row);
		bomList = new List<FCM_BOM__c>();		

		//=CONCATENATE("loadBom('Stiffener Adhesive ", B28, "',	'Variant',	'700',	'Flip Chip', '',	'',				'',			'FALSE',		'',		'", B28, "',			'',			'',	'',			'',					'',		'',		'',		'", G28, "',				'',	'", I28, "',					'',			'',		'',	'',			'',		'');")
		//adBom name	 					typeVal 	seq	 	pg 			 pf	 catVal	 leadCount	hasVariants	uom		decription			parent					sid	costUnit	usageScrap	baseQty	column	mfgCost	purchasePrice		row		stdUsage stripSublot	troyOz	groupName	usageRate	index	timePerWire)


		loadBom('Flux AWF-5',			'Variant', '1100',	'Flip Chip', '', '',	'', 	'FALSE',		'',		'AWF-5',					'Flux',				'',		  '',	 '',		'',	'',		'',	 '0.195',					'',			'',			'',			'',			'',			'',			'',			'');
		loadBom('Flux AWFJ-5',			'Variant', '1100',	'Flip Chip', '', '',	'', 	'FALSE',		'',		'AWFJ-5',					'Flux',				'',		  '',	 '',		'',	'',		'',	 '0.3',						'',			'',			'',			'',			'',			'',			'',			'');
		loadBom('Flux AWF-7',			'Variant', '1100',	'Flip Chip', '', '',	'', 	'FALSE',		'',		'AWF-7',					'Flux',				'',		  '',	 '',		'',	'',		'',	 '0.253',					'',			'',			'',			'',			'',			'',			'',			'');
		loadBom('Flux SCF-1',			'Variant', '1100',	'Flip Chip', '', '',	'', 	'FALSE',		'',		'SCF-1',					'Flux',				'',		  '',	 '',		'',	'',		'',	 '0.37',					'',			'',			'',			'',			'',			'',			'',			'');
		loadBom('Flux SCFJ-1',			'Variant', '1100',	'Flip Chip', '', '',	'', 	'FALSE',		'',		'SCFJ-1',					'Flux',				'',		  '',	 '',		'',	'',		'',	 '0.15547263681592',		'',			'',			'',			'',			'',			'',			'',			'');
		loadBom('Flux SCF-5',			'Variant', '1100',	'Flip Chip', '', '',	'', 	'FALSE',		'',		'SCF-5',					'Flux',				'',		  '',	 '',		'',	'',		'',	 '0.264',					'',			'',			'',			'',			'',			'',			'',			'');

		//=CONCATENATE("loadBom('Capacitor Paste/Flux ", B6 ,"',	'Variant', '200',  'Flip Chip',	'',	'',		'',		'FALSE',		'',		'", B6 ,"',					'Underfill',		 '',	  '',	  '',	   '',	 '',	'',	 '", G6 ,"',		'',		'',	'',	  '',	'',	  '',	  '',	'');"
		loadBom('Capacitor Paste/Flux HCP-1', 'Variant', '200',  'Flip Chip', '', '',  '',  'FALSE',  '',  			'HCP-1',     				'Capacitor Paste/Flux',   '',   '',   '',    '',  '', '',  		'0.074',	'',  '', '',   '', '',   '',   '', '');
		loadBom('Capacitor Paste/Flux ACP-1', 'Variant', '200',  'Flip Chip', '', '',  '',  'FALSE',  '',  			'ACP-1',     				'Capacitor Paste/Flux',   '',   '',   '',    '',  '', '',  		'0.19',		'',  '', '',   '', '',   '',   '', '');
		loadBom('Capacitor Paste/Flux SCP-5', 'Variant', '200',  'Flip Chip', '', '',  '',  'FALSE',  '',  			'SCP-5',     				'Capacitor Paste/Flux',   '',   '',   '',    '',  '', '',  		'0.193',	'',  '', '',   '', '',   '',   '', '');
		loadBom('Capacitor Paste/Flux SCF-2', 'Variant', '200',  'Flip Chip', '', '',  '',  'FALSE',  '',  			'SCF-2',     				'Capacitor Paste/Flux',   '',   '',   '',    '',  '', '',  		'0.248',	'',  '', '',   '', '',   '',   '', '');
		loadBom('Capacitor Paste/Flux DCP-2', 'Variant', '200',  'Flip Chip', '', '',  '',  'FALSE',  '',  			'DCP-2',     				'Capacitor Paste/Flux',   '',   '',   '',    '',  '', '',  		'0.09',		'',  '', '',   '', '',   '',   '', '');
		loadBom('Capacitor Paste/Flux DCP-1', 'Variant', '200',  'Flip Chip', '', '',  '',  'FALSE',  '',  			'DCP-1',     				'Capacitor Paste/Flux',   '',   '',   '',    '',  '', '',  		'0.06',		'',  '', '',   '', '',   '',   '', '');


		loadBom('Underfill NAU-6',		'Variant', '500',  'Flip Chip',	'',	'',		'',		'FALSE',		'',		'NAU-6',					'Underfill',		 '',	  '',	  '',	   '',	 '',	'',	 '1.02',		'',		'1.6',	'',	  '',	'',	  '',	  '',	'');
		loadBom('Underfill NAU-8',		'Variant', '500',  'Flip Chip',	'',	'',		'',		'FALSE',		'',		'NAU-8',					'Underfill',		 '',	  '',	  '',	   '',	 '',	'',	 '1.0',			'',		'1.6',	'',	  '',	'',	  '',	  '',	'');
		loadBom('Underfill NAU-12',		'Variant', '500',  'Flip Chip',	'',	'',		'',		'FALSE',		'',		'NAU-12',					'Underfill',		 '',	  '',	  '',	   '',	 '',	'',	 '3.5',			'',		'1.6',	'',	  '',	'',	  '',	  '',	'');
		loadBom('Underfill NAU-14',		'Variant', '500',  'Flip Chip',	'',	'',		'',		'FALSE',		'',		'NAU-14',					'Underfill',		 '',	  '',	  '',	   '',	 '',	'',	 '1.03',		'',		'1.6',	'',	  '',	'',	  '',	  '',	'');
		loadBom('Underfill NAU-19',		'Variant', '500',  'Flip Chip',	'',	'',		'',		'FALSE',		'',		'NAU-19',					'Underfill',		 '',	  '',	  '',	   '',	 '',	'',	 '0.99',		'',		'1.6',	'',	  '',	'',	  '',	  '',	'');
		loadBom('Underfill NAU-27',		'Variant', '500',  'Flip Chip',	'',	'',		'',		'FALSE',		'',		'NAU-27',					'Underfill',		 '',	  '',	  '',	   '',	 '',	'',	 '1.34',		'',		'1.6',	'',	  '',	'',	  '',	  '',	'');
		loadBom('Underfill SEU-1',		'Variant', '500',  'Flip Chip',	'',	'',		'',		'FALSE',		'',		'SEU-1',					'Underfill',		 '',	  '',	  '',	   '',	 '',	'',	 '1.95',		'',		'1.6',	'',	  '',	'',	  '',	  '',	'');

		loadBom('Stiffener 0.5mm 15',	'Variant', '600',  'Flip Chip', '', '',     '', 	'FALSE',    	'',   	'0.5mm Lid 15 Body',		'Stiffener 0.5mm',   '',  '',     '',      '',   '',   '',   '0.126',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Stiffener 0.5mm 17',	'Variant', '600',  'Flip Chip', '', '',     '', 	'FALSE',    	'',   	'0.5mm Lid 17 Body',		'Stiffener 0.5mm',   '',  '',     '',      '',   '',   '',   '0.135',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Stiffener 0.5mm 19',	'Variant', '600',  'Flip Chip', '', '',     '', 	'FALSE',    	'',   	'0.5mm Lid 19 Body',		'Stiffener 0.5mm',   '',  '',     '',      '',   '',   '',   '0.144',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Stiffener 0.5mm 21',	'Variant', '600',  'Flip Chip', '', '',     '', 	'FALSE',    	'',   	'0.5mm Lid 21 Body',		'Stiffener 0.5mm',   '',  '',     '',      '',   '',   '',   '0.153',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Stiffener 0.5mm 23',	'Variant', '600',  'Flip Chip', '', '',     '', 	'FALSE',    	'',   	'0.5mm Lid 23 Body',		'Stiffener 0.5mm',   '',  '',     '',      '',   '',   '',   '0.162',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Stiffener 0.5mm 25',	'Variant', '600',  'Flip Chip', '', '',     '', 	'FALSE',    	'',   	'0.5mm Lid 25 Body',		'Stiffener 0.5mm',   '',  '',     '',      '',   '',   '',   '0.171',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Stiffener 0.5mm 27',	'Variant', '600',  'Flip Chip', '', '',     '', 	'FALSE',    	'',   	'0.5mm Lid 27 Body',		'Stiffener 0.5mm',   '',  '',     '',      '',   '',   '',   '0.18',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Stiffener 0.5mm 29',	'Variant', '600',  'Flip Chip', '', '',     '', 	'FALSE',    	'',   	'0.5mm Lid 29 Body',		'Stiffener 0.5mm',   '',  '',     '',      '',   '',   '',   '0.198',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Stiffener 0.5mm 31',	'Variant', '600',  'Flip Chip', '', '',     '', 	'FALSE',    	'',   	'0.5mm Lid 31 Body',		'Stiffener 0.5mm',   '',  '',     '',      '',   '',   '',   '0.207',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Stiffener 0.5mm 33',	'Variant', '600',  'Flip Chip', '', '',     '', 	'FALSE',    	'',   	'0.5mm Lid 33 Body',		'Stiffener 0.5mm',   '',  '',     '',      '',   '',   '',   '0.225',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Stiffener 0.5mm 35',	'Variant', '600',  'Flip Chip', '', '',     '', 	'FALSE',    	'',   	'0.5mm Lid 35 Body',		'Stiffener 0.5mm',   '',  '',     '',      '',   '',   '',   '0.234',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Stiffener 0.5mm 37.5',	'Variant', '600',  'Flip Chip', '', '',     '', 	'FALSE',    	'',   	'0.5mm Lid 37.5 Body',		'Stiffener 0.5mm',   '',  '',     '',      '',   '',   '',   '0.2565',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Stiffener 0.5mm 40',	'Variant', '600',  'Flip Chip', '', '',     '', 	'FALSE',    	'',   	'0.5mm Lid 40 Body',		'Stiffener 0.5mm',   '',  '',     '',      '',   '',   '',   '0.279',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Stiffener 0.5mm 42.5',	'Variant', '600',  'Flip Chip', '', '',     '', 	'FALSE',    	'',   	'0.5mm Lid 42.5 Body',		'Stiffener 0.5mm',   '',  '',     '',      '',   '',   '',   '0.3015',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Stiffener 0.5mm 45',	'Variant', '600',  'Flip Chip', '', '',     '', 	'FALSE',    	'',   	'0.5mm Lid 45 Body',		'Stiffener 0.5mm',   '',  '',     '',      '',   '',   '',   '0.324',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Stiffener 1.0mm 25',	'Variant', '600',  'Flip Chip', '', '',     '', 	'FALSE',    	'',		'1.0mm Lid 25 Body',		'Stiffener 1.0mm',   '',  '',     '',      '',   '',   '',   '0.243',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Stiffener 1.0mm 27',	'Variant', '600',  'Flip Chip', '', '',     '', 	'FALSE',    	'',		'1.0mm Lid 27 Body',		'Stiffener 1.0mm',   '',  '',     '',      '',   '',   '',   '0.27',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Stiffener 1.0mm 29',	'Variant', '600',  'Flip Chip', '', '',     '', 	'FALSE',    	'',		'1.0mm Lid 29 Body',		'Stiffener 1.0mm',   '',  '',     '',      '',   '',   '',   '0.297',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Stiffener 1.0mm 31',	'Variant', '600',  'Flip Chip', '', '',     '', 	'FALSE',    	'',		'1.0mm Lid 31 Body',		'Stiffener 1.0mm',   '',  '',     '',      '',   '',   '',   '0.333',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Stiffener 1.0mm 33',	'Variant', '600',  'Flip Chip', '', '',     '', 	'FALSE',    	'',		'1.0mm Lid 33 Body',		'Stiffener 1.0mm',   '',  '',     '',      '',   '',   '',   '0.369',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Stiffener 1.0mm 35',	'Variant', '600',  'Flip Chip', '', '',     '', 	'FALSE',    	'',		'1.0mm Lid 35 Body',		'Stiffener 1.0mm',   '',  '',     '',      '',   '',   '',   '0.405',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Stiffener 1.0mm 37.5',	'Variant', '600',  'Flip Chip', '', '',     '', 	'FALSE',    	'',		'1.0mm Lid 37.5 Body',		'Stiffener 1.0mm',   '',  '',     '',      '',   '',   '',   '0.45',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Stiffener 1.0mm 40',	'Variant', '600',  'Flip Chip', '', '',     '', 	'FALSE',    	'',		'1.0mm Lid 40 Body',		'Stiffener 1.0mm',   '',  '',     '',      '',   '',   '',   '0.513',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Stiffener 1.0mm 42.5',	'Variant', '600',  'Flip Chip', '', '',     '', 	'FALSE',    	'',		'1.0mm Lid 42.5 Body',		'Stiffener 1.0mm',   '',  '',     '',      '',   '',   '',   '0.567',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Stiffener 1.0mm 45',	'Variant', '600',  'Flip Chip', '', '',     '', 	'FALSE',    	'',		'1.0mm Lid 45 Body',		'Stiffener 1.0mm',   '',  '',     '',      '',   '',   '',   '0.621',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Stiffener 1.0mm 47.5',	'Variant', '600',  'Flip Chip', '', '',     '', 	'FALSE',    	'',		'1.0mm Lid 47.5 Body',		'Stiffener 1.0mm',   '',  '',     '',      '',   '',   '',   '0.684',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Stiffener 1.0mm 50',	'Variant', '600',  'Flip Chip', '', '',     '', 	'FALSE',    	'',		'1.0mm Lid 50 Body',		'Stiffener 1.0mm',   '',  '',     '',      '',   '',   '',   '0.756',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Stiffener 1.0mm 52.5',	'Variant', '600',  'Flip Chip', '', '',     '', 	'FALSE',    	'',		'1.0mm Lid 52.5 Body',		'Stiffener 1.0mm',   '',  '',     '',      '',   '',   '',   '0.828',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Stiffener 1.0mm 55',	'Variant', '600',  'Flip Chip', '', '',     '', 	'FALSE',    	'',		'1.0mm Lid 55 Body',		'Stiffener 1.0mm',   '',  '',     '',      '',   '',   '',   '0.9',			'',		'',   '',     '',   '',   '',     '',   ''); 

		loadBom('Stiffener Adhesive AEA-2', 'Variant', '700', 	'Flip Chip', '', '',     '',	'FALSE',  		'',  	'AEA-2',   			'Stiffener Adhesive',	'',  '',   		'',     	'',  	'',  	'',  	'2.20533333333333',	'', 	'1.2',		'',   		'',  	'', 		'',   		'',  	'');
		loadBom('Stiffener Adhesive AEA-3', 'Variant', '700', 	'Flip Chip', '', '',     '',	'FALSE',  		'',  	'AEA-3',   			'Stiffener Adhesive',	'',  '',   		'',     	'',  	'',  	'',  	'1.59647058823529',	'', 	'1.2',		'',   		'',  	'', 		'',   		'',  	'');
		loadBom('Stiffener Adhesive JEA-1', 'Variant', '700', 	'Flip Chip', '', '',     '',	'FALSE',  		'',  	'JEA-1',   			'Stiffener Adhesive',	'',  '',   		'',     	'',  	'',  	'',  	'0.74311377245509',	'', 	'1.2',		'',   		'',  	'', 		'',   		'',  	'');
		loadBom('Stiffener Adhesive HEA-2', 'Variant', '700', 	'Flip Chip', '', '',     '',	'FALSE',  		'',  	'HEA-2',   			'Stiffener Adhesive',	'',  '',   		'',     	'',  	'',  	'',  	'1.166',			'', 	'1.2',		'',   		'',  	'', 		'',   		'',  	'');
		loadBom('Stiffener Adhesive HEA-3', 'Variant', '700', 	'Flip Chip', '', '',     '',	'FALSE',  		'',  	'HEA-3',   			'Stiffener Adhesive',	'',  '',   		'',     	'',  	'',  	'',  	'2.71707317073171',	'', 	'1.2',		'',   		'',  	'', 		'',   		'',  	'');
		loadBom('Stiffener Adhesive DCL-2', 'Variant', '700', 	'Flip Chip', '', '',     '',	'FALSE',  		'',  	'DCL-2',   			'Stiffener Adhesive',	'',  '',   		'',     	'',  	'',  	'',  	'0.51',				'', 	'1.2',		'',   		'',  	'', 		'',   		'',  	'');
		loadBom('Stiffener Adhesive DCL-4', 'Variant', '700', 	'Flip Chip', '', '',     '',	'FALSE',  		'',  	'DCL-4',   			'Stiffener Adhesive',	'',  '',   		'',     	'',  	'',  	'',  	'0.54',				'', 	'1.064',	'',   		'',  	'', 		'',   		'',  	'');
		loadBom('Stiffener Adhesive DCL-5', 'Variant', '700', 	'Flip Chip', '', '',     '',	'FALSE',  		'',  	'DCL-5',   			'Stiffener Adhesive',	'',  '',   		'',     	'',  	'',  	'',  	'0.5',				'', 	'2.192',	'',   		'',  	'', 		'',   		'',  	'');
		loadBom('Stiffener Adhesive TTA-1', 'Variant', '700', 	'Flip Chip', '', '',     '',	'FALSE',  		'',  	'TTA-1',   			'Stiffener Adhesive',	'',  '',   		'',     	'',  	'',  	'',  	'5.361',			'', 	'2.96',		'',   		'',  	'', 		'',   		'',  	'');

		loadBom('Heatspreader 0.5mm 15',	'Variant', '800',  'Flip Chip', '', '',     '', 	'FALSE',    	'',   	'0.5mm Lid 15 Body',		'Heatspreader 0.5mm',   '',  '',     '',      '',   '',   '',   '0.14',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Heatspreader 0.5mm 17',	'Variant', '800',  'Flip Chip', '', '',     '', 	'FALSE',    	'',   	'0.5mm Lid 17 Body',		'Heatspreader 0.5mm',   '',  '',     '',      '',   '',   '',   '0.15',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Heatspreader 0.5mm 19',	'Variant', '800',  'Flip Chip', '', '',     '', 	'FALSE',    	'',   	'0.5mm Lid 19 Body',		'Heatspreader 0.5mm',   '',  '',     '',      '',   '',   '',   '0.16',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Heatspreader 0.5mm 21',	'Variant', '800',  'Flip Chip', '', '',     '', 	'FALSE',    	'',   	'0.5mm Lid 21 Body',		'Heatspreader 0.5mm',   '',  '',     '',      '',   '',   '',   '0.17',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Heatspreader 0.5mm 23',	'Variant', '800',  'Flip Chip', '', '',     '', 	'FALSE',    	'',   	'0.5mm Lid 23 Body',		'Heatspreader 0.5mm',   '',  '',     '',      '',   '',   '',   '0.18',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Heatspreader 0.5mm 25',	'Variant', '800',  'Flip Chip', '', '',     '', 	'FALSE',    	'',   	'0.5mm Lid 25 Body',		'Heatspreader 0.5mm',   '',  '',     '',      '',   '',   '',   '0.19',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Heatspreader 0.5mm 27',	'Variant', '800',  'Flip Chip', '', '',     '', 	'FALSE',    	'',   	'0.5mm Lid 27 Body',		'Heatspreader 0.5mm',   '',  '',     '',      '',   '',   '',   '0.2',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Heatspreader 0.5mm 29',	'Variant', '800',  'Flip Chip', '', '',     '', 	'FALSE',    	'',   	'0.5mm Lid 29 Body',		'Heatspreader 0.5mm',   '',  '',     '',      '',   '',   '',   '0.22',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Heatspreader 0.5mm 31',	'Variant', '800',  'Flip Chip', '', '',     '', 	'FALSE',    	'',   	'0.5mm Lid 31 Body',		'Heatspreader 0.5mm',   '',  '',     '',      '',   '',   '',   '0.23',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Heatspreader 0.5mm 33',	'Variant', '800',  'Flip Chip', '', '',     '', 	'FALSE',    	'',   	'0.5mm Lid 33 Body',		'Heatspreader 0.5mm',   '',  '',     '',      '',   '',   '',   '0.25',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Heatspreader 0.5mm 35',	'Variant', '800',  'Flip Chip', '', '',     '', 	'FALSE',    	'',   	'0.5mm Lid 35 Body',		'Heatspreader 0.5mm',   '',  '',     '',      '',   '',   '',   '0.26',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Heatspreader 0.5mm 37.5',	'Variant', '800',  'Flip Chip', '', '',     '', 	'FALSE',    	'',   	'0.5mm Lid 37.5 Body',		'Heatspreader 0.5mm',   '',  '',     '',      '',   '',   '',   '0.285',	'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Heatspreader 0.5mm 40',	'Variant', '800',  'Flip Chip', '', '',     '', 	'FALSE',    	'',   	'0.5mm Lid 40 Body',		'Heatspreader 0.5mm',   '',  '',     '',      '',   '',   '',   '0.31',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Heatspreader 0.5mm 42.5',	'Variant', '800',  'Flip Chip', '', '',     '', 	'FALSE',    	'',   	'0.5mm Lid 42.5 Body',		'Heatspreader 0.5mm',   '',  '',     '',      '',   '',   '',   '0.335',	'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Heatspreader 0.5mm 45',	'Variant', '800',  'Flip Chip', '', '',     '', 	'FALSE',    	'',   	'0.5mm Lid 45 Body',		'Heatspreader 0.5mm',   '',  '',     '',      '',   '',   '',   '0.36',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Heatspreader 1.0mm 25',	'Variant', '800',  'Flip Chip', '', '',     '', 	'FALSE',    	'',		'1.0mm Lid 25 Body',		'Heatspreader 1.0mm',   '',  '',     '',      '',   '',   '',   '0.27',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Heatspreader 1.0mm 27',	'Variant', '800',  'Flip Chip', '', '',     '', 	'FALSE',    	'',		'1.0mm Lid 27 Body',		'Heatspreader 1.0mm',   '',  '',     '',      '',   '',   '',   '0.3',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Heatspreader 1.0mm 29',	'Variant', '800',  'Flip Chip', '', '',     '', 	'FALSE',    	'',		'1.0mm Lid 29 Body',		'Heatspreader 1.0mm',   '',  '',     '',      '',   '',   '',   '0.33',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Heatspreader 1.0mm 31',	'Variant', '800',  'Flip Chip', '', '',     '', 	'FALSE',    	'',		'1.0mm Lid 31 Body',		'Heatspreader 1.0mm',   '',  '',     '',      '',   '',   '',   '0.37',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Heatspreader 1.0mm 33',	'Variant', '800',  'Flip Chip', '', '',     '', 	'FALSE',    	'',		'1.0mm Lid 33 Body',		'Heatspreader 1.0mm',   '',  '',     '',      '',   '',   '',   '0.41',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Heatspreader 1.0mm 35',	'Variant', '800',  'Flip Chip', '', '',     '', 	'FALSE',    	'',		'1.0mm Lid 35 Body',		'Heatspreader 1.0mm',   '',  '',     '',      '',   '',   '',   '0.45',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Heatspreader 1.0mm 37.5',	'Variant', '800',  'Flip Chip', '', '',     '', 	'FALSE',    	'',		'1.0mm Lid 37.5 Body',		'Heatspreader 1.0mm',   '',  '',     '',      '',   '',   '',   '0.5',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Heatspreader 1.0mm 40',	'Variant', '800',  'Flip Chip', '', '',     '', 	'FALSE',    	'',		'1.0mm Lid 40 Body',		'Heatspreader 1.0mm',   '',  '',     '',      '',   '',   '',   '0.57',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Heatspreader 1.0mm 42.5',	'Variant', '800',  'Flip Chip', '', '',     '', 	'FALSE',    	'',		'1.0mm Lid 42.5 Body',		'Heatspreader 1.0mm',   '',  '',     '',      '',   '',   '',   '0.63',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Heatspreader 1.0mm 45',	'Variant', '800',  'Flip Chip', '', '',     '', 	'FALSE',    	'',		'1.0mm Lid 45 Body',		'Heatspreader 1.0mm',   '',  '',     '',      '',   '',   '',   '0.69',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Heatspreader 1.0mm 47.5',	'Variant', '800',  'Flip Chip', '', '',     '', 	'FALSE',    	'',		'1.0mm Lid 47.5 Body',		'Heatspreader 1.0mm',   '',  '',     '',      '',   '',   '',   '0.76',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Heatspreader 1.0mm 50',	'Variant', '800',  'Flip Chip', '', '',     '', 	'FALSE',    	'',		'1.0mm Lid 50 Body',		'Heatspreader 1.0mm',   '',  '',     '',      '',   '',   '',   '0.84',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Heatspreader 1.0mm 52.5',	'Variant', '800',  'Flip Chip', '', '',     '', 	'FALSE',    	'',		'1.0mm Lid 52.5 Body',		'Heatspreader 1.0mm',   '',  '',     '',      '',   '',   '',   '0.92',		'',		'',   '',     '',   '',   '',     '',   ''); 
		loadBom('Heatspreader 1.0mm 55',	'Variant', '800',  'Flip Chip', '', '',     '', 	'FALSE',    	'',		'1.0mm Lid 55 Body',		'Heatspreader 1.0mm',   '',  '',     '',      '',   '',   '',   '1.0',		'',		'',   '',     '',   '',   '',     '',   ''); 

		loadBom('H/S Adhesive AEA-2', 		'Variant', '700', 'Flip Chip', '', '',    '',   	'FALSE',  '',  			'AEA-2',   					'H/S Adhesive',   '', '',   '',     '',  '',  '',  				'2.20533333333333',	'', '1.5',     '',   '',  '', '',   '',  '');
		loadBom('H/S Adhesive AEA-3', 		'Variant', '700', 'Flip Chip', '', '',    '',   	'FALSE',  '',  			'AEA-3',   					'H/S Adhesive',   '', '',   '',     '',  '',  '',  				'1.59647058823529',	'', '1.5',     '',   '',  '', '',   '',  '');
		loadBom('H/S Adhesive JEA-1', 		'Variant', '700', 'Flip Chip', '', '',    '',   	'FALSE',  '',  			'JEA-1',   					'H/S Adhesive',   '', '',   '',     '',  '',  '',  				'0.74311377245509',	'', '1.5',     '',   '',  '', '',   '',  '');
		loadBom('H/S Adhesive HEA-2', 		'Variant', '700', 'Flip Chip', '', '',    '',   	'FALSE',  '',  			'HEA-2',   					'H/S Adhesive',   '', '',   '',     '',  '',  '',  				'1.166',			'', '1.5',     '',   '',  '', '',   '',  '');
		loadBom('H/S Adhesive HEA-3', 		'Variant', '700', 'Flip Chip', '', '',    '',   	'FALSE',  '',  			'HEA-3',   					'H/S Adhesive',   '', '',   '',     '',  '',  '',  				'2.71707317073171',	'', '1.5',     '',   '',  '', '',   '',  '');
		loadBom('H/S Adhesive DCL-2', 		'Variant', '700', 'Flip Chip', '', '',    '',   	'FALSE',  '',  			'DCL-2',   					'H/S Adhesive',   '', '',   '',     '',  '',  '',  				'0.51',				'', '1.5',     '',   '',  '', '',   '',  '');
		loadBom('H/S Adhesive DCL-4', 		'Variant', '700', 'Flip Chip', '', '',    '',   	'FALSE',  '',  			'DCL-4',   					'H/S Adhesive',   '', '',   '',     '',  '',  '',  				'0.54',				'', '1.33',    '',   '',  '', '',   '',  '');
		loadBom('H/S Adhesive DCL-5', 		'Variant', '700', 'Flip Chip', '', '',    '',   	'FALSE',  '',  			'DCL-5',   					'H/S Adhesive',   '', '',   '',     '',  '',  '',  				'0.5',				'', '2.74',    '',   '',  '', '',   '',  '');
		loadBom('H/S Adhesive TTA-1', 		'Variant', '700', 'Flip Chip', '', '',    '',   	'FALSE',  '',  			'TTA-1',   					'H/S Adhesive',   '', '',   '',     '',  '',  '',  				'5.361',			'', '3.7',     '',   '',  '', '',   '',  '');

		loadBom('TIM TTG-3', 				'Variant', '1000', 	'Flip Chip', '', '',     '',	'FALSE',  		'',  	'TTG-3',   			'TIM',    				'',  '',   		'',     	'',  	'',  	'',  	'1.704',			'', 	'2.56',		'',   		'',  	'', 		'',   		'',  	'');
		loadBom('TIM SHA-1', 				'Variant', '1000', 	'Flip Chip', '', '',     '',	'FALSE',  		'',  	'SHA-1',   			'TIM',    				'',  '',   		'',     	'',  	'',  	'',  	'1.55',				'', 	'2.5',		'',   		'',  	'', 		'',   		'',  	'');
		loadBom('TIM DCL-2HP', 				'Variant', '1000', 	'Flip Chip', '', '',     '',	'FALSE',  		'',  	'DCL-2HP',  		'TIM',    				'',  '',   		'',     	'',  	'',  	'',  	'5.61',				'', 	'2.5',		'',   		'',  	'', 		'',   		'',  	'');
		loadBom('TIM DCL-5', 				'Variant', '1000', 	'Flip Chip', '', '',     '',	'FALSE',  		'',  	'DCL-5',   			'TIM',    				'',  '',   		'',     	'',  	'',  	'',  	'0.5',				'', 	'2.74',		'',   		'',  	'', 		'',   		'',  	'');
		
		//=CONCATENATE("loadBom('Solder Balls ", B45 ,"', 				'Variant', '1100', 	'Flip Chip', '', '',     '',	'FALSE',  		'',  	'", B45 ,"',   			'Solder Balls',    				'',  '',   		'',     	'',  	'',  	'',  	'", G45 ,"',				'', 	'',		'',   		'',  	'', 		'',   		'',  	'');")
		loadBom('Solder Balls 0.61MM LF',	'Variant', '1100',  'Flip Chip', '', '',     '',	'FALSE',    	'',   	'0.61MM LF',		'Solder Balls',        '',  '',     '',      '',   '',   '',   '0.067',    '',  '',  '',     '',   '',   '',     '',   '');
		loadBom('Solder Balls 0.5MM LF',	'Variant', '1100',  'Flip Chip', '', '',     '',	'FALSE',    	'',   	'0.5MM LF',			'Solder Balls',        '',  '',     '',      '',   '',   '',   '0.042',    '',  '',  '',     '',   '',   '',     '',   '');
		loadBom('Solder Balls 0.4MM',		'Variant', '1100',  'Flip Chip', '', '',     '',	'FALSE',    	'',   	'0.4MM',			'Solder Balls',        '',  '',     '',      '',   '',   '',   '0.023',    '',  '',  '',     '',   '',   '',     '',   '');
		loadBom('Solder Balls 0.3MM',		'Variant', '1100',  'Flip Chip', '', '',     '',	'FALSE',    	'',   	'0.3MM',			'Solder Balls',        '',  '',     '',      '',   '',   '',   '0.014',    '',  '',  '',     '',   '',   '',     '',   '');
		loadBom('Solder Balls 0.25MM',		'Variant', '1100',  'Flip Chip', '', '',     '',	'FALSE',    	'',   	'0.25MM',			'Solder Balls',        '',  '',     '',      '',   '',   '',   '0.012',    '',  '',  '',     '',   '',   '',     '',   '');

		//=CONCATENATE("loadBom('Solder Ball Flux ", ,"',	'Variant', '1200',  'Flip Chip', '', '',     '',	'FALSE',    	'',   	'", ,"',			'Solder Ball Flux',        '',  '',     '',      '',   '',   '',   '", ,"',    '',  '',  '',     '',   '',   '',     '',   '');"
		loadBom('Solder Ball Flux SCF-2',	'Variant', '1200',  'Flip Chip', '', '',     '', 	'FALSE',     	'',    	'',   				'Solder Ball Flux',		'',  '',     	'',      '',   '',   '',   '0.248',    '',  '',  '',     '',   '',   '',     '',   '');
		loadBom('Solder Ball Flux AWF-11',	'Variant', '1200',  'Flip Chip', '', '',     '', 	'FALSE',     	'',    	'',   				'Solder Ball Flux',		'',  '',     	'',      '',   '',   '',   '0.235',    '',  '',  '',     '',   '',   '',     '',   '');
		loadBom('Solder Ball Flux AWF-12',	'Variant', '1200',  'Flip Chip', '', '',     '', 	'FALSE',     	'',    	'',   				'Solder Ball Flux',		'',  '',     	'',      '',   '',   '',   '0.235',    '',  '',  '',     '',   '',   '',     '',   '');

		loadBom('OverMold Softec 14', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'14',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'24',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 15', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'15',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'24',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 16', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'16',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'24',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 17', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'17',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'24',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 18', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'18',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'24',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 19', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'19',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'24',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 20', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'20',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'24',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 21', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'21',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'24',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 22', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'22',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'24',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 23', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'23',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'24',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 24', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'24',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'24',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 25', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'25',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'24',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 26', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'26',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'12',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 27', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'27',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'12',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 28', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'28',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'12',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 29', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'29',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'12',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 30', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'30',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'12',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 31', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'31',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'12',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 32', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'32',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'12',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 33', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'33',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'12',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 34', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'34',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'12',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 35', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'35',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'12',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 37.5',		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'37.5',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'10',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 39', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'39',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'10',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 40', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'40',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'10',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 41', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'41',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'10',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 42', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'42',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'10',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 43', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'43',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'10',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 44', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'44',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'10',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 45', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'45',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'8',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 46', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'46',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'8',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 47', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'47',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'8',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 48', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'48',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'8',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 49', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'49',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'8',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 50', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'50',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'8',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 51', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'51',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'8',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 52', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'52',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'8',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 53', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'53',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'8',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 54', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'54',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'8',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 55', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'55',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'8',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 56', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'56',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'8',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 57', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'57',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'8',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 58', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'58',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'8',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 59', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'59',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'8',    	'',     	'',   	'',   		'',     	'',   	'');
		loadBom('OverMold Softec 60', 		'Variant', '1600',  'Flip Chip', '', '',     '',    'FALSE',    	'',   	'60',    			'OverMold Softec',      '',  '',     	'',      	'',   	'',   	'',   	'',    				'',  	'8',    	'',     	'',   	'',   		'',     	'',   	'');



		//=CONCATENATE("loadBom('OverMold Softec ",B9,"', 				'Variant', '1600', 	'Flip Chip', '', '',     '',   		'FALSE',  		'',  	'",B9,"',   	'OverMold Softec',    				'',  '',   		'',     	'',  	'',  	'',  	'',				'', 	'",I9,"',    '',   		'',  	'', 		'',   		'',  	'');")

		//---Save list 
		insert bomList;
		bomVariantMap = new Map<String, FCM_BOM__c>();
		for(FCM_BOM__c row : bomList) bomVariantMap.put(row.name, row);
	}
	
	private void loadProcs()
	{
		//adProc('Process Name',				'parent',	'Type','Category',				'hasVariants',  'pg', 		 'equipCost',	'footprint',	 'index', 	'mmr',	'uph',	 '',	'seq',	'FC BGA',	'equip','leadct', 'uphExponent');
		loadProc('WBG-Taping',					'',			'Item','WBG',					'FALSE', 		'Flip Chip', '31',			'26',			 '', 		'5',	'40',    '',	'1000',	'FC BGA',	'',		'',		 '');
		loadProc('WBG-Grinding',				'',			'Item','WBG-Grinding',			'FALSE', 		'Flip Chip', '714',			'63',			 '', 		'5',	'2.1926','',	'1100',	'FC BGA',	'',		'',		 '0.1986');
		loadProc('WBG-Detaping',				'',			'Item','WBG',					'FALSE', 		'Flip Chip', '16',			'41',			 '', 		'5',	'48',    '',	'1200',	'FC BGA',	'',		'',		 '');
		loadProc('WBG-Inspect',					'',			'Item','WBG-Inspect',			'FALSE', 		'Flip Chip', '0',			'8',			 '', 		'1',	'15',	 '',	'1300',	'FC BGA',	'',		'',	 	 '');
		loadProc('Wafer Mount (stand alone)',	'',			'Item','Wafer Mount',			'TRUE',  		'Flip Chip', '119',			'25',			 '', 		'',		'50',    '',	'1400',	'FC BGA',	'',		'',		 '');
		loadProc('Laser Groove',				'',			'Item','Laser Groove',			'TRUE',  		'Flip Chip', '700',			'20.2',		 	 '', 		'',		'62711', '',	'1500',	'FC BGA',	'',		'',	 	 '-1.52');
		loadProc('Wafer Saw',					'',			'Item','Wafer Saw',				'TRUE',  		'Flip Chip', '230',			'20',			 '', 		'',		'32507', '',	'1600',	'FC BGA',	'',		'',	 	 '-1.315');
		loadProc('2nd Op',						'',			'Item','Standard Divide Die',	'TRUE',  		'Flip Chip', '0',			'8',			 '', 		'',		'5000',  '',	'1700',	'FC BGA',	'',		'',		 '');
		loadProc('Substrate Boat Load',			'',			'Item','Standard',				'TRUE',  		'Flip Chip', '180',			'45',			 '', 		'',		'2000',  '',	'1800',	'FC BGA',	'',		'',		 '');
		loadProc('Substrate Prebake',			'',			'Item','Boat',					'TRUE',  		'Flip Chip', '40',			'20',			 '', 		'',		'90',	 '',	'1900',	'FC BGA',	'',		'',		 '');
		loadProc('FC Attach (w/ Capacitors)',	'',			'Item','Capacitor',				'TRUE',  		'Flip Chip', '1910',		'340',			 '', 		'',		'',		 '',	'2000',	'FC BGA',	'',		'',		 '');
		loadProc('FC Attach (w/o Capacitors)',	'',			'Item','Capacitor',				'TRUE',  		'Flip Chip', '830',			'197',			 '', 		'',		'',		 '',	'2100',	'FC BGA',	'',		'',		 '');
		loadProc('Flux Clean',				  	'',			'Item','Boat',					'TRUE',  		'Flip Chip', '310',			'150',			 '', 		'',		'120',	 '',	'2200',	'FC BGA',	'',		'',		 '');
		loadProc('X-ray (Sampling)',			'',			'Item','Boat',					'TRUE',  		'Flip Chip', '150',			'20',			 '', 		'',		'300',	 '',	'2300',	'FC BGA',	'',		'',		 '');
		loadProc('UF Prebake',					'',			'Item','Boat',					'TRUE',  		'Flip Chip', '40',			'22',			 '', 		'',		'90',	 '',	'2400',	'FC BGA',	'',		'',		 '');
		loadProc('Plasma Clean',				'',			'Item','Boat',					'TRUE',  		'Flip Chip', '96',			'15',			 '', 		'',		'150',	 '',	'2500',	'FC BGA',	'',		'',		 '');
		loadProc('Underfill In-line Plasma',  	'',			'Item','Boat',					'TRUE',  		'Flip Chip', '230',			'43',			 '', 		'',		'60',	 '',	'2600',	'FC BGA',	'',		'',		 '');
		loadProc('UF Dispense',					'',			'Item','UF Dispense',			'TRUE',  		'Flip Chip', '230',			'43',			 '', 		'',		'',		 '',	'2700',	'FC BGA',	'',		'',		 '');
		loadProc('UF Cure',						'',			'Item','Boat',					'TRUE',  		'Flip Chip', '40',			'22',			 '', 		'',		'130',	 '',	'2800',	'FC BGA',	'',		'',		 '');
		loadProc('CSAM',						'',			'Item','Boat',					'TRUE',  		'Flip Chip', '250',			'20',			 '', 		'',		'800',	 '',	'2900',	'FC BGA',	'',		'',		 '');
		loadProc('3rd Op',						'',			'Item','Boat',					'TRUE',  		'Flip Chip', '1',			'8',			 '', 		'',		'1000',	 '',	'3000',	'FC BGA',	'',		'',		 '');
		loadProc('LA In-line Plasma',			'',			'Item','Boat',					'TRUE',  		'Flip Chip', '230',			'43',			 '', 		'',		'60',	 '',	'3100',	'FC BGA',	'',		'',		 '');
		loadProc('Lid Prebake',					'',			'Item','Boat',					'TRUE',  		'Flip Chip', '40',			'22',			 '', 		'',		'90',	 '',	'3200',	'FC BGA',	'',		'',		 '');
		loadProc('Lid Attach',					'',			'Item','Lid Attach',			'TRUE',  		'Flip Chip', '550',			'91.8', 		 '', 		'',		'',		 '',	'3300',	'FC BGA',	'',		'',		 '');
		loadProc('Lid Cure',					'',			'Item','Boat',					'TRUE',  		'Flip Chip', '40',			'22',			 '', 		'',		'130',	 '',	'3400',	'FC BGA',	'',		'',		 '');
		loadProc('Laser Mark',					'',			'Item','Boat',					'TRUE',  		'Flip Chip', '240',			'40',			 '', 		'',		'85',	 '',	'3500',	'FC BGA',	'',		'',		 '');
		loadProc('Ball Attach Prebake',			'',			'Item','Boat',					'TRUE',  		'Flip Chip', '40',			'22',			 '', 		'',		'90',	 '',	'3600',	'FC BGA',	'',		'',		 '');
		loadProc('Ball Attach + Tray Load',		'',			'Item','Boat',					'TRUE',  		'Flip Chip', '650',			'210',			 '', 		'',		'120',	 '',	'3700',	'FC BGA',	'',		'',		 '');
		loadProc('Cap Attached on BGA',			'',			'Item','Boat',					'TRUE',  		'Flip Chip', '650',			'8',			 '', 		'',		'120',	 '',	'3800',	'FC BGA',	'',		'',		 '');
		loadProc('OS Test',						'',			'Item','OS Test',				'TRUE',  		'Flip Chip', '227.841636',	'29.272453245',  '', 		'',		'900',	 '',	'3900',	'FC BGA',	'',		'',		 '');
		loadProc('Coplanarity Check',			'',			'Item','Tray',					'TRUE',  		'Flip Chip', '330',			'22.3',		 	 '', 		'',		'80',	 '',	'4000',	'FC BGA',	'',		'',		 '');
		loadProc('FVI',							'',			'Item','Tray',					'TRUE',  		'Flip Chip', '1',			'8',			 '', 		'',		'40',	 '',	'4100',	'FC BGA',	'',		'',		 '');
		loadProc('Bake for Dry Pack',			'',			'Item','Tray',					'TRUE',  		'Flip Chip', '40',			'22',			 '', 		'',		'80',	 '',	'4200',	'FC BGA',	'',		'',		 '');
		loadProc('Dry Pack',					'',			'Item','Tray',					'TRUE',  		'Flip Chip', '2',			'8',			 '', 		'',		'1000',	 '',	'4300',	'FC BGA',	'',		'',		 '');
		loadProc('Pack',						'',			'Item','Tray',					'TRUE',  		'Flip Chip', '1',			'8',			 '', 		'',		'800',	 '',	'4400',	'FC BGA',	'',		'',		 '');
		loadProc('Tooling',						'',			'Item','Tooling',				'FALSE', 		'Flip Chip', '',			'', 			 '', 		'', 	'',		 '',	'4450',	'FC BGA',	'',		'',		 '');
		loadProc('OverMold Dispense',			'',			'Item','OM',					'TRUE', 		'Flip Chip', '840',			'163',			 '', 		'1',	'',		 '',	'4500',	'FC BGA',	'',		'',		 '');
		loadProc('OverMold PMC',				'',			'Item','Boat',					'FALSE', 		'Flip Chip', '40',			'22',			 '', 		'10',	'90',	 '',	'4600',	'FC BGA',	'',		'',		 '');
		loadProc('OverMold Plate',				'',			'Item','OM Plate',				'TRUE', 		'Flip Chip', '30',			'0',			 '', 		'0',	'',		 '',	'4700',	'FC BGA',	'',		'', 	 '');
	



		//get from excel
		//=CONCATENATE("loadProc('", D23, "',										'','Item','Wafer Mount','TRUE','Flip Chip','", G23, "','", H23, "','','','','','", 1000 + Z23,"','FC BGA','','');")

		//---Save current list and load into map (For parent matching)
		insert procList;
		procMap = new Map<String, FCM_Process__c>();
		for(FCM_Process__c row : procList) procMap.put(row.name, row);
		procList = new List<FCM_Process__c>();

		loadProc('Wafer Mount (stand alone) K4',	'Wafer Mount (stand alone)',	'Variant','','FALSE','Flip Chip','','','','2',		'','','1400','FC BGA','','','');
		loadProc('Wafer Mount (stand alone) P3',	'Wafer Mount (stand alone)',	'Variant','','FALSE','Flip Chip','','','','5',		'','','1400','FC BGA','','','');
		loadProc('Wafer Mount (stand alone) T3',	'Wafer Mount (stand alone)',	'Variant','','FALSE','Flip Chip','','','','5',		'','','1400','FC BGA','','','');
		loadProc('Laser Groove K4',					'Laser Groove',					'Variant','','FALSE','Flip Chip','','','','8',		'','','1500','FC BGA','','','');
		loadProc('Laser Groove P3',					'Laser Groove',					'Variant','','FALSE','Flip Chip','','','','6',		'','','1500','FC BGA','','','');
		loadProc('Laser Groove T3',					'Laser Groove',					'Variant','','FALSE','Flip Chip','','','','5',		'','','1500','FC BGA','','','');
		loadProc('Wafer Saw K4',					'Wafer Saw',					'Variant','','FALSE','Flip Chip','','','','8',		'','','1600','FC BGA','','','');
		loadProc('Wafer Saw P3',					'Wafer Saw',					'Variant','','FALSE','Flip Chip','','','','6',		'','','1600','FC BGA','','','');
		loadProc('Wafer Saw T3',					'Wafer Saw',					'Variant','','FALSE','Flip Chip','','','','8',		'','','1600','FC BGA','','','');
		loadProc('2nd Op K4',						'2nd Op',						'Variant','','FALSE','Flip Chip','','','','1',		'','','1700','FC BGA','','','');
		loadProc('2nd Op P3',						'2nd Op',						'Variant','','FALSE','Flip Chip','','','','1',		'','','1700','FC BGA','','','');
		loadProc('2nd Op T3',						'2nd Op',						'Variant','','FALSE','Flip Chip','','','','1',		'','','1700','FC BGA','','','');
		loadProc('Substrate Boat Load K4',			'Substrate Boat Load',			'Variant','','FALSE','Flip Chip','','','','2',		'','','1800','FC BGA','','','');
		loadProc('Substrate Boat Load P3',			'Substrate Boat Load',			'Variant','','FALSE','Flip Chip','','','','2',		'','','1800','FC BGA','','','');
		loadProc('Substrate Boat Load T3',			'Substrate Boat Load',			'Variant','','FALSE','Flip Chip','','','','2',		'','','1800','FC BGA','','','');
		loadProc('Substrate Prebake K4',			'Substrate Prebake',			'Variant','','FALSE','Flip Chip','','','','6',		'','','1900','FC BGA','','','');
		loadProc('Substrate Prebake P3',			'Substrate Prebake',			'Variant','','FALSE','Flip Chip','','','','5',		'','','1900','FC BGA','','','');
		loadProc('Substrate Prebake T3',			'Substrate Prebake',			'Variant','','FALSE','Flip Chip','','','','6',		'','','1900','FC BGA','','','');
		loadProc('FC Attach (w/ Capacitors) K4',	'FC Attach (w/ Capacitors)',	'Variant','','FALSE','Flip Chip','','','','0.6',	'','','2000','FC BGA','','','');
		loadProc('FC Attach (w/ Capacitors) P3',	'FC Attach (w/ Capacitors)',	'Variant','','FALSE','Flip Chip','','','','1',		'','','2000','FC BGA','','','');
		loadProc('FC Attach (w/ Capacitors) T3',	'FC Attach (w/ Capacitors)',	'Variant','','FALSE','Flip Chip','','','','0.5',	'','','2000','FC BGA','','','');
		loadProc('FC Attach (w/o Capacitors) K4',	'FC Attach (w/o Capacitors)',	'Variant','','FALSE','Flip Chip','','','','0.6',	'','','2100','FC BGA','','','');
		loadProc('FC Attach (w/o Capacitors) P3',	'FC Attach (w/o Capacitors)',	'Variant','','FALSE','Flip Chip','','','','1',		'','','2100','FC BGA','','','');
		loadProc('FC Attach (w/o Capacitors) T3',	'FC Attach (w/o Capacitors)',	'Variant','','FALSE','Flip Chip','','','','0.7',	'','','2100','FC BGA','','','');
		loadProc('Flux Clean K4',					'Flux Clean',					'Variant','','FALSE','Flip Chip','','','','2',		'','','2200','FC BGA','','','');
		loadProc('Flux Clean P3',					'Flux Clean',					'Variant','','FALSE','Flip Chip','','','','2',		'','','2200','FC BGA','','','');
		loadProc('Flux Clean T3',					'Flux Clean',					'Variant','','FALSE','Flip Chip','','','','2',		'','','2200','FC BGA','','','');
		loadProc('X-ray (Sampling) K4',				'X-ray (Sampling)',				'Variant','','FALSE','Flip Chip','','','','1',		'','','2300','FC BGA','','','');
		loadProc('X-ray (Sampling) P3',				'X-ray (Sampling)',				'Variant','','FALSE','Flip Chip','','','','1',		'','','2300','FC BGA','','','');
		loadProc('X-ray (Sampling) T3',				'X-ray (Sampling)',				'Variant','','FALSE','Flip Chip','','','','1',		'','','2300','FC BGA','','','');
		loadProc('UF Prebake K4',					'UF Prebake',					'Variant','','FALSE','Flip Chip','','','','9',		'','','2400','FC BGA','','','');
		loadProc('UF Prebake P3',					'UF Prebake',					'Variant','','FALSE','Flip Chip','','','','6',		'','','2400','FC BGA','','','');
		loadProc('UF Prebake T3',					'UF Prebake',					'Variant','','FALSE','Flip Chip','','','','6',		'','','2400','FC BGA','','','');
		loadProc('Plasma Clean K4',					'Plasma Clean',					'Variant','','FALSE','Flip Chip','','','','6',		'','','2500','FC BGA','','','');
		loadProc('Plasma Clean P3',					'Plasma Clean',					'Variant','','FALSE','Flip Chip','','','','5',		'','','2500','FC BGA','','','');
		loadProc('Plasma Clean T3',					'Plasma Clean',					'Variant','','FALSE','Flip Chip','','','','6',		'','','2500','FC BGA','','','');
		loadProc('Underfill In-line Plasma K4',		'Underfill In-line Plasma',		'Variant','','FALSE','Flip Chip','','','','2.7',	'','','2600','FC BGA','','','');
		loadProc('Underfill In-line Plasma P3',		'Underfill In-line Plasma',		'Variant','','FALSE','Flip Chip','','','','4',		'','','2600','FC BGA','','','');
		loadProc('Underfill In-line Plasma T3',		'Underfill In-line Plasma',		'Variant','','FALSE','Flip Chip','','','','4',		'','','2600','FC BGA','','','');
		loadProc('UF Dispense K4',					'UF Dispense',					'Variant','','FALSE','Flip Chip','','','','2.7',	'','','2700','FC BGA','','','');
		loadProc('UF Dispense P3',					'UF Dispense',					'Variant','','FALSE','Flip Chip','','','','4',		'','','2700','FC BGA','','','');
		loadProc('UF Dispense T3',					'UF Dispense',					'Variant','','FALSE','Flip Chip','','','','4',		'','','2700','FC BGA','','','');
		loadProc('UF Cure K4',						'UF Cure',						'Variant','','FALSE','Flip Chip','','','','9',		'','','2800','FC BGA','','','');
		loadProc('UF Cure P3',						'UF Cure',						'Variant','','FALSE','Flip Chip','','','','5',		'','','2800','FC BGA','','','');
		loadProc('UF Cure T3',						'UF Cure',						'Variant','','FALSE','Flip Chip','','','','6',		'','','2800','FC BGA','','','');
		loadProc('CSAM K4',							'CSAM',							'Variant','','FALSE','Flip Chip','','','','5',		'','','2900','FC BGA','','','');
		loadProc('CSAM P3',							'CSAM',							'Variant','','FALSE','Flip Chip','','','','2',		'','','2900','FC BGA','','','');
		loadProc('CSAM T3',							'CSAM',							'Variant','','FALSE','Flip Chip','','','','2',		'','','2900','FC BGA','','','');
		loadProc('3rd Op K4',						'3rd Op',						'Variant','','FALSE','Flip Chip','','','','1',		'','','3000','FC BGA','','','');
		loadProc('3rd Op P3',						'3rd Op',						'Variant','','FALSE','Flip Chip','','','','1',		'','','3000','FC BGA','','','');
		loadProc('3rd Op T3',						'3rd Op',						'Variant','','FALSE','Flip Chip','','','','1',		'','','3000','FC BGA','','','');
		loadProc('LA In-line Plasma K4',			'LA In-line Plasma',			'Variant','','FALSE','Flip Chip','','','','2.7',	'','','3100','FC BGA','','','');
		loadProc('LA In-line Plasma P3',			'LA In-line Plasma',			'Variant','','FALSE','Flip Chip','','','','4',		'','','3100','FC BGA','','','');
		loadProc('LA In-line Plasma T3',			'LA In-line Plasma',			'Variant','','FALSE','Flip Chip','','','','4',		'','','3100','FC BGA','','','');
		loadProc('Lid Prebake K4',					'Lid Prebake',					'Variant','','FALSE','Flip Chip','','','','16',		'','','3200','FC BGA','','','');
		loadProc('Lid Prebake P3',					'Lid Prebake',					'Variant','','FALSE','Flip Chip','','','','8',		'','','3200','FC BGA','','','');
		loadProc('Lid Prebake T3',					'Lid Prebake',					'Variant','','FALSE','Flip Chip','','','','7',		'','','3200','FC BGA','','','');
		loadProc('Lid Attach K4',					'Lid Attach',					'Variant','','FALSE','Flip Chip','','','','1',		'6253','','3300','FC BGA','','','-0.856');
		loadProc('Lid Attach P3',					'Lid Attach',					'Variant','','FALSE','Flip Chip','','','','1',		'6253','','3300','FC BGA','','','-0.856');
		loadProc('Lid Attach T3',					'Lid Attach',					'Variant','','FALSE','Flip Chip','','','','1.5',	'6253','','3300','FC BGA','','','-0.856');
		loadProc('Lid Attach K4 2PC',				'Lid Attach',					'Variant','','FALSE','Flip Chip','','','','1',		'3126.5','','3300','FC BGA','','','-0.856');
		loadProc('Lid Attach P3 2PC',				'Lid Attach',					'Variant','','FALSE','Flip Chip','','','','1',		'3126.5','','3300','FC BGA','','','-0.856');
		loadProc('Lid Attach T3 2PC',				'Lid Attach',					'Variant','','FALSE','Flip Chip','','','','1.5',	'3126.5','','3300','FC BGA','','','-0.856');
		loadProc('Lid Cure K4',						'Lid Cure',						'Variant','','FALSE','Flip Chip','','','','16',		'','','3400','FC BGA','','','');
		loadProc('Lid Cure P3',						'Lid Cure',						'Variant','','FALSE','Flip Chip','','','','8',		'','','3400','FC BGA','','','');
		loadProc('Lid Cure T3',						'Lid Cure',						'Variant','','FALSE','Flip Chip','','','','6',		'','','3400','FC BGA','','','');
		loadProc('Laser Mark K4',					'Laser Mark',					'Variant','','FALSE','Flip Chip','','','','3',		'','','3500','FC BGA','','','');
		loadProc('Laser Mark P3',					'Laser Mark',					'Variant','','FALSE','Flip Chip','','','','2',		'','','3500','FC BGA','','','');
		loadProc('Laser Mark T3',					'Laser Mark',					'Variant','','FALSE','Flip Chip','','','','2',		'','','3500','FC BGA','','','');
		loadProc('Ball Attach Prebake K4',			'Ball Attach Prebake',			'Variant','','FALSE','Flip Chip','','','','16',		'','','3600','FC BGA','','','');
		loadProc('Ball Attach Prebake P3',			'Ball Attach Prebake',			'Variant','','FALSE','Flip Chip','','','','10',		'','','3600','FC BGA','','','');
		loadProc('Ball Attach Prebake T3',			'Ball Attach Prebake',			'Variant','','FALSE','Flip Chip','','','','8',		'','','3600','FC BGA','','','');
		loadProc('Ball Attach + Tray Load K4',		'Ball Attach + Tray Load',		'Variant','','FALSE','Flip Chip','','','','1',		'','','3700','FC BGA','','','');
		loadProc('Ball Attach + Tray Load P3',		'Ball Attach + Tray Load',		'Variant','','FALSE','Flip Chip','','','','1',		'','','3700','FC BGA','','','');
		loadProc('Ball Attach + Tray Load T3',		'Ball Attach + Tray Load',		'Variant','','FALSE','Flip Chip','','','','1',		'','','3700','FC BGA','','','');
		loadProc('Cap Attached on BGA K4',			'Cap Attached on BGA',			'Variant','','FALSE','Flip Chip','','','','0.5',	'','','3800','FC BGA','','','');
		loadProc('Cap Attached on BGA P3',			'Cap Attached on BGA',			'Variant','','FALSE','Flip Chip','','','','0.5',	'','','3800','FC BGA','','','');
		loadProc('Cap Attached on BGA T3',			'Cap Attached on BGA',			'Variant','','FALSE','Flip Chip','','','','0.5',	'','','3800','FC BGA','','','');
		loadProc('OS Test K4',						'OS Test',						'Variant','','FALSE','Flip Chip','','','','4',		'','','3900','FC BGA','','','');
		loadProc('OS Test P3',						'OS Test',						'Variant','','FALSE','Flip Chip','','','','2',		'','','3900','FC BGA','','','');
		loadProc('OS Test T3',						'OS Test',						'Variant','','FALSE','Flip Chip','','','','2',		'','','3900','FC BGA','','','');
		loadProc('Coplanarity Check K4',			'Coplanarity Check',			'Variant','','FALSE','Flip Chip','','','','4',		'','','4000','FC BGA','','','');
		loadProc('Coplanarity Check P3',			'Coplanarity Check',			'Variant','','FALSE','Flip Chip','','','','2',		'','','4000','FC BGA','','','');
		loadProc('Coplanarity Check T3',			'Coplanarity Check',			'Variant','','FALSE','Flip Chip','','','','2',		'','','4000','FC BGA','','','');
		loadProc('FVI K4',							'FVI',							'Variant','','FALSE','Flip Chip','','','','1',		'','','4100','FC BGA','','','');
		loadProc('FVI P3',							'FVI',							'Variant','','FALSE','Flip Chip','','','','1',		'','','4100','FC BGA','','','');
		loadProc('FVI T3',							'FVI',							'Variant','','FALSE','Flip Chip','','','','1',		'','','4100','FC BGA','','','');
		loadProc('Bake for Dry Pack K4',			'Bake for Dry Pack',			'Variant','','FALSE','Flip Chip','','','','5.5',	'','','4200','FC BGA','','','');
		loadProc('Bake for Dry Pack P3',			'Bake for Dry Pack',			'Variant','','FALSE','Flip Chip','','','','5',		'','','4200','FC BGA','','','');
		loadProc('Bake for Dry Pack T3',			'Bake for Dry Pack',			'Variant','','FALSE','Flip Chip','','','','6',		'','','4200','FC BGA','','','');
		loadProc('Dry Pack K4',						'Dry Pack',						'Variant','','FALSE','Flip Chip','','','','1',		'','','4300','FC BGA','','','');
		loadProc('Dry Pack P3',						'Dry Pack',						'Variant','','FALSE','Flip Chip','','','','2',		'','','4300','FC BGA','','','');
		loadProc('Dry Pack T3',						'Dry Pack',						'Variant','','FALSE','Flip Chip','','','','1',		'','','4300','FC BGA','','','');
		loadProc('Pack K4',							'Pack',							'Variant','','FALSE','Flip Chip','','','','1',		'','','4400','FC BGA','','','');
		loadProc('Pack P3',							'Pack',							'Variant','','FALSE','Flip Chip','','','','2',		'','','4400','FC BGA','','','');
		loadProc('Pack T3',							'Pack',							'Variant','','FALSE','Flip Chip','','','','1',		'','','4400','FC BGA','','','');
		
		loadProc('OverMold Dispense 14-25',   	'OverMold Dispense',   	'Variant','','FALSE','Flip Chip','','','','','600','','4500','FC BGA','','','');
		loadProc('OverMold Dispense 26-35',   	'OverMold Dispense',   	'Variant','','FALSE','Flip Chip','','','','','300','','4500','FC BGA','','','');
		loadProc('OverMold Dispense 37.5-44', 	'OverMold Dispense',   	'Variant','','FALSE','Flip Chip','','','','','250','','4500','FC BGA','','','');
		loadProc('OverMold Dispense 45-60',   	'OverMold Dispense',   	'Variant','','FALSE','Flip Chip','','','','','200','','4500','FC BGA','','','');
		loadProc('OverMold Plate 14-25',   		'OverMold Plate',   	'Variant','','FALSE','Flip Chip','','','','','600','','4500','FC BGA','','','');
		loadProc('OverMold Plate 26-35',   		'OverMold Plate',   	'Variant','','FALSE','Flip Chip','','','','','300','','4500','FC BGA','','','');
		loadProc('OverMold Plate 37.5-44', 		'OverMold Plate',   	'Variant','','FALSE','Flip Chip','','','','','250','','4500','FC BGA','','','');
		loadProc('OverMold Plate 45-60',   		'OverMold Plate',   	'Variant','','FALSE','Flip Chip','','','','','200','','4500','FC BGA','','','');

		//to get from excel
		//=CONCATENATE("loadProc('",D23, IF($B$1049=1, " K4",IF($B$1049=2," P3",IF($B$1049=3," T3"))), "',										'", D23, "','Variant','','FALSE','Flip Chip','','','','", E23, "','','','", 1000 + Z23,"','FC BGA','','');")

		insert procList;
		procVariantMap = new Map<String, FCM_Process__c>();
		for(FCM_Process__c row : procList) procVariantMap.put(row.name, row);

	}
	
	private void loadMatches()
	{
		
		//============ BEGIN PROCESS MATCHES ====================
		//match process to factory
		loadMatch('','Wafer Mount (stand alone) T3','ItemTextValue','Contains','Factory__r.Name','T3','FALSE');
		loadMatch('','Wafer Mount (stand alone) P3','ItemTextValue','Contains','Factory__r.Name','P3','FALSE');
		loadMatch('','Wafer Mount (stand alone) K4','ItemTextValue','Contains','Factory__r.Name','K4','FALSE');
		loadMatch('','Laser Groove T3','ItemTextValue','Contains','Factory__r.Name','T3','FALSE');
		loadMatch('','Laser Groove P3','ItemTextValue','Contains','Factory__r.Name','P3','FALSE');
		loadMatch('','Laser Groove K4','ItemTextValue','Contains','Factory__r.Name','K4','FALSE');
		loadMatch('','Wafer Saw T3','ItemTextValue','Contains','Factory__r.Name','T3','FALSE');
		loadMatch('','Wafer Saw P3','ItemTextValue','Contains','Factory__r.Name','P3','FALSE');
		loadMatch('','Wafer Saw K4','ItemTextValue','Contains','Factory__r.Name','K4','FALSE');
		loadMatch('','2nd Op T3','ItemTextValue','Contains','Factory__r.Name','T3','FALSE');
		loadMatch('','2nd Op P3','ItemTextValue','Contains','Factory__r.Name','P3','FALSE');
		loadMatch('','2nd Op K4','ItemTextValue','Contains','Factory__r.Name','K4','FALSE');
		loadMatch('','Substrate Boat Load T3','ItemTextValue','Contains','Factory__r.Name','T3','FALSE');
		loadMatch('','Substrate Boat Load P3','ItemTextValue','Contains','Factory__r.Name','P3','FALSE');
		loadMatch('','Substrate Boat Load K4','ItemTextValue','Contains','Factory__r.Name','K4','FALSE');
		loadMatch('','Substrate Prebake T3','ItemTextValue','Contains','Factory__r.Name','T3','FALSE');
		loadMatch('','Substrate Prebake P3','ItemTextValue','Contains','Factory__r.Name','P3','FALSE');
		loadMatch('','Substrate Prebake K4','ItemTextValue','Contains','Factory__r.Name','K4','FALSE');
		loadMatch('','FC Attach (w/ Capacitors) T3','ItemTextValue','Contains','Factory__r.Name','T3','FALSE');
		loadMatch('','FC Attach (w/ Capacitors) P3','ItemTextValue','Contains','Factory__r.Name','P3','FALSE');
		loadMatch('','FC Attach (w/ Capacitors) K4','ItemTextValue','Contains','Factory__r.Name','K4','FALSE');
		loadMatch('','FC Attach (w/o Capacitors) T3','ItemTextValue','Contains','Factory__r.Name','T3','FALSE');
		loadMatch('','FC Attach (w/o Capacitors) P3','ItemTextValue','Contains','Factory__r.Name','P3','FALSE');
		loadMatch('','FC Attach (w/o Capacitors) K4','ItemTextValue','Contains','Factory__r.Name','K4','FALSE');
		loadMatch('','Flux Clean T3','ItemTextValue','Contains','Factory__r.Name','T3','FALSE');
		loadMatch('','Flux Clean P3','ItemTextValue','Contains','Factory__r.Name','P3','FALSE');
		loadMatch('','Flux Clean K4','ItemTextValue','Contains','Factory__r.Name','K4','FALSE');
		loadMatch('','X-ray (Sampling) T3','ItemTextValue','Contains','Factory__r.Name','T3','FALSE');
		loadMatch('','X-ray (Sampling) P3','ItemTextValue','Contains','Factory__r.Name','P3','FALSE');
		loadMatch('','X-ray (Sampling) K4','ItemTextValue','Contains','Factory__r.Name','K4','FALSE');
		loadMatch('','UF Prebake T3','ItemTextValue','Contains','Factory__r.Name','T3','FALSE');
		loadMatch('','UF Prebake P3','ItemTextValue','Contains','Factory__r.Name','P3','FALSE');
		loadMatch('','UF Prebake K4','ItemTextValue','Contains','Factory__r.Name','K4','FALSE');
		loadMatch('','Plasma Clean T3','ItemTextValue','Contains','Factory__r.Name','T3','FALSE');
		loadMatch('','Plasma Clean P3','ItemTextValue','Contains','Factory__r.Name','P3','FALSE');
		loadMatch('','Plasma Clean K4','ItemTextValue','Contains','Factory__r.Name','K4','FALSE');
		loadMatch('','Underfill In-line Plasma T3','ItemTextValue','Contains','Factory__r.Name','T3','FALSE');
		loadMatch('','Underfill In-line Plasma P3','ItemTextValue','Contains','Factory__r.Name','P3','FALSE');
		loadMatch('','Underfill In-line Plasma K4','ItemTextValue','Contains','Factory__r.Name','K4','FALSE');
		loadMatch('','UF Dispense T3','ItemTextValue','Contains','Factory__r.Name','T3','FALSE');
		loadMatch('','UF Dispense P3','ItemTextValue','Contains','Factory__r.Name','P3','FALSE');
		loadMatch('','UF Dispense K4','ItemTextValue','Contains','Factory__r.Name','K4','FALSE');
		loadMatch('','UF Cure T3','ItemTextValue','Contains','Factory__r.Name','T3','FALSE');
		loadMatch('','UF Cure P3','ItemTextValue','Contains','Factory__r.Name','P3','FALSE');
		loadMatch('','UF Cure K4','ItemTextValue','Contains','Factory__r.Name','K4','FALSE');
		loadMatch('','CSAM T3','ItemTextValue','Contains','Factory__r.Name','T3','FALSE');
		loadMatch('','CSAM P3','ItemTextValue','Contains','Factory__r.Name','P3','FALSE');
		loadMatch('','CSAM K4','ItemTextValue','Contains','Factory__r.Name','K4','FALSE');
		loadMatch('','3rd Op T3','ItemTextValue','Contains','Factory__r.Name','T3','FALSE');
		loadMatch('','3rd Op P3','ItemTextValue','Contains','Factory__r.Name','P3','FALSE');
		loadMatch('','3rd Op K4','ItemTextValue','Contains','Factory__r.Name','K4','FALSE');
		loadMatch('','LA In-line Plasma T3','ItemTextValue','Contains','Factory__r.Name','T3','FALSE');
		loadMatch('','LA In-line Plasma P3','ItemTextValue','Contains','Factory__r.Name','P3','FALSE');
		loadMatch('','LA In-line Plasma K4','ItemTextValue','Contains','Factory__r.Name','K4','FALSE');
		loadMatch('','Lid Prebake T3','ItemTextValue','Contains','Factory__r.Name','T3','FALSE');
		loadMatch('','Lid Prebake P3','ItemTextValue','Contains','Factory__r.Name','P3','FALSE');
		loadMatch('','Lid Prebake K4','ItemTextValue','Contains','Factory__r.Name','K4','FALSE');
		loadMatch('','Lid Attach T3','ItemTextValue','Contains','Factory__r.Name','T3','FALSE');
		loadMatch('','Lid Attach P3','ItemTextValue','Contains','Factory__r.Name','P3','FALSE');
		loadMatch('','Lid Attach K4','ItemTextValue','Contains','Factory__r.Name','K4','FALSE');
		loadMatch('','Lid Attach T3 2PC','ItemTextValue','Contains','Factory__r.Name','T3','FALSE');
		loadMatch('','Lid Attach P3 2PC','ItemTextValue','Contains','Factory__r.Name','P3','FALSE');
		loadMatch('','Lid Attach K4 2PC','ItemTextValue','Contains','Factory__r.Name','K4','FALSE');
		loadMatch('','Lid Cure T3','ItemTextValue','Contains','Factory__r.Name','T3','FALSE');
		loadMatch('','Lid Cure P3','ItemTextValue','Contains','Factory__r.Name','P3','FALSE');
		loadMatch('','Lid Cure K4','ItemTextValue','Contains','Factory__r.Name','K4','FALSE');
		loadMatch('','Laser Mark T3','ItemTextValue','Contains','Factory__r.Name','T3','FALSE');
		loadMatch('','Laser Mark P3','ItemTextValue','Contains','Factory__r.Name','P3','FALSE');
		loadMatch('','Laser Mark K4','ItemTextValue','Contains','Factory__r.Name','K4','FALSE');
		loadMatch('','Ball Attach Prebake T3','ItemTextValue','Contains','Factory__r.Name','T3','FALSE');
		loadMatch('','Ball Attach Prebake P3','ItemTextValue','Contains','Factory__r.Name','P3','FALSE');
		loadMatch('','Ball Attach Prebake K4','ItemTextValue','Contains','Factory__r.Name','K4','FALSE');
		loadMatch('','Ball Attach + Tray Load T3','ItemTextValue','Contains','Factory__r.Name','T3','FALSE');
		loadMatch('','Ball Attach + Tray Load P3','ItemTextValue','Contains','Factory__r.Name','P3','FALSE');
		loadMatch('','Ball Attach + Tray Load K4','ItemTextValue','Contains','Factory__r.Name','K4','FALSE');
		loadMatch('','Cap Attached on BGA T3','ItemTextValue','Contains','Factory__r.Name','T3','FALSE');
		loadMatch('','Cap Attached on BGA P3','ItemTextValue','Contains','Factory__r.Name','P3','FALSE');
		loadMatch('','Cap Attached on BGA K4','ItemTextValue','Contains','Factory__r.Name','K4','FALSE');
		loadMatch('','OS Test T3','ItemTextValue','Contains','Factory__r.Name','T3','FALSE');
		loadMatch('','OS Test P3','ItemTextValue','Contains','Factory__r.Name','P3','FALSE');
		loadMatch('','OS Test K4','ItemTextValue','Contains','Factory__r.Name','K4','FALSE');
		loadMatch('','Coplanarity Check T3','ItemTextValue','Contains','Factory__r.Name','T3','FALSE');
		loadMatch('','Coplanarity Check P3','ItemTextValue','Contains','Factory__r.Name','P3','FALSE');
		loadMatch('','Coplanarity Check K4','ItemTextValue','Contains','Factory__r.Name','K4','FALSE');
		loadMatch('','FVI T3','ItemTextValue','Contains','Factory__r.Name','T3','FALSE');
		loadMatch('','FVI P3','ItemTextValue','Contains','Factory__r.Name','P3','FALSE');
		loadMatch('','FVI K4','ItemTextValue','Contains','Factory__r.Name','K4','FALSE');
		loadMatch('','Bake for Dry Pack T3','ItemTextValue','Contains','Factory__r.Name','T3','FALSE');
		loadMatch('','Bake for Dry Pack P3','ItemTextValue','Contains','Factory__r.Name','P3','FALSE');
		loadMatch('','Bake for Dry Pack K4','ItemTextValue','Contains','Factory__r.Name','K4','FALSE');
		loadMatch('','Dry Pack T3','ItemTextValue','Contains','Factory__r.Name','T3','FALSE');
		loadMatch('','Dry Pack P3','ItemTextValue','Contains','Factory__r.Name','P3','FALSE');
		loadMatch('','Dry Pack K4','ItemTextValue','Contains','Factory__r.Name','K4','FALSE');
		loadMatch('','Pack T3','ItemTextValue','Contains','Factory__r.Name','T3','FALSE');
		loadMatch('','Pack P3','ItemTextValue','Contains','Factory__r.Name','P3','FALSE');
		loadMatch('','Pack K4','ItemTextValue','Contains','Factory__r.Name','K4','FALSE');
		//end match process to factory

		loadMatch('','Wafer Mount (stand alone)','AlwaysDie','','','','');
		loadMatch('','Wafer Saw','AlwaysDie','','','','');

		//---TODO remove factories from list below, depend on parent level matches to filter through?
		loadMatch('','WBG-Taping','DieBoolean','Equals','WBG_Required__c','','TRUE');
		loadMatch('','WBG-Grinding','DieBoolean','Equals','WBG_Required__c','','TRUE');
		loadMatch('','WBG-Detaping','DieBoolean','Equals','WBG_Required__c','','TRUE');
		loadMatch('','WBG-Inspect','DieBoolean','Equals','WBG_Required__c','','TRUE');

		loadMatch('','FC Attach (w/ Capacitors)','AnyPassiveContains','Equals','Passive_Type__c','Capacitor','FALSE');
		loadMatch('','FC Attach (w/o Capacitors)','AnyPassiveContains','NotContains','Passive_Type__c','Capacitor','FALSE');

		loadMatch('','UF Dispense','AlwaysDie','','','','');
		loadMatch('','UF Dispense T3','ItemTextValue','NotContains','Package_Structure__c','FCmBGA','FALSE');
		loadMatch('','UF Dispense P3','ItemTextValue','NotContains','Package_Structure__c','FCmBGA','FALSE');
		loadMatch('','UF Dispense K4','ItemTextValue','NotContains','Package_Structure__c','FCmBGA','FALSE');

		loadMatch('','UF Cure T3','ItemTextValue','NotContains','Package_Structure__c','FCmBGA','FALSE');
		loadMatch('','UF Cure P3','ItemTextValue','NotContains','Package_Structure__c','FCmBGA','FALSE');
		loadMatch('','UF Cure K4','ItemTextValue','NotContains','Package_Structure__c','FCmBGA','FALSE');

		loadMatch('','LA In-line Plasma','ItemBoolean','Equals','Process_Include_LA_In_Line_Plasma__c','','TRUE');
		loadMatch('','Wafer Mount (stand alone)','ItemBoolean','Equals','Process_Include_Wafer_Mount_Stand_Alone__c','','TRUE');
		loadMatch('','Underfill In-line Plasma','ItemBoolean','Equals','Process_Include_Underfill_In_Line_Plasma__c','','TRUE');
		loadMatch('','Cap Attached on BGA','ItemBoolean','Equals','Process_Include_Cap_Attached_on_BGA__c','','TRUE');
		loadMatch('','OS Test','ItemBoolean','Equals','Process_Include_OS_Test__c','','TRUE');

		loadMatch('','Lid Prebake T3','ItemTextValue','NotContains','Package_Structure__c','FCmBGA','FALSE');
		loadMatch('','Lid Prebake P3','ItemTextValue','NotContains','Package_Structure__c','FCmBGA','FALSE');
		loadMatch('','Lid Prebake K4','ItemTextValue','NotContains','Package_Structure__c','FCmBGA','FALSE');
		loadMatch('','Lid Prebake T3','ItemTextValue','NotContains','Package_Structure__c','Bare Die','FALSE');
		loadMatch('','Lid Prebake P3','ItemTextValue','NotContains','Package_Structure__c','Bare Die','FALSE');
		loadMatch('','Lid Prebake K4','ItemTextValue','NotContains','Package_Structure__c','Bare Die','FALSE');

		loadMatch('','Lid Attach T3','ItemTextValue','NotContains','Package_Structure__c','FCmBGA','FALSE');
		loadMatch('','Lid Attach P3','ItemTextValue','NotContains','Package_Structure__c','FCmBGA','FALSE');
		loadMatch('','Lid Attach K4','ItemTextValue','NotContains','Package_Structure__c','FCmBGA','FALSE');
		loadMatch('','Lid Attach T3','ItemTextValue','NotContains','Package_Structure__c','Bare Die','FALSE');
		loadMatch('','Lid Attach P3','ItemTextValue','NotContains','Package_Structure__c','Bare Die','FALSE');
		loadMatch('','Lid Attach K4','ItemTextValue','NotContains','Package_Structure__c','Bare Die','FALSE');

		loadMatch('','Lid Attach T3 2PC','ItemTextValue','Equals','Package_Structure__c','2PC','FALSE');
		loadMatch('','Lid Attach P3 2PC','ItemTextValue','Equals','Package_Structure__c','2PC','FALSE');
		loadMatch('','Lid Attach K4 2PC','ItemTextValue','Equals','Package_Structure__c','2PC','FALSE');

		loadMatch('','Lid Cure T3','ItemTextValue','NotContains','Package_Structure__c','FCmBGA','FALSE');
		loadMatch('','Lid Cure P3','ItemTextValue','NotContains','Package_Structure__c','FCmBGA','FALSE');
		loadMatch('','Lid Cure K4','ItemTextValue','NotContains','Package_Structure__c','FCmBGA','FALSE');
		loadMatch('','Lid Cure T3','ItemTextValue','NotContains','Package_Structure__c','Bare Die','FALSE');
		loadMatch('','Lid Cure P3','ItemTextValue','NotContains','Package_Structure__c','Bare Die','FALSE');
		loadMatch('','Lid Cure K4','ItemTextValue','NotContains','Package_Structure__c','Bare Die','FALSE');

		loadMatch('','Tooling','AlwaysItem','','','','FALSE');

		loadMatch('','OverMold Dispense','ItemTextValue','Equals','Package_Structure__c','FCmBGA','FALSE');
		loadMatch('','OverMold PMC','ItemTextValue','Equals','Package_Structure__c','FCmBGA','FALSE');
		loadMatch('','OverMold Plate','ItemTextValue','Equals','Package_Structure__c','FCmBGA','FALSE');

		loadMatch('','OverMold Dispense 14-25',		'ItemNumberValue',	'GreaterThanEqualTo',	'Body_X__c','','FALSE', '14');
		loadMatch('','OverMold Dispense 14-25',		'ItemNumberValue',	'LessThanEqualTo',		'Body_X__c','','FALSE', '25');
		loadMatch('','OverMold Dispense 26-35',		'ItemNumberValue',	'GreaterThanEqualTo',	'Body_X__c','','FALSE', '26');
		loadMatch('','OverMold Dispense 26-35',		'ItemNumberValue',	'LessThanEqualTo',		'Body_X__c','','FALSE', '35');
		loadMatch('','OverMold Dispense 37.5-44',	'ItemNumberValue',	'GreaterThanEqualTo',	'Body_X__c','','FALSE', '37.5');
		loadMatch('','OverMold Dispense 37.5-44',	'ItemNumberValue',	'LessThanEqualTo',		'Body_X__c','','FALSE', '44');
		loadMatch('','OverMold Dispense 45-60',		'ItemNumberValue',	'GreaterThanEqualTo',	'Body_X__c','','FALSE', '45');
		loadMatch('','OverMold Dispense 45-60',		'ItemNumberValue',	'LessThanEqualTo',		'Body_X__c','','FALSE', '60');

		loadMatch('','OverMold Plate 14-25',		'ItemNumberValue',	'GreaterThanEqualTo',	'Body_X__c','','FALSE', '14');
		loadMatch('','OverMold Plate 14-25',		'ItemNumberValue',	'LessThanEqualTo',		'Body_X__c','','FALSE', '25');
		loadMatch('','OverMold Plate 26-35',		'ItemNumberValue',	'GreaterThanEqualTo',	'Body_X__c','','FALSE', '26');
		loadMatch('','OverMold Plate 26-35',		'ItemNumberValue',	'LessThanEqualTo',		'Body_X__c','','FALSE', '35');
		loadMatch('','OverMold Plate 37.5-44',		'ItemNumberValue',	'GreaterThanEqualTo',	'Body_X__c','','FALSE', '37.5');
		loadMatch('','OverMold Plate 37.5-44',		'ItemNumberValue',	'LessThanEqualTo',		'Body_X__c','','FALSE', '44');
		loadMatch('','OverMold Plate 45-60',		'ItemNumberValue',	'GreaterThanEqualTo',	'Body_X__c','','FALSE', '45');
		loadMatch('','OverMold Plate 45-60',		'ItemNumberValue',	'LessThanEqualTo',		'Body_X__c','','FALSE', '60');

		//--- TODO  FC Attach (w/ Capacitors), FC Attach (w/o Capacitors) 
		//	Depends on amount entered for capacitors

		//============ END PROCESS MATCHES ====================



		//============ BEGIN BOM MATCHES ====================
		//loadMatch( String bomName, String procName, String matchType, String operand, String fieldName, String textVal, String boolVal, String numericVal)

		loadMatch('Substrate',					'','AlwaysItem','','','','FALSE');
		loadMatch('Capacitor Paste/Flux',		'','AnyPassiveContains','Equals','Passive_Type__c','Capacitor','FALSE');
		loadMatch('Solder Ball Flux',			'','AlwaysItem','','','','FALSE');
		loadMatch('Tray',						'','AlwaysItem','','','','FALSE');
		loadMatch('WBG Tape',					'','DieBoolean','Equals','WBG_Required__c','','TRUE');


		loadMatch('Flux AWF-5',					'','ItemTextValue','Equals','Flux__c','AWF-5','FALSE');
		loadMatch('Flux AWFJ-5',				'','ItemTextValue','Equals','Flux__c','AWFJ-5','FALSE');
		loadMatch('Flux AWF-7',					'','ItemTextValue','Equals','Flux__c','AWF-7','FALSE');
		loadMatch('Flux SCF-1',					'','ItemTextValue','Equals','Flux__c','SCF-1','FALSE');
		loadMatch('Flux SCFJ-1',				'','ItemTextValue','Equals','Flux__c','SCFJ-1','FALSE');
		loadMatch('Flux SCF-5',					'','ItemTextValue','Equals','Flux__c','SCF-5','FALSE');

		loadMatch('Capacitor Paste/Flux HCP-1',	'','ItemTextValue','Equals','Capacitor_Paste_Flux__c','HCP-1','FALSE');
		loadMatch('Capacitor Paste/Flux ACP-1',	'','ItemTextValue','Equals','Capacitor_Paste_Flux__c','ACP-1','FALSE');
		loadMatch('Capacitor Paste/Flux SCP-5',	'','ItemTextValue','Equals','Capacitor_Paste_Flux__c','SCP-5','FALSE');
		loadMatch('Capacitor Paste/Flux SCF-2',	'','ItemTextValue','Equals','Capacitor_Paste_Flux__c','SCF-2','FALSE');
		loadMatch('Capacitor Paste/Flux DCP-2',	'','ItemTextValue','Equals','Capacitor_Paste_Flux__c','DCP-2','FALSE');
		loadMatch('Capacitor Paste/Flux DCP-1',	'','ItemTextValue','Equals','Capacitor_Paste_Flux__c','DCP-1','FALSE');

		loadMatch('Capacitor',					'','PassiveTextValue','Equals','Passive_Type__c','Capacitor','FALSE');

		loadMatch('Underfill',					'','AlwaysDie','','','','FALSE');
		loadMatch('Underfill',					'','ItemTextValue','NotContains','Package_Structure__c','FCmBGA','FALSE');
		loadMatch('Underfill NAU-6',			'','ItemTextValue','Equals','Underfill_Type__c','NAU-6','FALSE');
		loadMatch('Underfill NAU-8',			'','ItemTextValue','Equals','Underfill_Type__c','NAU-8','FALSE');
		loadMatch('Underfill NAU-12',			'','ItemTextValue','Equals','Underfill_Type__c','NAU-12','FALSE');
		loadMatch('Underfill NAU-14',			'','ItemTextValue','Equals','Underfill_Type__c','NAU-14','FALSE');
		loadMatch('Underfill NAU-19',			'','ItemTextValue','Equals','Underfill_Type__c','NAU-19','FALSE');
		loadMatch('Underfill NAU-27',			'','ItemTextValue','Equals','Underfill_Type__c','NAU-27','FALSE');
		loadMatch('Underfill SEU-1',			'','ItemTextValue','Equals','Underfill_Type__c','SEU-1','FALSE');

		loadMatch('Stiffener 0.5mm',			'','ItemTextValue','NotContains','Package_Structure__c','Bare Die','FALSE');
		loadMatch('Stiffener 0.5mm',			'','ItemTextValue','NotContains','Package_Structure__c','FCmBGA','FALSE');
		loadMatch('Stiffener 0.5mm',			'','ItemTextValue','NotContains','Package_Structure__c','1-pc Lid','FALSE'); 
		loadMatch('Stiffener 1.0mm',			'','ItemTextValue','NotContains','Package_Structure__c','Bare Die','FALSE');
		loadMatch('Stiffener 1.0mm',			'','ItemTextValue','NotContains','Package_Structure__c','FCmBGA','FALSE');
		loadMatch('Stiffener 1.0mm',			'','ItemTextValue','NotContains','Package_Structure__c','1-pc Lid','FALSE'); 
		loadMatch('Stiffener 0.5mm',			'','ItemTextValue','Equals','Lid_Thickness__c','0.5','FALSE');
		loadMatch('Stiffener 1.0mm',			'','ItemTextValue','Equals','Lid_Thickness__c','1.0','FALSE');
		loadMatch('Stiffener 0.5mm 15',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','15');
		loadMatch('Stiffener 0.5mm 17',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','17');
		loadMatch('Stiffener 0.5mm 19',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','19');
		loadMatch('Stiffener 0.5mm 21',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','21');
		loadMatch('Stiffener 0.5mm 23',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','23');
		loadMatch('Stiffener 0.5mm 25',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','25');
		loadMatch('Stiffener 0.5mm 27',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','27');
		loadMatch('Stiffener 0.5mm 29',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','29');
		loadMatch('Stiffener 0.5mm 31',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','31');
		loadMatch('Stiffener 0.5mm 33',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','33');
		loadMatch('Stiffener 0.5mm 35',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','35');
		loadMatch('Stiffener 0.5mm 37.5',		'','ItemNumberValue','Equals','Body_X__c','','FALSE','37.5');
		loadMatch('Stiffener 0.5mm 40',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','40');
		loadMatch('Stiffener 0.5mm 42.5',		'','ItemNumberValue','Equals','Body_X__c','','FALSE','42.5');
		loadMatch('Stiffener 0.5mm 45',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','45');
		loadMatch('Stiffener 1.0mm 25',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','25');
		loadMatch('Stiffener 1.0mm 27',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','27');
		loadMatch('Stiffener 1.0mm 29',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','29');
		loadMatch('Stiffener 1.0mm 31',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','31');
		loadMatch('Stiffener 1.0mm 33',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','33');
		loadMatch('Stiffener 1.0mm 35',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','35');
		loadMatch('Stiffener 1.0mm 37.5',		'','ItemNumberValue','Equals','Body_X__c','','FALSE','37.5');
		loadMatch('Stiffener 1.0mm 40',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','40');
		loadMatch('Stiffener 1.0mm 42.5',		'','ItemNumberValue','Equals','Body_X__c','','FALSE','42.5');
		loadMatch('Stiffener 1.0mm 45',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','45');
		loadMatch('Stiffener 1.0mm 47.5',		'','ItemNumberValue','Equals','Body_X__c','','FALSE','47');
		loadMatch('Stiffener 1.0mm 50',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','50');
		loadMatch('Stiffener 1.0mm 52.5',		'','ItemNumberValue','Equals','Body_X__c','','FALSE','52');
		loadMatch('Stiffener 1.0mm 55',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','55');

		loadMatch('Stiffener Adhesive',			'','ItemTextValue','NotContains','Package_Structure__c','Bare Die','FALSE');
		loadMatch('Stiffener Adhesive',			'','ItemTextValue','NotContains','Package_Structure__c','1-pc Lid','FALSE');
		loadMatch('Stiffener Adhesive',			'','ItemTextValue','NotContains','Package_Structure__c','FCmBGA','FALSE');
		loadMatch('Stiffener Adhesive AEA-2',	'','ItemTextValue','Equals','Stiffener_Adhesive__c','AEA-2','FALSE');
		loadMatch('Stiffener Adhesive AEA-3',	'','ItemTextValue','Equals','Stiffener_Adhesive__c','AEA-3','FALSE');
		loadMatch('Stiffener Adhesive JEA-1',	'','ItemTextValue','Equals','Stiffener_Adhesive__c','JEA-1','FALSE');
		loadMatch('Stiffener Adhesive HEA-2',	'','ItemTextValue','Equals','Stiffener_Adhesive__c','HEA-2','FALSE');
		loadMatch('Stiffener Adhesive HEA-3',	'','ItemTextValue','Equals','Stiffener_Adhesive__c','HEA-3','FALSE');
		loadMatch('Stiffener Adhesive DCL-2',	'','ItemTextValue','Equals','Stiffener_Adhesive__c','DCL-2','FALSE');
		loadMatch('Stiffener Adhesive DCL-4',	'','ItemTextValue','Equals','Stiffener_Adhesive__c','DCL-4','FALSE');
		loadMatch('Stiffener Adhesive DCL-5',	'','ItemTextValue','Equals','Stiffener_Adhesive__c','DCL-5','FALSE');
		loadMatch('Stiffener Adhesive TTA-1',	'','ItemTextValue','Equals','Stiffener_Adhesive__c','TTA-1','FALSE');

		loadMatch('TIM',						'','AlwaysDie','','','','');
		loadMatch('TIM',						'','ItemTextValue','NotContains','Package_Structure__c','Bare Die','FALSE');
		loadMatch('TIM',						'','ItemTextValue','NotContains','Package_Structure__c','Stiffener Only','FALSE');
		loadMatch('TIM',						'','ItemTextValue','NotContains','Package_Structure__c','FCmBGA','FALSE');
		loadMatch('TIM TTG-3',					'','ItemTextValue','Equals','TIM__c','TTG-3','FALSE');
		loadMatch('TIM SHA-1',					'','ItemTextValue','Equals','TIM__c','SHA-1','FALSE');
		loadMatch('TIM DCL-2HP',				'','ItemTextValue','Equals','TIM__c','DCL-2HP','FALSE');
		loadMatch('TIM DCL-5',					'','ItemTextValue','Equals','TIM__c','DCL-5','FALSE');

		loadMatch('Heatspreader 0.5mm',			'','ItemTextValue','NotContains','Package_Structure__c','Bare Die','FALSE');
		loadMatch('Heatspreader 0.5mm',			'','ItemTextValue','NotContains','Package_Structure__c','Stiffener Only','FALSE');
		loadMatch('Heatspreader 0.5mm',			'','ItemTextValue','NotContains','Package_Structure__c','FCmBGA','FALSE');
		loadMatch('Heatspreader 1.0mm',			'','ItemTextValue','NotContains','Package_Structure__c','Bare Die','FALSE');
		loadMatch('Heatspreader 1.0mm',			'','ItemTextValue','NotContains','Package_Structure__c','Stiffener Only','FALSE');
		loadMatch('Heatspreader 1.0mm',			'','ItemTextValue','NotContains','Package_Structure__c','FCmBGA','FALSE');
		loadMatch('Heatspreader 0.5mm',			'','ItemTextValue','Equals','Lid_Thickness__c','0.5','FALSE');
		loadMatch('Heatspreader 1.0mm',			'','ItemTextValue','Equals','Lid_Thickness__c','1.0','FALSE');
		loadMatch('Heatspreader 0.5mm 15',		'','ItemNumberValue','Equals','Body_X__c','','FALSE','15');
		loadMatch('Heatspreader 0.5mm 17',		'','ItemNumberValue','Equals','Body_X__c','','FALSE','17');
		loadMatch('Heatspreader 0.5mm 19',		'','ItemNumberValue','Equals','Body_X__c','','FALSE','19');
		loadMatch('Heatspreader 0.5mm 21',		'','ItemNumberValue','Equals','Body_X__c','','FALSE','21');
		loadMatch('Heatspreader 0.5mm 23',		'','ItemNumberValue','Equals','Body_X__c','','FALSE','23');
		loadMatch('Heatspreader 0.5mm 25',		'','ItemNumberValue','Equals','Body_X__c','','FALSE','25');
		loadMatch('Heatspreader 0.5mm 27',		'','ItemNumberValue','Equals','Body_X__c','','FALSE','27');
		loadMatch('Heatspreader 0.5mm 29',		'','ItemNumberValue','Equals','Body_X__c','','FALSE','29');
		loadMatch('Heatspreader 0.5mm 31',		'','ItemNumberValue','Equals','Body_X__c','','FALSE','31');
		loadMatch('Heatspreader 0.5mm 33',		'','ItemNumberValue','Equals','Body_X__c','','FALSE','33');
		loadMatch('Heatspreader 0.5mm 35',		'','ItemNumberValue','Equals','Body_X__c','','FALSE','35');
		loadMatch('Heatspreader 0.5mm 37.5',	'','ItemNumberValue','Equals','Body_X__c','','FALSE','37.5');
		loadMatch('Heatspreader 0.5mm 40',		'','ItemNumberValue','Equals','Body_X__c','','FALSE','40');
		loadMatch('Heatspreader 0.5mm 42.5',	'','ItemNumberValue','Equals','Body_X__c','','FALSE','42.5');
		loadMatch('Heatspreader 0.5mm 45',		'','ItemNumberValue','Equals','Body_X__c','','FALSE','45');
		loadMatch('Heatspreader 1.0mm 25',		'','ItemNumberValue','Equals','Body_X__c','','FALSE','25');
		loadMatch('Heatspreader 1.0mm 27',		'','ItemNumberValue','Equals','Body_X__c','','FALSE','27');
		loadMatch('Heatspreader 1.0mm 29',		'','ItemNumberValue','Equals','Body_X__c','','FALSE','29');
		loadMatch('Heatspreader 1.0mm 31',		'','ItemNumberValue','Equals','Body_X__c','','FALSE','31');
		loadMatch('Heatspreader 1.0mm 33',		'','ItemNumberValue','Equals','Body_X__c','','FALSE','33');
		loadMatch('Heatspreader 1.0mm 35',		'','ItemNumberValue','Equals','Body_X__c','','FALSE','35');
		loadMatch('Heatspreader 1.0mm 37.5',	'','ItemNumberValue','Equals','Body_X__c','','FALSE','37.5');
		loadMatch('Heatspreader 1.0mm 40',		'','ItemNumberValue','Equals','Body_X__c','','FALSE','40');
		loadMatch('Heatspreader 1.0mm 42.5',	'','ItemNumberValue','Equals','Body_X__c','','FALSE','42.5');
		loadMatch('Heatspreader 1.0mm 45',		'','ItemNumberValue','Equals','Body_X__c','','FALSE','45');
		loadMatch('Heatspreader 1.0mm 47.5',	'','ItemNumberValue','Equals','Body_X__c','','FALSE','47');
		loadMatch('Heatspreader 1.0mm 50',		'','ItemNumberValue','Equals','Body_X__c','','FALSE','50');
		loadMatch('Heatspreader 1.0mm 52.5',	'','ItemNumberValue','Equals','Body_X__c','','FALSE','52');
		loadMatch('Heatspreader 1.0mm 55',		'','ItemNumberValue','Equals','Body_X__c','','FALSE','55');


		loadMatch('H/S Adhesive',				'','ItemTextValue','NotContains','Package_Structure__c','Bare Die','FALSE');
		loadMatch('H/S Adhesive',				'','ItemTextValue','NotContains','Package_Structure__c','Stiffener Only','FALSE');
		loadMatch('H/S Adhesive',				'','ItemTextValue','NotContains','Package_Structure__c','FCmBGA','FALSE');
		loadMatch('H/S Adhesive AEA-2',			'','ItemTextValue','Equals','HS_Adhesive__c','AEA-2','FALSE');
		loadMatch('H/S Adhesive AEA-3',			'','ItemTextValue','Equals','HS_Adhesive__c','AEA-3','FALSE');
		loadMatch('H/S Adhesive JEA-1',			'','ItemTextValue','Equals','HS_Adhesive__c','JEA-1','FALSE');
		loadMatch('H/S Adhesive HEA-2',			'','ItemTextValue','Equals','HS_Adhesive__c','HEA-2','FALSE');
		loadMatch('H/S Adhesive HEA-3',			'','ItemTextValue','Equals','HS_Adhesive__c','HEA-3','FALSE');
		loadMatch('H/S Adhesive DCL-2',			'','ItemTextValue','Equals','HS_Adhesive__c','DCL-2','FALSE');
		loadMatch('H/S Adhesive DCL-4',			'','ItemTextValue','Equals','HS_Adhesive__c','DCL-4','FALSE');
		loadMatch('H/S Adhesive DCL-5',			'','ItemTextValue','Equals','HS_Adhesive__c','DCL-5','FALSE');
		loadMatch('H/S Adhesive TTA-1',			'','ItemTextValue','Equals','HS_Adhesive__c','TTA-1','FALSE');

		loadMatch('Solder Balls 0.61MM LF',		'','ItemTextValue','Equals','Ball_Pitch__c','1.00',	'FALSE');
		loadMatch('Solder Balls 0.5MM LF',		'','ItemTextValue','Equals','Ball_Pitch__c','0.8',	'FALSE');
		loadMatch('Solder Balls 0.4MM',			'','ItemTextValue','Equals','Ball_Pitch__c','0.65',	'FALSE');
		loadMatch('Solder Balls 0.3MM',			'','ItemTextValue','Equals','Ball_Pitch__c','0.5',	'FALSE');
		loadMatch('Solder Balls 0.25MM',		'','ItemTextValue','Equals','Ball_Pitch__c','0.44',	'FALSE');

		loadMatch('Solder Ball Flux SCF-2',		'','ItemTextValue','Equals','Solder_Ball_Flux__c','SCF-2',	'FALSE');
		loadMatch('Solder Ball Flux AWF-11',	'','ItemTextValue','Equals','Solder_Ball_Flux__c','AWF-11',	'FALSE');
		loadMatch('Solder Ball Flux AWF-12',	'','ItemTextValue','Equals','Solder_Ball_Flux__c','AWF-12',	'FALSE');

		loadMatch('OverMold',					'','ItemTextValue','Equals','Package_Structure__c','FCmBGA','FALSE');
		loadMatch('OverMold',					'','AlwaysDie','','','','FALSE');

		
		loadMatch('OverMold Softec',			'','ItemTextValue','Equals','Package_Structure__c','FCmBGA','FALSE');
		loadMatch('OverMold Softec 14',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','14');
		loadMatch('OverMold Softec 15',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','15');
		loadMatch('OverMold Softec 16',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','16');
		loadMatch('OverMold Softec 17',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','17');
		loadMatch('OverMold Softec 18',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','18');
		loadMatch('OverMold Softec 19',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','19');
		loadMatch('OverMold Softec 20',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','20');
		loadMatch('OverMold Softec 21',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','21');
		loadMatch('OverMold Softec 22',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','22');
		loadMatch('OverMold Softec 23',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','23');
		loadMatch('OverMold Softec 24',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','24');
		loadMatch('OverMold Softec 25',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','25');
		loadMatch('OverMold Softec 26',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','26');
		loadMatch('OverMold Softec 27',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','27');
		loadMatch('OverMold Softec 28',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','28');
		loadMatch('OverMold Softec 29',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','29');
		loadMatch('OverMold Softec 30',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','30');
		loadMatch('OverMold Softec 31',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','31');
		loadMatch('OverMold Softec 32',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','32');
		loadMatch('OverMold Softec 33',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','33');
		loadMatch('OverMold Softec 34',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','34');
		loadMatch('OverMold Softec 35',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','35');
		loadMatch('OverMold Softec 37.5',		'','ItemNumberValue','Equals','Body_X__c','','FALSE','37.5');
		loadMatch('OverMold Softec 39',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','39');
		loadMatch('OverMold Softec 40',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','40');
		loadMatch('OverMold Softec 41',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','41');
		loadMatch('OverMold Softec 42',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','42');
		loadMatch('OverMold Softec 43',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','43');
		loadMatch('OverMold Softec 44',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','44');
		loadMatch('OverMold Softec 45',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','45');
		loadMatch('OverMold Softec 46',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','46');
		loadMatch('OverMold Softec 47',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','47');
		loadMatch('OverMold Softec 48',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','48');
		loadMatch('OverMold Softec 49',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','49');
		loadMatch('OverMold Softec 50',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','50');
		loadMatch('OverMold Softec 51',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','51');
		loadMatch('OverMold Softec 52',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','52');
		loadMatch('OverMold Softec 53',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','53');
		loadMatch('OverMold Softec 54',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','54');
		loadMatch('OverMold Softec 55',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','55');
		loadMatch('OverMold Softec 56',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','56');
		loadMatch('OverMold Softec 57',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','57');
		loadMatch('OverMold Softec 58',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','58');
		loadMatch('OverMold Softec 59',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','59');
		loadMatch('OverMold Softec 60',			'','ItemNumberValue','Equals','Body_X__c','','FALSE','60');

		insert matchList;
	}

	private void loadFactoryValues()
	{
		List<CM_Factory_Value__c> factList = new List<CM_Factory_Value__c>();

		//=CONCATENATE("factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = '", xxxx ,"', Value__c = '", xxxxx, "'));")
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-10.000', Value__c = '86'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-12.000', Value__c = '72'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-13.000', Value__c = '60'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-15.000', Value__c = '60'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-17.000', Value__c = '40'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-18.000', Value__c = '40'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-19.000', Value__c = '40'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-21.000', Value__c = '32'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-22.000', Value__c = '32'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-22.000', Value__c = '32'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-23.000', Value__c = '32'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-25.000', Value__c = '24'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-25.000', Value__c = '24'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-26.000', Value__c = '24'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-27.000', Value__c = '24'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-28.000', Value__c = '24'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-28.000', Value__c = '24'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-29.000', Value__c = '24'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-31.000', Value__c = '24'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-33.000', Value__c = '18'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-34.000', Value__c = '18'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-35.000', Value__c = '18'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-38.000', Value__c = '18'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-38.000', Value__c = '18'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-39.000', Value__c = '18'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-40.000', Value__c = '18'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-41.000', Value__c = '18'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-43.000', Value__c = '18'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-44.000', Value__c = '10'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-44.000', Value__c = '10'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-45.000', Value__c = '10'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-47.000', Value__c = '10'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-48.000', Value__c = '10'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-50.000', Value__c = '10'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-52.000', Value__c = '10'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-52.500', Value__c = '10'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-55.000', Value__c = '8'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-57.000', Value__c = '8'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-58.000', Value__c = '8'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Boat-63.000', Value__c = '8'));
		 
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c =  'Tray-5.000', Value__c = '576'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c =  'Tray-5.000', Value__c = '624'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c =  'Tray-5.000', Value__c = '640'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c =  'Tray-6.000', Value__c = '360'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c =  'Tray-6.000', Value__c = '429'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c =  'Tray-6.000', Value__c = '608'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c =  'Tray-7.000', Value__c = '416'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c =  'Tray-7.000', Value__c = '476'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c =  'Tray-8.000', Value__c = '348'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c =  'Tray-8.000', Value__c = '360'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c =  'Tray-9.000', Value__c = '250'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c =  'Tray-9.000', Value__c = '260'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Tray-10.000', Value__c = '184'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Tray-10.000', Value__c = '240'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Tray-10.000', Value__c = '250'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Tray-11.000', Value__c = '176'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Tray-12.000', Value__c = '189'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Tray-12.000', Value__c = '198'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Tray-13.000', Value__c = '160'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Tray-14.000', Value__c = '152'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Tray-14.000', Value__c = '119'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Tray-15.000', Value__c = '126'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Tray-16.000', Value__c = '119'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Tray-17.000', Value__c = '90'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Tray-18.000', Value__c = '84'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Tray-19.000', Value__c = '84'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Tray-21.000', Value__c = '60'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Tray-22.000', Value__c = '60'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Tray-23.000', Value__c = '60'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Tray-25.000', Value__c = '44'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Tray-27.000', Value__c = '40'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Tray-29.000', Value__c = '36'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Tray-31.000', Value__c = '27'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Tray-32.500', Value__c = '24'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Tray-33.000', Value__c = '24'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Tray-35.000', Value__c = '24'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Tray-37.500', Value__c = '21'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Tray-40.000', Value__c = '21'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Tray-42.500', Value__c = '12'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Tray-45.000', Value__c = '12'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Tray-47.500', Value__c = '12'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Tray-50.000', Value__c = '10'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'Tray-52.500', Value__c = '10'));

		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-18bt-1', Value__c = '1.75'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-18bt-2', Value__c = '1.75'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-18bt-3', Value__c = '1.75'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-18bt-4', Value__c = '1.75'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-18bt-5', Value__c = '1.75'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-18bt-6', Value__c = '1.75'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-18bt-7', Value__c = '1.75'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-18bt-8', Value__c = '1.75'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-18bt-9', Value__c = '1.75'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-18bt-10', Value__c = '1.71'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-18bt-11', Value__c = '1.71'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-18bt-12', Value__c = '1.71'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-18bt-13', Value__c = '1.66'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-18bt-14', Value__c = '1.66'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-18bt-15', Value__c = '1.62'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-18bt-16', Value__c = '1.62'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-18bt-17', Value__c = '1.62'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-18bt-18', Value__c = '1.58'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-18bt-19', Value__c = '1.58'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-18bt-20', Value__c = '1.58'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-18bt-21', Value__c = '1.53'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-18bt-22', Value__c = '1.53'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-18bt-23', Value__c = '1.53'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-18bt-24', Value__c = '1.53'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-18bt-25', Value__c = '1.53'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-18bt-26', Value__c = '1.53'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-18bt-27', Value__c = '1.53'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-18bt-28', Value__c = '1.53'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-18bt-29', Value__c = '1.53'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-18bt-30', Value__c = '1.53'));

		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-24bt-1', Value__c = '1.79'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-24bt-2', Value__c = '1.79'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-24bt-3', Value__c = '1.79'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-24bt-4', Value__c = '1.79'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-24bt-5', Value__c = '1.79'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-24bt-6', Value__c = '1.79'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-24bt-7', Value__c = '1.79'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-24bt-8', Value__c = '1.79'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-24bt-9', Value__c = '1.79'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-24bt-10', Value__c = '1.75'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-24bt-11', Value__c = '1.75'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-24bt-12', Value__c = '1.75'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-24bt-13', Value__c = '1.7'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-24bt-14', Value__c = '1.7'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-24bt-15', Value__c = '1.66'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-24bt-16', Value__c = '1.66'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-24bt-17', Value__c = '1.66'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-24bt-18', Value__c = '1.61'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-24bt-19', Value__c = '1.61'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-24bt-20', Value__c = '1.61'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-24bt-21', Value__c = '1.57'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-24bt-22', Value__c = '1.57'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-24bt-23', Value__c = '1.57'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-24bt-24', Value__c = '1.57'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-24bt-25', Value__c = '1.57'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-24bt-26', Value__c = '1.57'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-24bt-27', Value__c = '1.57'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-24bt-28', Value__c = '1.57'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-24bt-29', Value__c = '1.57'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-24bt-30', Value__c = '1.57'));

		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-32bt-1', Value__c = '1.85'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-32bt-2', Value__c = '1.85'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-32bt-3', Value__c = '1.85'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-32bt-4', Value__c = '1.85'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-32bt-5', Value__c = '1.85'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-32bt-6', Value__c = '1.85'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-32bt-7', Value__c = '1.85'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-32bt-8', Value__c = '1.85'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-32bt-9', Value__c = '1.85'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-32bt-10', Value__c = '1.8'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-32bt-11', Value__c = '1.8'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-32bt-12', Value__c = '1.8'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-32bt-13', Value__c = '1.76'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-32bt-14', Value__c = '1.76'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-32bt-15', Value__c = '1.71'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-32bt-16', Value__c = '1.71'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-32bt-17', Value__c = '1.71'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-32bt-18', Value__c = '1.66'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-32bt-19', Value__c = '1.66'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-32bt-20', Value__c = '1.66'));

		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-40bt-1', Value__c = '1.9'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-40bt-2', Value__c = '1.9'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-40bt-3', Value__c = '1.9'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-40bt-4', Value__c = '1.9'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-40bt-5', Value__c = '1.9'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-40bt-6', Value__c = '1.9'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-40bt-7', Value__c = '1.9'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-40bt-8', Value__c = '1.9'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-40bt-9', Value__c = '1.9'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-40bt-10', Value__c = '1.86'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-40bt-11', Value__c = '1.86'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-40bt-12', Value__c = '1.86'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-40bt-13', Value__c = '1.81'));
		factList.add(new CM_Factory_Value__c(CM_Version__c = cmVersion.Id, Key__c = 'CapUPHMult-40bt-14', Value__c = '1.81'));

		insert factList;

	}

	public static void AMK1856()
	{
		List<CM_Factory_Value__c> factList = [SELECT id, key__c FROM CM_Factory_Value__c WHERE (key__c like 'Tray%' or key__c like 'Boat%')];

		for (CM_Factory_Value__c fact : factList) fact.Key__c += '0';

		update factList;
	}
}