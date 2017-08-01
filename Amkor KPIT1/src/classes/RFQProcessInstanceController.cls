public with sharing class RFQProcessInstanceController extends BaseController {

    public String approvalComments {get; set;}
    public ProcessInstanceWorkItem workItem {get; set;}
  //Ashish N - 17-July-2016 : SALESFORCE-243 : During escalation a 0 price is still able to be approved.
  //Commenting 'restrictBUApproval' for reducing code complexity.
  //Using 'invalidBUPrice' instead of 'restrictBUApproval'
    //public Boolean restrictBUApproval {get; set;}
    public Boolean showApprovalButton {get; set;}
    public RFQItemWrapper wrapper {get; set;}
    public Boolean isRFQItem {get; set;}
    public Boolean isUnderApproval {get; set;}
    private String actionURL;
    private String cancelURL;
    private Boolean isClone;
    public Boolean manualEntryVerified {get; set;}
    public Boolean hasAmkorSelected {get; set;}
    public Boolean invalidBUPrice {get; set;}
    public Boolean isPostTestServicesOnly {get;set;}
    public String execConcurrence {get; set;}
    public String execConcurrenceLabel {get {return 'Most Senior BU Member Involved in Determination';} set;}
    public String execConcurrenceHelp {get {return 'Highest BU personnel that concurs with approval/rejection';} set;}

    public RFQProcessInstanceController() {
        showApprovalButton = true;
    //Ashish N - 17-July-2016 : SALESFORCE-243 : During escalation a 0 price is still able to be approved.
    //Commenting 'restrictBUApproval' for reducing code complexity.
    //Using 'invalidBUPrice' instead of 'restrictBUApproval'
        //restrictBUApproval = false;       
        isRFQItem = false;
        isUnderApproval = true;
        execConcurrence = UserInfo.getName();
        String objectId = ApexPages.currentPage().getParameters().get('id');

        actionURL = ApexPages.currentPage().getParameters().get('actionURL');
        cancelURL = ApexPages.currentPage().getParameters().get('cancelURL');
        isClone = String.isNotBlank(actionURL);
        if(StringUtils.isBlank(cancelURL)) cancelURL = '/home/home.jsp';
        List<ProcessInstanceWorkitem> wiList
                    = [Select Id, ProcessInstance.Status, ProcessInstance.TargetObjectId,ProcessInstance.TargetObject.Name,
                                                          ProcessInstance.TargetObject.Type, ProcessInstanceId, ActorId
                       From ProcessInstanceWorkitem where ProcessInstance.TargetObjectId = :objectId];
        System.debug(LoggingLevel.ERROR, '###### wiList.size(): ' + wiList.size());

        if(wiList.size() > 0) {
            workItem = wiList[0];
            if(StringUtils.isBlank(actionURL)) actionURL = '/' + workItem.ProcessInstance.TargetObjectId;
            if(StringUtils.isBlank(cancelURL) || String.isBlank(ApexPages.currentPage().getParameters().get('cancelURL'))) cancelURL = '/' + workItem.ProcessInstance.TargetObjectId;

            if(workItem.ProcessInstance.TargetObject.Type == 'RFQ_Item__c') {
                RFQItemDao itemDao = RFQItemDao.getInstance();
                wrapper = itemDao.getWrapperById(workItem.ProcessInstance.TargetObjectId);
                isRFQItem = true;
                
                
                String info = '';
                invalidBUPrice = false;
                isPostTestServicesOnly = false;
                /*System.debug('--->RFQProcessInstanceController, getIsSalesApprove() : ' + getIsSalesApprove());
                System.debug('--->RFQProcessInstanceController, RFQSystemSettings.getIsBUUser() : ' + RFQSystemSettings.getIsBUUser());
                System.debug('--->RFQProcessInstanceController, RFQSystemSettings.getIsHybridUser() : ' + RFQSystemSettings.getIsHybridUser());*/
                
                if (!getIsSalesApprove() && (RFQSystemSettings.getIsBUUser() || RFQSystemSettings.getIsHybridUser()))
                {
                    System.debug('--->RFQProcessInstanceController, conditions met : ');
                    List<String> missingFields = new List<String>();
                    RFQILayout layout = PFFieldDefDao.getInstance().getPackageFamilyLayout(wrapper.packageFamily.Id, wrapper.packageFamily.Layout_Version__c, wrapper.rfqItem.Layout_Version__c, 'BU');
                    RFQIValidation validator = new RFQIValidation(wrapper, layout);
                    if(!validator.validateCostAndPriceSection(missingFields)) {
                        info += 'Cannot approve item without required Cost & Price information: <br />';
                        for(String m : missingFields) {
                           info += m + '<br />'; 
                        }
                        invalidBUPrice = true;
                    }
                    
                    manualEntryVerified = wrapper.rfqItem.Manual_Entry_Verified__c;
                    if (!manualEntryVerified) info += 'Cannot approve item without all required Cost Model Inputs<br />';
                    hasAmkorSelected = wrapper.rfqItem.Has_Amkor_Selected__c;
                    if (hasAmkorSelected) info += 'Cannot approve item if any attributes are "Amkor Selected", "Amkor Specified", or "Amkor Preferred"';
                    if(wrapper.packageFamily.Name == AMKVARS.PF_TEST){
                        if((String)wrapper.specificRfqItem.get('Test_Type__c') == AMKVARS.TT_POST) isPostTestServicesOnly = true;
                    }
                    //Lalit - 30-Jan-2017 : SALESFORCE-51 : Engineering services allows a 0 price to be returned.
                    //commenting the Engineering Services condition to hide the Approval button Start>>>>>>.
                    //if(wrapper.productGroup.Name != 'Engineering Servic0es'){
                        /*Abhay 28-Apr-17 : SF-204 22.1 UAT Added the if condition below to allow test approvals without bu price till step 4 
                        i.e. till Is_BU_Price_Mandatory__c == True */
                        //Abhay N - 20-July-2016 : SALESFORCE-249 : BU user cannot approve an RFQI leaving zero price for a TEST item.
                        //Increased the scope of below given IF condition, allow test approvals without bu price till step 4 incase of RFQs with multi-volume. Included if condition metioned at line 106.
                        if((wrapper.rfqItem.Package_Family_Name__c != 'Test')||(wrapper.rfqItem.Package_Family_Name__c =='Test'&& wrapper.rfqItem.Is_BU_Price_Mandatory__c == True )){
                            if(wrapper.rfqItem.get('BU_Price__c') == null || (Decimal)wrapper.rfqItem.get('BU_Price__c') <= 0){
                                invalidBUPrice = true;
                                String priceLabel = isPostTestServicesOnly ? 'BU Post Test Price /Unit' : 'BU Price';
                                info += 'Cannot approve item with a ' + priceLabel + ' of zero.<br />';
                                
                //Ashish N - 17-July-2016 : SALESFORCE-243 : During escalation a 0 price is still able to be approved.
                //Commenting below code for reducing code complexity.
                //Rerendering approval button when price is zero regardless of RFQI status. 



                                /*if(wrapper.rfqItem.Status__c == RFQItemDao.STATUS_PRICE_PENDING_BU) {
                                    restrictBUApproval = true;  
                                }*/

                            }
                        

                            // changes for SF -204 UAT 22.1 ends
                            if (!copyParentPricesToVolumes())


                            {
                                for (RFQIVolume vol : wrapper.volumeList)   

                                {
                                    if (vol.price == null || vol.price <= 0)
                                    {
                                        invalidBUPrice = true;

                                        info += 'Cannot approve item having an Additional Volume configuration with a BU price of zero - additional volume #' + vol.index + '<br />';
                                    }
                                    //Test doesn't have total cost
                                    if (vol.costLessSubs == null || vol.costLessSubs == 0 && wrapper.packageFamily.Name != 'Test')
                                    {
                                        String fieldName = wrapper.packageFamily.Has_Substrate__c ? 'Cost Less Substrate' : 'Total Cost';
                                        invalidBUPrice = true;
                                        info += 'Additional volume configuration must have ' + fieldName + ' - additional volume #' + vol.index + '<br />';
                                    }
                                }
                                
                  //Ashish N - 17-July-2016 : SALESFORCE-243 : During escalation a 0 price is still able to be approved.
                  //Commenting below code for reducing code complexity.
                  //Rerendering approval button when price is zero regardless of RFQI status. 









                                /*//Ashish - 05-Dec-2016 : Salesforce-125 : Zero BU Price moving to Price Complete
                                //If price in any of the volume config is zero and RFQI is in Price pending Bu Approval status
                                //then restrict approval from BU


                  if(invalidBUPrice && (wrapper.rfqItem.Status__c == RFQItemDao.STATUS_PRICE_PENDING_BU)) {
                                    restrictBUApproval = true;
                                }*/
                            }
                        }
                        

                    //Lalit - 30-Jan-2017 : SALESFORCE-51 : Engineering services allows a 0 price to be returned. End>>>}

                    if (info != '') addInfo(info);

                    if(wrapper.volumeList != null && wrapper.volumeList.size() > 0 && !getIsEscalation()) {
                        addInfo('This is a multi-volume RFQ Item - clicking approve may generate additional volume RFQ Items');
                    }
                    //Lalit - 07-Dec-2016 : Salesforce-125 : Zero BU Price moving to Price Complete
                    //Added the condition for the HybridUser also.
                    //Ashish N - 17-July-2016 : SALESFORCE-243 : During escalation a 0 price is still able to be approved.
          //First replaced 'restrictBUApproval' with 'invalidBUPrice' and later consolidated the condition to less complex formula below.
                    //showApprovalButton = ((isUnderApproval && manualEntryVerified && !hasAmkorSelected && !invalidBUPrice) || (getIsSalesView() && !restrictBUApproval) || (getIsBUView() && !invalidBUPrice));
                    showApprovalButton = (!invalidBUPrice && ( (isUnderApproval && manualEntryVerified && !hasAmkorSelected) || getIsSalesView() || getIsBUView() ));
                    system.debug('showApprovalButton : '+showApprovalButton);
                } //else {
                    //addError('Either the RFQ Item is in \'' + 'Sales Requires Pre-Approval\'' + ' status or You are not a BU User or a Hybrid User as per the configuaration in RFQ System Settings.');
                    //showApprovalButton = false;
                //}
                System.debug('--->RFQProcessInstanceController, info : ' + info);
            }
        }
        else {
            addError('This item is not under approval');
            isUnderApproval = false;
            showApprovalButton = false;
        }
        
        System.debug('--->RFQProcessInstanceController, isUnderApproval : ' + isUnderApproval);
        System.debug('--->RFQProcessInstanceController, manualEntryVerified : ' + manualEntryVerified);
        System.debug('--->RFQProcessInstanceController, hasAmkorSelected : ' + hasAmkorSelected);
        System.debug('--->RFQProcessInstanceController, invalidBUPrice : ' + invalidBUPrice);
        System.debug('--->RFQProcessInstanceController, getIsSalesView : ' + getIsSalesView());
        System.debug('--->RFQProcessInstanceController, getisBUView : ' + getisBUView());
        System.debug('--->RFQProcessInstanceController, IsNoBidPossible : ' + getIsNoBidPossible());

        System.debug('--->RFQProcessInstanceController, showApprovalButton : ' + showApprovalButton);
        System.debug('--->RFQProcessInstanceController, getIsSalesApprove() : ' + getIsSalesApprove());
        System.debug('--->RFQProcessInstanceController, RFQSystemSettings.getIsBUUser() : ' + RFQSystemSettings.getIsBUUser());
        System.debug('--->RFQProcessInstanceController, RFQSystemSettings.getIsHybridUser() : ' + RFQSystemSettings.getIsHybridUser());
    }

    public Boolean getIsNoBidPossible() {
        if(isRFQItem) {
            return isUnderApproval && wrapper.rfqItem.Status__c == RFQItemDao.STATUS_PRICE_PENDING_BU;
        }
        return false;
    }

    public PageReference approveItem() {
        if (!updateApprovalComments()) return null;

        if (!checkCommentLength()) return null;

        if (isRFQItem) {
            // Removed this condition as per AMK-1327, we should update price to customer
            // On pricing escalation as well
            //if (wrapper.rfqItem.Price_To_Customer__c == null || wrapper.rfqItem.Price_To_Customer__c == 0) {
            wrapper.copyBuPriceToCustomerPrice();


            try
            {
                if (!RFQItemDao.getInstance().saveLineItem(wrapper)) return null;
                wrapper = RFQItemDao.getInstance().getWrapperById(wrapper.rfqItem.Id);

                CPN cpn = CPNDao.getInstance().getCPN(wrapper);
                wrapper.rfqItem.Configured_Part_Number__c = cpn.cpnId;            
                if (!RFQItemDao.getInstance().saveLineItem(wrapper)) return null;
            } 
            catch (System.Dmlexception e)
            {
                if(e.getDmlType(0)==StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION)
                {
                    addError(e.getDmlMessage(0));
                    return null;
                }
                else if(e.getDmlType(0)==StatusCode.ENTITY_IS_LOCKED)
                {
                    addError(System.label.RFQ_ERR_0007);
                    return null;
                }
                else
                {
                    throw e;
                }
            }
        }
        //Update item status before approving the record because approver might not be in the next queue which would prevent them from editing the item
        if(getIsSalesApprove()) {
   
            wrapper.rfqItem.Status__c = RFQItemdao.STATUS_PRICE_PENDING_BU;
            update wrapper.rfqitem;
        }
        ApprovalUtils.approveRecord(workItem.Id,approvalComments);
        //Do creation of cloned items here, sales should not create these items though
       if (!getIsSalesApprove())
        {
            if(wrapper.volumeList != null && wrapper.volumeList.size() > 0 && !getIsEscalation()) {
                        String status = [select Status__c from RFQ_Item__c where Id =: wrapper.rfqItem.Id].Status__c;
                        if(status == RFQItemDao.STATUS_PRICE_COMPLETE) {
                            PageReference pg = new PageReference('/apex/RFQICreateVolumeClone');
                            pg.getParameters().put('rfqId',wrapper.rfqItem.Id);
                            pg.getParameters().put('completeAction',cancelURL);
                            return pg;
                        }
                    }
        }

        return new PageReference(isClone ? actionUrl : cancelURL);
    }
    

    //AMK-559
    public PageReference noBid() {
        if (!updateApprovalComments()) return null;

        if (!checkCommentLength()) return null;

        if(!validateComment()) return null;

        if (isRFQItem) {
            
            ApprovalUtils.rejectRecord(workItem.Id,approvalComments);
            wrapper.setRejectedState();


            wrapper.rfqItem.Status__c = RFQItemDao.STATUS_NO_BID;


            if (!RFQItemDao.getInstance().saveLineItem(wrapper)) return null;
        }
        return new PageReference(isClone ? actionUrl : cancelURL);
    }

    public PageReference rejectItem() {
        if (!updateApprovalComments()) return null;

        if (!checkCommentLength()) return null;

        if(!validateComment()) return null;
        ApprovalUtils.rejectRecord(workItem.Id,approvalComments);
        if (isRFQItem) {
            //clearPricesForreject only does stuff for non-escalations
            wrapper.setRejectedState();

            if (!RFQItemDao.getInstance().saveLineItem(wrapper)) return null;
        }
        return new PageReference(isClone ? actionUrl : cancelURL);
    }

    public PageReference cancelApproval() {
        return new PageReference(cancelURL);
    }

    public Boolean getIsSalesApprove()
    {
        return wrapper == null || wrapper.rfqItem.Status__c == RFQItemDao.STATUS_SALES_REQ_PREAPPROVAL;
    }

    public Boolean getIsSalesUser()
    {
        return !RFQSystemSettings.getIsBUUser();
    }

    public Boolean getIsSalesView()
    {
        System.debug('--->RFQProcessInstanceController, getIsSalesApprove() : ' + getIsSalesApprove());
        System.debug('--->RFQProcessInstanceController, getIsSalesUser() : ' + getIsSalesUser());
        return getIsSalesApprove() == getIsSalesUser();
    }

    public Boolean getIsBUView()
    {
        return !getIsSalesApprove() && (RFQSystemSettings.getIsBUUser() || RFQSystemSettings.getIsHybridUser());
    }
    
    private Boolean validateComment() {
        if(StringUtils.isEmpty(approvalComments)) {
            addError('Comments required for rejecting an item');
            return false;
        }
        else return true;    
    }

    public Boolean getIsPerTime()
    {
        String testUOM = (String)wrapper.specificRfqItem.get('Test_Quote_Unit_of_Measure__c');
        return CreateRFQItemController.testTimeUOMs.contains(testUOM);
    }

    public Boolean copyParentPricesToVolumes()
    {
        
        if (wrapper.packageFamily.Name == AMKVARS.PF_TEST)
        {
            String testUOM = (String)wrapper.specificRfqItem.get('Test_Quote_Unit_of_Measure__c');
            String testType = (String)wrapper.specificRfqItem.get('Test_Type__c');
            return CreateRFQItemController.testTimeUOMs.contains(testUOM) || testType == AMKVARS.TT_POST;
        }
        return false;
    }

    public Boolean getIsEscalation()
    {
        if (wrapper == null) return false;
        return RFQItemDao.getInstance().statusGreaterOrEqual(wrapper.rfqItem, RFQItemDao.STATUS_PRICE_ESCALATION);
    }

    public Boolean updateApprovalComments()
    {
        //if not escalation, then its valid
        if (getIsEscalation())
        {
            if (String.isBlank(execConcurrence))
            {
                addError(execConcurrenceLabel + ': Value is required');
                execConcurrence = UserInfo.getName();
                return false;
            }
            else
            {
                String tempString = execConcurrenceLabel + ' - ' +  execConcurrence;
                approvalComments = String.isBlank(approvalComments) ? tempString : approvalComments + '\n' + tempString;
                return true;
            }
        }
        else return true;
    }

    public Boolean checkCommentLength()
    {
        Boolean valid = approvalComments.length() <= 4000;
        if (!valid) addError('Maximum comment size (including Highest BU Concurrence) is 4000 characters. Please enter a smaller comment.');

        return valid;
    }
}