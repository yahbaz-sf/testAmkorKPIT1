/*************************************************************************
* 
* PURPOSE:  Helper class to map out fields for the product group installers 
*         
* CLASS: FieldBuilderHelper
* CREATED: 03/12/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Nathan Pilkington
* 
**************************************************************************/

public class FieldBuilderHelper {
		
		private String pfName;
		private Package_Family__c pf;
		private Map<String, RFQI_Section__c> sections;
		private Map<String, RFQI_Field_Def__c> fieldDefs;
		private List<RFQI_PF_Field_Def__c> pfFieldDefs;
		
		
		public FieldBuilderHelper(String packageFamilyName) {
			pf = [select Id, Name, Specific_RFQ_Item_Object__c, Product_Group__r.Name from Package_Family__c where Name =: packageFamilyName];
			
			if (pf == null) {
				throw new FieldBuilderHelperException('Could not find package family: ' + packageFamilyName);
			}
		
			sections = new Map<String, RFQI_Section__c>(); 
	        for(RFQI_Section__c section : [select Id,Name From RFQI_Section__c]) {
	        	sections.put(section.Name, section);
	        }
	        
	        if (sections.size() == 0) {
	        	throw new FieldBuilderHelperException('No sections!');
	        }
	        else {
	        	System.debug('### sections size is: ' + sections.size());
	        }
	        
	        fieldDefs = new Map<String, RFQI_Field_Def__c>(); 
	        for(RFQI_Field_Def__c fieldDef : [select Id,Name From RFQI_Field_Def__c]) {
	        	fieldDefs.put(fieldDef.Name, fieldDef);
	        }
	        
	        if (fieldDefs.size() == 0) {
	        	throw new FieldBuilderHelperException('No fieldDefs!');
	        }
	        else {
	        	System.debug('### fieldDefs size is: ' + fieldDefs.size());
	        }
			
			pfFieldDefs = new List<RFQI_PF_Field_Def__c>();
			
			pfName = packageFamilyName;
		}
		
		public String getPackageFamilyId() {
			return pf.Id;
		}
		
		public List<RFQI_PF_Field_Def__c> getPfFieldDefs() {
			return pfFieldDefs;
		}
		
		public void add(String sectionName, String fieldName, Integer sequence) {
			add(sectionName, fieldName, sequence, false);
		}
		
		public void add(String sectionName, String fieldName, Integer sequence, Boolean isCPNAttribute) {
			add(sectionName, fieldName, sequence, isCPNAttribute, false); 
		}
		
