/*************************************************************************
* 
* PURPOSE:  This class provides the supporting functions for RFQPdfExportSelect.page 
*         
* CLASS: RFQPdfExportSlectController
* CREATED: 05/1/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Nathan Pilkington npilkington@ethos.com
* 
**************************************************************************/

public with sharing class RFQPdfExportSelectController extends BaseController {

    public RFQ__c rfq { get; set; }
    
    public Account rfqAccount { get; set; }
     
    public List<RFQItemHolder> allItemsList { get; set; }

    public List<RFQItemHolder> finalTestItemsList { get; set; }
    
    public String comments { get; set; }

    public Boolean finalTestSelected { get; set; }
    public String selectedIdString { get; set; }
    public String adderBreakoutString { get; set; }
    public String lotChargeString { get; set; }
    public String separatePostTestString { get; set; }  

    public RFQPdfExportSelectController() {
        
        Boolean isBU = RFQSystemSettings.getIsBUUser();
        Boolean isHybrid = RFQSystemSettings.getIsHybridUser();
        allItemsList = new List<RFQItemHolder>();

        String rfqId = getParam('rfqId');
        rfq = RFQDao.getInstance().getRfqById(rfqId);
        if(rfq != null) {
            List<RFQ_Item__c> rfqItems = RFQItemDao.getInstance().getPriceCompleteByRfqId(rfq.Id, 'Package_Family__r.Name ASC');
            
            
            if(isBU && !isHybrid) {
                addError('Only Sales and Hybrid users can generate quotes');

            } 
            else { 
                for (RFQ_Item__c itemRow : rfqItems) {
                    //Abhay N- 24 April 2017- SF-198 RFQI'S with zero price should not be available to print on a quote: Added a condition to check Price_To_Customer__c to be greater than zero. 
                    if(itemRow.Price_To_Customer__c != null && itemRow.Price_To_Customer__c > 0) {
                        allItemsList.add(new RFQItemHolder(itemRow));
                    }
                }
                allItemsList.sort();
            }

        }
        else addError('Missing Parameter: Please reload this page from the RFQ');

        
    }
    
    
    public PageReference selectAllItems() {
        for (RFQItemHolder item : allItemsList) {
            item.selected = true;
        }
        
        return null;
    }
    
    public PageReference deselectAllItems() {
        for (RFQItemHolder item : allItemsList) {
            item.selected = false;
        }
        
        return null;
    }

    public PageReference selectAllBreakout() {
        for (RFQItemHolder item : allItemsList) {
            if (item.selected) item.adderBreakout = true;
        }
        
        return null;
    }

    public PageReference selectAllLotCharge() {
        for (RFQItemHolder item : allItemsList) {
            if (item.selected) item.lotCharge = true;
        }
        
        return null;
    }
    
    public PageReference selectAllSeparatePostTest() {
        for (RFQItemHolder item : allItemsList) {
            if (item.selected) item.separatePostTest = true;
        }
        
        return null;
    }
    
    /**
    * This method gets all the items that were selected on the page
    * and passes them into the RFQPdfExportPage, which generates the PDF.
    * It then attaches the PDF to the RFQ object.
    * It also updates all of the selected items to 'Quoted' status
    */
    public PageReference itemsSelected() {
        List<RFQ_Item__c> selectedItems = new List<RFQ_Item__c>();
        
        for (RFQItemHolder itemHolder : allItemsList) {
            if (itemHolder.selected) {
                selectedItems.add(itemHolder.item);
            }
        }
        
        if (selectedItems.size() == 0) {
            addError(Label.RFQ_ERR_0100);
        }
        else {
            List<String> idList = new List<String>();
            List<String> adderBreakoutList = new List<String>();
            List<String> lotChargeList = new List<String>();
            List<String> separatePostTestList = new List<String>();
            
            for (RFQ_Item__c item : selectedItems) {
                idList.add(item.Id);
            }
            
            for (RFQItemHolder itemHolder : allItemsList) {
                if (itemHolder.adderBreakout) {
                    adderBreakoutList.add(itemHolder.item.Id);
                }
                if (itemHolder.lotCharge) {
                    lotChargeList.add(itemHolder.item.Id);
                }
                if (itemHolder.separatePostTest){
                    system.debug('seperate post test: '+itemHolder);
                    separatePostTestList.add(itemHolder.item.Id);
                }
            }
            
            selectedIdString = String.join(idList, ',');
            adderBreakoutString = String.join(adderBreakoutList, ',');
            lotChargeString = String.join(lotChargeList, ',');
            separatePostTestString = String.join(separatePostTestList, ',');        

            RFQItemDao.getInstance().setItemsQuoted(selectedItems);

            rfq.Effective_Through_Date__c = Date.today() + 90;
            update rfq;
        }
        
        return null;
    }

    public PageReference generatePDF() {
        String attachId = null;
        if(!String.isBlank(selectedIdString)) attachId = RFQExportUtil.generatePdfQuote(rfq, selectedIdString, adderBreakoutString, lotChargeString, separatePostTestString, comments);
         
        if (attachId != null) {
            return new PageReference('/servlet/servlet.FileDownload?file='+attachId);
        } 
        else {
            addError('A system error occurred and so a PDF could not be generated');
        }
        return null;
    } 

    public PageReference generateExcel() {
        String attachId = null;
        if(!String.isBlank(selectedIdString)) attachId = RFQExportUtil.generateExcelQuote(rfq, selectedIdString, adderBreakoutString, lotChargeString, comments);
         
        if (attachId != null) {
            return new PageReference('/servlet/servlet.FileDownload?file='+attachId);
        } 
        else {
            addError('A system error occurred and so a Excel file could not be generated');
        }
        return null;
    } 
    
    /**
    * Holder class for the page to tell if an item is selected or not
    */
    public class RFQItemHolder implements Comparable{
        public Boolean selected { get; set; }
        public Boolean adderBreakout { get; set; }
        public Boolean lotCharge { get; set; }
        public RFQ_Item__c item { get; set; }
        public Boolean separatePostTest {get; set;}
        
        public RFQItemHolder(RFQ_Item__c newItem) {
            adderBreakout = false;
            lotCharge = false;
            selected = false;
            item = newItem;
            selected = false;
            separatePostTest = false;
        }

        public Integer compareTo(Object compareTo){
            RFQItemHolder compareItem = (RFQItemHolder)compareTo;
            if(item.Package_Family_Name__c == compareItem.item.Package_Family_Name__c) {
                if(item.Forecast_Median__c > compareItem.item.Forecast_Median__c) return 1;
                else if(item.Forecast_Median__c < compareItem.item.Forecast_Median__c) return -1;
                else return item.Package_Family_Name_fml__c.compareTo(compareItem.item.Package_Family_Name_fml__c);
            }
            return item.Package_Family_Name__c.compareTo(compareItem.item.Package_Family_Name__c);
        }


    }
}