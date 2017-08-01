public class RFQItemHolder {
	public RFQ_Item__c item { get; set; }
	public Boolean selected { get; set; }
	public String approvalComment { get; set; }

	public RFQItemHolder(RFQ_Item__c item) {
		this.item = item;
		this.selected = false;
		this.approvalComment = '';
	}


	public static List<RFQ_Item__c> getItemList(List<RFQItemHolder> holderList) {
		List<RFQ_Item__c> result = new List<RFQ_Item__c>();

		for (RFQItemHolder holder : holderList) {
			result.add(holder.item);
		}

		return result;
	}
}