		public void addLotChargeField(String sectionName, String fieldName, Integer sequence, Boolean isCPNAttribute) {
			// Copy-pasta with apologies because all of the method overloads are getting crazy. Don't really need
			// All of the null checks because they will happen on the other methods in the installers
			RFQI_Section__c section = sections.get(sectionName);
			RFQI_Field_Def__c fieldDef = fieldDefs.get(fieldName);
			
			if (fieldDef == null) {
				throw new FieldBuilderHelperException('fieldDef is null: ' + fieldName);
			}

			String factoryValues = FactoryHelper.getFactoryMapStringForField(pf.Specific_RFQ_Item_Object__c, fieldName);
			Boolean controlsFactory = factoryValues != null;
			
			pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = section.Id, 
				                                    RFQI_Field_Def__c = fieldDef.Id,
				                                    Sequence__c = sequence,
				                                    Package_Family__c = pf.Id,
				                                    CPN_Attribute__c = isCpnAttribute,
				                                    Is_Lot_Charge__c = true,
				                                    Controls_Factory__c = controlsFactory,
				                                    Factory_Values__c = factoryValues
				                                    ));
		}
		
		public void add(String sectionName, String fieldName, Integer sequence, Boolean isCPNAttribute, Boolean isGen) {
			add(sectionName, fieldName, sequence, isCPNAttribute, isGen, false); 
		}
		
		public void add(String sectionName, String fieldName, Integer sequence, Boolean isCpnAttribute, Boolean isGen, Boolean Required) {
			add(sectionName, fieldName, sequence, isCPNAttribute, isGen, Required, false);
		}
		
		public void add(String sectionName, String fieldName, Integer sequence, Boolean isCpnAttribute, Boolean isGen, Boolean Required, Boolean defaultDriver) {
				add(sectionName, fieldName, sequence, isCPNAttribute, isGen, Required, defaultDriver, null);
		}

		public void add(String sectionName, String fieldName, Integer sequence, Boolean isCpnAttribute, Boolean isGen, Boolean Required, Boolean defaultDriver, String otherField) {
			add(sectionName, fieldName, sequence, isCPNAttribute, isGen, Required, defaultDriver, otherField, false);
		}

		//additional add() method for AMK-579: mark default drivers in PF field defs for MLF
		
		public void add(String sectionName, String fieldName, Integer sequence, Boolean isCpnAttribute, Boolean isGen, Boolean Required, Boolean defaultDriver, String otherField, Boolean manuallyEntered) {
			if (sections == null) {
				throw new FieldBuilderHelperException('Sections is null');
			}
			
			if (fieldDefs == null) {
				throw new FieldBuilderHelperException('FieldDefs is null');
			}
			
			if (pfFieldDefs == null) {
				throw new FieldBuilderHelperException('PFFieldDefs is null');
			}
			
			if (pf == null) {
				throw new FieldBuilderHelperException('Pf is null');
			}
			
			
			RFQI_Section__c section = sections.get(sectionName);
			RFQI_Field_Def__c fieldDef = fieldDefs.get(fieldName);
			
			if (section == null) {
				throw new FieldBuilderHelperException('Section is null: ' +sectionName);
			}
			
			if (fieldDef == null) {
				throw new FieldBuilderHelperException('fieldDef is null: ' + fieldName);
			}

			String factoryValues = FactoryHelper.getFactoryMapStringForField(pf.Specific_RFQ_Item_Object__c, fieldName);
			Boolean controlsFactory = factoryValues != null;
			
			pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = section.Id, 
				                                    RFQI_Field_Def__c = fieldDef.Id,
				                                    Sequence__c = sequence,
				                                    Package_Family__c = pf.Id,
				                                    CPN_Attribute__c = isCpnAttribute,
				                                    Generated__c = isGen,
				                                    Required__c = Required,
				                                    Default_Driver__c = defaultDriver,
				                                    Controls_Factory__c = controlsFactory,
				                                    Factory_Values__c = factoryValues,
				                                    Other_Field__c = otherField,
				                                    Is_Manual_entry__c = manuallyEntered
				                                    ));
		}
		
		
		public void insertFields() {
			try {
		    	insert pfFieldDefs;
			} catch(Exception e) {
				system.debug('Could not install ' + pfName + ' Package Family Field Definitions : ' + e);
			}
		}
		
    /**
    * This method is a helper method for installing the Package Families
    *
    * @param name Name of the Package Family
    * @param prodGroup linked Product Group
    * @param rfqItem API name for RFQ item
    * @param wireConfig API name for RFQ items wire config
    * @param dieConfig API name for RFQ item's die config
    * @param targetList list where the package family is getting added to
    */
    public static void addPf(string name, Product_Group__c prodGroup, String rfqItem, 
                                                                      String wireConfig, 
                                                                      String dieConfig, 
                                                                      String passiveConfig, 
                                                                      String insertionConfig, List<Package_Family__c> targetList) {

	Package_Family__c PDIP =  new Package_Family__c(Name=name,Product_Group__c = prodGroup.Id);
	PDIP.Specific_RFQ_Item_Object__c = rfqItem;
	PDIP.Specific_Wire_Configuration_Object__c = wireConfig;
	PDIP.Specific_Die_Configuration_Object__c = dieConfig;
	PDIP.Specific_Passive_Configuration_Object__c = passiveConfig;
	PDIP.Specific_Insertion_Configuration_Object__c = insertionConfig;
	PDIP.Allowed_Factories__c = FactoryHelper.getAllowedFactories(rfqItem);
	targetList.add(PDIP);
    }

    public static void addPf(string name, Product_Group__c prodGroup, String rfqItem, 
                                                                      String wireConfig, 
                                                                      String dieConfig, 
                                                                      String passiveConfig, 
                                                                      String insertionConfig, List<Package_Family__c> targetList, Boolean hasFactories) {
    	addPf(name, prodGroup, rfqItem, wireConfig, dieConfig, passiveConfig, insertionConfig, targetList, hasFactories, '');
    }
    public static void addPf(string name, Product_Group__c prodGroup, String rfqItem, 
                                                                      String wireConfig, 
                                                                      String dieConfig, 
                                                                      String passiveConfig, 
                                                                      String insertionConfig, List<Package_Family__c> targetList, Boolean hasFactories, String cmImp) {

	Package_Family__c PDIP =  new Package_Family__c(Name=name,Product_Group__c = prodGroup.Id);
	PDIP.Specific_RFQ_Item_Object__c = rfqItem;
	PDIP.Specific_Wire_Configuration_Object__c = wireConfig;
	PDIP.Specific_Die_Configuration_Object__c = dieConfig;
	PDIP.Specific_Passive_Configuration_Object__c = passiveConfig;
	PDIP.Specific_Insertion_Configuration_Object__c = insertionConfig;
	PDIP.Has_Factory_Field__c = hasFactories;
	PDIP.Allowed_Factories__c = FactoryHelper.getAllowedFactories(rfqItem);
	PDIP.Cost_Model_Implementation__c = cmImp;
	targetList.add(PDIP);
    }

    public static void addPf(string name, Product_Group__c prodGroup, string rfqItem, string wireConfig, string dieConfig, List<Package_Family__c> targetList) {
		addPf(name, prodGroup, rfqItem, wireConfig, dieConfig, targetList, false);
    }

    public static void addPf(string name, Product_Group__c prodGroup, string rfqItem, string wireConfig, string dieConfig, List<Package_Family__c> targetList, Boolean hasManualEntry) {
	Package_Family__c PDIP =  new Package_Family__c(Name=name,Product_Group__c = prodGroup.Id);
	PDIP.Specific_RFQ_Item_Object__c = rfqItem;
	PDIP.Specific_Wire_Configuration_Object__c = wireConfig;
	PDIP.Specific_Die_Configuration_Object__c = dieConfig;
	PDIP.Allowed_Factories__c = FactoryHelper.getAllowedFactories(rfqItem);
	PDIP.Has_Manual_Entry_Fields__c = hasManualEntry;
	targetList.add(PDIP);
    }

    public static void addDefaultChildConfigsNum(string packageFamilyName, Integer numWire, Integer numDie, Integer numPassive, Integer numInsertion) {
    	Package_Family__c pf = [select Id From Package_Family__c where Name=: packageFamilyName ];
    	pf.Default_Number_Of_Wires__c = numWire;
    	pf.Default_Number_Of_Die__c = numDie;
    	pf.Default_Number_Of_Passives__c = numPassive;
    	pf.Default_Number_Of_Insertions__c = numInsertion;
    	update pf;
    }
	/*
	*Theses are methods for installing/deleting product groups
	*
	*
	*/	
    public static void clean(string pg) {
	delete [select id from cm_pf_value__c where CM_Version__r.Product_Group__r.Name=: pg];
	List<Product_Group__c> prodGroup = [select Id from Product_Group__c where Name =: pg];
	delete prodGroup;
    }

    public static Product_Group__c installProductGroup(string pg) {
		return installProductGroup(pg, false, false, '');
    }

    public static Product_Group__c installProductGroup(string pg, string cmImp) {
		return installProductGroup(pg, false, false, cmImp);
    }

	public static Product_Group__c installProductGroup(string pg, Boolean Advanced, Boolean Service) {
		return installProductGroup(pg, Advanced, Service, '');
	}
    /**
    * This method installs Product group
    *
    * @returns a the installed Product Group
    */
		public static Product_Group__c installProductGroup(string pg, Boolean Advanced, Boolean Service, String cmImp) {

			Product_Group__c ProductGroup = new Product_Group__c(Name = pg, Advanced__c = Advanced, Service__c = Service);
			if (cmImp != '') ProductGroup.Cost_Model_Implementation__c = cmImp;
			try {
			    insert ProductGroup;
			}catch(Exception e) {
				system.debug('Could not install' + pg + ':' + e);
			}
			return ProductGroup;
		}


		
		/**
		*This method is a helper method for installing default drivers
		*
		*
		*/
		public static void installDefaultDrivers(Package_Family__c pf, RFQI_Field_Def__c driver, string driverVal, RFQI_Field_Def__c child, string childVal) {
			RFQI_Default_Driver__c dd = new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = driver.Id, Driver_Value__c = driverVal, Child__c = child.Id, Child_Value__c = childVal);
			insert dd; 
            
		}

		public static void installDefaultDrivers(Package_Family__c pf, RFQI_Field_Def__c driver, string driverVal, RFQI_Field_Def__c child, string childVal, List<RFQI_Default_Driver__c> drivers) {
			drivers.add( new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = driver.Id, Driver_Value__c = driverVal, Child__c = child.Id, Child_Value__c = childVal));      
		}

		public static void installDefaultDriversMath(Package_Family__c pf, RFQI_Field_Def__c driver, string driverVal, RFQI_Field_Def__c child){
			RFQI_Default_Driver__c dd = new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = driver.Id, Driver_Value__c = driverVal, Child__c = child.Id, Read__c = true);
			insert dd;
		}

		public static void installDefaultDriversMath(Package_Family__c pf, RFQI_Field_Def__c driver, string driverVal, RFQI_Field_Def__c child, List<RFQI_Default_Driver__c> drivers){
			drivers.add(new RFQI_Default_Driver__c(Package_Family__c = pf.Id, Driver__c = driver.Id, Driver_Value__c = driverVal, Child__c = child.Id, Read__c = true));
		}
		
		/**
		* This method deletes default drivers for a Product Group
		* @param Product Group name
		*/
		public static void deleteProductgroupDefaultDriver(string pg) {
			delete [select Id from RFQI_Default_Driver__c where Package_Family__r.Product_Group__r.Name =: pg ];
		}
		/**
		* This method deletes default drivers for a package family
		* @param package family name
		*/
		public static void deleteDefaultDriver(string pf) {
			delete [select Id from RFQI_Default_Driver__c where Package_Family__r.Name =: pf];
		}
		/**
		*Marking Package families in a product group as having no package family
		*/
		public static void markNoCostModels(string pg) {
			List<Package_Family__c> pf = [select Id from Package_Family__c where Product_Group__r.Name =: pg];

			for(Package_Family__c packageFamily : pf) {
				packageFamily.No_Cost_Model__c = true;
			}
			update pf;
		}

		public static void mapOldFieldToNewField() {
			// List<RFQ_Item__c> items = [select Id from RFQ_Item__c where Package_Family__r.Name =: packageFamily];
			// List<RFQItemWrapper> wrappers = new List<RFQItemWrapper>();
			// for(RFQ_Item__c item : items) {
			// 	wrappers.add(RFQItemDao.getInstance().getWrapperById(item.Id));
			// }

			// for(RFQItemWrapper wrapper : wrappers) {
			// 	String valueOfOldField = String.valueOf(wrapper.specificRfqItem.get(oldField));

			// 	if(newFieldType == 'String') {
			// 		wrapper.setAttribute(newField,'Package',valueOfOldField);
			// 	}
			// 	if(newFieldType == 'Decimal') {
			// 		wrapper.setAttribute(newField,'Package',Decimal.valueOf(valueOfOldField));
			// 	}
			// 	if(newFieldType == 'Boolean') {
			// 		wrapper.setAttribute(newField,'Package',Boolean.valueOf(valueOfOldField));
			// 	}
			// 	RFQItemDao.getInstance().saveLineItem(wrapper);
			// }

			List<sObject> oldfields = [select Substrate_Thickness__c, Substrate_Thickness_Other__c from RFQI_fcCSP__c];
			//List<sObject> newFields = [select Substrate_Thickness_Other__c from RFQI_fcCSP__c];

			for (sObject oldfield : oldfields){
				String field = String.valueOf(oldfield.get('Substrate_Thickness__c'));
				oldfield.put('Substrate_Thickness_Other__c', Decimal.valueOf(field));
			}
			update oldfields;
		}

		public static Map<String, RFQI_Section__c> getSectionMap() {
			Map<String, RFQI_Section__c> sections = new Map<String, RFQI_Section__c>(); 
	        for(RFQI_Section__c section : [select Id,Name From RFQI_Section__c]) {
	        	sections.put(section.Name, section);
	        }

	        return sections;
		}

		public static Map<string, RFQI_Field_Def__c> getFieldDefs() {
			Map<String, RFQI_Field_Def__c> fieldDefs = new Map<String, RFQI_Field_Def__c>(); 
	        for(RFQI_Field_Def__c fieldDef : [select Id,Name, Type__c From RFQI_Field_Def__c]) {
	        	fieldDefs.put(fieldDef.Name, fieldDef);
	        }
	        return fieldDefs;
		}

		public static void updateFactoryValues() {
		List<RFQI_PF_Field_Def__c> pfFields = [select Id, Package_Family__r.Specific_RFQ_Item_Object__c,Package_Family__r.Name, Object_API_Name__c, RFQI_Field_Def__r.Name from RFQI_PF_Field_Def__c];

        for (RFQI_PF_Field_Def__c field : pfFields ) {
            string factoryValues = FactoryHelper.getFactoryMapStringForField(field.Object_API_Name__c, field.RFQI_Field_Def__r.Name);
            field.Factory_Values__c = factoryValues;
        }

        update pfFields;
		}
		
	}