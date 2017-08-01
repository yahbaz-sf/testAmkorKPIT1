/*************************************************************************
* 
* PURPOSE:  This class is the controller for the BU Rfq Item excel export page
* CLASS: RFQBuExportController
* CREATED: 4/17/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Nathan Pilkington npilkington@ethos.com
* 
**************************************************************************/

public with sharing class RFQBUMultiExportController extends BaseController {

	public List<RfqItemHolder> currentItems { get; set; }
	public List<Package_Family__c> packageFamilyList { get; set; }


	public String selectedPackageFamily { get; set; }

	public String rfqId { get; set; }

	public String testType {get;set;}

	public String packageFamilyName {get;set;}
	

	public RFQBUMultiExportController() {
		rfqId = getParam('rfqId');
		packageFamilyList = PackageFamilyDao.getInstance().getAllPackageFamiliesByRfq(rfqId);

		if (packageFamilyList == null || packageFamilyList.size() == 0) {
			addInfo('No RFQ Items found for this RFQ');
		}
	}


	public PageReference returnToRfq() {
		return new PageReference('/apex/RFQView?id=' + rfqId);
	}

	public PageReference export() {

		List<RfqItemHolder> selectedItems = new List<RfqItemHolder>();

		if (currentItems != null && currentItems.size() > 0) {
			for (RfqItemHolder item : currentItems) {
				if (item.selected) selectedItems.add(item);
			}
		} else {
			addError('No items available for export');
			return null;
		}


		if (selectedItems.size() == 0) {
			addError('Please select at least one item for export');
			return null;
		}
		
		String selectedIdString = '';

		// TODO some better way to pass in a list? post params?
		for (RfqItemHolder holder : selectedItems) {
			if (!StringUtils.isBlank(selectedIdString)) selectedIdString += ',';
			selectedIdString += holder.item.Id;
		}

		return new PageReference('/apex/RFQBUExport?pfId=' + selectedPackageFamily + '&rfqId=' + rfqId + '&selectedIds=' + selectedIdString);
	}


	public List<SelectOption> getPackageFamilyOptions() {
		List<SelectOption> result = new List<SelectOption>();

		
		if (packageFamilyList == null || packageFamilyList.size() == 0) {
			result.add(new SelectOption('', 'No package families'));
		}
		else {
			result.add(new SelectOption('', '-- Select --'));

			for (Package_Family__c pf : packageFamilyList) {
				result.add(new SelectOption(pf.Id, pf.Name));
			}
		}

		return result;
	}

	public List<SelectOption> getTestTypeOptions(){

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- None Selected --'));
        options.add(new SelectOption(AMKVARS.TT_FINAL, AMKVARS.TT_FINAL));
        options.add(new SelectOption(AMKVARS.TT_PROBE, AMKVARS.TT_PROBE));
        options.add(new SelectOption(AMKVARS.TT_STRIP, AMKVARS.TT_STRIP));
        options.add(new SelectOption(AMKVARS.TT_POST, AMKVARS.TT_POST));

        return options;
    }



	public void setItemList() {
		currentItems = new List<RfqItemHolder>();
		testType = null;

		if (!StringUtils.isBlank(selectedPackageFamily)) {
			packageFamilyName = PackageFamilyDao.getInstance().getById(selectedPackageFamily).Name;
			if(packageFamilyName != 'Test') {
				List<RFQ_Item__c> rfqItems = RFQItemDao.getInstance().getByRfqAndPfId(rfqId, selectedPackageFamily);

				for (RFQ_Item__c item : rfqItems) {
					if(item.Status__c == RFQItemDao.STATUS_PRICE_PENDING_BU){
						currentItems.add(new RfqItemHolder(item));
					}
				}
			}
		}
	}

	public void setItemListForTest() {
		currentItems = new List<RfqItemHolder>();
		if (!StringUtils.isBlank(testType)) {
			List<RFQ_Item__c> rfqItems = RFQItemDao.getInstance().getByRfqAndPfId(rfqId, selectedPackageFamily);
			String fml = 'Test/' + testType;

			for (RFQ_Item__c item : rfqItems) {
					if(item.Status__c == RFQItemDao.STATUS_PRICE_PENDING_BU && item.Package_Family_Name_fml__c == fml){
						currentItems.add(new RfqItemHolder(item));
					}
				}
		}
	}

	public class RfqItemHolder {
		public Boolean selected { get; set; }
		public RFQ_Item__c item { get; set; }

		public RfqItemHolder(RFQ_Item__c rfqItem) {
			selected = false;
			item = rfqItem;
		}

	}
}