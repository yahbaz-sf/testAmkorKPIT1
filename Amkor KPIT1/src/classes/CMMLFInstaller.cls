/*************************************************************************
*
* PURPOSE: Dual Installer
*
* CLASS: CMFCMInstaller
* CREATED: 5/01/2013 Ethos Solutions - www.ethos.com 
* AUTHOR: Steve Simpson
***************************************************************************/ 
global class CMMLFInstaller extends CMFCMInstaller
{
	global static void cleanAndInstall() 
	{
		clean();
		CMMLFInstaller installer = new CMMLFInstaller();
		//installer.cleanAll();

		installer.installFCM(); 
	}
	
	global static void install() 
	{
		CMMLFInstaller installer = new CMMLFInstaller();
		installer.installFCM();
	}
	
	global static void clean() 
	{
		CMMLFInstaller installer = new CMMLFInstaller();
		installer.clean('MLF');	

		
	}
	public override void loadPfMap()
	{
		List<Package_Family__c> pfList = [Select id, name, Specific_RFQ_Item_Object__c, Product_Group__c from Package_Family__c where Product_Group__c = :pgId];
		for(Package_Family__c row : pfList) pfMap.put(row.name, row);
	}
	public override void installFCM()
	{
		pgName = 'MLF';
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
	
	private void loadBoms()
	{
		//public void loadBom(String name, String typeVal,String seq, String pg,string pf, String catVal, String leadCount, String hasVariants, string uom, String decription, String parent, String sid, String costUnit, String usageScrap, String baseQty, String column, String mfgCost, String purchasePrice, String row, String stdUsage, String stripSublot, String troyOz, String unitsStrip, String usageRate, String index, String timePerWire)
		
		//---SHARED
		loadBom('Leadframe','Item','100','','','','','TRUE','Units','','','','','','','','','','','','','','Leadframe','1.05','','');
		loadBom('Epoxy','Item','200','','','','','TRUE','CC','','','','','','','','','','','','','','ODM','1.05','','');
		loadBom('Mold Compound','Item','500','','','','','TRUE','KGs','','','','','','','','','','','','','','ODM','1.05','','');
		loadBom('Tray','Item','600','','','','','TRUE','EA','','','','','','','','','','','','','','ODM','1.05','','');
		loadBom('PCC Wire','Item','300','','','','','TRUE','Ft','','','','','','','','','','','','','','Wire','1.05','','');
		loadBom('Au Wire','Item','400','','','','','TRUE','Ft','','','','','','','','','','','','','','Wire','1.05','','');
		
		//---PUNCH
		loadBom('Forming Gas','Item','700','','','','','TRUE','L/K unit','PCC wire','','','','','','','','0.017','','','','','ODM','1.05','','');
		
		//---SAW
		loadBom('Mold Flash Tape','Item','','','','','','TRUE','Ea','','','','','','','','','0','','','','','ODM','1.050','','');
		loadBom('Saw Tape','Item','','','','','','TRUE','Ea','','','','','','','','','139','','','','','ODM','1.050','','');
		loadBom('Saw Blade','Item','','','','','','TRUE','Ea','','','','','','','','','','','','','','ODM','1.050','','');
		
		//---Save current list and load into map (For parent matching) 
		insert bomList;
		bomMap = new Map<String, FCM_BOM__c>();
		for(FCM_BOM__c row : bomList) bomMap.put(row.name, row);
		bomList = new List<FCM_BOM__c>();		
			
		//---PUNCH VARIANTS
		loadBom('Leadframe','Variant','','MLF','Punch Single Row MLF','','','FALSE','','','Leadframe','','','','','','','','','1021.43','','','','','','');
		loadBom('Epoxy','Variant','','MLF','Punch Single Row MLF','','','FALSE','CC','CRM 1085A','Epoxy','','','','','','','3.96','','','','','','','','');
		//loadBom('Tray','Variant','','','Punch Single Row MLF','','','FALSE','EA','','Tray','','','','','','','','','0.99','','','','1.050','','');
		//real std usage should be 0.00448276
		loadBom('Tray','Variant','','MLF','Punch Single Row MLF','','','FALSE','EA','','Tray','','','','','','','1.4875','','0.00448276','','','','','','');
	

		loadBom('PCC 0.6 p','Variant','210','MLF','Punch Single Row MLF','','','FALSE','','','PCC Wire','','','','','','','0.02134','','','','','','','','');
		loadBom('PCC 0.7 p','Variant','220','MLF','Punch Single Row MLF','','','FALSE','','','PCC Wire','','','','','','','0.02134','','','','','','','','');
		loadBom('PCC 0.8 p','Variant','230','MLF','Punch Single Row MLF','','','FALSE','','','PCC Wire','','','','','','','0.01829','','','','','','','','');
		loadBom('PCC 0.9 p','Variant','240','MLF','Punch Single Row MLF','','','FALSE','','','PCC Wire','','','','','','','0.01829','','','','','','','','');
		loadBom('PCC 1.0 p','Variant','250','MLF','Punch Single Row MLF','','','FALSE','','','PCC Wire','','','','','','','0.01829','','','','','','','','');
		loadBom('PCC 1.1 p','Variant','260','MLF','Punch Single Row MLF','','','FALSE','','','PCC Wire','','','','','','','0.01829','','','','','','','','');		
		loadBom('PCC 1.2 p','Variant','270','MLF','Punch Single Row MLF','','','FALSE','','','PCC Wire','','','','','','','0.01829','','','','','','','','');
		loadBom('PCC 1.3 p','Variant','280','MLF','Punch Single Row MLF','','','FALSE','','','PCC Wire','','','','','','','0.02134','','','','','','','','');
		loadBom('PCC 1.5 p','Variant','290','MLF','Punch Single Row MLF','','','FALSE','','','PCC Wire','','','','','','','0.02134','','','','','','','','');
		loadBom('PCC 2.0 p','Variant','300','MLF','Punch Single Row MLF','','','FALSE','','','PCC Wire','','','','','','','0.02743','','','','','','','','');			
		
		loadBom('Au 0.6 p','Variant','210','MLF','Punch Single Row MLF','','','FALSE','','','Au Wire','','','','','','6.00','','','','','0.0345','','','','');
		loadBom('Au 0.7 p','Variant','220','MLF','Punch Single Row MLF','','','FALSE','','','Au Wire','','','','','','3.40','','','','','0.0470','','','','');
		loadBom('Au 0.8 p','Variant','230','MLF','Punch Single Row MLF','','','FALSE','','','Au Wire','','','','','','3.20','','','','','0.0610','','','','');
		loadBom('Au 0.9 p','Variant','240','MLF','Punch Single Row MLF','','','FALSE','','','Au Wire','','','','','','3.20','','','','','0.0786','','','','');
		loadBom('Au 1.0 p','Variant','250','MLF','Punch Single Row MLF','','','FALSE','','','Au Wire','','','','','','3.20','','','','','0.0946','','','','');
		loadBom('Au 1.1 p','Variant','260','MLF','Punch Single Row MLF','','','FALSE','','','Au Wire','','','','','','3.20','','','','','0.1110','','','','');
		loadBom('Au 1.2 p','Variant','270','MLF','Punch Single Row MLF','','','FALSE','','','Au Wire','','','','','','3.20','','','','','0.1322','','','','');
		loadBom('Au 1.3 p','Variant','280','MLF','Punch Single Row MLF','','','FALSE','','','Au Wire','','','','','','3.20','','','','','0.1551','','','','');
		loadBom('Au 1.5 p','Variant','290','MLF','Punch Single Row MLF','','','FALSE','','','Au Wire','','','','','','3.20','','','','','0.2071','','','','');
		loadBom('Au 2.0 p','Variant','300','MLF','Punch Single Row MLF','','','FALSE','','','Au Wire','','','','','','3.20','','','','','0.3682','','','','');
	
		loadBom('Mold Compound','Variant','','MLF','Punch Single Row MLF','','','FALSE','KGs','G700','Mold Compound','','','','','','','12.5','','','','','','','','');
		
		loadBom('Forming Gas','Variant','','MLF','Punch Single Row MLF','','','FALSE','L/K unit','','Forming Gas','','','','','','','0.017','','','','','','','','');
		
		//---SAW VARIANTS
		loadBom('Leadframe','Variant','','MLF','Saw Single Row MLF','','','FALSE','','','Leadframe','','','','','','','','','1021.43','','','','','','');
		loadBom('Epoxy','Variant','','MLF','Saw Single Row MLF','','','FALSE','CCM','AMK-06','Epoxy','','','','','','','3.6','','','','','','','','');
		
		loadBom('PCC 0.6 s','Variant','210','MLF','Saw Single Row MLF','','','FALSE','','','PCC Wire','','','','','','','0.02134','','','','','','','','');
		loadBom('PCC 0.7 s','Variant','220','MLF','Saw Single Row MLF','','','FALSE','','','PCC Wire','','','','','','','0.02134','','','','','','','','');
		loadBom('PCC 0.8 s','Variant','230','MLF','Saw Single Row MLF','','','FALSE','','','PCC Wire','','','','','','','0.01829','','','','','','','','');
		loadBom('PCC 0.9 s','Variant','240','MLF','Saw Single Row MLF','','','FALSE','','','PCC Wire','','','','','','','0.01829','','','','','','','','');
		loadBom('PCC 1.0 s','Variant','250','MLF','Saw Single Row MLF','','','FALSE','','','PCC Wire','','','','','','','0.01829','','','','','','','','');
		loadBom('PCC 1.1 s','Variant','260','MLF','Saw Single Row MLF','','','FALSE','','','PCC Wire','','','','','','','0.01829','','','','','','','','');
		loadBom('PCC 1.2 s','Variant','270','MLF','Saw Single Row MLF','','','FALSE','','','PCC Wire','','','','','','','0.01829','','','','','','','','');
		loadBom('PCC 1.3 s','Variant','280','MLF','Saw Single Row MLF','','','FALSE','','','PCC Wire','','','','','','','0.02134','','','','','','','','');
		loadBom('PCC 1.5 s','Variant','290','MLF','Saw Single Row MLF','','','FALSE','','','PCC Wire','','','','','','','0.02134','','','','','','','','');
		loadBom('PCC 2.0 s','Variant','300','MLF','Saw Single Row MLF','','','FALSE','','','PCC Wire','','','','','','','0.02743','','','','','','','','');


		loadBom('Au 0.6 s','Variant','210','MLF','Saw Single Row MLF','','','FALSE','','','Au Wire','','','','','','6.00','','','','','0.0345','','','','');
		loadBom('Au 0.7 s','Variant','220','MLF','Saw Single Row MLF','','','FALSE','','','Au Wire','','','','','','3.40','','','','','0.0470','','','','');
		loadBom('Au 0.8 s','Variant','230','MLF','Saw Single Row MLF','','','FALSE','','','Au Wire','','','','','','3.20','','','','','0.0610','','','','');
		loadBom('Au 0.9 s','Variant','240','MLF','Saw Single Row MLF','','','FALSE','','','Au Wire','','','','','','3.20','','','','','0.0786','','','','');
		loadBom('Au 1.0 s','Variant','250','MLF','Saw Single Row MLF','','','FALSE','','','Au Wire','','','','','','3.20','','','','','0.0946','','','','');
		loadBom('Au 1.1 s','Variant','260','MLF','Saw Single Row MLF','','','FALSE','','','Au Wire','','','','','','3.20','','','','','0.1110','','','','');
		loadBom('Au 1.2 s','Variant','270','MLF','Saw Single Row MLF','','','FALSE','','','Au Wire','','','','','','3.20','','','','','0.1322','','','','');
		loadBom('Au 1.3 s','Variant','280','MLF','Saw Single Row MLF','','','FALSE','','','Au Wire','','','','','','3.20','','','','','0.1551','','','','');
		loadBom('Au 1.5 s','Variant','290','MLF','Saw Single Row MLF','','','FALSE','','','Au Wire','','','','','','3.20','','','','','0.2071','','','','');
		loadBom('Au 2.0 s','Variant','300','MLF','Saw Single Row MLF','','','FALSE','','','Au Wire','','','','','','3.20','','','','','0.3682','','','','');

		loadBom('Mold Compound','Variant','','MLF','Saw Single Row MLF','','','FALSE','KGs','G700','Mold Compound','','','','','','','12.5','','','','','','','','');
		loadBom('Mold Flash Tape','Variant','','MLF','Saw Single Row MLF','','','FALSE','Ea','','Mold Flash Tape','','','','','','','0','','','','','','','','');
		loadBom('Saw Tape','Variant','','MLF','Saw Single Row MLF','','','FALSE','Ea','','Saw Tape','','','','','','','139','','','','','','','','');
		loadBom('Saw Blade','Variant','','MLF','Saw Single Row MLF','','','FALSE','Ea','','Saw Blade','','','','','','','45.0','','99120.1922563418','','','','','','');
		loadBom('Tray','Variant','','MLF','Saw Single Row MLF','','','FALSE','PC','','Tray','','','','','','','1.27','','0.002449','','','','','','');
		
		//---Save list 
		insert bomList;
		bomVariantMap = new Map<String, FCM_BOM__c>();
		for(FCM_BOM__c row : bomList) bomVariantMap.put(row.name, row);
	}
	
	private void loadProcs()
	{
		//NOTE: mmr = machines per person
		procList = new List<FCM_Process__c>();	
		//loadProc(String name,String parent, String typeVal, String catVal, String hasVariants, String pg, String equipCost, String footprint, String index, String mmr, String uph, String timeWire, String seq,String pf, String equipment, String leadCount)
		//---PUNCH
		loadProc('Wafer B/G - Die 1','','Item','Standard','TRUE','MLF','','','','','','','100','','',''); 
		loadProc('Wafer Mount - Die 1','','Item','Standard','TRUE','MLF','','','','','','','110','','',''); 
		loadProc('Saw - Die 1','','Item','Standard','TRUE','MLF','','','','','','','120','','',''); 
		loadProc('2nd Op - Die 1','','Item','Standard','TRUE','MLF','','','','','14000','','130','','',''); 
		loadProc('Wafer B/G - Die 2','','Item','Standard','TRUE','MLF','','','','','','','140','','',''); 
		loadProc('Wafer Mount - Die 2','','Item','Standard','TRUE','MLF','','','','','','','150','','',''); 
		loadProc('Saw - Die 2','','Item','Standard','TRUE','MLF','','','','','','','160','','',''); 
		loadProc('2nd Op - Die 2','','Item','Standard','TRUE','MLF','','','','','14000','','170','','',''); 
		loadProc('D/A - Die 1','','Item','Standard','TRUE','MLF','','','','','3500','','180','','',''); 
		loadProc('D/A Cure - Die 1','','Item','Standard','TRUE','MLF','','','','','','','190','','',''); 
		loadProc('D/A - Die 2','','Item','Standard','TRUE','MLF','','','','','3500','','200','','',''); 
		loadProc('D/A Cure - Die 2','','Item','Standard','TRUE','MLF','','','','','3500','','210','','',''); 
		loadProc('Wire Bond - Die 1','','Item','Standard','TRUE','MLF','','','','','','','220','','',''); 
		loadProc('3rd Op - Die 1','','Item','Standard','TRUE','MLF','','','','','14000','','230','','',''); 
		loadProc('Wire Bond - Die 2','','Item','Standard','TRUE','MLF','','','','','','','240','','',''); 
		loadProc('3rd Op - Die 2','','Item','Standard','TRUE','MLF','','','','','14000','','250','','',''); 
		loadProc('Mold','','Item','Standard','TRUE','MLF','','','','','','','260','','',''); 
		loadProc('Chemical Deflash','','Item','Standard','TRUE','MLF','','','','','','','270','','',''); 
		loadProc('P/Cure','','Item','Standard','TRUE','MLF','','','','','','','280','','',''); 
		loadProc('Laser','','Item','Standard','TRUE','MLF','','','','','','','290','','',''); 
		loadProc('S/PLT','','Item','Standard','TRUE','MLF','','','','','','','300','','',''); 
		loadProc('Singulate','','Item','Standard','TRUE','MLF','','','','','','','310','','',''); 
		loadProc('FVI','','Item','Standard','TRUE','MLF','','','','','','','320','','',''); 
		loadProc('Pack','','Item','Standard','TRUE','MLF','','','','','','','330','','',''); 
		
		//---SAW (NOT IN PUNCH)
		loadProc('D/A','','Item','Standard','TRUE','MLF','','','','','','','180','','',''); 
		loadProc('D/A Cure','','Item','Standard','TRUE','MLF','','','','','','','190','','',''); 
		loadProc('Wire Bond','','Item','Standard','TRUE','MLF','','','','','','','200','','',''); 
		loadProc('Tape Removal','','Item','Standard','TRUE','MLF','','','','','','','210','','',''); 
		loadProc('Chemical Deflash/Plating','','Item','Standard','TRUE','MLF','','','','','','','220','','',''); 
		loadProc('Post-Plate Bake','','Item','Standard','TRUE','MLF','','','','','','','230','','',''); 
		loadProc('Laser Mark','','Item','Standard','TRUE','MLF','','','','','','','240','','',''); 
		loadProc('Saw Singulate','','Item','Standard','TRUE','MLF','','','','','','','250','','',''); 
		loadProc('FVI Q','','Item','Standard','TRUE','MLF','','','','','','','260','','',''); 
		
		//---Save current list and load into map (For parent matching)
		insert procList;
		procMap = new Map<String, FCM_Process__c>();
		for(FCM_Process__c row : procList) procMap.put(row.name, row);
		procList = new List<FCM_Process__c>();
		
		//---PUNCH
		loadProc('Wafer B/G - Die 1','Wafer B/G - Die 1','Variant','Standard','FALSE','MLF','1400','47','','2.0','','','100','Punch Single Row MLF','',''); 
		loadProc('Wafer Mount - Die 1','Wafer Mount - Die 1','Variant','Standard','FALSE','MLF','110','22','','2.0','','','110','Punch Single Row MLF','','');
		loadProc('Saw - Die 1','Saw - Die 1','Variant','Standard','FALSE','MLF','140','15','','9.0','','','120','Punch Single Row MLF','','');
		loadProc('2nd Op - Die 1','2nd Op - Die 1','Variant','Standard','FALSE','MLF','15','6','','1.0','','','130','Punch Single Row MLF','','');
		
		loadProc('Wafer B/G - Die 2','Wafer B/G - Die 2','Variant','Standard','FALSE','MLF','1400','47','','2.0','','','140','Punch Single Row MLF','',''); 
		loadProc('Wafer Mount - Die 2','Wafer Mount - Die 2','Variant','Standard','FALSE','MLF','300','68','','2.0','','','150','Punch Single Row MLF','','');
		loadProc('Saw - Die 2','Saw - Die 2','Variant','Standard','FALSE','MLF','250','41','','2.0','','','160','Punch Single Row MLF','','');
		loadProc('2nd Op - Die 2','2nd Op - Die 2','Variant','Standard','FALSE','MLF','15','6','','1.0','','','170','Punch Single Row MLF','','');
		
		loadProc('D/A - Die 1','D/A - Die 1','Variant','Standard','FALSE','MLF','201','18','','3.0','','','180','Punch Single Row MLF','','');
		loadProc('D/A Cure - Die 1','D/A Cure - Die 1','Variant','Standard','FALSE','MLF','25','22','','8.0','','','190','Punch Single Row MLF','','');
		loadProc('D/A - Die 2','D/A - Die 2','Variant','Standard','FALSE','MLF','201','18','','3.0','','','200','Punch Single Row MLF','','');
		loadProc('D/A Cure - Die 2','D/A Cure - Die 2','Variant','Standard','FALSE','MLF','25','22','','8.0','','','210','Punch Single Row MLF','','');
		
		loadProc('Wire Bond - Die 1','Wire Bond','Variant','Standard','FALSE','MLF','60','10','','35.0','','','220','Punch Single Row MLF','','');			//---CU WIRE
		loadProc('3rd Op - Die 1','3rd Op - Die 1','Variant','Standard','FALSE','MLF','2','6','','1.0','','','230','Punch Single Row MLF','','');
		
		loadProc('Wire Bond - Die 2','Wire Bond - Die 2','Variant','Standard','FALSE','MLF','60','10','','35.0','','','240','Punch Single Row MLF','','');			//---AU WIRE
		loadProc('3rd Op - Die 2','3rd Op - Die 2','Variant','Standard','FALSE','MLF','2','6','','1.0','','','250','Punch Single Row MLF','','');
		
		loadProc('Mold','Mold','Variant','Standard','FALSE','MLF','575','60','','2.0','','','260','Punch Single Row MLF','','');
		loadProc('Chemical Deflash','Chemical Deflash','Variant','Standard','FALSE','MLF','400','120','','3.0','','','270','Punch Single Row MLF','','');
		loadProc('P/Cure','P/Cure','Variant','Standard','FALSE','MLF','25','22','','15.0','','','280','Punch Single Row MLF','','');
		loadProc('Laser','Laser','Variant','Standard','FALSE','MLF','260','37','','3.0','','','290','Punch Single Row MLF','','');
		loadProc('S/PLT','S/PLT','Variant','Standard','FALSE','MLF','1100','500','','2.0','','','300','Punch Single Row MLF','','');
		loadProc('Singulate','Singulate','Variant','Standard','FALSE','MLF','358','20','','2.0','','','310','Punch Single Row MLF','','');
		loadProc('FVI','FVI','Variant','Standard','FALSE','MLF','0','6','','1.0','','','320','Punch Single Row MLF','','');
		loadProc('Pack','Pack','Variant','Standard','FALSE','MLF','5','6','','1.0','','','330','Punch Single Row MLF','','');
		
		
		//---SAW
		loadProc('Wafer B/G - Die 1','Wafer B/G - Die 1','Variant','Standard','FALSE','MLF','1400','47','','2.0','','','100','Saw Single Row MLF','',''); 
		loadProc('Wafer Mount - Die 1','Wafer Mount - Die 1','Variant','Standard','FALSE','MLF','300','68','','2.0','','','110','Saw Single Row MLF','','');
		loadProc('Saw - Die 1','Saw - Die 1','Variant','Standard','FALSE','MLF','250','41','','2.0','','','120','Saw Single Row MLF','','');
		loadProc('2nd Op - Die 1','2nd Op - Die 1','Variant','Standard','FALSE','MLF','15','6','','1.0','','','130','Saw Single Row MLF','','');
		
		loadProc('Wafer B/G - Die 2','Wafer B/G - Die 2','Variant','Standard','FALSE','MLF','1400','47','','2.0','','','140','Saw Single Row MLF','',''); 
		loadProc('Wafer Mount - Die 2','Wafer Mount - Die 2','Variant','Standard','FALSE','MLF','300','68','','2.0','','','150','Saw Single Row MLF','','');
		loadProc('Saw - Die 2','Saw - Die 2','Variant','Standard','FALSE','MLF','250','41','','2.0','','','160','Saw Single Row MLF','','');
		loadProc('2nd Op - Die 2','2nd Op - Die 2','Variant','Standard','FALSE','MLF','15','6','','1.0','','','170','Saw Single Row MLF','','');
		
		loadProc('D/A','D/A','Variant','Standard','FALSE','MLF','230','32','','6.0','3500','','180','Saw Single Row MLF','','');
		loadProc('D/A Cure','D/A Cure','Variant','Standard','FALSE','MLF','63','25','','15.0','','','190','Saw Single Row MLF','','');
		loadProc('Wire Bond','Wire Bond','Variant','Standard','FALSE','MLF','60','18','','30.0','','','200','Saw Single Row MLF','','');
		loadProc('Mold','Mold','Variant','Standard','FALSE','MLF','315','68','','2.0','','','210','Saw Single Row MLF','','');
		loadProc('Tape Removal','Tape Removal','Variant','Standard','FALSE','MLF','2.1','16','','1.0','','','220','Saw Single Row MLF','','');
		loadProc('P/Cure','P/Cure','Variant','Standard','FALSE','MLF','30','26','','15.0','','','230','Saw Single Row MLF','','');
		
		loadProc('Chemical Deflash/Plating','Chemical Deflash/Plating','Variant','Standard','FALSE','MLF','1200','1108','','2.0','','','240','Saw Single Row MLF','','');
		loadProc('Post-Plate Bake','Post-Plate Bake','Variant','Standard','FALSE','MLF','30','26','','15.0','','','250','Saw Single Row MLF','','');
		loadProc('Laser Mark','Laser Mark','Variant','Standard','FALSE','MLF','300','62','','3.0','','','260','Saw Single Row MLF','','');
		loadProc('Saw Singulate','Saw Singulate','Variant','Standard','FALSE','MLF','560','76','','2.0','','','270','Saw Single Row MLF','','');
		loadProc('FVI Q','FVI Q','Variant','Standard','FALSE','MLF','3.15','16','','1.0','39200','','280','Saw Single Row MLF','','');
		loadProc('Pack','Pack','Variant','Standard','FALSE','MLF','16.8','23','','1.0','','','290','Saw Single Row MLF','','');
	
		insert procList;
		procVariantMap = new Map<String, FCM_Process__c>();
		for(FCM_Process__c row : procList) procVariantMap.put(row.name, row);
	}
	
	private void loadMatches()
	{
		loadMatch('Leadframe','','AlwaysItem','','','','');
		loadMatch('Epoxy','','AlwaysDie','','','','');
		loadMatch('Mold Compound','','AlwaysItem','','','','');
		loadMatch('Tray','','AlwaysItem','','','','');
		loadMatch('Mold Flash Tape','','AlwaysItem','','','','');
		loadMatch('Saw Tape','','AlwaysItem','','','','');
		loadMatch('Saw Blade','','AlwaysItem','','','','');
		//loadMatch('Forming Gas','','AlwaysItem','','','','');
		
		//Lalit SF-85.
		loadMatch('Forming Gas','','WireTextValue','ContainsOnlyOne','Wire_Material__c','AuPCC','FALSE');
	    //Lalit SF-85.
		loadMatch('PCC Wire','','WireTextValue','Contains','Wire_Material__c','AuPCC','FALSE');
		loadMatch('Au Wire','','WireTextValue','Contains','Wire_Material__c','Au','FALSE');
	
		loadMatch('PCC 0.6 p','','WireTextValue','Contains','Wire_Diameter__c','0.6','FALSE');
		loadMatch('PCC 0.7 p','','WireTextValue','Contains','Wire_Diameter__c','0.7','FALSE');
		loadMatch('PCC 0.8 p','','WireTextValue','Contains','Wire_Diameter__c','0.8','FALSE');
		loadMatch('PCC 0.9 p','','WireTextValue','Contains','Wire_Diameter__c','0.9','FALSE');
		loadMatch('PCC 1.0 p','','WireTextValue','Contains','Wire_Diameter__c','1.0','FALSE');
		loadMatch('PCC 1.1 p','','WireTextValue','Contains','Wire_Diameter__c','1.1','FALSE');
		loadMatch('PCC 1.2 p','','WireTextValue','Contains','Wire_Diameter__c','1.2','FALSE');
		loadMatch('PCC 1.3 p','','WireTextValue','Contains','Wire_Diameter__c','1.3','FALSE');
		loadMatch('PCC 1.5 p','','WireTextValue','Contains','Wire_Diameter__c','1.5','FALSE');
		loadMatch('PCC 2.0 p','','WireTextValue','Contains','Wire_Diameter__c','2.0','FALSE');
		
		loadMatch('Au 0.6 p','','WireTextValue','Contains','Wire_Diameter__c','0.6','FALSE');
		loadMatch('Au 0.7 p','','WireTextValue','Contains','Wire_Diameter__c','0.7','FALSE');
		loadMatch('Au 0.8 p','','WireTextValue','Contains','Wire_Diameter__c','0.8','FALSE');
		loadMatch('Au 0.9 p','','WireTextValue','Contains','Wire_Diameter__c','0.9','FALSE');
		loadMatch('Au 1.0 p','','WireTextValue','Contains','Wire_Diameter__c','1.0','FALSE');
		loadMatch('Au 1.1 p','','WireTextValue','Contains','Wire_Diameter__c','1.1','FALSE');
		loadMatch('Au 1.2 p','','WireTextValue','Contains','Wire_Diameter__c','1.2','FALSE');
		loadMatch('Au 1.3 p','','WireTextValue','Contains','Wire_Diameter__c','1.3','FALSE');
		loadMatch('Au 1.5 p','','WireTextValue','Contains','Wire_Diameter__c','1.5','FALSE');
		loadMatch('Au 2.0 p','','WireTextValue','Contains','Wire_Diameter__c','2.0','FALSE');
		
		loadMatch('PCC 0.6 s','','WireTextValue','Contains','Wire_Diameter__c','0.6','FALSE');
		loadMatch('PCC 0.7 s','','WireTextValue','Contains','Wire_Diameter__c','0.7','FALSE');
		loadMatch('PCC 0.8 s','','WireTextValue','Contains','Wire_Diameter__c','0.8','FALSE');
		loadMatch('PCC 0.9 s','','WireTextValue','Contains','Wire_Diameter__c','0.9','FALSE');
		loadMatch('PCC 1.0 s','','WireTextValue','Contains','Wire_Diameter__c','1.0','FALSE');
		loadMatch('PCC 1.1 s','','WireTextValue','Contains','Wire_Diameter__c','1.1','FALSE');
		loadMatch('PCC 1.2 s','','WireTextValue','Contains','Wire_Diameter__c','1.2','FALSE');
		loadMatch('PCC 1.3 s','','WireTextValue','Contains','Wire_Diameter__c','1.3','FALSE');
		loadMatch('PCC 1.5 s','','WireTextValue','Contains','Wire_Diameter__c','1.5','FALSE');
		loadMatch('PCC 2.0 s','','WireTextValue','Contains','Wire_Diameter__c','2.0','FALSE');
		
		loadMatch('Au 0.6 s','','WireTextValue','Contains','Wire_Diameter__c','0.6','FALSE');
		loadMatch('Au 0.7 s','','WireTextValue','Contains','Wire_Diameter__c','0.7','FALSE');
		loadMatch('Au 0.8 s','','WireTextValue','Contains','Wire_Diameter__c','0.8','FALSE');
		loadMatch('Au 0.9 s','','WireTextValue','Contains','Wire_Diameter__c','0.9','FALSE');
		loadMatch('Au 1.0 s','','WireTextValue','Contains','Wire_Diameter__c','1.0','FALSE');
		loadMatch('Au 1.1 s','','WireTextValue','Contains','Wire_Diameter__c','1.1','FALSE');
		loadMatch('Au 1.2 s','','WireTextValue','Contains','Wire_Diameter__c','1.2','FALSE');
		loadMatch('Au 1.3 s','','WireTextValue','Contains','Wire_Diameter__c','1.3','FALSE');
		loadMatch('Au 1.5 s','','WireTextValue','Contains','Wire_Diameter__c','1.5','FALSE');
		loadMatch('Au 2.0 s','','WireTextValue','Contains','Wire_Diameter__c','2.0','FALSE');
		
	
		//---Processes		
		loadMatch('','Wafer B/G - Die 1','DiePosition','','','','','1');
		loadMatch('','Wafer Mount - Die 1','DiePosition','','','','','1');
		loadMatch('','Saw - Die 1','DiePosition','','','','','1');
		loadMatch('','2nd Op - Die 1','DiePosition','','','','','1');
		loadMatch('','Wafer B/G - Die 2','DiePosition','','','','','2');
		loadMatch('','Wafer Mount - Die 2','DiePosition','','','','','2');
		loadMatch('','Saw - Die 2','DiePosition','','','','','2');
		loadMatch('','2nd Op - Die 2','DiePosition','','','','','2');
		loadMatch('','D/A - Die 1','DiePosition','','','','','1');
		loadMatch('','D/A Cure - Die 1','DiePosition','','','','','1');
		loadMatch('','D/A - Die 2','DiePosition','','','','','2');
		loadMatch('','D/A Cure - Die 2','DiePosition','','','','','2');
		loadMatch('','Wire Bond - Die 1','DiePosition','','','','','1');
		loadMatch('','3rd Op - Die 1','DiePosition','','','','','1');
		loadMatch('','Wire Bond - Die 2','DiePosition','','','','','2');
		loadMatch('','3rd Op - Die 2','DiePosition','','','','','2');
		loadMatch('','Mold','AlwaysItem','','','','');
		loadMatch('','Chemical Deflash','AlwaysItem','','','','');
		loadMatch('','P/Cure','AlwaysItem','','','','');
		loadMatch('','Laser','AlwaysItem','','','','');
		loadMatch('','S/PLT','AlwaysItem','','','','');
		loadMatch('','Singulate','AlwaysItem','','','','');
		loadMatch('','FVI','AlwaysItem','','','','');
		loadMatch('','Pack','AlwaysItem','','','','');
		loadMatch('','D/A','AlwaysItem','','','','');
		loadMatch('','D/A Cure','AlwaysItem','','','','');
		loadMatch('','Wire Bond','AlwaysItem','','','','');
		loadMatch('','Tape Removal','AlwaysItem','','','','');
		loadMatch('','Chemical Deflash/Plating','AlwaysItem','','','','');
		loadMatch('','Post-Plate Bake','AlwaysItem','','','','');
		loadMatch('','Laser Mark','AlwaysItem','','','','');
		loadMatch('','Saw Singulate','AlwaysItem','','','','');
		loadMatch('','FVI Q','AlwaysItem','','','','');
		
		insert matchList;
	}
	
	public static void incrementalInstall1(){

		//Delete the previous FCM Assumption for MLF
		CMMLFInstaller installer = new CMMLFInstaller();
		List<Package_Family__c> pfs = [Select Id, Name, Specific_RFQ_Item_Object__c, Product_Group__r.Name from Package_Family__c where Product_Group__r.Name =: 'MLF'];
		
		//Delete FCM_Assuption__c for all MLF product group
		for(Package_Family__c pf : pfs){
			List<FCM_Assumption__c> fcmAList = [Select Id, Package_Family__c from FCM_Assumption__c where Package_Family__c =: pf.Id];		
			if(fcmAList != null)			
				delete fcmAList;
		}

		//Reinstall it
		
		loadAssumptions();

	}

	public static void incrementalInstall_AMK1426(){
		
		CMMLFInstaller installer = new CMMLFInstaller();		
		//Delete previous cmmargin
		Product_Group__c productGroup = [Select Id, Name from Product_Group__c where Name =: 'MLF'];
		CM_Margin_Version__c cmMarginVersion = CMMarginVersionDao.getInstance().getByPGAndStatus(productGroup.Id, 'Active')[0];
		
		//clone a new one and archive the old one
		CM_Margin_Version__c newCMMarginVersion = cmMarginVersion.clone(false, true, false, false);
		Decimal nextVerNum = CMMarginVersionDao.getInstance().getNextVersionNum(productGroup.Id);
		newCMMarginVersion.Version__c = nextVerNum;		
		insert newCMMarginVersion;
		//Clone child list
		List<CM_Margin__c> sourceMarginList = CMMarginDao.getInstance().getByVersion(cmMarginVersion.id);		
		installer.cloneMarginVersionChildList(sourceMarginList, newCMMarginVersion.id, null);				
		
		cmMarginVersion.Status__c = 'Archived';
		update cmMarginVersion;

		//mulipulate the new one
		installer.cmMarginVersion = CMMarginVersionDao.getInstance().getByPGAndStatus(productGroup.Id, 'Active')[0];	
		List<CM_Margin__c> marginList = CMMarginDao.getInstance().getByVersion(installer.cmMarginVersion.id);
		delete marginList;
		

		
		//clone a new one and archive the old one
		CM_Version__c cmVersion = CMVersionDao.getInstance().getByPGAndStatus(productGroup.Id, 'Active')[0];
		CM_Version__c newCMVersion = cmVersion.clone(false, true, false, false);		
		nextVerNum = CMVersionDao.getInstance().getNextVersionNum(productGroup.Id);
		newCMVersion.Version__c = nextVerNum;
		insert newCMVersion;


		//---Clone BOM (with children and match conditions)
		List<FCM_Match_Condition__c> matchList = FCMMatchConditionDao.getInstance().getAllByBomVersion(cmVersion.id);		
		List<FCM_BOM__c> sourceBomList = FCMBOMDao.getInstance().getByVersion(cmVersion.id);
		installer.cloneCMVersionChildList(sourceBomList, newCMVersion.id, 'Parent_BOM__c', matchList, 'FCM_BOM__c');
				
		//---Clone Process (with children and match conditions) 
		matchList = FCMMatchConditionDao.getInstance().getAllByProcessVersion(cmVersion.id);		
		List<FCM_Process__c> sourceProcessList = FCMProcessDao.getInstance().getByVersion(cmVersion.id);
		installer.cloneCMVersionChildList(sourceProcessList, newCMVersion.id, 'Parent_Process__c', matchList, 'FCM_Process__c');
		
		//---Clone Assumptions
		List<FCM_Assumption__c> sourceAssumptionList = FCMAssumptionDao.getInstance().getByVersion(cmVersion.id);
		installer.cloneCMVersionChildList(sourceAssumptionList, newCMVersion.id, null, null, null);
				
		//---Clone PF Values
		List<CM_PF_Value__c> sourceValueList = CMPFValueDao.getInstance().getByVersion(cmVersion.id);
		installer.cloneCMVersionChildList(sourceValueList, newCMVersion.id, null, null, null);

		//---Clone Test Models
		List<CM_Test_Model__c> sourceModelList = CMTestModelDao.getInstance().getByVersion(cmVersion.id);
		installer.cloneCMVersionChildList(sourceModelList, newCMVersion.id, null, null, null);

		

		cmVersion.Status__c = 'Archived';
		update cmVersion;

		//mulipulate the new one
		installer.cmVersion = CMVersionDao.getInstance().getByPGAndStatus(productGroup.Id, 'Active')[0];
		List<CM_PF_Value__c> cmpfValueList = CMPFValueDao.getInstance().getByVersion(installer.cmVersion.id);
		delete cmpfValueList;
		

		//setup cmversion and pfMap		
		installer.pfMap = new Map<String, Package_Family__c>();
		installer.marginList = new List<CM_Margin__c>();
		installer.valueList = new List<CM_PF_Value__c>();
		List<Package_Family__c> pfList = [Select id, name, Specific_RFQ_Item_Object__c, Product_Group__c from Package_Family__c where Product_Group__c = :productGroup.Id];
		for(Package_Family__c row : pfList) installer.pfMap.put(row.name, row);
		

		//load margins and pfvalues
		if(CMMarginDao.getInstance().getByVersion(installer.cmMarginVersion.id).size() == 0)
			installer.loadMargins();		
		if(CMPFValueDao.getInstance().getByVersion(installer.cmVersion.id).size() == 0)
			installer.loadValues();
	}

	private void cloneMarginVersionChildList(List<SObject> sourceList, String verId, String parentFieldName)
	{
		List<SObject> cloneList = new List<SObject>();
		
		Map<String, String> keyMap = new Map<String, String>();
		
		if (sourceList != null && sourceList.size() != 0)
		{
			for(SObject row : sourceList)
			{
				SObject cloneObj = row.clone(false, true, false, false);
				cloneObj.put('CM_Margin_Version__c', verId);
				cloneList.add( cloneObj);								
			}
			
			insert cloneList;
			
			if (parentFieldName != null)
			{
				Integer counter = 0;
				for(SObject row : sourceList)
				{
					keyMap.put(sourceList[counter].id, cloneList[counter].id);	//---Record old and new key	
					counter++;
				}
			
				for(SObject row : cloneList)
				{
					String parentVal = (String)row.get(parentFieldName);		//---Lookup the old key
				
					if (parentVal != null)
					{
						String newKey = keyMap.get(parentVal);					//---Get the new key
						row.put(parentFieldName, newKey);
					}
				}
				
				update cloneList;
			}
		}				
	}


	private void cloneCMVersionChildList(List<SObject> sourceList, String verId, String parentFieldName, List<FCM_Match_Condition__c> sourceMatchList, String matchParentField)
	{
		List<SObject> cloneList = new List<SObject>();
		
		Map<String, String> keyMap = new Map<String, String>();
		
		if (sourceList != null && sourceList.size() != 0)
		{
			for(SObject row : sourceList)
			{
				SObject cloneObj = row.clone(false, true, false, false);
				cloneObj.put('CM_Version__c', verId);
				cloneList.add( cloneObj);
			}
			
			insert cloneList;
			
			if (parentFieldName != null)
			{
				Integer counter = 0;
				for(SObject row : sourceList)
				{
					keyMap.put(sourceList[counter].id, cloneList[counter].id);	//---Record old and new key	
					counter++;
				}
			
				for(SObject row : cloneList)
				{
					String parentVal = (String)row.get(parentFieldName);		//---Lookup the old key
				
					if (parentVal != null)
					{
						String newKey = keyMap.get(parentVal);					//---Get the new key
						row.put(parentFieldName, newKey);
					}
				}
				
				update cloneList;
			}
			
			//---Update Source Match List
			if (sourceMatchList != null)
			{
				List<FCM_Match_Condition__c> cloneMatchList = new List<FCM_Match_Condition__c>();
				
				for(FCM_Match_Condition__c row : sourceMatchList)
				{
					FCM_Match_Condition__c cloneObj = row.clone(false, true, false, false);
					
					String origParent = (String)cloneObj.get(matchParentField);
					String newParent = keyMap.get(origParent);
					cloneObj.put(matchParentField,  newParent);
					
					cloneMatchList.add( cloneObj);
				}
				
				insert cloneMatchList;
			}
		}
				
	}

	private static void loadAssumptions() 
	{
		//---TODO Development Cost(3 yr amort) =
		//---TODO GNA(including Amkor GnA) % to Process cost =
		//---TODO Interest % to Depreciation =
		//---TODO Indirect Labor ( % of Direct Labor) =
		List<FCM_Assumption__c> assumptionList = new List<FCM_Assumption__c>();
		List<Factory__c> factories = [select id, Name from Factory__c];
		Map<String, String> factoryMap = new Map<String, String>();
		for(Factory__c factory : factories){
			factoryMap.put(factory.Name, factory.id);
		}
		
		FCM_Assumption__c fcmA = null;
		
		//get all possible package families
		List<Package_Family__c> pfs = [Select Id, Name, Specific_RFQ_Item_Object__c, Product_Group__r.Name from Package_Family__c where Product_Group__r.Name =: 'MLF'];
		Product_Group__c productGroup = [Select Id, Name from Product_Group__c where Name =: 'MLF'];
		List<CM_Version__c> cmList = CMVersionDao.getInstance().getByPGAndStatus(productGroup.Id, 'Active');
		CM_Version__c cm = cmList[0];
		
		for(Package_Family__c pf : pfs)		
		{			
			String pf_sub_class_1 = getPF_Sub_Class_1(pf);
			String factoryName = FactoryHelper.getAllowedFactories(convertPfNameToRfqi(pf.Name));
			if (pf != null && pf_sub_class_1.compareTo('PMLF') == 0)
			{
				//Convert package family to rfqi

				//---KOREA
				if(factoryName.contains('K')){
					fcmA = new FCM_Assumption__c(Factory__c = factoryMap.get(factoryName), CM_Version__c=cm.id,Product_Group__c=pf.Product_Group__c, Package_Family__c=pf.id);
				//fcmA.Factory__c = 'K1';
					fcmA.Available_Hours_Per_Week__c = 168;
					fcmA.Work_Weeks_Year__c = 50;
					fcmA.Direct_Labor_Rate__c = 12.76;
					fcmA.Off_Equipment_Direct_To_Direct__c =  .281;
					fcmA.Equipment_Life__c = 7;
					fcmA.Annual_Fac_Cost_Sqft__c = 31;
					fcmA.QA_Cost_To_Process_Cost__c = 0.05395771560;
					fcmA.Service_Cost_To_Process_Cost__c = 0.05590255150;
					fcmA.Manuf_OH_To_Process_Cost__c = .244;

					fcmA.Utilization_Efficiency_Percent__c = 70;
					fcmA.Utilization_Efficiency_Compound_Percent__c = 65; 
					fcmA.Cum_Yield_Percent__c = 99.5;
					fcmA.Material_Freight_Percent__c = 2;
					fcmA.Material_Tooling_Percent__c = 2;
					fcmA.Material_Brokerage_Percent__c = 0;
					fcmA.Forecast_Factor_1__c = 1.42920000000;
					fcmA.Forecast_Factor_2__c = 1.19100000000;  
					fcmA.Forecast_Factor_3__c = 0.95280000000;  
					fcmA.FCM_Is_Dedicated__c = false;
					assumptionList.add( fcmA);
				}
			
				//---PI
				if(factoryName.contains('P')){
					fcmA = new FCM_Assumption__c(Factory__c = factoryMap.get(factoryName), CM_Version__c=cm.id,Product_Group__c=pf.Product_Group__c, Package_Family__c=pf.id);
				//fcmA.Factory__c = 'P1';
					fcmA.Available_Hours_Per_Week__c = 168;
					fcmA.Work_Weeks_Year__c = 50;
					fcmA.Direct_Labor_Rate__c = 2.87027132176725;
					fcmA.Off_Equipment_Direct_To_Direct__c =  0.162105263157895;
					fcmA.Equipment_Life__c = 7;
					fcmA.Annual_Fac_Cost_Sqft__c = 33;
					fcmA.QA_Cost_To_Process_Cost__c = 0.031115683170326;
					fcmA.Service_Cost_To_Process_Cost__c = 0.0549919203730756;
					fcmA.Manuf_OH_To_Process_Cost__c = 0.411129336956957;

					fcmA.Utilization_Efficiency_Percent__c = 70;
					fcmA.Utilization_Efficiency_Compound_Percent__c = 65;  
					fcmA.Cum_Yield_Percent__c = 99.5;
					fcmA.Material_Freight_Percent__c = 2;
					fcmA.Material_Tooling_Percent__c = 2;
					fcmA.Material_Brokerage_Percent__c = 0;
					fcmA.Forecast_Factor_1__c = 1.36777637098;
					fcmA.Forecast_Factor_2__c = 1.13981364248;  
					fcmA.Forecast_Factor_3__c = 0.91185091398;   
					fcmA.FCM_Is_Dedicated__c = false;

					assumptionList.add( fcmA);
				}
			
				//---CHINA
				if(factoryName.contains('C')){
					fcmA = new FCM_Assumption__c(Factory__c = factoryMap.get(factoryName), CM_Version__c=cm.id,Product_Group__c=pf.Product_Group__c, Package_Family__c=pf.id);
				//fcmA.Factory__c = 'C1';
					fcmA.Available_Hours_Per_Week__c = 168;
					fcmA.Work_Weeks_Year__c = 50;
					fcmA.Direct_Labor_Rate__c = 2.96;
					fcmA.Off_Equipment_Direct_To_Direct__c =  0.3;
					fcmA.Equipment_Life__c = 7;
					fcmA.Annual_Fac_Cost_Sqft__c = 78;
					fcmA.QA_Cost_To_Process_Cost__c = 0.07;
					fcmA.Service_Cost_To_Process_Cost__c = 0.11;
					fcmA.Manuf_OH_To_Process_Cost__c = 0.46;

					fcmA.Utilization_Efficiency_Percent__c = 70;
					fcmA.Utilization_Efficiency_Compound_Percent__c = 65;  
					fcmA.Cum_Yield_Percent__c = 99.5;
					fcmA.Material_Freight_Percent__c = 2;
					fcmA.Material_Tooling_Percent__c = 2;
					fcmA.Material_Brokerage_Percent__c = 0;
					fcmA.Forecast_Factor_1__c = 1.71600000000;
					fcmA.Forecast_Factor_2__c = 1.43000000000;  
					fcmA.Forecast_Factor_3__c = 1.14400000000;  
					fcmA.FCM_Is_Dedicated__c = false;

					assumptionList.add( fcmA);
				}
			}			
 
			if (pf != null && pf_sub_class_1 == 'SMLF')
			{
				//System.debug(LoggingLevel.ERROR, '##### load SMLF package family is ' + pf.Name);
				//---KOREA
				//fcmA.Factory__c = 'K1';
				if(factoryName.contains('K')){
					fcmA = new FCM_Assumption__c(Factory__c = factoryMap.get(factoryName), CM_Version__c=cm.id,Product_Group__c=pf.Product_Group__c, Package_Family__c=pf.id);
					fcmA.Available_Hours_Per_Week__c = 168;
					fcmA.Work_Weeks_Year__c = 50;
					fcmA.Direct_Labor_Rate__c = 12.76;
					fcmA.Off_Equipment_Direct_To_Direct__c =  .281;
					fcmA.Equipment_Life__c = 7;
					fcmA.Annual_Fac_Cost_Sqft__c = 31;
				//TODO fcmA.QA_Cost_To_Process_Cost__c = ;
				//TODO fcmA.Service_Cost_To_Process_Cost__c = ;
					fcmA.Manuf_OH_To_Process_Cost__c = .244;

					fcmA.Utilization_Efficiency_Percent__c = 70; 
					fcmA.Cum_Yield_Percent__c = 99.5;
					fcmA.Material_Freight_Percent__c = 2;
					fcmA.Material_Tooling_Percent__c = 2;
					fcmA.Material_Brokerage_Percent__c = 0;
					fcmA.Forecast_Factor_1__c = 1.42920000000;
					fcmA.Forecast_Factor_2__c = 1.19100000000;  
					fcmA.Forecast_Factor_3__c = 0.95280000000;  
					fcmA.FCM_Is_Dedicated__c = false;
					assumptionList.add( fcmA);
				}
			
				//---PI
				if(factoryName.contains('P')){
					fcmA = new FCM_Assumption__c(Factory__c = factoryMap.get(factoryName), CM_Version__c=cm.id,Product_Group__c=pf.Product_Group__c, Package_Family__c=pf.id);
				//fcmA.Factory__c = 'P1';
					fcmA.Available_Hours_Per_Week__c = 168;
					fcmA.Work_Weeks_Year__c = 50;
					fcmA.Direct_Labor_Rate__c = 2.87027132176725;
					fcmA.Off_Equipment_Direct_To_Direct__c =  0.162105263157895;
					fcmA.Equipment_Life__c = 7;
					fcmA.Annual_Fac_Cost_Sqft__c = 33;
					fcmA.QA_Cost_To_Process_Cost__c = 0.031115683170326;
					fcmA.Service_Cost_To_Process_Cost__c = 0.0549919203730756;
					fcmA.Manuf_OH_To_Process_Cost__c = .411129336956957;

					fcmA.Utilization_Efficiency_Percent__c = 70; 
					fcmA.Cum_Yield_Percent__c = 99.5;
					fcmA.Material_Freight_Percent__c = 2;
					fcmA.Material_Tooling_Percent__c = 2;
					fcmA.Material_Brokerage_Percent__c = 0;
					fcmA.Forecast_Factor_1__c = 1.36777637098;
					fcmA.Forecast_Factor_2__c = 1.13981364248;  
					fcmA.Forecast_Factor_3__c = 0.91185091398;   
					fcmA.FCM_Is_Dedicated__c = false;

					assumptionList.add( fcmA);
				}
			
				//---CHINA
				if(factoryName.contains('C')){
					fcmA = new FCM_Assumption__c(Factory__c = factoryMap.get(factoryName), CM_Version__c=cm.id,Product_Group__c=pf.Product_Group__c, Package_Family__c=pf.id);
				//fcmA.Factory__c = 'C1';
					fcmA.Available_Hours_Per_Week__c = 168;
					fcmA.Work_Weeks_Year__c = 50;
					fcmA.Direct_Labor_Rate__c = 2.96;
					fcmA.Off_Equipment_Direct_To_Direct__c =  0.3;
					fcmA.Equipment_Life__c = 7;
					fcmA.Annual_Fac_Cost_Sqft__c = 78;
					fcmA.QA_Cost_To_Process_Cost__c = 0.07;
					fcmA.Service_Cost_To_Process_Cost__c = 0.11;
					fcmA.Manuf_OH_To_Process_Cost__c = 0.46;

					fcmA.Utilization_Efficiency_Percent__c = 70; 
					fcmA.Cum_Yield_Percent__c = 99.5;
					fcmA.Material_Freight_Percent__c = 2;
					fcmA.Material_Tooling_Percent__c = 2;
					fcmA.Material_Brokerage_Percent__c = 0;
					fcmA.Forecast_Factor_1__c = 1.71600000000;
					fcmA.Forecast_Factor_2__c = 1.43000000000;  
					fcmA.Forecast_Factor_3__c = 1.14400000000;  
					fcmA.FCM_Is_Dedicated__c = false;

					assumptionList.add( fcmA);
				}
			}
			
		}
		insert assumptionList;
	}
	
	//package family has Specific RFQ Item with PF_Sub_Class_1 which has default value 'PMLF' or 'SMLF'
	//However, the default values are null unless the data are inserted
	//Using getDefaultValueFormula to get the default value: http://www.tgerm.com/2010/01/salesforce-apex-default-values.html
	private static String getPF_Sub_Class_1(Package_Family__c pf)
	{			
		String subClassName = 'PF_Sub_Class_1__c';		
		Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(pf.Specific_RFQ_Item_Object__c).getDescribe().fields.getMap();
		Schema.SObjectField subClassField = objectFields.get(subClassName);
		if(subClassField != null){
			String subClass = (String)subClassField.getDescribe().getDefaultValueFormula();
			Integer startIndex = subClass.indexOf('"');
			Integer endIndex = (subClass.lastIndexOf('"') == -1) ? subClass.length() : subClass.lastIndexOf('"') ;
			return subClass.substring(startIndex+1, endIndex);			
		}
		return null;
	}

	private static String convertPfNameToRfqi(String pfName){
		String[] pfNameSplited = pfName.toUpperCase().split('\\s');
		String rfqiName = String.join(pfNameSplited, '_');
		return 'RFQI_' + rfqiName + '__c';
	}

	private void loadValues()
	{
		//oadValue(String pf, String fppRate, String RSSB, String pf_sub_class, String body_size, String unit_per_strip, String subs_number_per_col, String emcShot, String subs_cost_per_strip, String frame_finish){
		//load PMLF
		loadValue('Punch Single Row DFN', '', '', 'PMLF', '2.5', '0.0  ', '0.00', '21.6', '1.7', '');
		loadValue('Punch Single Row DFN', '', '', 'PMLF', '3  ', '396.0', '11.0', '21.6', '1.7', '');
		loadValue('Punch Single Row DFN', '', '', 'PMLF', '4  ', '300.0', '10.0', '21.6', '1.7', '');
		loadValue('Punch Single Row DFN', '', '', 'PMLF', '5  ', '224.0', '8.00', '21.6', '1.7', '');
		loadValue('Punch Single Row DFN', '', '', 'PMLF', '5.5', '192.0', '8.00', '18.0', '1.9', '');
		loadValue('Punch Single Row DFN', '', '', 'PMLF', '6  ', '168.0', '7.00', '18.0', '1.9', '');
		loadValue('Punch Single Row DFN', '', '', 'PMLF', '7  ', '120.0', '6.00', '30.6', '1.9', '');
		loadValue('Punch Single Row DFN', '', '', 'PMLF', '8  ', '120.0', '6.00', '27.6', '2.1', '');
		loadValue('Punch Single Row DFN', '', '', 'PMLF', '9  ', '90.0 ', '5.00', '27.6', '2.1', '');
		loadValue('Punch Single Row DFN', '', '', 'PMLF', '10 ', '80.0 ', '5.00', '27.6', '2.3', '');
		loadValue('Punch Single Row DFN', '', '', 'PMLF', '12 ', '56.0 ', '4.00', '21.6', '2.3', '');
		loadValue('Punch Single Row DFN', '', '', 'PMLF', '13 ', '52.0 ', '4.00', '21.6', '2.3', '');

		//load SMLF
		loadValue('Saw Single Row DFN', '', '', 'SMLF', '1.4 ', '3150.0', '', '', '', '');
		loadValue('Saw Single Row DFN', '', '', 'SMLF', '1.6 ', '3720.0', '', '', '', '');
		loadValue('Saw Single Row DFN', '', '', 'SMLF', '2   ', '2548.0', '', '', '', '');
		loadValue('Saw Single Row DFN', '', '', 'SMLF', '2.1 ', '2914.0', '', '', '', '');
		loadValue('Saw Single Row DFN', '', '', 'SMLF', '2.4 ', '1836.0', '', '', '', '');
		loadValue('Saw Single Row DFN', '', '', 'SMLF', '2.5 ', '1680.0', '', '', '', '');
		loadValue('Saw Single Row DFN', '', '', 'SMLF', '2.6 ', '2184.0', '', '', '', '');
		loadValue('Saw Single Row DFN', '', '', 'SMLF', '2.74', '1428.0', '', '', '', '');
		loadValue('Saw Single Row DFN', '', '', 'SMLF', '2.96', '1200.0', '', '', '', '');
		loadValue('Saw Single Row DFN', '', '', 'SMLF', '3   ', '1224.0', '', '', '', '');
		loadValue('Saw Single Row DFN', '', '', 'SMLF', '3.35', '960.0 ', '', '', '', '');
		loadValue('Saw Single Row DFN', '', '', 'SMLF', '4   ', '676.0 ', '', '', '', '');
		loadValue('Saw Single Row DFN', '', '', 'SMLF', '4.47', '572.0 ', '', '', '', '');
		loadValue('Saw Single Row DFN', '', '', 'SMLF', '4.74', '506.0 ', '', '', '', '');
		loadValue('Saw Single Row DFN', '', '', 'SMLF', '5   ', '462.0 ', '', '', '', '');
		loadValue('Saw Single Row DFN', '', '', 'SMLF', '5.3 ', '416.0 ', '', '', '', '');
		loadValue('Saw Single Row DFN', '', '', 'SMLF', '5.5 ', '396.0 ', '', '', '', '');
		loadValue('Saw Single Row DFN', '', '', 'SMLF', '6   ', '324.0 ', '', '', '', '');
		loadValue('Saw Single Row DFN', '', '', 'SMLF', '7   ', '240.0 ', '', '', '', '');
		loadValue('Saw Single Row DFN', '', '', 'SMLF', '7.1 ', '242.0 ', '', '', '', '');
		loadValue('Saw Single Row DFN', '', '', 'SMLF', '8   ', '182.0 ', '', '', '', '');
		loadValue('Saw Single Row DFN', '', '', 'SMLF', '9   ', '144.0 ', '', '', '', '');
		loadValue('Saw Single Row DFN', '', '', 'SMLF', '10  ', '110.0 ', '', '', '', '');
		loadValue('Saw Single Row DFN', '', '', 'SMLF', '11  ', '100.0 ', '', '', '', '');
		loadValue('Saw Single Row DFN', '', '', 'SMLF', '12  ', '72.0  ', '', '', '', '');
		loadValue('Saw Single Row DFN', '', '', 'SMLF', '12.1', '90.0  ', '', '', '', '');
		loadValue('Saw Single Row DFN', '', '', 'SMLF', '13  ', '64.0  ', '', '', '', '');

		loadValue('Saw Single Row DFN', '', '', 'SMLF', '', '', '', '', '2.31', 'Ag Plate');
		loadValue('Saw Single Row DFN', '', '', 'SMLF', '', '', '', '', '3.20', 'RuCu');
		loadValue('Saw Single Row DFN', '', '', 'SMLF', '', '', '', '', '3.93', 'PPF');
		
		insert valueList;
	}

	private void loadMargins()
	{
		marginList = new List<CM_Margin__c>();
		//AMK-2004 changed forecast and margins
		//loadMargin('199', '30');
		//loadMargin('201', '27');
		//loadMargin('501', '23');

		//loadMargin('399', '28');
		//loadMargin('401', '25');
		//loadMargin('751', '21');

		//loadMargin('499',  '25');
		//loadMargin('501',  '22');
		//loadMargin('1001', '18');

		loadMargin('100',  '30', '1 - 199');
		loadMargin('350',  '25', '200 - 499');
		loadMargin('625',  '23', '500 - 749');
		loadMargin('875',  '21', '750 - 1000');
		loadMargin('1001', '18', '> 1000'); 
		
		insert marginList;
	}
	
}