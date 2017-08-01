/*************************************************************************
*
* PURPOSE: Controller for the create/edit wizard for account import mapings
*
* CLASS: RFQAcMapEditController
* CREATED: 3/06/2012 Ethos Solutions - www.ethos.com 
* AUTHOR: Nathan Pilkington
***************************************************************************/

public with sharing class RFQAcMapEditController extends RFQAcMapController { 

	public String fileName { get; set; }
	public Blob fileContent { get; set; }

	public Integer currentStep { get; set; }

	public Boolean shouldShowControls { get; set; }
	
	public RFQAcMapEditController(ApexPages.StandardController controller) {
		super(controller);

		shouldShowControls = true;

		String rtId = AccountFileMapDao.getInstance().getInactiveRtId();
		if (accountMap.RecordTypeId == rtId) {
			addError('Sorry, you may not edit inactive (historical) mappings. Please locate the most recent version of this mapping in order to edit it');
			shouldShowControls = false;
		}
		
		currentStep = 1;
		
	}
	
	public Integer getFinalStep() {
		return 3;
	}
	
	public Boolean getAllowDraftSave() {
		if (String.isBlank(accountMap.Id)) return true;
		
		String draftRtId = [Select Id from RecordType where DeveloperName = 'Draft' and SobjectType = 'RFQ_Ac_Map__c'].Id;
		
		return draftRtId.equals(accountMap.RecordTypeId);
	}

	/*****************************************
	 * Step 1 Methods
	 *****************************************/

	/**
    * This method adds a blank column to the spreadsheet columns list
    */	
	public PageReference addAccountColumn() {
		
		accountMapColumns.add(new AccountMapColumnHolder(new RFQ_Ac_Map_Column__c()));
		
		return null;
	}
	
	/**
    * This method removes all selected columns from the spreadsheet columns list
    */
	public PageReference removeSelectedColumns() {
		
		for (Integer i = accountMapColumns.size() - 1; i >= 0; i--) {
			if (accountMapColumns[i].selected) {
				if (!StringUtils.isBlank(accountMapColumns[i].accountMapColumn.Id)) {
					removedAccountMapColumns.add(accountMapColumns[i]);
				}
				
				accountMapColumns.remove(i);
			}
		}
		
		return null;
		
	}


	/*****************************************
	 * Step 3 Methods
	 *****************************************/


	public PageReference addPfMapping() {
		pfMappings.add(new PfMappingHolder(new RFQ_Ac_Map_Pf__c(), new List<PfFieldMappingHolder>(), packageFamilies));

		return null;
	}

	public PageReference removeLastPfMapping() {
		if (pfMappings.size() > 1) {
			Integer lastIndex = pfMappings.size() - 1;

			if (!StringUtils.isBlank(pfMappings[lastIndex].pfMap.Id)) {
				removedPfMappings.add(pfMappings[lastIndex]);
			}

			pfMappings.remove(lastIndex);
		}

		return null;
	}

	public PageReference mappingPackageFamilyChanged() {
		String itemId = PageUtil.getParam('uniqueId');

		PfMappingHolder mapping = null;
		for (PfMappingHolder row : pfMappings) {
			if (StringUtils.isMatch(row.uniqueId, itemId)) mapping = row;
		}

		Id packageFamilyId = mapping.pfMap.Package_Family__c;

		mapping.fieldMaps.clear();

		List<RFQI_PF_Field_Def__c> requiredFields = PFFieldDefDao.getInstance().getRequiredFieldsForPackageFamily(packageFamilyId);

		if (requiredFields != null && requiredFields.size() > 0) {
			// Add required fields as options
			for (RFQI_PF_Field_Def__c field : requiredFields) {
				String section = field.RFQI_Section__r.Name;
				if (!field.Not_Required_on_Import__c && !StringUtils.isMatch(section, 'Cost and Price')) {
					PfFieldMappingHolder holder = new PfFieldMappingHolder(new RFQ_Ac_Map_Pf_Column__c(RFQI_PF_Field_Def__c=field.Id));
					holder.autoAdded = true;
					mapping.fieldMaps.add(holder);
				}
			}
		}

		return null;
	}


	/*****************************************
	 * Wizard button methods
	 *****************************************/

	/**
    * This method returns the user to the previous step
    */
	public PageReference previousStep() {
		
		if (currentStep > 1) currentStep--;

		return null;
	}

	/**
    * This method validates all values for the current step,
    * and if all values are valid takes the user to the next step
    */
	public PageReference nextStep() {
		Boolean isValid = true;

		if (currentStep == 1) {
			isValid = validateStep1();	
		}
		else if (currentStep == 2) {
			isValid = validateStep2();
		}

		if (isValid) {
			currentStep++;
		}

		return null;
	}

	/**
    * Makes sure that the user has entered a file map name and some columns
    */
	private Boolean validateStep1() {
		Boolean isValid = true;

		if (StringUtils.isBlank(accountMap.Name)) {
				addError('Please enter a name for the account file map.');
				isValid = false;
			}

			if (accountMapColumns.size() == 0 && fileContent == null) {
				addError('Please enter at least one column or upload an example CSV.');
				isValid = false;
			}
			else if (fileContent != null) {
				if (accountMapColumns != null) accountMapColumns.clear();
				
				String fileContentString = fileContent.toString().replaceAll('\r\n', '\n');
				System.debug('### FileContentString: ' + fileContentString);
				
				CsvParser parser = new CsvParser(fileContentString);

				if (parser.getTotalLines() < 1) {
					addError('The CSV file must have at least one header line');
					return false;
				}
				
				List<List<String>> fileLines;
				
				try {
					fileLines = parser.parse(0, 0, false);
				} catch (Exception e) {
					addError('The file supplied is not in a valid CSV format');
					return false;
				}

				List<String> columnHeaders = fileLines[0];

				for (String columnHeader : columnHeaders) {
					accountMapColumns.add(new AccountMapColumnHolder(new RFQ_Ac_Map_Column__c(Name=columnHeader)));
				}
			}
			else {
				for (Integer i = 0; i < accountMapColumns.size() && isValid; i++) {
					if (StringUtils.isBlank(accountMapColumns[i].accountMapColumn.Name)) {
						addError('Please enter a name for all of the columns.');
						isValid = false;
					}
				}
			}

		return isValid;
	}

	/**
    * Makes sure that the user selects a device name column
    */
	private Boolean validateStep2() {
		Boolean isValid = true;

		if (StringUtils.isBlank(accountMap.Device_Name_Column__c)) {
				addError('Please select a device name column.');
				isValid = false;
		}

		return isValid;
	}

	/**
    * Makes sure that the user enters in values for all of the PF mappings
    */
	private Boolean validateStep3() {
		Boolean isValid = true;

		Boolean missingMappingColumns = false;

		for (Integer i = 0; i < pfMappings.size() && isValid; i++) {
				PfMappingHolder holder = pfMappings[i];
				RFQ_Ac_Map_Pf__c pfMap = holder.pfMap;

				if (holder.fieldMaps.size() == 0) {
					addError('Please specify at least one column to cost attribute mapping for all package family mappings');
					isValid = false;
					System.debug(LoggingLevel.INFO, '### Save mapping invalid due to no field maps');
				}
				else {
					for (PfFieldMappingHolder fieldMap : holder.fieldMaps) {
						String fieldMapColumn = fieldMap.pfColumn.RFQ_Ac_Map_Column__c;
						String fieldMapCostAttribute = fieldMap.pfColumn.RFQI_PF_Field_Def__c;

						if (StringUtils.isBlank(fieldMapColumn) || StringUtils.isBlank(fieldMapCostAttribute)) {
							isValid = false;
							missingMappingColumns = true;
						}
					}
				}

				if (StringUtils.isBlank(pfMap.Account_Device_Name__c) || StringUtils.isBlank(pfMap.Package_Family__c) || StringUtils.isBlank(pfMap.Product_Group__c)) {
					addError('Please fill in all fields for each package family mapping.');
					isValid = false;
					System.debug(LoggingLevel.INFO, '### Save mapping not valid due to not all fields filled in');
				}
		}

		if (missingMappingColumns) {
			addError('Please select a spreadsheet column and cost attribute for each cost attribute mapping');
		}

		return isValid;
	}

	/**
    * This method returns the user to the account page
    */
	public PageReference cancel() {
		return new PageReference('/' + accountMap.Account__c);
	}
	
	
	public PageReference saveMappingActive() {
		
		String rtId = AccountFileMapDao.getInstance().getActiveRtId();
		
		return 	saveMapping(rtId);
	}
	
	
	public PageReference saveMappingDraft() {
		
		String rtId = AccountFileMapDao.getInstance().getDraftRtId();
		
		return saveMapping(rtId);	
	}
	
	public PageReference saveMappingClone() {
		RFQ_Ac_Map__c mapClone = accountMap.clone();
		mapClone.Parent_Map__c = accountMap.Id;

		accountMap.Name = oldFileMapName;
	
		accountMap.RecordTypeId = AccountFileMapDao.getInstance().getInactiveRtId();
		update accountMap;
		
		accountMap = mapClone;
		accountMap.Version__c = accountMap.Version__c + 1;
		
		for (AccountMapColumnHolder row : accountMapColumns) {
			row.accountMapColumn = row.accountMapColumn.clone();
		}
		
		for (PfMappingHolder row : pfMappings) {
			row.pfMap = row.pfMap.clone();
			
			for (PfFieldMappingHolder fieldRow : row.fieldMaps) {
				fieldRow.pfColumn = fieldRow.pfColumn.clone();
			}
		}
	
		return saveMapping(null);
	}
	

	/**
    * This method saves the current account file mapping (for both new and existing mappings)
    */
	public PageReference saveMapping(String rtId) {
		Boolean isValid = validateStep3();

		if (isValid) {
			System.debug(LoggingLevel.Info, '### Saving the mapping');
			
			if (rtId != null) accountMap.RecordTypeId = rtId;
			upsert accountMap;

			List<RFQ_Ac_Map_Column__c> columnSaveList = new List<RFQ_Ac_Map_Column__c>();
			List<RFQ_Ac_Map_Pf__c> pfMapSaveList = new List<RFQ_Ac_Map_Pf__c>();

			for (AccountMapColumnHolder holder : accountMapColumns) {
				if (String.isBlank(holder.accountMapColumn.Id)) {
					holder.accountMapColumn.RFQ_Ac_Map__c = accountMap.Id;
				}
				columnSaveList.add(holder.accountMapColumn);
			}

			upsert columnSaveList;

			if (removedAccountMapColumns.size() > 0) {
				columnSaveList.clear();

				for (AccountMapColumnHolder holder : removedAccountMapColumns) {
					columnSaveList.add(holder.accountMapColumn);
				}

				try { delete columnSaveList; }
				catch (Exception e) { System.debug(LoggingLevel.INFO, '### Error while processing delete list'); }
			}


			for (PfMappingHolder holder : pfMappings) {
				if (String.isBlank(holder.pfMap.Id)) {
					holder.pfMap.RFQ_Ac_Map__c = accountMap.Id;
				}
				upsert holder.pfMap;

				List<RFQ_Ac_Map_Pf_Column__c> fieldMapSaveList = new List<RFQ_Ac_Map_Pf_Column__c>();

				for (PfFieldMappingHolder fieldMapHolder : holder.fieldMaps) {
					if (String.isBlank(fieldMapHolder.pfColumn.Id)) {
						fieldMapHolder.pfColumn.RFQ_Ac_Map_Pf__c = holder.pfMap.Id;
					}
					fieldMapSaveList.add(fieldMapHolder.pfColumn);
				}

				upsert fieldMapSaveList;
			}

			return new PageReference('/' + accountMap.Id);
		}
		else {
			System.debug(LoggingLevel.Info, '### Something was not valid for saving the mapping...');
		}

		return null;
	}

	/*****************************************
	 * Dropdown reference methods
	 *****************************************/

	public List<SelectOption> getAccountColumnOptions() {
		List<SelectOption> results = new List<SelectOption>();
		results.add(new SelectOption('', '-- Select --'));

		if (accountMapColumns != null && accountMapColumns.size() > 0) {
			for (AccountMapColumnHolder holder : accountMapColumns) {
				results.add(new SelectOption(holder.accountMapColumn.Name, holder.accountMapColumn.Name));
			}
		}

		return results;
	}

	public List<SelectOption> getIndexColumnOptions() {
		List<SelectOption> results = new List<SelectOption>();

		results.add(new SelectOption('0', 'N/A'));
		
		for (Integer i = 1; i <= 16; i++) {
			results.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
		}

		return results;
	}

	public List<SelectOption> getProductGroupOptions() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('','-- None Selected --'));

		for(Product_Group__c productGroup : productGroups) {
			options.add(new SelectOption(productGroup.Id,productGroup.Name));
		} 
 
		return options;
	}
 

	

}