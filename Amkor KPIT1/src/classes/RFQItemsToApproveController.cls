public virtual with sharing class RFQItemsToApproveController {
   
    public Boolean hasItems {get; set;} 
    public List<ApprovalItemWrapper> itemsToApprove { get; set; }
    
    public RFQItemsToApproveController() {
        itemsToApprove = ApprovalUtils.getItemsToApprove();
        hasItems = itemsToApprove.size() > 0;
    }
}