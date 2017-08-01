public with sharing class RFQOpItemEditController extends RFQOpItemController{
	
	private String oppId;

	public RFQOpItemEditController(ApexPages.StandardController sc) {
        
        super(sc);
        oppId = getParam('oppId');
        if(StringUtils.isBlank(oppId)) oppId = wrapper.rfqItem.Opportunity__c;
    }

     public override virtual PageReference saveItemAsDraft() {
        if(!StringUtils.isBlank(oppId)) wrapper.rfqItem.Opportunity__c = oppId;
        super.saveItemAsDraft();
        return new PageReference('/apex/RFQOpItemView?id=' + wrapper.rfqItem.Id);
    }

    public override virtual PageReference cancelItem() {
        
        super.cancelItem();
        if(isNewItem) {
            return new PageReference('/' + oppId);
        }
        PageReference pg = new PageReference('/apex/RFQOpItemView?id=' + wrapper.rfqItem.Id);
        pg.setRedirect(true);
        return pg;
    }



}