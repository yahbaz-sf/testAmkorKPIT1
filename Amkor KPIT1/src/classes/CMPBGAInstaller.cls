public class CMPBGAInstaller {

	public static String pgName {get; set;}
	public static String pgId  {get; set;}
	
	public static Product_Group__c pg {get; set;}
	public static CM_Version__c cmVersion {get; set;}
	
	public static Map<String, Package_Family__c> pfMap {get; set;}
	
	public static Map<String, RFQI_Field_Def__c> fieldMap {get; set;}
	static CMPBGAInstaller installer;
	
	

	public static void cleanAndInstall() 
	{
		clean();
		installer = new CMPBGAInstaller();		
		installer.installFCM(); 
	}
	
	public static void install() 
	{				
		installer = new CMPBGAInstaller();		
		installer.installFCM();
	}
	
	public static void clean() 
	{
		List<CM_Version__c> verList = [select id, Product_Group__r.Name from CM_Version__c where Product_Group__r.Name =: 'PBGA'];
		
		delete verList;

		
	}
	
	public void installFCM()
	{
		pgName = 'PBGA';
				
		setupInstaller();		
		pg.Au_Cost__c = 1690;
		update pg;
		
				
		fieldMap = new Map<String, RFQI_Field_Def__c>();
		List<RFQI_Field_Def__c> fieldList = [select id, name from RFQI_Field_Def__c];
		for(RFQI_Field_Def__c row : fieldList) fieldMap.put(row.name, row);
		
	}
	
	private void setupInstaller(){
		List<Product_Group__c> pgList = [select id, Au_Cost__c from Product_Group__c where name = :pgName];
		if (pgList != null && pgList.size() > 0)
		{
			pg = pgList[0];
		}
		else
		{
			pg = new Product_Group__c();
		}
		pgId = pg.id;
		
		cmVersion = new CM_Version__c(Product_Group__c=pgId, Status__c='Active', Version__c=1);
		cmVersion.Wire_Die_Thickness__c = 180;
		cmVersion.Wire_Loop_Height__c = 4;
		cmVersion.Wire_DA_Thickness__c = 0.9;
		cmVersion.Wire_Paddle_Down__c = 0;
		cmVersion.Wire_Ball_Ratio__c = 1.8;
		insert cmVersion;

		
		loadPfMap();


		CM_PF_Value__c pfValue;
        List<CM_PF_Value__c> pfValueList = new List<CM_PF_Value__c>();
        List<Package_Family__c> families = pfMap.values();
        
        for (Package_Family__c family : families)
        {
            pfValue = new CM_PF_Value__c(CM_Version__C=cmVersion.Id, Package_Family__c=family.Id, Subs_Markup_Perc__c=5, Base_Customer_Au_Price__c=1000, Assembly_GM_wo_Substrate__c=40);
            pfValueList.add(pfValue);
        }
        insert pfValueList;
	}
	
	private void loadPfMap()
	{		
		pfMap = new Map<String, Package_Family__c>();
		List<Package_Family__c> pfList = [Select id, name, Product_Group__c from Package_Family__c where Product_Group__c = :pgId];
		for(Package_Family__c row : pfList) pfMap.put(row.name, row);		
	}
}