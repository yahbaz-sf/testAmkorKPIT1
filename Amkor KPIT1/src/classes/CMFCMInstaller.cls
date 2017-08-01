/*************************************************************************
*
* PURPOSE: Base class for FCM Installers
*
* CLASS: CMFCMInstaller
* CREATED: 5/01/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
public abstract class CMFCMInstaller 
{
	public String pgName {get; set;} 
	public String pgId  {get; set;}
	
	public Product_Group__c pg {get; set;}
	public CM_Version__c cmVersion {get; set;}
	public CM_Margin_Version__c cmMarginVersion {get; set;}
	
	public Map<String, Package_Family__c> pfMap {get; set;}
	
	public List<FCM_BOM__c> bomList {get; set;}
	public Map<String, FCM_BOM__c> bomMap {get; set;}
	public Map<String, FCM_BOM__c> bomVariantMap {get; set;}
	
	public List<FCM_Process__c> procList {get; set;}
	public Map<String, FCM_Process__c> procMap {get; set;}
	public Map<String, FCM_Process__c> procVariantMap {get; set;}

	public List<CM_Margin__c> marginList {get; set;}

	public List<FCM_Match_Condition__c> matchList {get; set;}
	
	public List<CM_PF_Value__c> valueList {get; set;}
	
	public Map<String, RFQI_Field_Def__c> fieldMap {get; set;}
	public DebugUtils debug {get {return DebugUtils.getInstance();} }
	
	public void setupInstaller()
	{
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
		List<CM_Version__c> versionList = new List<CM_Version__c>();
		List<CM_Version__c> oldVersionList = [select Id, Version__c, Status__c from CM_Version__c where Product_Group__c=:pgId and Status__c='Active'];
		Decimal newVersionNumber = 1;
		if (oldVersionList.size() > 0)
		{ 
			CM_Version__c oldVersion = oldVersionList[0];
			oldVersion.Status__c = 'Archived';
			newVersionNumber = oldVersion.Version__c + 1;
			versionList.add(oldVersion);
		}
		
		cmVersion = new CM_Version__c(Product_Group__c=pgId, Status__c='Active', Version__c=newVersionNumber);
		cmVersion.Wire_Die_Thickness__c = 200;
		cmVersion.Wire_Loop_Height__c = 5;
		cmVersion.Wire_DA_Thickness__c = 1;
		cmVersion.Wire_Paddle_Down__c = 0;
		cmVersion.Wire_Ball_Ratio__c = 1.8;
		
		versionList.add(cmVersion);
		upsert versionList;

		List<CM_Margin_Version__c> marginVersionList = new List<CM_Margin_Version__c>();
		List<CM_Margin_Version__c> oldMarginVersionList = [select Id, Version__c, Status__c from CM_Margin_Version__c where Product_Group__c=:pgId and Status__c='Active'];
		newVersionNumber = 1;
		if (oldMarginVersionList.size() > 0)
		{ 
			CM_Margin_Version__c oldMarginVersion = oldMarginVersionList[0];
			oldMarginVersion.Status__c = 'Archived';
			newVersionNumber = oldMarginVersion.Version__c + 1;
			marginVersionList.add(oldMarginVersion);
		}
		cmMarginVersion = new CM_Margin_Version__c(Product_Group__c=pgId, Status__c='Active', Version__c=newVersionNumber);
		marginVersionList.add(cmMarginVersion);
		upsert marginVersionList;
		
		bomList = new List<FCM_BOM__c>();
		
		bomMap = new Map<String, FCM_BOM__c>();
		bomVariantMap = new Map<String, FCM_BOM__c>();
		
		procList = new List<FCM_Process__c>();
		
		procMap = new Map<String, FCM_Process__c>();
		procVariantMap = new Map<String, FCM_Process__c>();
		
		matchList = new List<FCM_Match_Condition__c>();
		
		valueList = new List<CM_PF_Value__c>();
		
		pfMap = new Map<String, Package_Family__c>();
	}
	
	public virtual void loadPfMap()
	{
		List<Package_Family__c> pfList = [Select id, name, Product_Group__c from Package_Family__c where Product_Group__c = :pgId];
		for(Package_Family__c row : pfList) pfMap.put(row.name, row);
	}
	
	public void postInstall()
	{
		CMBOMCalcBase.updateAllBomCalc();
		CMProcessCalcBase.updateAllProcessCalc();
	}
	
	public abstract void installFCM();
	
	//  a     b        c                        d        e          f                   g                    h                  i        j            k               l            m                 n            o                 p                  q            r                     s         t     u                      v                w                 x
	//NAME	UOM__C	DESCRIPTION__C	PARENT_BOM__R.NAME	SID__C	COST_PER_UNIT__C	USAGE_SCRAP_RATE__C	BASE_QUANTITY__C	COLUMN__C	MFG_COST__C	PURCHASE_PRICE__C	ROW__C	STANDARD_USAGE__C	STRIP_SUBLOT__C	TROY_OZ_COST__C	UNITS_PER_STRIP__C	USAGE_RATE__C	PRODUCT_GROUP__R.NAME	SEQUENCE__C	TYPE__C	PACKAGE_FAMILY__R.NAME	CATEGORY__C	FILTER_LEAD_COUNT__C	HAS_VARIANTS__C				
	//="loadBom('"&A2&"','"&T2&"','"&S2&"','"&R2&"','"&U2&"','"&V2&"','"&W2&"','"&X2&"','"&B2&"','"&C2&"','"&D2&"','"&E2&"','"&F2&"','"&G2&"','"&H2&"','"&I2&"','"&J2&"','"&K2&"','"&L2&"','"&M2&"','"&N2&"','"&O2&"','"&P2&"','"&Q2 &"');"	
	
	public void loadBom(String name, String typeVal,String seq, String pg,string pf, String catVal, String leadCount, String hasVariants, string uom, String decription, String parent, String sid, String costUnit, String usageScrap, String baseQty, String column, String mfgCost, String purchasePrice, String row, String stdUsage, String stripSublot, String troyOz, String groupName, String usageRate, String index, String timePerWire)
	{
		FCM_BOM__c rec = new FCM_BOM__c(CM_Version__c=cmVersion.id, Product_Group__c=pgId);
		rec.name = name;
		rec.Type__c = typeVal;
		if (seq != '') rec.Sequence__c = Double.valueOf(seq);
		rec.CM_Version__c = cmVersion.id;
		
		if (pf != '' && pg != 'Dual Leadframe')
		{
			Package_Family__c pfRef = pfMap.get(pf);
			if (pfRef != null) rec.Package_Family__c = pfRef.id;
		}
		
		rec.Category__c = catVal;
		if (parent != '')
		{
			FCM_BOM__c par = bomMap.get(parent);
			if (par != null)
			{
				 rec.Parent_BOM__c = par.id;
				 rec.Category__c = par.Category__c;
				 rec.Sequence__c = par.Sequence__c;
			}
		}
		if (hasVariants != '') rec.Has_Variants__c = hasVariants == 'TRUE';
		if (leadCount != '' && pg != 'Dual Leadframe') rec.Filter_Lead_Count__c = leadCount;		

		//---Override fields
		setFieldText(rec, 'UOM', uom);
		setFieldText(rec, 'Description', decription);
		setFieldText(rec, 'SID', sid);
		setFieldNumeric(rec, 'Cost_Per_Unit', costUnit);
		setFieldNumeric(rec, 'Usage_Rate', usageScrap);
		setFieldNumeric(rec, 'Column', column);
		setFieldNumeric(rec, 'Mfg_Cost', mfgCost);
		setFieldNumeric(rec, 'Purchase_Price', purchasePrice);
		setFieldNumeric(rec, 'Standard_Usage', stdUsage);
		setFieldNumeric(rec, 'Troy_Oz_Cost', troyOz);
		setFieldNumeric(rec, 'Usage_Rate', usageRate);
		setFieldNumeric(rec, 'Index', index);
		setFieldNumeric(rec, 'Time_Per_Wire', timePerWire);
		setFieldText(rec, 'Group', groupName);		
		
		bomList.add(rec);
	}
	
	public void setFieldText(SObject sObj, String fieldName, String value)
	{
		if (value != '')
		{
			sObj.put(fieldName + '__c', value);
			sObj.put(fieldName + '_OR__c', true);
		}
	}
	
	public void setFieldNumeric(SObject sObj, String fieldName, String value)
	{
		if (value != '')
		{
			sObj.put(fieldName + '__c', Double.valueOf(value));
			sObj.put(fieldName + '_OR__c', true);
		}
	}
	
	
	// a         b                       c                    d           e      f         g                             h             i          j                        k                    l      m            n                o              p         
	//NAME	EQUIPMENT_COST__C	FOOTPRINT_PER_MACHINE__C	INDEX__C	MMR__C	UPH__C	TIME_PER_WIRE__C	PRODUCT_GROUP__R.NAME	SEQUENCE__C	PACKAGE_FAMILY__R.NAME	PARENT_PROCESS__R.NAME	TYPE__C	CATEGORY__C	HAS_VARIANTS__C	EQUIPMENT__C	FILTER_LEAD_COUNT__C		GEN
	//="loadProc('" &   A2 & "','" & K2 & "','" &  L2 & "','" &M2 & "','" & N2 & "','" & H2 & "','" & B2 & "','" & C2 & "','" & D2 & "','" & E2 & "','" & F2 & "','" & G2 & "','" & I2 & "','" & J2 & "','" & O2 & "','" & P2          & "');"
	
	public void loadProc(String name, String parent, String typeVal, String catVal, String hasVariants, String pg, String equipCost, String footprint, String index, String mmr, String uph, String timeWire, String seq, String pf, String equipment, String leadCount)
	{
		loadProc(name, parent, typeVal, catVal, hasVariants, pg, equipCost, footprint, index, mmr, uph, timeWire, seq, pf, equipment, leadCount, '');
	}

	public void loadProc(String name, String parent, String typeVal, String catVal, String hasVariants, String pg, String equipCost, String footprint, String index, String mmr, String uph, String timeWire, String seq, String pf, String equipment, String leadCount, String uphExponent)
	{
		FCM_Process__c rec = new FCM_Process__c(CM_Version__c=cmVersion.id, Product_Group__c=pgId);
		rec.name = name;
		rec.Type__c = typeVal;
		if (seq != '') rec.Sequence__c = Double.valueOf(seq);
		rec.CM_Version__c = cmVersion.id;
			

		//removed so all dual prices using the soic150 cost model
		if (pf != '' && pg != 'Dual Leadframe')
		{
			Package_Family__c pfRef = pfMap.get(pf);
			if (pfRef != null) rec.Package_Family__c = pfRef.id;
		}

		rec.Category__c = catVal;
		if (parent != '')
		{
			FCM_Process__c par = procMap.get(parent);
			if (par != null) 
			{
				rec.Parent_Process__c = par.id;
				rec.Category__c = par.Category__c;
				rec.Sequence__c = par.Sequence__c;
			}
		}
		if (hasVariants != '') rec.Has_Variants__c = hasVariants == 'TRUE';
		
		//removed so all dual prices using the 8ld cost model
		if (leadCount != '' && pg != 'Dual Leadframe') rec.Filter_Lead_Count__c = leadCount;

		//---Override fields
		setFieldText(rec, 'Equipment', equipment);
		setFieldNumeric(rec, 'Equipment_Cost', equipCost);
		setFieldNumeric(rec, 'Footprint_Per_Machine', footprint);
		setFieldNumeric(rec, 'Index', index);
		setFieldNumeric(rec, 'MMR', mmr);
		setFieldNumeric(rec, 'Time_Per_Wire', timeWire);
		setFieldNumeric(rec, 'UPH', uph);
		setFieldNumeric(rec, 'UPH_Exponent', uphExponent);
		
		procList.add(rec);
	}
	
	//OPERAND__C	RFQI_FIELD_DEF__R.NAME	MATCH_TYPE__C	FCM_BOM__R.NAME	FCM_PROCESS__R.NAME	TEXT_VALUE__C	BOOLEAN_VALUE__C							 		
	//="loadMatch('" &   D2 & "','" & E2 & "','" &  C2 & "','" & A2 & "','" & B2 & "','" & F2 & "','" & G2 & "');"
	public void loadMatch( String bomName, String procName, String matchType, String operand, String fieldName, String textVal, String boolVal)
	{
		loadMatch( bomName, procName, matchType, operand, fieldName, textVal, boolVal, '');
	}
	
	public void loadMatch( String bomName, String procName, String matchType, String operand, String fieldName, String textVal, String boolVal, String numericVal)
	{
		FCM_Match_Condition__c rec = new FCM_Match_Condition__c();
		
		if (bomName != '') 
		{
			FCM_BOM__c bom = bomMap.get(bomName);
			if (bom == null)
			{
				bom = bomVariantMap.get(bomName);
				if (bom == null)
				{
					DebugUtils.getInstance().log('Cannot find Variant BOM', bomName);
				}
				else
				{
					 rec.FCM_BOM__c = bom.id;
				}
			}
			else
			{
				rec.FCM_BOM__c = bom.id;
			}
		}
		if (procName != '') 
		{
			FCM_Process__c proc = procMap.get(procName);
			if (proc == null)
			{
				proc = procVariantMap.get(procName);
				if (proc == null)
				{
					DebugUtils.getInstance().log('Cannot find Variant Proc', procName);
				}
				else
				{
					rec.FCM_Process__c = proc.id;
				}
			}
			else
			{
				rec.FCM_Process__c = proc.id;
			}
		}
		
		if (fieldName != '') 
		{
			RFQI_Field_Def__c fld = fieldMap.get(fieldName);
			if (fld != null) rec.RFQI_Field_Def__c = fld.id;
		}
		
		if (matchType != '') rec.Match_Type__c = matchType;
		if (operand != '') rec.Operand__c = operand;
		if (textVal != '') rec.Text_Value__c = textVal;
		if (boolVal != '') rec.Boolean_Value__c = boolVal == 'TRUE';
		if (numericVal != '') rec.Numeric_Value__c = Double.valueOf(numericVal);
		
		matchList.add(rec);
	}
	
	public void loadValue(String pf, String fppRate, String RSSB)
	{
		
		loadValue(pf, fppRate, RSSB, '', '', '', '', '', '', '');
	}

	//This one is specific for MLF
	public void loadValue(String pf, String fppRate, String RSSB, String pf_sub_class, String body_size, String unit_per_strip, String subs_number_per_col, String emcShot, String subs_cost_per_strip, String frame_finish){

		CM_PF_Value__c rec = new CM_PF_value__c(CM_Version__c=cmVersion.id);
		Package_Family__c pfRef = pfMap.get(pf);
		if (pfRef != null) rec.Package_Family__c = pfRef.id;
		
		if (fppRate != '') rec.FPP_Rate__c = Double.valueOf(fppRate);
		if (RSSB != '') rec.RSSB__c = Double.valueOf(RSSB);

		if (pf_sub_class != null) rec.PF_Sub_Class_1__c = pf_sub_class;
		if (body_size != '') rec.Body_Size__c = Double.valueOf(body_size);
		if (unit_per_strip != '') rec.Unit_Per_Strip__c = Double.valueOf(unit_per_strip);
		if (subs_number_per_col != '') rec.Subs_Number_Per_Column__c = Double.valueOf(subs_number_per_col);
		if (emcShot != '') rec.EMC_Shot__c = Double.valueOf(emcShot);
		if (subs_cost_per_strip != '') rec.Subs_Cost_Per_Strip__c = Double.valueOf(subs_cost_per_strip);
		if (frame_finish != null) rec.Frame_Finish__c = frame_finish;

		valueList.add(rec);

	}

	public void loadMargin(String volume_floor, String margin)
	{
		loadMargin(volume_floor, margin, '');
	}

	public void loadMargin(String volume_floor, String margin, String name)
	{
		CM_Margin__c rec = new CM_Margin__c(CM_Margin_Version__c = cmMarginVersion.id);
		if (margin != '') rec.Margin__c = Double.valueOf(margin);
		if (volume_floor != '') rec.Volume_Floor__c = Double.valueOf(volume_floor);
		if (name != '') rec.Name = name;

		marginList.add(rec);

	}
	public void clean(String pg)
	{
		
		List<CM_Version__c> verList = [select id, Product_Group__r.Name from CM_Version__c where Product_Group__r.Name =: pg];
		
		
		for(CM_Version__c ver : verList )
		{		

			matchList = FCMMatchConditionDao.getInstance().getAllByBomVersion(ver.id);
			matchList.addAll(FCMMatchConditionDao.getInstance().getAllByProcessVersion(ver.id));
			delete matchList;					

		}

		delete verList;

		List<CM_Margin_Version__c> marginVerList = [select id, Product_Group__r.Name from CM_Margin_Version__c where Product_Group__r.Name =: pg];	
		delete marginVerList;


	}

	public void cleanAll()
	{
		matchList = [select id from FCM_Match_Condition__c];
		delete matchList;
		
		bomList = [select id from FCM_BOM__c];
		delete bomList;
		
		procList = [select id from FCM_Process__c];
		delete procList;	
		
		List<FCM_Assumption__c> assumptionList = [Select id from FCM_Assumption__c];
		delete assumptionList;
		
		List<CM_Version__c> verList = [select id from CM_Version__c];
		delete verList;

		List<CM_Margin_Version__c> mVerList = [select id from CM_Margin_Version__c];
		delete mVerList;
	}

	public static void updateProcs()
	{
		List<RFQI_Process__c> rfqiProcess = [SELECT Id, Name, Category__c, RFQI_FCM__r.RFQ_Item__r.Product_Group_Name__c from RFQI_Process__c];
		List<FCM_Process__c> fcmProcess = [SELECT Id, Name, CM_Version__c, Category__c, CM_Version__r.Name, CM_Version__r.Product_Group__c, CM_Version__r.Product_Group__r.Name from FCM_Process__c WHERE CM_Version__r.Status__c='Active' ];

		Map<String, Map<String, String>> fcmCategoryMap = new Map<String, Map<String, String>>();

		for (FCM_Process__c row : fcmProcess)
		{
			if (fcmCategoryMap.get(row.CM_Version__r.Product_Group__r.Name) == null) fcmCategoryMap.put(row.CM_Version__r.Product_Group__r.Name, new Map<String, String>());

			fcmCategoryMap.get(row.CM_Version__r.Product_Group__r.Name).put(row.Name, row.Category__c);
		}

		for (RFQI_Process__c row : rfqiProcess)
		{

			row.Category__c = fcmCategoryMap.get(row.RFQI_FCM__r.RFQ_Item__r.Product_Group_Name__c).get(row.Name);
		}

		update rfqiProcess;
	}
}