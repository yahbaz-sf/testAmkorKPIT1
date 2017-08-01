public with sharing class RFQOpportunityDao extends BaseDao {
    


    private static final RFQOpportunityDao mDao = new RFQOpportunityDao();
    
    private RFQOpportunityDao(){  super('Opportunity'); }
    
    public static RFQOpportunityDao getInstance() {
        return mDao;
    }

    //@future
    public static void repointRFQItems() {

        List<RFQ_Item__c> items = [select Id, RFQ__r.Opportunity__c, Opportunity__c 
                                   from RFQ_Item__c where Opportunity__c =: null and 
                                   RFQ__r.Opportunity__c !=: null];

        for(RFQ_Item__c item : items) {
            item.Opportunity__c = item.RFQ__r.Opportunity__c;
        }
        update items;
        
    }


    //convert RFQ Status to opttyStage
    public static String mapStatusToStage(RFQ_Item__c item) {
        
        //Ashish - 26-July-2016 : Salesforce 69
        //Consolidated statusToStage conditions, old stage logic is available in commented status at the end of method
        //The default value is 'RFQ/Quote' and its the same for follwing conditions. Thus no need to assign explicitly.  
        //Conditions start ---
        //RFQItemDao.getInstance().statusLessOrEqual(item, RFQItemDao.STATUS_PRICE_COMPLETE) || 
        //item.Status__c == RFQItemDao.STATUS_QUOTED ||
        //item.Status__c == RFQItemDao.STATUS_PRICE_ESCALATION
        //Conditions end
        
        
         //Abhay - 26-July-2017 :Salesforce 199 :  Opportunity Stage Auto Update Fix//
        // Replaced the status to stage mapping with the map created using statusMap custom data type
       
        String stage = '';
        if(item != null){
            if(RFQItemDao.statusToStageMap.keyset().contains(item.Status__c)){
                
                stage = RFQItemDao.statusToStageMap.get(item.Status__c);
                        System.debug('SF 199- Line no 48 Stage:'+stage);

            }
            
           
           /* if(item.Status__c == RFQItemDao.STATUS_Qual) {
                stage = 'Qual';
            } else if(item.Status__c == RFQItemDao.STATUS_PROGRAM_WIN) { 
                stage = 'Closed Program Win';
            } else if(item.Status__c == RFQItemDao.STATUS_PROGRAM_LOSS) {
                stage = 'Closed Program Loss';
            } else if(item.Status__c == RFQItemDao.STATUS_PROGRAM_CANCELED) {
                stage = 'Closed Program Cancel';
            } else if(item.Status__c == RFQItemDao.STATUS_PRODUCTION_WIN) {
                stage = 'Closed Program Win';
            }else if(item.Status__c == RFQItemDao.STATUS_NO_BID) {
                //Abhay - 26-June-2017 : Salesforce-199 - Opportunity Stage Auto Update Fix // Added if condition for setting the 'No Bid' stage on oppty
                stage = 'No Bid';
            }*/
            
        }
        if(stage ==''|| stage == null){
            stage = 'RFQ/Quote';
        }
        System.debug('SF 199- Line no 70 Stage:'+stage);
        return stage;
        
        /*if(item == null) return 'RFQ';
        if(RFQItemDao.getInstance().statusLessOrEqual(item, RFQItemDao.STATUS_PRICE_COMPLETE)) return 'RFQ';
        else if(item.Status__c == RFQItemDao.STATUS_QUOTED) return 'Price Quoted / Negotiation';
        else if(item.Status__c == RFQItemDao.STATUS_PRICE_ESCALATION) return 'Price Quoted / Negotiation';
        else if(item.Status__c == RFQItemDao.STATUS_WON_PROTOTYPE) return 'Build Execution';
        else if(item.Status__c == RFQItemDao.STATUS_WON_QUALIFICATION) return 'Build Execution';
        else if(item.Status__c == RFQItemDao.STATUS_PROGRAM_WIN) return 'Closed';
        else if(item.Status__c == RFQItemDao.STATUS_PROGRAM_LOSS) return 'Closed';
        else if(item.Status__c == RFQItemDao.STATUS_PROGRAM_CANCELED) return 'Closed';
        else if(item.Status__c == RFQItemDao.STATUS_PRODUCTION_WIN) return 'Closed';
        return 'RFQ';*/
    }

    //Bhanu 29-June-2016 Salesforce 69 : Opportunity Stage Updation "RFQ" with "RFQ/Quote" & QUAL in opportunity
    //convert RFQ Status to opttyStatus
    //status field on Opportunity object is now removed from Page layout hence code not updated
    public static String mapRFQStatusToOpportunityStatus(RFQ_Item__c item) {
        if(item == null) return 'RFQ';
        if(RFQItemDao.getInstance().statusLessOrEqual(item, RFQItemDao.STATUS_QUOTED)) return 'Open';
        //Bhanu 29-June-2016 Salesforce 69 Opportunity Stage Updation
        //else if(item.Status__c == RFQItemDao.STATUS_WON_PROTOTYPE) return 'Won Prototype';
        //else if(item.Status__c == RFQItemDao.STATUS_WON_QUALIFICATION) return 'Won Qualification';
        else if(item.Status__c == RFQItemDao.STATUS_Qual) return 'Qual';
        else if(item.Status__c == RFQItemDao.STATUS_PROGRAM_WIN) return 'Closed Program Won';
        else if(item.Status__c == RFQItemDao.STATUS_PROGRAM_LOSS) return 'Closed Program Lost';
        else if(item.Status__c == RFQItemDao.STATUS_PROGRAM_CANCELED) return 'Closed Program Canceled';
        else if(item.Status__c == RFQItemDao.STATUS_PRODUCTION_WIN) return 'Closed Production Won';
        return 'RFQ';
    }

    public static void createFromRFQ(Set<Id> rfqIds) {
        createFromRFQ(rfqIds, false);
    }
    
    public static void createFromRFQ(Set<Id> rfqIds, Boolean mapStatuses) {
 
        List<RFQ__c> rfqs = null;
        RecordType rt = [select Id, Name from RecordType where Name = 'Existing Opp' AND sObjectType = 'Opportunity' limit 1];

        if(mapStatuses) rfqs = [select RFQ_Name__c,SBU_Name__c,(select Id, Status__c from RFQ_Items__r),Effective_Through_Date__c, Projected_Revenue__c from RFQ__c where Id in: rfqids];
        else rfqs = [select RFQ_Name__c,SBU_Name__c,Effective_Through_Date__c, Projected_Revenue__c from RFQ__c where Id in: rfqids];       

        Map<Id,Opportunity> opps = new Map<Id,Opportunity>();
        
        //Bhanu 09-August-2016 Updating 'RFQ' stage with 'RFQ/Quote'.
        for(RFQ__c rfq : rfqs) {
              Opportunity opp = new Opportunity(Name = rfq.RFQ_Name__c,
                                        RFQ__c = rfq.Id,
                                        AccountId = rfq.SBU_Name__c,
                                        StageName = mapStatuses ? mapStatusToStage(
                                                                      getHighestStatusItem(rfq.RFQ_Items__r)
                                                                  ) : 'RFQ/Quote',
                                        CloseDate = rfq.Effective_Through_Date__c,
                                        Projected_Revenue__c = rfq.Projected_Revenue__c,
                                        RecordTypeId = rt.Id
                                    );
              opps.put(rfq.Id,opp);
        }

        insert opps.values();

        for(RFQ__c rfq : rfqs) {
            rfq.Opportunity__c = opps.get(rfq.Id).Id;
        }
        update rfqs;
    }

    public static List<RFQ_Item__c> getRFQItems(Opportunity o) {
        return [select Id, Status__c, RFQ__c, Opportunity__c from RFQ_Item__c where Opportunity__c=: o.Id];
    }

    public static RFQ_Item__c getHighestStatusItem(Opportunity o) {
        List<RFQ_Item__c> rfqItems = [select Id, Status__c, RFQ__c, Opportunity__c from RFQ_Item__c where Opportunity__c=: o.Id];
        return getHighestStatusItem(rfqItems);
    }

    public static RFQ_Item__c getHighestStatusItem(List<RFQ_Item__c> rfqItems) {
        RFQ_Item__c highestStatus = null;
        RfQItemDao dao = RFQItemDao.getInstance();
        if(rfqItems != null) {
            for (RFQ_Item__c item : rfqItems) {
                 //Abhay - 26-June-2017 : Salesforce-199 - Opportunity Stage Auto Update Fix 
                // Removed the No Bid condition from below if condition to include No bid in the highest status calculation
                //if (item.Status__c != RFQItemDao.STATUS_NO_BID && (highestStatus == null || dao.statusGreaterOrEqual(item, highestStatus.Status__c))) {
                if ((highestStatus == null || dao.statusGreaterOrEqual(item, highestStatus.Status__c))) {
                    highestStatus = item;
                }    
            }
        }
        return highestStatus;
    }

    public static RFQ_Item__c getHighestStatusItemNotClosed(Opportunity o) {
        List<RFQ_Item__c> rfqItems = [select Id, Status__c, RFQ__c, Opportunity__c from RFQ_Item__c where Opportunity__c=: o.Id];
        return getHighestStatusItemNotClosed(rfqItems);
    }

    public static RFQ_Item__c getHighestStatusItemNotClosed(List<RFQ_Item__c> rfqItems) {
        RFQ_Item__c highestStatus = null;
        RfQItemDao dao = RFQItemDao.getInstance();
        if(rfqItems != null) {
            for (RFQ_Item__c item : rfqItems) {
                system.debug('SF-199 Line 163 highestStatus: '+highestStatus);
                if (item.Status__c != RFQItemDao.STATUS_NO_BID && !RFQItemDao.STATUS_CLOSED.contains(item.Status__c) && (highestStatus == null || dao.statusGreaterOrEqual(item, highestStatus.Status__c))) {
                   system.debug('SF-199 Line 165 highestStatus: '+highestStatus);
                 system.debug('SF-199 Line 166 item.Status__c: '+item.Status__c);

                    highestStatus = item;
                }    
            }
        }
        system.debug('SF-199 Line 172 highestStatus: '+highestStatus);
        return highestStatus;
    }
}