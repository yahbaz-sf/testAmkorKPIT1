public virtual with sharing class RFQOpItemController extends RFQItemEditController{
	
    public List<RFQISectionAttribute> attributes {get; set;}
   
	public RFQOpItemController(ApexPages.StandardController sc) {
		
        super(sc);
      
        attributes = new List<RFQISectionAttribute>();
       

        if(layout.sectionMap.get('Quote Information') != null)
            attributes.addAll(layout.sectionMap.get('Quote Information').attributes);
        
        if(layout.sectionMap.get('Package Description') != null)
            attributes.addAll(layout.sectionMap.get('Package Description').attributes);
        
        if(layout.sectionMap.get('Substrate Description') != null)
           attributes.addAll(layout.sectionMap.get('Substrate Description').attributes);
    }

    public virtual PageReference editItem() {

    	return new PageReference('/apex/RFQOpItemEdit?id='+wrapper.rfqItem.Id);
    }

    public PageReference addOppService() {
        String isSiP = (wrapper.rfqItem.SiP__c) ? '1' : '0';
        return new PageReference('/apex/RFQItemAddService?rfqItemId=' + wrapper.rfqItem.Id + '&OpportunityId=' + wrapper.rfqItem.Opportunity__c + '&SiP=' + isSiP);
    }



     //used to get only Sales sections
    protected virtual override RFQILayout getLayout(RFQItemWrapper itemWrapper){
        return PFFieldDefDao.getInstance().getMiniPackageFamilyLayout(itemWrapper.packageFamily.Id, itemWrapper.packageFamily.Layout_Version__c, itemWrapper.rfqItem.Layout_Version__c);
    }


}