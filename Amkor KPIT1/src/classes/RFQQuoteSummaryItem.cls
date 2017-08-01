public with sharing class RFQQuoteSummaryItem implements Comparable{

    public String packageFamilyName {get; set;}
    public String projectDeviceName {get; set;}
    public String productGroupName {get; set;}
    public Boolean hasParentRfqItem {get; set;}
    public String testType {get; set;}
    public Boolean isChildRfqItem {get; set;}
    public String factoryName {get; set;}
    public String bodySize {get; set;}
    public String leads {get; set;}
    private String wireTypeAndDiam {get; set;}
    private String dieInfo {get; set;}
    public String uom {get; set;}
    public String volumePerWk {get; set;}
    public Decimal price {get; set;}
    public String auAdderString {get; set;}
    public Decimal auAdder {get; set;}
    public Decimal nreTotal {get; set;}
    public String cpn {get; set;}
    public String rfqiName {get; set;}
    public String rfqItemId {get; set;}
    public String serviceType {get; set;}
    public String parentRfqItemName {get; set;}
    public String style {get; set;}
    public Boolean isSubtotalItem {get; set;}
    public Decimal forecastMed {get; set;}
    public Id packageFamilyId {get;set;}

    public String description {get; set;}
    public String postTestServiceNames {get; set;}
    public Decimal totalPostTestPrice {get; set;}
    public Decimal totalPriceWithPostTest {get; set;}
    public List<RFQItemWrapper.AdderCharge> adderItems {get; set;}
    public Decimal adderTotal {get; set;}
    public Decimal engSvcsQuantity {get; set;}
    public Boolean isEngineeringService {get; set;}
    public String parentMultiVolId {get;set;}
    public String parentMultiVolName {get;set;}

    public Map<String,String> engineeringServiceFields = new Map<String, String>{
        'Board Level Reliability' => 'BLR_Test_Description__c',
        'Component Level Reliability' => 'Component_Reliability_Test__c',
        'Electromigration Tests' => 'EM_Test_Description__c',
        'Imaging only' => 'Imaging_Only_Selections__c',
        'Nano Materials Analysis' => 'Nano_Analysis_Type__c',
        'Package Materials Testing' => 'Material_Analysis_Description__c',
        'X-Section-SEM-EDX' => 'Cross_Section_SEM_EDX__c',
        'Mechanical' => 'Simulation__c',
        'Thermal' => 'Simulation__c',
        'Design' => 'Service_Type__c',
        'Electrical Services' => 'Electrical_Services__c'
    };


    public RFQQuoteSummaryItem(){

    }

    public RFQQuoteSummaryItem(RFQItemWrapper wrapper, RFQILayout layout) {
        projectDeviceName = wrapper.rfqItem.Project_Device__c;
        packageFamilyName = wrapper.rfqItem.Package_Family__r.Name;
        packageFamilyId = wrapper.rfqItem.Package_Family__c;
        productGroupName = wrapper.packageFamily.Product_Group_Name__c;
        hasParentRfqItem = wrapper.rfqItem.Parent_RFQ_Item__c != null;
        testType = (packageFamilyName == AMKVARS.PF_TEST) ? String.valueOf(wrapper.specificRfqItem.get('Test_Type__c')) : 'FAKE Test';
        system.debug('testType RFQQuoteSummaryItem class #67 : '+testType);
        parentMultiVolId = (wrapper.rfqItem.Parent_Volume_Item__c != null) ? wrapper.rfqItem.Parent_Volume_Item__c : wrapper.rfqItem.Id;
        parentMultiVolName = (wrapper.rfqItem.Parent_Volume_Item__c != null) ? wrapper.rfqItem.Parent_Volume_Item__r.Name : wrapper.rfqItem.Name;
        isChildRfqItem = wrapper.rfqItem.Is_Child__c;
        factoryName = wrapper.factoryName;
        bodySize = wrapper.rfqItem.Body_Size__c;
        leads = wrapper.rfqItem.Leads__c;
        wireTypeAndDiam = wrapper.rfqItem.Wire_Type_And_Diameter__c;
        dieInfo = wrapper.rfqItem.Die_Information__c;
        uom = null;
        adderTotal = 0;
        if(wrapper.rfqItem.Forecast_Median__c != null) {
            forecastMed = wrapper.rfqItem.Forecast_Median__c;
        }
        else forecastMed = 0;

        if(wrapper.rfqItem.BU_Price_Label__c != null){
            uom = wrapper.rfqItem.BU_Price_Label__c;
        }else if(packageFamilyName != 'Engineering Services'){
            uom = '/Unit';
        }
        volumePerWk = wrapper.rfqItem.Forecast__c;
        price = DataUtils.getDecimal(wrapper.rfqItem, 'Price_To_Customer__c', 0);
        system.debug('Here::Price:: '+price);
        auAdderString = DataUtils.getString(wrapper.specificRfqItem, 'Au_Adder__c', null);
        if(String.isNotBlank(auAdderString)) {
            if(auAdderString == 'Inclusive') {
                auAdder = 0;
            }
            else {
                auAdder = Decimal.valueOf(auAdderString);
            }
        }
        else {
            auAdder = 0;
        }
        cpn = wrapper.rfqItem.Configured_Part_Number__r.Name;
        rfqiName = wrapper.rfqItem.Name;
        rfqItemId = wrapper.rfqItem.Id;
        serviceType = 'Assembly';
        isSubtotalItem = false;
        totalPostTestPrice = DataUtils.getDecimal(wrapper.specificRfqItem, 'Post_Price_To_Customer__c', 0);
        totalPriceWithPostTest = price + totalPostTestPrice;
        postTestServiceNames = '';
        engSvcsQuantity = wrapper.getNumberOfServiceConfigurations();
        isEngineeringService = false;
        if(hasParentRfqItem){
            parentRfqItemName = wrapper.rfqItem.Parent_RFQ_Item__r.Name;
        }else{ //it has no parent but we use this to order the list for display purposes, so must be same as children
            parentRfqItemName = wrapper.rfqItem.Name;
        }
        if(packageFamilyName == AMKVARS.PF_TEST){
            System.debug('inside the RFQQuoteSummaryItem class line 117');
            description = setupTestDescription(wrapper, layout);
            system.debug('description  : '+description);
            if(hasParentRfqItem) serviceType = testType;
            system.debug('testType'+testType);
            if(testType == AMKVARS.TT_PROBE && uom == '/Unit' ){
                uom = '/Wafer';
            }
            //Lalit - 18-Jan-2017 : Salesforce-42 : Turnkey ATP with ultraFlex (TI)
            //added one more else if condition for the /Time and Unit  and assigning uom= /Unit.
            else if(testType == AMKVARS.TT_FINAL && uom == '/Time and Unit'){
                //uom = '/Unit';
                uom = '/Hr';
                System.debug('uom #131 : '+uom);
            }
        }else if(packageFamilyName == 'Bump' || packageFamilyName == AMKVARS.PF_BUMP){
            description = setupBumpDescription(wrapper);
            if(hasParentRfqItem) serviceType = 'Bump';
            uom = '/Wafer';         
        }
        else if (packageFamilyName == 'WLCSP'){
            serviceType = 'Bump';
            uom = '/Wafer';         
            description = packageFamilyName + ', ' + bodySize + ', ' + leads + ', ' + wireTypeAndDiam + ', ' + dieInfo;
        }
        else if (packageFamilyName == AMKVARS.PF_DPS){
            serviceType = 'Bump';
            uom = '/Die';           
            description = packageFamilyName + ', ' + bodySize + ', ' + leads + ', ' + wireTypeAndDiam + ', ' + dieInfo;
        }
        else if (packageFamilyName == AMKVARS.PF_WLCSP){
            serviceType = 'WLCSP (Die Services)';
            uom = '/Die';           
            description = bodySize + ', ' + leads + ', ' + wireTypeAndDiam + ', ' + dieInfo;
        }
        else if(packageFamilyName == 'Reflow'){
            description = String.valueOf(wrapper.specificRfqItem.get('Wafer_Size_PK__c'));
            uom = '/Wafer';
        }else if(engineeringServiceFields.keySet().contains(packageFamilyName)){
            uom = '/Service';
            description = '';
            serviceType = packageFamilyName;
            if(wrapper.getNumberOfServiceConfigurations() > 0){
                isEngineeringService = true;
                for(sObject serviceConfig : wrapper.serviceConfigurations){
                    if(description.isWhitespace()){
                        description += String.valueOf(serviceConfig.get(engineeringServiceFields.get(packageFamilyName)));
                    }else{
                        description += ', '+ String.valueOf(serviceConfig.get(engineeringServiceFields.get(packageFamilyName)));
                    }
                }
            }
            else if (packageFamilyName == 'Electrical Services') {
                isEngineeringService = true;
                description = String.valueOf(wrapper.getAttribute('Electrical_Services__c',RFQItemWrapper.PACKAGE_OBJECT, 0));
                if(wrapper.rfqItem.SiP__c) description += ' (SiP)';
                engSvcsQuantity = 1;
            }
            else if (packageFamilyName == 'Design') {
                isEngineeringService = true;
                description = String.valueOf(wrapper.getAttribute('Service_Type__c',RFQItemWrapper.PACKAGE_OBJECT, 0));
                if(wrapper.rfqItem.SiP__c) description += ' (SiP)';
                engSvcsQuantity = 1;
            }
        }else if(packageFamilyName == 'Die Sales'){
            packageFamilyName = 'Assembly - Die Sales';
            serviceType = 'Assembly - Die Sales';
            //volumePerWk = String.valueOf(wrapper.specificRfqItem.get('Die_per_Month__c'));
            description = setupDieSalesDescription(wrapper);
        }else{
            description = packageFamilyName;
            if(wrapper.rfqItem.SiP__c) description += ' (SiP)';
            description += ', ' + bodySize + ', ' + leads + ', ' + wireTypeAndDiam + ', ' + dieInfo;
            if(wrapper.adderCharges.size() > 0) adderItems = wrapper.adderCharges;
        }
    }

    private String setupTestDescription(RFQItemWrapper wrapper, RFQILayout layout){
        String description;
        if(wrapper.getNumberOfInsertionConfigurations() > 1){
            description = 'Multiple Insertions - see detail section.';          
        }else if (wrapper.getNumberOfInsertionConfigurations() == 1){
            sObject insertion = wrapper.insertionConfigurations[0];
            factoryName =  String.valueOf(insertion.get('Factory_Selected__c'));
            String testerModel = String.valueOf(insertion.get('Tester_Model__c'));
            String testerOwner = String.valueOf(insertion.get('Tester__c'));
            String handlerModel = String.valueOf(insertion.get('Handler_Model__c'));
            String handlerOwner = String.valueOf(insertion.get('Handler__c'));
            String testerAvailable = String.valueOf(insertion.get('Tester_Avaliable__c'));
            String handlerAvailable = String.valueOf(insertion.get('Handler_Avaliable__c'));

            description = testerModel + ', ' + testerOwner + ', ' + handlerModel + ', ' + handlerOwner;

            if(testerAvailable != null) description += ', '+ testerAvailable;
            if(handlerAvailable != null) description += ', '+ handlerAvailable;
        }
        else {
            system.debug('entering post test loop');
            if(layout.sectionMap.get('Post Test Services') != null) {
                for(RFQISectionAttribute attribute : layout.sectionMap.get('Post Test Services').attributes){
                    try{
                        String postTestValue = DataUtils.getString(wrapper.specificRfqItem, attribute.fieldAPIName, '');
                        if(String.isNotBlank(postTestValue) && postTestValue != 'false'){

                            if(description == null || description.isWhitespace()){                                  
                                description = FieldLabelHelper.getInstance().getLabel('RFQI_TESTS__c', attribute.fieldAPIName);                             
                            }else{
                                description += ', '+FieldLabelHelper.getInstance().getLabel('RFQI_TESTS__c', attribute.fieldAPIName);                               
                            }
                        }           
                    }catch(Exception ex){}
                }
            }
        }

        return description;
    }

    private String setupBumpDescription(RFQItemWrapper wrapper){

        String waferSize = String.valueOf(wrapper.specificRfqItem.get('Wafer_Size_PK__c'));
        String typeOfBump = String.valueOf(wrapper.specificRfqItem.get('Type_of_Bump__c'));
        String bumpComp = String.valueOf(wrapper.specificRfqItem.get('Bump_Composition__c'));
        String structure = String.valueOf(wrapper.specificRfqItem.get('Structure__c'));

        return waferSize + ', ' + typeOfBump + ', ' + bumpComp + ', ' + structure;
    }

    private String setupDieSalesDescription(RFQItemWrapper wrapper){
        String description = '';

        String waferSize = String.valueOf(wrapper.specificRfqItem.get('Wafer_Size_PK__c'));
        String dieX = String.valueOf(wrapper.specificRfqItem.get('Die_Size_X_PK__c'));
        String dieY = String.valueOf(wrapper.specificRfqItem.get('Die_Size_Y_PK__c'));
        String inspect1 = String.valueOf(wrapper.specificRfqItem.get('Inspect__c'));
        String inspect2 = String.valueOf(wrapper.specificRfqItem.get('Inspect_2__c'));
        String backgrind = String.valueOf(wrapper.specificRfqItem.get('Backgrind__c'));
        String dice = String.valueOf(wrapper.specificRfqItem.get('Dice__c'));
        String packing = String.valueOf(wrapper.specificRfqItem.get('Packing__c'));


        description += waferSize + 'mm, ' + dieX + ', ' + dieY;

        if(inspect1 != null) description += ', '+inspect1;
        if(inspect2 != null) description += ', '+inspect2;
        if(backgrind == 'Yes') description += ', Backgrind';
        if(dice == 'Yes') description += ', Dice';

        return description;

    }

    public Integer compareTo(Object compareTo){

        RFQQuoteSummaryItem compareItem = (RFQQuoteSummaryItem)compareTo;

        if(packageFamilyName == compareItem.packageFamilyName) {
            if(forecastMed > compareItem.forecastMed) return 1;
            else if(forecastMed == compareItem.forecastMed) return 0;
            else return -1;
        }
        if(packageFamilyName == null || compareItem.packageFamilyName == null) return 0;

        return packageFamilyName.compareTo(compareItem.packageFamilyName);

    }

    public with sharing class RFQQuoteSummaryItemList implements Comparable{
        public List<RFQQuoteSummaryItem> quoteSummaryItems {get;set;}
        public Decimal forecastMed {get;set;}
        public String packageFamilyName {get;set;}
        public String rfqiName {get;set;}
        public String serviceType {get;set;}
        public String parentVol {get;set;}

        public RFQQuoteSummaryItemList() {
            quoteSummaryItems = new List<RFQQuoteSummaryItem>();
        }

        public RFQQuoteSummaryItemList(List<RFQQuoteSummaryItem> items) {
            quoteSummaryItems.addAll(items);
            system.debug(' RFQQuoteSummaryItem Class Line 298   quoteSummaryItems :'+quoteSummaryItems);
        }

        public void setForSort() {
            if(quoteSummaryItems.size() == 1) {
                packageFamilyName = quoteSummaryItems[0].packageFamilyName;
                system.debug(' RFQQuoteSummaryItem Class 304  packageFamilyName :'+packageFamilyName);
                forecastMed = quoteSummaryItems[0].forecastMed;
                system.debug(' RFQQuoteSummaryItem Class 306 forecastMed :'+forecastMed);
                rfqiName = quoteSummaryItems[0].rfqiName;
                system.debug(' RFQQuoteSummaryItem Class 308  rfqiName :'+rfqiName);
                serviceType = quoteSummaryItems[0].serviceType;
                system.debug(' RFQQuoteSummaryItem Class 310 serviceType :'+serviceType);
                parentVol = quoteSummaryItems[0].parentMultiVolName;
                system.debug(' RFQQuoteSummaryItem Class 312 parentVol :'+parentVol);

            }
            else {
                for(RFQQuoteSummaryItem item : quoteSummaryItems) {
                    if(!item.hasParentRfqItem) {
                        if(item.packageFamilyName != null) {
                            system.debug(' RFQQuoteSummaryItem Class Inside else condition  :');
                            packageFamilyName = item.packageFamilyName;
                            system.debug(' RFQQuoteSummaryItem Class 321 packageFamilyName :'+packageFamilyName);
                            forecastMed = item.forecastMed;
                            system.debug(' RFQQuoteSummaryItem Class 323 packageFamilyName :'+forecastMed);
                            rfqiName = item.rfqiName;
                            system.debug(' RFQQuoteSummaryItem Class 325 packageFamilyName :'+rfqiName);
                            serviceType = item.serviceType;
                            system.debug(' RFQQuoteSummaryItem Class 327 packageFamilyName :'+serviceType);
                            parentVol = item.parentMultiVolName;
                            system.debug(' RFQQuoteSummaryItem Class 329 packageFamilyName :'+parentVol);
                        } 
                    }
                }
            }
            
        }

        public Integer compareTo(Object compareTo){

        RFQQuoteSummaryItemList compareItem = (RFQQuoteSummaryItemList)compareTo;

        if(packageFamilyName == compareItem.packageFamilyName) {
            if(serviceType == compareItem.serviceType) {
                if(forecastMed > compareItem.forecastMed) return 1;
                else if(forecastMed == compareItem.forecastMed) {
                    return parentVol.compareTo(compareItem.parentVol);
                }
                else return -1;
            }
            else return serviceType.compareTo(compareItem.serviceType);
        }
        if(packageFamilyName == null || compareItem.packageFamilyName == null) return 0;

        return packageFamilyName.compareTo(compareItem.packageFamilyName);

        }

    }

    
}