/*************************************************************************
*
* PURPOSE: This class handles routing for RFQ Line Items that are saved 
*          in non draft mode. 
*
* CLASS: RFQItemApprovalController
* CREATED: 4/25/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/
public class RFQItemApprovalRouting {

    public enum RoutingType {NONE,PRE_APPROVAL,POST_APPROVAL}
    private User currentUser;


    public RFQItemApprovalRouting() {
        currentUser = UserDao.getInstance().getCurrentUser();
    }
    
    /**
    * This method takes the wrapper used in construction and passes back 
    * an RFQItemApprovalRouting.RFQItemRoute object which describes how 
    * the RFQ Line Item was routed
    *
    * @returns a RFQItemApprovalRouting.RFQItemRoute object describing how the object
    *          was attempted to be routed (submited for approval) and if the routing 
    *          was successful (e.g. if a valid approval process could be found)
    */ 
    public RFQItemRoute route(RFQItemWrapper wrapper) {
                
        Boolean requiresApproval = false;
        RFQItemRoute route = new RFQItemRoute();
        
        //If the item is already under approval, don't return that 
        //we don't need to route anything. 
        if(ApprovalUtils.isUnderApproval(wrapper.rfqItem.Id)) return route;

        //attempt to see if this item is a candidate for pre-approval
        RFQItemRoute preRoute = preApprovalRouting(wrapper);
        if(preRoute.itemRouteType != RoutingType.NONE) {
            route = preRoute;
            requiresApproval = true;
        } 
        
        //if it wasn't now check if it is a candidate for
        //post approval routing
        if(!requiresApproval) {
            
            RFQItemRoute postRoute = postApprovalRouting(wrapper);
            if(postRoute.itemRouteType != RoutingType.NONE) {
                route = postRoute;
                requiresApproval = true;
            }
        }
    
        //in either case, submit to salesforce to 
        //check if it can be matched against an approval process
        if (requiresApproval) {
            try {
                ApprovalUtils.startApproval(wrapper.rfqItem.Id, route.approvalComment);
            } 
            catch(Exception e) { route.isSuccess = false; }
        }
        //the controller should inspect the isSuccess flag and reporte the
        //error on the route object
        return route;
    }

    //helper method for pre approvals
    private RFQItemRoute preApprovalRouting(RFQItemWrapper wrapper) {
        
        RFQ__c rfq = RFQDao.getInstance().getRfqById(wrapper.rfqItem.RFQ__c);
        Account account = AccountDao.getInstance().getAccountById(rfq.SBU_Name__c);

        if(wrapper.rfqItem.Status__c == RFQItemDao.STATUS_PRICE_SUBMIT) {
            
            RoutingType roType = RoutingType.PRE_APPROVAL;
            if (wrapper.packageFamily.No_Cost_Model__c) {
                wrapper.rfqItem.Status__c = RFQItemDao.STATUS_PRICE_PENDING_BU;
                RFQIStatusHistoryDao.getInstance().updateStatusHistory(wrapper);
                wrapper.clearPriceToCustomerIfRequired();

                if (!RFQItemDao.getInstance().saveLineItem(wrapper)) return new RFQItemRoute();
                String approvalComment = 'No Cost Model configured for Product Group';
                return new RFQItemRoute(approvalComment,Label.RFQ_ERR_0002,roType);                
            }
            else if (currentUser.Requires_Approval__c) {
                
                wrapper.rfqItem.Status__c = RFQItemDao.STATUS_USER_REQ_PREAPPROVAL;
                RFQIStatusHistoryDao.getInstance().updateStatusHistory(wrapper);
                if (!RFQItemDao.getInstance().saveLineItem(wrapper)) return new RFQItemRoute();
                System.debug(LoggingLevel.Info, '### Current user Requires Approval');
                return new RFQItemRoute(Label.RFQ_MSG_0001,Label.RFQ_ERR_0004,roType); 
            }
            else if (account.Requires_Pre_Approval__c) {
                
                wrapper.rfqItem.Status__c = RFQItemDao.STATUS_ACCOUNT_REQ_PREAPPROVAL;
                RFQIStatusHistoryDao.getInstance().updateStatusHistory(wrapper);
                if (!RFQItemDao.getInstance().saveLineItem(wrapper)) return new RFQItemRoute();
                System.debug(LoggingLevel.Info, '### Account Requires Approval');
                return new RFQItemRoute(Label.RFQ_MSG_0002,Label.RFQ_ERR_0004,roType); 
            }
            
            //TODO - this is incorrect, this needs to be on the product group
            else if (wrapper.packageFamily.Sales_Requires_Pre_Approval__c || wrapper.productGroup.Sales_Requires_Pre_Approval__c) {
                
                wrapper.rfqItem.Status__c = RFQItemDao.STATUS_SALES_REQ_PREAPPROVAL;
                RFQIStatusHistoryDao.getInstance().updateStatusHistory(wrapper);
                if (!RFQItemDao.getInstance().saveLineItem(wrapper)) return new RFQItemRoute();
                System.debug(LoggingLevel.Info, '### Package family Requires Approval');
                return new RFQItemRoute(Label.RFQ_MSG_0003,Label.RFQ_ERR_0004,roType); 
            }
        }
        
        return new RFQItemRoute(); 
    }
    
    //helper method for post approvals
    private RFQItemRoute postApprovalRouting(RFQItemWrapper wrapper) {
        if(wrapper.rfqItem.Status__c == RFQItemDao.STATUS_PRICE_COMPLETE ||
           wrapper.rfqItem.Status__c == RFQItemDao.STATUS_PREAPPROVAL_COMPLETE) {
            RoutingType roType = RoutingType.POST_APPROVAL;
            if(wrapper.productGroup.Generated_Price_Requires_BU_Review__c) {
                wrapper.rfqItem.Status__c = RFQItemDao.STATUS_PRICE_PENDING_BU;
                RFQIStatusHistoryDao.getInstance().updateStatusHistory(wrapper);

                wrapper.clearPriceToCustomerIfRequired();

                if (!RFQItemDao.getInstance().saveLineItem(wrapper)) return new RFQItemRoute();
                return new RFQItemRoute(Label.RFQ_MSG_0004,Label.RFQ_ERR_0005,roType); 
            } 
            else if(wrapper.productGroup.Generated_Price_Requires_Sales_Review__c) {
                wrapper.rfqItem.Status__c = RFQItemDao.STATUS_PRICE_PENDING_SALES;
                if (!RFQItemDao.getInstance().saveLineItem(wrapper)) return new RFQItemRoute();
                return new RFQItemRoute(Label.RFQ_MSG_0004,Label.RFQ_ERR_0006,roType); 
            }
        }
        return new RFQItemRoute(); 
    }
    
    //helper class for returning data about
    //how the line item was routed
    public class RFQItemRoute {
        
        public String approvalComment {get; set;}
        public String approvalError {get; set;}
        public Boolean isSuccess {get; set;}
        public RoutingType itemRouteType {get; set;}
        
        public RFQItemRoute() {
            this('','',RoutingType.NONE);
        }
        
        public RFQItemRoute(String appvComment, String appvErr, RoutingType roType) {
            approvalComment = appvComment;
            approvalError = appvErr;
            isSuccess = true;
            itemRouteType = roType;
        }
    }
    
    
    
}