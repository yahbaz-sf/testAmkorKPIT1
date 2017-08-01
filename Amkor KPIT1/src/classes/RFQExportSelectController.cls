/*************************************************************************
* 
* PURPOSE:  This class provides the supporting functions for RFQExportSelect.page 
*         
* CLASS: RFQExportSelectController
* CREATED: 07/9/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Nathan Pilkington npilkington@ethos.com
* 
**************************************************************************/

public with sharing class RFQExportSelectController extends BaseController {

	private static String MASTER = 'MASTER';
	private static String ACCOUNT = 'ACCOUNT';

	private static String ALL = 'ALL';
	private static String ALL_ORIGINAL = 'ALL_ORIGINAL';
	private static String ONLY_SELECTED = 'ONLY_SELECTED';

	public Boolean wasImportedFromCsv { get; set; }

	public RFQ__c rfq;

	public List<RFQItemHolder> rfqItems { get; set; }

	public String selectedFormat { get; set; }
	public String selectionMode { get; set; }

	public Boolean wasExported { get; set; }

	public String attachmentId { get; set; }

	public RFQExportSelectController() {
		String rfqId = getParam('rfqId');

		rfq = RFQDao.getInstance().getRfqById(rfqId);
		List<RFQ_Item__c> itemList = RFQItemDao.getInstance().getRfqsByRfqId(rfq.Id);
		
		wasImportedFromCsv = !StringUtils.isBlank(rfq.RFQ_Account_File_Map__c);
		rfqItems = getHolderList(itemList);

		if (!wasImportedFromCsv) {
			selectedFormat = MASTER;
			addInfo('This RFQ was not imported from an account file and so account format export is not available');
		}

		if (rfqItems.size() == 0) {
			addInfo('This RFQ has no items available for export');
		}

		wasExported = false;
	}

	public PageReference buViewRedirect() {
        if(RFQSystemSettings.getIsBUUser()) {
            return new PageReference('/apex/RFQBUMultiExport?rfqId=' + getParam('rfqId'));
        }
        return null;
    }

	public PageReference cancel() {
		return new PageReference('/' + rfq.Id); 
	}

	public List<SelectOption> getFormatOptions() {
		List<SelectOption> results = new List<SelectOption>();

		results.add(new SelectOption(MASTER, 'RFQ List'));
		if (wasImportedFromCsv) results.add(new SelectOption(ACCOUNT, 'Account Quote Format'));

		return results;
	}

	public List<SelectOption> getExportOptions() {
		List<SelectOption> results = new List<SelectOption>();

		results.add(new SelectOption(ALL, 'All'));
		if (wasImportedFromCsv) results.add(new SelectOption(ALL_ORIGINAL, 'All Original'));
		results.add(new SelectOption(ONLY_SELECTED, 'Selected'));


		return results;
	}

	public List<RFQItemHolder> getSelectableItems() {
		List<RFQItemHolder> results = new List<RFQItemHolder>();

		for (RFQItemHolder holder : rfqItems) {
			// If exporting to master quote format, then only allow quoted or greater status
			// If exporting to account format, then allow price complete or greater status

			Boolean isMasterFormat = StringUtils.isMatch(selectedFormat, MASTER);
			Boolean isPriceCompleteOrGreater = RFQItemDao.getInstance().statusGreaterOrEqual(holder.item, RFQItemDao.STATUS_PRICE_COMPLETE);
			Boolean isQuotedOrGreater = RFQItemDao.getInstance().statusGreaterOrEqual(holder.item, RFQItemDao.STATUS_QUOTED);
			
			if (isMasterFormat || isPriceCompleteOrGreater) {
				results.add(holder);
			}
		}

		return results;
	}

	public PageReference export() {
		if (StringUtils.isBlank(selectedFormat)) {
			addError('Please select an export format');
			return null;
		}

		if (StringUtils.isBlank(selectionMode)) {
			addError('Please select which items you wish to export');
			return null;
		}

		Boolean isMasterFormat = StringUtils.isMatch(selectedFormat, MASTER);

		if (!isMasterFormat && getSelectableItems().size() == 0) {
			addError('There are no items in this RFQ that are a price complete or greater status, so RFQ cannot be exported into account file format');
			return null;
		}

		List<RFQItemHolder> exportList = new List<RFQItemHolder>();

		if (StringUtils.isMatch(selectionMode, ALL)) {
			exportList = isMasterFormat ? rfqItems : getSelectableItems();
		}
		else if (StringUtils.isMatch(selectionMode, ALL_ORIGINAL)) {
			List<RFQItemHolder> sourceList = isMasterFormat ? rfqItems : getSelectableItems();
			
			for (RFQItemHolder row : sourceList) {
				// All items that were imported from the CSV will have a line number
				if (row.item.Line_Number__c != null) exportList.add(row);
			}
		}
		else {
			for (RFQItemHolder row : rfqItems) {
				if (row.selected) exportList.add(row);
			}
		}

		if (exportList.size() == 0) {
			addError('Please select at least one item to export');
			return null;
		}

		if (!isMasterFormat && !validateHasMapping(exportList)) {
			addError('One or more of the items you selected does not have a package family mapping on the account file map');
			return null;
		}

		List<String> selectedIds = new List<String>();

		for (RFQItemHolder row : exportList) {
			selectedIds.add(row.item.Id);
		}

		String selectedIdString = String.join(selectedIds, ',');

        Boolean isBU = RFQSystemSettings.getIsBUUser();
        Boolean isHybrid = RFQSystemSettings.getIsHybridUser();

        if(!isBU || isHybrid) {
			if (!isMasterFormat) {
				RFQItemDao.getInstance().setItemsQuoted(RFQItemHolder.getItemList(exportList));
				RFQExportUtil.generatePdfQuote(rfq, selectedIdString, '', '', '', '');
			}
	    }

		attachmentId = RFQExportUtil.generateCsvQuote(rfq, selectedIdString, isMasterFormat);

		wasExported = true;

		return null;
	}

	private Boolean validateHasMapping(List<RFQItemHolder> rfqItems) {
		String mapId = rfq.RFQ_Account_File_Map__c;

		List<RFQ_Ac_Map_Pf__c> pfMaps = AccountFileMapDao.getInstance().getPfMapsByMapId(mapId);

		// Go through each item and make sure a corresponding PF mapping is found, if not then return false
		for (RFQItemHolder itemRow : rfqItems) {
			Boolean foundMapping = false;

			for (RFQ_Ac_Map_Pf__c pfMap : pfMaps) {
				if (StringUtils.isMatch(pfMap.Package_Family__c, itemRow.item.Package_Family__c)) {
					foundMapping = true;
				}
			}

			if (!foundMapping) return false;
		}

		return true;
	}

	public static List<RFQItemHolder> getHolderList(List<RFQ_Item__c> itemList) {
		List<RFQItemHolder> result = new List<RFQItemHolder>();

		for (RFQ_Item__c item : itemList) {
			result.add(new RFQItemHolder(item));
		}
		return result;
	}
}