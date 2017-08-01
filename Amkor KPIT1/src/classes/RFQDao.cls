/*************************************************************************
*
* PURPOSE: Data access and manipulation for RFQ__c
*
* CLASS: RFQDao
* CREATED: 3/27/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Nathan Pilkington
***************************************************************************/

public class RFQDao extends BaseDao {

    public static final String STATUS_NEW = 'New';
    public static final String STATUS_NEW_REVISION = 'New / Revision';
    public static final String STATUS_IN_PROGRESS = 'In Progress';
    public static final String STATUS_PRICING_COMPLETE = 'Pricing Complete';
    public static final String STATUS_PRICING_ESCALATION = 'Pricing Escalation';
    public static final String STATUS_CLOSED = 'Closed';

    public static final String STATUS2_OPEN = 'Open';
    public static final String STATUS2_CLOSED = 'Closed';
    public static final String STATUS2_CLOSED_CANCELED = 'Closed Canceled';

    private static final Map<String,Integer> statusMap = new Map<String,Integer>
    {     
        STATUS_NEW_REVISION => 10,
        STATUS_IN_PROGRESS => 20,
        STATUS_PRICING_COMPLETE => 30,
        STATUS_PRICING_ESCALATION => 40,
        STATUS_CLOSED => 50  
    };

    private static final RFQDao RFQDao = new RFQDao();
        
    private RFQDao() {  
        super('RFQ__c'); 
        addSingleField('SBU_Name__r.Name');
    }
    
    public static RFQDao getInstance() {
        return RFQDao;
    }
    
    public RFQ__c save(RFQ__c rfq) {
        update rfq;
        return rfq;
    }
    
    public RFQ__c getRfqById(String rfqId) {
        return (RFQ__c)getSObjectById(rfqId);
    }

    @future
    public static void closeRFQs(Set<Id> rfqIds) {
        List<RFQ__c> rfqs = [select Id, Opportunity__c from RFQ__c where Id in: rfqIds];
        Map<String, Opportunity> opportunityMap = new Map<String, Opportunity>();
        
        for(RFQ__c rfq : rfqs) {
            if (opportunityMap.containsKey(rfq.Opportunity__c))
                continue;
            Opportunity o = new Opportunity();
            o.Id = rfq.Opportunity__c;
            RFQ_Item__c higestStatusedItem = RFQOpportunityDao.getHighestStatusItem(o);
            o.StageName = RFQOpportunityDao.mapStatusToStage(higestStatusedItem);
            o.Opportunity_Status__c = RFQOpportunityDao.mapRFQStatusToOpportunityStatus(higestStatusedItem);
            opportunityMap.put(o.Id, o);
            rfq.Status2__c = STATUS2_CLOSED;
        }

        update opportunityMap.Values();
        update rfqs;
    }

    @future
    public static void openRFQs(Set<Id> rfqIds) {
        List<RFQ__c> rfqs = [select Id, Opportunity__c from RFQ__c where Id in: rfqIds];
        Map<String, Opportunity> opportunityMap = new Map<String, Opportunity>();
        
        for(RFQ__c rfq : rfqs) {
            if (opportunityMap.containsKey(rfq.Opportunity__c))
                continue;
            Opportunity o = new Opportunity();
            o.Id = rfq.Opportunity__c;
            RFQ_Item__c higestStatusedItem = RFQOpportunityDao.getHighestStatusItemNotClosed(o);
            o.StageName = RFQOpportunityDao.mapStatusToStage(higestStatusedItem);
            o.Opportunity_Status__c = RFQOpportunityDao.mapRFQStatusToOpportunityStatus(higestStatusedItem);
            opportunityMap.put(o.Id, o);
            rfq.Status2__c = STATUS2_OPEN;
            system.debug('at line number 88 RFQDao  rfq :  '+rfq.Id);
            system.debug('at line number 88 RFQDao  rfq :  '+rfq.Status__c);
        }
        update opportunityMap.Values();
        system.debug('at line number 90 RFQDao  rfqs :  '+rfqs);
        update rfqs;    
    }

    public static List<Id> canOpportunityClose(List<Id> oppIds) {
    
        List<Id> errorList = new List<Id>();

        List<Opportunity> ops = [select Id, (SELECT Status__c FROM RFQ_Items__r) from Opportunity where Id in: oppIds];
        for(Opportunity op : ops) {
      
            for(RFQ_Item__c item : op.RFQ_Items__r) {
                if(!RFQItemDao.STATUS_CLOSED.contains(item.Status__c)) {
                    errorList.add(op.Id);
                    break;

                }
            }
        }
        return errorList;
    }

    public static RFQ__c createFromOpportunity(Opportunity opp) {
        system.debug('---->RFQDao.createFromOpportunity(), opp : ' + opp);
        RFQ__c rfq = new RFQ__c(RFQ_Name__c = opp.Name,
                                Opportunity__c = opp.Id,
                                SBU_Name__c = opp.AccountId,
                                Projected_Revenue__c = opp.Projected_Revenue__c
                                );
        //TODO - capture some other information... like decison to buy date
        insert rfq;
        
        //Bhanu - 7-Apr-2016 : Salesforce 57 ADD Item from New Opportunity is creating 2 RFQ header records
        //Setting RFQ__c on Opportunity
        System.debug('---> RFQ id : '+rfq.Id);
        opp.RFQ__c = rfq.Id;
        update opp;
        system.debug('---->RFQDao.createFromOpportunity(), opp : ' + opp);

        List<RFQ_Item__c> items = [select Id from RFQ_Item__c where Opportunity__c =: opp.Id];
        for(RFQ_Item__c item : items) {
            item.RFQ__c = rfq.Id;
        }
        update items;
        return rfq;
    }

    
    public static void createFromOpportunity(List<Id> oppIds) {
        system.debug('---->RFQDao.createFromOpportunity(List<Id> oppIds), oppIds: ' + oppIds);
        List<Opportunity> opps = [select Name,Id,AccountId,Projected_Revenue__c, (SELECT Id FROM RFQ_Items__r) from Opportunity where Id in: oppIds];
        
        Map<Id,RFQ__c> rfqMap = new Map<Id,RFQ__c>();

        for(Opportunity opp : opps) {

             RFQ__c rfq = new RFQ__c(RFQ_Name__c = opp.Name,
                                     Opportunity__c = opp.Id,
                                     SBU_Name__c = opp.AccountId,
                                     Projected_Revenue__c = opp.Projected_Revenue__c);
             rfqMap.put(opp.Id,rfq);
        }

        insert rfqMap.values();
        System.debug('--->rfqMap.values()'+rfqMap.values());

        List<RFQ_Item__c> items = new List<RFQ_Item__c>();
        for(Opportunity opp : opps) {
             
             Id rfqId = rfqMap.get(opp.Id).Id;
             opp.RFQ__c = rfqId;
             for(RFQ_Item__c item : opp.RFQ_Items__r) {
                 item.RFQ__c = rfqId;

                 items.add(item);
             }

        }
        update items;
        update opps;
    }

    public Boolean statusGreaterOrEqual(RFQ__c item, String itemStatusName) {
        Integer itemStatus = statusMap.get(item.Status__c);
        Integer compareStatus = statusMap.get(itemStatusName);
        return itemStatus >= compareStatus; 
    }
     
    public Boolean statusLessOrEqual(RFQ__c item, String itemStatusName) {
        Integer itemStatus = statusMap.get(item.Status__c);
        Integer compareStatus = statusMap.get(itemStatusName);
        return itemStatus <= compareStatus; 
    }

}