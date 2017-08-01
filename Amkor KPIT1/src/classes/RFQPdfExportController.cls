/*************************************************************************
* 
* PURPOSE:  This class provides the supporting functions for RFQPdfExport.page 
*         
* CLASS: RFQPdfExportController
* CREATED: 04/26/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Nathan Pilkington npilkington@ethos.com
* 
**************************************************************************/

public with sharing class RFQPdfExportController extends BaseController {
    
    public RFQ__c rfq { get; set; }
    
    public Account rfqAccount { get; set; }

    public String comments { get; set; }

    public Boolean showAdderDetailColumn { get; set; }

    public Boolean renderNrePage { get; set; }

    public String todayStr {get; set;}
    
    // Flat list of selected RFQ Item Wrappers (where price is 'Quoted' or 'Price Complete')
    public List<RFQItemWrapper> wrappers { get; set; }

    // Flat list of selected RFQ Item Wrappers (where price is 'Quoted' or 'Price Complete' and package family NOT TEST)
    public List<RFQItemWrapper> summaryWrappers { get; set; }

    // Flat list of selected RFQ Item Wrappers (where price is 'Quoted' or 'Price Complete' AND package family is TEST + Test Type is Final Test)
    public List<RFQItemWrapper> testSummaryWrappers { get; set; }

    // Flat list of selected RFQ Item Wrappers (where price is 'Quoted' or 'Price Complete' AND package family is TEST + Test Type is Wafer Probe)
    public List<RFQItemWrapper> probeSummaryWrappers { get; set; }

    // Flat list of selected TEST RFQI Insertion Configurations for Test Type Final Test
    public List<sObject> testConfigurations { get; set; }
    
    // Flat list of selected TEST RFQI Insertion Configurations for Test Type Wafer Probe/Strip Test
    public List<sObject> probeConfigurations { get; set; }

    // Map of Package Family ID -> Wrappers for that PF
    public Map<ID, List<RFQItemWrapper>> pfWrappers { get; set; }

    public Map<ID, List<RFQItemWrapper>> pfWrappersNotServiceSorted { get; set; }
    
    // Map of Package Family ID -> Wrappers for that PF that have lot charges
    public Map<ID, List<RFQItemWrapper>> lotChargeWrappers { get; set; }
    // Map of which package families have lot charge wrappers
    public Map<ID, Boolean> hasLotCharges { get; set; }

    // Map of which package families have items with NRE enabled and at least one NRE config/field with a price > 0
    public Map<ID, Boolean> pfHasNreItems { get; set; }

    // Map of which wrappers have at least one nre config/field with a price > 0
    public Map<Id, Boolean> wrapperHasNreItems {get; set;}
    
    // Map of Package Family ID -> Layout for that PF
    public Map<ID, RFQILayout> pfLayouts { get; set; }

    // Map of RFQI IDs -> Layout for that item
    public Map<ID, RFQILayout> wrapperLayouts { get; set; }

    // Hack: Map of RFQI IDs -> List containing that single Item (for the summary table to show up on the detail section)
    public Map<ID, List<RFQItemWrapper>> wrapperLists { get; set; }

    // String of RFQ Items that have children
    public Set <String> parentRFQItems { get; set; }

    // List of RFQQuoteSummaryItem objects to display
    public List<RFQQuoteSummaryItem> quoteSummaryItems { get; set; }

    //map to keep the summary items grouped by the name of the parent (top level) RFQI
    public Map<String, List<RFQQuoteSummaryItem>> summaryItemMap {get; set;}
    //map for showing summary on specific RFQ Items instead of showing all of them together
    public Map<String, List<RFQQuoteSummaryItem>> specificItemMap {get; set;}

    //list to maintain RFQIs that have post test services
    public List<RFQQuoteSummaryItem> postTestServiceItems {get; set;}
    public Map<String, RFQQuoteSummaryItem> postTestServiceMap {get; set;}

    public List<RFQQuoteSummaryItem> engineeringServicesItems {get; set;}

    public List<RFQQuoteSummaryItem> adderItems {get; set;}

    // Map of Factory Id->Factory Object
    public Map<Id, Factory__c> factories { get; set; }
    
    // List of all package families referenced in this RFQ
    public List<Package_Family__c> packageFamilies { get; set; }

    public List<Package_Family__c> nrePackageFamilies { get; set; }

    public List<RFQ_Account_Adder_Cost__c> adderCosts { get; set; }
    private Map<Id, List<RFQ_Acct_Adder_Match_Crit__c>> adderCostAdditionalCriteria = new Map<Id, List<RFQ_Acct_Adder_Match_Crit__c>>();
    
    public User accountRep { get; set; }


    public String separatePostTestList {get; set;}
    public Set<String> selectedSeparatePostTestItems {get; set;}
    public Map<String, Boolean> breakoutPostTestPriceMap {get; set;}

    public List<String> dummyList {get{return new List<String> { '1', '2', '3', '4'}; } }

    public Boolean hasEngineeringServices {get;set;}

    public String rfqisWithIncludedPrices {get; set;}

    public Map <String, Decimal> testTotalPrices {get; set;}

    public Set <String> addedPostTestServices {get; set;}
    public List<String> wrapperOrder {get;set;}
    //public Map<String, String> cpnNames {get;set;}
    public Map<String, String> rfqINamesMap {get;set;}


    public RFQPdfExportController() {
        try {
            String selectedRfqItemList = getParam('selectedRfqItems');
            String adderBreakoutList = getParam('adderBreakoutItems');
            separatePostTestList = getParam('separatePostTestItems');
            if (adderBreakoutList == null) adderBreakoutList = '';

            String lotChargeList = getParam('lotChargeItems');
            if (lotChargeList == null) lotChargeList = '';

            if (separatePostTestList == null) separatePostTestList = '';
            selectedSeparatePostTestItems = new Set<String>(separatePostTestList.split(','));
            breakoutPostTestPriceMap = new Map<String, Boolean>();
            
            comments = getParam('comments');

            factories = setupFactoryList();
            
            String rfqId = getParam('rfqId');
            rfq = RFQDao.getInstance().getRfqById(rfqId);

            rfqAccount = AccountDao.getInstance().getAccountById(rfq.SBU_Name__c);

            adderCosts = AccountAdderCostDao.getInstance().getByAccountId(rfq.SBU_Name__c);

            if (adderCosts.size() > 0) {
                adderCostAdditionalCriteria = setupAdditionalCriteriaFromAdders(adderCosts);
            }

            renderNrePage = false;
            showAdderDetailColumn = false;

            summaryItemMap = new Map<String, List<RFQQuoteSummaryItem>>();
            postTestServiceMap = new Map<String, RFQQuoteSummaryItem>();
            
            packageFamilies = PackageFamilyDao.getInstance().getAllPackageFamiliesByRfq(rfq.Id);
            nrePackageFamilies = packageFamilies.clone();

            hasEngineeringServices = false;

            rfqisWithIncludedPrices = '';

            testTotalPrices = new Map<String, Decimal>();
            addedPostTestServices = new Set<String>();
            
            wrappers = setupRfqItemWrappersFromRfq(rfq, packageFamilies, selectedRfqItemList, adderBreakoutList);
            
            pfWrappers = setupPfWrappers(wrappers);
            pfWrappersNotServiceSorted = setupPfWrappersUnsorted();
            
            lotChargeWrappers = setupLotChargeWrappers(wrappers, lotChargeList);
            
            // Remove unused package families
            
            for (Integer i = packageFamilies.size() - 1; i >= 0; i--) {
                if (!pfWrappers.containsKey(packageFamilies[i].Id)) {
                    packageFamilies.remove(i);
                }
                else if(packageFamilies[i].Name == 'Die Sales') packageFamilies[i].Name = 'Assembly - Die Sales';
            }

            packageFamilies.sort();

            for (Integer i = nrePackageFamilies.size() - 1; i >= 0; i--) {
                if (!pfWrappersNotServiceSorted.containsKey(nrePackageFamilies[i].Id)) {
                    nrePackageFamilies.remove(i);
                }
            }

            wrapperLists = new Map<ID, List<RFQItemWrapper>>();
            for (RFQItemWrapper wrapperRow : wrappers) {
                List<RFQItemWrapper> tempList = new List<RFQItemWrapper> { wrapperRow };
                wrapperLists.put(wrapperRow.rfqItem.Id, tempList);
            }

            accountRep = getAccountRepUser(rfqAccount);
            todayStr  = datetime.now().format('MM/dd/yyyy HH:mm z');

            
            for(RFQItemWrapper thisWrapper : wrappers){
                if(thiswrapper.packageFamily.Name == AMKVARS.PF_TEST && thisWrapper.specificRfqItem.get('Test_Type__c') == AMKVARS.TT_FINAL){ 
                    if(testSummaryWrappers == null) testSummaryWrappers = new List<RFQItemWrapper>();
                    testSummaryWrappers.add(thisWrapper);
                    if(thisWrapper.insertionConfigurations != null){
                        if(testConfigurations == null) testConfigurations = new List<sObject>();
                        for(sObject thisConfig : thisWrapper.insertionConfigurations) testConfigurations.add(thisConfig);
                    }
                }else if(thiswrapper.packageFamily.Name == AMKVARS.PF_TEST && thisWrapper.specificRfqItem.get('Test_Type__c') != AMKVARS.TT_FINAL){
                    if(probeSummaryWrappers == null) probeSummaryWrappers = new List<RFQItemWrapper>();
                    probeSummaryWrappers.add(thisWrapper);
                    if(thisWrapper.insertionConfigurations != null){
                        if(probeConfigurations == null) probeConfigurations = new List<sObject>();
                        for(sObject thisConfig : thisWrapper.insertionConfigurations) probeConfigurations.add(thisConfig);
                    }
                }else{
                    if(summaryWrappers == null) summaryWrappers = new List<RFQItemWrapper>();                   
                    summaryWrappers.add(thisWrapper);
                }

                //if(thisWrapper.rfqItem.Parent_RFQ_Item__c == null) parentRFQItems += thisWrapper.rfqItem.Parent_RFQ_Item__r.Name;

            }

        } catch (Exception e) {
            // Rethrow exception with more detailed information in the exception message, otherwise it
            // gets swallowed up when generating a quote
            throw new FieldBuilderHelperException('Error: ' + e.getMessage() + ' - ' + e.getStackTraceString());
        }
    }

    public Map<Id, Factory__c> setupFactoryList() {
        Map<Id, Factory__c> result = new Map<Id, Factory__c>(FactoryDao.getInstance().getAllFactories());
        return result;
    }

    public User getAccountRepUser(Account rfqAccount) {
        User user;

        if (rfqAccount.Display_User_name_as_Acct_Rep__c) {
            user = UserDao.getInstance().getCurrentUser();
        }
        else {
            user = UserDao.getInstance().getUserById(rfqAccount.OwnerId);
        }

        return user;
    }
    
    /**
    * This method gets all the RFQ_Item__c and specific RFQ Items
    * for the specified rfq and returns them in a list of RFQItemWrapper
    *
    * @param  rfq the Parent RFQ
    * @param packageFamilyList All the package families used by the rfq
    * @param selectedIdList A comma separated list of RFQ Item IDs selected to include in the quote (TODO find a better way to handle this)
    * @param adderBreakoutList A comma seperated list of which items were selected for adder breakout (TODO find a better way to handle this)
    */
    public List<RFQItemWrapper> setupRfqItemWrappersFromRfq(RFQ__c rfq, List<Package_Family__c> packageFamilyList, String selectedIdList, String adderBreakoutList) {
        Map<Id, Package_Family__c> pfMap = new Map<Id, Package_Family__c>(packageFamilyList);

        pfHasNreItems = new Map<Id, Boolean>();
        wrapperHasNreItems = new Map<Id, Boolean>();

        wrapperLayouts = new Map<ID, RFQILayout>();
        
        // Get all the layouts and specific items for the package families
        pfLayouts = new Map<Id, RFQILayout>();

        for (Package_Family__c pf : packageFamilyList) {
            // Get the layout
            //Because we dont have the rfq item here, just use the most recent version
            RFQILayout layout = PFFieldDefDao.getInstance().getPackageFamilyLayout(pf.Id, pf.Layout_Version__c, pf.Layout_Version__c, 'Sales');
            pfLayouts.put(pf.Id, layout);

            pfHasNreItems.put(pf.Id, false);

            // Setup dummy sections for any non-enabled sections to avoid VisualForce exception in the PDF page
            for (String sectionName : layout.enabledSections.keySet()) {
                if (!layout.enabledSections.get(sectionName)) {
                    layout.sectionMap.put(sectionName, new RFQILayoutSection(sectionName));
                }
            }           
            
        }
        
        // Setup the wrapper objects
        List<RFQItemWrapper> result = new List<RFQItemWrapper>();
        List<RFQ_Item__c> rfqItems = RFQItemDao.getInstance().getPriceCompleteByRfqId(rfq.Id, 'Name ASC');
        
        for (RFQ_Item__c rfqItem : rfqItems) {
            if (selectedIdList.contains(rfqItem.Id)) {
                wrapperHasNreItems.put(rfqitem.Id, false);

                RFQItemWrapper wrapper = new RFQItemWrapper();
                wrapper.rfqItem = rfqItem;
                wrapper.inflateSpecificObjectsFromJson();
                
                wrapper.adderCharges = new List<RFQItemWrapper.AdderCharge>();
                wrapper.packageFamily = pfMap.get(rfqItem.Package_Family__c);
                wrapper.productGroup = (Product_Group__c)wrapper.packageFamily.getsObject('Product_Group__r');

                if(wrapper.packageFamily.Product_Group_Name__c == 'Engineering Services') hasEngineeringServices = true;

                wrapper.applyFactoryName(factories);


                if (adderBreakoutList.contains(rfqItem.Id)) {
                    setupAdderCharges(wrapper);
                }

                RFQILayout layout = pfLayouts.get(rfqItem.Package_Family__c).copy();

                wrapper.setForecastMedian();
                wrapper.determineAttributeQuoteVisibility(layout); 
                wrapper.renderOtherFields(layout);
                wrapper.OtherFieldsChange(layout);

                for (String sectionName : layout.enabledSections.keySet()) {
                    if (!layout.enabledSections.get(sectionName)) {
                        layout.sectionMap.put(sectionName, new RFQILayoutSection(sectionName));
                    }
                }  

                result.add(wrapper);
                //construct the item to be used to display the summary
                pfLayouts.put(rfqItem.Package_Family__c,layout);
                wrapperLayouts.put(rfqItem.Id, layout);
                

                //NRE needs to be below layout setup, because it needs to check the NRE fields
                if (rfqItem.Include_NRE_On_Quote__c || ((rfqItem.NRE_Inclusion__c != null) && (rfqItem.NRE_Inclusion__c.equals('If Applicable') || rfqItem.NRE_Inclusion__c.equals('Required')))) {
                    Boolean hasNRE = false;
                    //only display nre section if at least one nre config has a price > 0
                    
                    
                    for (RFQISectionAttribute attribute : wrapperLayouts.get(rfqItem.Id).sectionMap.get('NRE').attributes)
                    {
                        
                        //Bhanu - 8-Feb-2016 : 597492 Missing NRE and T/C's incomplete on EXCEL version which can lead to wrong quote to customer
                        //Added Debug to check attributes on NRE
                        System.debug('--->'+attribute);
                        
                        if(attribute.dataType != 'Boolean') {
                            Decimal price = DataUtils.getDecimal(wrapper.specificRfqItem, attribute.fieldAPIName, 0);
                            if (price > 0)
                            {
                                hasNRE = true;
                                break;
                            }
                        }
                        else if (attribute.dataType == 'Boolean') {
                            if(DataUtils.getBoolean(wrapper.specificRfqItem, attribute.fieldAPIName, false)) {
                                hasNRE = true;
                                break;
                            }
                        }
                    }
                    if (!hasNRE)
                    {
                        for (sObject nre : wrapper.nreConfigurations)
                        {
                            Decimal price = DataUtils.getDecimal(nre, 'Price_New__c', 0);
                            if (price > 0)
                            {
                                hasNRE = true;
                                break;
                            }
                        }
                    }
                    
                    //whether this item has an nre with price > 0
                    wrapperHasNreItems.put(rfqItem.Id, hasNRE);

                    //whether any item in the package family has an nre with price > 0
                    pfHasNreItems.put(rfqItem.Package_Family__c, (pfHasNreItems.get(rfqItem.Package_Family__c) || hasNRE));
                    
                    //whether any item in any package family has an nre with price > 0
                    //if renderNREPage was false and hasNRE is true, set renderNRE to true
                    //if renderNREPage was true, it needs to stay true
                    renderNrePage = renderNrePage || hasNRE;
                }
                setupQuoteItemFromWrapper(wrapper, layout);
            }
        }
        //perform final steps to prepare list of objects to be displayed on summary

        setupSummarySection();
        
        
        return result;
    }

    private void setupAdderCharges(RFQItemWrapper wrapper) {
        if (adderCosts != null && adderCosts.size() > 0) {
            Map<String, RFQ_Account_Adder_Cost__c> applicableCharges = new Map<String, RFQ_Account_Adder_Cost__c>();

            for (RFQ_Account_Adder_Cost__c row : adderCosts) {
                String rfqPackageFamily = wrapper.rfqItem.Package_Family__r.Product_Group__c;
                String rfqProductGroup = wrapper.rfqItem.Package_Family__c;
                if ((StringUtils.isBlank(row.Package_Family__c) && StringUtils.isMatch(row.Product_Group__c, rfqPackageFamily)) || StringUtils.isMatch(row.Package_Family__c, rfqProductGroup)) {
                    String adderName = row.Is_Other_Adder__c ? row.Other_Name__c : row.Adder__c;

                    if (!applicableCharges.containsKey(adderName)) {
                        // No adder found yet, put it in
                        applicableCharges.put(adderName, row);
                    }
                    else {
                        // Adder found, see if it's a package family override
                        RFQ_Account_Adder_Cost__c existingAdder = applicableCharges.get(adderName);
                        if (StringUtils.isBlank(existingAdder.Package_Family__c) && !StringUtils.isBlank(row.Package_Family__c)) {
                            // Other one had a product group but no PF, and this one had a PF, so put this one in
                            applicableCharges.put(adderName, row);
                        }
                    }
                }
            }

            if (applicableCharges.keySet().size() > 0) {
                showAdderDetailColumn = true;
                wrapper.setupBasePriceFromAdders(applicableCharges.values(), adderCostAdditionalCriteria);
            }
            else {
                System.debug(LoggingLevel.Warn, 'No applicable adder charges found, skipping item: ' + wrapper.rfqItem.Id);
            }
        }
        else {
            System.debug(LoggingLevel.Warn, 'No adder charges on account');
        }
    }
    
    public Map<ID, List<RFQItemWrapper>> setupPfWrappersUnsorted() {
        
        Map<ID, List<RFQItemWrapper>> result = new Map<ID, List<RFQItemWrapper>>();
        List<RFQItemWrapper> tempList = new List<RFQItemWrapper>();
        
        //use a map of the itemId to wrapper in order to 
        for(List<RFQItemWrapper> w : pfWrappers.values()) tempList.addAll(w);

        for (RFQItemWrapper row : tempList) {
            Id pfKey = row.packageFamily.Id;
            if (!result.containsKey(pfKey)) {
                List<RFQItemWrapper> pfWrapperList = new List<RFQItemWrapper>();
                pfWrapperList.add(row);
                result.put(pfKey, pfWrapperList);
            }
            else {
                result.get(pfKey).add(row);
            }
        }
        return result;
    }
    
    private void setupNames(String id) {
        String tempString;
        for(RFQQuoteSummaryItem q : specificItemMap.get(id)) {
            if(q.serviceType != 'Post Test Services') {
                if(StringUtils.isBlank(tempString)) tempString = q.serviceType + ' ' + q.rfqiName;
                else tempString += ', ' + q.rfqiName;
            }
        }
        rfqINamesMap.put(id, tempString);
    }

    /**
    * This method sets up a map of Package Family ID -> Item Wrappers
    */
    public Map<ID, List<RFQItemWrapper>> setupPfWrappers(List<RFQItemWrapper> wrapperList) {
        
        Map<ID, List<RFQItemWrapper>> result = new Map<ID, List<RFQItemWrapper>>();
        List<RFQItemWrapper> childWrapperList = new List<RFQItemWrapper>();
        List<RFQItemWrapper> parentWrapperList = new List<RFQItemWrapper>();
        List<RFQItemWrapper> lostChildren = new List<RFQItemWrapper>();
        List<RFQItemWrapper> enginWrappers = new List<RFQItemWrapper>();
        Map<String, Set<RFQItemWrapper>> extraWrappers = new Map<String, Set<RFQItemWrapper>>();
        rfqINamesMap = new Map<String, String>();
        Set<Id> multiVolIds = new Set<Id>();

        List<RFQItemWrapper> tempWrapperList = new List<RFQItemWrapper>();
        for(String s : wrapperOrder) {
            for(RFQItemWrapper r : wrapperList) {
                if(r.rfqItem.Name == s) tempWrapperList.add(r);
            }
        }
            
        for (RFQItemWrapper row : tempWrapperList) {
            Id doubleID = (row.rfqItem.Parent_Volume_Item__c == null) ? row.rfqItem.Id : row.rfqItem.Parent_Volume_Item__c;
            if(row.rfqItem.Product_Group_Name__c == 'Engineering Services') enginWrappers.add(row);
            else if(row.rfqItem.Parent_RFQ_Item__c == null) {
                setupMultivolumeLists(multiVolIds, doubleID, row, parentWrapperList, extraWrappers);
            }
            else {
                setupMultivolumeLists(multiVolIds, doubleID, row, childWrapperList, extraWrappers);
            }
        }

        for(RFQItemWrapper parent : parentWrapperList) {
            if(!result.containsKey(parent.packageFamily.Id)) {
                result.put(parent.packageFamily.Id, new List<RFQItemWrapper>());
                result.get(parent.packageFamily.Id).add(parent);
            }
            else {
                result.get(parent.packageFamily.Id).add(parent);
            }
            for(RFQItemWrapper child : childWrapperList) {
                if(child.rfqItem.Parent_RFQ_Item__c == parent.rfqItem.Id) {
                    result.get(parent.packageFamily.Id).add(child);

                }
                else {
                    if(rfqINamesMap.get(parent.parentVolId).contains(child.rfqItem.Parent_RFQ_Item__r.Name)) {
                        result.get(parent.packageFamily.Id).add(child);
                    }
                    else {
                        if(extraWrappers.get(child.parentVolId) != null) {
                            Boolean added = false;
                            for(RFQItemWrapper r : extraWrappers.get(child.parentVolId)) {
                                if (r.rfqItem.Parent_RFQ_Item__r.Name != null && rfqINamesMap.get(parent.parentVolId).contains(r.rfqItem.Parent_RFQ_Item__r.Name) && !added) {
                                    result.get(parent.packageFamily.Id).add(child);
                                    added = true;
                                }
                            }
                        }
                    }
                }
            }
        }

        for(RFQItemWrapper child : childWrapperList) {
            Boolean shouldAdd = true;
            for(List<RFQItemWrapper> listW : result.values()) {
                for(RFQItemWrapper w : listW) {
                    if(child.rfqItem.Id == w.rfqItem.Id) shouldAdd = false;
                }
                
            }
            if (shouldAdd){
                lostChildren.add(child);
            }
        }

        for(RFQItemWrapper lostChild : lostChildren) {
            if(!result.containsKey(lostChild.packageFamily.Id)) {
                result.put(lostChild.packageFamily.Id, new List<RFQItemWrapper>());
                result.get(lostChild.packageFamily.Id).add(lostChild);
            }
            else {
                result.get(lostChild.packageFamily.Id).add(lostChild);
                result.get(lostChild.packageFamily.Id).sort();
            }
        }

        for(RFQItemWrapper e : enginWrappers) {
            if(!result.containsKey(e.packageFamily.Id)) {
                result.put(e.packageFamily.Id, new List<RFQItemWrapper>());
                result.get(e.packageFamily.Id).add(e);
            }
            else{
                result.get(e.packageFamily.Id).add(e);
            }
            e.parentVolId = e.rfqItem.Id;
            setupNames(e.parentVolId);
        }
        return result;
    }
    
    public class LotChargeItem {
        
        public String deviceName { get; set; }
        
    }

    public void setupMultivolumeLists(Set<Id> multiVolIds, Id doubleID, RFQItemWrapper row, List<RFQItemWrapper> targetList, Map<String, Set<RFQItemWrapper>> extraWrappers)
    {
        Boolean shouldBreakoutPrice = row.packageFamily.Name == AMKVARS.PF_TEST  && !(Boolean)row.getAttribute('Post_Test_Services_Single_Price__c', RFQItemWrapper.PACKAGE_OBJECT, 0);
        shouldBreakoutPrice |= selectedSeparatePostTestItems.contains(row.rfqItem.Id);
        
        if(!multiVolIds.contains(doubleID)) {
            targetList.add(row);
            multiVolIds.add(doubleID);
            row.parentVolId = doubleID;
            setupNames(doubleID);
            //if the item has the field checked or 
            //if the checkbox on pdf select page was checked
            //then breakout price
            breakoutPostTestPriceMap.put(doubleID, shouldBreakoutPrice);
        }
        else {
            if(extraWrappers.get(doubleID) == null) {
                extraWrappers.put(doubleID, new Set<RFQItemWrapper>{row});
            }
            else {
                extraWrappers.get(doubleID).add(row);
            }
            //if the item has the field checked or 
            //if the checkbox on pdf select page was checked or
            //if any item in this item's multivolume group (parent/siblings)
            //then breakout price
            Boolean oldValue = breakoutPostTestPriceMap.get(doubleID);
            breakoutPostTestPriceMap.put(doubleID, shouldBreakoutPrice || oldValue);
        }
    }
    
    public Map<ID, List<RFQItemWrapper>> setupLotChargeWrappers(List<RFQItemWrapper> wrapperList, String lotChargeList) {
        Map<ID, List<RFQItemWrapper>> result = new Map<ID, List<RFQItemWrapper>>();
        hasLotCharges = new Map<ID, Boolean>();

        List<Account_Lot_Charge__c> accountLotCharges = AccountLotChargeDao.getInstance().getByAccountId(rfqAccount.Id);

        System.debug('*** Got some lot charges: ' + accountLotCharges.size());
        RFQILayout layout;
        for (RFQItemWrapper row : wrapperList) {
            layout = pfLayouts.get(row.packageFamily.Id);
            if (!hasLotCharges.containsKey(row.packageFamily.Id)) {
                hasLotCharges.put(row.packageFamily.Id, false);
            }
            
            // If NRE Section enabled, check for lot charges (added '== true' because the unit test was throwing an exception otherwise...)
            if (layout != null && layout.enabledSections != null && layout.enabledSections.get('NRE') == true && layout.sectionMap != null && layout.sectionMap.get('NRE') != null) {
                row.lotCharges = new List<RFQItemWrapper.AdderCharge>();

                RFQILayoutSection nreSection = layout.sectionMap.get('NRE');
                
                Boolean hasLotChargeValue = false;
                
                for (RFQISectionAttribute attrib : nreSection.attributes) {
                    if (attrib.isLotCharge) {
                        Decimal value = (Decimal)row.specificRfqItem.get(attrib.fieldAPIName);
                        if (value != null && value > 0) hasLotChargeValue = true;
                    }
                }

                Map<String, Account_Lot_Charge__c> matchCharges = new Map<String, Account_Lot_Charge__c>();

                if (lotChargeList.contains(row.rfqItem.Id)) {
                    for (Account_Lot_Charge__c lotCharge : accountLotCharges) {
                        String lotChargePg = lotCharge.Product_Group__c;
                        String lotChargePf = lotCharge.Package_Family__c;
                        String wrapperPg = row.rfqItem.Package_Family__r.Product_Group__c;
                        String wrapperPf = row.rfqItem.Package_Family__c;

                        System.debug('*** lotChargePg: ' + lotChargePg + ' -- lotChargePf: ' + lotChargePf + ' -- wrapperPg: ' + wrapperPg + ' -- wrapperPf: ' + wrapperPf);

                        if (StringUtils.isMatch(lotChargePg, wrapperPg) && (StringUtils.isBlank(lotChargePf) || StringUtils.isMatch(lotChargePf, wrapperPf))) {
                            if (matchCharges.containsKey(lotCharge.Charge_Name__c)) {
                                // See if the current one overrides the previously added one
                                if (StringUtils.isBlank(matchCharges.get(lotCharge.Charge_Name__c).Package_Family__c) && !StringUtils.isBlank(lotChargePf)) {
                                    matchCharges.put(lotCharge.Charge_Name__c, lotCharge);
                                }
                            }
                            else {
                                matchCharges.put(lotCharge.Charge_Name__c, lotCharge);
                            }
                        }
                    }
                }
                if (matchCharges.keySet().size() > 0) {
                    hasLotChargeValue = true;
                    
                    for (Account_Lot_Charge__c lotCharge : matchCharges.values()) {
                        row.lotCharges.add(new RFQItemWrapper.AdderCharge(lotCharge.Charge_Name__c, lotCharge.Charge_Amount__c, lotCharge.Volume_Quantity__c));
                    }   
                } 
                
                if (hasLotChargeValue) {
                    if (!result.containsKey(row.packageFamily.Id)) {
                        result.put(row.packageFamily.Id, new List<RFQItemWrapper>());
                    }
                
                    result.get(row.PackageFamily.Id).add(row);
                    
                    hasLotCharges.put(row.packageFamily.Id, true);
                    renderNrePage = true;
                }
            }
        }
        
        return result;
    }

    private Map<Id, List<RFQ_Acct_Adder_Match_Crit__c>> setupAdditionalCriteriaFromAdders(List<RFQ_Account_Adder_Cost__c> adders) {
        Map<Id, List<RFQ_Acct_Adder_Match_Crit__c>> result = new Map<Id, List<RFQ_Acct_Adder_Match_Crit__c>>();

        Set<Id> addersIds = new Set<Id>();

        for (RFQ_Account_Adder_Cost__c adderRow : adders) {
            addersIds.add(adderRow.Id);
        }

        // Apologies for the raw SOQL, it was the cleanest way to get the in clause working...
        List<RFQ_Acct_Adder_Match_Crit__c> allCriteria = [Select Id, Body_Size__c, Customer_Device_Name__c, Charge_Amount__c, Lead_Ball_Count__c, Parent__c
                                                            from RFQ_Acct_Adder_Match_Crit__c where Parent__c in :addersIds];

        for (RFQ_Acct_Adder_Match_Crit__c critRow : allCriteria) {
            if (!result.containsKey(critRow.Parent__c)) {
                result.put(critRow.Parent__c, new List<RFQ_Acct_Adder_Match_Crit__c>());
            }

            result.get(critRow.Parent__c).add(critRow);
        }

        return result;
    } 
    
    
    public List<RFQISectionAttribute> getDummyAttributeList() {
        return new List<RFQISectionAttribute>();    
    }


    // Return the account number, with all leading zeros removed (AMK-1465)
    public String getAccountNumber() {
        String accountNumber = rfqAccount.AccountNumber;
        if (!StringUtils.isBlank(accountNumber)) accountNumber = accountNumber.replaceFirst('^0+(?!$)', '');
        return accountNumber;
    }

    public String getParentAccountNumber() {
        String accountNumber = '';
        if (rfqAccount.Parent != null && !StringUtils.isBlank(rfqAccount.Parent.AccountNumber)) {
            accountNumber = rfqAccount.Parent.AccountNumber;
            accountNumber = accountNumber.replaceFirst('^0+(?!$)', '');
        }
        

        return accountNumber;
    }

    private void setupQuoteItemFromWrapper(RFQItemWrapper wrapper, RFQILayout layout){

        if(quoteSummaryItems == null) quoteSummaryItems = new List<RFQQuoteSummaryItem>();
        System.debug('Lalit quoteSummaryItems  #729: '+quoteSummaryItems);

        RFQQuoteSummaryItem tempItem = new RFQQuoteSummaryItem(wrapper, layout);
        System.debug('#732 tempItem : '+tempItem);

        Decimal tempNreTotal = 0;

        if (pfHasNreItems.get(wrapper.packageFamily.Id)) {
            List<RFQISectionAttribute> nreAttributes = layout.sectionMap.get('NRE').attributes;
            if(nreAttributes != null && !nreAttributes.isEmpty()){
                for(RFQISectionAttribute attr : nreAttributes){
                    DebugUtils.write('attr.fieldApiName', attr.fieldApiName);
                    try{//there are booleans that we don't want to blow this up so catch those exceptions
                        tempNreTotal += DataUtils.getDecimal(wrapper.specificRfqItem, attr.fieldAPIName, 0);
                    }catch(Exception ex){}
                }                   
            }
        }
        if(wrapper.getNumberOfNREConfigurations() > 0){
            for(sObject nreConfig : wrapper.nreConfigurations){
                tempNreTotal += DataUtils.getDecimal(nreConfig, 'Price_New__c', 0);
            }
        }

        if(tempNreTotal > 0) tempItem.nreTotal = tempNreTotal;

        //concatenate the various selected post test service names
        if (tempItem.packageFamilyName == AMKVARS.PF_TEST)
        {
            String sectionName;
            if(tempItem.serviceType == AMKVARS.TT_STRIP || tempItem.serviceType == AMKVARS.TT_FINAL || tempItem.testType == AMKVARS.TT_STRIP || tempItem.testType == AMKVARS.TT_FINAL || tempItem.serviceType == AMKVARS.TT_POST || tempItem.testType == AMKVARS.TT_POST) 
            {
                sectionName = 'Post Test Services';
            }
            else if (tempItem.serviceType == AMKVARS.TT_PROBE || tempItem.testType == AMKVARS.TT_PROBE)
            {
                sectionName = 'Post Test Services - Wafer Probe';
            }
            if (sectionName != null)
            {
                for(RFQISectionAttribute attribute : layout.sectionMap.get(sectionName).attributes){
                    try{
                        String postTestValue = DataUtils.getString(wrapper.specificRfqItem, attribute.fieldAPIName, '');
                        if(String.isNotBlank(postTestValue) && postTestValue != 'false'){
                            if(String.isBlank(tempItem.postTestServiceNames)){                                  
                                tempItem.postTestServiceNames += FieldLabelHelper.getInstance().getLabel('RFQI_TESTS__c', attribute.fieldAPIName);
                                system.debug(' 774 # tempItem.postTestServiceNames : '+tempItem.postTestServiceNames);
                            }else{
                                tempItem.postTestServiceNames += ', '+FieldLabelHelper.getInstance().getLabel('RFQI_TESTS__c', attribute.fieldAPIName);
                                system.debug(' 777 # tempItem.postTestServiceNames : '+tempItem.postTestServiceNames);
                            }
                        }           
                    }catch(Exception ex){}
                }
            }
        }
        if(tempItem.postTestServiceNames != null && !tempItem.postTestServiceNames.isWhitespace()){
            if(postTestServiceItems == null) postTestServiceItems = new List<RFQQuoteSummaryItem>();
            postTestServiceItems.add(tempItem);
        }

        if(summaryItemMap.get(tempItem.parentRfqItemName) == null || (tempItem.packageFamilyName == 'WLCSP' || tempItem.packageFamilyName == 'Die Processing Service' || tempItem.testType == AMKVARS.TT_PROBE || tempItem.packageFamilyName == AMKVARS.PF_WLCSP || tempItem.packageFamilyName == AMKVARS.PF_BUMP)){
            String key = (tempItem.packageFamilyName == 'WLCSP' || tempItem.packageFamilyName == 'Die Processing Service' || tempItem.testType == AMKVARS.TT_PROBE || tempItem.packageFamilyName == AMKVARS.PF_WLCSP || tempItem.packageFamilyName == AMKVARS.PF_BUMP) ? tempItem.rfqiName : tempItem.parentRfqItemName;
            List<RFQQuoteSummaryItem> tempList = new List<RFQQuoteSummaryItem>();
                tempList.add(tempItem);
                summaryItemMap.put(key, tempList);
        }else{
            List<RFQQuoteSummaryItem> tempList = summaryItemMap.get(tempItem.parentRfqItemName);
            System.debug('#794 tempList : '+tempList);
                if(tempList != null) tempList.add(tempItem);
                System.debug('#794 tempList : '+tempList);
                System.debug('#794 tempItem.parentRfqItemName : '+tempItem.parentRfqItemName);
                summaryItemMap.put(tempItem.parentRfqItemName, tempList);
                System.debug('#797 summaryItemMap : '+summaryItemMap);
        }
        if(!tempItem.hasParentRfqItem){
            if(parentRFQItems == null) parentRFQItems = new Set<String>();
            parentRFQItems.add(tempItem.parentRfqItemName);
        }
    }

    private void setupSummarySection(){
        Set<String> rfqItemNames = new Set<String>();
        rfqItemNames = summaryItemMap.keySet();

        Map<String, List<RFQQuoteSummaryItem>> assemblyDieItems = new Map<String, List<RFQQuoteSummaryItem>>();
        Map<String, List<RFQQuoteSummaryItem>> waferItems = new Map<String, List<RFQQuoteSummaryItem>>();

        for(String rfqiKey : rfqItemNames){//iterate over all RFQI names
            //get list of items related to this RFQI (parent + children)
            List <RFQQuoteSummaryItem> tempItemList = summaryItemMap.get(rfqiKey);
            System.debug(' #813 tempItemList : '+tempItemList);
            List <RFQQuoteSummaryItem> assemblyTestItems = new List<RFQQuoteSummaryItem>();
            //maintain whether or not a summary line has been added for this grouping of parent/child RFQIs yet
            Boolean addedAssemblyDieSummary = false;
            Boolean addedWaferSummary = false;

            if(tempItemList != null){

                //  tempItemList.sort();
                if(parentRFQItems == null) parentRFQItems = new Set<String>();

                if(parentRFQItems.contains(rfqiKey) && tempItemList.size() > 1){                        
                    String serviceType = 'Assembly';
                    Decimal tempPrice = 0;
                    Decimal tempNreTotal = 0;
                    Integer itemsToTotal = 0;
                    Set <String> assemblyDieUOMTypes = new Set<String>();
                    Set <String> waferUOMTypes = new Set<String>(); 

                    for(RFQQuoteSummaryItem uomItem : tempItemList){

                        Boolean isAssemblyDieType = (uomItem.serviceType == 'Assembly' || uomItem.serviceType == AMKVARS.TT_FINAL || uomItem.serviceType == AMKVARS.TT_STRIP || uomItem.serviceType == 'Assembly - Die Sales' || uomItem.serviceType == AMKVARS.TT_POST);
                        Boolean isWaferType = (uomItem.serviceType == 'Bump' || uomItem.serviceType == AMKVARS.TT_PROBE || uomItem.serviceType == 'Reflow');

                        if(isAssemblyDieType || uomItem.engineeringServiceFields.keySet().contains(uomItem.packageFamilyName)){
                            if(uomItem.serviceType != 'Assembly'){
                                assemblyDieUOMTypes.add(uomItem.serviceType);
                            }
                        }else if(isWaferType){
                            waferUOMTypes.add(uomItem.serviceType);
                        }   
                    }       

                    for(RFQQuoteSummaryItem item : tempItemList){
                        Boolean isAssemblyDieType = (item.serviceType == 'Assembly' || item.serviceType == AMKVARS.TT_FINAL || item.serviceType == AMKVARS.TT_STRIP || item.serviceType == 'Assembly - Die Sales' || item.serviceType == AMKVARS.TT_POST);
                        Boolean isWaferType = (item.serviceType == 'Bump' || item.serviceType == AMKVARS.TT_PROBE || item.serviceType == 'Reflow' || item.packageFamilyName == 'Die Processing Service (WLCSP)' || item.packageFamilyName == 'WLCSP' || item.packageFamilyName == AMKVARS.PF_WLCSP);

                        if(item.postTestServiceNames != null && !item.postTestServiceNames.isWhitespace() && item.serviceType  != AMKVARS.TT_POST){
                            postTestServices(item, 'text-align: right');
                        }

                        if(showAdderDetailColumn && item.adderItems != null){
                            if(adderItems == null) adderItems = new List<RFQQuoteSummaryItem>();
                            Decimal adderTotal = 0;
                            String selectedAdders = '';
                            RFQQuoteSummaryItem adderItem = new RFQQuoteSummaryItem();
                            for(RFQItemWrapper.AdderCharge adder : item.adderItems){
                                if(selectedAdders.isWhitespace()){
                                    selectedAdders += adder.name;
                                }else{
                                    selectedAdders += ', '+adder.name;
                                }
                                adderTotal += adder.amount;
                            }

                            item.adderTotal = adderTotal;
                        }       

                        Set<String> serviceTypeSet = new Set<String>();

                        if(item.serviceType != 'Post Test Services' && item.serviceType != 'Adders' && item.hasParentRfqItem){
                            serviceTypeSet.add(item.packageFamilyName);
                        }

                        for(String thisServiceType : serviceTypeSet){
                            serviceType += ', '+thisServiceType;
                        }
                        
                        if(item.nreTotal != null) tempNreTotal += item.nreTotal;

                        if(item.serviceType != 'Post Test Services' && item.productGroupName != 'Engineering Services') item.style = 'text-align: center';
                        item.isSubtotalItem = true;                         

                        if(!addedAssemblyDieSummary && (isAssemblyDieType) && item.packageFamilyName != 'Die Processing Service' && item.packageFamilyName != AMKVARS.PF_BUMP){

                            RFQQuoteSummaryItem summaryLine = new RFQQuoteSummaryItem();
                            summaryLine.projectDeviceName = tempItemList[0].projectDeviceName;

                            //check each set to determine which service types are available for the different groupings
                            serviceType = 'Assembly';
                            for(String thisUOM : assemblyDieUOMTypes){
                                if(serviceType.isWhitespace()){
                                    serviceType = thisUOM;
                                }else{
                                    serviceType += ', '+thisUOM;
                                }
                            } 

                            summaryLine.serviceType = serviceType;
                            summaryLine.hasParentRfqItem = false;

                            if(assemblyDieItems.get(rfqiKey) == null) assemblyDieItems.put(rfqiKey, new List<RFQQuoteSummaryItem>());
                            assemblyDieItems.get(rfqiKey).add(summaryLine);
                            addedAssemblyDieSummary = true;

                        }
                        //else if( !addedWaferSummary && (isWaferType) ){

                        //  RFQQuoteSummaryItem summaryLine = new RFQQuoteSummaryItem();
                        //  summaryLine.projectDeviceName = tempItemList[0].projectDeviceName;

                        //  //check each set to determine which service types are available for the different groupings
                        //  serviceType = '';
                        //  for(String thisUOM : waferUOMTypes){
                        //      if(serviceType.isWhitespace()){
                        //          serviceType = thisUOM;
                        //      }else{
                        //          serviceType += ', '+thisUOM;
                        //      }

                        //  }

                        //  summaryLine.serviceType = serviceType;
                        //  summaryLine.hasParentRfqItem = false;

                        //  if(waferItems.get(rfqiKey) == null) waferItems.put(rfqiKey, new List<RFQQuoteSummaryItem>());
                        //  waferItems.get(rfqiKey).add(summaryLine);
                        //  addedWaferSummary = true;
                        //}
                    }               

                }else if(tempItemList.size() == 1){
                    RFQQuoteSummaryItem tmpItem = tempItemList[0];
                    system.debug(' #936 tmpItem : '+tmpItem);
                    if(tmpItem.packageFamilyName == AMKVARS.PF_TEST || tmpItem.packageFamilyName == AMKVARS.PF_BUMP|| tmpItem.productGroupName == 'Engineering Services') {
                        tempItemList[0].serviceType = (tmpItem.packageFamilyName == AMKVARS.PF_TEST) ? tmpItem.testType : tmpItem.packageFamilyName;
                    }
                    system.debug('938 tmpItem : '+tmpItem);
                    if(tmpItem.postTestServiceNames != null && !tmpItem.postTestServiceNames.isWhitespace() && tmpItem.serviceType  != AMKVARS.TT_POST){
                        system.debug('940 calling from here with tmpItem : '+tmpItem);
                        postTestServices(tmpItem, 'text-align: center');
                    }

                    if(showAdderDetailColumn && tmpItem.adderItems != null){
                        if(adderItems == null) adderItems = new List<RFQQuoteSummaryItem>();                            
                        Decimal adderTotal = 0;
                        String selectedAdders = '';
                        RFQQuoteSummaryItem adderItem = new RFQQuoteSummaryItem();
                        for(RFQItemWrapper.AdderCharge adder : tmpItem.adderItems){
                            if(selectedAdders.isWhitespace()){
                                selectedAdders += adder.name;
                            }else{
                                selectedAdders += ', '+adder.name;
                            }
                            adderTotal += adder.amount;

                            RFQAdderSummaryItem newAdder = new RFQAdderSummaryItem();
                            newAdder.adderName = adder.name;
                            newAdder.amount = adder.amount;
                            newAdder.rfqiName = tmpItem.rfqiName;

                        }

                        adderItem.serviceType = 'Adders';
                        adderItem.price = adderTotal;
                        tmpItem.adderTotal = adderTotal;
                        adderItem.description = selectedAdders;
                        adderItem.style = 'text-align: center';
                        adderItems.add(tmpItem);
                    }
                }               

                for(RFQQuoteSummaryItem tempItem : tempItemList){
                    DebugUtils.write('tempItem.rfqiName', tempItem.rfqiName);
                    if(tempItem.engineeringServiceFields.keySet().contains(tempItem.packageFamilyName)){
                        if(engineeringServicesItems == null) engineeringServicesItems = new List<RFQQuoteSummaryItem>();
                        engineeringServicesItems.add(tempItem);
                    }else{ 
                        if((tempItem.serviceType == 'Assembly' || tempItem.serviceType == AMKVARS.TT_FINAL || tempItem.serviceType == AMKVARS.TT_STRIP || tempItem.serviceType == 'Assembly - Die Sales' || tempItem.serviceType == AMKVARS.TT_POST) && (tempItem.hasParentRfqItem || parentRFQItems.contains(tempItem.parentRfqItemName) ) &&  assemblyDieItems.keySet().contains(tempItem.parentRfqItemName) ){                               
                            //quoteSummaryItems.add(tempItem);
                            DebugUtils.write('tempItem.parentRfqItemName', tempItem.parentRfqItemName);
                            assemblyDieItems.get(tempItem.parentRfqItemName).add(tempItem);
                            //waferItems.get(tempItem.parentRfqItemName).add(tempItem);
                        }else{
                            quoteSummaryItems.add(tempItem);
                            system.debug('quoteSummaryItems #985 : '+quoteSummaryItems);
                            system.debug('tempItem #986 : '+tempItem);
                            if(!StringUtils.isBlank(tempItem.postTestServiceNames) && tempItem.serviceType  != AMKVARS.TT_POST) {
                                postTestServices(tempItem, 'text-align: right');
                            }
                        }
                    }
    
                    if(specificItemMap == null) specificItemMap = new Map<String, List<RFQQuoteSummaryItem>>();
                    if(!specificItemMap.keySet().contains(tempItem.parentMultiVolId)){
                        specificItemMap.put(tempItem.parentMultiVolId, new List<RFQQuoteSummaryItem>());
                    }
                    if(tempItem.serviceType != 'Post Test Services'){
                            specificItemMap.get(tempItem.parentMultiVolId).add(tempItem);
                            specificItemMap.get(tempItem.parentMultiVolId).sort();
                    }
                    if(postTestServiceMap.keySet().contains(tempItem.rfqiName)){
                        if(!addedPostTestServices.contains(tempItem.rfqiName)){
                            //Abhay N- 24 April 2017- SF-198 RFQI'S with zero price should not be available to print on a quote: Added a condition to check PostTestPrice to be greater than zero. 
                            if(tempItem.totalPostTestPrice > 0){
                                specificItemMap.get(tempItem.parentMultiVolId).add(postTestServiceMap.get(tempItem.rfqiName));
                                addedPostTestServices.add(tempItem.rfqiName);
                                specificItemMap.get(tempItem.parentMultiVolId).sort();
                            }
                        }
                    }
                }                   
            }
        }

        for(String s : specificItemMap.keySet()) {
            for(RFQQuoteSummaryItem r : specificItemMap.get(s)) {
                if(r.serviceType != 'Post Test Services') r.style = 'text-align: center';
            }
        }

        List<RFQQuoteSummaryItem.RFQQuoteSummaryItemList> quoteList = new List<RFQQuoteSummaryItem.RFQQuoteSummaryItemList>();

        system.debug('LIne 1016 quoteSummaryItems :  '+quoteSummaryItems);
        for(RFQQuoteSummaryItem quoteItem : quoteSummaryItems) {
            RFQQuoteSummaryItem.RFQQuoteSummaryItemList quote = new RFQQuoteSummaryItem.RFQQuoteSummaryItemList();
            //Abhay N- 24 April 2017- SF-198 RFQI'S with zero price should not be available to print on a quote: Checked quoteItem to be greater than zero before adding it into the list.
            if(quoteItem.price>0){
                quote.quoteSummaryItems.add(quoteItem);
                quote.setForSort();
                system.debug('LIne 1016 quote :  '+quote);
                quoteList.add(quote);
                system.debug('LIne 1016 quoteList :  '+quoteList);
            }
            
        }

        quoteSummaryItems.clear();
        system.debug('quoteSummaryItems #1029 : '+quoteSummaryItems);
        
        for(String itemName : rfqItemNames){
            DebugUtils.write('itemName', itemName);
            system.debug('itemName #1033 : '+itemName);
            RFQQuoteSummaryItem.RFQQuoteSummaryItemList quote = new RFQQuoteSummaryItem.RFQQuoteSummaryItemList();
            if(assemblyDieItems.keySet().contains(itemName)) {
                for(RFQQuoteSummaryItem thisItem : assemblyDieItems.get(itemName)){
                    DebugUtils.write('thisItem.rfqiName', thisItem.rfqiName);
                    quote.quoteSummaryItems.add(thisItem);
                }
            }
            if(waferItems.keySet().contains(itemName)) {
                for(RFQQuoteSummaryItem thisItem : waferItems.get(itemName)){
                    quote.quoteSummaryItems.add(thisItem);
                }
            }
            quote.setForSort();

            if(quote.packageFamilyName != null) quoteList.add(quote);

            
        }
        if(engineeringServicesItems != null) engineeringServicesItems.sort();
        quoteList.sort();
        Set<String> hasMultiVol = new Set<String>();
        Set<String> wrapperName = new Set<String>();
        wrapperOrder = new List<String>();
        for(RFQQuoteSummaryItem.RFQQuoteSummaryItemList item : quoteList) {
            for(RFQQuoteSummaryItem i : item.quoteSummaryItems) {
                if(hasMultiVol.contains(i.parentMultiVolId) && item.serviceType != 'Bump' && item.packageFamilyName != 'Die Processing Service') {
                    i.projectDeviceName = null;
                    i.cpn = null;
                }
                else hasMultiVol.add(i.parentMultiVolId);
                quoteSummaryItems.add(i);
                if(postTestServiceMap.keyset().contains(i.rfqiName)) quoteSummaryItems.add(postTestServiceMap.get(i.rfqiName));
                if(!wrapperName.contains(i.rfqiName) && i.rfqiName != null) {
                    wrapperName.add(i.rfqiName);
                    wrapperOrder.add(i.rfqiName);
                }
            }
        }
        
        //Bhanu - 10 feb 2016 575798 - SFDC PDF RFQ - Volume Config out of sequence issue
        //debug to check contents of quoteSummaryItems
        for(RFQQuoteSummaryItem i: quoteSummaryItems)
            System.debug('--->'+i);

        //Abhay N- 24 April 2017- SF-198 RFQI'S with zero price should not be available to print on a quote: Iterated and eliminated RFQQuoteSummaryItem from quoteSummaryItems, if its price is less than zero
        for(Integer i=0;i<quoteSummaryItems.size();i++){
            System.debug('this is the price:: '+quoteSummaryItems[i].price);
            if(quoteSummaryItems[i].price<=0){
                quoteSummaryItems.remove(i);
            }
        } 

        if(engineeringServicesItems != null) {
            for(RFQQuoteSummaryItem q : engineeringServicesItems) {
                if(!wrapperName.contains(q.rfqiName) && q.rfqiName != null) {
                    wrapperName.add(q.rfqiName);
                    wrapperOrder.add(q.rfqiName);
                }
            }
        }
    }

    public RFQQuoteSummaryItem postTestServices(RFQQuoteSummaryItem item, String style) {
        RFQQuoteSummaryItem postTestItem = new RFQQuoteSummaryItem();
        postTestItem.serviceType = 'Post Test Services';
        postTestItem.style = style;
        System.debug('1091 postTestItem : '+postTestItem);
        postTestItem.forecastMed = item.forecastMed;
        postTestItem.packageFamilyName = item.packageFamilyName;
        System.debug('1094 postTestItem.packageFamilyName : '+postTestItem.packageFamilyName);
        postTestItem.description = item.postTestServiceNames;
        postTestItem.price = item.totalPostTestPrice;
        postTestItem.rfqiName = item.rfqiName;
        if(item.testType == AMKVARS.TT_PROBE) postTestItem.uom = '/Wafer';
        else postTestItem.uom = '/Unit';
        System.debug(' 1100 postTestItem.uom : '+postTestItem.uom);
        postTestItem.parentRfqItemName = item.rfqiName;
        postTestItem.hasParentRfqItem = true;

        postTestServiceMap.put(item.rfqiName, postTestItem);
        return postTestItem;
    }

    public String getIncludedPriceKeys(){
        String tmpKeyList = ' ';
        for(String thisKey : testTotalPrices.keySet()){
            tmpKeyList += thisKey+',';
        }
        return tmpKeyList;
    }
    
}