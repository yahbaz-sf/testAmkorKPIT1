/*************************************************************************
*
* PURPOSE: Data access and manipulation for RFQ_Item__c
*
* CLASS: RFQItemDao
* CREATED: 3/06/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/
public class RFQItemDao extends BaseDao {
    
     
    //Abhay - 26-July-2017 :Salesforce 199 :  Opportunity Stage Auto Update Fix
    private final static  Map<String,Integer> statusMap;
    private final static  Map<String,String> Statuses;
    public final static Map<String,String> statusToStageMap;
    public static final Set<String> STATUS_NO_COPY_PRICE_TO_CUSTOMER;
    public static final Set<String> STATUS_OPEN;
    public static final Set<String> STATUS_CLOSED;
    public static final Set<String> STATUS_PROGRESS;
    public static final Set<String> reportableStatuses;

    static
    {
      
        statusMap = new Map<String,Integer>();
        Statuses = new Map<String,String>();
        statusToStageMap = new Map<String,String>(); 
        STATUS_NO_COPY_PRICE_TO_CUSTOMER = new Set<String>();
        STATUS_OPEN = new Set<String>();
        STATUS_CLOSED = new Set<String>();
        STATUS_PROGRESS = new Set<String>();
        reportableStatuses = new Set<String>();
	
		for(StatusMap__mdt statusMDT:[select Status__c,Weight__c,Status_No_Copy_Price_to_Cust__c,Status_open__c,Status_closed__c,Status_Progress__c,Status_Reportable__c,Opportunity_Stage__c,DeveloperName from StatusMap__mdt]){
		    if(statusMDT.Status_No_Copy_Price_to_Cust__c){
		        STATUS_NO_COPY_PRICE_TO_CUSTOMER.add(statusMDT.Status__c);
		    }
		    if(statusMDT.Status_open__c){
                STATUS_OPEN.add(statusMDT.Status__c);
		    }
		    if(statusMDT.Status_closed__c){
		        STATUS_CLOSED.add(statusMDT.Status__c);
		    }
		    if(statusMDT.Status_Progress__c){
		        STATUS_PROGRESS.add(statusMDT.Status__c);
		    }
		    if(statusMDT.Status_Reportable__c){
		        reportableStatuses.add(statusMDT.Status__c);
		    }
	    	statusMap.put(statusMDT.Status__c,(Integer)statusMDT.Weight__c);
			statuses.put(statusMDT.DeveloperName,statusMDT.Status__c);
            statusToStageMap.put(statusMDT.Status__c,statusMDT.Opportunity_Stage__c);
		}
	
    }

    DebugUtils debug {get {return DebugUtils.getInstance();} }  
    
    //Abhay - 26-July-2017 :Salesforce 199 :  Opportunity Stage Auto Update Fix
    public static final String STATUS_NEW = statuses.get('STATUS_NEW');
    public static final String STATUS_IMPORT_PENDING = statuses.get('STATUS_IMPORT_PENDING'); // Items that have been imported, but the defaults haven't been applied yet
    public static final String STATUS_PENDING_PROCESSING = statuses.get('STATUS_PENDING_PROCESSING'); // Items that have been imported, but the rest of the Items in the CSV haven't been imported yet
    public static final String STATUS_BU_DRAFT = statuses.get('STATUS_BU_DRAFT');
    public static final String STATUS_DRAFT = statuses.get('STATUS_DRAFT');
    public static final String STATUS_READY_TO_PRICE = statuses.get('STATUS_READY_TO_PRICE');
    public static final String STATUS_PRICE_SUBMIT = statuses.get('STATUS_PRICE_SUBMIT');
    public static final String STATUS_USER_REQ_PREAPPROVAL = statuses.get('STATUS_USER_REQ_PREAPPROVAL');
    public static final String STATUS_ACCOUNT_REQ_PREAPPROVAL = statuses.get('STATUS_ACCOUNT_REQ_PREAPPROVAL');
    public static final String STATUS_SALES_REQ_PREAPPROVAL = statuses.get('STATUS_SALES_REQ_PREAPPROVAL');
    public static final String STATUS_PREAPPROVAL_COMPLETE = statuses.get('STATUS_PREAPPROVAL_COMPLETE');
    public static final String STATUS_PRICE_PENDING_BU = statuses.get('STATUS_PRICE_PENDING_BU');
    public static final String STATUS_PRICE_PENDING_SALES = statuses.get('STATUS_PRICE_PENDING_SALES');
    public static final String STATUS_PENDING_ASSEMBLY_APPROVAL = statuses.get('STATUS_PENDING_ASSEMBLY_APPROVAL');
    public static final String STATUS_PRICE_COMPLETE =statuses.get('STATUS_PRICE_COMPLETE');
    //Lalit - 04-Mar-2017 : Salesforce-114 : Reject change to 'Return to Sales' during BU process for RFQI
    //changed the status from pricing Declined to Returned to sales.
    //public static final String STATUS_PRICE_DECLINED = 'Pricing Declined';
    public static final String STATUS_PRICE_DECLINED = statuses.get('STATUS_PRICE_DECLINED');
    public static final String STATUS_PRICE_ESCALATION =statuses.get('STATUS_PRICE_ESCALATION');
    public static final String STATUS_PROGRAM_WIN = statuses.get('STATUS_PROGRAM_WIN');
    public static final String STATUS_PROGRAM_LOSS = statuses.get('STATUS_PROGRAM_LOSS');
    public static final String STATUS_PROGRAM_CANCELED =statuses.get('STATUS_PROGRAM_CANCELED');
    public static final String STATUS_PRODUCTION_WIN = statuses.get('STATUS_PRODUCTION_WIN');
    public static final String STATUS_QUOTED = statuses.get('STATUS_QUOTED');
    public static final String STATUS_NO_BID = statuses.get('STATUS_NO_BID');
    //Bhanu - 29-June-2016 : Salesforce 69 - New Opportunity STAGE changes
    //Adding Set as Qual button and removing obsolete Status
    /*
    public static final String STATUS_WON_PROTOTYPE = 'Won Prototype Build';
    public static final String STATUS_WON_QUALIFICATION = 'Won Qualification Build';
    */
    public static final String STATUS_Qual = statuses.get('STATUS_Qual');

    
    // The list of statuses in which BU Price should not be copied over to price to customer
    
     //Abhay - 26-July-2017 :Salesforce 199 :  Opportunity Stage Auto Update Fix
    //commented the following sets and replaced by a custom metadata type 'StatusMap__mdt'
    
   /* public static final Set<String> STATUS_NO_COPY_PRICE_TO_CUSTOMER = new Set<String> {
        STATUS_NEW,
        STATUS_IMPORT_PENDING,
        STATUS_PENDING_PROCESSING,
        STATUS_BU_DRAFT,
        STATUS_DRAFT,
        STATUS_PRICE_SUBMIT,
        STATUS_PRICE_PENDING_BU,
        STATUS_PRICE_DECLINED,
        STATUS_NO_BID
    };

    public static final Set<String> STATUS_CLOSED = new Set<String> {
        STATUS_PROGRAM_WIN,
        STATUS_PROGRAM_LOSS,
        STATUS_PROGRAM_CANCELED,
        STATUS_PRICE_DECLINED,
        STATUS_NO_BID,
        STATUS_PRODUCTION_WIN
    };


    public static final Set<String> STATUS_OPEN = new Set<String> {
        STATUS_NEW,
        STATUS_IMPORT_PENDING,
        STATUS_PENDING_PROCESSING,
        STATUS_BU_DRAFT,
        STATUS_DRAFT,
        STATUS_READY_TO_PRICE,
        STATUS_PRICE_SUBMIT,
        STATUS_USER_REQ_PREAPPROVAL,
        STATUS_ACCOUNT_REQ_PREAPPROVAL,
        STATUS_SALES_REQ_PREAPPROVAL,
        STATUS_PREAPPROVAL_COMPLETE,
        STATUS_PRICE_PENDING_BU,
        STATUS_PRICE_PENDING_SALES,
        STATUS_PENDING_ASSEMBLY_APPROVAL,
        STATUS_PRICE_COMPLETE,
        STATUS_PRICE_ESCALATION,
        STATUS_QUOTED,
        STATUS_Qual
        //STATUS_WON_PROTOTYPE,
        //STATUS_WON_QUALIFICATION
    };

    public static final Set<String> STATUS_PROGRESS = new Set<String> {
        STATUS_IMPORT_PENDING,
        STATUS_PENDING_PROCESSING,
        STATUS_READY_TO_PRICE,
        STATUS_PRICE_SUBMIT,
        STATUS_USER_REQ_PREAPPROVAL,
        STATUS_ACCOUNT_REQ_PREAPPROVAL,
        STATUS_SALES_REQ_PREAPPROVAL,
        STATUS_PREAPPROVAL_COMPLETE,
        STATUS_PRICE_PENDING_BU,
        STATUS_PRICE_PENDING_SALES,
        STATUS_PENDING_ASSEMBLY_APPROVAL,
        STATUS_PRICE_COMPLETE,
        STATUS_PRICE_ESCALATION,
        STATUS_QUOTED
    };
    
    */
    
       //Abhay - 24-July-2017 :Salesforce 199 :  Opportunity Stage Auto Update Fix
    private static final RFQItemDao rfqItemDao = new RFQItemDao();
    
      //Abhay - 24-July-2017 :Salesforce 199 :  Opportunity Stage Auto Update Fix 
    //Commented below map and replaced by Custom Metadata type "StatusMap__mdt"

