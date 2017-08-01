/*************************************************************************
*
* PURPOSE: Allows user to enter in an account adder charge
*
* CLASS: AccountAdderChargeController
* CREATED: 3/12/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Nathan Pilkington
***************************************************************************/

public with sharing class AccountAdderChargeController extends BaseController {

	public static final String ADDER_OTHER = 'OTHER';

	public RFQ_Account_Adder_Cost__c adderCost { get; set; }

	public String adderId { get; set; }

	public List<MatchCriteriaHolder> matchCriteria { get; set; }

	private List<RFQ_Acct_Adder_Match_Crit__c> removeList = new List<RFQ_Acct_Adder_Match_Crit__c>();

	public AccountAdderChargeController() {
		String accountId = getParam('accountId');

		if (StringUtils.isBlank(accountId)) {
			addError('Account ID Not specified');
		}

		adderCost = new RFQ_Account_Adder_Cost__c(Account__c = accountId);

		matchCriteria = new List<MatchCriteriaHolder>();
	}

	public Boolean getCanEdit() {
		return !ApprovalUtils.isUnderApproval(adderCost.Id);
	}

	public AccountAdderChargeController(ApexPages.Standardcontroller sc) {
		adderCost = (RFQ_Account_Adder_Cost__c)sc.getRecord();

		matchCriteria = new List<MatchCriteriaHolder>();

		if (!StringUtils.isBlank(adderCost.Id)) {
			adderCost = AccountAdderCostDao.getInstance().getById(adderCost.Id);
			List<RFQ_Acct_Adder_Match_Crit__c> children = AccountAdderCostMatchCriteriaDao.getInstance().getByParent(adderCost.Id);
			for (RFQ_Acct_Adder_Match_Crit__c row : children) {
				matchCriteria.add(new MatchCriteriaHolder(row));
			}
		}

		if (adderCost.Is_Other_Adder__c) {
			adderId = ADDER_OTHER;
		}
		else {
			adderId = adderCost.Adder__c;
		}
	}

	public List<SelectOption> getProductGroups() {
		List<Product_Group__c> productGroups = ProductGroupDao.getInstance().getAllProductGroups();

		List<SelectOption> results = new List<SelectOption>();

		results.add(new SelectOption('', '-- Select --'));

		for (Product_Group__c pg : productGroups) {
			results.add(new SelectOption(pg.Id, pg.Name));
		}

		return results;
	}

	public List<SelectOption> getPackageFamilies() {
		List<SelectOption> results = new List<SelectOption>();

		results.add(new SelectOption('', '-- Select --'));

		if (!StringUtils.isBlank(adderCost.Product_Group__c)) {
			List<Package_Family__c> pfList = PackageFamilyDao.getInstance().getFamiliesByProductGroup(adderCost.Product_Group__c);

			for (Package_Family__c pf : pfList) {
				results.add(new SelectOption(pf.Id, pf.Name));
			}
		}

		return results;
	}

	public String getAdderName() {
		List<SelectOption> adderFields = getAdderFields();

		for (SelectOption option : adderFields) {
			if (StringUtils.isMatch(option.getValue(), adderCost.Adder__c)) {
				return option.getLabel();
			}
		}

		return null;
	}


	public List<SelectOption> getAdderFields() {
		List<SelectOption> results = new List<SelectOption>();

		results.add(new SelectOption('', '-- Select --'));

		String pfId = null;

		if (!StringUtils.isBlank(adderCost.Package_Family__c)) {
			pfId = adderCost.Package_Family__c;
		} 
		else if (!StringUtils.isBlank(adderCost.Product_Group__c)) {
			// If not package family selected yet, then just use the first one from the selected product group

			List<Package_Family__c> pfList = PackageFamilyDao.getInstance().getFamiliesByProductGroup(adderCost.Product_Group__c);

			if (pfList.size() > 0) {
				pfId = pfList[0].Id;
			}
		}

		if (!StringUtils.isBlank(pfId)) {
			Package_Family__c packageFamily = PackageFamilyDao.getInstance().getById(pfId);
			List<RFQI_PF_Field_Def__c> fieldDefs = PFFieldDefDao.getInstance().getFieldsForPackageFamilySection(pfId, 'Adders');

			if (fieldDefs.size() == 0) {
				results.add(new SelectOption('', 'No Adders for This Product Group/Package Family'));
			} 
			else {
				String objName = packageFamily.Specific_RFQ_Item_Object__c;

				for (RFQI_PF_Field_Def__c fieldDef : fieldDefs) {
					String label = FieldLabelHelper.getInstance().getLabel(objName, fieldDef.RFQI_Field_Def__r.Name);
					results.add(new SelectOption(fieldDef.Id, label));
				}

				results.add(new SelectOption('OTHER', 'Other'));
			}
		}

		return results;
	}

	public PageReference addMatchCriteria() {
		matchCriteria.add(new MatchCriteriaHolder(new RFQ_Acct_Adder_Match_Crit__c()));
		return null;
	}

	public PageReference removeSelectedCriteria() {
		for (Integer i = matchCriteria.size() - 1; i >= 0; i--) {
			if (matchCriteria[i].selected != null && matchCriteria[i].selected) {
				if (!StringUtils.isBlank(matchCriteria[i].obj.Id)) {
					removeList.add(matchCriteria[i].obj);
				}

				matchCriteria.remove(i);
			}
		}
		return null;
	}


	public PageReference saveChargeItem() {

		adderCost.Is_Other_Adder__c = StringUtils.isMatch(adderid, ADDER_OTHER);

		if (adderCost.Is_Other_Adder__c) {
			adderCost.Adder__c = null;
		}
		else {
			adderCost.Other_Name__c = null;
			adderCost.Adder__c = adderId;
		}

		if (matchCriteria.size() > 0) {
			for (MatchCriteriaHolder row : matchCriteria) {
				if ((StringUtils.isBlank(row.obj.Body_Size__c) && StringUtils.isBlank(row.obj.Customer_Device_Name__c) && (row.obj.Lead_Ball_Count__c == null || row.obj.Lead_Ball_Count__c == 0)) || row.obj.Charge_Amount__c == null || row.obj.Charge_Amount__c == 0)
				{
					addError('Please enter a body size, lead/ball count, or customer device name and charge amount for each additional match criteria item');
					return null;
				}
			}
		}
		else if (matchCriteria.size() == 0 && adderCost.Additional_Match_Criteria__c) {
			addError('If you select "Additional Match Criteria" you must enter at least one criteria item');
		}

		if (!StringUtils.isBlank(adderCost.Product_Group__c) && (!StringUtils.isBlank(adderCost.Adder__c) || !StringUtils.isBlank(adderCost.Other_Name__c)) && adderCost.Charge_Amount__c > 0) {

			if (adderCost.All_Package_Families__c) {
				adderCost.Package_Family__c = null;
			}

			upsert adderCost;

			ApprovalUtils.startApproval(adderCost.Id, 'BU Review For Account Adder Cost');

			if (removeList.size() > 0) {
				delete removeList;
			}

			List<RFQ_Acct_Adder_Match_Crit__c> saveList = new List<RFQ_Acct_Adder_Match_Crit__c>();

			for (MatchCriteriaHolder row : matchCriteria) {
				row.obj.Parent__c = adderCost.Id;
				saveList.add(row.obj);
			}

			if (saveList.size() > 0) {
				upsert saveList;
			}

			return new PageReference('/' + adderCost.Account__c);
		}
		else {
			addError('Please select a product group and adder (or enter a name), and specify a charge amount');
		}

		return null;
	}

	public PageReference cancel() {
		return new PageReference('/' + adderCost.Account__c);
	}


	public class MatchCriteriaHolder {

		public Boolean selected { get; set; }
		public RFQ_Acct_Adder_Match_Crit__c obj { get; set; }

		public MatchCriteriaHolder(RFQ_Acct_Adder_Match_Crit__c obj) {
			this.obj = obj;
		}

	}


}