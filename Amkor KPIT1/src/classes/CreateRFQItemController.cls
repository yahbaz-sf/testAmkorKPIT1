/*************************************************************************
 * 
 * PURPOSE:  controller for CreateRFQItem page
 *          
 *         
 * CLASS: CreateRFQItemController
 * CREATED: 03/06/2013 Ethos Solutions - www.ethos.com
 * AUTHOR: Jason Swenski  
 * 
 **************************************************************************/
public with sharing class CreateRFQItemController extends BaseController{

    public String rfqId;
    private String oppId;
    private Boolean isNewProduct;
    public RFQ_Item__c rfqItem {get; set;}
    public String itemPackageGroup {get; set;}
    public String itemPackageFamily {get; set;}
    public String numberOfWires {get; set;}
    public String numberOfPassives {get; set;}
    public String numberOfInsertions {get; set;}
    public String numberOfServices {get; set;}
    public String numberOfDies {get; set;}
    public String packageType {get; set;}
    public String serviceDesignType {get; set;}
    public Boolean isOppOnly {get; set;}
    public String finalTestPackageFamily {get; set;}
    public String errorAddingItem = System.Label.AddItemError;

    public String finalTestProductGroup {get; set;}

    String[] breakdowns = new String[]{};


    public String testTimeUOM {get; set;}
    public String testUOM {get; set;}
    public String testBodyX {get; set;}
    public String testBodyY {get; set;}
    public String testBodyZ {get; set;}
    public String testBodySize {get; set;}
    public String testPackageLead {get; set;}
    public Boolean isBallLeadText {get; set;}
    public Boolean isBodySizeText {get; set;}
    public List<SelectOption> ballLeadOptions {get; set;}
    public List<SelectOption> bodySizeOptions {get; set;}
    public Boolean hasBodySizeEntry {get; set;}
    public Boolean hasBallLeadEntry {get; set;}
    public sObject specificRfqItem {get;set;}
    public String bodyXName {get;set;} //so we know what fields to validate
    public String bodyYName {get;set;} //so we know what fields to validate
    public String bodyZName {get;set;} //so we know what fields to validate
    public String ballLeadName {get;set;} //so we know what fields to validate
    public List<RFQI_PF_Field_Def__c> assemblyTestPfFieldDefs {get;set;}
    public String isFinalTestAddedService {get; set;}
    public String testType {get;set;}
    public String waferSize {get; set;}
    public String grossDiePerWafer {get; set;}

    public String otherService {get;set;}
    public String engineeringService {get;set;}
    public String advproduct {get;set;}
    public String packageFamilyName {get;set;}

    //For SiP AMK-2592
    public Boolean SiPQ1 {get;set;}
    public Boolean SiPQ2 {get;set;}
    public Boolean SiPQ3 {get;set;}

    //Bhanu 4-May-2016 New Logic Table
    public Boolean SiPQ4 {get;set;}
    public Boolean showNewLogicTable{set;get;}
    public Boolean isPageVisible{get;set;}


    //-- These just pass the CSS class name for required fields
    //-- Set by default, blanked if we conditionally do not want to require
    public String requiredInput {get; set;}
    public String requiredBlock {get; set;}

    //TODO - think this is defined elsewhere
    private static final Integer MAX_DIE = 16;
    private static final Integer MAX_WIRE = 16;
    private static final Integer MAX_PASSIVE = 16;
    private static final Integer MAX_INSERTION = 16;
    private static final Integer MAX_SERVICE = 16;

    public static final Set<String> testTimeUOMs = new Set<String>
    {
        '/Hr',
        '/Min',
        '/Sec',
        '/Month'
    };

    //These are package families that aren't SiP eligible
    public static final Set<String> notSiPPFs = new Set<String> {
        AMKVARS.PF_HERM,
        AMKVARS.PF_BUMP,
        AMKVARS.PF_DPS,
        AMKVARS.PF_DS,
        AMKVARS.PF_LF,
        AMKVARS.PF_WB,
        AMKVARS.PF_WLCSP
    };

    public CreateRFQItemController() {
        numberOfWires = '0';
        numberOfDies = '0';
        numberOfPassives = '0';
        numberOfInsertions = '0';
        numberOfServices = '0';
        itemPackageGroup = '';
        itemPackageFamily = '';

        isNewProduct = false;
        isOppOnly = false;
        SiPQ1 = false;
        SiPQ2 = false;

        requiredInput = 'requiredInput';
        requiredBlock = 'requiredBlock';
        hasBodySizeEntry = false;
        hasBallLeadEntry = false;
        isFinalTestAddedService = 'false';


        rfqId = getParam('rfqId');
        oppId = getParam('oppId');


        rfqItem = new RFQ_Item__c();
        isPageVisible = validateRFQICreation();

        if(!StringUtils.isBlank(rfqId)) {
            isNewProduct = [select New_Product_Development__c from RFQ__c where Id =: rfqId].New_Product_Development__c;

        }
        else {
            isOppOnly = !StringUtils.isBlank(oppId);
        }
    }
    //Bhanu S 09-Aug-2016-Salesforce 111
    /**
     * This method validates the CreateRFQItem page. 
     * If the Opportunity stage is 'RFQ/Quote' and the Primary Campaign Source is 'Samurai',
     * then the user is not allowed to add an RFQItem for that Opportunity or to its corresponding RFQ.
     */
    public boolean validateRFQICreation(){
        isPageVisible = true;
        if(!StringUtils.isBlank(oppId)) {
            //Lalit - 07-April-2017 : Salesforce-36 : Inactive accounts from SAP to SFDC
            //Added Account.Inactive__c in soql query
            Opportunity tempOpp = [Select Campaign.Name,AccountId,Account.Inactive__c from Opportunity where id=:oppId];
            if((StringUtils.isNotBlank(tempOpp.Campaign.Name))&&((tempOpp.Campaign.Name).equalsIgnoreCase('Samurai'))){
                isPageVisible = false;
                addError(errorAddingItem);       
            }
            //Lalit - 07-April-2017 : Salesforce-36 : Inactive accounts from SAP to SFDC
            //changed the if condition Now, it is checking the queried opportunity account is activ/inactive.
            else if(tempOpp.Account.Inactive__c == true){
                isPageVisible = false;
                addError('Cannot create Items for an Inactive SBU');
            }
            else{
                isPageVisible = true;
            }
        }
        return isPageVisible;
    }

    public PageReference hacks() {
        getAssemblyPfFieldDefs();
        return null;
    }

    public void resetSelection() {
        itemPackageFamily = null;
        otherService = null;
        engineeringService = null;
        packageFamilyName = null;
    }

    public void populateDefaultConfigurationNumbers() {
        //Bhanu 4-May-2016 : SALESFORCE-27 SiP Question changes - Text needs to be updated
        //Boolean to Show/Hide New Logic table  
        showNewLogicTable = false;

        System.debug('---> itemPackageFamily : '+itemPackageFamily);
        DebugUtils.write('Debug 1');

        if(StringUtils.isBlank(itemPackageGroup)) itemPackageFamily = null;

        if(StringUtils.isBlank(itemPackageFamily)) {
            packageFamilyName = null;
            return;
        } 
        Package_Family__c packageFamily;
        system.debug('Other Service :'+otherService);
        
        // Abhay 12 May 2017 SF-208 : Since Test Only is a static test and not an id. On selection of "Test Only" getting the "Test" Package family ID  by using getFamilyByName method
        if(otherService != 'Test Only'){
             packageFamily =  PackageFamilyDao.getInstance().getById(itemPackageFamily);
        }else{
             packageFamily =  PackageFamilyDao.getInstance().getFamilyByName('Standalone Services','Test');
             itemPackageFamily = packageFamily.id;
        }     
        packageFamilyName = packagefamily.Name;

        System.debug('---> packageFamilyName : '+packageFamilyName);

        //Bhanu 4-May-2016 : SALESFORCE-27 SiP Question changes - Text needs to be updated
        //Boolean to Show/Hide New Logic table  
        if(packageFamilyName == 'FC BGA' || packageFamilyName == 'FC CSP'){
            showNewLogicTable = true;
        }

        Decimal numPassive = packageFamily.Default_Number_Of_Passives__c;        
        Decimal numDie = packageFamily.Default_Number_Of_Die__c;        
        Decimal numWire = packageFamily.Default_Number_Of_Wires__c;        
        Decimal numInsertion = packageFamily.Default_Number_Of_Insertions__c;
        Decimal numService = packageFamily.Default_Number_Of_Services__c;            

        numberOfWires = normalizeDefault(numWire,RFQItemWrapper.WIRE_OBJECT);
        numberOfDies = normalizeDefault(numDie,RFQItemWrapper.DIE_OBJECT);
        numberOfPassives = normalizeDefault(numPassive,RFQItemWrapper.PASSIVE_OBJECT);
        numberOfInsertions = normalizeDefault(numInsertion,RFQItemWrapper.INSERTION_OBJECT);
        numberOfServices = normalizeDefault(numService,RFQItemWrapper.SERVICE_OBJECT);

        if(testType != null) {
            if(testType == AMKVARS.TT_POST) {
                numberOfInsertions = '0';
            }
        }

        //resetting this when user changes pg/pf
        serviceDesignType = null;
    }

    private String normalizeDefault(Decimal defaultNum, String objType) {
        if(defaultNum == null) return '0';
        Integer num = Integer.valueOf(defaultNum);
        if(objType == RFQItemWrapper.DIE_OBJECT && num > MAX_DIE) num = MAX_DIE;  
        else if(objType == RFQItemWrapper.WIRE_OBJECT && num > MAX_WIRE) num = MAX_WIRE; 
        else if(objType == RFQItemWrapper.PASSIVE_OBJECT && num > MAX_PASSIVE) num = MAX_PASSIVE; 
        else if(objType == RFQItemWrapper.INSERTION_OBJECT && num > MAX_INSERTION) num = MAX_INSERTION;
        else if(objType == RFQItemWrapper.SERVICE_OBJECT && num > MAX_SERVICE) num = MAX_SERVICE;
        return String.valueOf(num);
    }

    /**
     * Checks the page parameters and autocreates an RFQ Item if the package family already passed in,
     * returns null otherwise
     *
     * @returns a PageReference to the RFQ Item page if item was auto created ()
     */
    public PageReference autoCreateRedirect() {

        String packageFamilyId = getParam('packageFamilyId');

        if (!StringUtils.isBlank(packageFamilyId)) {
            Package_Family__c packageFamily =  PackageFamilyDao.getInstance().getById(packageFamilyId); 

            if(!StringUtils.isBlank(packageFamily.Specific_Insertion_Configuration_Object__c)){
                try {numberOfInsertions = getParam('numInsertions');}
                catch(exception e){}
            }

            if(!StringUtils.isBlank(packageFamily.Specific_Service_Configuration_Object__c)){
                numberOfServices = '1';
            }

            String serviceType = getParam('serviceType');
            String parentRfqItemId = getParam('parentRfqItemId');
            try {serviceDesignType = getParam('serviceDesignType');}
            catch(exception e){}
            try {testUOM = getParam('testUOM');}
            catch(exception e){}
            try {testTimeUOM = getParam('testTimeUOM');}
            catch(exception e){}
            try {isFinalTestAddedService = getParam('isFinalTestAddedService');}
            catch(exception e){}
            try {testType = getParam('testType');}
            catch(exception e){}
            try {waferSize = getParam('waferSize');}
            catch(exception e){}
            try {grossDiePerWafer = getParam('grossDiePerWafer');}
            catch(exception e){}
            if(getParam('SiP') == '1') SiPQ1 = true;
            itemPackageFamily = packageFamilyId;
            numberOfWires = '1';
            //TODO - might need to populate passives/insertions here?           

            return createLineItem(parentRfqItemId, serviceType);
        }

        return null;
    }

    /**
     * Cancel action returns you to the main RFQ page
     *
     * @returns a PageReference to the RFQ page
     */
    public PageReference cancel() {
        PageReference pg = null;
        if(isOppOnly) pg = new PageReference('/'+oppId);
        else pg = new PageReference('/'+rfqId);
        pg.setRedirect(true);
        return pg;
    }

    /**
     * Creates a line item for the specific package family
     *
     * @returns a PageReference to the RFQ Item page
     */
    public PageReference createLineItem() {

        if(StringUtils.isBlank(itemPackageFamily)) {
            addError('Please select a Product Group and Package Family');
            return null;
        }
        packageFamilyName = PackageFamilyDao.getInstance().getById(itemPackageFamily).Name;
        if(packageFamilyName == 'Design') {
            if(StringUtils.isBlank(serviceDesignType)) {
                addError('Please select a Service Type for the Design Service');
                return null;
            }
            if(serviceDesignType == 'New Design' || serviceDesignType == 'Other') {
                if(StringUtils.isBlank(packageType)) {
                    addError('Please select a Package Type for the Design Service');
                    return null;
                }
            }
        }
        if(packageFamilyName == AMKVARS.PF_TEST) {
            if(StringUtils.isBlank(finalTestPackageFamily) && testUOM != null) {
                addError('Please select a Package Type for the Test Service');
                return null;
            }

            if(StringUtils.isBlank(testUOM)){
                addError('Please select a Test Quote Unit of Measure');
                return null;
            }

            if(getIsTestPerTime() && StringUtils.isBlank(testTimeUOM)){
                addError('Please select a Time Unit of Measure');
                return null;
            }

            if(testType == null){
                addError('Please select a Test Type');
                return null;
            }

            if(getIsProbeUnit() && !grossDiePerWafer.isNumeric()){
                addError('Gross Die Per Wafer must be a number.');
                return null;
            }

        }
        return createLineItem(null, 'Assembly');
    }

    /**
     * Creates a line item for the specific package family, with an optional parent rfq item
     *
     * @param parentRfqItemId the ID of the parent RFQ Item
     * @returns a PageReference to the RFQ Item page
     */
    public PageReference createLineItem(String parentRfqItemId, String serviceType) {
        //TODO - add passives/insertions for specific prodgroups
        Package_Family__c packageFamily =  PackageFamilyDao.getInstance().getById(itemPackageFamily);
        if(testType == AMKVARS.TT_POST) {
            numberOfInsertions = '0';
        }
        debug.log('create rfqItem.packageFamily.Layout_Version__c', packageFamily.Layout_Version__c);
        rfqItem = RFQItemDao.getInstance().createItem(rfqId, itemPackageFamily, serviceType, 
                Integer.valueOf(numberOfWires), Integer.valueOf(numberOfDies),Integer.valueOf(numberOfInsertions),Integer.valueOf(numberOfPassives), packageFamily.Layout_Version__c, Integer.valueOf(numberOfServices));

        RFQItemWrapper childWrapper = RFQItemDao.getInstance().getWrapperById(rfqItem.Id);
        childWrapper.defaultFactory();
        //Abhay 12 May 2017 SF-208 : Making the Is_Test_Only_Business__c as true for Test Only Business
        if(otherService == 'Test Only'){
            childWrapper.rfqItem.Is_Test_Only_Business__c = true;
        }
        if((SiPQ1 || SiPQ2) && !notSiPPFs.contains(packageFamily.Name)) childwrapper.rfqItem.SiP__c = true;

        if(childWrapper.packageFamily.Name == 'Design') {
            if(serviceDesignType != null) {
                childWrapper.setAttribute('Service_Type__c','Package', serviceDesignType);
            }

            if(packageType != null) {
                childWrapper.setAttribute('Assembly_Package_Name__c','Package', packageType);
            }
        }

        //AMK-2212, AMK-2613 change default for CABGA and PBGA only AMK-2626 for SCSP and Flipchip
        if (childWrapper.packageFamily.Name == AMKVARS.PF_CABGA || childWrapper.packageFamily.Name == AMKVARS.PF_PBGA || childwrapper.productGroup.Name == AMKVARS.PG_SCSP || childwrapper.productGroup.Name == AMKVARS.PG_FC)
        {
            childWrapper.rfqItem.Consigned__c = 'Assembly plus Substrate';
        }

        if(childWrapper.rfqItem.Opportunity__c == null && !StringUtils.isBlank(oppId)) {
            childWrapper.rfqItem.Opportunity__c = oppId;
        }    

        if(childwrapper.packageFamily.Name == AMKVARS.PF_TEST) {

            if(testType != null) {
                childWrapper.setAttribute('Test_Type__c', 'Package', testType);
                childWrapper.rfqItem.Test_Type__c = testType;
            }


            if(finalTestPackageFamily != null) {
                String finalTestPackageFamilyName = null;
                try{
                    finalTestPackageFamilyName = PackageFamilyDao.getInstance().getById(finalTestPackageFamily).Name;
                }catch(Exception ex){
                    finalTestPackageFamilyName = 'W/B Wafer'; //Outlier that does not actually have an Object associated
                }

                childWrapper.setAttribute('Assembly_Package_Name__c','Package', finalTestPackageFamilyName);

                if(finalTestPackageFamilyName != 'W/B Wafer'){
                    childWrapper.rfqItem.Test_Package_Type__c = finalTestPackageFamily;
                }
            }
            if(!getIsTestPerTime()){               
                childWrapper.setAttribute('Test_Quote_Unit_of_Measure__c', 'Package', testUOM); 

                if(getIsProbeUnit()){
                    childWrapper.setAttribute('Wafer_Size_PK__c', 'Package', waferSize);
                    childWrapper.setAttribute('GDPW_PK__c', 'Package', Decimal.valueOf(grossDiePerWafer));
                    //hacks because packing method is defaulted to true, but wafer probe does not have packing method as a viewable field to change it
                    childWrapper.setAttribute('Packing_Method__c', 'Package', null);
                    System.Debug('---> in getIsProbeUnit part of line number 401'+childWrapper);
                }else{
                    childWrapper.setAttribute('Body_Size_X__c', 'Package', getBodySizeX());
                    System.Debug('---> in else part of line number 403'+childWrapper);
                    childWrapper.setAttribute('Body_Size_Y__c', 'Package', getBodySizeY());
                    childWrapper.setAttribute('Body_Size_Z__c', 'Package', getBodySizeZ());
                    DebugUtils.write('getBallLeadCount()', getBallLeadCount());
                    childWrapper.setAttribute('Ball_Lead_Count__c', 'Package', getBallLeadCount());

                }
            }
            else {
                childWrapper.setAttribute('Test_Quote_Unit_of_Measure__c', 'Package', testTimeUOM);
                childWrapper.setAttribute('Body_Size_X__c', 'Package', getBodySizeX());
                childWrapper.setAttribute('Body_Size_Y__c', 'Package', getBodySizeY());
                childWrapper.setAttribute('Body_Size_Z__c', 'Package', getBodySizeZ());
                childWrapper.setAttribute('Ball_Lead_Count__c', 'Package', getBallLeadCount());
                system.debug('childWrapper more else part of line number 418'+childWrapper);
            }

            //AMK-2491: add user role name to field for Test Approval Process TPM
            try {
                childWrapper.rfqItem.Creator_Role_Name__c = [select Name from UserRole where Id =: UserInfo.getUserRoleId()].Name;
            }
            catch (Exception e) {
                DebugUtils.write('Could not find role: ' + e);
            }
        }

        if (parentRfqItemId != null) {
            //RFQItemWrapper childWrapper = RFQItemDao.getInstance().getWrapperById(rfqItem.Id);
            RFQItemWrapper parentWrapper = RFQItemDao.getInstance().getWrapperById(parentRfqItemId);

            if (childWrapper.productGroup.Name == 'Standalone Services') {
                childWrapper.copyServiceFieldsFromParentNew(parentWrapper);
                if(waferSize != null && grossDiePerWafer != null) {
                    childWrapper.setAttribute('Wafer_Size_PK__c', 'Package', waferSize);
                    childWrapper.setAttribute('GDPW_PK__c', 'Package', Decimal.valueOf(grossDiePerWafer));
                }
            }

            if(childWrapper.productGroup.Name == 'Engineering Services') {
                childWrapper.copyServiceFieldsFromParentNew(parentWrapper);
            }

            //AMK-2279
            //reset multi volume list
            system.debug('before setting this is blank (childWrapper.rfqItem.Multi_Volume__c)  : '+childWrapper.rfqItem.Multi_Volume__c);
            childWrapper.rfqItem.Multi_Volume__c = '';
            system.debug('after setting this is as blank (childWrapper.rfqItem.Multi_Volume__c)  : '+childWrapper.rfqItem.Multi_Volume__c);
            system.debug('Calling from Here line 475 : ');
            childWrapper.inflateVolume();
            system.debug('childWrapper.volumeList  : '+childWrapper.volumeList);
            childWrapper.volumeList.clear();

            if (packageFamily.Name != AMKVARS.PF_BUMP && childWrapper.rfqItem.Test_Type__c != AMKVARS.TT_PROBE && packagefamily.Name != 'Die Processing Service (WLCSP)' &&  packageFamily.Name != 'WLCSP' && packageFamily.Name != 'WLCSP (Die Services)' && packagefamily.Name != 'Die Processing Service') {
                RFQIVolume newVolume;
                Map<String, Decimal> forecastMap;
                for (RFQIVolume volume : parentWrapper.volumeList)
                {
                    newVolume = new RFQIVolume(false);
                    newVolume.parentVolumeKey = volume.parentVolumeKey;
                    newVolume.volume = volume.volume;
                    newVolume.index = volume.index;
                    if(childWrapper.productGroup.Name == 'Engineering Services') {
                        if(childWrapper.serviceConfigurations != null && childWrapper.serviceConfigurations.size() > 0) {
                            for(sObject s : childWrapper.serviceConfigurations) {
                                newVolume.subTotals.add(DataUtils.getDecimal(s, 'Sub_Total__c', 0));
                            }
                        }
                    }
                    childWrapper.volumeList.add(newVolume);
                }
            }

            childWrapper.rfqItem.Parent_RFQ_Item__c = parentRfqItemId;

            //if (!RFQItemDao.getInstance().saveLineItem(childWrapper)) return null;
        }

        if(isOppOnly) {
            Opportunity opp = OpportunityDao.getInstance().getOppById(oppId);
            childWrapper.copyOppFieldsToWrapper(opp);
        }

        if (!RFQItemDao.getInstance().saveLineItem(childWrapper)) return null;

        PageReference pg = null;
        if(isOppOnly) {
            pg = new PageReference('/apex/RFQItemEdit?id='+rfqItem.Id +'&new=1&oppId='+oppId);
        }
        else {
            pg = new PageReference('/apex/RFQItemEdit?id='+rfqItem.Id +'&new=1');
        }

        pg.setRedirect(true);
        return pg;
    }

    /**
     * Gets the list product groups in the system as SelectOptions
     *
     * @returns List<SelectOption> of Product_Group__c
     */
    public List<SelectOption> getProductGroups() {

        List<Product_Group__c> productGroups = ProductGroupDao.getInstance().getProductGroups(false, false);

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- None Selected --'));
        for(Product_Group__c productGroup : productGroups) {
            //AMK-2346 - engineering service is no longer an added service, but it is shown differently on the create item page
            if (productGroup.Name != 'Engineering Services' && productGroup.Name != 'ALL')
            {
                options.add(new SelectOption(productGroup.Id,productGroup.Name));
            }
        }
        options.add(new SelectOption('Other Services', 'Other Services')); 
        return options;
    }

    public List<SelectOption> getPackageTypeOptions() {

        List<SelectOption> options = new List<SelectOption>();

        options.add(new SelectOption('','-- None Selected --'));
        if(serviceDesignType == 'Other') {
            options.add(new SelectOption('Bump','Bump'));
            options.add(new SelectOption('DFN','DFN'));
            options.add(new SelectOption('LQFP','LQFP'));
            options.add(new SelectOption('MLF','MLF'));
            options.add(new SelectOption('MQFP','MQFP'));
            options.add(new SelectOption('Other','Other'));
            options.add(new SelectOption('PDIP','PDIP'));
            options.add(new SelectOption('SOIC','SOIC'));
            options.add(new SelectOption('SSOP','SSOP'));
            options.add(new SelectOption('TQFP','TQFP'));
            options.add(new SelectOption('TSSOP','TSSOP'));
            options.add(new SelectOption('WLCSP','WLCSP'));
        }
        if(serviceDesignType == 'New Design') {
            options.add(new SelectOption('CABGA','CABGA'));
            options.add(new SelectOption('Cavity MEMS','Cavity MEMS'));
            options.add(new SelectOption('Cavity MEMS L2L','Cavity MEMS L2L'));
            options.add(new SelectOption('FC BGA','FC BGA'));
            options.add(new SelectOption('FC CSP','FC CSP'));
            options.add(new SelectOption('FC SCSP','FC SCSP'));
            options.add(new SelectOption('PBGA','PBGA'));
            options.add(new SelectOption('PoP','PoP'));
            options.add(new SelectOption('SCSP','SCSP'));
            options.add(new SelectOption('SiP','SiP'));
        }

        return options;
    }

    public List<SelectOption> getServiceTypeOptions() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- None Selected --'));
        options.add(new SelectOption('3D Design', '3D Design'));
        options.add(new SelectOption('Daisy Chain Design', 'Daisy Chain Design'));
        options.add(new SelectOption('Other', 'Other'));
        options.add(new SelectOption('New Design', 'New Design'));
        options.add(new SelectOption('Test Board Design', 'Test Board Design'));

        return options;
    }

    //public List<SelectOption> getBreakdownOptions() {

    //    List<SelectOption> options = new List<SelectOption>();
    //    options.add(new SelectOption('Quote_to_Customer_Price_per_Hour__c', 'Price per Hour'));
    //    options.add(new SelectOption('Quote_to_Customer_Price_per_Minute__c', 'Price per Minute'));
    //    options.add(new SelectOption('Quote_to_Customer_Price_per_Second__c', 'Price per Second'));
    //    options.add(new SelectOption('Quote_to_Customer_Price_per_Unit__c', 'Price per Unit'));

    //    return options;
    //}

    /**
     * Gets the number of wires as SelectOptions
     * 
     * @returns List<SelectOption> of numbers (1-16)
     */
    public List<SelectOption> getNumberOfWiresOptions() {
        return getNumberOptions(0,MAX_WIRE);
    }

    public List<SelectOption> getNumberOfPassivesOptions() {
        return getNumberOptions(0,MAX_PASSIVE);
    }

    public List<SelectOption> getNumberOfInsertionOptions() {
        return getNumberOptions(0,MAX_INSERTION);
    }

    /**
     * Gets the number of passives as SelectOptions
     * 
     * @returns List<SelectOption> of numbers (1-16)
     */
    public List<SelectOption> getNumberOfDiesOptions() {
        return getNumberOptions(0,MAX_DIE);
    }

    public List<SelectOption> getNumberOfServiceOptions() {
        return getNumberOptions(0,MAX_SERVICE);
    }

    private List<SelectOption> getNumberOptions(Integer num) {
        return getNumberOptions(1,num);
    }

    private List<SelectOption> getNumberOptions(Integer start, Integer num) {

        List<SelectOption> options = new List<SelectOption>();
        for(Integer i = start; i <= num; i++) {
            String val = String.valueOf(i);
            options.add(new SelectOption(val,val));
        }
        return options;
    }

    public List<SelectOption> getAllPackageFamilies() {
        
        //Abhay 20-June-2017 SF-232 added Other in the excludedServices
        //Set <String> excludedServices = new Set<String>{'Die Processing Service', 'Die Sales', 'LEAD FINISH', 'Test', 'ALL'};
        Set <String> excludedServices = new Set<String>{'Die Processing Service', 'Die Sales', 'LEAD FINISH', 'Test', 'ALL','Other'};

        //Bhanu - 10-Mar-2016 : Saleforce-20 Please add "MEMS" or " CAVITYMEMS" as available assembly package
        //"Cavity MEMS" package family is configured with product Group as "MEMS", removing Restriction Product_Group__r.Name !=: 'MEMS'
        //List<Package_Family__c> packageFamilies = [select Id, Name from Package_Family__c where Product_Group__r.Name !=: 'Engineering Services' AND Product_Group__r.Name !=: 'MEMS' AND Name NOT IN :excludedServices AND Product_Group__r.Name !=: 'Unlisted' AND Inactive__c = false];
       
       //Abhay A: 21-Jun-17:SF-232:Test RFQi selection for package family selection via the "other" method, avail package family does not match via Assembly package family
        /* List<Package_Family__c> packageFamilies = [select Id, Name,Inactive__c from Package_Family__c where Product_Group__r.Name !=: 'Engineering Services'  AND Name NOT IN :excludedServices AND Product_Group__r.Name !=: 'Unlisted' AND Inactive__c = false];
        system.debug('Pack families-->'+packageFamilies);
       */
       
        Map<String,String> mapPFName_PFID = new Map<String,String>();
        List<String> packageFamilyNames = new List<String>();

        for(Package_Family__c pf : [select Id, Name,Inactive__c from Package_Family__c where Product_Group__r.Name !=: 'Engineering Services'  AND Name NOT IN :excludedServices  AND Inactive__c = false]) {
            String pfName = pf.Name;
            pfName = pfName.toUpperCase()+pfName;
            packageFamilyNames.add(pfName);
            mapPFName_PFID.put(pf.Name, pf.id);
        }
     
        packageFamilyNames.sort();
        
        List<String> pfNamesAfterSort = new List<String>();
        for(String pfName:packageFamilyNames) {
            pfNamesAfterSort.add(pfName.Substring(pfName.length()/2));
        }
        
        List<SelectOption> finalTestPackageTypes = new List<SelectOption>();
        finalTestPackageTypes.add(new SelectOption('','-- None Selected --'));
        for(String pfName : pfNamesAfterSort) {
            finalTestPackageTypes.add(new SelectOption(mapPFName_PFID.get(pfName),pfName));
        }
        //Abhay 21-June-2017 SF-232 sorted the assembly package famili pickist alphabetically -------- End -------------//

        system.debug('finalTestPackageTypes>>>>>>>    : '+finalTestPackageTypes);
        // Lalit - 31-Aug-2016 : Salesforce-102 Assembly package list for Test - Wafer Probe has invalid values
        /*if(testType != null && testType == AMKVARS.TT_PROBE){
            finalTestPackageTypes.add(new SelectOption('W/B Wafer', 'W/B Wafer'));
        }*/
        return finalTestPackageTypes;
    }

    /**
     * Gets the list package families in the system as SelectOptions
     * that correspond to the selected product group
     *
     * @returns List<SelectOption> of Package_Family__c
     */
    public List<SelectOption> getPackageFamilies() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- None Selected --'));
        if(itemPackageGroup != 'Other Services') {
            List<Package_Family__c> packageFamilies 
            = PackageFamilyDao.getInstance().getFamiliesByProductGroup(itemPackageGroup);
            packageFamilies.sort();

            for(Package_Family__c packageFamily : packageFamilies) {
                options.add(new SelectOption(packageFamily.Id,packageFamily.Name));
            }
        }
        return options;
    }

    public List<SelectOption> getOtherServices() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- None Selected --'));
        if(itemPackageGroup == 'Other Services') {
            List<Package_Family__c> packageFamilies 
            = PackageFamilyDao.getInstance().getFamiliesByProductGroupName('Standalone Services');
            packageFamilies.sort();
            for(Package_Family__c packageFamily : packageFamilies) {
                options.add(new SelectOption(packageFamily.Id,packageFamily.Name));
              // Abhay 12 May 2017 SF-208 : Adding "Test Only" to the picklist when Other Services is selected
               if(packageFamily.Name == 'Test'){
                    options.add(new SelectOption('Test Only','Test Only'));
                }
              
            }
            options.add(new SelectOption('Engineering Services','Engineering Services'));
            options.add(new SelectOption('Advanced Product Development','Advanced Product Development'));
        }
        return options;
    }

    public List<SelectOption> getEngineeringServices() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- None Selected --'));
        if(otherService == 'Engineering Services') {
            List<Package_Family__c> packageFamilies 
            = PackageFamilyDao.getInstance().getFamiliesByProductGroupName('Engineering Services');
            packageFamilies.sort();
            for(Package_Family__c packageFamily : packageFamilies) {
                options.add(new SelectOption(packageFamily.Id,packageFamily.Name));
            }
        }
        return options;
    }

    public List<SelectOption> getAdvProducts() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- None Selected --'));
        if(otherService == 'Advanced Product Development') {
            List<Package_Family__c> packageFamilies 
            = PackageFamilyDao.getInstance().getFamiliesByProductGroupName('Advanced Product Development');
            packageFamilies.sort();
            for(Package_Family__c packageFamily : packageFamilies) {
                options.add(new SelectOption(packageFamily.Id,packageFamily.Name));
            }
        }
        return options;
    }

    public void CopyOtherServicesToItemPackageFamily() {
        if(otherService != 'Engineering Services' && otherService != 'Advanced Product Development') {
            itemPackageFamily = otherService;
            populateDefaultConfigurationNumbers();
        }else {
            itemPackageFamily = null;
            engineeringService = null;
            advProduct = null;
            packageFamilyName = null;
        }
    }

    public void CopyEngineeringServicesToItemPackageFamily() {
        itemPackageFamily = engineeringService;
        populateDefaultConfigurationNumbers();

    }

    public void CopyAdvProductsToItemPackageFamily() {
        itemPackageFamily = advProduct;
        populateDefaultConfigurationNumbers();
    }

    /**
     * Gets the list package families in the system as SelectOptions
     * that correspond to the selected product group specifically for Final Test
     *
     * @returns List<SelectOption> of Package_Family__c
     */
    public List<SelectOption> getPackageFamiliesForTest() {

        List<Package_Family__c> packageFamilies 
        = PackageFamilyDao.getInstance().getFamiliesByProductGroup(finalTestProductGroup);
        //packageFamilies.sort();

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- None Selected --'));
        for(Package_Family__c packageFamily : packageFamilies) {
            if(packageFamily.Name != 'ALL') options.add(new SelectOption(packageFamily.Id,packageFamily.Name));
        }
        return options;
    }

    public Boolean getHasPassiveConfiguration() {
        if(StringUtils.isBlank(itemPackageFamily)) return false;
        Package_Family__c packageFamily =  PackageFamilyDao.getInstance().getById(itemPackageFamily);
        return !StringUtils.isBlank(packageFamily.Specific_Passive_Configuration_Object__c);
    }

    public Boolean getHasDieConfiguration() {
        if(StringUtils.isBlank(itemPackageFamily)) return false;
        Package_Family__c packageFamily =  PackageFamilyDao.getInstance().getById(itemPackageFamily);
        return !StringUtils.isBlank(packageFamily.Specific_Die_Configuration_Object__c);
    }

    public Boolean getHasWireConfiguration() {
        if(StringUtils.isBlank(itemPackageFamily)) return false;
        Package_Family__c packageFamily =  PackageFamilyDao.getInstance().getById(itemPackageFamily);
        return !StringUtils.isBlank(packageFamily.Specific_Wire_Configuration_Object__c);
    }

    public Boolean getHasInsertionConfiguration() {
        if(StringUtils.isBlank(itemPackageFamily)) return false;
        Package_Family__c packageFamily =  PackageFamilyDao.getInstance().getById(itemPackageFamily);
        return !StringUtils.isBlank(packageFamily.Specific_Insertion_Configuration_Object__c);
    }

    public Boolean getHasServiceConfiguration() {
        if(StringUtils.isBlank(itemPackageFamily)) return false;
        Package_Family__c packageFamily =  PackageFamilyDao.getInstance().getById(itemPackageFamily);
        return !StringUtils.isBlank(packageFamily.Specific_Service_Configuration_Object__c);
    }

    public Boolean getIsDesign() {
        if(StringUtils.isBlank(itemPackageFamily)) return false;
        Package_Family__c packageFamily =  PackageFamilyDao.getInstance().getById(itemPackageFamily);
        return packageFamily.Name == 'Design';
    }

    public Boolean getIsDesignPackageFamilies() {
        if(StringUtils.isBlank(serviceDesignType)) return false;
        if(serviceDesignType == 'Other' || serviceDesignType == 'New Design') return true;
        return false;
    }

    public Boolean getIsFinalTestPackageFamily() {
        if(StringUtils.isBlank(itemPackageFamily)) return false;
        Package_Family__c packageFamily =  PackageFamilyDao.getInstance().getById(itemPackageFamily);
        system.debug('packageFamily :   '+packageFamily);
        return packageFamily.Name == AMKVARS.PF_TEST;
    }

    public List<SelectOption> getTestUOMOptions(){
        
        /*List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- None Selected --'));
        if(testType != null) {
            if(testType != AMKVARS.TT_POST && testType != AMKVARS.TT_STRIP) {
                options.add(new SelectOption('/Time', '/Time'));
            }
        }
        if(testType != AMKVARS.TT_PROBE) options.add(new SelectOption('/Unit', '/Unit'));
        else options.add(new SelectOption('/Wafer', '/Wafer'));

        return options;
        */
        
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- None Selected --'));
        //Salesforce-42 Lalit Singh 26/20/2016 : Turnkey ATP with ultraFlex (TI) start>>>
        if(testType != null) {
            if(testType != AMKVARS.TT_POST && testType != AMKVARS.TT_STRIP && testType != AMKVARS.TT_PROBE) {
                options.add(new SelectOption('/Time', '/Time'));
                options.add(new SelectOption('/Time and Unit', '/Time and Unit'));
            }
            else if(testType == AMKVARS.TT_PROBE && testType != AMKVARS.TT_FINAL){ 
                //options.add(new SelectOption('/Time and Unit', '/Time and Unit'));
                //options.add(new SelectOption('/Wafer', '/Wafer'));
                options.add(new SelectOption('/Time', '/Time'));
                options.add(new SelectOption('/Time and Wafer', '/Time and Wafer'));
            }
            else if(testType == AMKVARS.TT_POST || testType == AMKVARS.TT_STRIP && testType != AMKVARS.TT_FINAL && testType != AMKVARS.TT_PROBE ){
                options.add(new SelectOption('/Unit', '/Unit'));
            }
            /*else if(testType != AMKVARS.TT_POST && testType == AMKVARS.TT_STRIP && testType != AMKVARS.TT_FINAL && testType != AMKVARS.TT_PROBE ){
                options.add(new SelectOption('/Unit', '/Unit'));
            }*/ 
            //Salesforce-42 Lalit Singh 26/20/2016 : Turnkey ATP with ultraFlex (TI) End>>>
        }
        return options;
    }

    public List<SelectOption> getTestTimeOptions(){

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- None Selected --'));
        for (String uom : testTimeUOMs) options.add(new SelectOption(uom, uom));

        return options;
    }

    public Boolean getIsTestPerTime(){
        Boolean isPerTime = false;
        if(testUOM == '/Time'){
            isPerTime = true;
            requiredInput = '';
            requiredBlock = '';
        }else{
            requiredInput = 'requiredInput';
            requiredBlock = 'requiredBlock';
        }


        return isPerTime;
    }

    public void setupAssemblyPfFieldDefs(){
        assemblyTestPfFieldDefs = null;
        bodyXName = null;
        bodyYName = null;
        bodyZName = null;
        ballLeadName = null;

        Set<String> bodyXNames = new Set<String>{
            'Body_Size_X__c',
            'Body_X__c',
            'Body_Size__c'
        };

        Set<String> bodyYNames = new Set<String>{
            'Body_Size_Y__c',
            'Body_Y__c',
            'Body_Size__c'
        };

        Set<String> bodyZNames = new Set<String>{
            'Body_Size_Z__c',
            'Body_Z__c',
            'Body_Size__c'
        };

        Set<String> ballLeadNames = new Set<String>{
            'Lead_Count__c',
            'Ball_Count__c',
            'Ball_Lead_Count__c'
        };

        assemblyTestPfFieldDefs = [select Object_API_Name__c, RFQI_Field_Def__r.Name from RFQI_PF_Field_Def__c where Package_Family__r.Id = :finalTestPackageFamily AND (Show_Lead_Count_Final_Test__c = true OR Show_Body_Size_Final_Test__c = true)];
        system.debug('assemblyTestPfFieldDefs    :'+assemblyTestPfFieldDefs);
        if(assemblyTestPfFieldDefs != null){
            for(RFQI_PF_Field_Def__c thisDef : assemblyTestPfFieldDefs){
                if(bodyXNames.contains(thisDef.RFQI_Field_Def__r.Name)){
                    bodyXName = thisDef.RFQI_Field_Def__r.Name;
                }
                if(bodyYNames.contains(thisDef.RFQI_Field_Def__r.Name)){
                    bodyYName = thisDef.RFQI_Field_Def__r.Name;
                }
                if(bodyZNames.contains(thisDef.RFQI_Field_Def__r.Name)){
                    bodyZName = thisDef.RFQI_Field_Def__r.Name;
                }
                if(ballLeadNames.contains(thisDef.RFQI_Field_Def__r.Name)){
                    ballLeadName = thisDef.RFQI_Field_Def__r.Name;
                }
            }
        }

        if(assemblyTestPfFieldDefs != null && !assemblyTestPfFieldDefs.isEmpty() && testType != AMKVARS.TT_PROBE){

            specificRfqItem = createObject(assemblyTestPfFieldDefs[0].Object_API_Name__c);
        }

    }


    public List<RFQI_PF_Field_Def__c> getAssemblyPfFieldDefs(){

        bodyXName = null;
        bodyYName = null;
        bodyZName = null;
        ballLeadName = null;

        Set<String> bodyXNames = new Set<String>{
            'Body_Size_X__c',
            'Body_X__c',
            'Body_Size__c'
        };

        Set<String> bodyYNames = new Set<String>{
            'Body_Size_Y__c',
            'Body_Y__c',
            'Body_Size__c'
        };

        Set<String> bodyZNames = new Set<String>{
            'Body_Size_Z__c',
            'Body_Z__c',
            'Body_Size__c'
        };

        Set<String> ballLeadNames = new Set<String>{
            'Lead_Count__c',
            'Ball_Count__c',
            'Ball_Lead_Count__c',
            'Lead_Count_Entry__c'
        };

        List<RFQI_PF_Field_Def__c> assemblyTestPfFieldDefs = [select Object_API_Name__c, RFQI_Field_Def__r.Name from RFQI_PF_Field_Def__c where Package_Family__r.Id = :finalTestPackageFamily AND (Show_Lead_Count_Final_Test__c = true OR Show_Body_Size_Final_Test__c = true)];
        system.debug('At Line number 966 assemblyTestPfFieldDefs  :'+assemblyTestPfFieldDefs);
        
        for(RFQI_PF_Field_Def__c thisDef : assemblyTestPfFieldDefs){
            if(bodyXNames.contains(thisDef.RFQI_Field_Def__r.Name)){
                bodyXName = thisDef.RFQI_Field_Def__r.Name;
            }
            if(bodyYNames.contains(thisDef.RFQI_Field_Def__r.Name)){
                bodyYName = thisDef.RFQI_Field_Def__r.Name;
            }
            if(bodyZNames.contains(thisDef.RFQI_Field_Def__r.Name)){
                bodyZName = thisDef.RFQI_Field_Def__r.Name;
            }
            if(ballLeadNames.contains(thisDef.RFQI_Field_Def__r.Name)){
                ballLeadName = thisDef.RFQI_Field_Def__r.Name;
            }
        }

        if(assemblyTestPfFieldDefs != null && !assemblyTestPfFieldDefs.isEmpty() && testType != AMKVARS.TT_PROBE){

            specificRfqItem = createObject(assemblyTestPfFieldDefs[0].Object_API_Name__c);
        }

        system.debug('At Line number 987 assemblyTestPfFieldDefs  :'+assemblyTestPfFieldDefs);
        return assemblyTestPfFieldDefs;


    }


    public static sObject createObject(String typeName) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
        if (targetType == null) {
            // throw an exception
        }

        // Instantiate an sObject with the type passed in as an argument
        //  at run time.
        return targetType.newSObject(); 
    }

    public Decimal getBodySizeX() {
        String tempBody = '';
        try {

            String [] tempBodyX = StringUtils.sanitize(String.valueOf(specificRfqItem.get('Body_Size__c'))).split('x');
            tempBody = tempBodyX[0];

        } catch(Exception e) {}
        try {
            if (StringUtils.isBlank(tempBody)) tempBody = StringUtils.sanitize(String.valueOf(specificRfqItem.get('Body_Size__c')));
        } catch(Exception e) {}
        try {
            if (StringUtils.isBlank(tempBody)) tempBody = StringUtils.sanitize(String.valueOf(specificRfqItem.get('Body_X__c')));
        }catch(Exception e){}
        try {
            if (StringUtils.isBlank(tempBody)) tempBody = StringUtils.sanitize(String.valueOf(specificRfqItem.get('Body_Size_X__c')));
        }catch(Exception e){}
        try {
            if (StringUtils.isBlank(tempBody)) tempBody = testBodyX;
        }catch(Exception e){}
        try {
            return Decimal.ValueOf(tempBody);
        }catch(Exception e){}
        return null;

    }

    public Decimal getBodySizeY() {
        String tempBody = '';
        try {

            String [] tempBodyY = StringUtils.sanitize(String.valueOf(specificRfqItem.get('Body_Size__c'))).split('x');
            tempBody = tempBodyY[1];

        } catch(Exception e) {}
        try {
            if (StringUtils.isBlank(tempBody)) tempBody = StringUtils.sanitize(String.valueOf(specificRfqItem.get('Body_Size__c')));
        } catch(Exception e) {}
        try {
            if (StringUtils.isBlank(tempBody)) tempBody = StringUtils.sanitize(String.valueOf(specificRfqItem.get('Body_Y__c')));
        }catch(Exception e){}
        try {
            if (StringUtils.isBlank(tempBody)) tempBody = StringUtils.sanitize(String.valueOf(specificRfqItem.get('Body_Size_Y__c')));
        }catch(Exception e){}
        try {
            if (StringUtils.isBlank(tempBody)) tempBody = testBodyY;
        }catch(Exception e){}
        try {
            return Decimal.ValueOf(tempBody);
        }catch(Exception e){}
        return null;
    } 

    public String getBodySizeZ() {
        String tempBody = '';
        try {
            tempBody = StringUtils.sanitize(String.valueOf(specificRfqItem.get('Body_Size_Z__c')));
        } catch(Exception e) {}
        try {
            if (StringUtils.isBlank(tempBody)) tempBody = StringUtils.sanitize(String.valueOf(specificRfqItem.get('Body_Z__c')));
        }catch(Exception e){}
        try {
            if (StringUtils.isBlank(tempBody)) tempBody = StringUtils.sanitize(String.valueOf(specificRfqItem.get('Body_Size_Z__c')));
        }catch(Exception e){}
        try {
            if (StringUtils.isBlank(tempBody)) tempBody = testBodyZ;
        }catch(Exception e){}

        return tempBody;
    } 

    public String getBallLeadCount() {
        String tempLeads = '';

        try {
            if (StringUtils.isBlank(tempLeads)) tempLeads = StringUtils.sanitize(String.valueOf(specificRfqItem.get('Lead_Count__c'))); 
        } catch(Exception e) {}

        try {
            if (StringUtils.isBlank(tempLeads)) tempLeads = StringUtils.sanitize(String.valueOf(specificRfqItem.get('Ball_Count__c'))); 
        } catch(Exception e) {}

        try {
            if (StringUtils.isBlank(tempLeads)) tempLeads = StringUtils.sanitize(String.valueOf(specificRfqItem.get('Ball_Lead_Count__c'))); 
        } catch(Exception e) {}

        try {
            if (StringUtils.isBlank(tempLeads)) tempLeads = StringUtils.sanitize(String.valueOf(specificRfqItem.get('Lead_Count_Entry__c'))); 
        } catch(Exception e) {}

        try {
            if (StringUtils.isBlank(tempLeads)) tempLeads = testPackageLead; 
        } catch(Exception e) {}


        return tempLeads;
    }

    public List<SelectOption> getTestTypeOptions(){

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- None Selected --'));
        options.add(new SelectOption(AMKVARS.TT_FINAL, AMKVARS.TT_FINAL));
        //Bharat - 25-Jul-2017 : Salesforce-81 : JDevice Plant Quoting capability in SFDC
        //Adding Final Test-JDev to the picklist
        options.add(new SelectOption(AMKVARS.TT_FINAL_JDEV, AMKVARS.TT_FINAL_JDEV));
        options.add(new SelectOption(AMKVARS.TT_PROBE, AMKVARS.TT_PROBE));
        //Bharat - 25-Jul-2017 : Salesforce-81 : JDevice Plant Quoting capability in SFDC
        //Adding Wafer Probe-JDev to the picklist
        options.add(new SelectOption(AMKVARS.TT_PROBE_JDEV, AMKVARS.TT_PROBE_JDEV));
        if(otherService !='Test Only'){
            options.add(new SelectOption(AMKVARS.TT_STRIP, AMKVARS.TT_STRIP));
        }    
        options.add(new SelectOption(AMKVARS.TT_POST, AMKVARS.TT_POST));

        return options;
    }

    public Boolean getIsProbeUnit(){
        //return (testType == AMKVARS.TT_PROBE && testUOM == '/Wafer');
        //SF:42 (Turnkey ATP with ultraFlex (TI)) lalit Start
        return (testType == AMKVARS.TT_PROBE && testUOM == '/Time and Wafer');
        //SF:42(Turnkey ATP with ultraFlex (TI)) lalit End
    }

    public List<SelectOption> getWaferSizeOptions(){

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- None Selected --'));
        options.add(new SelectOption('1" (25 mm)', '1" (25 mm)'));
        options.add(new SelectOption('2" (51 mm)', '2" (51 mm)'));
        options.add(new SelectOption('3" (76 mm)', '3" (76 mm)'));
        options.add(new SelectOption('4" (100 mm)', '4" (100 mm)'));
        options.add(new SelectOption('5" (130 mm)', '5" (130 mm)'));
        options.add(new SelectOption('6" (150 mm)', '6" (150 mm)'));
        options.add(new SelectOption('8" (200 mm)', '8" (200 mm)'));
        options.add(new SelectOption('12" (300 mm)', '12" (300 mm)'));
        options.add(new SelectOption('18" (450 mm)', '18" (450 mm)'));

        return options;
    }

    public String[] getBreakdowns() {
        return breakdowns;
    }

    public void setBreakdowns(String[] breakdowns) {
        this.breakdowns = breakdowns;
    }

    public Boolean getIsSiP() {
        return (packageFamilyName != null && !notSiPPFs.contains(packageFamilyName));
    }

}