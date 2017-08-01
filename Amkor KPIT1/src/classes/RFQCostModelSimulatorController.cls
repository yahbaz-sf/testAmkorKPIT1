public with sharing class RFQCostModelSimulatorController extends RFQBUItemAttributeEditController{
	
    public RFQCostModelSimulatorController(ApexPages.StandardController sc) {
	super(sc);
    } 
	
    public PageReference initPage(){

        costModelRunSettings.usePending = getParam('usePending') == '1' ;
        if(costModelRunSettings.usePending) {
            addInfo('Using Pending Version of Cost Model');
        }
	if(cloneItem==null){//only want a new cloneItem if we dont have a clone of original item already
 	    reloadClone();
	    setupCostModel(cloneItem);
	}
	return null;
    }
	
    public override PageReference resetPrice() { 

	if (!RFQItemDao.getInstance().saveLineItem(cloneItem)) return null;
	setupCostModel(cloneItem);
        if(costModelRunSettings.usePending) {
            addInfo('Using Pending Version of Cost Model');
        }
		return null;
    }
	
    public void deleteClone(){//called onunload if the user leaves without clicking Cancel
        if(cloneItem != null) RFQItemDao.getInstance().deleteLineItem(cloneItem);
    }
	
    public PageReference cancelSimulator() {
	if(cloneItem != null) RFQItemDao.getInstance().deleteLineItem(cloneItem);
	return new PageReference('/apex/RFQBUItemView?id='+wrapper.rfqItem.Id);
    }

    public PageReference usePendingSimulator() {	
	PageReference pg = new PageReference('/apex/RFQCostModelSimulator');
        pg.getParameters().put('id',wrapper.rfqItem.Id);
        pg.getParameters().put('usePending','1');
        pg.setRedirect(true);
        return pg;
    }

    public PageReference useActiveSimulator() {	
	PageReference pg = new PageReference('/apex/RFQCostModelSimulator');
        pg.getParameters().put('id',wrapper.rfqItem.Id);
        pg.getParameters().put('usePending','0');
        pg.setRedirect(true);
        return pg;
    }
}