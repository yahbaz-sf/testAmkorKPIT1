/*************************************************************************
* 
* PURPOSE:  This class provides the supporting functions for RFQMassApprove.page 
*         
* CLASS: RFQMassApproveController
* CREATED: 01/10/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Raghuveer Mandali rmandali@ethos.com
* 
**************************************************************************/
public with sharing class RFQMassApproveController extends BaseController{

    public Set<Product_Group__c> productGroupList { get; set; }
    public String rfqId { get; set; }
    public String selectedProductGroup { get; set; }
    public List<RfqItemHolder> currentItems { get; set; }
    public List<RfqItemHolder> selectedItems {get; set;}
    public String approvalComment {get; set; }
    public Boolean startedApproval {get; set;}
    public Integer numberRemaining { get; set; }
	
    public RFQMassApproveController() {
        rfqId = getParam('rfqId');

        productGroupList = ProductGroupDao.getInstance().getAllProductGroupByRfq(rfqId);

        if (productGroupList == null || productGroupList.size() == 0) {
            addInfo('No RFQ Items found for this RFQ');
        }
        startedApproval = false;
        numberRemaining = 0;
    }

    public PageReference returnToRfq() {
        return new PageReference('/apex/RFQView?id=' + rfqId);
    }

    public List<SelectOption> getProductGroupOptions() {
        List<SelectOption> result = new List<SelectOption>();

        
        if (productGroupList == null || productGroupList.size() == 0) {
            result.add(new SelectOption('', 'No Product Groups'));
        }
        else {
            result.add(new SelectOption('', '-- Select --'));

            for (Product_Group__c pg : productGroupList) {
                result.add(new SelectOption(pg.Id, pg.Name));
            }
        }

        return result;
    }


    public void setItemList() {
        currentItems = new List<RfqItemHolder>();

        if (!StringUtils.isBlank(selectedProductGroup)) {
            List<RFQ_Item__c> rfqItems = RFQItemDao.getInstance().getByRfqAndPgId(rfqId, selectedProductGroup);

            for (RFQ_Item__c item : rfqItems) {
                if(item.Status__c == RFQItemDao.STATUS_PRICE_PENDING_BU && item.Has_Been_BU_Imported__c){
                    currentItems.add(new RfqItemHolder(item));
                }
            }

        }
    }

    public PageReference massApprove() {
        Boolean noApproval = false;
        selectedItems = new List<RfqItemHolder>();
        if (currentItems != null && currentItems.size() > 0) {
            for (RfqItemHolder item : currentItems) {
                if (item.selected) {
                    if(!StringUtils.isBlank(approvalComment)) {
                        selectedItems.add(item);
                    }
                    else if(!StringUtils.isBlank(item.approvalComment)) {
                        selectedItems.add(item);
                    }
                    else {
                        addError('Rfq Item: ' + item.item.Name + ' was not added because there was no Mass Approval Comment or Approval Comment for this Specific Item');
                        selectedItems.add(item);
                        noApproval = true;
                    }
                }
            }
        } else {
            addError('No items available for approval');
            return null;
        }
        if (selectedItems.size() == 0) {
            addError('Please select at least one item for approval');
        }
        else if (noApproval) {
            selectedItems.clear();
            addError('Please fill out Approval Comments');
        }
        else{
            numberRemaining = selectedItems.size();
            startedApproval = true;
        }
        return null;
    }

    public void submitNextItemApprove() {
        if(selectedItems != null && selectedItems.size() > 0) {
            try {
                system.debug('Size: ' + selectedItems.size());
                ProcessInstanceWorkItem workItem = [Select Id, ProcessInstance.Status, ProcessInstance.TargetObjectId,ProcessInstance.TargetObject.Name,
                                                          ProcessInstance.TargetObject.Type, ProcessInstanceId, ActorId
                       From ProcessInstanceWorkitem where ProcessInstance.TargetObjectId = :selectedItems[0].item.Id LIMIT 1];
                if(workItem != null && workItem.ProcessInstance.TargetObject.Type == 'RFQ_Item__c') {
                    system.debug('grabbing wrapper');
                    RFQItemWrapper wrapper = RFQItemDao.getInstance().getWrapperById(selectedItems[0].item.Id);
                    wrapper.copyBuPriceToCustomerPrice();
                    CPN cpn = CPNDao.getInstance().getCPN(wrapper);
                    wrapper.rfqItem.Configured_Part_Number__c = cpn.cpnId;            
                    RFQItemDao.getInstance().saveLineItem(wrapper);
                    if(!StringUtils.isBlank(selectedItems[0].approvalComment)) {
                        system.debug('custom approval comment: ' + selectedItems[0].approvalComment);
                        ApprovalUtils.approveRecord(workItem.Id,selectedItems[0].approvalComment);
                    }
                    else {
                        system.debug('mass approval comment: ' + approvalComment);
                        ApprovalUtils.approveRecord(workItem.Id,approvalComment);
                    }
                    system.debug('removing approved item');
                    selectedItems.remove(0);
                    numberRemaining = selectedItems.size();
                }
                else {
                    addError('This Item is not under review');
                }
            }
            catch (Exception e){}
        }
    }

    public void submitNextItemReject() {
        if(selectedItems != null && selectedItems.size() > 0) {
            try {
                system.debug('Size: ' + selectedItems.size());
                ProcessInstanceWorkItem workItem = [Select Id, ProcessInstance.Status, ProcessInstance.TargetObjectId,ProcessInstance.TargetObject.Name,
                                                          ProcessInstance.TargetObject.Type, ProcessInstanceId, ActorId
                       From ProcessInstanceWorkitem where ProcessInstance.TargetObjectId = :selectedItems[0].item.Id LIMIT 1];
                if(workItem != null && workItem.ProcessInstance.TargetObject.Type == 'RFQ_Item__c') {
                    system.debug('grabbing wrapper');
                    RFQItemWrapper wrapper = RFQItemDao.getInstance().getWrapperById(selectedItems[0].item.Id);
                    if(!StringUtils.isBlank(selectedItems[0].approvalComment)) {
                        system.debug('custom approval comment: ' + selectedItems[0].approvalComment);
                        ApprovalUtils.rejectRecord(workItem.Id,selectedItems[0].approvalComment);
                    }
                    else {
                        system.debug('mass approval comment: ' + approvalComment);
                        ApprovalUtils.rejectRecord(workItem.Id,approvalComment);
                    }
                    system.debug('removing approved item');
                    wrapper.setRejectedState();
                    RFQItemDao.getInstance().saveLineItem(wrapper);
                    selectedItems.remove(0);
                    numberRemaining = selectedItems.size();
                }
                else {
                    addError('This Item is not under review');
                }
            }
            catch (Exception e){}
        }
    }

    public void submitNextItemNoBid() {
        if(selectedItems != null && selectedItems.size() > 0) {
            try {
                system.debug('Size: ' + selectedItems.size());
                ProcessInstanceWorkItem workItem = [Select Id, ProcessInstance.Status, ProcessInstance.TargetObjectId,ProcessInstance.TargetObject.Name,
                                                          ProcessInstance.TargetObject.Type, ProcessInstanceId, ActorId
                       From ProcessInstanceWorkitem where ProcessInstance.TargetObjectId = :selectedItems[0].item.Id LIMIT 1];
                if(workItem != null && workItem.ProcessInstance.TargetObject.Type == 'RFQ_Item__c') {
                    system.debug('grabbing wrapper');
                    RFQItemWrapper wrapper = RFQItemDao.getInstance().getWrapperById(selectedItems[0].item.Id);
                    if(!StringUtils.isBlank(selectedItems[0].approvalComment)) {
                        system.debug('custom approval comment: ' + selectedItems[0].approvalComment);
                        ApprovalUtils.rejectRecord(workItem.Id,selectedItems[0].approvalComment);
                    }
                    else {
                        system.debug('mass approval comment: ' + approvalComment);
                        ApprovalUtils.rejectRecord(workItem.Id,approvalComment);
                    }
                    system.debug('removing approved item');
                    wrapper.setRejectedState();
                    wrapper.rfqItem.Status__c = RFQItemDao.STATUS_NO_BID;
                    RFQItemDao.getInstance().saveLineItem(wrapper);
                    selectedItems.remove(0);
                    numberRemaining = selectedItems.size();
                }
                else {
                    addError('This Item is not under review');
                }
            }
            catch (Exception e){}
        }
    }

}