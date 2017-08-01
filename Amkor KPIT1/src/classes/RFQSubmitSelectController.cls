public with sharing class RFQSubmitSelectController extends BaseController {
	
    private static String ALL = 'ALL';
	private static String ONLY_SELECTED = 'ONLY_SELECTED';
	public Boolean exportAvailable { get; set; }
	public RFQ__c rfq;
	public List<RFQItemHolder> rfqItems { get; set; }
	public String selectionMode { get; set; }

	public RFQSubmitSelectController() {

	    String rfqId = getParam('rfqId');
		rfq = RFQDao.getInstance().getRfqById(rfqId);
		List<RFQ_Item__c> itemList = RFQItemDao.getInstance().getReadyRfqItemssByRfqId(rfq.Id);
		rfqItems = getHolderList(itemList);
		exportAvailable = true;
	}

    public PageReference submitItems() {
		
		if (StringUtils.isBlank(selectionMode)) {
			addError('Please select which items you wish to export');
			return null;
		}

		List<RFQItemHolder> exportList = new List<RFQItemHolder>();

		if (StringUtils.isMatch(selectionMode, ALL)) {
			exportList = rfqItems;
		}
		else {
			for (RFQItemHolder row : rfqItems) {
				if (row.selected) exportList.add(row);
			}
		}

		Integer listSize = exportList.size();

		if (listSize == 0) {
			addError('Please select at least one item to submit');
			return null;
		}
		List<RFQ_Item__c> selectedItems = new List<RFQ_Item__c>();

		for (RFQItemHolder row : exportList) {
			selectedItems.add(new RFQ_Item__c(Id=row.item.Id,Status__c = RFQItemDao.STATUS_PRICE_SUBMIT));
		}
		update selectedItems;

        String firstId = selectedItems[0].Id;
        PageReference pg = new PageReference('/apex/RFQItemAutoSubmit?id='+firstId + '&numberLeft='+listSize);
        pg.setRedirect(true);
        return pg;
	

	}

	

	public static List<RFQItemHolder> getHolderList(List<RFQ_Item__c> itemList) {
		List<RFQItemHolder> result = new List<RFQItemHolder>();

		for (RFQ_Item__c item : itemList) {
			result.add(new RFQItemHolder(item));
		}
		return result;
	}

	public List<SelectOption> getExportOptions() {
		List<SelectOption> results = new List<SelectOption>();
		results.add(new SelectOption(ALL, 'All'));
		results.add(new SelectOption(ONLY_SELECTED, 'Selected'));
		return results;
	}
}