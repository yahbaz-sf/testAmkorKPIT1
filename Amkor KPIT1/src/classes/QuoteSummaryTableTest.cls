public class QuoteSummaryTableTest{

    public List<RFQQuoteSummaryItem> quoteSummaryItemsList{get;set;}
    
    public QuoteSummaryTableTest(){
        
        for(integer i=0; i<quoteSummaryItemsList.size();i++){
            if((quoteSummaryItemsList[i].price == 0)){
                system.debug('quoteSummaryItem Price : '+quoteSummaryItemsList[i].price);
                //quoteSummaryItemsList.remove(i);
            }
        }
    }

}