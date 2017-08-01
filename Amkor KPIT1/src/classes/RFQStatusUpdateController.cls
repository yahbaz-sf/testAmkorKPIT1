public with sharing class RFQStatusUpdateController extends BaseController{

    public List<RFQ_Item__c> rfqitems {get; set;}
    public List<StatusWrapper> statusWrappers {get;set;}

    public Integer startRange {get;set;}
    public Integer endRange {get;set;}
    public String sortedColumn {get;set;}
    public Boolean sortedASC {get;set;}
    //public List<String> alphabets {get{return new List<String>{'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','Other', 'All'}; } }
    public Map<String, String> columnFieldNames = new Map<String, String>{'SBU Name' => 'RFQ__r.SBU_Name_fml__c', 'Package Family' => 'Package_Family_Name__c', 'Project Device' => 'Project_Device__c', 'Status' => 'Status__c', 'Account Owner' => 'RFQ__r.SBU_Name__r.Owner.Name', 'RFQ' => 'RFQ__r.Name', 'Customer Decision to Buy Date' => 'Decision_To_Buy__c'};
    public List<SortCriteria> sortCrit {get;set;}
    public String query {get;set;}
    public String countQuery {get;set;}
    public String searchWhereClaus {get;set;}

    public String tempQuery {get;set;}
    public String tempCountQuery {get;set;}
    public String statusFilter {get;set;}
    public Integer currentCount {get;set;}
    
    ////Bhanu - 01-July-2016 : Salesforce 69
    //Updating RFQI Status In below list variable
    /* public static final List<String> statusesIWant = new List<String>{ RFQItemDao.STATUS_PRICE_COMPLETE, RFQItemDao.STATUS_QUOTED,RFQItemDao.STATUS_WON_PROTOTYPE, RFQItemDao.STATUS_WON_QUALIFICATION, RFQItemDao.STATUS_PROGRAM_WIN, RFQItemDao.STATUS_PROGRAM_LOSS, RFQItemDao.STATUS_PROGRAM_CANCELED}; */
    
    public static final List<String> statusesIWant = new List<String>{ RFQItemDao.STATUS_PRICE_COMPLETE, RFQItemDao.STATUS_QUOTED,RFQItemDao.STATUS_Qual, RFQItemDao.STATUS_PROGRAM_WIN, RFQItemDao.STATUS_PROGRAM_LOSS, RFQItemDao.STATUS_PROGRAM_CANCELED};

    public List<SelectOption> selectedStatuss {get; private set;} // This is set by the Multi Select Pick List as select options.

    public static Integer QUERY_SIZE = 30;
    public static Integer MAX_OFFSET = 2000;
    public Integer pageNumber { get; set; }

    public RFQStatusUpdateController() {
        selectedStatuss = new List<SelectOption>();
        //Check RFQ__r.Name != null because RFQ_item__c is public read/write, so no sharing exists on it
        //There is sharing on the RFQ though, so checking rfq__r.name will ensure that the user only
        //gets rfq items related to rfq's they can see
        rfqitems = new List<RFQ_Item__c>();
        resetCriteria();
        query = 'select Id, Name, Package_Family__c, RFQ__c, Package_Family_Name__c, Project_Device__c, HVP_Anticipated_Start_Date__c, Decision_To_Buy__c, Quoted_Status__c, Dim_XY_Leads_Wires__c, Forecast__c, Price_To_Customer__c, Status__c, StatusReason__c, Status_Comments__c, RFQ__r.SBU_Name__c, RFQ__r.Name, RFQ__r.SBU_Name_fml__c, RFQ__r.SBU_Name__r.OwnerId, RFQ__r.SBU_Name__r.Owner.Name from RFQ_Item__c where RFQ__r.Name != null';
        countQuery = 'select count() from RFQ_Item__c where RFQ__r.Name != null';
        sortedASC = true;
        sortedColumn = 'SBU Name';
    }

    public PageReference resetCriteria() {
        selectedStatuss.clear();
        startRange = 0;
        endRange = startRange + QUERY_SIZE;
        pageNumber=0;
        currentCount = 0;
        List<String> colNames = new List<String>{'SBU Name', 'Package Family', 'Project Device', 'Status', 'Customer Decision to Buy Date', 'Account Owner'};

        tempQuery = '';
        tempCountQuery = '';
        searchWhereClaus = '';
        sortCrit = new List<SortCriteria>();
        for(String s : colNames) {
            if(s == 'Status') {
                sortCrit.add(new SortCriteria(s, null, 'multiselectpicklist'));
            }
            else if (s == 'Package Family' || s == 'Customer Decision to Buy Date') {
                sortCrit.add(new SortCriteria(s, null, 'picklist'));
            }
            else { 
                sortCrit.add(new SortCriteria(s, null, 'input'));
            }
        }
        rfqitems = new List<RFQ_Item__c>();
        statusWrappers = new List<StatusWrapper>();
        return null;
    }

    public PageReference searchItems() {
        searchWhereClaus = '';
        List<SortCriteria> selectedCriteria = new List<SortCriteria>();
        for(SortCriteria sc : sortCrit) {
            if(sc.selected) selectedCriteria.add(sc);
        }
        if(selectedCriteria.size() > 0) {
            Boolean shouldQuery = true;
            Boolean filterOnStatus = false;
            tempQuery = query;
            rfqitems = new List<RFQ_Item__c>();
            for(SortCriteria s : selectedCriteria) {
                if(s.filterType == 'Input') {
                    if(String.isBlank(s.filterCriteria)) {
                        addError('Please enter at least one character for ' + s.column);
                        shouldQuery = false;
                        break;
                    }
                    else searchWhereClaus += ' AND ' + columnFieldNames.get(s.column) + ' Like ' + '\'' + s.filterCriteria+ '%\'';
                }
                else if (s.filterType == 'multiselectpicklist') {
                    filterOnStatus = true;
                    if (selectedStatuss.size() > 0)
                    {
                        List<string> statussQuoted = new List<string>();
                        for (SelectOption item : selectedStatuss) { 
                             statussQuoted.add(BaseDao.quote(item.getValue()));
                        }
                        searchWhereClaus += ' AND ' + columnFieldNames.get(s.column) + ' IN (';
                        searchWhereClaus += String.join(statussQuoted, ',');
                        searchWhereClaus += ')';
                    }
                }
                else if (s.column != 'Customer Decision to Buy Date') {
                     searchWhereClaus += ' AND ' + columnFieldNames.get(s.column) + ' = ' + '\'' + s.filterCriteria + '\'';
                }
                else {
                    if(s.filterCriteria == null || s.qYear == null) addError('Please select a quarter and year for Customer Decision to Buy Date');
                    else searchWhereClaus += ' AND CALENDAR_YEAR(' + columnFieldNames.get(s.column) + ') = ' + s.qYear + ' AND CALENDAR_QUARTER(' + columnFieldNames.get(s.column) + ') = ' + s.filterCriteria.substring(1, 2);
                }
            }
            if (!filterOnStatus) {
                // Do the filter on all statuss we care about for this page
                searchWhereClaus += ' AND Status__c in: statusesIWant';
            }
            
            if(shouldQuery) {
                tempQuery = query + searchWhereClaus;
                tempCountQuery = countQuery + searchWhereClaus;
                selectRFQItems();
            }
        }
        else {
            addError('Please select at least one search criteria');
        }
        return null;
    }

    private void setupWrappers(Integer bottomRange) {
        Integer topRange = bottomRange + QUERY_SIZE;
        if(topRange > rfqitems.size()) topRange = rfqitems.size();
        
        statusWrappers = new List<StatusWrapper>();
        for(Integer i = bottomRange; i < topRange; i++) {
            statusWrappers.add(new StatusWrapper(rfqitems[i]));  
        }
    }

    private void displayCurrentCount() {
        addInfo('Displaying ' + String.valueOf((startRange+1)) + '-' + String.valueOf(endRange) + ' of ' + currentCount + ' RFQ Items');
        if (currentCount == 0) {
            addInfo('    No Items to Display.');
        }
    }

    private void selectRFQItems() {
        String order = (sortedASC) ? 'ASC' : 'DESC';
        
        DebugUtils.write('tempCountQuery', tempCountQuery);

        Integer oldCount = currentCount;        
        // Get the current count of all matching items.
        currentCount = Database.countQuery(tempCountQuery);

        if (oldCount != 0 && oldCount != currentCount) {
            // reset to the first page if the query results have changed
            pageNumber = 0;
        }

        tempQuery += ' Order by ' + columnFieldNames.get(sortedColumn) + ' ' + order;
        if (order == 'DESC')
            tempQuery += ' NULLS LAST ';

        Integer offset = QUERY_SIZE * pageNumber;
        if (offset > MAX_OFFSET) {
            addError('Maximum Offset of 2000 was reached, please reduce filter footprint to view all items.');
            offset = MAX_OFFSET;
        }

        tempQuery += ' LIMIT ' + QUERY_SIZE + ' OFFSET ' + offset;

        DebugUtils.write('tempQuery', tempQuery);

        rfqitems = Database.query(tempQuery);
		
		//Abhay 8-March-17 SF-118 :Sales ability to update RFQI Status from Cancel to Win/Loss
		/*Blanking the Quoted Status of the RFQ Item so that it always defaults to none */
		for(RFQ_Item__c item:rfqitems){
			item.Quoted_Status__c ='';
		}

        startRange = offset;
        endRange = startRange + QUERY_SIZE;
        if (endRange > currentCount)
            endRange = currentCount;

        setupWrappers(0);
        displayCurrentCount();
    }

    public PageReference firstPage() {
        if (startRange <= QUERY_SIZE) {
            addError('Displaying first page already');
            displayCurrentCount();
            return null;
        }
        pageNumber = 0;
        searchItems();
        return null;
    }

    public PageReference nextPage() {
        if (endRange >= currentCount) {
            addError('Displaying last page already');
            displayCurrentCount();
            return null;
        }
        if ((pageNumber+1 * QUERY_SIZE) > MAX_OFFSET)
            pageNumber = MAX_OFFSET/QUERY_SIZE;
        else
            pageNumber++;

        searchItems();
        return null;
    }

    public PageReference lastPage() {
        if (currentCount > MAX_OFFSET)
            pageNumber = MAX_OFFSET/QUERY_SIZE;
        else
            pageNumber = currentCount/QUERY_SIZE;
        searchItems();
        return null;
    }

    public PageReference previousPage() {
        if (pageNumber == 0) {
            addError('Displaying first page already');
            displayCurrentCount();
            return null;
        }
        if ((pageNumber * QUERY_SIZE) > MAX_OFFSET)
            pageNumber = MAX_OFFSET/QUERY_SIZE;
        else
            pageNumber--;
        
        searchItems();
        return null;
    }

    public PageReference savePage() {
        Boolean noUpdate = false;

        for(StatusWrapper wrapper : statusWrappers) {
            if(wrapper.rfqItem.Quoted_Status__c != null){
                if(wrapper.rfqItem.Quoted_Status__c == RFQItemDao.STATUS_PROGRAM_LOSS) {
                    if(wrapper.rfqItem.StatusReason__c == null) {
                        addError('Please specify a reason for: ' + wrapper.rfqItem.Name);
                        noUpdate = true;
                    }
                }
                if(wrapper.rfqItem.StatusReason__c == 'Other' || wrapper.rfqItem.StatusReason__c == 'Multi-service quote non competitive') {
                    if(wrapper.rfqItem.Status_Comments__c == null) {
                        addError('Please specify a comment for: ' + wrapper.rfqItem.Name);
                        noUpdate = true;
                    }
                }
            }
        }

        if(!noUpdate) {
            List<RFQ_Item__c> rfqItemsToUpdate = new List<sObject>();

            for(Integer i = 0; i < statusWrappers.size(); i++) {
                if(statusWrappers[i].rfqItem.Quoted_Status__c != null) {
                    statusWrappers[i].rfqItem.Status__c = statusWrappers[i].rfqItem.Quoted_Status__c;
					//Abhay 8-March-17 SF-118 :Sales ability to update RFQI Status from Cancel to Win/Loss
					/*Blanking the Quoted Status of the RFQ Item so that it always defaults to none */
					statusWrappers[i].rfqItem.Quoted_Status__c = '';
                }
                rfqItemsToUpdate.add(statusWrappers[i].rfqItem);
            }
            update rfqItemsToUpdate;
            addInfo('Save complete');
            displayCurrentCount();
            return null;
        }
        else {
            displayCurrentCount();
            return null;
        }
    }

    public PageReference sortColumn() {
        if(!StringUtils.isBlank(tempQuery)) {
            String columnName = getParam('columnName');
            if(sortedColumn == columnName) {
                sortedASC = !sortedASC;
            }
            else {
                sortedColumn = columnName;
                sortedASC = true;
            }
            tempQuery = query + searchWhereClaus;
            tempCountQuery = countQuery + searchWhereClaus;
            selectRFQItems();
        }
        else addError('Please select at least one search criteria');
        return null;
    }

    public SelectOption[] GetLeftOptions(){
        List<SelectOption> leftOptions = new List<SelectOption>();
        for (String status : statusesIWant) {
            Boolean containedInSelected = false;
            for (SelectOption option : selectedStatuss) { 
                 if (option.getValue() == status) {
                    containedInSelected = true;
                    break;
                 }
            }
            if (!containedInSelected) {
                leftOptions.add(new SelectOption(status, status));
            }
        }
        return leftOptions;
    }

    public class StatusWrapper implements Comparable{
        public RFQ_Item__c rfqItem {get;set;}
        public String sbuName {get;set;}
        public String rfqName {get;set;}
        public String deviceName {get;set;}
        public String status {get;set;}
        public String lastModString {get;set;} 
        public String newStatus {get;set;}

        public StatusWrapper(RFQ_Item__c item) {
            rfqItem = item;

            String rfqItemId = item.Id;
            //specificItem = Database.query('Select Id, HVP_Anticipated_Start_Date__c from ' + item.Package_Family__r.Specific_RFQ_Item_Object__c + ' WHERE RFQ_Item__c =: rfqItemId');
            sbuName = item.RFQ__r.SBU_Name_fml__c.toLowercase();          
            rfqName = item.RFQ__r.Name;
            if(item.Project_Device__c != null) {
                deviceName = item.Project_Device__c;
            }
            else deviceName = '';
            status = setStatusForSort();


            lastModString = '';
            try{
                lastModString = [Select Id, LastModifiedDate from RFQI_Status_History__c where RFQ_Item__c =: Item.Id Order By CreatedDate ASC][0].LastModifiedDate.format();
            }
            catch(Exception e) {}
        }
        
        //Bhanu 01-July-2016 Salesforce-69 Opportunity Stage Update
        //Updating RFQI Status
        /* private String setStatusForSort() {
            if(rfqItem.Status__c == RFQItemDao.STATUS_PRICE_COMPLETE) {return 'a';}
            else if (rfqItem.Status__c == RFQItemDao.STATUS_QUOTED) {return 'b';}
            else if (rfqItem.Status__c == RFQItemDao.STATUS_WON_PROTOTYPE) {return 'c';}
            else if (rfqItem.Status__c == RFQItemDao.STATUS_WON_QUALIFICATION) {return 'd';}
            else if (rfqItem.Status__c == RFQItemDao.STATUS_PROGRAM_WIN) {return 'e';}
            else if (rfqItem.Status__c == RFQItemDao.STATUS_PROGRAM_CANCELED) {return 'f';}
            else return 'g';
        } */
        
        private String setStatusForSort() {
            if(rfqItem.Status__c == RFQItemDao.STATUS_PRICE_COMPLETE) {return 'a';}
            else if (rfqItem.Status__c == RFQItemDao.STATUS_QUOTED) {return 'b';}
            else if (rfqItem.Status__c == RFQItemDao.STATUS_Qual) {return 'c';}
            else if (rfqItem.Status__c == RFQItemDao.STATUS_PROGRAM_WIN) {return 'd';}
            else if (rfqItem.Status__c == RFQItemDao.STATUS_PROGRAM_CANCELED) {return 'e';}
            else return 'f';
        }
        
        public Integer compareTo(Object compareTo){
            StatusWrapper compareItem = (StatusWrapper)compareTo;

            if(sbuName == compareItem.sbuName) {
                if(rfqName == compareItem.rfqName) {
                    if(deviceName == compareItem.deviceName) {
                        return status.compareTo(compareItem.status);
                    }
                    return deviceName.compareTo(compareItem.deviceName);
                }
                return rfqName.compareTo(compareItem.rfqName);
            }
            return sbuName.compareTo(compareItem.sbuName);
        }
    }

    public class SortCriteria {
        public Boolean selected {get;set;}
        public String column {get;set;}
        public String filterCriteria {get;set;}
        public String filterType {get;set;}
        public String qYear {get;set;}

        public SortCriteria() {

        }

        public SortCriteria(String clm, String criteria, String type) {
            selected = false;
            column = clm;
            filterCriteria = criteria;
            filterType = type;
        }

        public List<SelectOption> getStatusList() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', '-- None Selected --'));
            if(column == 'Status') {
                for(String s : RFQStatusUpdateController.statusesIWant) {
                    options.add(new SelectOption(s, s));
                }
            }
            else if(column == 'Package Family'){
                for(Package_Family__c packageFamily : [select Id, Name from Package_Family__c where Inactive__c = false ORDER BY Name]) {
                    if (packageFamily.Name == 'ALL') {
                        continue;
                    }
                    options.add(new SelectOption(packageFamily.Name,packageFamily.Name));
                }
            }
            else if(column == 'Customer Decision to Buy Date') {
                options.add(new SelectOption('Q1', 'Q1'));
                options.add(new SelectOption('Q2', 'Q2'));
                options.add(new SelectOption('Q3', 'Q3'));
                options.add(new SelectOption('Q4', 'Q4'));
            }
            return options;
        }

        public List<SelectOption> getYears() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', '-- None Selected --'));
            
            for(String s : AMKVARS.YEARS) {
                options.add(new SelectOption(s, s));
            }

            return options;
        }
    }
}