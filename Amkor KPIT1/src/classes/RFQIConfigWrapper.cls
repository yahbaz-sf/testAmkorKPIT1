public with sharing class RFQIConfigWrapper {
	
	public Integer index {get; set;}
	public sObject conf {get; set;}

	public RFQIConfigWrapper(Integer index, sObject conf) {
		this.index = index;
		this.conf = conf;
	}
}