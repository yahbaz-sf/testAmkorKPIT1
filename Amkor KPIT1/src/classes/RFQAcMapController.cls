public virtual with sharing class RFQAcMapController extends BaseController {
	
	// The master parent object	
	public RFQ_Ac_Map__c accountMap { get; set; }
	
	// What columns are on the spreadsheet
	public List<AccountMapColumnHolder> accountMapColumns { get; set; }
	

	// The Package Family cost attribute mappings
	public List<PfMappingHolder> pfMappings { get; set; }
	
	public List<AccountMapColumnHolder> removedAccountMapColumns { get; set; }
	
	public List<PfMappingHolder> removedPfMappings { get; set; }
	

	// Reference objects
	public List<Product_Group__c> productGroups { get; set; }
	public List<Package_Family__c> packageFamilies { get; set; }

	public Map<Id,Package_Family__c> packageFamilyMap { get; set; }
	
	public static Map<String, List<FieldHolder>> packageFamilyFields { get; set; }
	public static Map<String, String> fieldLabels { get; set; }

	public String oldFileMapName { get; set; }
	
	
	public RFQAcMapController(ApexPages.StandardController controller) {
		
		// Set up reference objects
		productGroups = ProductGroupDao.getInstance().getAllProductGroups();
		packageFamilies = PackageFamilyDao.getInstance().getAllPackageFamilies();

		packageFamilyMap = new Map<Id,Package_Family__c>(packageFamilies);
		
		removedAccountMapColumns = new List<AccountMapColumnHolder>();
		removedPfMappings = new List<PfMappingHolder>(); 
		
		// Get the parent mapping object
		accountMap = (RFQ_Ac_Map__c)controller.getRecord();
		
		pfMappings = new List<PfMappingHolder>(); 
		accountMapColumns = new List<AccountMapColumnHolder>();
		
		if (StringUtils.isBlank(accountMap.Id)) {
			// If we are creating a new record, set up the initial values
			accountMap.Version__c = 1;
			pfMappings.add(new PfMappingHolder(new RFQ_Ac_Map_Pf__c(), new List<PfFieldMappingHolder>(), packageFamilies));
		}
		else {
			// Re-query so we can be sure we have all the fields
			accountMap = AccountFileMapDao.getInstance().getMapById(accountMap.Id);

			oldFileMapName = accountMap.Name;

			// Get the existing child records for this mapping object
			
			List<RFQ_Ac_Map_Column__c> columns = AccountFileMapDao.getInstance().getMapColumnsByMapId(accountMap.Id);
			
			for (RFQ_Ac_Map_Column__c row : columns) {
				accountMapColumns.add(new AccountMapColumnHolder(row));
			} 
			
			
			List<RFQ_Ac_Map_Pf__c> pfMaps = AccountFileMapDao.getInstance().getPfMapsByMapId(accountMap.Id);
			
			for (RFQ_Ac_Map_Pf__c row : pfMaps) {
				List<RFQ_Ac_Map_Pf_Column__c> children = AccountFileMapDao.getInstance().getPfFieldMapsByParentId(row.Id);
				
				List<PfFieldMappingHolder> childrenHolders = new List<PfFieldMappingHolder>();
				
				for (RFQ_Ac_Map_Pf_Column__c fieldRow : children) {
					childrenHolders.add(new PfFieldMappingHolder(fieldRow, (fieldRow.RFQI_PF_Field_Def__r.Required__c && !fieldRow.RFQI_PF_Field_Def__r.Not_Required_on_Import__c)));
				}
				
				pfMappings.add(new PfMappingHolder(row, childrenHolders, packageFamilies));
			}
		}
	}
	
	public PageReference editMap() {
		return new PageReference('/' + accountMap.Id + '/e?retUrl=%2F' + accountMap.Id);
	}
	
	public PageReference returnToAccount() {
		return new PageReference('/' + accountMap.Account__c);
	}
	
	public static List<FieldHolder> getFieldsForPackageFamily(String pfId) {
		if (packageFamilyFields == null) packageFamilyFields = new Map<String, List<FieldHolder>>();
		if (fieldLabels == null) fieldLabels = new Map<String, String>();

		if (!packageFamilyFields.containsKey(pfId)) {
			// TODO Don't hardcode excluded sections
			List<String> excludedSections = new List<String> { 'BU Header', 'Cost and Price' };
			
			// Get PF ref obj and fields for that PF
			Package_Family__c packageFamily = PackageFamilyDao.getInstance().getById(pfId);
			List<RFQI_PF_Field_Def__c> fieldDefs = [Select Id, RFQI_Field_Def__r.Name, RFQI_Field_Def__r.Object__c, RFQI_Section__r.Name, Required__c
													from RFQI_PF_Field_Def__c 
													where Package_Family__c = :pfId and RFQI_Section__r.Name not in :excludedSections
													order by RFQI_Field_Def__r.Name];
			
			
			// See if we've already got the field labels for each field, if not then get them
			Boolean needsMainDescribe = false;
			Boolean needsWireDescribe = false;
			Boolean needsDieDescribe = false;
			Boolean needsPassiveDescribe = false;
			Boolean needsInsertionDescribe = false;
			
			for (RFQI_PF_Field_Def__c fieldRow : fieldDefs) {
				String fieldName = fieldRow.RFQI_Field_Def__r.Name;
				
				if (!fieldLabels.containsKey(fieldName) && !StringUtils.contains(fieldName, '__r')) {
					String objectType = fieldRow.RFQI_Field_Def__r.Object__c;
					
					if (StringUtils.isMatch(objectType, RFQItemWrapper.DIE_OBJECT)) needsDieDescribe = true;
					else if (StringUtils.isMatch(objectType, RFQItemWrapper.WIRE_OBJECT)) needsWireDescribe = true;
					else if (StringUtils.isMatch(objectType, RFQItemWrapper.PASSIVE_OBJECT)) needsPassiveDescribe = true;
					else if (StringUtils.isMatch(objectType, RFQItemWrapper.INSERTION_OBJECT)) needsInsertionDescribe = true;
					else needsMainDescribe = true;
				}
			}
			

			if (needsMainDescribe) {
				addFieldLabelsForObject(packageFamily.Specific_RFQ_Item_Object__c);
			}
			
			if (needsWireDescribe) {
				addFieldLabelsForObject(packageFamily.Specific_Wire_Configuration_Object__c);
			}
			
			if (needsDieDescribe) {
				addFieldLabelsForObject(packageFamily.Specific_Die_Configuration_Object__c);
			}

			if (needsInsertionDescribe) {
				addFieldLabelsForObject(packageFamily.Specific_Insertion_Configuration_Object__c);
			}

			if (needsPassiveDescribe) {
				addFieldLabelsForObject(packageFamily.Specific_Passive_Configuration_Object__c);
			}
			 
			
			
			// Build the list of results
			
			List<FieldHolder> results = new List<FieldHolder>();
			
			for (RFQI_PF_Field_Def__c fieldDef : fieldDefs) {
				String fieldName = fieldDef.RFQI_Field_Def__r.Name;
				if (fieldName == null) fieldName = '';
				String label = fieldLabels.get(fieldName.toLowerCase());
				Boolean isRequired = fieldDef.Required__c;

				// Label might be null if current user does not have access
				if (!StringUtils.contains(fieldName, '__r') && label != null) {

					results.add(new FieldHolder(fieldDef.Id, fieldName, label, isRequired));						
				}
			}
			
			packageFamilyFields.put(pfId, results);
		}
		
		return packageFamilyFields.get(pfId);
	}
	
	private static void addFieldLabelsForObject(String objectName) {
		if (!StringUtils.isBlank(objectName)) {
			Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
		
			for (String fieldName : objectFields.keySet()) {
				// If we haven't already cached the field label, and it is not a relationship field, then add it
				fieldName = fieldName.toLowerCase();
				
				if (!fieldLabels.containsKey(fieldName) && !StringUtils.contains(fieldName, '__r')) {
					Schema.SObjectField field = objectFields.get(fieldName);
					Schema.DescribeFieldResult fieldInfo = field.getDescribe();

					// If user does not have access to field, then just store null so we won't re-describe it later on
					if (fieldInfo.isAccessible()) fieldLabels.put(fieldInfo.getName().toLowerCase(), fieldInfo.getLabel());
					else fieldLabels.put(fieldInfo.getName().toLowerCase(), null);
				}
			}
		}
	}
	
	/*****************************************
	 * Holder classes for UI components
	 *****************************************/

	public virtual class BaseSelectableHolder {
		public Boolean selected { get; set; }
	}
	
	
	/**
	 * FieldHolder allows us to easily store a field's information (including label) in one place
	 */
	public class FieldHolder {
		
		public Id fieldId { get; set; }
		public String fieldName { get; set; }
		public String fieldLabel { get; set; }
		public Boolean isRequired { get; set; }
		
		public FieldHolder(Id fieldId, String fieldName, String fieldLabel, Boolean isRequired) {
			this.fieldId = fieldId;
			this.fieldName = fieldName;
			this.fieldLabel = fieldLabel;
			this.isRequired = isRequired;
		}
		
	}
	
	/** 
    * This is a holder class for the RFQ_Ac_Map_Column__c objects
    */
	public class AccountMapColumnHolder extends BaseSelectableHolder {
		
		public RFQ_Ac_Map_Column__c accountMapColumn { get; set; }
		
		public AccountMapColumnHolder(RFQ_Ac_Map_Column__c column) {
			accountMapColumn = column;
		}
		
	}

	/**
    * This is a holder class for the RFQ_Ac_Map_Pf__c objects
    */
	public class PfMappingHolder extends BaseSelectableHolder {
			// The actual package family mapping object
			public RFQ_Ac_Map_Pf__c pfMap { get; set; }

			// The child list of cost attribute to file columns
			public List<PfFieldMappingHolder> fieldMaps { get; set; }

			// Reference objects for the dropdowns
			public List<Package_Family__c> availablePackageFamilies { get; set; }

			// Unique GUID so we can get a handle on it even when it hasn't been inserted yet
			public String uniqueId { get; set; }

			/**
		    * The constructor method accepts:
		    * @param obj The RFQ_Ac_Map_Pf__c that this will be a holder for
		    * @param pfFields The child RFQ_Ac_Map_Pf_Column__c records for this PF Mapping
		    * @param availablePf a list of all package families in the system (will be filtered when a group is selected)
		    */
			public PfMappingHolder(RFQ_Ac_Map_Pf__c obj, List<PfFieldMappingHolder> pfFields, List<Package_Family__c> availablePf) {
				pfMap = obj;
				availablePackageFamilies = availablePf;
				fieldMaps = pfFields;
				uniqueId = StringUtils.newGuid();
			}

			/**
		    * This method returns which package families are available based on which product group is selected
		    */
			public List<SelectOption> getSelectablePackageFamilies() {
				List<SelectOption> options = new List<SelectOption>();
				List<Package_Family__c> packageFamilies = new List<Package_Family__c>();

				for (Package_Family__c availablePf : availablePackageFamilies) {
					if (availablePf.Product_Group__c == pfMap.Product_Group__c) {
						packageFamilies.add(availablePf);
					}
				}

				options.add(new SelectOption('','-- None Selected --'));

				for (Package_Family__c packageFamily : packageFamilies) {
					options.add(new SelectOption(packageFamily.Id,packageFamily.Name));
				}

				return options;
			}

			/**
		    * This method returns a list of fields for the currently selected package family
		    */
			public List<SelectOption> getSelectableFields() {
				List<SelectOption> options = new List<SelectOption>();

				if (!StringUtils.isBlank(pfMap.Package_Family__c)) {

					options.add(new SelectOption('', '-- Select --'));

					for (FieldHolder fieldHolder : getFieldsForPackageFamily(pfMap.Package_Family__c)) {
						ID fieldId = fieldHolder.fieldId;
						String fieldLabel = fieldHolder.fieldLabel;

						if (fieldHolder.isRequired) {
							fieldLabel += ' (Required)';
						}
						
						options.add(new SelectOption(fieldId, fieldLabel));
					}
				}

				return options;
			}

			/**
		    * Adds a new field mapping object
		    */
			public PageReference addFieldMapping() {
				fieldMaps.add(new PfFieldMappingHolder(new RFQ_Ac_Map_Pf_Column__c()));
				return null;				
			}

			/**
		    * Removes all selected field mapping objects
		    */
			public PageReference removeFieldMappings() {
				for (Integer i = fieldMaps.size() - 1; i >= 0; i--) {
					if (fieldMaps[i].selected != null && fieldMaps[i].selected) {
						fieldMaps.remove(i);
					}
				}

				return null;
			}

	}

	/**
    * This is a holder class for the RFQ_Ac_Map_Pf_Column__c objects
    */
	public class PfFieldMappingHolder extends BaseSelectableHolder {

		public Boolean autoAdded { get; set; }
		public RFQ_Ac_Map_Pf_Column__c pfColumn { get; set; }

		public PfFieldMappingHolder(RFQ_Ac_Map_Pf_Column__c obj) {
			this(obj, false);
		}

		public PfFieldMappingHolder(RFQ_Ac_Map_Pf_Column__c obj, Boolean isAutoAdded) {
			autoAdded = isAutoAdded;
			pfColumn = obj;
		}

		public Boolean getIsChildObject() {
			String objectType = pfColumn.RFQI_PF_Field_Def__r.RFQI_Field_Def__r.Object__c;
			return (objectType == RFQItemWrapper.WIRE_OBJECT || 
				    objectType == RFQItemWrapper.DIE_OBJECT || 
				    objectType == RFQItemWrapper.INSERTION_OBJECT || 
				    objectType == RFQItemWrapper.PASSIVE_OBJECT);
		}

		public String getFriendlyName() {
			if (pfColumn.RFQI_PF_Field_Def__c == null || pfColumn.RFQI_PF_Field_Def__r.RFQI_Field_Def__r.Name == null) {
				// Fix for AMK-1657, if PF Field def deleted it was causing the screen to throw a null error
				return 'UNKNOWN';
			}

			String label = FieldLabelHelper.getInstance().getLabel(pfColumn.RFQI_PF_Field_Def__r.Object_API_Name__c, pfColumn.RFQI_PF_Field_Def__r.RFQI_Field_Def__r.Name);
			return label;
		}

	}

}