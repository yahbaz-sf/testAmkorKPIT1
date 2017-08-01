/*************************************************************************
*
* PURPOSE: Dummy Cost Model when no cost model is specified for Package family and Product Group
*
* CLASS: CMDummyBuilder
* CREATED: 10/25/2016 KPIT

***************************************************************************/
public virtual with sharing class CMDummyBuilder extends CMBuilder
{
	public CMDummyBuilder()
	{
		bridge = new CMOthersBridge();
	}



	//To Do:
	public override void loadSettings(RFQItemWrapper itemWrapper, Boolean isReloaded){
		//setup(pWrapper);

	}

	public override void onAttributeChange(RFQItemWrapper itemWrapper, String attributeName){
		calcResults(itemWrapper, false);
        calcCostModel(itemWrapper);
	}
	
	public override void setEditabilityforNoCostModel(RFQILayout layout)
	{
		// blank
		
		
	
	}

	//To Do:
	protected override void calcCostModel(RFQItemWrapper itemWrapper){}



	protected override void calcResults(RFQItemWrapper itemWrapper, Boolean runCostModel)
	{

	}


	
}