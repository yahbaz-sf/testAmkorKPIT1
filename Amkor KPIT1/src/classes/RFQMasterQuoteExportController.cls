/*************************************************************************
* 
* PURPOSE:  This class provides the supporting functions for RFQMasterQuoteExport.page 
*         
* CLASS: RFQExportSelectController
* CREATED: 07/30/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Nathan Pilkington npilkington@ethos.com
* 
**************************************************************************/

public with sharing class RFQMasterQuoteExportController extends BaseController {

	private List<RFQItemWrapper> wrappers;

	private CsvParser.CsvHolder csvHolder;

	private RFQ__c rfq;

	private List<Master_Quote_Format_Column__c> formatColumns;

	public RFQMasterQuoteExportController() {

		wrappers = new List<RFQItemWrapper>();

		String rfqId = getParam('rfqId');
		String selectedItems = getParam('selectedIds');
		
		rfq = RFQDao.getInstance().getRfqById(rfqId);
		List<RFQ_Item__c> rfqItems = RFQItemDao.getInstance().getRfqsByRfqId(rfq.Id);

		// Remove RFQ Items not selected

		for (Integer i = rfqItems.size() - 1; i >= 0; i--) {
			if (!selectedItems.contains(rfqItems[i].Id)) {
				rfqItems.remove(i);
			}
		}

		for (RFQ_Item__c rfqItem : rfqItems) {
			RFQItemWrapper wrapper = new RFQItemWrapper();
			wrapper.rfqItem = rfqItem;
			wrapper.inflateSpecificObjectsFromJson();
			wrappers.add(wrapper);
		}

		formatColumns = MasterQuoteFormatDao.getInstance().getMasterQuoteColumns();

		List<String> columnHeaders = new List<String>();

		for (Master_Quote_Format_Column__c column : formatColumns) {
			columnHeaders.add(column.Name);
		}

		System.debug('Column headers are: ' + System.JSON.serialize(columnHeaders));

		csvHolder = new CsvParser.CsvHolder(rfqItems.size(), columnHeaders);
	}

	public String getCsvOutput() {

		for (Integer i = 0; i < wrappers.size(); i++) {
			RFQItemWrapper wrapper = wrappers.get(i);

			for (Master_Quote_Format_Column__c column : formatColumns) {
				String val = getVal(wrapper, column);
				csvHolder.putVal(val, i, column.Name);
			}

		}

		return csvHolder.toCsvString();
	}

	private String getVal(RFQItemWrapper wrapper, Master_Quote_Format_Column__c column) {
		String val = null;

		try {
			sObject targetObj = null;

			if (StringUtils.isMatch(column.Object_Type__c, MasterQuoteFormatDao.RFQ)) {
				targetObj = rfq;
			}
			else if (StringUtils.isMatch(column.Object_Type__c, MasterQuoteFormatDao.RFQ_ITEM)) {
				targetObj = wrapper.rfqItem;
			}
			else if (StringUtils.isMatch(column.Object_Type__c, MasterQuoteFormatDao.SPECIFIC_RFQ_ITEM)) {
				targetObj = wrapper.specificRfqItem;
			}
			else if (StringUtils.isMatch(column.Object_Type__c, MasterQuoteFormatDao.WIRE_CONFIG)) {
				targetObj = wrapper.wireConfigurations.get(0);
			}
			else if (StringUtils.isMatch(column.Object_Type__c, MasterQuoteFormatDao.DIE_CONFIG)) {
				targetObj = wrapper.dieConfigurations.get(0);
			}
			else if (StringUtils.isMatch(column.Object_Type__c, MasterQuoteFormatDao.PASSIVE_CONFIG)) {
				targetObj = wrapper.passiveConfigurations.get(0);
			}
			else if (StringUtils.isMatch(column.Object_Type__c, MasterQuoteFormatDao.INSERTION_CONFIG)) {
				targetObj = wrapper.insertionConfigurations.get(0);
			}

			val = tryGetValue(targetObj, column.API_Names__c);
		}
		catch (Exception e) {
			// Just return empty value if encountering a problem
			System.debug('Caught exception while getting value: ' + e);
		}

		return val == null ? '' : val;
	}

	private String tryGetValue(sObject obj, String fields) {
		List<String> possibleFieldNames = fields.split(',');
		String val = null;

		for (String fieldName : possibleFieldNames) {
			try {
				if (val == null) {
					Object oVal = obj.get(fieldName);
					if (oVal != null) val = String.valueOf(oVal);
				}
			}
			catch (Exception e) {
				// At least one of the possible field names 
			}
		}

		return val;
	}
}