/*************************************************************************
*
* PURPOSE: Allows the user to select a test service to add to an RFQ Item
*
* CLASS: RFQItemAddServiceController
* CREATED: 5/2/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Nathan Pilkington
***************************************************************************/

public with sharing class RFQItemAddServiceController extends BaseController {
    
    public RFQ_Item__c rfqItem { get; set; }
    //public String itemPackageGroup {get; set;}
    public String itemPackageFamily {get; set;}
    public String serviceDesignType {get; set;}
    public String testTimeUOM {get; set;}
    public String testUOM {get; set;}
    public String isFinalTestAddedService {get; set;}
    public String testType {get;set;}
    public String numberOfInsertions {get; set;}
    public String oppId {get; set;}
    public Boolean isOppOnly {get; set;}
    private Boolean isNewProduct;
    public String rfqId;
    public String waferSize {get; set;}
    public String grossDiePerWafer {get; set;}


    private static final Integer MAX_INSERTION = 16;
    private static final Integer MAX_SERVICE = 16;

    //For SiP AMK-2592
    public Boolean SiPQ1 {get;set;}
    
    public RFQItemAddServiceController() {
        isOppOnly = false;
        isNewProduct = false;
        String rfqItemId = getParam('rfqItemId');
        rfqItem = RfqItemDao.getInstance().getById(rfqItemId);
        isFinalTestAddedService = 'false';
        oppId = getParam('OpportunityId');
        rfqId = rfqItem.RFQ__c;
        numberOfInsertions = '1';
        SiPQ1 = getParam('SiP') == '1';

        if(!StringUtils.isBlank(rfqId)) {
            isNewProduct = [select New_Product_Development__c from RFQ__c where Id =: rfqId].New_Product_Development__c;

        }
        else {
            isOppOnly = !StringUtils.isBlank(oppId);
            

        }
        if (!isOppOnly) 
        {
            oppId = rfqItem.Opportunity__c;
        }
    }
    
    /**
     * Redirect the user to the RFQ Item
     */
    public PageReference returnToRfqItem() {
        if(!isOppOnly) {
            return new PageReference('/apex/RFQItemView?id=' + rfqItem.Id);
        }
        else return new PageReference('/apex/RFQOpItemView?id=' + rfqItem.Id);
    }
    
    /**
     * Create the RFQ Item service linked to the original RFQ Item
     */
     public PageReference createRfqItemService() {
        
        if (String.isBlank(itemPackageFamily)) {
            addError('Please select a Package Family');
            return null;
        }

        String packageFamilyName = PackageFamilyDao.getInstance().getById(itemPackageFamily).Name;

        if(packageFamilyName == 'Design') {
            if(StringUtils.isBlank(serviceDesignType)) {
                addError('Please select a Service Type for Design');
                return null;
            }
        }

        if(packageFamilyName == 'Final Test' || packageFamilyName == AMKVARS.PF_TEST) {

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

            if(getIsProbeUnit() && (StringUtils.isBlank(waferSize) || StringUtils.isBlank(grossDiePerWafer))) {
                addError('Please enter Wafer Size and Gross Die Per Wafer');
                return null;
            }
        }    
        
        String rfqId = getParam('rfqId');
        Package_Family__c pf = PackageFamilyDao.getInstance().getById(itemPackageFamily);

        PageReference pr = new PageReference('/apex/CreateRFQItem');
        pr.getParameters().put('packageFamilyId', pf.Id);
        pr.getParameters().put('serviceType', pf.Name);
        pr.getParameters().put('oppId', oppId);
        pr.getParameters().put('parentRfqItemId', rfqItem.Id);


        if(isFinalTestAddedService == 'true')
        {
            pr.getParameters().put('testUOM', testUOM.escapeHtml4());
            pr.getParameters().put('isFinalTestAddedService', isFinalTestAddedService);
            pr.getParameters().put('testType', testType);
            pr.getParameters().put('numInsertions', numberOfInsertions);
            if(getIsTestPerTime())
            {
                pr.getParameters().put('testTimeUOM', testTimeUOM.escapeHtml4());
            }
            else
            {
                pr.getParameters().put('waferSize', waferSize);
                pr.getParameters().put('grossDiePerWafer', grossDiePerWafer);
            }
        }
        else if(serviceDesignType != null) 
        {
            pr.getParameters().put('serviceDesignType', serviceDesignType);
        }

        if (!isOppOnly)
        {
            pr.getParameters().put('rfqId', rfqItem.RFQ__c);
        }

        if((SiPQ1) && !CreateRFQItemController.notSiPPFs.contains(pf.Name)) pr.getParameters().put('SiP', '1');
        else pr.getParameters().put('SiP', '0');

        return pr;
     }

    // public List<SelectOption> getProductGroups() {
        
    //    ProductGroupDao prodDao = ProductGroupDao.getInstance();
    //    RFQDao rfDao = RFQDao.getInstance();
                
    //    List<Product_Group__c> productGroups
    //     = prodDao.getProductGroups(false, true);
    //     productGroups.sort();
        
    //    List<SelectOption> options = new List<SelectOption>();
    //    options.add(new SelectOption('','-- None Selected --'));
    //    for(Product_Group__c productGroup : productGroups) {
    //        options.add(new SelectOption(productGroup.Id,productGroup.Name));
    //    } 
    //    return options;
    //}

    public List<SelectOption> getPackageFamilies() {
        
        List<Package_Family__c> packageFamilies 
            = PackageFamilyDao.getInstance().getFamiliesByProductGroupName('Standalone Services');
        packageFamilies.sort();
 
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- None Selected --'));
        for(Package_Family__c packageFamily : packageFamilies) {
            if(packageFamily.Name != 'WAFER BACKGRIND') options.add(new SelectOption(packageFamily.Id,packageFamily.Name));
        }
        return options;
    }

    //public List<SelectOption> getServiceTypeOptions() {

    //    List<SelectOption> options = new List<SelectOption>();
    //    options.add(new SelectOption('','-- None Selected --'));
    //    options.add(new SelectOption('3D Design', '3D Design'));
    //    options.add(new SelectOption('Daisy Chain Design', 'Daisy Chain Design'));
    //    options.add(new SelectOption('Other', 'Other'));
    //    options.add(new SelectOption('New Design', 'New Design'));
    //    options.add(new SelectOption('Test Board Design', 'Test Board Design'));

    //    return options;
    //}
    
    // public List<SelectOption> getServiceTypeOptions() {
        
    //     List<SelectOption> options = new List<SelectOption>();
    //     options.add(new SelectOption('','-- None Selected --'));
        
    //     ProductGroupDao prodDao = ProductGroupDao.getInstance();
        
    //     List<Product_Group__c> productGroups
    //      = prodDao.getProductGroups(false, true);
        
    //     if(productGroups.size() > 0) {
    //         for(Integer a = 0; a < productGroups.size(); a++ ){
       //      List<Package_Family__c> packageFamilies 
       //           = PackageFamilyDao.getInstance().getFamiliesByProductGroup(productGroups[a].Id);
             
       //      for(Package_Family__c packageFamily : packageFamilies) {
       //          options.add(new SelectOption(packageFamily.Id,packageFamily.Name));
       //      }
    //     }
    // }
       

    //     return options;
    // }

    //public Boolean getIsDesign() {
    //    if(StringUtils.isBlank(itemPackageFamily)) return false;
    //    Package_Family__c packageFamily =  PackageFamilyDao.getInstance().getById(itemPackageFamily);
    //    return packageFamily.Name == 'Design';
    //}

    public Boolean getIsFinalTestPackageFamily() {
        if(StringUtils.isBlank(itemPackageFamily)) return false;
        Package_Family__c packageFamily =  PackageFamilyDao.getInstance().getById(itemPackageFamily);
        if(packageFamily.Name == 'Final Test' || packageFamily.Name == AMKVARS.PF_TEST) isFinalTestAddedService = 'true';
        return packageFamily.Name == 'Final Test' || packageFamily.Name == 'Wafer Probe' || packageFamily.Name == AMKVARS.PF_TEST;
    }

        public List<SelectOption> getTestUOMOptions(){

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- None Selected --'));
        if(testType != null) {
            if(testType != AMKVARS.TT_POST && testType != AMKVARS.TT_STRIP) {
                options.add(new SelectOption('/Time', '/Time'));
            }
        }
        if(testType != AMKVARS.TT_PROBE) options.add(new SelectOption('/Unit', '/Unit'));
        else options.add(new SelectOption('/Wafer', '/Wafer'));
        

        return options;
    }

    public List<SelectOption> getTestTimeOptions(){

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- None Selected --'));
        options.add(new SelectOption('/Month', '/Month'));
        options.add(new SelectOption('/Hr', '/Hr'));
        options.add(new SelectOption('/Min', '/Min'));
        options.add(new SelectOption('/Sec', '/Sec'));

        return options;
    }

    public Boolean getIsTestPerTime(){
        Boolean isPerTime = false;
        if(testUOM == '/Time'){
            isPerTime = true;
        }

        return isPerTime;
    }

    public List<SelectOption> getTestTypeOptions(){

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- None Selected --'));
        options.add(new SelectOption(AMKVARS.TT_FINAL, AMKVARS.TT_FINAL));
        options.add(new SelectOption(AMKVARS.TT_PROBE, AMKVARS.TT_PROBE));
        options.add(new SelectOption(AMKVARS.TT_STRIP, AMKVARS.TT_STRIP));
        options.add(new SelectOption(AMKVARS.TT_POST, AMKVARS.TT_POST));
        //Bharat - 26-Jul-2017 : Salesforce-81 : JDevice Plant Quoting capability in SFDC
        //Adding Final Test-JDev and Wafer Probe-JDev to the picklist
        options.add(new SelectOption(AMKVARS.TT_FINAL_JDEV, AMKVARS.TT_FINAL_JDEV));
        options.add(new SelectOption(AMKVARS.TT_PROBE_JDEV, AMKVARS.TT_PROBE_JDEV));

        return options;
    }

    public void setdefaultInsertionConfigs() {
        if(testType != null) {
            if(testType == AMKVARS.TT_POST) {
                numberOfInsertions = '0';
            }
            else {
                numberOfInsertions = '1';
            }
        }
    }

    public Boolean getHasInsertionConfiguration() {
        if(StringUtils.isBlank(itemPackageFamily)) return false;
        Package_Family__c packageFamily =  PackageFamilyDao.getInstance().getById(itemPackageFamily);
        return !StringUtils.isBlank(packageFamily.Specific_Insertion_Configuration_Object__c);
    }

    public List<SelectOption> getNumberOfInsertionOptions() {
        return getNumberOptions(0,MAX_INSERTION);
    }

    @TestVisible private List<SelectOption> getNumberOptions(Integer num) {
        return getNumberOptions(1,num);
    }
    
    @TestVisible private List<SelectOption> getNumberOptions(Integer start, Integer num) {
        
        List<SelectOption> options = new List<SelectOption>();
        for(Integer i = start; i <= num; i++) {
            String val = String.valueOf(i);
            options.add(new SelectOption(val,val));
        }
        return options;
    }

    public Boolean getIsProbeUnit(){
        return (testType == AMKVARS.TT_PROBE && testUOM == '/Wafer');
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

}