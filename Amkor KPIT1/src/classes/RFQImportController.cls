/*************************************************************************
*
* PURPOSE: Controller for the import account file wizard
*
* CLASS: RFQImportController
* CREATED: 3/27/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Nathan Pilkington
***************************************************************************/

public with sharing class RFQImportController extends BaseController {

	private Static final Integer BATCH_SIZE = 10;
	
	public Integer currentStep { get; set; }
	
	public Account account { get; set; }
	
	public RFQ__c rfq { get; set; }
	
	public List<RFQ_Ac_Map__c> availableMaps { get; set; }
	
	public String selectedMapId { get; set; }
	
	public RFQ_Ac_Map__c accountMap { get; set; }
	public List<RFQ_Ac_Map_Column__c>  mapColumns { get; set; }
	
	// Map of Device Name-> PF Map
	public Map<String, RFQ_Ac_Map_Pf__c> mapPfs { get; set; }
	public List<RFQ_Ac_Map_Pf__c> mapPfList { get; set; }
	
	public Map<String, List<RFQ_Ac_Map_Pf_Column__c>> mapPfColumns { get; set; } 
	
	
	public Map<String, ID> factories { get; set; }
	
	public String fileName { get; set; }
	public Blob fileContent { get; set; }

	// Records found that did not get run through the default driver processing
	public Boolean unprocessedRecordsFound { get; set; }

	// Records found that were part of a CSV that was not fully uploaded
	public Boolean incompleteRecordsFound { get; set; }

	// Which attachment ID we are working with
	public String attachmentId { get; set; }

	// Used in postback -- the next beginning index of the batch of lines to process
	public Integer nextIndex { get; set; }

	// Total number of lines (minus the header line) that are in the uploaded CSV
	public Integer totalLines { get; set; }
	// How many lines have been processed so far
	public Integer currentLineCount { get; set; }
	
	
	// This gets set to true when the file is first selected
	public Boolean processingStarted { get; set; }
	// This gets set to true when all of the line items in the CSV have been imported
	public Boolean processingCompleted { get; set; }

	
	public RFQImportController() {
		currentStep = 1;
		
		String rfqId = getParam('rfqId');
		
		if (StringUtils.isBlank(rfqId)) {
			addError('No RFQ specifed.');
			currentStep = 0;
			return;
		}
		
		rfq = RFQDao.getInstance().getRfqById(rfqId);
		
		if (rfq == null) {
			addError('RFQ not found.');
			currentStep = 0;
			return;
		}

		List<RFQ_Item__c> unprocessedRecords = [Select Id from RFQ_Item__c where Status__c =: RFQItemDao.STATUS_IMPORT_PENDING and RFQ__c =: rfq.Id];
		List<RFQ_Item__c> incompleteRecords = [Select Id from RFQ_Item__c where Status__C =: RFQItemDao.STATUS_PENDING_PROCESSING and RFQ__c =: rfq.Id];
		unprocessedRecordsFound = unprocessedRecords.size() > 0;
		incompleteRecordsFound = incompleteRecords.size() > 0;
		
		availableMaps = AccountFileMapDao.getInstance().getActiveMapsByAccountId(rfq.SBU_Name__c);
		
		setupFactoryMap();
		
		if (availableMaps.size() == 0) {
			addError('No active mappings for this account.');
		}
	}

	public PageReference buViewRedirect() {
        if(RFQSystemSettings.getIsBUUser()) {
            return new PageReference('/apex/RFQBUImport?rfqId=' + getParam('rfqId')+'&isRfq=true');
        }
        return null;
    }
	
	// Quick hack for AMK-282
	public void setupFactoryMap() {
		// FIXME Use a proper dao, optimize
		factories = new Map<String, ID>();
		
		List<Factory__c> factoryList = [Select Id, Name from Factory__c];
		
		for (Factory__c factory : factoryList) {
			factories.put(factory.Name, Factory.Id);
		}
	}
	
	public List<SelectOption> getMappingOptions() {
		List<SelectOption> results = new List<SelectOption>();
		
		if (availableMaps != null) {
			results.add(new SelectOption('', '-- Select --'));
			
			for (RFQ_Ac_Map__c row : availableMaps) {
				results.add(new SelectOption(row.Id, row.Name));
			}
		}
		
		return results;
	}

	public PageReference deleteIncompleteRecords() {
		cleanupBadImport(rfq.Id);
		incompleteRecordsFound = false;
		return null;
	}
	
	public PageReference resumeProcessing() {
		PageReference pg = new PageReference('/apex/ImportDefaults?rfqId='+rfq.Id);
        pg.setRedirect(true);
        return pg;
	}
	
	
	public PageReference returnToRfq() {
		if (rfq == null) return new PageReference('/');
		return new PageReference('/' + rfq.Id);
	}
	
	public PageReference returnToMapSelect() {
		currentStep = 1;
		return null;
	}
	
	public PageReference mappingSelected() {
		
		if (StringUtils.isBlank(selectedMapId)) {
			addError('Please select an account file mapping');
		}
		else {	
			setupMappingObjectsFromMapId(selectedMapId);
			currentStep = 2;
		}

		return null;
	}

	private void setupMappingObjectsFromMapId(String mapId) {
		//--- TODO There may be a better way to set these up (e.g. hashmaps)

		accountMap = AccountFileMapDao.getInstance().getMapById(mapId);
		mapPfList = AccountFileMapDao.getInstance().getPfMapsByMapId(mapId);
		
		mapPfs = new Map<String, RFQ_Ac_Map_Pf__c>();
		
		mapPfColumns = new Map<String, List<RFQ_Ac_Map_Pf_Column__c>>();
		
		for (RFQ_Ac_Map_Pf__c row : mapPfList) {
			List<RFQ_Ac_Map_Pf_Column__c> pfColumns = AccountFileMapDao.getInstance().getPfFieldMapsByParentId(row.Id);
			mapPfColumns.put(row.Id, pfColumns);
			
			mapPfs.put(row.Account_Device_Name__c, row);
		}
	}
	
	public PageReference fileSelected() {
		
		if (fileContent == null) {
			addError('Please select a file.');
		}
		else {
			String fileContentString = fileContent.toString().replaceAll('\r\n', '\n');
			
			CsvParser parser = new CsvParser(fileContentString);

			if (parser.getTotalLines() <= 1) {
				addError('The CSV file must have at least one header line and one data line');
				return null;
			}

			totalLines = parser.getTotalLines() - 1;
			currentLineCount = 0;

			Attachment attachment = new Attachment();
			attachment.Body = fileContent;
			attachment.Name = fileName;
			attachment.ParentId = rfq.Id;
			attachment.Description = 'File uploaded using the import wizard';
			
			insert attachment;

			attachmentId = attachment.Id;

			currentStep = 3;
			
			nextIndex = 0;

			processingCompleted = false;
		}
		
		return null;
	}
	
	/****************************
	 * Main parsing logic       *
	 ****************************/

	public void processNextBatch() {
		processingStarted = true;
 		String attachId = getParam('attachId');
 		String accountMapId = getParam('accountMapId');

 		setupMappingObjectsFromMapId(accountMapId);

 		Attachment attach = [Select Body, Name, Id from Attachment where Id =: attachId];

 		String fileContentString = attach.Body.toString().replaceAll('\r\n', '\n');
		CsvParser parser = new CsvParser(fileContentString);

		// Number of lines minus the header
		Integer totalLines = parser.getTotalLines() - 1;

		// What we are starting at
		Integer startIndex = nextIndex;

		// TotalLines = 50
		// startIndex + BATCH_SIZE = 0 + 50 = 50
		Integer endIndex = ((startIndex + BATCH_SIZE >= totalLines) ? totalLines : startIndex + BATCH_SIZE) - 1;

 		List<List<String>> fileLines;
			
		try {
			fileLines = parser.parse(startIndex, endIndex);
		} catch (Exception e) {
			// Go back to file select and show error, bad CSV
			System.debug(LoggingLevel.ERROR, 'Caught exception while importing: ' + e);

			addError('The file supplied is not in a valid CSV format');

			currentStep = 2;
			cleanupBadImport(rfq.Id);
			processingStarted = false;

			return;
		}

		
		Boolean success = tryMapLines(fileLines);
		
		if (success) {
			if (endIndex >= totalLines - 1) {
				processingCompleted = true;

				// Flip the status of the items just imported to import pending so we know the whole file imported okay
				List<RFQ_Item__c> processedItems = [Select Id, RFQ__c, Status__c from RFQ_Item__c where RFQ__c =: rfq.Id and Status__c =: RFQItemDao.STATUS_PENDING_PROCESSING];

				for (RFQ_Item__c row : processedItems) {
					row.Status__c = RFQItemDao.STATUS_IMPORT_PENDING;
				}

				update processedItems;
			}
			else {
				nextIndex = endIndex + 1;
				currentLineCount = nextIndex;
			}
		}
		else {
			// Go back to file select and cleanup, something was wrong with the CSV file
			currentStep = 2;
			cleanupBadImport(rfq.Id);
			processingStarted = false;
		}
	} 

	private void cleanupBadImport(String rfqId) {
		// If something went wrong during the CSV parsing, clean up any files 
		List<RFQ_Item__c> incompleteRecords = [Select Id from RFQ_Item__c where Status__C =: RFQItemDao.STATUS_PENDING_PROCESSING and RFQ__c =: rfqId];
		delete incompleteRecords;
	}
	
	private Boolean tryMapLines(List<List<String>> fileLines) {
		
		if (StringUtils.isBlank(accountMap.Device_Name_Column__c)) {
			addError('No device name column was specified for the account file mapping');
			return false;
		}
		
		CsvParser.CsvHolder holder = new CsvParser.CsvHolder(fileLines);
		
		Integer lineCount = holder.getLineCount();
		Integer deviceNameColumnIndex = holder.getIndexOfColumn(accountMap.Device_Name_Column__c);
		
		if (deviceNameColumnIndex < 0) {
			addError('Device name column (' + accountMap.Device_Name_Column__c + ') not found in file specified.');
			return false;
		}

		List<RFQItemWrapper> itemHolders = new List<RFQItemWrapper>();
		
		for (Integer i = 0; i < lineCount; i++) {
			Integer fileIndex = i + 2; // Zero indexed, plus the header line
			String lineDeviceName;
			
			try {
				lineDeviceName = holder.getVal(i, deviceNameColumnIndex);
			}
			catch (Exception e) {
				addError('Was not able to retrieve device name for line ' + fileIndex + '. Please ensure the CSV is properly formatted.');
			}
			
			if (!mapPfs.containsKey(lineDeviceName)) {
				addError('No package family mapping found for account device name: ' + lineDeviceName + ' --  on line: ' + fileIndex + '.');
				return false;
			}
			
			RFQ_Ac_Map_Pf__c pfMap = mapPfs.get(lineDeviceName);
			
			
			RFQ_Item__c rfqItem = new RFQ_Item__c(Status__c=RFQItemDao.STATUS_PENDING_PROCESSING);
			rfqItem.Package_Family__c = pfMap.Package_Family__c;
			rfqItem.RFQ__c = rfq.Id;
			rfqItem.Line_Number__c = i;

			cachePackageFamily(pfMap.Package_Family__c);

			sObject specificRfqItem = createLineItemForPfId(pfMap.Package_Family__c);
			sObject specificWireItem = createWireConfigItemForPfId(pfMap.Package_Family__c);
			sObject specificDieItem = createDieConfigItemForPfId(pfMap.Package_Family__c);
			sObject specificInsertionItem = createInsertionConfigItemForPfId(pfMap.Package_Family__c);
			sObject specificPassiveItem = createPassiveConfigItemForPfId(pfMap.Package_Family__c);
			sObject specificServiceItem = createServiceConfigItemForPfId(pfMap.Package_Family__c);


			RFQItemWrapper wrapper = new RFQItemWrapper();
			wrapper.rfqItem = rfqItem;
			wrapper.specificRfqItem = specificRfqItem;
			if (specificWireItem != null) wrapper.wireConfigurations = new List<sObject> { specificWireItem };
			if (specificDieItem != null) wrapper.dieConfigurations = new List<sObject> { specificDieItem };
			if (specificInsertionItem != null) wrapper.insertionConfigurations = new List<sObject> { specificInsertionItem };
			if (specificPassiveItem != null) wrapper.passiveConfigurations = new List<sObject> { specificPassiveItem };
			if (specificServiceItem != null) wrapper.serviceConfigurations = new List<sObject> { specificServiceItem };
			
			itemHolders.add(wrapper);
			
			List<RFQ_Ac_Map_Pf_Column__c> pfColumns = mapPfColumns.get(pfMap.Id);
			
			for (RFQ_Ac_Map_Pf_Column__c column : pfColumns) {
				String fieldName = column.RFQI_PF_Field_Def__r.RFQI_Field_Def__r.Name;
				String sectionName = column.RFQI_PF_Field_Def__r.RFQI_Section__r.Name;
				String objName = column.RFQI_PF_Field_Def__r.RFQI_Field_Def__r.Object__c;

				// Object index is 1..n of which wire object the column belongs to. Subtract one from it to get zero-indexed number
				Integer objectIndex = (column.Object_Index__c == null || column.Object_Index__c == 0) ? 0 : (Integer)column.Object_Index__c - 1;
				
				sObject targetObj;
				if (StringUtils.isMatch(objName, RFQItemWrapper.WIRE_OBJECT)) {
					targetObj = getChildObject(wrapper.wireConfigurations, objectIndex, objName, pfMap.Package_Family__c);
				}
				else if (StringUtils.isMatch(objName, RFQItemWrapper.DIE_OBJECT)) {
					targetObj = getChildObject(wrapper.dieConfigurations, objectIndex, objName, pfMap.Package_Family__c);
				}
				else if (StringUtils.isMatch(objName, RFQItemWrapper.PASSIVE_OBJECT)) {
					targetObj = getChildObject(wrapper.passiveConfigurations, objectIndex, objName, pfMap.Package_Family__c);
				}
				else if (StringUtils.isMatch(objName, RFQItemWrapper.INSERTION_OBJECT)) {
					targetObj = getChildObject(wrapper.insertionConfigurations, objectIndex, objName, pfMap.Package_Family__c);
				}
				else if (StringUtils.isMatch(objName, RFQItemWrapper.SERVICE_OBJECT)) {
					targetObj = getChildObject(wrapper.serviceConfigurations, objectIndex, objName, pfMap.Package_Family__c);
				}
				else targetObj = specificRfqItem;
				
				Integer columnIndex = holder.getIndexOfColumn(column.RFQ_Ac_Map_Column__c);
				
				if (columnIndex < 0) {
					addError('The column "' + column.RFQ_Ac_Map_Column__c + '" was not found in the CSV file.');
					return false;
				}
				
				String val;
				try {
					val = holder.getVal(i, columnIndex);
				}
				catch (Exception e) {
					// Index out of range, probably a malformed CSV file (not enough columns in a certain row or something)
					addError('Could not retrieve field value for column ' + column.RFQ_Ac_Map_Column__c + ' on line ' + fileIndex + '. Please make sure the supplied CSV is valid');
					return false;
				}
				
				try {
					Schema.DescribeFieldResult fieldInfo = getFieldInfo(targetObj, fieldName);
					Schema.DisplayType fieldType = fieldInfo.getType();
					
					if (fieldType == Schema.DisplayType.Double || fieldType == Schema.DisplayType.Currency || fieldType == Schema.DisplayType.Integer) {
						targetObj.put(fieldName, StringUtils.TryParseDouble(val));
						System.debug('### SUCCESS Successfully mapped a double value: ' + fieldName + '-' + val);
					}
					else if (fieldType == Schema.DisplayType.Boolean) {
						if (val.startsWith('Y')) targetObj.put(fieldName, true);
						else targetObj.put(fieldName, false); 
						System.debug('### SUCCESS Successfully mapped a bool value: ' + fieldName + '-' + val);
					}
					else if (fieldType == Schema.DisplayType.Reference) {
						// FIXME Remove awful hardcoded reference to factory
						if (fieldName.equalsIgnoreCase('Factory__c') && val != null) {
							if (factories.containsKey(val)) {
								targetObj.put(fieldName, factories.get(val));
							}
						}
						else {
							System.debug('### FIELD SKIPPED: ' + fieldName + ' BECAUSE IT IS A NON-FACTORY LOOKUP.');
						}
					}
					else if (fieldType == Schema.DisplayType.Date) {
						targetObj.put(fieldName, Date.parse(val));
					}
					else if (fieldType == Schema.DisplayType.DateTime) {
						targetObj.put(fieldName, DateTime.parse(val));
					} 
					else {
						targetObj.put(fieldName, val);
						System.debug('### SUCCESS Successfully mapped a string value: ' + fieldName + '-' + val);
					}
				
				
				} catch (Exception e) {
					System.debug(LoggingLevel.ERROR, '### ERROR While trying to parse the value \'' + val + '\' :' + e);
				}
				
				
			}
		} 
		
		List<RFQ_Item__c> rfqItemSaveList = new List<RFQ_Item__c>();

		// Insert the parent RFQ_Item__c objects first, so the child objects can be linked
		for (RFQItemWrapper row : itemHolders) {
			rfqItemSaveList.add(row.rfqItem);
			RFQItemDao.getInstance().copyFieldsToGeneric(row);
			RFQItemDao.updateJsonFields(row);
		}
		
		insert rfqItemSaveList;

		saveChildObjectsForWrappers(itemHolders, true);

		// Link the RFQ to the import mapping so we know what format to export it out
		rfq.RFQ_Account_File_Map__c = selectedMapId;
		update rfq;
		
		return true;
	}


	private sObject getChildObject(List<sObject> childList, Integer objectIndex, String objName, Id pfId) {

		if (childList.size() - 1 < objectIndex) {

			// "Grow" the child list to match the selected index
			while (childList.size() - 1 < objectIndex) {
				if (objName == RFQItemWrapper.WIRE_OBJECT) {
					childList.add(createWireConfigItemForPfId(pfId));
				}
				else if (objName == RFQItemWrapper.DIE_OBJECT) {
					childList.add(createDieConfigItemForPfId(pfId));
				}
				else if (objName == RFQItemWrapper.PASSIVE_OBJECT) {
					childList.add(createPassiveConfigItemForPfId(pfId));
				}
				else if (objName == RFQItemWrapper.INSERTION_OBJECT) {
					childList.add(createInsertionConfigItemForPfId(pfId));
				}
			}
		}

		return childList[objectIndex];
	}

	private void saveChildObjectsForWrappers(List<RFQItemWrapper> itemHolders, Boolean shouldInsert) {
		Map<String, List<sObject>> specificItemSaveList = new Map<String, List<sObject>>();
		Map<String, List<sObject>> specificWireSaveList = new Map<String, List<sObject>>();
		Map<String, List<sObject>> specificDieSaveList = new Map<String, List<sObject>>();
		Map<String, List<sObject>> specificPassiveSaveList = new Map<String, List<sObject>>();
		Map<String, List<sObject>> specificInsertionSaveList = new Map<String, List<sObject>>();
		Map<String, List<sObject>> specificServiceSaveList = new Map<String, List<sObject>>();

		// Now go through the child objects, link them to the parent RFQI and insert them

		for (RFQItemWrapper row : itemHolders) {
			row.setupChildParentIds();
			addObjectToSaveList(specificItemSaveList, row.specificRfqItem, null);
		}

		List<sObject> specificInsertList = new List<sObject>();
		combineItemsToSaveList(specificItemSaveList, specificInsertList);

		if (shouldInsert) {
			insert specificInsertList;
		}
		else {
			update specificInsertList;
		}
		

		for (RFQItemWrapper row : itemHolders) {
			row.setupChildParentIds();
			addObjectToSaveList(specificWireSaveList, null, row.wireConfigurations);
			addObjectToSaveList(specificDieSaveList, null, row.dieConfigurations);
			addObjectToSaveList(specificPassiveSaveList, null, row.passiveConfigurations);
			addObjectToSaveList(specificInsertionSaveList, null, row.insertionConfigurations);
			addObjectToSaveList(specificServiceSaveList, null, row.serviceConfigurations);
		}

		
		List<sObject> wireInsertList = new List<sObject>();
		List<sObject> dieInsertList = new List<sObject>();
		List<sObject> passiveInsertList = new List<sObject>();
		List<sObject> insertionInsertList = new List<sObject>();
		List<sObject> serviceInsertList = new List<sObject>();

		calculateWireLengths(specificWireSaveList.values());
		
		combineItemsToSaveList(specificWireSaveList, wireInsertList);
		combineItemsToSaveList(specificDieSaveList, dieInsertList);
		combineItemsToSaveList(specificPassiveSaveList, passiveInsertList);
		combineItemsToSaveList(specificInsertionSaveList, insertionInsertList);
		combineItemsToSaveList(specificServiceSaveList, serviceInsertList);

		
		if (shouldInsert) {
			insert wireInsertList;
			insert dieInsertList;
			insert passiveInsertList;
			insert insertionInsertList;
			insert serviceInsertList;
		}
		else {
			update wireInsertList;
			update dieInsertList;
			update passiveInsertList;
			update insertionInsertList;
			update serviceInsertList; 
		}
		
	}

	private void combineItemsToSaveList(Map<String, List<sObject>> sourceList, List<sObject> targetList) {
		for (List<SObject> sObjList : sourceList.values()) {
			targetList.addAll(sObjList);
		}
	}

	private void addObjectToSaveList(Map<String, List<sObject>> targetList, sObject singleObj, List<sObject> objList) {
		if (singleObj != null) {
			//Schema.SObjectType oType = singleObj.getSObjectType();
			String oName = singleObj.getSObjectType().getDescribe().getName();

			if (targetList.get(oName) == null) {
				targetList.put(oName, new List<sObject>());
			}

			targetList.get(oName).add(singleObj);
		}

		if (objList != null && objList.size() > 0) {
			// Schema.SObjectType oType = objList[0].getSObjectType();
			String oName = objList[0].getSObjectType().getDescribe().getName();

			if (targetList.get(oName) == null) {
				targetList.put(oName, new List<sObject>());
			}

			targetList.get(oName).addAll(objList);
		}
	}

	private void calculateWireLengths(List<List<sObject>> objectList)
	{

        Type t = Type.forName('CMWireCalcBase');
        CMWireCalcBase wireCalc = (CMWireCalcBase)t.newInstance();
        CM_Version__c ver = new CM_Version__c();
        for (List<Sobject> wireList : objectList)
		{
			for (sObject wire : wireList)
			{
				wireCalc.calcLength(wire, ver);
			}
		}
	}
	
	/****************************
	 * Metadata parsing methods *
	 ****************************/
	
	private Map<String, Package_Family__c> packageFamilyMap = new Map<String, Package_Family__c>();
	private Map<String, Schema.SObjectType> packageFamilyTypeMap = new Map<String, Schema.SObjectType>();
	private Map<String, Schema.SObjectType> wireConfigTypeMap = new Map<String, Schema.SObjectType>();
	private Map<String, Schema.SObjectType> dieConfigTypeMap = new Map<String, Schema.SObjectType>();
	private Map<String, Schema.SObjectType> passiveConfigTypeMap = new Map<String, Schema.SObjectType>();
	private Map<String, Schema.SObjectType> insertionConfigTypeMap = new Map<String, Schema.SObjectType>();
	private Map<String, Schema.SObjectType> serviceConfigTypeMap = new Map<String, Schema.SObjectType>();
	
	private Map<String, Map<String, Schema.SObjectField>> fieldDescribeCache = new Map<String, Map<String, Schema.SObjectField>>();
	 
	private sObject createLineItemForPfId(String pfId) {
		Package_Family__c pf = getPackageFamilyById(pfId);
		return createChildObject(pf, pf.Specific_RFQ_Item_Object__c, packageFamilyTypeMap);
	}
	
	private sObject createWireConfigItemForPfId(String pfId) {
		Package_Family__c pf = getPackageFamilyById(pfId);
		return createChildObject(pf, pf.Specific_Wire_Configuration_Object__c, wireConfigTypeMap);
	}
	
	private sObject createDieConfigItemForPfId(String pfId) {
		Package_Family__c pf = getPackageFamilyById(pfId);
		return createChildObject(pf, pf.Specific_Die_Configuration_Object__c, dieConfigTypeMap);
	}

	private sObject createPassiveConfigItemForPfId(String pfId) {
		Package_Family__c pf = getPackageFamilyById(pfId);
		return createChildObject(pf, pf.Specific_Passive_Configuration_Object__c, passiveConfigTypeMap);
	}

	private sObject createInsertionConfigItemForPfId(String pfId) {
		Package_Family__c pf = getPackageFamilyById(pfId);
		return createChildObject(pf, pf.Specific_Insertion_Configuration_Object__c, insertionConfigTypeMap);
	}

	private sObject createServiceConfigItemForPfId(String pfId) {
		Package_Family__c pf = getPackageFamilyById(pfId);
		return createChildObject(pf, pf.Specific_Service_Configuration_Object__c, serviceConfigTypeMap);
	}

	private sObject createChildObject(Package_Family__c pf, String objectName, Map<String, Schema.SObjectType> typeCache) {
		if (!StringUtils.isBlank(objectName)) {
			Schema.SObjectType targetType = null;

			if (!typeCache.containsKey(pf.Id)) {	
				targetType = Schema.getGlobalDescribe().get(objectName);
				typeCache.put(pf.Id, targetType);
				
				return targetType.newSObject();
			}
			else {
				targetType = typeCache.get(pf.Id);
			}
			
			return targetType.newSObject(); 
		}
		
		return null;
	}
	
	private Package_Family__c getPackageFamilyById(String pfId) {
		if (!packageFamilyMap.containsKey(pfId)) {
		 	Package_Family__c  packageFam = PackageFamilyDao.getInstance().getById(pfId);
		 	packageFamilyMap.put(pfId, packageFam);
		 	return packageFam;
		}
		
		return packageFamilyMap.get(pfId);
	}

	private void cachePackageFamily(String pfId) {
		if (!packageFamilyMap.containsKey(pfId)) {
		 	Package_Family__c packageFam = PackageFamilyDao.getInstance().getById(pfId);
		 	packageFamilyMap.put(pfId, packageFam);
		}
	}
	
	
	private Schema.DescribeFieldResult getFieldInfo(SObject targetObj, String fieldName)
	{
		Map<String, Schema.SObjectField> fieldList = getFieldList(targetObj);
		Schema.SObjectField field = fieldList.get(fieldName);
		return field.getDescribe();
	}
	
	private Map<String, Schema.SObjectField> getFieldList(SObject targetObj)
	{
		Schema.DescribeSObjectResult descr = targetObj.getSObjectType().getDescribe();
		if (!fieldDescribeCache.containsKey(descr.getName()))
		{
			fieldDescribeCache.put(descr.getName(), descr.fields.getMap());
		}
		
		return fieldDescribeCache.get(descr.getName());
	}
	

}