/*    private static final Map<String,Integer> statusMap = new Map<String,Integer>{ 
        
        STATUS_PENDING_PROCESSING => 7,
        STATUS_IMPORT_PENDING => 8,
        STATUS_PRICE_DECLINED => 9,
        STATUS_NEW => 10,
        STATUS_DRAFT => 11,
        STATUS_READY_TO_PRICE => 12,
        STATUS_PRICE_SUBMIT => 20,
        STATUS_USER_REQ_PREAPPROVAL =>21,
        STATUS_ACCOUNT_REQ_PREAPPROVAL => 22,
        STATUS_SALES_REQ_PREAPPROVAL => 23,
        STATUS_PREAPPROVAL_COMPLETE => 24,
        STATUS_PRICE_PENDING_SALES => 28,
        STATUS_PRICE_PENDING_BU => 30,
        STATUS_PENDING_ASSEMBLY_APPROVAL => 35,
        STATUS_BU_DRAFT => 40,
        STATUS_PRICE_COMPLETE => 50,
        STATUS_PRICE_ESCALATION => 60,
        STATUS_QUOTED => 70,
        //STATUS_WON_PROTOTYPE => 73,
        //STATUS_WON_QUALIFICATION => 76,
        STATUS_Qual => 76,
        //Lalit - 24-April-2017 : Salesforce 199 - Opportunity Stage Auto Update Fix
        STATUS_PROGRAM_CANCELED => 80,
        STATUS_PROGRAM_LOSS => 82,
        STATUS_PROGRAM_WIN => 85,
        STATUS_PRODUCTION_WIN => 110,
        
         //Abhay - 26-June-2017 : Salesforce-199 - Opportunity Stage Auto Update Fix // changed the No Bid status rankng from 120 --> 6
        //STATUS_NO_BID => 120
        STATUS_NO_BID => 6
       

    };
    
    */
  	

    //AMK-1719  
    /*
    public static final Set<String> reportableStatuses = new Set<String>
    {
        STATUS_PRICE_COMPLETE,
        STATUS_PRICE_DECLINED,
        STATUS_QUOTED,
        STATUS_PROGRAM_WIN,
        STATUS_PROGRAM_LOSS,
        STATUS_PROGRAM_CANCELED,
        STATUS_PRODUCTION_WIN,
        STATUS_PRICE_PENDING_BU,
        STATUS_SALES_REQ_PREAPPROVAL,
        STATUS_PRICE_ESCALATION,
        STATUS_Qual
        //STATUS_WON_PROTOTYPE,
        //STATUS_WON_QUALIFICATION
    };
    */

    public static final Set<String> pfsWithPriceBreakdown = new Set<String>
    {
        'Final Test',
        'Wafer Probe'
    };
    
    /*
    //Bhanu - 9-Mar-2016 : Salesforce-9 Pricing Complete email no longer sent to Test Super users 
    //Updating roleRegionMap as requested by Adam
    public static final Map<String, String> roleRegionMap = new Map<String, String>
    {
        'ASIA' => 'ASIA TEST SALES SUPER USER',
        'EUROPE' => 'EUROPE TEST SALES SUPER USER',
        'JAPAN' => 'JAPAN TEST SALES SUPER USER',
        'US Fabless' => 'USFABLESS TEST SALES SUPER USER',
        'US IDM' => 'USIDM TEST SALES SUPER USER'
    };
    */
    
    
    
     public static final Map<String, String> roleRegionMap = new Map<String, String>
    {
        'ASIA' => 'ASIA TEST SALES SUPER USER',
        'EUROPE' => 'EUROPE TEST SALES SUPER USER',
        'JAPAN' => 'JAPAN TEST SALES SUPER USER',
        'WEST' => 'WEST TEST SALES SUPER USER',
        'SOUTHWEST' => 'SOUTHWEST TEST SALES SUPER USER',
        'EAST' =>'EAST TEST SALES SUPER USER'
    }; 
    
    //Bhanu - 04-May-2016 :Salesforce 10 :  Update the Test Super User Price complete email
    //replacing Hardcoded roleRegionMap with CustomSetting as requested by Adam
    //Map<String, String> roleRegionMap = new Map<String, String>();
       
    private static Set<String> productGroupFields;
    
    
    //Abhay - 24-July-2017 :Salesforce 199 :  Opportunity Stage Auto Update Fix

    @testvisible private RFQItemDao(){  
        
        super('RFQ_Item__c'); 
        

        
        productGroupFields = new Set<String>();
        
        //TODO - these are just to support places where we used the relationship
        //Product Group is now a part of the ItemWrapper and should be used going forward
        //so these can be removed in the future
        //productGroupFields.add('Product_Group__r.Name');
        productGroupFields.add('Product_Group__r.No_Cost_Model__c');
        productGroupFields.add('Product_Group__r.BU_Screen_Columns__c');
        productGroupFields.add('Product_Group__r.Generated_Price_Requires_BU_Review__c');
        //productGroupFields.add('Product_Group__r.Cost_Model_Implementation__c');
        productGroupFields.add('Product_Group__r.Sales_Screen_Columns__c');
        productGroupFields.add('Product_Group__r.Wire_Calculation_Implementation__c');
        productGroupFields.add('Product_Group__r.Generated_Price_Requires_Sales_Review__c');
        productGroupFields.add('Product_Group__r.Generated_Price_Requires_Sales_Review__c');
        productGroupFields.add('Product_Group__r.Sales_Requires_Pre_Approval__c');
    }
    
    /**
    * This method returns an instance of RFQItemDao
    *
    * @returns a RFQItemDao instance
    */
    public static RFQItemDao getInstance() {
        return rfqItemDao;
    }
    
    /**
    * This method gets the RFQ_Item__c with the given Id
    *
    * @param  recordId the RFQ_Item__c Id
    * @returns RFQ_Item__c with the given Id
    */
    public RFQ_Item__c getById(String recordId) {
        return (RFQ_Item__c)getSObjectById(recordId);
    }
    
    /**
    * Get RFQ Items that have a certain CPN (up to a certain limit)
    *
    * @param  cpnId the CPN Id
    * @param   rowLimit the max number of rows to return 
    * @returns a List of RFQ_Item__c that have that CPN
    */
    public List<RFQ_Item__c> getSimilarItems(String cpnId, Integer rowLimit) {
        //String sql = '(Status__c in (' + quote(STATUS_PROGRAM_WIN) + ',' + quote(STATUS_PRODUCTION_WIN) + ',' + quote(STATUS_QUOTED) + ')) ';
        //Ashish 19-July-2017 : Salesforce 225 -Similar RFQ Items feature.
        //Now the Similar RFQ Items are fetched by 5 statuses : Price Complete, Program Loss Closed, Program Win Closed, Qual, Quoted.
        String sql = '(Status__c in (' + quote(STATUS_PRICE_COMPLETE) + ',' + quote(STATUS_PROGRAM_LOSS) + ',' + quote(STATUS_PROGRAM_WIN) + ',' + quote(STATUS_Qual) + ',' + quote(STATUS_QUOTED) + ')) ';
        return getByCpnId(sql, cpnId, rowLimit);
    }
    
    
    /**
    * Get all RFQ Items that have a certain CPN
    *
    * @param accountId The account of the RFQ to limit the search to (optional, if null than no filter)
    * @param startDate The begin date of the search range (optional)
    * @param endDate The end date of the search range (optional)
    * @param  cpnId the CPN Id
    * @param rowLimit max number of rows to return
    * @returns a List of RFQ_Item__c that have that CPN
    */
    public List<RFQ_Item__c> getSimilarItems(String accountId, Date startDate, Date endDate, String cpnId) {
        
        System.debug('### Params are: {' + accountId + ':' + startDate + ':' + endDate + ':' + cpnId + '}');
        
        //String sql = '(Status__c in (' + quote(STATUS_PROGRAM_WIN) + ',' + quote(STATUS_PRODUCTION_WIN) + ',' + quote(STATUS_QUOTED) + ')) ';
        //Ashish 19-July-2017 : Salesforce 225 -Similar RFQ Items feature.
        //Now the Similar RFQ Items are fetched by 5 statuses : Price Complete, Program Loss Closed, Program Win Closed, Qual, Quoted.
        String sql = '(Status__c in (' + quote(STATUS_PROGRAM_WIN) + ',' + quote(STATUS_QUOTED) + ',' + quote(STATUS_PROGRAM_LOSS) + ',' + quote(STATUS_PROGRAM_CANCELED) + ',' + quote(STATUS_Qual) + ',' + quote(STATUS_PRICE_COMPLETE) + ')) ';
        if (!StringUtils.isBlank(accountId)) {
             sql += ' and RFQ__r.SBU_Name__c = ' + quote(accountId);
        }
        if (startDate != null) {
             sql += ' and CreatedDate > ' + StringUtils.getSqlStringForDate(startDate);
        }
        if (endDate != null) {
            sql += ' and CreatedDate < ' + StringUtils.getSqlStringForDate(endDate);
        }
        
        return getByCpnId(sql, cpnId, 49999);
    }
    
    /**
    * Get all RFQ Items that have a certain CPN
    *
    * @param whereClause any Additional SQL to pass in
    * @param  cpnId the CPN Id
    * @param rowLimit max number of rows to return
    * @returns a List of RFQ_Item__c that have that CPN
    */
    private List<RFQ_Item__c> getByCpnId(String whereClause, String cpnId, Integer rowLimit) {
        // addFields(new Set<String>{'RFQ__r.Name', 'Configured_Part_Number__r.Name', 'Package_Family__r.Name', 'RFQ__r.RFQ_Name__c', 'RFQ__r.SBU_Name__c'});
        addFields(new Set<String>{'Package_Family__r.Name', 'RFQ__r.RFQ_Name__c', 'RFQ__r.SBU_Name__c'});
        
        String sql = 'Configured_Part_Number__c = ' + quote(cpnId);
        if (!StringUtils.isBlank(whereClause)) sql += ' and ' + whereClause;
        return (List<RFQ_Item__c>)getSObjects(sql, 'LastModifiedDate', rowLimit);
    }
    
    /**
    * This method gets the List<RFQ_Item__c> with the given rfqId
    *
    * @param  recordId the RFQ
    * @returns List<RFQ_Item__c> with the given Id
    */
    public List<RFQ_Item__c> getByRfqId(String recordId) {
        addFields(new Set<String>{'RFQ__r.Name', 'Configured_Part_Number__r.Name','Package_Family__r.Name', 'Owner.Name'});
        return (List<RFQ_Item__c>)getSObjects('RFQ__c = ' + quote(recordId));
    }

    public Map<String, Decimal> getMaxMinForecast(String forecast, String pg, String pf) {

        return ForecastUtil.getMaxMinForecast(forecast,  pg, pf);
    }



    /**
    * This method gets a List<RFQ_Item__c> with the given RFQI Names (format: RFQI-000001)
    *
    * @param  rfqiNames the set containing all the RFQI #s
    * @returns List<RFQ_Item__c> with the given names
    */
    public List<RFQ_Item__c> getMultipleByName(Set<String> rfqiNames) {
        String inStr = '';

        for (String rfqiName : rfqiNames) {
            if (inStr.length() > 0) inStr += ',';
            inStr += quote(rfqiName);
        }
        return (List<RFQ_Item__c>)getSObjects('Name in (' + inStr + ')');
    }

    /**
    * This method gets the List<RFQ_Item__c> with the given rfqId and Package family
    *
    * @param  recordId the RFQ
    * @returns List<RFQ_Item__c> with the given Id and package family
    */
    public List<RFQ_Item__c> getByRfqAndPfId(String recordId, String packageFamilyId) {
        addFields(new Set<String>{'RFQ__r.Name', 'Configured_Part_Number__r.Name','Package_Family__r.Name'});
        return (List<RFQ_Item__c>)getSObjects('RFQ__c = ' + quote(recordId) + ' and Package_Family__c = ' + quote(packageFamilyId));
    }

    /**
    * This method gets the List<RFQ_Item__c> with the given rfqId and Product Group
    *
    * @param  recordId the RFQ
    * @param  productGroupId the Product Group selected 
    * @returns List<RFQ_Item__c> with the given Id and package family
    */
    public List<RFQ_Item__c> getByRfqAndPgId(String recordId, String productGroupId) {
        addFields(new Set<String>{'RFQ__r.Name', 'Configured_Part_Number__r.Name','Package_Family__r.Name'});
        return (List<RFQ_Item__c>)getSObjects('RFQ__c = ' + quote(recordId) + ' and Package_Family__r.Product_Group__c = ' + quote(productGroupId));
    }
    
    /**
    * This method gets quoted and price complete RFQ Items for the given rfq
    *
    * @param  rfqId the RFQ Id
    * @returns child RFQ Items for the specified RFQ that are in 'Quoted' or 'Price Complete' status
    */
    public List<RFQ_Item__c> getPriceCompleteByRfqId(String rfqId, String sortOrder) {
        addFields(new Set<String>{'RFQ__r.Name', 'Configured_Part_Number__r.Name', 'Package_Family__r.Name', 'Package_Family__r.Product_Group__c', 'Parent_RFQ_Item__r.Package_Family__r.Id', 'Parent_RFQ_Item__r.Name', 'Parent_RFQ_Item__r.Parent_Volume_Item__c', 'Parent_Volume_Item__r.Name'});
        /* return (List<RFQ_Item__c>)getSObjects('RFQ__c = ' + quote(rfqId) + ' and Status__c in (' + quote(STATUS_QUOTED) + ',' + quote(STATUS_PRICE_COMPLETE) + ',' + quote(STATUS_WON_PROTOTYPE) + ',' + quote(STATUS_PROGRAM_CANCELED) + ',' + quote(STATUS_PROGRAM_WIN) + ',' + quote(STATUS_PROGRAM_LOSS) + ',' + quote(STATUS_WON_QUALIFICATION) + ')', sortOrder); */
        return (List<RFQ_Item__c>)getSObjects('RFQ__c = ' + quote(rfqId) + ' and Status__c in (' + quote(STATUS_QUOTED) + ',' + quote(STATUS_PRICE_COMPLETE) + ',' + quote(STATUS_Qual) + ',' + quote(STATUS_PROGRAM_CANCELED) + ',' + quote(STATUS_PROGRAM_WIN) + ',' + quote(STATUS_PROGRAM_LOSS) + ')', sortOrder);
        
    }
    
    /**
    * This method gets RFQ Items based on the parent ID, ordered
    * by the Line_Number__c field (used in the import screen)
    *
    * @param  rfqId the Parent RFQ Id
    * @returns List of RFQ Items for the specified RFQ
    */
    
    public List<RFQ_Item__c> getRfqsByRfqId(String rfqId) {
        return (List<RFQ_Item__c>) getSObjects('RFQ__c = ' + quote(rfqId), 'Line_Number__c');
    }

    public List<RFQ_Item__c> getOwnRFQsByStatus(String userId, Set<String> statuses) {

        String statusList = String.join(new List<String>(statuses),',');
        addFields(new Set<String>{'Package_Family__r.Specific_RFQ_Item_Object__c'});
        return (List<RFQ_Item__c>)getSObjects('RFQ__r.OwnerId = ' + quote(userId) + ' and Status__c in (' + statusList + ')','Name DESC');

    }


    public List<RFQ_Item__c> getReadyRfqItemssByRfqId(String rfqId) {
        return (List<RFQ_Item__c>) getSObjects('RFQ__c = ' + quote(rfqId) + ' AND Status__c = ' + quote(STATUS_READY_TO_PRICE), 'Line_Number__c');
    }

    
    /**
    * This method creates an RFQ Item object with all associated
    * linkages for a particular package family  
    *
    * @param  rfqId  the RFQ__c object
    * @param  packageFamilyId  the Id for the particular package family
    * @param  service  what service {Assembly, Test, Probe..etc}
    * @param  numberOfWires  number of wire objects to create this line item with
    * @param  numberOfDie  number of die objects to create this line item with
    * @param  layoutVersion  current version of the layout of the package family
    *
    * @returns RFQ_Item__c of the proper configuration
    */
    public RFQ_Item__c createItem(String rfqId, String packageFamilyId, String service, Integer numberOfWires, Integer numberOfDie) {
        return createItem(rfqId, packageFamilyId, service, numberOfWires, numberOfDie, 0, 0, 1.0); 
    }
    
    public RFQ_Item__c createItem(String rfqId, String packageFamilyId, String service, Integer numberOfWires, Integer numberOfDie, Decimal layoutVersion) {
        return createItem(rfqId, packageFamilyId, service, numberOfWires, numberOfDie, 0, 0, layoutVersion); 
    }

    public RFQ_Item__c createItem(String rfqId, String packageFamilyId, String service, Integer numberOfWires, Integer numberOfDie, Integer numberOfInsertions, Integer numberOfPassives) {
        return createItem(rfqId, packageFamilyId, service, numberOfWires, numberOfDie, numberOfInsertions, numberOfPassives, 1.0);
    }

    public RFQ_Item__c createItem(String rfqId, String packageFamilyId, String service, Integer numberOfWires, Integer numberOfDie, Integer numberOfInsertions, Integer numberOfPassives, Decimal layoutVersion) {
        
        return createItem(rfqId, packageFamilyId, service, numberOfWires, numberOfDie, numberOfInsertions, numberOfPassives, 1.0, 0);
    }

    public RFQ_Item__c createItem(String rfqId, String packageFamilyId, String service, Integer numberOfWires, Integer numberOfDie, Integer numberOfInsertions, Integer numberOfPassives, Decimal layoutVersion, Integer numberOfServices) {
        
        RFQ_Item__c rfqItem = new RFQ_Item__c();
        rfqItem.RFQ__c = rfqId;
        rfqItem.Service__c = service;
        rfqItem.Package_Family__c = packageFamilyId;
        rfqItem.Layout_Version__c = layoutVersion;
        insert rfqItem;

        //get the package family object so we know what object to create
        Package_Family__c packageFam = PackageFamilyDao.getInstance().getById(packageFamilyId);
        String objectType = packageFam.Specific_RFQ_Item_Object__c;
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectType);
        sObject specificLineItem = targetType.newSObject(); 
        specificLineItem.put('RFQ_Item__c',rfqItem.Id);
        insert specificLineItem;
        createWireObject(packageFam,specificLineItem.Id,numberOfWires);
        createDieObject(packageFam,specificLineItem.Id,numberOfDie);
        createInsertionObject(packageFam,specificLineItem.Id,numberOfInsertions);
        createPassiveObject(packageFam,specificLineItem.Id,numberOfPassives);
        createServiceObject(packageFam,specificLineItem.Id,numberOfServices);

        //create status history object
        RFQIStatusHistoryDao.getInstance().newStatusHistory(rfqItem);

        if(packageFam.Default_NRE_Configs__c != null) {
            addDefaultNREOthers(packageFam.Default_NRE_Configs__c, rfqItem.Id);
        }

        return rfqItem;
    }

    private static void addDefaultNREOthers(String nreConfigs, String rfqItemId) {
        try {
            Map<String, Object> rawMap = (Map<String, Object>)System.JSON.deserializeUntyped(nreConfigs);
            Map<String, String> nreMap = new Map<String, String>();

            for (String key : rawMap.keySet()) {
                nreMap.put(key, (String)rawMap.get(key));
            }

            List<RFQI_NRE__c> nres = new List<RFQI_NRE__c>();
            for(String nreconfig : nreMap.keySet()) {
                nres.add(new RFQI_NRE__c(Description__c = nreconfig, Price_New__c = Decimal.valueOf(nreMap.get(nreconfig)), Parent__c = rfqItemId));
            }
            insert nres;
        }
        catch(Exception e) {
            System.debug('Could not create NRE defaults: ' + e);
        }
    }

    public RFQ_Item__c createItem(String rfqId, String packageFamilyId, String service, Integer numberOfWires) {
        return createItem(rfqId, packageFamilyId, service, numberOfWires, 0, 1); 
    }

    public RFQ_Item__c createItem(String rfqId, String packageFamilyId, String service, Integer numberOfWires, Decimal layoutVersion) {
        return createItem(rfqId, packageFamilyId, service, numberOfWires, 0, layoutVersion); 
    }
    
    //new method for use in conjunction with deleting configuration objects
    //by ID instead of by index
    public static void deleteConfig(sObject removeConfig) {
        delete removeConfig;
    }
    
   
    /**
    * This method creates an die configuration object with all associated
    * linkages for a particular package family  
    *
    * @param  family  a package family object
    * @param  specificLineItemId  the record id of the the particuluar specific line item to link to
    *
    * @returns sObject of the proper die configuration type
    */

    public static List<sObject> createDieObject(Package_Family__c family, String specificLineItemId, Integer numberDie) {
        return createChildItemObject(specificLineItemId,family.Specific_Die_Configuration_Object__c,numberDie, true);
    }

    public static List<sObject> createDieObject(Package_Family__c family, String specificLineItemId, Integer numberDie, Boolean shouldInsert) {
        return createChildItemObject(specificLineItemId,family.Specific_Die_Configuration_Object__c,numberDie, shouldInsert);
    }
    
    public static List<sObject> createPassiveObject(Package_Family__c family, String specificLineItemId, Integer numberPassive) {
        return createChildItemObject(specificLineItemId,family.Specific_Passive_Configuration_Object__c,numberPassive, true);
    }

    public static List<sObject> createPassiveObject(Package_Family__c family, String specificLineItemId, Integer numberPassive, Boolean shouldInsert) {
        return createChildItemObject(specificLineItemId,family.Specific_Passive_Configuration_Object__c,numberPassive, shouldInsert);
    }

    public static List<sObject> createInsertionObject(Package_Family__c family, String specificLineItemId, Integer numberInsertion) {
        return createChildItemObject(specificLineItemId,family.Specific_Insertion_Configuration_Object__c,numberInsertion, true);
    }

    public static List<sObject> createInsertionObject(Package_Family__c family, String specificLineItemId, Integer numberInsertion, Boolean shouldInsert) {
        return createChildItemObject(specificLineItemId,family.Specific_Insertion_Configuration_Object__c,numberInsertion, shouldInsert);
    }

    public static sObject cloneInsertionObject(Package_Family__c family, String specificLineItemId, Integer numberInsertion, sObject cloneObject) {
        return cloneChildItemObject(specificLineItemId,family.Specific_Insertion_Configuration_Object__c,numberInsertion, cloneObject);     
    }

    public static List<sObject> createWireObject(Package_Family__c family, String specificLineItemId,Integer numberWire) {
        return createChildItemObject(specificLineItemId,family.Specific_Wire_Configuration_Object__c,numberWire, true);
    }

    public static List<sObject> createWireObject(Package_Family__c family, String specificLineItemId,Integer numberWire, Boolean shouldInsert) {
        return createChildItemObject(specificLineItemId,family.Specific_Wire_Configuration_Object__c,numberWire, shouldInsert);
    }

    public static List<sObject> createServiceObject(Package_Family__c family, String specificLineItemId,Integer numberService) {
        return createChildItemObject(specificLineItemId,family.Specific_Service_Configuration_Object__c,numberService, true);
    }

    public static List<sObject> createServiceObject(Package_Family__c family, String specificLineItemId,Integer numberService, Boolean shouldInsert) {
        return createChildItemObject(specificLineItemId,family.Specific_Service_Configuration_Object__c,numberService, shouldInsert);
    }

    public static List<sObject> createNREObject(Package_Family__c family, String rfqItemId,Integer numberService) {
        return createChildItemObject(rfqItemId,'RFQI_NRE__c',numberService, true);
    }

    public static List<sObject> createNREObject(Package_Family__c family, String rfqItemId,Integer numberService, Boolean shouldInsert) {
        return createChildItemObject(rfqItemId,'RFQI_NRE__c',numberService, shouldInsert);
    }

    private static List<sObject> createChildItemObject(String specificLineItemId, String objectName, Integer numberObjects) {
        return createChildItemObject(specificLineItemId, objectName, numberObjects, true);
    }
    private static List<sObject> createChildItemObject(String specificLineItemId, String objectName, Integer numberObjects, Boolean shouldInsert) {
      
        if(StringUtils.isBlank(objectName)) return null;        
        List<sObject> children = new List<sObject>();

        for(Integer i = 0; i < numberObjects; i++) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectName.trim());       
        sObject specificConfiguration = targetType.newSObject(); 
        specificConfiguration.put('Parent__c', specificLineItemId);
        children.add(specificConfiguration);
        }
        //TODO - see if we can not have to return an sObject at all..
        if(children.size() > 0) {
            if (shouldInsert) insert children;
            return children;
        }
        return null;
    }

    private static sObject cloneChildItemObject(String specificLineItemId, String objectName, Integer numberObjects, sObject cloneObject) {
      
        if(StringUtils.isBlank(objectName)) return null;        
        List<sObject> children = new List<sObject>();

        for(Integer i = 0; i < numberObjects; i++) {      
        sObject specificConfiguration = cloneObject.clone(false, true, false, false);
        specificConfiguration.put('Parent__c', specificLineItemId);
        children.add(specificConfiguration);
        }
        //TODO - see if we can not have to return an sObject at all..
        if(children.size() > 0) {
            insert children;
            return children[0];
        }
        return null;
    }

    
    /**
    * This method saves a RFQItemWrapper object with all associated
    * linkages 
    *
    * @param  wrapper a RFQItemWrapper with all the components {RFQ_Item__c, specific line item, wire configurations}to save
    *
    */
    public Boolean saveLineItem(RFQItemWrapper wrapper) {
        
        return saveLineItem(wrapper, true);
    }
    public Boolean saveLineItem(RFQItemWrapper wrapper, Boolean runWireCalc) {
        return saveLineItem(wrapper, runWireCalc, false);

    }

    public Boolean saveLineItem(RFQItemWrapper wrapper, Boolean runWireCalc, Boolean updateBUPrice) {
        return saveLineItem(wrapper, runWireCalc, updateBUPrice, false);

    }

    public Boolean saveLineItem(RFQItemWrapper wrapper, Boolean runWireCalc, Boolean updateBUPrice, Boolean clearMultiVolume) {
        return saveLineItems(new List<RFQItemWrapper>{wrapper}, runWireCalc, updateBUPrice, clearMultiVolume);
    }

    public Boolean saveLineItems(List<RFQItemWrapper> wrappers, Boolean runWireCalc, Boolean updateBUPrice, Boolean clearMultiVolume) {

        List<sObject> itemObjects = new List<sObject>();

        List<sObject> allRfqItems = new List<sObject>();
        List<sObject> allSpecificRfqItems = new List<sObject>();
        List<sObject> allWireConfigurations = new List<sObject>();
        List<sObject> allDieConfigurations = new List<sObject>();
        List<sObject> allPassiveConfigurations = new List<sObject>();
        List<sObject> allInsertionConfigurations = new List<sObject>();
        List<sObject> allServiceConfigurations = new List<sObject>();
        List<sObject> allNreConfigurations = new List<sObject>();

        //list of ids relating to items which may have added services to be updated
        Set<String> parentsOfServices = new Set<String>();
        Map<String, RFQItemWrapper> parentWrapperMap = new Map<String, RFQItemWrapper>();
        for (RFQItemWrapper wrapper : wrappers)
        {
            if (runWireCalc)
            {
                try {
                    Type t = Type.forName(wrapper.packageFamily.Product_Group__r.Wire_Calculation_Implementation__c);
                    CMWireCalcBase wireCalc = (CMWireCalcBase)t.newInstance();
                    wireCalc.calculate(wrapper);
                } 
                catch(Exception e) {}//Todo - base wirecalculator? 
                
            }

            //wrapper.calculateAuPricing();

            //switch to check to overwrite, in order to clear this field on 
            if (clearMultiVolume) wrapper.rfqItem.Multi_Volume__c = 'null';
            else wrapper.rfqItem.Multi_Volume__c = JSON.serialize(wrapper.volumeList);
        
            //AMK-2279, check if multi volumes were added and if so, add that to all added services
            if (!clearMultiVolume && wrapper.rfqitem.Service__c == 'Assembly')
            {
                parentsOfServices.add(wrapper.rfqItem.Id);
                parentWrapperMap.put(wrapper.rfqItem.Id, wrapper);
            }


            //TODO - check this logic against creating multi volumes - possible?
            //AMK-1867
            //default drivers need to update the BU price for engineering services
            if(wrapper.productGroup.Name == 'Engineering Services') {
                if(wrapper.packageFamily.Name != 'Electrical Services' && wrapper.packageFamily.Name != 'Design'){
                    Decimal serviceTotal = 0;
                    try {
                        for (sObject service : wrapper.serviceConfigurations) {
                            serviceTotal += (service.get('Sub_Total__c') == null) ? 0 : (Decimal)service.get('Sub_Total__c');
                        }
                        wrapper.specificRfqItem.put('BU_Price__c', serviceTotal);
                    }
                    catch(exception e){}
                }
                else if(updateBUPrice) {
                    if(wrapper.packageFamily.Name == 'Design') {
                        wrapper.specificRfqItem.put('BU_Price__c', wrapper.specificRfqItem.get('Service_Total__c'));
                    }
                    else if (wrapper.packageFamily.Name == 'Electrical Services') {
                        wrapper.specificRfqItem.put('BU_Price__c', ElectricalServicesPricing.electricalServicesPricing(wrapper));
                    }
                }
            }
            updateJsonFields(wrapper);
            if(wrapper.rfqItem != null) allRfqItems.add(wrapper.rfqItem);
            allSpecificRfqItems.add(wrapper.specificRfqItem);
            if(wrapper.wireConfigurations != null) allWireConfigurations.addAll(wrapper.wireConfigurations);
            if(wrapper.dieConfigurations != null) allDieConfigurations.addAll(wrapper.dieConfigurations);
            if(wrapper.passiveConfigurations != null) allPassiveConfigurations.addAll(wrapper.passiveConfigurations);
            if(wrapper.insertionConfigurations != null) allInsertionConfigurations.addAll(wrapper.insertionConfigurations);
            if(wrapper.serviceConfigurations != null) allServiceConfigurations.addAll(wrapper.serviceConfigurations);
            if(wrapper.nreConfigurations != null) allNreConfigurations.addAll(wrapper.nreConfigurations);
            copyFieldsToGeneric(wrapper);
        }

        //AMK-2279, find added services and update their multi volume configs
        Set<String> itemsToRecall = new Set<String>();
        Set<String> itemsToResubmit = new Set<String>();
        List<RFQI_Escalation__c> escalations = new List<RFQI_Escalation__c>();

        if (!parentsOfServices.isEmpty())
        {
            updateAddedServiceVolumeConfigs(parentWrapperMap, parentsOfServices, itemObjects, itemsToResubmit, escalations, itemsToRecall);
        }

        //two steps to add to this list because there is a limit of 10 chunks in sObject list when updating
        itemObjects.addAll(allRfqItems);
        itemObjects.addAll(allSpecificRfqItems);
        itemObjects.addAll(allWireConfigurations);
        itemObjects.addAll(allDieConfigurations);
        itemObjects.addAll(allPassiveConfigurations);
        itemObjects.addAll(allInsertionConfigurations);
        itemObjects.addAll(allServiceConfigurations);
        itemObjects.addAll(allNreConfigurations);
        Boolean success = true;
        
        //Abhay SF-204 unlock cloned items to bypass [Record lock for editing Exception]
        
        List<RFQ_Item__c> relatedRFQIsToUnlock = new List<RFQ_Item__c>();
        
        List<RFQ_Item__c> relatedRFQIs = [select id from RFQ_Item__c where Parent_RFQ_Item__c IN:allRfqItems];//collecting related RFQIs
        
        For(RFQ_Item__c rfqi:relatedRFQIs){ 
            If(Approval.isLocked(rfqi)){
                //system.debug('Following RFQI is Locked'+rfqi.id);
                relatedRFQIsToUnlock.add(rfqi); // collecting related locked RFQIs
            }
        }
        
        //system.debug('Size of relatedRFQIsToUnlock : '+relatedRFQIsToUnlock.size());
         
        try
        {
            system.debug('--->RFQItemDao.savelineitem, 688, itemobjects : ' + itemObjects);

            // Unlock Related RFQIs //changed as part of SF-204
            if(relatedRFQIsToUnlock.size()>0){
               RecordLockUtils.unlockRelatedRFQIs(relatedRFQIsToUnlock);
            }
            
            update itemObjects;
            
            // Lock the Unlocked RFQIs //changed as part of SF-204
            if(relatedRFQIsToUnlock.size()>0){
             //  RecordLockUtils.lockRelatedRFQIs(relatedRFQIsToUnlock);
            }
        }
        catch (System.Dmlexception e)
        {
            if (e.getDmlType(0) == StatusCode.STRING_TOO_LONG) 
            {
                success = false;
            }
        }
        //start approvals after update so status isn't wiped out
        //recall items
        if (!itemsToRecall.isEmpty()) ApprovalUtils.recallItems(itemsToRecall, 'Automatic recall: additional volume configurations were updated on item');
        for (String item : itemsToResubmit)
        {
            ApprovalUtils.startApproval(item, 'Automatic submission: additional volume configurations were updated on item');
        }
        //escalate items
        for (RFQI_Escalation__c item : escalations)
        {
            ApprovalUtils.startApproval(item.RFQ_Item__c, item.Reason__c + ': ' + item.Comments__c);
        }
        return success;

    }

    public void updateAddedServiceVolumeConfigs(Map<String, RFQItemWrapper> parentWrapperMap, Set<String> parentsOfServices, List<sObject> itemObjects, Set<String> itemsToResubmit, List<RFQI_Escalation__c> escalations, Set<String> itemsToRecall)
    {
        addFields(new Set<String>{'Package_Family__r.Specific_RFQ_Item_Object__c', 
            'Package_Family__r.Sales_Requires_Pre_Approval__c', 
            'RFQ__r.SBU_Name__r.Sales_Region__c'});
        
        String tempWhereClause = 'Package_Family_Name__c != \'Bump\' AND Package_Family_Name__c != \'Bump/WLCSP (Wafer Services)\' AND Package_Family_Name__c != \'Die Processing Service (WLCSP)\' AND Package_Family_Name__c != \'WLCSP (Die Services)\' AND Package_Family_Name__c != \'WLCSP\' AND Package_Family_Name__c != \'Die Processing Service\' AND Test_Type__c != \'Wafer Probe\''; 
        List<RFQ_Item__c> addedServiceItems = getSObjectByIdSet('Parent_RFQ_Item__c', parentsOfServices, tempWhereClause);

        Set<String> itemsToEscalate = new Set<String>();

        RFQItemWrapper childWrapper, parentWrapper;
        RFQIVOlume tempVolume;
        List<RFQIVolume> tempVolumeList;
        for (RFQ_Item__c addedService : addedServiceItems)
        {
            //if (childWrapper.rfqItem.Package_Family_Name__c != AMKVARS.PF_BUMP && childWrapper.rfqItem.Test_Type__c != AMKVARS.TT_PROBE && packagefamily.Name != 'Die Processing Service (WLCSP)') {
                childWrapper = new RFQItemWrapper();
                childWrapper.rfqItem = addedService;
                childWrapper.inflateVolume();
                parentWrapper = parentWrapperMap.get(addedService.Parent_RFQ_Item__c);
                //for use with RFQItemController.getNewStatusForSubmit(), save a query by using reference to pf from item
                childWrapper.packageFamily = new Package_Family__c();
                childWrapper.packageFamily.Sales_Requires_Pre_Approval__c = addedService.Package_Family__r.Sales_Requires_Pre_Approval__c;

                //AMK-2403, forecast on child is not editable so must match parent's
                addedService.Forecast__c = parentWrapper.rfqItem.Forecast__c;
                addedService.Volume__c = parentWrapper.rfqItem.Forecast__c;

                Map<String, RFQIVolume> childVolumeMap = new Map<String, RFQIVolume>();

                for (RFQIVolume childVolume : childWrapper.volumeList)
                {
                    //use .volume here even for test because the volume comes from the parent volume
                    childVolumeMap.put(childVolume.parentVolumeKey, childVolume);
                }

                //build new volume list from scratch, 
                //refer to old ones in map where needed
                tempVolumeList = new List<RFQIVolume>();

                for (RFQIVolume parentVolume : parentWrapper.volumeList)
                {
                    //depending on how multi volumes were added/removed
                    //from parent item, the child volume could either:
                    //--have the same forecast with the same index
                    //--have the same forecast with a different index
                    //--not exist in the parent list (it was deleted)
                    //--exist only in the parent list (it was added)

                    tempVolume = childVolumeMap.get(parentVolume.volume);
                    if (tempVolume == null)
                    {
                        RFQIVolume newVolume = new RFQIVolume(false);
                        newVolume.volume = parentVolume.volume;
                        newVolume.parentVolumeKey = parentVolume.volume;
                        newVolume.index = parentVolume.index;
                        //run cost model on next bu page load for this multi volume
                        newVolume.needsRecalc = true;
                        tempVolumeList.add(newVolume);
                    }
                    else
                    {
                        tempVolume.index = parentVolume.index;
                        tempVolumeList.add(tempVolume);
                    }
                }
                addedService.Multi_Volume__c = JSON.serialize(tempVolumeList);
                //only recall if the volume lists are not the same
                if (tempVolumeList != childWrapper.volumeList)
                {
                    //if status is pending assembly, then the approval process is finished, so escalate. 
                    //Otherwise, recall the item
                    //Bump requires sales to enter a volume, so punt it back to sales
                    if (addedService.Status__c == STATUS_PENDING_ASSEMBLY_APPROVAL || addedService.Status__c == STATUS_PRICE_COMPLETE)
                    {
                        if (addedService.Package_Family_Name__c != AMKVARS.PF_BUMP && addedService.Test_Type__c != AMKVARS.TT_PROBE) 
                        {
                            addedService.Status__c = STATUS_PRICE_ESCALATION;
                            itemsToEscalate.add(addedService.Id);
                        }
                        else addedService.Status__c = STATUS_NEW;
                    }
                    else
                    {
                        if(addedService.Status__c == STATUS_PRICE_PENDING_BU || addedService.Status__c == STATUS_SALES_REQ_PREAPPROVAL) 
                        {
                            addedService.Status__c = RFQItemController.getNewStatusForSubmit(childWrapper);
                            if (addedService.Package_Family_Name__c != AMKVARS.PF_BUMP && addedService.Test_Type__c != AMKVARS.TT_PROBE) itemsToResubmit.add(addedService.Id);
                            itemsToRecall.add(addedService.Id);
                        }
                        else if (addedService.Status__c == STATUS_PRICE_ESCALATION)
                        {
                            if (addedService.Package_Family_Name__c != AMKVARS.PF_BUMP && addedService.Test_Type__c != AMKVARS.TT_PROBE) itemsToResubmit.add(addedService.Id);
                            itemsToRecall.add(addedService.Id);
                        }
                    }
                }
            //}
        }

        //update forecast on specific line items
        if (!addedServiceItems.isEmpty())
        {
            updateForecastForAddedServiceSpecificItems(addedServiceItems, parentWrapperMap, itemObjects);
        }
        

        //escalate items
        RFQI_Escalation__c escalation;
        for (String itemId : itemsToEscalate)
        {
            escalation = new RFQI_Escalation__c(Reason__c='Automatic Escalation', Comments__c='additional volume configurations were updated on item');
            escalation.RFQ_Item__c = itemId;        
            escalations.add(escalation);
        }

        //insert them by themselves because cannot upsert on List<sObject>
        if (!escalations.isEmpty()) insert escalations;

        //update added service items
        itemObjects.addAll((List<sObject>)addedServiceItems);
    }

    private void updateForecastForAddedServiceSpecificItems(List<RFQ_Item__c> addedServiceItems, Map<String, RFQItemWrapper> parentWrapperMap, List<sObject> itemObjects)
    {
        Map<String, Set<String>> itemIdMap = new Map<String, Set<String>>();
        for (RFQ_Item__c item : addedServiceItems)
        {
            Set<String> itemIds = itemIdMap.get(item.Package_Family__r.Specific_RFQ_Item_Object__c);
            if (itemIds == null) itemIdMap.put(item.Package_Family__r.Specific_RFQ_Item_Object__c, new Set<String>{item.Id});
            else itemIds.add(item.Id);
        }

        for (String specificObjectName : itemIdMap.keyset())
        {
            BaseDao dao = new BaseDao(specificObjectName);
            dao.addSingleField('RFQ_Item__r.Parent_RFQ_Item__c');
            List<sObject> specificRfqItems = dao.getSObjectByIdSet('RFQ_Item__c', itemIdMap.get(specificObjectName));

            for (sObject obj : specificRfqItems)
            {
                RFQItemWrapper pWrapper = parentWrapperMap.get((String)obj.getSObject('RFQ_Item__r').get('Parent_RFQ_Item__c'));
                obj.put('Forecast__c', pWrapper.rfqItem.Forecast__c);
            }
            itemObjects.addAll((List<sObject>)specificRfqItems);
        }
    }

    public RFQItemWrapper refresh(RFQItemWrapper wrapper) {
        saveLineItem(wrapper, true);
        return getWrapperById(wrapper.rfqItem.Id);
    }

    public RFQItemWrapper refresh(RFQItemWrapper wrapper, Boolean runWireCalc) {
        saveLineItem(wrapper, runWireCalc);
        return getWrapperById(wrapper.rfqItem.Id);
    }

    public RFQItemWrapper refresh(RFQItemWrapper wrapper, Boolean runWireCalc, Boolean copyToGeneric) {
        saveLineItem(wrapper, runWireCalc, copyToGeneric);
        return getWrapperById(wrapper.rfqItem.Id);
    }

    public RFQItemWrapper refreshForDD(RFQItemWrapper wrapper, String driverObj, String childObj, String packageFamilyId, String rfqItemId) {
        if(simpleSaveForDD(wrapper)) {
            return getSmallWrapperById(rfqItemId, driverObj, childObj, packageFamilyId);
        }
        else return null;
    }

    public Boolean simpleSaveForDD(RFQItemWrapper wrapper) {
        List<sObject> itemObjects = new List<sObject>();
        if(wrapper.rfqItem != null) itemObjects.add(wrapper.rfqItem);
        itemObjects.add(wrapper.specificRfqItem);
        if(wrapper.wireConfigurations != null) itemObjects.addAll(wrapper.wireConfigurations);
        if(wrapper.dieConfigurations != null) itemObjects.addAll(wrapper.dieConfigurations);
        if(wrapper.passiveConfigurations != null) itemObjects.addAll(wrapper.passiveConfigurations);
        if(wrapper.insertionConfigurations != null) itemObjects.addAll(wrapper.insertionConfigurations);
        if(wrapper.serviceConfigurations != null) itemObjects.addAll(wrapper.serviceConfigurations);
        if(wrapper.nreConfigurations != null) itemObjects.addAll(wrapper.nreConfigurations);

        Boolean success = true;

        try
        {
            update itemObjects;
        }
        catch (System.Dmlexception e)
        {
            if (e.getDmlType(0) == StatusCode.STRING_TOO_LONG) 
            {
                success = false;
            }
        }
        return success;
    }


    public static void updateJsonFields(RFQItemWrapper wrapper) {
        String rfqiJson = System.JSON.serialize(wrapper.specificRfqItem);
        String rfqiWcJson = '';
        String rfqiDcJson = '';
        String rfqiPcJson = '';
        String rfqiIcJson = '';
        String rfqiScJson = '';
        String rfqiNcJson = '';

        if (wrapper.wireConfigurations != null) {
            rfqiWcJson = System.JSON.serialize(wrapper.wireConfigurations);
        }
        if (wrapper.dieConfigurations != null) {
            rfqiDcJson = System.JSON.serialize(wrapper.dieConfigurations);
        }
        if (wrapper.passiveConfigurations != null) {
            rfqiPcJson = System.JSON.serialize(wrapper.passiveConfigurations);
        }
        if (wrapper.insertionConfigurations != null) {
            rfqiIcJson = System.JSON.serialize(wrapper.insertionConfigurations);
        }
        if (wrapper.serviceConfigurations != null) {
            rfqiScJson = System.JSON.serialize(wrapper.serviceConfigurations);
        }
        if (wrapper.nreConfigurations != null) {
            rfqiNcJson = System.JSON.serialize(wrapper.nreConfigurations);
        }

        wrapper.rfqItem.RFQI_JSON__c = rfqiJson;
        wrapper.rfqItem.RFQIWC_JSON__c = rfqiWcJson;
        wrapper.rfqItem.RFQIDC_JSON__c = rfqiDcJson;
        wrapper.rfqItem.RFQIPC_JSON__c = rfqiPcJson;
        wrapper.rfqItem.RFQIIC_JSON__c = rfqiIcJson;
        wrapper.rfqItem.RFQISC_JSON__c = rfqiScJson;
        wrapper.rfqItem.RFQINC_JSON__c = rfqiNcJson;
    }

    public void saveWireConfigurationById(RFQItemWrapper wrapper, String wireId) {
        try {
            Type t = Type.forName(wrapper.packageFamily.Product_Group__r.Wire_Calculation_Implementation__c);
            CMWireCalcBase wireCalc = (CMWireCalcBase)t.newInstance();
            wireCalc.calculate(wrapper, wireId);
        } catch(Exception e) {
            //TODO -- instead of try catching this, what we really should do is have a default
            //wirecalculation class that gets used
        }
        update wrapper.wireConfigurations;
    }

    public void copyFieldsToGeneric(RFQ_Item__c rfqItem, sObject specificRfqItem, sObject wireConfiguration) {
        RFQItemWrapper wrapper = new RFQItemWrapper();
        wrapper.rfqItem = rfqItem;
        wrapper.specificRfqItem = specificRfqItem;
        wrapper.wireConfigurations = new List<sObject> { wireConfiguration };

        copyFieldsToGeneric(wrapper);
    }
    
    public void copyFieldsToGeneric(RFQItemWrapper wrapper) {
        RFQ_Item__c rfqItem = wrapper.rfqItem;
        sObject specificRfqItem = wrapper.specificRfqItem;
        //tried to get away with not using a field for this, but they wanted the label on the RFQ View related list
        if (pfsWithPriceBreakdown.contains(wrapper.packageFamily.Name) && wrapper.packageFamily.Inactive__c)
        {
            if (specificRfqItem.get('BU_Price_Per_Hour__c') != null && (Decimal)specificRfqItem.get('BU_Price_Per_Hour__c') > 0)
            {
                rfqItem.Price_To_Customer__c = DataUtils.getDecimal(specificRfqItem,'Price_To_Customer_Hour__c',null);
                rfqItem.BU_Price__c = DataUtils.getDecimal(specificRfqItem,'BU_Price_Per_Hour__c',null);
                rfqItem.BU_Price_Label__c = ' / Hour';
            }
            else if(specificRfqItem.get('BU_Price_per_Minute__c') != null && (Decimal)specificRfqItem.get('BU_Price_per_Minute__c') > 0)
            {
                rfqItem.Price_To_Customer__c = DataUtils.getDecimal(specificRfqItem,'Price_To_Customer_Minute__c',null);
                rfqItem.BU_Price__c = DataUtils.getDecimal(specificRfqItem,'BU_Price_per_Minute__c',null);
                rfqItem.BU_Price_Label__c = ' / Minute';
            }
            else if(specificRfqItem.get('BU_Price__c') != null && (Decimal)specificRfqItem.get('BU_Price__c') > 0)
            {
                rfqItem.Price_To_Customer__c = DataUtils.getDecimal(specificRfqItem,'Price_To_Customer__c',null);
                rfqItem.BU_Price__c = DataUtils.getDecimal(specificRfqItem,'BU_Price__c',null);
                rfqItem.BU_Price_Label__c = ' / Unit';
            }

        }
        else
        {
            rfqItem.BU_Price__c = DataUtils.getDecimal(specificRfqItem,'BU_Price__c',null);
            rfqItem.Price_To_Customer__c = DataUtils.getDecimal(specificRfqItem,'Price_To_Customer__c',null);
            if(wrapper.packageFamily.Name == AMKVARS.PF_TEST) {
                try{
                    String testType = (String)(specificRfqItem.get('Test_Type__c'));
                    rfqItem.BU_Price_Label__c = (String)(specificRfqItem.get('Test_Quote_Unit_of_Measure__c'));
                    rfqItem.Test_Type__c = testType;
                    if(testType == AMKVARS.TT_POST) {
                        rfqItem.Price_To_Customer__c = DataUtils.getDecimal(specificRfqItem,'Post_Price_To_Customer__c',null);
                        rfqItem.BU_Price__c = DataUtils.getDecimal(specificRfqItem,'BU_Post_Test_Price_Unit__c',null);
                    }

                }
                catch(Exception e){}
            }
            
        }
        
        rfqItem.Customer_Target_Price__c = DataUtils.getDecimal(specificRfqItem,'Customer_Target_Price__c',null);
        rfqItem.Sales_Target_Price__c = DataUtils.getDecimal(specificRfqItem,'Sales_Target_Price__c',null);
        rfqItem.Competitor__c = DataUtils.getString(specificRfqItem,'Competitor__c','');
        rfqItem.Competitor_AU_Inclusive_Price__c = DataUtils.getDecimal(specificRfqItem,'Competitor_Au_Inclusive_Price__c',null);
        //Lalit - 22-Dec-2016 : Salesforce-170 : Enable reporting on the Automotive Checkbox at the RFQI level
        // Added one more entry for Automotive field to copy value from specificRfqItem to rfqitem.
        // Not Allowing to Update the Automotive field if the prodcutgroup : 'Engineering Services' and 
        //if the package family is one of ('final test',' and 'wafer probe', 'test','Embedded Die').
        if(wrapper.productGroup.Name != 'Engineering Services' && wrapper.packageFamily.Name != 'Final Test' && wrapper.packageFamily.Name != 'Wafer Probe' && wrapper.packageFamily.Name != 'Test' && wrapper.packageFamily.Name != 'Embedded Die'){
            rfqItem.Automotive__c = DataUtils.getBoolean(specificRfqItem,'Automotive__c',false);
        }
        rfqItem.End_Market_Segment__c = DataUtils.getString(specificRfqItem,'End_Market_Segment__c','');
        rfqItem.Volume__c = DataUtils.getString(specificRfqItem,'Forecast__c','');
        rfqItem.Total_Perc_GM__c = wrapper.getPercGm();
        rfqItem.Mold_Type__c = DataUtils.getString(specificRfqItem, 'Mold_Type__c', null);
        rfqItem.Number_Of_Die__c = wrapper.dieConfigurations == null ? 0 : wrapper.dieConfigurations.size();
        rfqItem.Number_Of_Wires__c = wrapper.getNumberOfWiresTotal();
        rfqItem.Total_Wire_Length__c = wrapper.getNumberOfTotal3dWireLength();
        rfqItem.Heatspreader__c = DataUtils.getString(specificRfqItem, 'Heatspreader__c', null);
        //rfqItem.HVP_Anticipated_Start_Date__c = DataUtils.getDate(specificRfqItem, 'HVP_Anticipated_Start_Date__c', null);
        //TODO - don't know if it makes much difference - might be nice to move the some of this stuff
        //into RFQItemWrapper - e.g. getVolume methods?
        //copy forecast to generic 
        try {
            String forecastField = 'Forecast__c';
            String pfName = wrapper.rfqItem.Package_Family_Name__c;
            String pgName = wrapper.rfqItem.Product_Group_Name__c;
            //if(wrapper.packageFamily.Name == 'Advanced Product Development' || wrapper.packageFamily.Name == AMKVARS.PF_TEST) {
            //    rfqItem.Forecast_Minimum__c = (Decimal)specificRfqItem.get('Forecast__c');
            //    rfqItem.Forecast_Maximum__c = (Decimal)specificRfqItem.get('Forecast__c'); 
            //}
            if(wrapper.packageFamily.Name == 'Wafer Die Processing' || wrapper.packageFamily.Name == 'Die Processing Service') {
                if(specificRfqItem.get('Die_per_Month__c') != null){//the RFQI uses the old Die per Month field
                    forecastField = 'Die_per_Month__c';
                }
            }
            if(wrapper.rfqItem.Is_Child__c && wrapper.rfqItem.Package_Family_Name__c != AMKVARS.PF_BUMP && wrapper.rfqItem.Package_Family_Name__c != 'Die Processing Service (WLCSP)' && wrapper.rfqItem.Package_Family_Name__c != 'WLCSP' && wrapper.rfqItem.Package_Family_Name__c != 'Die Processing Service' && wrapper.rfqItem.Test_Type__c != AMKVARS.TT_PROBE && wrapper.rfqItem.Package_Family_Name__c != AMKVARS.PF_WLCSP) {
                pfName = wrapper.rfqItem.Parent_RFQ_Item_Package_Family_Name__c;
                pgName = wrapper.rfqItem.Parent_RFQ_Item_Product_Group_Name__c;
            }
            Map<String, Decimal> forecastMap = ForecastUtil.getMaxMinForecast(String.valueOf(specificRfqItem.get(forecastField)), pgName, pfName);
            rfqItem.Forecast_Minimum__c = forecastMap.get('min');
            rfqItem.Forecast_Maximum__c = forecastMap.get('max');

            
            rfqItem.Package_Item_Value__c = ((rfqItem.Forecast_Minimum__c+rfqItem.Forecast_Maximum__c)/2)*(Decimal)specificRfqItem.get('Price_To_Customer__c');
        }catch(Exception e){}   

        try {
            Object oForecast = specificRfqItem.get('Forecast__c');
            String sVal = '';
            if (oForecast != null) sVal = String.valueOf(oForecast);

            rfqItem.Forecast__c = sVal;
        } catch (Exception e) {}

        try {
            sObject factory = wrapper.specificRfqItem.getSObject('Factory__r');
            rfqItem.Factory__c = String.valueOf(factory.get('Name'));
            System.debug('SpecificItem Sales Factory '+rfqItem.Factory__c);
            //Ashish 02-June-2017 : Salesforce 116 -Add Amkor Preferred picklist value under Factory for RFQI.
            sObject buFactory = wrapper.specificRfqItem.getSObject('BU_Factory__r');
            System.debug('SpecificItem BU Factory '+buFactory);
            rfqItem.BU_Factory__c = String.valueOf(buFactory.get('Name'));
            System.debug('rfqItem BU Factory '+rfqItem.BU_Factory__c);
        }catch(Exception e){}
        

        try {   
            String projectName = StringUtils.sanitize((String) specificRfqItem.get('Customer_Project_Name__c'));
            String deviceName = StringUtils.sanitize((String)specificRfqItem.get('Customer_Device_Name__c'));
            rfqItem.Project_Device__c = StringUtils.isBlank(deviceName) ? projectName : projectName + ' / ' + deviceName;  
        } catch(Exception e) {}
        
      
       String tempBody = wrapper.getBodySize();
       String tempLeads = wrapper.getBallLeadCount();
       String tempWire = ''; 
       String tempDie = '';
       

       try {
            if (wrapper.wireConfigurations == null || wrapper.wireConfigurations.size() == 0) {
                tempWire = 'No Wire';
            }
            else if (wrapper.wireConfigurations.size() == 1) {
                sObject wireObject = wrapper.wireConfigurations[0];
                String wireMaterial = String.valueOf(wireObject.get('Wire_Material__c'));
                String wireDiameter = String.valueOf(wireObject.get('Wire_Diameter__c'));
                tempWire = wireMaterial + '/' + wireDiameter;

                rfqItem.Primary_Wire_Diameter__c = DataUtils.getDecimal(wrapper.wireConfigurations[0],'Wire_Diameter__c',null);
                rfqItem.Primary_Wire_Material__c = DataUtils.getString(wrapper.wireConfigurations[0],'Wire_Material__c',null);
            }
            else {
                tempWire = 'Multiple';
                rfqItem.Primary_Wire_Diameter__c = DataUtils.getDecimal(wrapper.wireConfigurations[0],'Wire_Diameter__c',null);
                rfqItem.Primary_Wire_Material__c = DataUtils.getString(wrapper.wireConfigurations[0],'Wire_Material__c',null);
            }
            
       } catch (Exception e) {}

       try {
            if (StringUtils.isBlank(wrapper.packageFamily.Specific_Die_Configuration_Object__c)) {
                tempDie = 'N/A';
            }
            else if (wrapper.dieConfigurations == null || wrapper.dieConfigurations.size() == 0) {
                tempDie = '0';
            }
            else {
                tempDie = String.valueOf(wrapper.dieConfigurations.size());
            }
       } catch (Exception e) {}
        
       rfqItem.Leads__c = tempLeads;
       rfqItem.Wire_Type_And_Diameter__c = tempWire;
       rfqItem.Body_Size__c = tempBody;
       rfqItem.Dim_XY__c = tempBody + ' - ' + tempLeads;
       rfqItem.Dim_XY_Leads_Wires__c = rfqItem.Dim_XY__c + ' - ' + tempWire;
       rfqItem.Die_Information__c = tempDie;


    }
 
    public RFQItemWrapper cloneLineItem(RFQItemWrapper wrapper) {
        return cloneLineItem(wrapper, STATUS_NEW);
    }

    public RFQItemWrapper cloneLineItem(RFQItemWrapper wrapper, String itemStatus) {
        return cloneLineItem(wrapper, itemStatus, false);
    }

    public RFQItemWrapper cloneLineItem(RFQItemWrapper wrapper, String itemStatus, Boolean preserveOwner) {
        return cloneLineItem(wrapper, itemstatus, preserveOwner, null);
    }

    public RFQItemWrapper cloneLineItem(RFQItemWrapper wrapper, String itemStatus, Boolean preserveOwner, RFQILayout layout) {
        return cloneLineItem(wrapper, itemstatus, preserveOwner, layout, true);
    }
    public RFQItemWrapper cloneLineItem(RFQItemWrapper wrapper, String itemStatus, Boolean preserveOwner, RFQILayout layout, Boolean clearPrices) {
        return cloneLineItem(wrapper, itemstatus, preserveOwner, layout, clearPrices, true);
    }

    public RFQItemWrapper cloneLineItem(RFQItemWrapper wrapper, String itemStatus, Boolean preserveOwner, RFQILayout layout, Boolean clearPrices, Boolean clearPostTestPrices) {
        return cloneLineItems(wrapper, itemstatus, preserveOwner, layout, clearPrices, clearPostTestPrices, 1)[0];
    }
    public List<RFQItemWrapper> cloneLineItems(RFQItemWrapper wrapper, String itemStatus, Boolean preserveOwner, RFQILayout layout, Boolean clearPrices, Boolean clearPostTestPrices, Integer numClones) {
        List<RFQItemWrapper> cloneItems = createNewFromWrapper(wrapper, numClones);
        String roleName = '';
        try{
            if(preserveOwner) roleName = [SELECT UserRole.Name FROM User WHERE Id =: wrapper.rfqItem.ownerId].UserRole.Name;
            else roleName              = [SELECT UserRole.Name FROM User WHERE Id =: UserInfo.getUserId()].UserRole.Name;
        }
        catch(Exception e) {System.debug('Could not find role: ' + e);}
        
        for (RFQItemWrapper cloneItem : cloneItems)
        {

            cloneItem.rfqItem.Status__c = itemStatus;
            cloneItem.rfqItem.Creator_Role_Name__c = roleName;
            if(preserveOwner) {
                cloneItem.rfqItem.OwnerId = wrapper.rfqItem.ownerId;
            }
            else {
                cloneItem.rfqItem.OwnerId = UserInfo.getUserId();
            }
            //if added service link the
            if(wrapper.rfqItem.Service__c != 'Assembly') {
                cloneItem.rfqItem.Parent_RFQ_Item__c = wrapper.rfqItem.Parent_RFQ_Item__c;
            }
            cloneItem.rfqItem.Original_RFQ_Item__c = wrapper.rfqItem.Id;
            cloneItem.rfqItem.Layout_Version__c = wrapper.rfqItem.Layout_Version__c;
            //AMK-1631 hack due to need for field without an RFQI PF Field Def on edit page....
            //lamesauce..
            cloneItem.rfqItem.Consigned__c = wrapper.rfqItem.Consigned__c;
            cloneItem.rfqItem.Test_Package_Type__c = wrapper.rfqItem.Test_Package_Type__c;
            cloneItem.rfqItem.Multi_Volume__c = wrapper.rfqItem.Multi_Volume__c;
            cloneItem.rfqItem.NRE_Inclusion__c = wrapper.rfqItem.NRE_Inclusion__c;
            cloneItem.rfqItem.HVP_Anticipated_Start_Date__c = wrapper.rfqItem.HVP_Anticipated_Start_Date__c;
            cloneItem.rfqItem.SiP__c = wrapper.rfqItem.SiP__c;
            
            //Bhanu - 3-Feb-2016 : SALESFORCE-6 - 600705 - When cloning a RFQI the Customer Decision to buy date is not being populated
            //Added mapping for Decision to buy date field
            cloneItem.rfqItem.Decision_To_Buy__c = wrapper.rfqItem.Decision_To_Buy__c;
            
            //---Inflate here because saveLineItem writes to the Multi Volume field based on the inflated volumes
            cloneItem.inflateVolume();
            for (RFQIVolume vol : cloneItem.volumeList)
            {
                vol.createdRFQIId = null;
                vol.createdRFQIName = null;
            }
            copySobjectData(new List<sObject>{cloneItem.specificRfqItem}, 
                            new List<sObject>{wrapper.specificRfqItem}, 
                            cloneItem.getFieldsForObject(RFQItemWrapper.PACKAGE_OBJECT));

            copySobjectData(cloneItem.wireConfigurations, 
                            wrapper.wireConfigurations, 
                            cloneItem.getFieldsForObject(RFQItemWrapper.WIRE_OBJECT));

            copySobjectData(cloneItem.dieConfigurations, 
                            wrapper.dieConfigurations, 
                            cloneItem.getFieldsForObject(RFQItemWrapper.DIE_OBJECT));

            copySobjectData(cloneItem.passiveConfigurations, 
                            wrapper.passiveConfigurations, 
                            cloneItem.getFieldsForObject(RFQItemWrapper.PASSIVE_OBJECT));

            copySobjectData(cloneItem.insertionConfigurations, 
                            wrapper.insertionConfigurations, 
                            cloneItem.getFieldsForObject(RFQItemWrapper.INSERTION_OBJECT));

            copySobjectData(cloneItem.serviceConfigurations, 
                            wrapper.serviceConfigurations, 
                            cloneItem.getFieldsForObject(RFQItemWrapper.SERVICE_OBJECT));

            copySobjectData(cloneItem.nreConfigurations, 
                            wrapper.nreConfigurations, 
                            cloneItem.getFieldsForObject(RFQItemWrapper.NRE_OBJECT));

            if (layout != null) {
                cloneItem.clearCostAndPrice(layout);
            }
            if (clearPrices) cloneItem.clearPrices(clearPostTestPrices);

        }
        saveLineItems(cloneItems, true, false, false);

        List<String> itemIds = new List<String>();
        for (RFQItemWrapper cloneItem : cloneItems) itemIds.add(cloneItem.rfqItem.Id);
        return getWrappersByIds(itemIds);

    }

    public RFQItemWrapper createNewFromWrapper(RFQItemWrapper wrapper) {
        return createNewFromWrapper(wrapper, 1)[0];
    }
    public List<RFQItemWrapper> createNewFromWrapper(RFQItemWrapper wrapper, Integer numClones) {

        List<RFQItemWrapper> cloneItems = new List<RFQItemWrapper>();
        List<RFQ_Item__c> cloneBareItems = createCloneItems(wrapper.rfqItem.RFQ__c,
                                              wrapper.rfqItem.Opportunity__c, 
                                              wrapper.packageFamily,
                                              wrapper.rfqItem.Service__c, 
                                              wrapper.wireConfigurations == null ? 0 : wrapper.wireConfigurations.size(), 
                                              wrapper.dieConfigurations == null ? 0 : wrapper.dieConfigurations.size(), 
                                              wrapper.insertionConfigurations == null ? 0 : wrapper.insertionConfigurations.size(), 
                                              wrapper.passiveConfigurations == null ? 0 : wrapper.passiveConfigurations.size(),
                                              wrapper.serviceConfigurations == null ? 0 : wrapper.serviceConfigurations.size(),
                                              wrapper.nreConfigurations == null ? 0 : wrapper.nreConfigurations.size(), 
                                              wrapper.rfqItem.Layout_Version__c,
                                              numClones);


        List<String> itemIds = new List<String>();
        for (RFQ_Item__c rfqItem : cloneBareItems) itemIds.add(rfqItem.Id);
        return getWrappersByIds(itemIds);
    }

    private List<RFQ_Item__c> createCloneItems(String rfqId, String oppId,Package_Family__c pf, String service, Integer numberOfWires, Integer numberOfDie, Integer numberOfInsertions, Integer numberOfPassives, Integer numberOfServices, Integer numberOfNREs, Decimal layoutVersion, INteger numClones) {
        List<RFQ_Item__c> rfqItems = new List<RFQ_Item__c>();
        List<sObject> children = new List<sObject>();

        
        for (Integer i = 0; i < numClones; i++)
        {
            RFQ_Item__c rfqItem = new RFQ_Item__c();
            rfqItem.RFQ__c = rfqId;
            rfqItem.Opportunity__c = oppId;
            rfqItem.Service__c = service;
            rfqItem.Package_Family__c = pf.Id;
            rfqItem.Layout_Version__c = layoutVersion;
            rfqItems.add(rfqitem);

        }
        insert rfqItems;

        String objectType = pf.Specific_RFQ_Item_Object__c;
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectType);

        List<sObject> specificItems = new List<sObject>();
        sObject specificLineItem;
        List<sObject> statusObjects = new List<sObject>();
        List<sObject> nreObjects = new List<sObject>();
        for (RFQ_Item__c item : rfqItems)
        {
            specificLineItem = targetType.newSObject(); 
            specificLineItem.put('RFQ_Item__c',item.Id);
            specificItems.add(specificLineItem);

            List<sObject> tempNreObjects = createNREObject(pf,item.Id,numberOfNREs, false);
            if (tempNreObjects != null) nreObjects.addAll(tempNreObjects);

            //create status history object
            statusObjects.add(RFQIStatusHistoryDao.getInstance().newStatusHistory(item, false));

        }
        insert specificItems;
        List<sObject> wireObjects = new List<sObject>();
        List<sObject> dieObjects = new List<sObject>();
        List<sObject> insertionObjects = new List<sObject>();
        List<sObject> passiveObjects = new List<sObject>();
        List<sObject> serviceObjects = new List<sObject>();
        for (sObject lineItem : specificItems)
        {
            List<sObject> newObjects;
            newObjects = createWireObject(pf,lineItem.Id,numberOfWires, false);
            if (newObjects != null) wireObjects.addAll(newObjects);

            newObjects = createDieObject(pf,lineItem.Id,numberOfDie, false);
            if (newObjects != null) dieObjects.addAll(newObjects);

            newObjects = createInsertionObject(pf,lineItem.Id,numberOfInsertions, false);
            if (newObjects != null) insertionObjects.addAll(newObjects);

            newObjects = createPassiveObject(pf,lineItem.Id,numberOfPassives, false);
            if (newObjects != null) passiveObjects.addAll(newObjects);

            newObjects = createServiceObject(pf,lineItem.Id,numberOfServices, false);
            if (newObjects != null) serviceObjects.addAll(newObjects);
        }

        if (!statusObjects.isEmpty()) children.addAll(statusObjects);
        if (!nreObjects.isEmpty()) children.addAll(nreObjects);
        if (!wireObjects.isEmpty()) children.addAll(wireObjects);
        if (!dieObjects.isEmpty()) children.addAll(dieObjects);
        if (!insertionObjects.isEmpty()) children.addAll(insertionObjects);
        if (!passiveObjects.isEmpty()) children.addAll(passiveObjects);
        if (!serviceObjects.isEmpty()) children.addAll(serviceObjects);

        insert children;


        return rfqItems;
    }

    private void copySobjectData(List<sObject> target, List<sObject> source, Set<String> fields) {
        for(Integer i = 0; i < target.size(); i++) {

            for(String field : fields) {
                try {
                    if(field != 'Parent__c' && field != 'Id') { 
                        target[i].put(field,source[i].get(field));
                    }
                }
                catch(Exception e){}
            }
        }
    }

    public RFQItemWrapper getSmallWrapperById(String rfqItemId, String driverObj, String childObj, String packageFamilyId) {
        Package_Family__c packageFamily = PackageFamilyDao.getInstance().getById(packageFamilyId);
        Product_Group__c productGroup = null;
        BaseDao specificItemDao = new BaseDao(packageFamily.Specific_RFQ_Item_Object__c);
        sObject specificRfqItem = specificItemDao.getSObjects('RFQ_Item__c = ' + BaseDao.quote(rfqItemId))[0];
        RFQ_Item__c rfqItem = null;
        List<sObject> wireConfigurations = new List<sObject>();
        List<sObject> dieConfigurations = new List<sObject>();
        List<sObject> passiveConfigurations = new List<sObject>();
        List<sObject> insertionConfigurations = new List<sObject>();
        List<sObject> serviceConfigurations = new List<sObject>();
        List<RFQI_Status_History__c> statusHistories = new List<RFQI_Status_History__c>();
        List<sObject> nreConfigurations = new List<sObject>();

        if(driverObj == RFQItemWrapper.WIRE_OBJECT || childObj == RFQItemWrapper.WIRE_OBJECT) {
            if(packageFamily.Specific_Wire_Configuration_Object__c != null) {
                BaseDao wireDao = new BaseDao(packageFamily.Specific_Wire_Configuration_Object__c);
                wireConfigurations = wireDao.getSObjects('Parent__c = ' + BaseDao.quote(specificRfqItem.Id), 'CreatedDate ASC');
            }
        }
              
        if(driverObj == RFQItemWrapper.DIE_OBJECT || childObj == RFQItemWrapper.DIE_OBJECT) {   
            if(packageFamily.Specific_Die_Configuration_Object__c != null) {
                BaseDao dieDao = new BaseDao(packageFamily.Specific_Die_Configuration_Object__c);
                dieConfigurations = dieDao.getSObjects('Parent__c = ' + BaseDao.quote(specificRfqItem.Id), 'CreatedDate ASC');  
            }
        }
            
        if(driverObj == RFQItemWrapper.PASSIVE_OBJECT || childObj == RFQItemWrapper.PASSIVE_OBJECT) {       
            if(packageFamily.Specific_Passive_Configuration_Object__c != null) {
               BaseDao passiveDao = new BaseDao(packageFamily.Specific_Passive_Configuration_Object__c);
               passiveConfigurations = passiveDao.getSObjects('Parent__c = ' + BaseDao.quote(specificRfqItem.Id), 'CreatedDate ASC');
            }
        }
        
        if(driverObj == RFQItemWrapper.INSERTION_OBJECT || childObj == RFQItemWrapper.INSERTION_OBJECT) { 
            if(packageFamily.Specific_Insertion_Configuration_Object__c != null) {
                BaseDao insertionDao = new BaseDao(packageFamily.Specific_Insertion_Configuration_Object__c);
                insertionConfigurations = insertionDao.getSObjects('Parent__c = ' + BaseDao.quote(specificRfqItem.Id), 'CreatedDate ASC'); 
            }
        }

        if(driverObj == RFQItemWrapper.SERVICE_OBJECT || childObj == RFQItemWrapper.SERVICE_OBJECT) {   
            if(packageFamily.Specific_Service_Configuration_Object__c != null) {
                BaseDao serviceDao = new BaseDao(packageFamily.Specific_Service_Configuration_Object__c);
                serviceConfigurations = serviceDao.getSObjects('Parent__c = ' + BaseDao.quote(specificRfqItem.Id), 'CreatedDate ASC');
                system.debug('serviceConfigurations'+serviceConfigurations);
            } 
        }  

        return new RFQItemWrapper(rfqItem,specificRfqItem,wireConfigurations,dieConfigurations,passiveConfigurations,insertionConfigurations,serviceConfigurations,packageFamily,productGroup,statusHistories, nreConfigurations);

    }
    
    public RFQItemWrapper getWrapperById(String rfqItemId) {
        return getWrappersByIds(new List<String>{rfqItemId})[0];
    }

    /**
    * This method returns a list of wrappers
    * IMPORTANT - all the items must have the same package family 
    * Used for when an item is cloned multiple times
    *
    * @param mesg a String containing your message
    */
    public List<RFQItemWrapper> getWrappersByIds(List<String> rfqItemIds) {
        Map<String,Set<String>> fieldMap = new Map<String,Set<String>>();
        
        //added fields to allow removal of layout from wrapper
        addFields(new Set<String>{'RFQ__r.Name', 'Configured_Part_Number__r.Name', 'RFQ__r.SBU_Name__r.Sales_Region__c', 'Parent_RFQ_Item__r.Status__c', 'Owner.Name'});
        
        List<RFQ_Item__c> rfqItems = getSObjectByIdSet('Id', new Set<String>(rfqItemIds));
        system.debug('RFQItemDao line number 1455 rfqItems : '+rfqItems);
        fieldMap.put('ITEM',getFields());
        
        PackageFamilyDao packageDao = PackageFamilyDao.getInstance();  
        //since there are a crap ton of these now, it makes sense for us to just grab
        //the whole product group, using the relationship fields from package family is now
        //considered deprecated
        packageDao.addFields(productGroupFields);
       
        Package_Family__c packageFamily= packageDao.getById(rfqItems[0].Package_Family__c);
        Product_Group__c productGroup = ProductGroupDao.getInstance().getById(packageFamily.Product_Group__c);
        BaseDao specificItemDao = new BaseDao(packageFamily.Specific_RFQ_Item_Object__c);
        fieldMap.put(RFQItemWrapper.PACKAGE_OBJECT,specificItemDao.getFields());

        specificItemDao.addFields(new Set<String>{'RFQ_Item__r.Status__c', 'RFQ_Item__r.Service__c', 'RFQ_Item__r.Customer_Tier__c', 
                                    'RFQ_Item__r.RFQ__r.RFQ_Name__c', 'RFQ_Item__r.RFQ__r.SBU_Name__r.AccountNumber', 'RFQ_Item__r.RFQ__r.SBU_Name__r.Customer_AU_Base_fml__c', 
                                    'RFQ_Item__r.Package_Family__r.Name', 'RFQ_Item__r.RFQ__r.SBU_Name__c', 'RFQ_Item__r.RFQ__c', 'RFQ_Item__r.OwnerId', 'RFQ_Item__r.CreatedById', 'RFQ_Item__r.Inactive__c', 'RFQ_Item__r.RFQ__r.SBU_Name__r.Name',
                                    'RFQ_Item__r.RFQ__r.SBU_Name__r.Gold_Billing_Flag__c', 'RFQ_Item__r.Package_Family__r.Product_Group__r.Au_Cost__c', 'RFQ_Item__r.HVP_Anticipated_Start_Date__c', 'RFQ_Item__r.Gold_Billing_Flag__c', 'RFQ_Item__r.SiP__c'});

        if(specificItemDao.hasField('Factory__c')){
            specificItemDao.addSingleField('Factory__r.Name');
            //Ashish 14-June-2017 : Salesforce 116 - Add Amkor Preferred picklist value under Factory for RFQI.
            //Added Single Field BU Factory to the Specific RFQ Item.
            specificItemDao.addSingleField('BU_Factory__r.Name');
            specificItemDao.addSingleField('RFQ_Item__r.Final_Factory__c');
            
            //specificItemDao.addFields(new Set<String>{'Factory__c','BU_Factory__r.Name'});   
        }
        List<sObject> specificRfqItems = specificItemDao.getSObjectByIdSet('RFQ_Item__c', new Set<String>(rfqItemIds));
        Set<String> specificRfqItemIds = new Set<String>();
        
        for (sObject specificRfqItem : specificRfqItems) 
            specificRfqItemIds.add(specificRfqItem.Id);

        
        //grab the wire configuration object(s) for this package families particular object
        List<sObject> wireConfigurations = new List<sObject>();

        if(packageFamily.Specific_Wire_Configuration_Object__c != null) {
            BaseDao wireDao = new BaseDao(packageFamily.Specific_Wire_Configuration_Object__c);
            wireConfigurations = wireDao.getSObjectByIdSet('Parent__c', specificRfqItemIds, null, 'CreatedDate ASC');
            fieldMap.put(RFQItemWrapper.WIRE_OBJECT,wireDao.getFields());
    
        }
        
        //grab the wire configuration object(s) for this package families particular object
        List<sObject> dieConfigurations = new List<sObject>();
        if(packageFamily.Specific_Die_Configuration_Object__c != null) {
            BaseDao dieDao = new BaseDao(packageFamily.Specific_Die_Configuration_Object__c);
            dieConfigurations = dieDao.getSObjectByIdSet('Parent__c', specificRfqItemIds, null, 'CreatedDate ASC');  
            fieldMap.put(RFQItemWrapper.DIE_OBJECT,dieDao.getFields());  
        }
        
        List<sObject> passiveConfigurations = new List<sObject>();
        if(packageFamily.Specific_Passive_Configuration_Object__c != null) {
           BaseDao passiveDao = new BaseDao(packageFamily.Specific_Passive_Configuration_Object__c);
           passiveConfigurations = passiveDao.getSObjectByIdSet('Parent__c', specificRfqItemIds, null, 'CreatedDate ASC');
            fieldMap.put(RFQItemWrapper.PASSIVE_OBJECT,passiveDao.getFields());      
        }
       
        List<sObject> insertionConfigurations = new List<sObject>();
        if(packageFamily.Specific_Insertion_Configuration_Object__c != null) {
            BaseDao insertionDao = new BaseDao(packageFamily.Specific_Insertion_Configuration_Object__c);
            insertionConfigurations = insertionDao.getSObjectByIdSet('Parent__c', specificRfqItemIds, null, 'CreatedDate ASC');
            fieldMap.put(RFQItemWrapper.INSERTION_OBJECT,insertionDao.getFields());      
    
        }

        List<sObject> serviceConfigurations = new List<sObject>();
        if(packageFamily.Specific_Service_Configuration_Object__c != null) {
            BaseDao serviceDao = new BaseDao(packageFamily.Specific_Service_Configuration_Object__c);
            serviceConfigurations = serviceDao.getSObjectByIdSet('Parent__c', specificRfqItemIds, null, 'CreatedDate ASC');
            fieldMap.put(RFQItemWrapper.SERVICE_OBJECT,serviceDao.getFields());      
    
        }

        List<sObject> nreConfigurations = new List<sObject>();
        BaseDao nreDao = new BaseDao('RFQI_NRE__c');
        nreConfigurations = nreDao.getSObjectByIdSet('Parent__c', new Set<String>(rfqItemIds), null, 'CreatedDate ASC');
        fieldMap.put(RFQItemWrapper.NRE_OBJECT,nreDao.getFields());

        List<RFQI_Status_History__c> statusHistories = RFQIStatusHistoryDao.getInstance().getByRfqItemIds(new Set<String>(rfqItemIds)); 
        Map<String, sObject> specificRfqItemMap = new Map<String, sObject>();
        for (sObject specItem : specificRfqItems) specificRfqItemMap.put((String)specItem.get('RFQ_Item__c'), specItem);
        Map<String, List<sObject>> wireConfigurationMap = buildChildMap(specificRfqItemIds, wireConfigurations, 'Parent__c');
        Map<String, List<sObject>> dieConfigurationMap = buildChildMap(specificRfqItemIds, dieConfigurations, 'Parent__c');
        Map<String, List<sObject>> passiveConfigurationMap = buildChildMap(specificRfqItemIds, passiveConfigurations, 'Parent__c');
        Map<String, List<sObject>> insertionConfigurationMap = buildChildMap(specificRfqItemIds, insertionConfigurations, 'Parent__c');
        Map<String, List<sObject>> serviceConfigurationMap = buildChildMap(specificRfqItemIds, serviceConfigurations, 'Parent__c');
        Map<String, List<sObject>> nreConfigurationMap = buildChildMap(new Set<String>(rfqItemIds), nreConfigurations, 'Parent__c');
        Map<String, List<sObject>> statusHistoryMap = buildChildMap(new Set<String>(rfqItemIds), statusHistories, 'RFQ_Item__c');

        List<RFQItemWrapper> wrappers = new List<RFQItemWrapper>();
        for (RFQ_Item__c rfqItem : rfqItems)
        {
            system.debug('RFQItemDao rfqitem inside the for loop  : '+rfqitem);
            sObject specificRfqItem = specificRfqItemMap.get(rfqItem.Id);

            RFQItemWrapper wrapper = new RFQItemWrapper(rfqItem,
                                        specificRfqItem,
                                        wireConfigurationMap.get(specificRfqItem.Id),
                                        dieConfigurationMap.get(specificRfqItem.Id),
                                        passiveConfigurationMap.get(specificRfqItem.Id),
                                        insertionConfigurationMap.get(specificRfqItem.Id),
                                        serviceConfigurationMap.get(specificRfqItem.Id),
                                        packageFamily,
                                        productGroup,
                                        statusHistoryMap.get(rfqItem.Id),
                                        nreConfigurationMap.get(rfqItem.Id));
            System.debug('RFQItemDao wrapper :  '+wrapper);                            
            wrapper.setFieldMap(fieldMap);
            system.debug('calling the inflateVolume method of the wrapper class in escalation mode');
            wrapper.inflateVolume();
            wrapper.indexConfigurations();
            wrappers.add(wrapper);
            system.debug('--->getWrappersByIds(), line no 1632, queries limit :  '+Limits.getQueries());
        }

        return wrappers;  
    }

    //Note: this method was causing Internal Server Errors when either the child objects did not have the parentKey as
    //a field, or when the wrong set of Ids was passed in - be careful
    private Map<String, List<sObject>> buildChildMap(Set<String> parentIds, List<sObject> children, String parentKey)
    {
        Map<String, List<sObject>> childMap = new Map<String, List<sObject>>();
        for (String parentId : parentIds) childMap.put(parentId, new List<sObject>());

        String parentId;
        for (sObject child : children)
        {
            parentId = String.valueOf(child.get(parentKey));
            childMap.get(parentId).add(child);
        }

        return childMap;
    }


    public static List<sObject> getSpecificItems(String objectName, Set<Id> rfqItemIds, Boolean useParent) {
        BaseDao itemDao = new BaseDao(objectName);

        String idString = '';
        for (Id objId : rfqItemIds) {
            if (idString.length() > 0) idString += ',';
            idString += BaseDao.quote(objId);
        }

        String sql = '';

        if (useParent) {
            itemDao.addSingleField('Parent__r.RFQ_Item__c');
            sql = 'Parent__r.RFQ_Item__c in (' + idString + ')';
        }
        else {
            sql = 'RFQ_Item__c in (' + idString + ')';
        }
        

        System.debug(LoggingLevel.ERROR, '### SQL: ' + sql);

        List<sObject> items = itemDao.getSObjects(sql);
        System.debug('items'+items);

        return items;
    }
    
    public Boolean deleteLineItem(RFQItemWrapper item) {

        try{
            RFQ_Item__c thisItem = item.rfqItem;
            thisItem.Inactive__c = true;
            thisItem.RFQ__c = null;
            //Lalit - 09-Mar-2017 : Salesforce-188 : Die Processing rfqi cancel button is not working
            //Commented the updation of the Rfq item which we care going to delete because of that trigger will fire and anyhow we need to delete the rfq item.
            //update thisItem;
            //deleting the lineitems in the below line.
            if(thisItem != null) delete thisItem;
            return true; 
            
        }catch(Exception ex){
            return false;
        }

            
    }

    public Boolean statusGreaterOrEqual(RFQ_Item__c item, String itemStatusName) {
        system.debug('SF-199 item '+item.status__c);
        system.debug('value of status  '+STATUS_PRICE_COMPLETE);

        Integer itemStatus = statusMap.get(item.Status__c);
        Integer compareStatus = statusMap.get(itemStatusName);
        system.debug('Line 1708 itemStatus : '+itemStatus+'</n>'+'compareStatus : '+compareStatus);
        system.debug(itemStatus >= compareStatus);
        return itemStatus >= compareStatus; 
    }
     
    public Boolean statusGreaterOrEqual(String status1, String status2) {
        Integer itemStatus = statusMap.get(status1);
        Integer compareStatus = statusMap.get(status2);
        return itemStatus >= compareStatus; 
    }
    
    public Boolean statusLessOrEqual(RFQ_Item__c item, String itemStatusName) {
        Integer itemStatus = statusMap.get(item.Status__c);
        Integer compareStatus = statusMap.get(itemStatusName);
        return itemStatus <= compareStatus; 
    }
    public Boolean statusLessOrEqual(String status1, String status2) {
        Integer itemStatus = statusMap.get(status1);
        Integer compareStatus = statusMap.get(status2);
        return itemStatus <= compareStatus; 
    }

    public Boolean statusEqual(String status1, String status2) {
        Integer itemStatus = statusMap.get(status1);
        Integer compareStatus = statusMap.get(status2);
        return itemStatus == compareStatus; 
    }
    
    //---Special method to lookp the Account (SBU Name) by item Id
    public String getAccountIdFromItemId(String itemId) {
    List<RFQ_Item__c> itemList = [Select id, RFQ__r.SBU_Name__c from RFQ_Item__c where id = :itemId];   
    return itemList == null || itemList.size() == 0 ? null : itemList[0].RFQ__r.SBU_Name__c;
    }

    /**
    * This method updates a supplied list of RFQ Items and sets their status to 'Quoted'
    *
    * @param selectedItemList the list of RFQ Items to update
    */
    public void setItemsQuoted(List<RFQ_Item__c> selectedItemList) {
        for (RFQ_Item__c item : selectedItemList) {
            if(!statusGreaterOrEqual(item, STATUS_QUOTED)) {
                item.Status__c = STATUS_QUOTED;
            }
        }
        
        update selectedItemList;
    }

    
    public RFQ_Item__c getHighestStatusItem(List<RFQ_Item__c> rfqItems) {
        RFQ_Item__c highestStatus = null;
        if(rfqItems != null) {
            for (RFQ_Item__c item : rfqItems) {
                if (highestStatus == null || statusGreaterOrEqual(item, highestStatus.Status__c)) {
                    highestStatus = item;
                }    
            }
        }
        system.debug('highestStatus '+highestStatus);
        return highestStatus;
    }
    

    public Map<String, List<String>> getSuperUserEmails(List<RFQ_Item__c> items)
    {   
        //Bhanu - 04-May-2016 :Salesforce 10 :  Update the Test Super User Price complete email
        //replacing Hardcoded roleRegionMap with CustomSetting as requested by Adam
        /*
        Map<String, TestSuperUsers__c> testSuperUsersmap = TestSuperUsers__c.getAll();
        if(testSuperUsersmap != null){
            for(TestSuperUsers__c t : testSuperUsersmap.values()){
                roleRegionMap.put(t.Region__c, t.Role__c);
            }
        }
        
        System.debug('--->roleRegionMap formed with Custom Setting : '+roleRegionMap);
        */
                    
        Map<String, List<String>> retVals = new Map<String, List<String>>();

        User markBerry;
        Map<String, List<String>> userMap = new Map<String, List<String>>();
        //List<String> tempList;
        
        //Ashish - 10-April-2017 : Salesforce-207 : Update Mark Berry Price Complete notifications to include Europe
        //replaced userlist variable with SOQL below && captured Mark Berry's user in a variable
        //put business logic to add value to a map in a new method in DataUtils class & called it
        for (User u : [SELECT Id, FirstName, LastName, Email, UserRole.Name FROM User where UserRole.Name in :roleRegionMap.values()])
        {
            
            If(u.FirstName.equalsIgnoreCase('Mark') && u.LastName.equalsIgnoreCase('Berry')){
                markBerry = u;
            }
            DataUtils.addStringKeyValueToMap(u.UserRole.Name, u.Email, userMap);
            
        }
        
        //Ashish - 10-April-2017 : Salesforce-207 : Update Mark Berry Price Complete notifications to include Europe
        //called new method to add mark berry for Europe role
        addExceptionToSuperUser('EUROPE TEST SALES SUPER USER', markBerry, userMap);
        
        
        String region;
        String salesRegion;
        for (RFQ_Item__c item : items)
        {
            salesRegion = item.RFQ__r.SBU_Name__r.Sales_Region__c;
            
            system.debug('Salesregion value  : '+salesRegion);
            if(salesRegion != null && salesRegion != ''){
                region = roleRegionMap.get(salesRegion.toUpperCase());
                system.debug('value of region  : '+region);
                retVals.put(item.Id, userMap.get(region));
                system.debug('value of the retvals map : '+retVals);
            }
        }

        return retVals;
    }
    
    //Ashish - 10-April-2017 : Salesforce-207 : Update Mark Berry Price Complete notifications to include Europe
    //new method to add exceptions to the standard role region mapping for TestSuperUsers
    public void addExceptionToSuperUser(String region, User userRecord, Map<String, List<String>> userMap) {
        if(String.isNotBlank(region) && userRecord != null) {
            DataUtils.addStringKeyValueToMap(region, userRecord.Email, userMap);
        }
    }

    public List<RFQ_Item__c> getByVolumeParent(String rfqitemId)
    {
        return (List<RFQ_Item__c>)getSObjects('Parent_Volume_Item__c = ' + quote(rfqitemId), 'Volume_Index__c');
    }

    public List<RFQ_Item__c> getByParentItem(String rfqItemId)
    {
        //check for parent_volume_item being empty because
        //one iteration of volume clone page will create a service
        //then next instance will try to clone that new service
        return (List<RFQ_Item__c>)getSObjects('Parent_RFQ_Item__c = ' + quote(rfqItemId) + ' AND Parent_Volume_Item__c = \'\' AND Status__c = ' + quote(STATUS_PENDING_ASSEMBLY_APPROVAL), 'Name ASC');
    }
    
    public class RFQIOpportunityStatusMismatchException extends Exception {}

}