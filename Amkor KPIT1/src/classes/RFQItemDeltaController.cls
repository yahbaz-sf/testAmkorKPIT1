/*************************************************************************
*
* PURPOSE: Controller for the RFQ Item Delta page
* 
* CLASS: RFQItemDeltaController
* CREATED: 9/17/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/
public with sharing class RFQItemDeltaController extends RFQItemController{

    public RFQItemWrapper other {get; set;}

    public RFQItemWrapper.RFQIDelta delta {get; set;}
    public List<PieWedgeData> data {get; set;}
    public String rfqiA {get; set;}
    public String rfqiB {get; set;}

    private Boolean isDefault;

	public RFQItemDeltaController(ApexPages.StandardController sc) {
		super(sc);
	}

	public void init() {
        isDefault = false;
        data = new List<PieWedgeData>();
        //if an 'otherId' is passed in we're comparing against
        //a counter proposal RFQI
		String otherId = getParam('otherId');
		if(otherId == null) {
			//if otherId is null then we should create a new RFQI wrapper
			//that doesn't point to an RFQ just so we can calculate defaults
			//we can then compare the current RFQI to the temp one with defaults
			//to see how many defaults Sales has changed
            isDefault = true;
            other = RFQItemDao.getInstance().createNewFromWrapper(wrapper);
            other.rfqItem.RFQ__c = null;
            RFQItemDao.getInstance().saveLineItem(other);
		}
		else {
            other = RFQItemDao.getInstance().getWrapperById(otherId);
		}
		  
        rfqiA = wrapper.rfqItem.Name;
        rfqiB = isDefault ? 'Default' : other.rfqItem.Name;

		delta = wrapper.compareRFQI(other);
		delta.removeNotInLayout(layout);

		data.add(new PieWedgeData('Similarities',delta.sames.size()));
		data.add(new PieWedgeData('Differences',delta.deltas.size()));
	}

	public PageReference backToItem() {
		
		if(isDefault){			
			if(!RFQItemDao.getInstance().deleteLineItem(other)){
                addError('There was a problem deleting the line item. Please try again.');
            }
		}
		return new PageReference('/apex/RFQItemView?id='+wrapper.rfqItem.Id); 
	}

	public class PieWedgeData {  
		public String name { get; set; }  
		public Decimal data { get; set; }  
		  
		public PieWedgeData(String name, Decimal data) {  
			this.name = name;  
	        this.data = data;  
		}  
	 }  
}