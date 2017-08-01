public class ApprovalItemWrapper {
    
    public Boolean isSelected {get; set;}
    public RFQ_Item__c rfqItem {get; set;}
    public ProcessInstanceWorkItem workItem {get; set;}
    public ProcessInstance pInst {get; set;}

    public Boolean isRFQItem { get { return rfqItem != null; } }

    public ApprovalItemWrapper(ProcessInstanceWorkItem piWorkItem, ProcessInstance procInst) {
        pInst = procInst;
        workItem = piWorkItem;
        isSelected = false;
    }

    public Boolean getIsSales()
    {
        return rfqItem.Status__c == RFQItemDao.STATUS_SALES_REQ_PREAPPROVAL;
    }
}