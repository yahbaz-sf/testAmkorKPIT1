/*************************************************************************
*
* PURPOSE: Dual Installer
*
* CLASS: CMFCMInstaller
* CREATED: 5/01/2013 Ethos Solutions - www.ethos.com 
* AUTHOR: Steve Simpson
***************************************************************************/ 
global class CMDualInstaller extends CMFCMInstaller
{
	global static void cleanAndInstall() 
	{
		clean();
		CMDualInstaller installer = new CMDualInstaller();
		//installer.cleanAll();
		installer.installFCM(); 
	}
	
	global static void install() 
	{
		CMDualInstaller installer = new CMDualInstaller();
		installer.installFCM();
	}
	
	global static void clean() 
	{
		CMDualInstaller installer = new CMDualInstaller();
		installer.clean('Dual Leadframe');
	}
	
	public override void installFCM()
	{
		pgName = 'Dual Leadframe';
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
		
		postInstall();
	}
	
	private void loadAssumptions()
	{
		List<FCM_Assumption__c> assumptionList = new List<FCM_Assumption__c>();
		
		FCM_Assumption__c fcmA = new FCM_Assumption__c(CM_Version__c=cmVersion.id, Product_Group__c=pgId);
		fcmA.Cum_Yield_Percent__c = 99.8;
		fcmA.Utilization_Efficiency_Percent__c = 70.0;
		fcmA.Manuf_OH_To_Process_Cost__c = 0.558003950025957;
		fcmA.QA_Cost_To_Process_Cost__c = 0.0562590159178489;
		fcmA.Service_Cost_To_Process_Cost__c = 0.06672084523198;
		fcmA.Available_Hours_Per_Week__c = 168;
		fcmA.Direct_Labor_Rate__c = 2.8133074290548;
		fcmA.Off_Equipment_Direct_To_Direct__c =  0.142942472201648;
		fcmA.Equipment_Life__c = 7;
		fcmA.Work_Weeks_Year__c = 50;
		//fcmA.Annual_Fac_Cost_Sqft__c = 31;
		fcmA.Annual_Fac_Cost_Sqft__c = 30.5463157891104;
		fcmA.Material_Freight_Percent__c = 2;
		fcmA.Material_Tooling_Percent__c = 2;
		fcmA.Material_Brokerage_Percent__c = 0;
		fcmA.Forecast_Factor_1__c = 1.68351246131644;
		fcmA.Forecast_Factor_2__c = 1.40292705109703;
		fcmA.Forecast_Factor_3__c = 1.12234164087763;
		fcmA.FCM_Is_Dedicated__c = false;
		assumptionList.add( fcmA);
		
		insert assumptionList;
	}
	
	private void loadBoms()
	{
		loadBom('R-Ag (Ring Silver) Lead Frame','Item','10','Dual Leadframe','','Leadframe','','TRUE','KUnits','R-Ag','','','','1.012','','','','','','','','','Leadframe','','','');
		loadBom('Lead Frame - Rough Adder','Item','20','Dual Leadframe','','Standard','','TRUE','KUnits','','','','','1.012','','','','','','','','','Leadframe','','','');
		loadBom('Lead Frame- Etch adder','Item','30','Dual Leadframe','','Leadframe','','TRUE','KUnits','','','','','1.012','','','','','','','','','Leadframe','','','');
		loadBom('S-Ag (Spot Silver) Lead Frame','Item','40','Dual Leadframe','','Leadframe','','TRUE','KUnits','','','','','1.012','','','','','','','','','Leadframe','','','');
		loadBom('Lead Frame - Rough Adder','Item','50','Dual Leadframe','','Leadframe','','TRUE','KUnits','','','','','1.012','','','','','','','','','Leadframe','','','');
		loadBom('Lead Frame- Etch adder','Item','60','Dual Leadframe','','Leadframe','','TRUE','KUnits','','','','','1.012','','','','','','','','','Leadframe','','','');
		loadBom('DR-Ag (Double Ring Silver) Lead Frame','Item','70','Dual Leadframe','','Leadframe','','TRUE','KUnits','','','','','1.012','','','','','','','','','Leadframe','','','');
		loadBom('Lead Frame - Rough Adder','Item','80','Dual Leadframe','','Leadframe','','TRUE','KUnits','','','','','1.012','','','','','','','','','Leadframe','','','');
		loadBom('Lead Frame- Etch adder','Item','90','Dual Leadframe','','Leadframe','','TRUE','KUnits','','','','','1.012','','','','','','','','','Leadframe','','','');
		loadBom('TL-PPF (Pre-Plated Frame) Lead Frame','Item','100','Dual Leadframe','','Leadframe','','TRUE','KUnits','','','','','1.012','','','','','','','','','Leadframe','','','');
		loadBom('Lead Frame - Rough Adder','Item','110','Dual Leadframe','','Leadframe','','TRUE','KUnits','','','','','1.012','','','','','','','','','Leadframe','','','');
		loadBom('Lead Frame- Etch adder','Item','120','Dual Leadframe','','Leadframe','','TRUE','CCM','','','','','1.012','','','','','','','','','Leadframe','','','');

  		loadBom('Au Wire','Item','130','Dual Leadframe','','AuWire','','TRUE','KFt','','','','','','','','','','','','','','Wire','','','');
		loadBom('Cu Wire','Item','140','Dual Leadframe','','Wire','','TRUE','Ft','','','','','','','','','','','','','','Wire','','','');
		loadBom('PCC Wire','Item','150','Dual Leadframe','','Wire','','TRUE','','','','','','','','','','','','','','','Wire','','','');
		loadBom('Ag Wire','Item','160','Dual Leadframe','','Wire','','TRUE','','','','','','','','','','','','','','','Wire','','','');
		
		loadBom('Mold Compound','Item','200','Dual Leadframe','','Mold','','TRUE','Gm','','','','','1.012','','','','','','','','','ODM','','','');
		loadBom('Silver Filled Epoxy','Item','210','Dual Leadframe','','Standard','','TRUE','CCM','','','101374994','','1.15','','','','2.39','','1.216','','','ODM','','','');
		loadBom('Non_Conductive_Epoxy','Item','220','Dual Leadframe','','Standard','','TRUE','Unit','','','','','','','','','','','','','','ODM','','','');
		loadBom('High_Thermal_Performance_Epoxy','Item','230','Dual Leadframe','','Standard','','TRUE','CCM','','','','','1.15','','','','','','','','','ODM','','','');
		loadBom('Sintered','Item','240','Dual Leadframe','','Standard','','TRUE','CCM','','','','','1.15','','','','','','','','','ODM','','','');
		loadBom('Non_Conductive_Film','Item','250','Dual Leadframe','','Standard','','TRUE','CCM','','','','','1.15','','','','','','','','','ODM','','','');
		loadBom('Conductive_Film','Item','260','Dual Leadframe','','Standard','','TRUE','','','','','','1.012','','','','','','','','','ODM','','','');
		loadBom('Hi_Pb_Solder','Item','270','Dual Leadframe','','Standard','','TRUE','Ft','','','','','','','','','','','','','','ODM','','','');
		loadBom('No_Pb_Solder','Item','280','Dual Leadframe','','Standard','','TRUE','Ft','','','','','','','','','','','','','','ODM','','','');
		loadBom('Die Coat','Item','290','Dual Leadframe','','Standard','','TRUE','Ft','','','','','1.012','','','','','','','','','ODM','','','');
		loadBom('Forming gas - For Cu wire','Item','350','Dual Leadframe','','FormingGas','','TRUE','','','','','','','','','','','','','','','ODM','','','');
		loadBom('Forming gas - For PCC wire','Item','360','Dual Leadframe','','FormingGas','','TRUE','L/Hr','','','','','','','','','','','','','','ODM','','','');

		loadBom('Tube Plug','Item','300','Dual Leadframe','','Standard','','TRUE','','','','','','','','','','','','','','','ODM','','','');
		loadBom('BOX','Item','310','Dual Leadframe','','Standard','','TRUE','','','','','','','','','','','','','','','ODM','','','');
		loadBom('TUBE','Item','330','Dual Leadframe','','Standard','','TRUE','','','','','','','','','','','','','','','ODM','','','');
		loadBom('PACKING MATERIALS','Item','340','Dual Leadframe','','Standard','','TRUE','','','','','','','','','','','','','','','ODM','','','');
		loadBom('BAG','Item','','Dual Leadframe','','Standard','','TRUE','','','','','','','','','','','','','','','ODM','','','');

		//---Save current list and load into map (For parent matching) 
		insert bomList;
		bomMap = new Map<String, FCM_BOM__c>();
		for(FCM_BOM__c row : bomList) bomMap.put(row.name, row);
		bomList = new List<FCM_BOM__c>();		

		//To Do check Troy Oz/ K-ft for Au and Ag
		loadBom('Forming gas - For Cu wire','Variant','10','Dual Leadframe','SOIC 150mil Body','FormingGas','8ld','FALSE','L/Hr','H2N2 Forming gas','Forming gas - For Cu wire','Forming gas','0.00585','','','','','','','','','','','','0.710400000','0.166700000');
		loadBom('R-Ag (Ring Silver) Lead Frame','Variant','10','Dual Leadframe','SOIC 150mil Body','Leadframe','8ld','FALSE','k-units','R-Ag','R-Ag (Ring Silver) Lead Frame','101','','1.012','0','40','','5.18','15','1','80','','','','','');
		loadBom('Lead Frame - Rough Adder','Variant','10','Dual Leadframe','SOIC 150mil Body','Leadframe','8ld','FALSE','k-units','R-Ag','Lead Frame - Rough Adder','101','','1.012','0','40','','1.2','15','1','80','','','','','');
		loadBom('Lead Frame- Etch adder','Variant','10','Dual Leadframe','SOIC 150mil Body','Leadframe','8ld','FALSE','k-units','R-Ag','Lead Frame- Etch adder','101','','1.012','0','40','','1.3','15','1','80','','','','','');
		loadBom('S-Ag (Spot Silver) Lead Frame','Variant','10','Dual Leadframe','SOIC 150mil Body','Leadframe','8ld','FALSE','','S-Ag','S-Ag (Spot Silver) Lead Frame','','','1.012','0','40','','6.18','15','1','80','','','','','');
		loadBom('Lead Frame - Rough Adder','Variant','10','Dual Leadframe','SOIC 150mil Body','Leadframe','8ld','FALSE','','S-Ag','Lead Frame - Rough Adder','','','1.012','0','40','','1.2','15','1','80','','','','','');
		loadBom('Lead Frame- Etch adder','Variant','10','Dual Leadframe','SOIC 150mil Body','Leadframe','8ld','FALSE','','S-Ag','Lead Frame- Etch adder','','','1.012','0','40','','6.18','15','1','80','','','','','');
		loadBom('DR-Ag (Double Ring Silver)','Variant','10','Dual Leadframe','','Leadframe','','FALSE','','DR-Ag','DR-Ag (Double Ring Silver) Lead Frame','','','1.012','0','40','','7.18','15','1','80','','','','','');
		loadBom('Lead Frame - Rough Adder','Variant','10','Dual Leadframe','SOIC 150mil Body','Leadframe','8ld','FALSE','','DR-Ag','Lead Frame - Rough Adder','','','1.012','0','40','','1.2','15','1','80','','','','','');
		loadBom('Lead Frame- Etch adder','Variant','10','Dual Leadframe','SOIC 150mil Body','Leadframe','8ld','FALSE','','DR-Ag','Lead Frame- Etch adder','','','1.012','0','40','','1.3','15','1','80','','','','','');
		loadBom('TL-PPF (Pre-Plated Frame) Lead Frame','Variant','10','Dual Leadframe','SOIC 150mil Body','Leadframe','8ld','FALSE','','LF SO S 8L 90*90 C194 TLPPF 150B XD','TL-PPF (Pre-Plated Frame) Lead Frame','101378808','','1.012','0','40','','2.87','15','1','80','','','','','');
		loadBom('Lead Frame - Rough Adder','Variant','10','Dual Leadframe','SOIC 150mil Body','Leadframe','8ld','FALSE','','LF SO S 8L 90*90 C194 TLPPF 150B XD','Lead Frame - Rough Adder','101378808','','1.012','0','40','','0.97','15','1','80','','','','','');
		loadBom('Lead Frame- Etch adder','Variant','10','Dual Leadframe','SOIC 150mil Body','Leadframe','8ld','FALSE','','LF SO S 8L 90*90 C194 TLPPF 150B XD','Lead Frame- Etch adder','101378808','','1.012','0','40','','2.09','15','1','80','','','','','');
		loadBom('Silver Filled Epoxy','Variant','10','Dual Leadframe','SOIC 150mil Body','Standard','8ld','FALSE','CCM','EP EPOXY 8290 10CC - ABA-2','Silver Filled Epoxy','101374994','','1.15','','','','2.39','','1.215','','','','','','');
		loadBom('High_Thermal_Epoxy','Variant','10','Dual Leadframe','SOIC 150mil Body','Standard','8ld','FALSE','CCM','CRM-ZA236','High_Thermal_Performance_Epoxy','New Mat','','1.15','','','','2.39','','1.215','','','','','','');
		loadBom('Non_Conductive_Epoxy','Variant','10','Dual Leadframe','SOIC 150mil Body','Standard','8ld','FALSE','Unit','Non-Conductive','Non_Conductive_Epoxy','SID','','1.012','','','','3.95','','0','','','','','','');
		loadBom('Sintered','Variant','10','Dual Leadframe','SOIC 150mil Body','Standard','8ld','FALSE','CCM','D591-3B','Sintered','New Mat','','1.15','','','','12.465','','1.215','','','','','','');
		loadBom('Non_Conductive_Film','Variant','10','Dual Leadframe','SOIC 150mil Body','Standard','8ld','FALSE','','D591-3B','Non_Conductive_Film','New Mat','','1.012','','','','12.465','','1.215','','','','','','');
		loadBom('Conductive_Film','Variant','10','Dual Leadframe','SOIC 150mil Body','Standard','8ld','FALSE','','','Conductive_Film','','','1.012','','','','','','','','','','','','');
		loadBom('No_Pb_Solder','Variant','10','Dual Leadframe','SOIC 150mil Body','Standard','8ld','FALSE','','','No_Pb_Solder','','','1.012','','','','','','','','','','','','');
		loadBom('Die Coat','Variant','10','Dual Leadframe','SOIC 150mil Body','Standard','8ld','FALSE','','SOLDER PREFORM WIRE TYPE, PB95/SN5, 30MI','Die Coat','101300679','','1.012','','','','1.07','','0.008','','','','','','');
		loadBom('0.6mil_Cu','Variant','10','Dual Leadframe','SOIC 150mil Body','Wire','','FALSE','Ft','','Cu Wire','','0.01','1.012','','','','0.009','','','','','','','','');
		loadBom('0.7mil_PCC','Variant','10','Dual Leadframe','SOIC 150mil Body','Wire','','FALSE','Ft','','PCC Wire','','0.02','1.012','','','','0.02134','','','','','','','','');
		loadBom('0.6mil_Ag','Variant','10','Dual Leadframe','SOIC 150mil Body','Wire','','FALSE','Ft','','Ag Wire','','2.8','1.012','','','','','','','','0.38377672710822','','','','');
		loadBom('Mold Compound','Variant','10','Dual Leadframe','SOIC 150mil Body','Mold','8ld','FALSE','Gm','EMC, EME-G700M(16*8.6) - SBS MADE','Mold Compound','101323649','14.05','1.012','','','','14.05','','0.065','','','','','','');
		loadBom('0.6mil_Au','Variant','10','Dual Leadframe','SOIC 150mil Body','AuWire','','FALSE','KFt','15UM(0.6MIL)','Au Wire','101347133','','1.012','','','4.8','','','','','0.0345399054397398','','','','');
		loadBom('Forming gas - For PCC wire','Variant','10','Dual Leadframe','SOIC 150mil Body','FormingGas','8ld','FALSE','','H2N2 Forming gas','Forming gas - For PCC wire','Forming gas','0.00585','','','','','','','','','','','','0.710400000','0.166700000');
		loadBom('0.8mil_Cu','Variant','20','Dual Leadframe','SOIC 150mil Body','Wire','','FALSE','Ft','','Cu Wire','','0.01','1.012','','','','0.0067','','','','','','','','');
		loadBom('0.8mil_PCC','Variant','20','Dual Leadframe','SOIC 150mil Body','Wire','','FALSE','Ft','','PCC Wire','','0.02','1.012','','','','0.0183','','','','','','','','');
		loadBom('0.8mil_Ag','Variant','20','Dual Leadframe','SOIC 150mil Body','Wire','','FALSE','Ft','','Ag Wire','','2.8','1.012','','','','','','','','0.38377672710822','','','','');
		loadBom('0.8mil_Au','Variant','20','Dual Leadframe','SOIC 150mil Body','AuWire','','FALSE','Ft','0.8MIL - HP WIRE','Au Wire','101308898','','1.012','','','2.8','','','','','0.0614','','','','');
		loadBom('0.9mil_Cu','Variant','30','Dual Leadframe','SOIC 150mil Body','Wire','','FALSE','Ft','','Cu Wire','','0.01','1.012','','','','0.0067','','','','','','','','');
		loadBom('0.9mil_PCC','Variant','30','Dual Leadframe','SOIC 150mil Body','Wire','','FALSE','Ft','','PCC Wire','','0.02','1.012','','','','0.0183','','','','','','','','');
		loadBom('0.9mil_Ag','Variant','30','Dual Leadframe','SOIC 150mil Body','Wire','','FALSE','Ft','','Ag Wire','','2.8','1.012','','','','','','','','0.38377672710822','','','','');
		loadBom('0.9mil_Au','Variant','30','Dual Leadframe','SOIC 150mil Body','AuWire','','FALSE','Ft','0.9 MIL HP WIRE','Au Wire','101320435','','1.012','','','2.8','','','','','0.0777','','','','');
		loadBom('1.0mil_Au','Variant','40','Dual Leadframe','SOIC 150mil Body','AuWire','','FALSE','Ft','1.0 MIL NORMAL LOOP','Au Wire','101006525','','1.012','','','2.8','','','','','0.095944181777055','','','','');
		loadBom('1.0mil_Cu','Variant','40','Dual Leadframe','SOIC 150mil Body','Wire','','FALSE','Ft','','Cu Wire','','0.01','1.012','','','','0.0067','','','','','','','','');
		loadBom('1.0mil_PCC','Variant','40','Dual Leadframe','SOIC 150mil Body','Wire','','FALSE','Ft','','PCC Wire','','0.0183','1.012','','','','0.0183','','','','','','','','');
		loadBom('1.0mil_Ag','Variant','40','Dual Leadframe','SOIC 150mil Body','Wire','','FALSE','Ft','','Ag Wire','','2.8','1.012','','','','','','','','0.38377672710822','','','','');
		loadBom('1.2mil_Au','Variant','50','Dual Leadframe','SOIC 150mil Body','AuWire','','FALSE','Ft','1.2 MIL NORMAL LOOP','Au Wire','101221809','','1.012','','','2.8','','','','','0.138159621758959','','','','');
		loadBom('1.2mil_Cu','Variant','50','Dual Leadframe','SOIC 150mil Body','Wire','','FALSE','Ft','','Cu Wire','','0.01','1.012','','','','0.0067','','','','','','','','');
		loadBom('1.2mil_PCC','Variant','50','Dual Leadframe','SOIC 150mil Body','Wire','','FALSE','Ft','','PCC Wire','','0.02','1.012','','','','0.0183','','','','','','','','');
		loadBom('1.2mil_Ag','Variant','50','Dual Leadframe','SOIC 150mil Body','Wire','','FALSE','Ft','','Ag Wire','','2.8','1.012','','','','','','','','0.38377672710822','','','','');
		loadBom('1.3mil_Au','Variant','60','Dual Leadframe','SOIC 150mil Body','AuWire','','FALSE','Ft','','Au Wire','','','1.012','','','2.8','','','','','0.162145667203223','','','','');
		loadBom('1.3mil_Cu','Variant','60','Dual Leadframe','SOIC 150mil Body','Wire','','FALSE','Ft','','Cu Wire','','0.01','1.012','','','','0.0067','','','','','','','','');
		loadBom('1.3mil_PCC','Variant','60','Dual Leadframe','SOIC 150mil Body','Wire','','FALSE','Ft','','PCC Wire','','0.02','1.012','','','','0.02134','','','','','','','','');
		loadBom('1.3mil_Ag','Variant','60','Dual Leadframe','SOIC 150mil Body','Wire','','FALSE','Ft','','Ag Wire','','2.8','1.012','','','','','','','','0.38377672710822','','','','');
		loadBom('1.5mil_Au','Variant','70','Dual Leadframe','SOIC 150mil Body','AuWire','','FALSE','Ft','','Au Wire','','','1.012','','','2.8','','','','','0.215874408998374','','','','');
		loadBom('1.5mil_Cu','Variant','70','Dual Leadframe','SOIC 150mil Body','Wire','','FALSE','Ft','','Cu Wire','','0.01','1.012','','','','0.0067','','','','','','','','');
		loadBom('1.5mil_PCC','Variant','70','Dual Leadframe','SOIC 150mil Body','Wire','','FALSE','Ft','','PCC Wire','','0.02','1.012','','','','0.02134','','','','','','','','');
		loadBom('1.5mil_Ag','Variant','70','Dual Leadframe','SOIC 150mil Body','Wire','','FALSE','Ft','','Ag Wire','','2.8','1.012','','','','','','','','0.38377672710822','','','','');
		loadBom('2.0mil_Au','Variant','80','Dual Leadframe','SOIC 150mil Body','AuWire','','FALSE','Ft','','Au Wire','','','1.012','','','2.8','','','','','0.38377672710822','','','','');
		loadBom('2.0mil_Cu','Variant','80','Dual Leadframe','SOIC 150mil Body','Wire','','FALSE','Ft','','Cu Wire','','0.01','1.012','','','','0.0067','','','','','','','','');
		loadBom('2.0mil_PCC','Variant','80','Dual Leadframe','SOIC 150mil Body','Wire','','FALSE','Ft','','PCC Wire','','0.03','1.012','','','','0.02743','','','','','','','','');
		loadBom('2.0mil_Ag','Variant','80','Dual Leadframe','SOIC 150mil Body','Wire','','FALSE','Ft','','Ag Wire','','2.8','1.012','','','','','','','','0.38377672710822','','','','');
		loadBom('Hi_Pb_Solder','Variant','','Dual Leadframe','SOIC 150mil Body','Standard','8ld','FALSE','Ft','SOLDER PREFORM WIRE TYPE, PB95/SN5, 30MI','Hi_Pb_Solder','101300679','','1.012','','','','1.07','','0.008','','','','','','');
		loadBom('CRM-ZA239A','Variant','','Dual Leadframe','SOIC 150mil Body','Standard','','FALSE','','','','','','1.15','','','','3.39','','1.215','','','','','','');
		loadBom('CRM-ZA236','Variant','','Dual Leadframe','','Standard','','FALSE','','','','','','1.15','','','','2.39','','1.215','','','','','','');
		loadBom('a26K0000000lNYc','Variant','','','','Standard','','FALSE','','','','','','','','','','','','','','','','','','');
		
		//public void loadBom(String name, String typeVal,String seq, String pg,string pf, String catVal, String leadCount, String hasVariants, string uom, String decription, String parent, String sid, String costUnit, String usageScrap, String baseQty, String column, String mfgCost, String purchasePrice, String row, String stdUsage, String stripSublot, String troyOz, String unitsStrip, String usageRate, String index, String timePerWire)
		/*
		loadBom('PACKING_MATERIALS','Variant','10','Dual Leadframe','SOIC 150mil Body','Standard','8ld','FALSE','KPC/KUNIT','TBD','PACKING MATERIALS','TBD','','1.012','','','','','','','','','','','','');	
		loadBom('BOX','Variant','10','Dual Leadframe','SOIC 150mil Body','Standard','8ld','FALSE','PC/KUNIT','BOX, 4K (L-22, W-10 3/4, H-5 1/8)','BOX','201298475','','1.012','','','','0.57977','','0.0687285223367698','','','','','','');
		loadBom('TUBE','Variant','10','Dual Leadframe','SOIC 150mil Body','Standard','8ld','FALSE','PC/KUNIT','TUBE, 150 MILS SOIC ANTISTATIC AAPI STD','TUBE','201298447','','1.012','','','','0.0305','','10.3092783505155','','','','','','');
		loadBom('Tube Plug','Variant','10','Dual Leadframe','SOIC 150mil Body','Standard','8ld','FALSE','KPC/KUNIT','END PLUG 150MIL SOIC STD','Tube Plug','201298512','','1.012','','','','1.85','','0.0206185567010309','','','','','','');	
		loadBom('BAG','Variant','','Dual Leadframe','SOIC 150mil Body','Standard','8ld','FALSE','PC/KUNIT','BAG STATIC SHIELD 12INCHX25INCH','BAG','201298470','','1.012','','','','0.173','','0.13745704467354','','','','','','');
		*/
		loadBom('PACKING_MATERIALS','Variant','10','Dual Leadframe','SOIC 150mil Body','Standard','8ld','FALSE','KPC/KUNIT','TBD','PACKING MATERIALS','TBD','','1.012','','','','','','','','','','','','');	
		loadBom('BOX','Variant','10','Dual Leadframe','SOIC 150mil Body','Standard','8ld','FALSE','PC/KUNIT','BOX, 4K (L-22, W-10 3/4, H-5 1/8)','BOX','201298475','','1.012','','','','','','','','','','','','');
		loadBom('TUBE','Variant','10','Dual Leadframe','SOIC 150mil Body','Standard','8ld','FALSE','PC/KUNIT','TUBE, 150 MILS SOIC ANTISTATIC AAPI STD','TUBE','201298447','','1.012','','','','','','','','','','','','');
		loadBom('Tube Plug','Variant','10','Dual Leadframe','SOIC 150mil Body','Standard','8ld','FALSE','KPC/KUNIT','END PLUG 150MIL SOIC STD','Tube Plug','201298512','','1.012','','','','','','','','','','','','');	
		loadBom('BAG','Variant','','Dual Leadframe','SOIC 150mil Body','Standard','8ld','FALSE','PC/KUNIT','BAG STATIC SHIELD 12INCHX25INCH','BAG','201298470','','1.012','','','','','','','','','','','','');

		//---Save list 
		insert bomList;
		bomVariantMap = new Map<String, FCM_BOM__c>();
		for(FCM_BOM__c row : bomList) bomVariantMap.put(row.name, row);
	}
	
	private void loadProcs()
	{
		loadProc('Wafer Backgrind','','Item','Standard','TRUE','Dual Leadframe','','','','','','','20','','','');
		loadProc('Wafer Inspection','','Item','Standard','TRUE','Dual Leadframe','','','','','','','30','','','');
		loadProc('Wafer Mount','','Item','Standard','TRUE','Dual Leadframe','','','','','','','40','','','');
		loadProc('Film die attach wafer mount','','Item','Standard','TRUE','Dual Leadframe','','','','','','','50','','','');
		loadProc('Bar Code','','Item','Standard','TRUE','Dual Leadframe','','','','','','','60','','','');
		loadProc('Wafer Saw','','Item','Standard','TRUE','Dual Leadframe','','','','','','','70','','','');
		loadProc('Wafer Stealth dicing','','Item','Standard','TRUE','Dual Leadframe','','','','','','','80','','','');
		loadProc('Wafer scribe','','Item','Standard','TRUE','Dual Leadframe','','','','','','','90','','','');
		loadProc('Epoxy Die Attach','','Item','Standard','TRUE','Dual Leadframe','','','','','5538.461538461538461538','','100','','','');
		loadProc('Film Die Attach','','Item','Standard','TRUE','Dual Leadframe','','','','','10151.22505547926471293','','110','','','');
		loadProc('Solder Die Attach','','Item','Standard','TRUE','Dual Leadframe','','','','','','','120','','','');
		loadProc('Epoxy D/A Cure','','Item','Standard','TRUE','Dual Leadframe','','','','','','','130','','','');
		loadProc('Film D/A Cure','','Item','Standard','TRUE','Dual Leadframe','','','','','','','140','','','');
		loadProc('Sintered D/A Cure','','Item','Standard','TRUE','Dual Leadframe','','','','','','','150','','','');
		loadProc('Batch plasma before die attach','','Item','Standard','TRUE','Dual Leadframe','','','','','','','160','','','');
		loadProc('Batch plasma before mold','','Item','Standard','TRUE','Dual Leadframe','','','','','','','170','','','');
		loadProc('Direct Plasma before wirebond','','Item','Standard','TRUE','Dual Leadframe','','','','','','','180','','','');
		loadProc('Die coat','','Item','Standard','TRUE','Dual Leadframe','','','','','','','190','','','');
		loadProc('Die coat cure','','Item','Standard','TRUE','Dual Leadframe','','','','','','','200','','','');
		loadProc('Au Wire bond','','Item','Wirebond','TRUE','Dual Leadframe','','','','','','','210','','','');
		loadProc('Cu Wire bond','','Item','Wirebond','TRUE','Dual Leadframe','','','','','','','220','','','');
		loadProc('PCC Wire bond','','Item','Wirebond','TRUE','Dual Leadframe','','','','','','','230','','','');
		loadProc('Ag Wire bond','','Item','Standard','TRUE','Dual Leadframe','','','','','','','240','','','');
		loadProc('Mold','','Item','Standard','TRUE','Dual Leadframe','','','','','','','250','','','');
		loadProc('Chemical deflash','','Item','Standard','TRUE','Dual Leadframe','','','','','','','260','','','');
		loadProc('Delash trim','','Item','Standard','TRUE','Dual Leadframe','','','','','','','270','','','');
		loadProc('Post Mold Cure','','Item','Standard','TRUE','Dual Leadframe','','','','','','','280','','','');
		loadProc('Lead finish (Plate)','','Item','Standard','TRUE','Dual Leadframe','','','','','','','290','','','');
		loadProc('Post Plate Bake','','Item','Standard','TRUE','Dual Leadframe','','','','','','','300','','','');
		loadProc('Bottom Laser Mark','','Item','Standard','TRUE','Dual Leadframe','','','','','','','310','','','');
		loadProc('Top Laser Mark','','Item','Standard','TRUE','Dual Leadframe','','','','','','','320','','','');
		loadProc('Lead length cut','','Item','Standard','TRUE','Dual Leadframe','','','','','','','330','','','');
		loadProc('Deflash Trim Form Singulate','','Item','Standard','TRUE','Dual Leadframe','','','','','','','340','','','');
		loadProc('Trim Form Singulate','','Item','Standard','TRUE','Dual Leadframe','','','','','','','350','','','');
		loadProc('Form Singulate','','Item','Standard','TRUE','Dual Leadframe','','','','','','','360','','','');
		loadProc('Pack','','Item','Standard','TRUE','Dual Leadframe','','','','','','','370','','','');


		//---Save current list and load into map (For parent matching)
		insert procList;
		procMap = new Map<String, FCM_Process__c>();
		for(FCM_Process__c row : procList) procMap.put(row.name, row);
		procList = new List<FCM_Process__c>();
		
		//To Do: Chechk machine UPH in Excel Sheet Dual LeadframePrice, tab Assy Process Parameters 
		//To Do: Check Footprint per square feet in Excel Sheet Dual LeadframePrice, tab Assy Process Parameters
		loadProc('Wafer Backgrind','Wafer Backgrind','Variant','Standard','FALSE','Dual Leadframe','200','50','','5','350300','','10','SOIC 150mil Body','BG','8ld');
		loadProc('Wafer Inspection','Wafer Inspection','Variant','Standard','FALSE','Dual Leadframe','200','50','','5','15570','','10','SOIC 150mil Body','Wafer Inspection','8ld');
		loadProc('Wafer Mount','Wafer Mount','Variant','Standard','FALSE','Dual Leadframe','250','95.4','','1','280240','','10','SOIC 150mil Body','TAKATORI','8ld');
		loadProc('Film die attach wafer mount','Film die attach wafer mount','Variant','Standard','FALSE','Dual Leadframe','250','95.4','','1','280240','','10','SOIC 150mil Body','Film die attach','8ld');
		loadProc('Bar Code','Bar Code','Variant','Standard','FALSE','Dual Leadframe','0','20','','1','100000','','10','SOIC 150mil Body','OPR','');
		loadProc('Wafer Saw','Wafer Saw','Variant','Standard','FALSE','Dual Leadframe','235','50.8','','5','18367','','10','SOIC 150mil Body','DISCO 651','8ld');
		loadProc('Wafer Stealth dicing','Wafer Stealth dicing','Variant','Standard','FALSE','Dual Leadframe','975','20','','9','11720','','10','SOIC 150mil Body','Stealth dicing','8ld');
		loadProc('Wafer scribe','Wafer scribe','Variant','Standard','FALSE','Dual Leadframe','975','20','','9','11720','','10','SOIC 150mil Body','Wafer Scribe','8ld');		
		loadProc('Epoxy Die Attach','Epoxy Die Attach','Variant','Standard','FALSE','Dual Leadframe','250','48.44','','5','','','10','SOIC 150mil Body','ESEC2100XP','8ld');
		loadProc('Film Die Attach','Film Die Attach','Variant','Standard','FALSE','Dual Leadframe','250','48.44','','5','','','10','SOIC 150mil Body','Film die attach','8ld');
		loadProc('Solder Die Attach','Solder Die Attach','Variant','Standard','FALSE','Dual Leadframe','320','43','','5','1514','','10','SOIC 150mil Body','ESEC2009 SSI','8ld');
		loadProc('Epoxy D/A Cure','Epoxy D/A Cure','Variant','Standard','FALSE','Dual Leadframe','37.5','30','','5','235636','','10','SOIC 150mil Body','Blue M','8ld');
		loadProc('Film D/A Cure','Film D/A Cure','Variant','Standard','FALSE','Dual Leadframe','37','30','','7','125000','','10','SOIC 150mil Body','Blue M','8ld');
		loadProc('Sintered D/A Cure','Sintered D/A Cure','Variant','Standard','FALSE','Dual Leadframe','37','30','','7','125000','','10','SOIC 150mil Body','Blue M','8ld');
		loadProc('Batch plasma before die attach','Batch plasma before die attach','Variant','Standard','FALSE','Dual Leadframe','100','50','','1','125000','','10','SOIC 150mil Body','Plasma (Batch)','8ld');
		loadProc('Batch plasma before mold','Batch plasma before mold','Variant','Standard','FALSE','Dual Leadframe','100','50','','1','125000','','10','SOIC 150mil Body','Plasma (Batch)','8ld');
		loadProc('Direct Plasma before wirebond','Direct Plasma before wirebond','Variant','Standard','FALSE','Dual Leadframe','302.2','50','','3','125000','','10','SOIC 150mil Body','VISION','8ld');
		loadProc('Die coat','Die coat','Variant','Standard','FALSE','Dual Leadframe','250','48.44','','5','10151.2250554793','','10','SOIC 150mil Body','ESEC2100XP','8ld');
		loadProc('Die coat cure','Die coat cure','Variant','Standard','FALSE','Dual Leadframe','37','30','','7','10000','','10','SOIC 150mil Body','Blue M','8ld');
		loadProc('Au Wire bond','Au Wire bond','Variant','Wirebond','FALSE','Dual Leadframe','80','30','0.7104','30','','0.1667','10','SOIC 150mil Body','Express GOCU','8ld');
		loadProc('Cu Wire bond','Cu Wire bond','Variant','Wirebond','FALSE','Dual Leadframe','80','30','0.7104','20','','0.1667','10','SOIC 150mil Body','Express GOCU','8ld');
		loadProc('PCC Wire bond','PCC Wire bond','Variant','Wirebond','FALSE','Dual Leadframe','80','30','0.7104','20','','0.1667','10','SOIC 150mil Body','Express GOCU','8ld');
		loadProc('Ag Wire bond','Ag Wire bond','Variant','Wirebond','FALSE','Dual Leadframe','80','30','0.7104','30','','0.1667','10','SOIC 150mil Body','Express GOCU','8ld');
		loadProc('Mold','Mold','Variant','Standard','FALSE','Dual Leadframe','850','260','','2','111600','','10','SOIC 150mil Body','ASM','8ld');
		loadProc('Chemical deflash','Chemical deflash','Variant','Standard','FALSE','Dual Leadframe','1200','1200','','2','115000','','10','SOIC 150mil Body','Chemical deflash','8ld');
		loadProc('Delash trim','Delash trim','Variant','Standard','FALSE','Dual Leadframe','280','103','','3','32142','','10','','ASM','');
		loadProc('Post Mold Cure','Post Mold Cure','Variant','Standard','FALSE','Dual Leadframe','37','30','','7','257142','','10','SOIC 150mil Body','Blue M','8ld');
		loadProc('Lead finish (Plate)','Lead finish (Plate)','Variant','Standard','FALSE','Dual Leadframe','1200','1200','','3','450000','','10','SOIC 150mil Body','Lead Finish','8ld');
		loadProc('Post Plate Bake','Post Plate Bake','Variant','Standard','FALSE','Dual Leadframe','37','30','','7','818181','','10','SOIC 150mil Body','Blue M','8ld');
		loadProc('Bottom Laser Mark','Bottom Laser Mark','Variant','Standard','FALSE','Dual Leadframe','310','129','','3','261000','','10','','EO TECH','');
		loadProc('Top Laser Mark','Top Laser Mark','Variant','Standard','FALSE','Dual Leadframe','310','129','','3','261000','','10','SOIC 150mil Body','EO TECH','8ld');
		loadProc('Lead length cut','Lead length cut','Variant','Standard','FALSE','Dual Leadframe','250','103','','2','324000','','10','SOIC 150mil Body','ASM','');
		loadProc('Deflash Trim Form Singulate','Deflash Trim Form Singulate','Variant','Standard','FALSE','Dual Leadframe','280','103','','3','324000','','10','','ASM','');
		loadProc('Trim Form Singulate','Trim Form Singulate','Variant','Standard','FALSE','Dual Leadframe','280','103','','3','324000','','10','SOIC 150mil Body','ASM','8ld');
		loadProc('Form Singulate','Form Singulate','Variant','Standard','FALSE','Dual Leadframe','280','103','','3','324000','','10','SOIC 150mil Body','ASM','');
		loadProc('Pack','Pack','Variant','Standard','FALSE','Dual Leadframe','0','20','','1','138461','','10','SOIC 150mil Body','OPR','');

		insert procList;
		procVariantMap = new Map<String, FCM_Process__c>();
		for(FCM_Process__c row : procList) procMap.put(row.name, row);
	}
	
	private void loadMatches()
	{
		loadMatch('0.8mil_PCC','','WireTextValue','Contains','Wire_Diameter__c','0.8','FALSE');
		loadMatch('','Die coat','ItemBoolean','Equals','Die_Coat__c','','TRUE');
		loadMatch('Lead Frame - Rough Adder','','ItemTextValue','Equals','Standard_Rough_Leadframe__c','Rough','FALSE');
		loadMatch('1.5mil_Au','','WireTextValue','Contains','Wire_Diameter__c','1.5','FALSE');
		loadMatch('Lead Frame - Rough Adder','','ItemTextValue','Equals','Leadframe_Finish__c','DR-Ag (Double Ring Silver)','FALSE');
		loadMatch('1.2mil_PCC','','WireTextValue','Contains','Wire_Diameter__c','1.2','FALSE');
		loadMatch('','Bar Code','AlwaysItem','','','','FALSE');
		loadMatch('Lead Frame - Rough Adder','','ItemTextValue','Equals','Standard_Rough_Leadframe__c','Rough','FALSE');
		loadMatch('PACKING MATERIALS','','AlwaysItem','','','','FALSE');
		loadMatch('1.3mil_Au','','WireTextValue','Contains','Wire_Diameter__c','1.3','FALSE');
		loadMatch('1.2mil_Cu','','WireTextValue','Contains','Wire_Diameter__c','1.2','FALSE');
		loadMatch('0.8mil_Cu','','WireTextValue','Contains','Wire_Diameter__c','0.8','FALSE');
		loadMatch('1.3mil_PCC','','WireTextValue','Contains','Wire_Diameter__c','1.3','FALSE');
		loadMatch('2.0mil_PCC','','WireTextValue','Contains','Wire_Diameter__c','2.0','FALSE');
		loadMatch('','Sintered D/A Cure','DieTextValue','Contains','Die_Attach__c','Sintered','FALSE');
		loadMatch('Lead Frame- Etch adder','','ItemTextValue','Equals','Leadframe_Finish__c','DR-Ag (Double Ring Silver)','FALSE');
		loadMatch('Lead Frame - Rough Adder','','ItemTextValue','Equals','Leadframe_Finish__c','S-Ag (Spot Silver)','FALSE');
		loadMatch('BOX','','AlwaysItem','','','','FALSE');
		loadMatch('Cu Wire','','WireTextValue','Contains','Wire_Material__c','Cu','FALSE');
		loadMatch('','Film D/A Cure','DieTextValue','Contains','Die_Attach__c','Film','FALSE');
		loadMatch('1.5mil_PCC','','WireTextValue','Contains','Wire_Diameter__c','1.5','FALSE');
		loadMatch('Hi_Pb_Solder','','DieTextValue','Contains','Die_Attach__c','Hi Pb Solder','FALSE');
		loadMatch('R-Ag (Ring Silver) Lead Frame','','ItemTextValue','Contains','Leadframe_Finish__c','R-Ag','FALSE');
		loadMatch('No_Pb_Solder','','DieTextValue','Contains','Die_Attach__c','No Pb Solder','FALSE');
		loadMatch('','Wafer Saw','DieTextValue','Contains','Wafer_Singulation__c','Saw','FALSE');
		loadMatch('1.5mil_Cu','','WireTextValue','Contains','Wire_Diameter__c','1.5','FALSE');
		loadMatch('0.9mil_PCC','','WireTextValue','Contains','Wire_Diameter__c','0.9','FALSE');
		loadMatch('Lead Frame - Rough Adder','','ItemTextValue','Equals','Standard_Rough_Leadframe__c','Rough','FALSE');
		loadMatch('TL-PPF (Pre-Plated Frame) Lead Frame','','ItemTextValue','Contains','Leadframe_Finish__c','TL-PPF','FALSE');
		loadMatch('Ag Wire','','WireTextValue','Contains','Wire_Material__c','Ag','FALSE');
		loadMatch('1.3mil_Ag','','WireTextValue','Contains','Wire_Diameter__c','1.3','FALSE');
		loadMatch('','Film Die Attach','DieTextValue','Contains','Die_Attach__c','Film','FALSE');
		loadMatch('','Solder Die Attach','DieTextValue','Contains','Die_Attach__c','Solder','FALSE');
		loadMatch('','Post Plate Bake','ItemTextValue','NotContains','Leadframe_Finish__c','PPF','FALSE');
		loadMatch('Forming gas - For Cu wire','','WireTextValue','Contains','Wire_Material__c','Cu','FALSE');
		loadMatch('0.8mil_Au','','WireTextValue','Contains','Wire_Diameter__c','0.8','FALSE');
		loadMatch('0.9mil_Ag','','WireTextValue','Contains','Wire_Diameter__c','0.9','FALSE');
		loadMatch('S-Ag (Spot Silver) Lead Frame','','ItemTextValue','Contains','Leadframe_Finish__c','S-Ag','FALSE');
		loadMatch('Lead Frame - Rough Adder','','ItemTextValue','Equals','Standard_Rough_Leadframe__c','Rough','FALSE');
		loadMatch('0.9mil_Cu','','WireTextValue','Contains','Wire_Diameter__c','0.9','FALSE');
		loadMatch('','Top Laser Mark','AlwaysItem','','','','FALSE');
		loadMatch('','Wafer Inspection','ItemBoolean','Equals','Wafer_Inspection__c','','TRUE');
		loadMatch('TUBE','','AlwaysItem','','','','FALSE');
		loadMatch('0.6mil_Cu','','WireTextValue','Contains','Wire_Diameter__c','0.6','FALSE');
		loadMatch('1.5mil_Ag','','WireTextValue','Contains','Wire_Diameter__c','1.5','FALSE');
		loadMatch('Non_Conductive_Epoxy','','DieTextValue','Contains','Die_Attach__c','Non Conductive Epoxy','FALSE');
		loadMatch('Au Wire','','WireTextValue','Contains','Wire_Material__c','Au','FALSE');
		loadMatch('1.2mil_Ag','','WireTextValue','Contains','Wire_Diameter__c','1.2','FALSE');
		loadMatch('','Wafer Mount','AlwaysItem','','','','FALSE');
		loadMatch('','Cu Wire bond','WireTextValue','Contains','Wire_Material__c','Cu','FALSE');
		loadMatch('1.2mil_Au','','WireTextValue','Contains','Wire_Diameter__c','1.2','FALSE');
		loadMatch('Lead Frame- Etch adder','','ItemTextValue','Equals','Leadframe_Finish__c','TL-PPF (Pre-Plated Frame)','FALSE');
		loadMatch('2.0mil_Au','','WireTextValue','Contains','Wire_Diameter__c','2.0','FALSE');
		loadMatch('','Chemical deflash','ItemTextValue','NotContains','Leadframe_Finish__c','PPF','FALSE');
		loadMatch('0.9mil_Au','','WireTextValue','Contains','Wire_Diameter__c','0.9','FALSE');
		loadMatch('','Mold','AlwaysItem','','','','FALSE');
		//Lalit SF-85.
		loadMatch('Forming gas - For PCC wire','','WireTextValue','Contains','Wire_Material__c','AuPCC','FALSE');
		loadMatch('Lead Frame- Etch adder','','ItemTextValue','Equals','Stamped_Etched_Leadframe__c','Etched','FALSE');
		loadMatch('High_Thermal_Performance_Epoxy','','DieTextValue','Contains','Die_Attach__c','High Thermal Performance','FALSE');
		loadMatch('2.0mil_Ag','','WireTextValue','Contains','Wire_Diameter__c','2.0','FALSE');
		loadMatch('1.0mil_Au','','WireTextValue','Contains','Wire_Diameter__c','1.0','FALSE');
		loadMatch('Conductive_Film','','DieTextValue','Contains','Die_Attach__c','Conductive Film','FALSE');
		loadMatch('','Film die attach wafer mount','DieTextValue','Contains','Die_Attach__c','Film','FALSE');
		loadMatch('','Trim Form Singulate','AlwaysItem','','','','FALSE');
		loadMatch('','Batch plasma before die attach','ItemBoolean','Equals','Plasma_Before_Die_Attach__c','','TRUE');
		loadMatch('','Au Wire bond','WireTextValue','Contains','Wire_Material__c','Au','FALSE');
		loadMatch('','Wafer Stealth dicing','DieTextValue','Contains','Wafer_Singulation__c','Stealth (Laser)','FALSE');
		loadMatch('Lead Frame- Etch adder','','ItemTextValue','Equals','Stamped_Etched_Leadframe__c','Etched','FALSE');
		loadMatch('Lead Frame- Etch adder','','ItemTextValue','Equals','Stamped_Etched_Leadframe__c','Etched','FALSE');
		loadMatch('DR-Ag (Double Ring Silver) Lead Frame','','ItemTextValue','Contains','Leadframe_Finish__c','DR-Ag','FALSE');
		loadMatch('Tube Plug','','AlwaysItem','','','','FALSE');
		loadMatch('','Die coat cure','ItemBoolean','Equals','Die_Coat__c','','TRUE');
		loadMatch('','Lead finish (Plate)','ItemTextValue','NotContains','Leadframe_Finish__c','PPF','FALSE');
		loadMatch('','Post Mold Cure','AlwaysItem','','','','FALSE');
		loadMatch('0.6mil_Ag','','WireTextValue','Contains','Wire_Diameter__c','0.6','FALSE');
		loadMatch('Lead Frame- Etch adder','','ItemTextValue','Equals','Leadframe_Finish__c','R-Ag (Ring Silver)','FALSE');
		loadMatch('PCC Wire','','WireTextValue','Contains','Wire_Material__c','PCC','FALSE');
		loadMatch('','PCC Wire bond','WireTextValue','Contains','Wire_Material__c','PCC','FALSE');
		loadMatch('','Direct Plasma before wirebond','ItemBoolean','Equals','Plasma_Before_Wire_Bond__c','','TRUE');
		loadMatch('Mold Compound','','AlwaysItem','','','','FALSE');
		loadMatch('0.7mil_PCC','','WireTextValue','Contains','Wire_Diameter__c','0.7','FALSE');
		loadMatch('','Ag Wire bond','WireTextValue','Contains','Wire_Material__c','Ag','FALSE');
		loadMatch('','Pack','AlwaysItem','','','','FALSE');
		loadMatch('Lead Frame- Etch adder','','ItemTextValue','Equals','Leadframe_Finish__c','S-Ag (Spot Silver)','FALSE');
		loadMatch('2.0mil_Cu','','WireTextValue','Contains','Wire_Diameter__c','2.0','FALSE');
		loadMatch('Lead Frame- Etch adder','','ItemTextValue','Equals','Stamped_Etched_Leadframe__c','Etched','FALSE');
		loadMatch('Non_Conductive_Film','','DieTextValue','Contains','Die_Attach__c','Non Conductive Film','FALSE');
		loadMatch('','Batch plasma before mold','ItemBoolean','Equals','Plasma_Before_Mold__c','','TRUE');
		loadMatch('Sintered','','DieTextValue','Contains','Die_Attach__c','Sintered','FALSE');
		loadMatch('','Wafer scribe','DieTextValue','Contains','Wafer_Singulation__c','Scribe','FALSE');
		loadMatch('','Epoxy D/A Cure','DieTextValue','Contains','Die_Attach__c','Epoxy','FALSE');
		loadMatch('Lead Frame - Rough Adder','','ItemTextValue','Equals','Leadframe_Finish__c','R-Ag (Ring Silver)','FALSE');
		loadMatch('Silver Filled Epoxy','','DieTextValue','Contains','Die_Attach__c','Silver Filled Epoxy','FALSE');
		loadMatch('','Wafer Backgrind','DieBoolean','Equals','Wafer_Backgrind__c','','TRUE');
		loadMatch('1.0mil_Cu','','WireTextValue','Contains','Wire_Diameter__c','1.0','FALSE');
		loadMatch('0.6mil_Au','','WireTextValue','Contains','Wire_Diameter__c','0.6','FALSE');
		loadMatch('1.0mil_PCC','','WireTextValue','Contains','Wire_Diameter__c','1.0','FALSE');
		loadMatch('','Epoxy Die Attach','DieTextValue','Contains','Die_Attach__c','Epoxy','FALSE');
		loadMatch('1.3mil_Cu','','WireTextValue','Contains','Wire_Diameter__c','1.3','FALSE');
		loadMatch('0.8mil_Ag','','WireTextValue','Contains','Wire_Diameter__c','0.8','FALSE');
		loadMatch('Lead Frame - Rough Adder','','ItemTextValue','Equals','Leadframe_Finish__c','TL-PPF (Pre-Plated Frame)','FALSE');
		loadMatch('Die Coat','','ItemBoolean','Equals','Die_Coat__c','','TRUE');
		loadMatch('1.0mil_Ag','','WireTextValue','Contains','Wire_Diameter__c','1.0','FALSE');
		loadMatch('','Lead length cut','AlwaysItem','','','','FALSE');

		insert matchList;
	}
}