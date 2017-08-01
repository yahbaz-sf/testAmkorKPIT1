/*************************************************************************
*
* PURPOSE: Controller for the BU price attribute import page
*
* CLASS: RFQBUImportController
* CREATED: 10/8/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Nathan Pilkington
***************************************************************************/

public with sharing class RFQBUImportController extends BaseController {

	public Blob fileContent { get; set; }
	public String fileName { get; set; }

	public String rfqItemId { get; set; }
	public String rfqId { get; set; }

	public RFQItemWrapper itemWrapper { get; set; }
	public RFQILayout layout { get; set; }

	private Boolean isMultiImport = false;

	public Boolean isRfq { get; set; }

	public Boolean success { get; set; }

	public final String NULL_INDEX_MSG = 'Null list index';

	public RFQBUImportController() {
		rfqId = getParam('rfqId');
		rfqItemId = getParam('rfqItemId');

		isRfq = getParam('isRfq') == 'true';


		if (!StringUtils.isBlank(rfqId)) {
			isMultiImport = true;
		}
		else {
			isMultiImport = false;
			itemWrapper = RFQItemDao.getInstance().getWrapperById(rfqItemId);
		}

		success = false;
	}

	public PageReference returnToItem(){

		if(getParam('edit') == '1')
		{
			return new PageReference ('/apex/RFQBUItemPriceEdit?id=' + rfqItemId);
		}

		return new PageReference ('/apex/RFQBUItemView?id=' + rfqItemId);

	}

	public PageReference import() {

		if (fileContent == null) {
			addError('Please select a file');
			return null;
		}

		String fileContentString;

		try {
			fileContentString = fileContent.toString().replaceAll('\r\n', '\n');
		} 
		catch (Exception e) {
			addError('The file you uploaded contains one or more special characters. Please remove the special characters before re-uploading the file');
			return null;
		}

		CsvParser parser = new CsvParser(fileContentString);

		if (parser.getTotalLines() < 2) {
			addError('The CSV file must have at least one header line and one data line');
			return null;
		}
		
		List<List<String>> fileLines;
		
		try {
			fileLines = parser.parse();
		} catch (Exception e) {
			addError('The file supplied is not in a valid CSV format');
			return null;
		}

		CsvParser.CsvHolder csvHolder = new CsvParser.CsvHolder(fileLines);

		Integer numLines = csvHolder.getLineCount();

		if (csvHolder.getIndexOfColumn(RFQBUExportController.RFQI_NUM_COLUMN) < 0) {
			addError('The RFQI # column was not found in the spreadsheet');
			return null;
		}

		List<RFQItemWrapper> itemWrappers = new List<RFQItemWrapper>();


		if (isMultiImport) {
			// Build up list of RFQI #'s that are contained in the CSV
			

			Set<String> rfqiList = new Set<String>();

			for (Integer i = 0; i < numLines; i++) {
				String rfqiName = csvHolder.getVal(i, RFQBUExportController.RFQI_NUM_COLUMN);

				if (StringUtils.isBlank(rfqiName)) {
					addError('No RFQI # found for line ' + (i + 1));
					return null;
				}

				rfqiList.add(rfqiName);
			}

			List<RFQ_Item__c> itemList = RFQItemDao.getInstance().getMultipleByName(rfqiList);

			Package_Family__c pf = PackageFamilyDao.getInstance().getById(itemList[0].Package_Family__c);

			for (RFQ_Item__c rfqItem : itemList) {
				RFQItemWrapper wrapper = new RFQItemWrapper();
				wrapper.rfqItem = rfqItem;
				wrapper.packageFamily = pf;
				wrapper.productGroup = new Product_Group__c(Cost_Model_Implementation__c=pf.Product_Group__r.Cost_Model_Implementation__c);
				wrapper.inflateSpecificObjectsFromJson();
				wrapper.inflateVolume();
				itemWrappers.add(wrapper);
			}
		}
		else {
			itemWrappers.add(itemWrapper);
		}

		layout = setupLayoutForWrapper(itemWrappers[0]);

		List<sObject> saveList = new List<sObject>();
		List<sObject> itemList = new List<sObject>();

		// Loop through cost and price section
		for (Integer i = 0; i < numLines; i++) {
			String rfqiNum = csvHolder.getVal(i, RFQBUExportController.RFQI_NUM_COLUMN);
			RFQItemWrapper wrapper = getWrapperByName(itemWrappers, rfqiNum);

			if (wrapper == null) {
				addError('RFQI # "' + rfqiNum + '" not found for this RFQ');
				return null;
			}

			List<RFQISectionAttribute> priceAttributes = layout.sectionMap.get('Cost and Price').attributes;

			for (RFQISectionAttribute attribute : priceAttributes) {
				if (!StringUtils.isMatch(attribute.fieldAPIName, 'BLANK')) {
					String fieldLabel = FieldLabelHelper.getInstance().getLabel(wrapper.packageFamily.Specific_RFQ_Item_Object__c, attribute.fieldAPIName);

					if (csvHolder.getIndexOfColumn(fieldLabel) < 0) {
						addError('The cost and price field ' + fieldLabel + ' was not found in the file provided');
						return null;
					}

					String sVal = csvHolder.getVal(i, fieldLabel);
					Schema.DescribeFieldResult fieldInfo = FieldLabelHelper.getInstance().getFieldInfo(wrapper.specificRfqItem, attribute.fieldAPIName);

					if (fieldInfo != null) {
						Schema.DisplayType fieldType = fieldInfo.getType();
						if (fieldType == Schema.DisplayType.Double || fieldType == Schema.DisplayType.Currency || fieldType == Schema.DisplayType.Integer) {
							Double val = StringUtils.TryParseDouble(sVal);
							wrapper.specificRfqItem.put(attribute.fieldAPIName, val);

						}
						else if (fieldType == Schema.DisplayType.Boolean) {
							if (sVal.startsWith('Y')) wrapper.specificRfqItem.put(attribute.fieldAPIName, true);
							else wrapper.specificRfqItem.put(attribute.fieldAPIName, false); 
						}
						else {
							wrapper.specificRfqItem.put(attribute.fieldAPIName, sVal);
						}
					}
				}
			}

			//AMK-2334
			//make sure there is a next row
			if (i + 1 < numLines)
			{
				//check next row for "Additional Volume x" - it is a multi volume item, and belongs in the same wrapper
				Map<String, String> fieldMap = CMBuilder.getCMBuilderByWrapper(wrapper).getFieldMap();
				rfqiNum = csvHolder.getVal(i + 1, RFQBUExportController.RFQI_NUM_COLUMN);
				Integer volumeIndex = 0;
				while (rfqiNum.contains('Additional volume') && i + 1 < numLines)
				{
					//increment i because we're on the next row - the addtl volume
					i++;
					RFQIVolume volume = wrapper.volumeList[volumeIndex++];
					for (String  key : fieldMap.keyset())
					{
						try
						{
							String columnName = FieldLabelHelper.getInstance().getLabel(wrapper.packageFamily.Specific_RFQ_Item_Object__c, fieldMap.get(key));
							volume.setDynamicValue(key, csvHolder.getVal(i, columnName));
						}
						catch (System.ListException e)
						{
							if (NULL_INDEX_MSG.equalsIgnoreCase(e.getMessage()))
							{
								DebugUtils.write('e', e);
								DebugUtils.write('e.getStackTraceString()', e.getStackTraceString());
								DebugUtils.write('Could not find multivolume field ' + key + ' in file. Object API name is ' + fieldMap.get(key));
							}
							else throw e;
						}
					}

					if (wrapper.packageFamily.Name == AMKVARS.PF_TEST && !wrapper.insertionConfigurations.isEmpty())
					{
						String insObjName = wrapper.insertionConfigurations[0].getSObjectType().getDescribe().getName();
						Integer insertionIndex = 0;
						for (RFQIVolume.RFQITestInsertion testInsertion : volume.testInsertions)
						{
	    					copyTestFieldsFromCSV(csvHolder, volume, insObjName, i, insertionIndex, 'buPriceHour', 'Insertion_BU_Price_Per_Hour__c');
	    					copyTestFieldsFromCSV(csvHolder, volume, insObjName, i, insertionIndex, 'buPriceUnit', 'BU_Price_Per_Unit_Final__c');
	    					copyTestFieldsFromCSV(csvHolder, volume, insObjName, i, insertionIndex, 'buPriceMonthly', 'Insertion_BU_Price_Monthly_Charge__c');

							insertionIndex++;
						}
						
						String specificObjName = wrapper.specificRfqItem.getSObjectType().getDescribe().getName();
    					copyTestFieldsFromCSV(csvHolder, volume, specificObjName, i, null, 'buPriceHour', 'BU_Price_Per_Hour__c');
    					copyTestFieldsFromCSV(csvHolder, volume, specificObjName, i, null, 'buPriceUnit', 'BU_Final_Test_Price_Unit__c');
    					copyTestFieldsFromCSV(csvHolder, volume, specificObjName, i, null, 'buPriceMonthly', 'BU_Price_Monthly_Charge__c');

					}

					//not i + 1 because i was already incremented
					rfqiNum = csvHolder.getVal(i, RFQBUExportController.RFQI_NUM_COLUMN);
				}
			}

			wrapper.rfqItem.Multi_Volume__c = JSON.serialize(wrapper.volumeList);
			wrapper.rfqItem.Has_Been_BU_Imported__c = true;
			RFQItemDao.getInstance().copyFieldsToGeneric(wrapper);
			itemList.add(wrapper.rfqItem);
			saveList.add(wrapper.specificRfqItem);
		}
		
		saveList.addAll(itemList);
		update saveList;


		if (isRfq) {
			addConfirm('File successfully uploaded, you may now close this window');
		}
		else {
			addConfirm('File successfully uploaded');
		}
		
		success = true;

		return null;
		//return new PageReference('/apex/RFQBUItemView?id=' + rfqItemId);
	}

    private void copyTestFieldsFromCSV(CsvParser.CsvHolder csvHolder, RFQIvolume volume, String objName, Integer csvIndex, Integer insertionIndex, String volField, String objField)
	{
        String columnName = FieldLabelHelper.getInstance().getLabel(objName, objField);
		if (insertionIndex != null) columnName += ' ' + (insertionIndex + 1);
		volume.setDynamicValue(volField, csvHolder.getVal(csvIndex, columnName), insertionIndex);
	}

	private RFQItemWrapper getWrapperByName(List<RFQItemWrapper> srcList, String rfqiNum) {
		for (RFQItemWrapper wrapper : srcList) {
			if (StringUtils.isMatch(wrapper.rfqItem.Name, rfqiNum)) {
				return wrapper;
			}
		}

		return null;
	}

	private RFQILayout setupLayoutForWrapper(RFQItemWrapper wrapper) {
		RFQILayout itemLayout = PFFieldDefDao.getInstance().getBULayoutForWrapper(wrapper);

		LayoutUtil.setupLayoutForBuEditScreen(wrapper, itemLayout);

		return itemLayout;
	}
}