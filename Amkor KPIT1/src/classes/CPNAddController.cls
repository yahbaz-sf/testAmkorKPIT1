/*************************************************************************
*
* PURPOSE: Allows the user to enter in attributes to create a new configured
*          part number.
*
* CLASS: CPNAddController
* CREATED: 3/12/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Nathan Pilkington
***************************************************************************/

public with sharing class CPNAddController extends BaseController {

	public RFQItemWrapper itemWrapper { get; set; }
	
	public String itemPackageGroup { get; set; }
	public String itemPackageFamily { get; set; }

	public RFQILayout layout {get; set;}

    public static String dieConfigMessage {get {return 'Die Configuration 1 represents the bottom die configuration on the chip'; }}


	public CPNAddController(ApexPages.StandardController controller) { }

	/**
    * Passes in the rfq item holder object into the CPN dao which will create a new CPN if one
    * does not already exist
    */
	public PageReference createCpn() {
		if (itemPackageGroup == null || itemPackageFamily == null || itemWrapper == null) {
			addError('Please select a package group, package family, and enter the CPN attributes.');
			return null;
		}
		
		Package_Family__c packageFam = PackageFamilyDao.getInstance().getById(itemPackageFamily);
		CPN newCpn = CPNDao.getInstance().getCPN(itemWrapper);
		
		if (newCpn == null) {
			addError('Sorry, there was an error creating this CPN');
			return null;
		}
		
		return new PageReference('/' + newCpn.cpnId);
	}


	/**
    * This method returns the user to the CPN list page
    */
	public PageReference cancel() {
		if (itemWrapper != null) {
			if(!RFQItemDao.getInstance().deleteLineItem(itemWrapper)){
                addError('There was a problem deleting the line item. Please try again.');
            }
		}
		
		Schema.DescribeSObjectResult sa = Configured_Part_Number__c.sObjectType.getDescribe();
		String prefix = sa.getKeyPrefix();
		return new PageReference('/' + prefix + '/o');
	}

	/**
    * This method instantiates the SpecificRFQItem placeholder object and 
    * populates the layout
    */
	public PageReference setSelectedPackageFamily() {

		if (itemPackageFamily == null || itemPackageFamily.length() == 0) {
			addError('Please select a package family');
		}
		else {
			Package_Family__c packageFam = PackageFamilyDao.getInstance().getById(itemPackageFamily);
			
			// TODO What is the service type?
			RFQ_Item__c lineItem = RFQItemDao.getInstance().createItem(null, packageFam.Id, 'Assembly', 1, 1);
			
			itemWrapper = RFQItemDao.getInstance().getWrapperById(lineItem.Id);
			layout = setupLayout(itemWrapper);
			layout.removeNonCpnAttributes();
		}
		
		return null;
	}

	/**
	* This method instantiates the layout
	*/
	private RFQILayout setupLayout(RFQItemWrapper wrapper)
    {
        RFQILayout layout = PFFieldDefDao.getInstance().getPackageFamilyLayout(wrapper.packageFamily.Id, wrapper.packageFamily.Layout_Version__c, (Decimal)wrapper.rfqItem.get('Layout_Version__c'));

        //Loop over OtherAttributes, check if they contain other
        //if they do, add attribute 
        for(String fieldName : layout.getOtherFieldApiNames()) { 
            String fieldValue = String.valueOf(wrapper.getAttribute(fieldName, RFQItemWrapper.PACKAGE_OBJECT, 0));
            if(fieldValue != null && fieldValue.toLowerCase() == 'other') {
                layout.addAttributeForOtherField(fieldName);
            }
        }

        Decimal salesScreenColumns = wrapper.packageFamily.Product_Group__r.Sales_Screen_Columns__c;
        Decimal buScreenColumns = wrapper.packageFamily.Product_Group__r.BU_Screen_Columns__c;
        layout.setBUColumns(Integer.valueOf(bUScreenColumns));
        layout.setSalesColumns(Integer.valueOf(salesScreenColumns));

        wrapper.calculateAttributeVisibility(layout);
        return layout;
    }

	/**
    * This method adds a wire config object to the page based on which PF is selected
    */
	public PageReference addWireConfiguration() {

		Package_Family__c packageFam = PackageFamilyDao.getInstance().getById(itemPackageFamily);
		String wireObjectType = packageFam.Specific_Wire_Configuration_Object__c;	
		Schema.SObjectType wireTargetType = Schema.getGlobalDescribe().get(wireObjectType);
		sObject specificWireConfiguration = wireTargetType.newSObject(); 

		itemWrapper.wireConfigurations.add(specificWireConfiguration);

		return null;
	}

	/**
    * This method removes the last wire config from the page
    */
	public PageReference removeWireConfiguration() {
		
		if (itemWrapper.wireConfigurations.size() > 1) {
			itemWrapper.wireConfigurations.remove(itemWrapper.wireConfigurations.size()-1);
		}

		return null;
	}
	
	
	/**
    * This method adds a die config object to the page based on which PF is selected
    */
	public PageReference addDieConfiguration() {
		
		Package_Family__c packageFam = PackageFamilyDao.getInstance().getById(itemPackageFamily);
		String dieObjectType = packageFam.Specific_Die_Configuration_Object__c;	
		Schema.SObjectType dieTargetType = Schema.getGlobalDescribe().get(dieObjectType);
		sObject specificDieConfiguration = dieTargetType.newSObject(); 

		itemWrapper.dieConfigurations.add(specificDieConfiguration);

		return null;
	}
	
	/**
    * This method removes the last die config from the page
    */
	public PageReference removeDieConfiguration() {
		
		if (itemWrapper.dieConfigurations.size() > 1) {
			itemWrapper.dieConfigurations.remove(itemWrapper.dieConfigurations.size()-1);
		}

		return null;
	}


	public List<SelectOption> getPackageGroups() {
		
		List<Product_Group__c> productGroups = ProductGroupDao.getInstance().getAllProductGroups();
		    
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('','-- None Selected --'));
		for(Product_Group__c productGroup : productGroups) {
			options.add(new SelectOption(productGroup.Id,productGroup.Name));
		} 
		return options;
	}


	public List<SelectOption> getPackageFamilies() {
		
		List<Package_Family__c> packageFamilies = PackageFamilyDao.getInstance().getFamiliesByProductGroup(itemPackageGroup);
		    
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('','-- None Selected --'));
		for(Package_Family__c packageFamily : packageFamilies) {
			options.add(new SelectOption(packageFamily.Id,packageFamily.Name));
		}
		return options;
	}

	public Boolean getShowAttributes() {
		System.debug('### itemPackageFamily is: ' + itemPackageFamily);

		return itemPackageFamily != null && itemPackageFamily.length() != 0;
	}

}