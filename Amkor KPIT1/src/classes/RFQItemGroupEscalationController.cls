/*************************************************************************
*
* PURPOSE: Controller for the RFQ Item Group Escalation page
*
* CLASS: RFQItemGroupEscalationController
* CREATED: 6/18/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Nathan Pilkington
***************************************************************************/
public with sharing class RFQItemGroupEscalationController extends BaseController {
    
    public RFQ__c rfq { get; set; }

    public List<EscalateItemHolder> escalateItems { get; set; }

    public RFQI_Escalation__c escalation {get;set;}
    
    public RFQItemGroupEscalationController() {

        escalation = new RFQI_Escalation__c();

        String rfqId = getParam('rfqId');

        rfq = RFQDao.getInstance().getRfqById(rfqId);

        List<RFQ_Item__c> rfqItems = RFQItemDao.getInstance().getByRfqId(rfq.Id);

        escalateItems = getEscalatableItems(rfqItems);

        if (escalateItems.size() == 0) {
            addInfo(Label.RFQ_MSG_0200);
        }
    } 

    /**
    * Takes in a list of RFQ Items and a list of active approval processes for the rfq, and returns
    * the ones that can be escalated
    *
    * @param allItems The list of items which will be filtered
    * @returns a List<EscalateItemHolder> of which items can be escalated
    */
    public List<EscalateItemHolder> getEscalatableItems(List<RFQ_Item__c> allItems) {
        List<EscalateItemHolder> escalatableItems = new List<EscalateItemHolder>();

        // Get all the active approval processes for the rfq in one go, and shove them into a set
        Map<Id, RFQ_Item__c> rfqItemMap = new Map<Id, RFQ_Item__c>(allItems);
        List<ProcessInstanceWorkitem> wiList  = [Select Id, ProcessInstance.Status, 
                                                 ProcessInstance.TargetObjectId, 
                                                 ProcessInstanceId 
                                                 From ProcessInstanceWorkitem 
                                                 where ProcessInstance.TargetObjectId in :rfqItemMap.keySet()];
        Set<Id> wiSet = new Set<Id>();

        for (ProcessInstanceWorkitem workItem : wiList) {
            wiSet.add(workItem.ProcessInstance.TargetObjectId);
        }

        for (RFQ_Item__c rfqItem : allItems) {

            // If no approval process found for the item, and in price complete then add it to the list
            if (!wiSet.contains(rfqItem.Id) && (rfqItem.Status__c == RFQItemDao.STATUS_PRICE_COMPLETE || rfqItem.Status__c == RFQItemDao.STATUS_QUOTED))
            {
                escalatableItems.add(new EscalateItemHolder(rfqItem));
            }
        }

        return escalatableItems;
    }
    
    /**
    * Creates escalation objects used for reporting (for selected items), 
    * and attempts to launch an approval process for each item
    *
    * @returns a PageReference to the view page if successful, null otherwise
    */
    public PageReference escalate() {
        List<EscalateItemHolder> selectedItems = new List<EscalateItemHolder>();
        List<RFQ_Item__c> items = new List<RFQ_Item__c>();

        for (EscalateItemHolder holder : escalateItems) {
            if (holder.selected) {
                selectedItems.add(holder);
                holder.rfqItem.Status__c = RFQItemDao.STATUS_PRICE_ESCALATION;
                items.add(holder.rfqItem);
            }
        }

        if (selectedItems.size() == 0) { 
            // Must select at least one
            addError(Label.RFQ_ERR_0200);
        }
        else if (selectedItems.size() > 100) {
            // Too many items
            addError(Label.RFQ_ERR_0201);
        }
        else { 
            // Do the escalation stuff
            try {
                List<RFQI_Escalation__c> escalations = new List<RFQI_Escalation__c>();
                update items;
                for (EscalateItemHolder holder : selectedItems) {
                    ApprovalUtils.startApproval(holder.rfqItem.Id, escalation.Reason__c + ': ' + escalation.Comments__c);
                    escalations.add(new RFQI_Escalation__c(RFQ_Item__c=holder.rfqItem.Id,Reason__c=escalation.Reason__c,Comments__c=escalation.Comments__c));
                }

                insert escalations;

                return new PageReference('/' + rfq.Id);
            } catch (Exception e) {
                System.debug(LoggingLevel.Error, '### Error while escalating items: ' + e);
                addError(Label.RFQ_ERR_0003);
            }
        }

        return null;
        // try {
            
        //     ApprovalUtils.startApproval(wrapper.rfqItem.Id, escalation.Reason__c + ': ' + escalation.Comments__c);
        //     escalation.RFQ_Item__c = wrapper.rfqItem.Id;        
        //     insert escalation;
            
        // } catch(Exception e){
        //     addError(Label.RFQ_ERR_0003);
        //     return null;
        // } 
        // return new PageReference('/apex/RFQItemView?id='+wrapper.rfqItem.Id);

        return null;
    }

    public PageReference cancelEscalation() {
        return new PageReference('/' + rfq.Id);
    }

    public PageReference selectAll() {
        for (EscalateItemHolder holder : escalateItems) {
            holder.selected = true;
        }

        return null;
    }

    public PageReference selectNone() {
        for (EscalateItemHolder holder : escalateItems) {
            holder.selected = false;
        }

        return null;
    }


    public class EscalateItemHolder {

        public Boolean selected { get; set; }
        public RFQ_Item__c rfqItem { get; set; }

        public EscalateItemHolder(RFQ_Item__c rfqItem) {
            this.rfqItem = rfqItem;
            this.selected = false;
        }
    }
}