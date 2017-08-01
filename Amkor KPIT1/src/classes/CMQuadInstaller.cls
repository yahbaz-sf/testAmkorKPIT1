/*************************************************************************
*
* PURPOSE: 
*
* CLASS: 
* CREATED: 5/01/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/ 
global class CMQuadInstaller extends CMFCMInstaller
{
	global static void cleanAndInstall() 
	{
		clean();
		CMQuadInstaller installer = new CMQuadInstaller();
		//installer.cleanAll();
		installer.installFCM();
	}
	
	global static void install() 
	{
		CMQuadInstaller installer = new CMQuadInstaller();
		installer.installFCM();
	}
	
	global static void clean() 
	{
		CMQuadInstaller installer = new CMQuadInstaller();
		installer.clean('Quad Leadframe');
		//installer.cleanAll();uad
	}
	
	public override void installFCM()
	{
		pgName = 'Quad Leadframe';
		setupInstaller();
		
		pg.Au_Cost__c = 1690;
		update pg;
		
		loadPfMap();
			
		fieldMap = new Map<String, RFQI_Field_Def__c>();
		List<RFQI_Field_Def__c> fieldList = [select id, name from RFQI_Field_Def__c];
		for(RFQI_Field_Def__c row : fieldList) fieldMap.put(row.name, row);
		
		loadAssumptions();
		loadBoms();
		loadProcs();
		loadMatches();
		loadMargins();
		loadValues();
		
		postInstall();
	}
	
	private void loadAssumptions() 
	{
		List<FCM_Assumption__c> assumptionList = new List<FCM_Assumption__c>();
		
		FCM_Assumption__c fcmA = null;
		Package_Family__c pf = null;
		
		pf = pfMap.get('TQFP'); 
		if (pf != null)
		{
			
			fcmA = new FCM_Assumption__c(CM_Version__c=cmVersion.id, Product_Group__c=pgId, Package_Family__c=pf.id);
			fcmA.Cum_Yield_Percent__c = 100;
			fcmA.Utilization_Efficiency_Percent__c = 70.0;
			fcmA.Available_Hours_Per_Week__c = 168;			
			fcmA.Equipment_Life__c = 7;
			fcmA.Work_Weeks_Year__c = 50;
			fcmA.Material_Freight_Percent__c = 2;
			fcmA.Material_Tooling_Percent__c = 2;
			fcmA.Material_Brokerage_Percent__c = 0;
			fcmA.FCM_Is_Dedicated__c = false;

			//these values are gotten from the "rates" tab, which the spreadsheet was pulling from
			fcmA.Service_Cost_To_Process_Cost__c = 0.058;
			fcmA.QA_Cost_To_Process_Cost__c = 0.046;
			fcmA.Annual_Fac_Cost_Sqft__c= 23.81;
			fcmA.Direct_Labor_Rate__c = 15.1386809815951;
			fcmA.Forecast_Factor_1__c = 0.966864820932894;
			fcmA.Forecast_Factor_2__c = 0.805720684110745;  
			fcmA.Forecast_Factor_3__c = 0.644576547288596;   
			fcmA.Manuf_OH_To_Process_Cost__c = 0.256;

			//these  values are gotten from the "Asusmptions tab"
			/*
			fcmA.Service_Cost_To_Process_Cost__c = 0.062604782411213;
			fcmA.QA_Cost_To_Process_Cost__c = 0.0921991602185734;
			fcmA.Annual_Fac_Cost_Sqft__c = 31.0250183366521;
			fcmA.Direct_Labor_Rate__c = 12.7577542189638;
			fcmA.Forecast_Factor_2__c = 1.337130803900691;//0.805720684110745;  
			fcmA.Forecast_Factor_1__c = fcmA.Forecast_Factor_2__c * 1.2;
			fcmA.Forecast_Factor_3__c = fcmA.Forecast_Factor_2__c * 0.8;  
			fcmA.Manuf_OH_To_Process_Cost__c = 0.151112153932877; 
			*/
			
			assumptionList.add( fcmA);
		}
		
		pf = pfMap.get('MQFP');
		if (pf != null)
		{
			fcmA = new FCM_Assumption__c(CM_Version__c=cmVersion.id, Product_Group__c=pgId, Package_Family__c=pf.id);
			fcmA.Cum_Yield_Percent__c = 100;
			fcmA.Utilization_Efficiency_Percent__c = 70.0;
			fcmA.Manuf_OH_To_Process_Cost__c = 0.0521378354192182;
			fcmA.QA_Cost_To_Process_Cost__c = 0.0600599234567673;
			fcmA.Service_Cost_To_Process_Cost__c = 0.0577648813427664;
			fcmA.Available_Hours_Per_Week__c = 168;
			fcmA.Direct_Labor_Rate__c = 12.7577542189638;
			fcmA.Off_Equipment_Direct_To_Direct__c = 0.14340490797546;
			fcmA.Equipment_Life__c = 7;
			fcmA.Work_Weeks_Year__c = 50;
			fcmA.Annual_Fac_Cost_Sqft__c = 31.0250183366521;
			fcmA.Material_Freight_Percent__c = 2;
			fcmA.Material_Tooling_Percent__c = 2;
			fcmA.Material_Brokerage_Percent__c = 0;
			fcmA.Forecast_Factor_1__c = 0.966864820932894;
			fcmA.Forecast_Factor_2__c = 0.805720684110745;  
			fcmA.Forecast_Factor_3__c = 0.644576547288596;   
			fcmA.FCM_Is_Dedicated__c = false;
			assumptionList.add( fcmA);
		}
		
		pf = pfMap.get('tsCSP');
		if (pf != null)
		{
			fcmA = new FCM_Assumption__c(CM_Version__c=cmVersion.id, Product_Group__c=pgId, Package_Family__c=pf.id);
			fcmA.Cum_Yield_Percent__c = 100;
			fcmA.Utilization_Efficiency_Percent__c = 70.0;
			fcmA.Manuf_OH_To_Process_Cost__c = 0.137115118404964;
			fcmA.QA_Cost_To_Process_Cost__c = 0.0306729609315371;
			fcmA.Service_Cost_To_Process_Cost__c = 0.0591571424272184;
			fcmA.Available_Hours_Per_Week__c = 168;
			fcmA.Direct_Labor_Rate__c = 12.7577542189638;
			fcmA.Off_Equipment_Direct_To_Direct__c =  0.14340490797546;
			fcmA.Equipment_Life__c = 7;
			fcmA.Work_Weeks_Year__c = 50;
			fcmA.Annual_Fac_Cost_Sqft__c = 49.5223473852678;
			fcmA.Material_Freight_Percent__c = 2;
			fcmA.Material_Tooling_Percent__c = 2;
			fcmA.Material_Brokerage_Percent__c = 0;
			fcmA.Forecast_Factor_1__c = 0.966864820932894;
			fcmA.Forecast_Factor_2__c = 0.805720684110745;  
			fcmA.Forecast_Factor_3__c = 0.644576547288596;   
			fcmA.FCM_Is_Dedicated__c = false;
			assumptionList.add( fcmA);
		}
		
		insert assumptionList;
	}
	
	private void loadBoms()
	{
		//loadBom(String name, String typeVal,String seq, String pg,string pf, String catVal, String leadCount, String hasVariants, string uom, String decription, String parent, String sid, String costUnit, String usageScrap, String baseQty, String column, String mfgCost, String purchasePrice, String row, String stdUsage, String stripSublot, String troyOz, String unitsStrip, String usageRate, String index, String timePerWire)
		loadBom('LF-TQFP','Item','10','','TQFP','Leadframe','','TRUE','kpc/kunit','','','','','','','','','','','','','','Leadframe','1','','');
		loadBom('LF','Item','10','','LQFP','Leadframe','','TRUE','kpc/kunit','','','','','','','','','','','','','','Leadframe','1','','');
		//loadBom('EP','Item','30','','','','','FALSE','cc/kunit','EP, QMI 536 (BN1144) 5CC/10CC','','101316643','','','','','','5.06','','','','','','1.51169910728567','','');
		//loadBom('WU B','Item','50','','','','','FALSE','kft/kunit','Wire per instructions','','','','','','','','','','','','','','1.07491516766931','','');
		//loadBom('TR','Item','70','','','','','FALSE','pc/kunit','TR','','','','','','','','','','','','','','','','');
		
		loadBom('EP','Item','100','','','Quad-EP','','TRUE','cc/kunit','','','','','','','','','','','','','','ODM','1.51169910728567','',''); 
		
		//---Wire
		loadBom('WU-Au','Item','200','','','Quad-Au','','TRUE','kft/kunit','Wire per instructions','','','','','','','','','','','','','Wire','1.07491516766931','','');
		loadBom('WU-Cu','Item','300','','','Quad-Wire','','FALSE','kft/kunit','Wire per instructions','','','','','','','','0.01','','','','','Wire','1.07491516766931','','');
		loadBom('WU-PCC','Item','400','','','Quad-Wire','','FALSE','kft/kunit','Wire per instructions','','','','','','','','0.018','','','','','Wire','1.07491516766931','','');
		
		//Mold compound price changed by AMK-914
		loadBom('MC','Item','500','','','Quad-MC','','TRUE','kg/kunit','EMC, G700Y','','101357447','','','','','','17.74','','','','','ODM','1.07491516766931','','');

		loadBom('MC-TQFP','Item','500','','TQFP','Quad-MC','','TRUE','kg/kunit','EMC, G700Y','','101357447','','','','','','','','1','','','ODM','1','','');
		
	
		//---Save current list and load into map (For parent matching) 
		insert bomList;
		bomMap = new Map<String, FCM_BOM__c>();
		for(FCM_BOM__c row : bomList) bomMap.put(row.name, row);
		bomList = new List<FCM_BOM__c>();		
		
		
		//---AU Variants by wire diameter
		loadBom('Au 0.6','Variant','210','','','','','FALSE','','','WU-Au','','3.5','','','','','','','','','','','','','');
		loadBom('Au 0.7','Variant','220','','','','','FALSE','','','WU-Au','','3.0','','','','','','','','','','','','','');
		loadBom('Au 0.8','Variant','230','','','','','FALSE','','','WU-Au','','2.6','','','','','','','','','','','','','');
		loadBom('Au 0.9','Variant','240','','','','','FALSE','','','WU-Au','','2.6','','','','','','','','','','','','','');
		loadBom('Au 1.0','Variant','250','','','','','FALSE','','','WU-Au','','2.6','','','','','','','','','','','','','');
		loadBom('Au 1.2','Variant','260','','','','','FALSE','','','WU-Au','','2.6','','','','','','','','','','','','','');
		loadBom('Au 1.3','Variant','270','','','','','FALSE','','','WU-Au','','2.6','','','','','','','','','','','','','');
		loadBom('Au 1.5','Variant','280','','','','','FALSE','','','WU-Au','','2.6','','','','','','','','','','','','','');
		loadBom('Au 2.0','Variant','290','','','','','FALSE','','','WU-Au','','2.6','','','','','','','','','','','','','');
		
		loadBom('EP1','Variant','110','','','','','FALSE','','EP, ABLEBOND 3230(RP323-16) 20CC','EP','101356448','','','','','','4.460','','','','','','','','');
		loadBom('EP2','Variant','110','','','','','FALSE','','EP, QMI 536 (BN1144) 5CC/10CC','EP','101316643','','','','','','5.060','','','','','','','','');
		
		
		loadBom('LF 5x5'  ,'Variant','11','','TQFP','','','FALSE','','','LF-TQFP','','','','','','','0.0200963157894737','','','','','','','','');
		loadBom('LF 7x7'  ,'Variant','12','','TQFP','','','FALSE','','','LF-TQFP','','','','','','','0.0227475','','','','','','','','');
		loadBom('LF 10x10','Variant','13','','TQFP','','','FALSE','','','LF-TQFP','','','','','','','0.0348533333333333','','','','','','','','');
		loadBom('LF 12x12','Variant','14','','TQFP','','','FALSE','','','LF-TQFP','','','','','','','0.0511352380952381','','','','','','','','');
		loadBom('LF 14x14','Variant','15','','TQFP','','','FALSE','','','LF-TQFP','','','','','','','0.0529870588235294','','','','','','','','');
		loadBom('LF 16x16','Variant','16','','TQFP','','','FALSE','','','LF-TQFP','','','','','','','0.0596','','','','','','','','');
		loadBom('LF 20x20','Variant','17','','TQFP','','','FALSE','','','LF-TQFP','','','','','','','0.095970753968254','','','','','','','','');
		loadBom('LF 24x24','Variant','18','','TQFP','','','FALSE','','','LF-TQFP','','','','','','','0.1357275','','','','','','','','');
		loadBom('LF 28x28','Variant','19','','TQFP','','','FALSE','','','LF-TQFP','','','','','','','0.176303333333333','','','','','','','','');

		loadBom('MC 5x5'  ,'Variant','510','','TQFP','','','FALSE','','','MC-TQFP','','','','','','','0.0051','','','','','','','','');
		loadBom('MC 7x7'  ,'Variant','520','','TQFP','','','FALSE','','','MC-TQFP','','','','','','','0.00729','','','','','','','','');
		loadBom('MC 10x10','Variant','530','','TQFP','','','FALSE','','','MC-TQFP','','','','','','','0.00984','','','','','','','','');
		loadBom('MC 12x12','Variant','540','','TQFP','','','FALSE','','','MC-TQFP','','','','','','','0.0153','','','','','','','','');
		loadBom('MC 14x14','Variant','550','','TQFP','','','FALSE','','','MC-TQFP','','','','','','','0.01931','','','','','','','','');
		loadBom('MC 16x16','Variant','560','','TQFP','','','FALSE','','','MC-TQFP','','','','','','','0.02915','','','','','','','','');
		loadBom('MC 20x20','Variant','570','','TQFP','','','FALSE','','','MC-TQFP','','','','','','','0.03589','','','','','','','','');
		loadBom('MC 24x24','Variant','580','','TQFP','','','FALSE','','','MC-TQFP','','','','','','','0.04081','','','','','','','','');
		loadBom('MC 28x28','Variant','590','','TQFP','','','FALSE','','','MC-TQFP','','','','','','','0.12662','','','','','','','','');
		
		//---Save list 
		insert bomList;
		bomVariantMap = new Map<String, FCM_BOM__c>();
		for(FCM_BOM__c row : bomList) bomVariantMap.put(row.name, row);
	}
	
	private void loadProcs()
	{
		procList = new List<FCM_Process__c>();	
		loadProc('W/B/G 1-W/B/G_18.0+-0.5M TOLERANCE','','Item','Standard','FALSE','','354.661','46.500093000186','','1.7','','','10','','VG502MKII8','');
		loadProc('W/B/Q_5 WFRS / LOT-W/B/Q_5 WFRS / LOT','','Item','Standard','FALSE','','','','','','','','20','','','');
		loadProc('WAF/M-WAF/M_','','Item','Standard','FALSE','','300','22.14136287','','2','','','30','','AWM-A100/8','');
		loadProc('SAW/C 1-SAW/C_CO2 BUBBLER','','Item','Standard','FALSE','','137.158','22.1155303421718','','8.5','2793','','40','','DFD640','');
		loadProc('2ND/Q_LTPD  5/0-2ND/Q_LTPD  5/0','','Item','Standard','FALSE','','','','','','','','50','','','');
		loadProc('W/B/G2-W/B/G_10.0+-0.5M TOLERANCE','','Item','Standard','FALSE','','354.661','46.500093000186','','1.7','37113','','60','','VG502MKII8','');
		loadProc('W/B/Q_5 WFRS / LOT-W/B/Q_5 WFRS / LOT','','Item','Standard','FALSE','','','','','','','','70','','','');
		loadProc('WAF/M2-WF/M2_','','Item','Standard','FALSE','','118.672','22.14136287','','2','92308','','80','','AWM-A100/8','');
		loadProc('SAW/C2-SAW/2_CO2 BUBBLER','','Item','Standard','FALSE','','137.158','22.1155303421718','','8.5','4885','','90','','DFD640','');
		loadProc('2ND/Q_LTPD  5/0-2ND/Q_LTPD  5/0','','Item','Standard','FALSE','','','','','','','','100','','','');
		loadProc('D/A 1-D/A_CUSTOMER MAP','','Item','Standard','FALSE','','200','30.19276755','','3.7','3000','','110','','AD-8912','');
		loadProc('DA/CU 1-DA/CU_175+-5C/ 15MIN','','Item','Standard','FALSE','','39','22','','12','5349','','120','','HS-3600A','');
		loadProc('D/A2-D/A-2_CUSTOMER MAP','','Item','Standard','FALSE','','200','30.19276755','','3.7','2329','','130','','AD-8912','');
		loadProc('DA/CU2-DA/C2_175+-5C/15MIN','','Item','Standard','FALSE','','39','22','','12','5349','','140','','HS-3600A','');
		loadProc('PLAS2-PLAS2_','','Item','Standard','FALSE','','88','19.53649665','','4','8372','','150','','VSP-88H','');
		loadProc('W/B_Wire-W/B_200+-10C AU','','Item','Standard','FALSE','','60','11.973773484','','30','','','160','','ASM_E60','');
		//loadProc('W/B_Wire A-W/B_200+-10C AU','','Item','Standard','FALSE','','60','11.973773484','','30','','','160','','ASM_E60','');
		//loadProc('Ex/WI_ExTRA WIRES:121-130-','','Item','Standard','FALSE','','','','','','','','170','','','');
		//loadProc('3RD/Q_LTPD 5/0-','','Item','Standard','FALSE','','','','','','','','180','','','');
		//loadProc('W/B Wire B-W/B_200+-10C AU','','Item','Standard','FALSE','','60','11.973773484','','30','','','190','','ASM_E60','');
		loadProc('Ex/WI_ExTRA WIRES:121-130-','','Item','Standard','FALSE','','','','','','','','200','','','');
		loadProc('3RD/Q_LTPD 5/0-','','Item','Standard','FALSE','','','','','','','','210','','','');
		loadProc('MOLD-MOLD_MATTE','','Item','Standard','FALSE','','574.647','57.8829282658565','','2.8','13440','','220','','APM_4','');
		loadProc('DFLSH-DFLSH_','','Item','Standard','FALSE','','391.943','117.283567900469','','2.5','8471','','230','','JETEK_AUTO','');
		loadProc('P/CUR-P/CUR_175+-5C / 4 HR','','Item','Standard','FALSE','','39','14.8541958','','30','3547','','240','','REMCO-2900HS','');
		loadProc('LASER-LASER_TOP','','Item','Standard','FALSE','','240','26','','5.5','5941','','250','','','EO2_DYANG_818');
		loadProc('TRIM-TRIM_','','Item','Standard','FALSE','','357.75','19.8529563725794','','3.7','18090','','260','','TR-A-H-APM_S3','');
		loadProc('SN-SN_MATTE SN','','Item','Standard','FALSE','','1001.507','581.251162502325','','1.9','12811','','270','','TECH_SP800','');
		loadProc('P/P/B-P/P/B_150+-5C/1HR+10/-0M','','Item','Standard','FALSE','','39','14.8541958','','15.2','13585','','280','','REMCO-2900HS','');
		loadProc('FM/SG-FM/SG_TQFP-1.0  / 0.1','','Item','Standard','FALSE','','357.75','19.8529563725794','','3.8','8000','','290','','FS-A-H-APM_S3','');
		//loadProc('FVI/Q_LTPD 5/0-FVI/Q_LTPD 5/0','','Item','Standard','FALSE','','','','','','','','300','','','');
		loadProc('PACK-PACK_','','Item','Standard','FALSE','','1','8','','1','72000','','310','','','');

		insert procList;
		procMap = new Map<String, FCM_Process__c>();
		for(FCM_Process__c row : procList) procMap.put(row.name, row);
	}
	
	private void loadMatches()
	{
		//---BOM
		loadMatch('WU-Au','','WireTextValue','Contains','Wire_Material__c','Au','FALSE');
		loadMatch('WU-Cu','','WireTextValue','Contains','Wire_Material__c','Cu','FALSE');
		//Lalit SF-85
		loadMatch('WU-PCC','','WireTextValue','Contains','Wire_Material__c','AuPCC','FALSE');
		
		loadMatch('Au 0.6','','WireTextValue','Contains','Wire_Diameter__c','0.6','FALSE');
		loadMatch('Au 0.7','','WireTextValue','Contains','Wire_Diameter__c','0.7','FALSE');
		loadMatch('Au 0.8','','WireTextValue','Contains','Wire_Diameter__c','0.8','FALSE');
		loadMatch('Au 0.9','','WireTextValue','Contains','Wire_Diameter__c','0.9','FALSE');
		loadMatch('Au 1.0','','WireTextValue','Contains','Wire_Diameter__c','1.0','FALSE');
		loadMatch('Au 1.2','','WireTextValue','Contains','Wire_Diameter__c','1.2','FALSE');
		loadMatch('Au 1.3','','WireTextValue','Contains','Wire_Diameter__c','1.3','FALSE');
		loadMatch('Au 1.5','','WireTextValue','Contains','Wire_Diameter__c','1.5','FALSE');
		loadMatch('Au 2.0','','WireTextValue','Contains','Wire_Diameter__c','2.0','FALSE');
		
		loadMatch('MC 5x5'  ,'','ItemTextValue','Equals','Body_Size__c','5x5'  ,'FALSE');
		loadMatch('MC 7x7'  ,'','ItemTextValue','Equals','Body_Size__c','7x7'  ,'FALSE');
		loadMatch('MC 10x10','','ItemTextValue','Equals','Body_Size__c','10x10','FALSE');
		loadMatch('MC 12x12','','ItemTextValue','Equals','Body_Size__c','12x12','FALSE');
		loadMatch('MC 14x14','','ItemTextValue','Equals','Body_Size__c','14x14','FALSE');
		loadMatch('MC 14x20','','ItemTextValue','Equals','Body_Size__c','14x20','FALSE');
		loadMatch('MC 20x20','','ItemTextValue','Equals','Body_Size__c','20x20','FALSE');
		loadMatch('MC 24x24','','ItemTextValue','Equals','Body_Size__c','24x24','FALSE');
		loadMatch('MC 28x28','','ItemTextValue','Equals','Body_Size__c','28x28','FALSE');
		loadMatch('EP1','','DiePosition','','','','', '1');
		loadMatch('EP2','','DiePosition','','','','', '2');
		loadMatch('MC','','AlwaysItem','','','','');

		loadMatch('LF 5x5','','ItemTextValue','Equals','Body_Size__c', '5x5' ,'FALSE');
		loadMatch('LF 7x7','','ItemTextValue','Equals','Body_Size__c', '7x7' ,'FALSE');
		loadMatch('LF 10x10','','ItemTextValue','Equals','Body_Size__c', '10x10' ,'FALSE');
		loadMatch('LF 12x12','','ItemTextValue','Equals','Body_Size__c', '12x12' ,'FALSE');
		loadMatch('LF 14x14','','ItemTextValue','Equals','Body_Size__c', '14x14' ,'FALSE');
		loadMatch('LF 16x16','','ItemTextValue','Equals','Body_Size__c', '16x16' ,'FALSE');
		loadMatch('LF 20x20','','ItemTextValue','Equals','Body_Size__c', '20x20' ,'FALSE');
		loadMatch('LF 24x24','','ItemTextValue','Equals','Body_Size__c', '24x24' ,'FALSE');
		loadMatch('LF 28x28','','ItemTextValue','Equals','Body_Size__c', '28x28' ,'FALSE');
		
		//---Process
		loadMatch('','W/B/G 1-W/B/G_18.0+-0.5M TOLERANCE','AlwaysItem','','','','');
		loadMatch('','W/B/Q_5 WFRS / LOT-W/B/Q_5 WFRS / LOT','AlwaysItem','','','','');
		loadMatch('','WAF/M-WAF/M_','AlwaysItem','','','','');
		loadMatch('','SAW/C 1-SAW/C_CO2 BUBBLER','AlwaysItem','','','','');
		loadMatch('','2ND/Q_LTPD  5/0-2ND/Q_LTPD  5/0','AlwaysItem','','','','');
		loadMatch('','W/B/G2-W/B/G_10.0+-0.5M TOLERANCE','DieTextValue','Equals','Wafer_Material__c','Silicon','FALSE');
		loadMatch('','W/B/Q_5 WFRS / LOT-W/B/Q_5 WFRS / LOT','AlwaysItem','','','','');
		loadMatch('','WAF/M2-WF/M2_','DieCountMin','','','','','2');				
		loadMatch('','SAW/C2-SAW/2_CO2 BUBBLER','DieCountMin','','','','','2');
		loadMatch('','2ND/Q_LTPD  5/0-2ND/Q_LTPD  5/0','AlwaysItem','','','','');
		loadMatch('','D/A 1-D/A_CUSTOMER MAP','AlwaysItem','','','','');
		loadMatch('','DA/CU 1-DA/CU_175+-5C/ 15MIN','AlwaysItem','','','','');
		loadMatch('','D/A2-D/A-2_CUSTOMER MAP','AlwaysItem','','','','');
		loadMatch('','DA/CU2-DA/C2_175+-5C/15MIN','DieCountMin','','','','','2');
		loadMatch('','PLAS2-PLAS2_','DieCountMin','','','','','2');
		//loadMatch('','W/B_Wire A-W/B_200+-10C AU','AlwaysItem','','','','');
		loadMatch('','W/B_Wire-W/B_200+-10C AU','AlwaysWire','','','','');
		
		loadMatch('','Ex/WI_ExTRA WIRES:121-130-','AlwaysItem','','','','');
		loadMatch('','3RD/Q_LTPD 5/0-','AlwaysItem','','','','');
		//loadMatch('','W/B Wire B-W/B_200+-10C AU','AlwaysItem','','','','');
		//loadMatch('','Ex/WI_ExTRA WIRES:121-130-','AlwaysItem','','','','');
		//loadMatch('','3RD/Q_LTPD 5/0-','AlwaysItem','','','','');
		loadMatch('','MOLD-MOLD_MATTE','AlwaysItem','','','','');
		loadMatch('','DFLSH-DFLSH_','AlwaysItem','','','','');
		loadMatch('','P/CUR-P/CUR_175+-5C / 4 HR','AlwaysItem','','','','');
		loadMatch('','LASER-LASER_TOP','AlwaysItem','','','','');
		loadMatch('','TRIM-TRIM_','AlwaysItem','','','','');
		loadMatch('','SN-SN_MATTE SN','ItemTextValue','NotContains','Leadframe_Finish__c','PPF','FALSE');
		loadMatch('','P/P/B-P/P/B_150+-5C/1HR+10/-0M','ItemTextValue','NotContains','Leadframe_Finish__c','PPF','FALSE');
		loadMatch('','FM/SG-FM/SG_TQFP-1.0  / 0.1','AlwaysItem','','','','');
		//loadMatch('','FVI/Q_LTPD 5/0-FVI/Q_LTPD 5/0','AlwaysItem','','','','');
		loadMatch('','PACK-PACK_','AlwaysItem','','','','');
	
		insert matchList;
	}
	
	private void loadValues()
	{
		loadValue('MQFP', '0.291', '0.36375');
		loadValue('TQFP', '0.254', '0.3175');
		
		insert valueList;
	}

	private void loadMargins()
	{
		marginList = new List<CM_Margin__c>();
		loadMargin('0', '35');
		loadMargin('50', '35');
		loadMargin('250', '30');
		loadMargin('510', '25');

		insert marginList;
	}

	global static void incrementalInstall1()
	{
		FCM_BOM__c parentBom = [select id, Name, Purchase_Price__c, Standard_Usage__c from fcm_bom__c where Name='MC-TQFP' and CM_Version__r.Product_Group__r.Name='Quad Leadframe'];

		parentBom.Purchase_Price__c = 17.74;
		parentBom.Usage_Rate__c = 1.02698945230528;
		parentBom.Standard_Usage__c = null;

		List<FCM_BOM__c> children = [select id, Name, Purchase_Price__c, Standard_Usage__c from FCM_BOM__c where Parent_BOM__c=:parentBom.Id order by Sequence__c asc];

		Map<String, Decimal> mappings = new Map<String, Decimal>();

		mappings.put('MC 5x5', 0.28);
		mappings.put('MC 7x7', 0.4);
		mappings.put('MC 10x10', 0.54);
		mappings.put('MC 12x12', 0.84);
		mappings.put('MC 14x14', 1.06);
		mappings.put('MC 16x16', 1.06);
		mappings.put('MC 20x20', 1.97);
		mappings.put('MC 24x24', 2.24);
		mappings.put('MC 28x28', 6.95);
		mappings.put('MC 32x32', 8.88);

		for (FCM_BOM__c row : children)
		{
			row.Purchase_Price__c = null;
			row.Purchase_Price_Calc__c = 17.74;
			row.Purchase_Price_OR__c = true;
			row.Usage_Rate__c = null;
			row.Usage_Rate_Calc__c = 1.02698945230528;
			row.Usage_Rate_OR__c = true;
			row.Standard_Usage__c = mappings.get(row.Name);
			row.Standard_Usage_Calc__c = mappings.get(row.Name);
		}
		update parentBom;
		update children;

	}
}