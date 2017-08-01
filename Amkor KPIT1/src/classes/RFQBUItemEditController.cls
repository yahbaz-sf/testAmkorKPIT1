/*************************************************************************
*
* PURPOSE: BU Specific Controller for the RFQ Item view/edit page
* 
* CLASS: RFQBUItemEditController
* CREATED: 3/12/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/
public virtual with sharing class RFQBUItemEditController extends RFQItemEditController {
    public string fieldAPIName{get;set;}
	public RFQBUItemEditController(ApexPages.StandardController sc) {
        super(sc);
        
        getAutoCostErrors();
	}

	protected void disableAllEditabilityExcept(RFQILayoutSection section) {
        List<RFQISectionAttribute>  attributes = section.attributes;
        for (RFQISectionAttribute attribute : attributes) {  
            system.debug('at line number 20 inside the class RFQBUItemEditController' );
            system.debug('RFQBUItemEditController   attribute.fieldAPIName  :'+attribute.fieldAPIName );
            layout.changeEditability(attribute.fieldAPIName,false);

            if (attribute.fieldAPIName == 'Forecast__c')  {
                layout.changeEditability(attribute.fieldAPIName,true);
            }

            if (attribute.fieldAPIName == 'Annual_Volume__c' )  {
                layout.changeEditability(attribute.fieldAPIName,true);
            }
            if (attribute.fieldAPIName == 'Quote_Request_Type__c' )  {
                layout.changeEditability(attribute.fieldAPIName,true);
            }         
        }    
    }

    protected void enableAllEditability(RFQILayoutSection section, Set<String> fieldsToStayReadOnly) {
        if(section != null) {
            List<RFQISectionAttribute>  attributes = section.attributes;
            for(RFQISectionAttribute attribute : attributes){
                if(!fieldsToStayReadOnly.contains(attribute.fieldAPIName)) {
                    layout.changeEditability(attribute.fieldAPIName,true);
                }            
            }    
        } 
    }

    public virtual PageReference reCalculatePrice(RFQItemWrapper itemWrapper, Boolean isRerun) {              
        return setupCostModel(itemWrapper, false, isRerun);
    }

    public virtual PageReference reCalculatePrice(RFQItemWrapper itemWrapper){
        return reCalculatePrice(itemWrapper, false);
    }

    public virtual PageReference reCalculatePriceById(){
        Pagereference pg =  reCalculatePrice(wrapper);
        // Ashish - 10-Nov-2016 : Salesforce-107: Volume config RFQI's are not getting created and responded back to Sales
        // populate total cost in volume configs with total cost of RFQ item.
        system.debug('### fieldAPIName :::'+fieldAPIName);
        if(!CMBuilder.getHasSubstrate(wrapper) && wrapper.productGroup.Name == 'MLF' && fieldAPIName == 'Total_Cost__c' ){
            populateTotalCostinVolumeconfig();
        }
        return pg;
    }

    public virtual PageReference gotoStandardApprovalWizardAndClone() {
       PageReference pg = gotoStandardApprovalWizard();
       if(pg == null) return null;
       pg.getParameters().put('actionURL','/apex/RFQBUItemAttributeEdit?id='+wrapper.rfqItem.Id);
       return pg; 
    }

    public Boolean getShowRecalculateLink()
    {
        CMBuilder tempCMBuilder = new CMDefaultBuilder();
        Boolean returnVal = wrapper.packageFamily.No_Cost_Model__c || CMBuilder.getPfsWithNoSubstrate().contains(wrapper.packageFamily.Name);
        
        return returnVal;
    }

    
}