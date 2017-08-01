/*************************************************************************
*
* PURPOSE: 
*
* CLASS: 
* CREATED: 5/13/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
public abstract class CMPBGABuilder extends CMBuilder
{
	private RFQI_PBGA__c sItem;
	private RFQIWC_PBGA__c wireConfig;
	private Map<String, Decimal> costModelResults;

	public CMPBGABuilder()
	{
		bridge = new CMPBGABridge();
	}

	

	
	public override void loadSettings(RFQItemWrapper itemWrapper, Boolean isReloaded){
		itemWrapper.specificRfqItem.put('LGP_Market_Price__c', itemWrapper.productGroup.Au_Cost__c);

		RFQ_Item__c gItem = (RFQ_Item__c)itemWrapper.specificRfqItem.getSObject('RFQ_Item__r');
		itemWrapper.specificRfqItem.put('Base_Customer_Au_Price__c', gItem.RFQ__r.SBU_Name__r.Customer_AU_Base_fml__c);
		if (itemWrapper.specificRfqItem.get('Base_Customer_Au_Price__c') == null || itemWrapper.specificRfqItem.get('Base_Customer_Au_Price__c') == 0) itemWrapper.specificRfqItem.put('Base_Customer_Au_Price__c', 525);
		
		//load attributes
		List<String> attributes = new List<String> ();
		attributes.add('Assembly__c');
		//attributes.add('Base_Customer_Au_Price__c');

		List<String> pfAttributes = new List<String>();
		pfAttributes.add('Assembly_GM_wo_Substrate__c');
		//pfAttributes.add('Base_Customer_Au_Price__c');

		super.loadSettingsByPFAttributes(itemWrapper, isReloaded, attributes, pfAttributes);		
		
	}
	
	public void costModelTestMapInstall(){
		costModelResults = new Map<String, Decimal>();
	}



	protected override void calcCostModel(RFQItemWrapper itemWrapper){		
				
		sItem = (RFQI_PBGA__c)itemWrapper.specificRfqItem;
		
		if (itemWrapper.wireConfigurations != null && itemWrapper.wireConfigurations.size() > 0)
		{
			wireConfig = (RFQIWC_PBGA__c)itemWrapper.wireConfigurations[0];
			
		}
		else
		{
			wireConfig = new RFQIWC_PBGA__c();
		}
		
		Factory__c factory = new Factory__c(name='Unknown');		
		if (sItem.Factory__c != null) factory = [Select id, name From Factory__c where id=:sItem.Factory__c];
		
		//---Attributes
		Decimal costModel_D7 = getDecimal(sItem, 'Body_Size__c', 0); 		
		Decimal costModel_D8 = getDecimal(sItem, 'Ball_Count__c', 0);//sItem.Ball_Count__c;
		String costModel_D9 =  sItem.Mold_Process_Type__c;		
		String costModel_D10 = factory.name;
		Boolean costModel_D11 = sItem.Heatspreader__c;
		Decimal costModel_D14 = getDecimal(sItem, 'Capacity_UE_Rate__c', 0);//sItem.Capacity_UE_Rate__c;	
		String costModel_D15 = String.valueOf(wireConfig.Wire_Material__c);
		Decimal costModel_D16 = getDecimal(wireConfig, 'Number_Of_Wires__c', 0);//wireConfig.Number_Of_Wires__c;
		Decimal costModel_D17 = getDecimal(sItem, 'LGP_Market_Price__c', 0);//sItem.LGP_Market_Price__c;	
		Decimal costModel_D18 = getDecimal(sItem, 'Base_Customer_Au_Price__c', 0);//sItem.Base_Customer_Au_Price__c;	
		Boolean costModel_D20 = sItem.Apply_3D_Factor__c;	
		Decimal costModel_D22 = getDecimal(wireConfig, 'Wire_Diameter__c', 0);//(wireConfig.Wire_Diameter__c == null) ? 0 : Decimal.valueOf(wireConfig.Wire_Diameter__c);
		Decimal costModel_D23 = getDecimal(sItem, 'Number_of_Chips_per_Package__c', 0);//sItem.Number_of_Chips_per_Package__c;
		Decimal costModel_D24 = getDecimal(sItem, 'Complex_Adder__c', 0);//sItem.Complex_Adder__c;			
		String costModel_D25 = sItem.Mold_Type__c;
		Decimal costModel_D26 = getDecimal(sItem, 'Mold_Wastage__c', 0);//sItem.Mold_Wastage__c;			
		Decimal costModel_D28 = getDecimal(sItem, 'Substrate_Perc_Markup__c', 0)/100.0;//sItem.Substrate_Perc_Markup__c;
		Decimal costModel_I12 = getDecimal(sItem, 'Materials_Substrate__c', 0.0);
		
		Decimal s2d3d_F19 = getDecimal(wireConfig, 'Total_2D_Wire_Length__c', 0);//wireConfig.Total_2D_Wire_Length__c; 	//mm
		Decimal s2d3d_E26 = getDecimal(wireConfig, 'Total_3D_Wire_Length__c', 0);//wireConfig.Total_3D_Wire_Length__c;	//mm	TODO, PROTECT FROM NULL OR ZERO
		
		//---Constants
		Decimal moldAdder_D4 = 15;								//STD $/kg
		Decimal moldAdder_D5 = 30;								//LowAlpha $/kg
		Decimal moldAdder_D6 = 80;								//ThermalEMC $/kg
		Decimal auPCC_Q12 = 0.00664618715669629;					//PCC forming gas adder
		Decimal auPCC_O9 = 1.012;								//Au Usage Rate
		Decimal auPCC_P9 = 0.999;								//Au Cum Yield
		Decimal auPCC_O11 = 1.063;								//PCC Usage Rate
		Decimal auPCC_P11 = 0.999;								//PCC Cum Yield
		
		//---Calculations // To do test here
		
		
		Decimal petsa = 1.00;		
		Decimal s2d3d_I27 = s2d3d_E26/10/2.54/12;		
		Decimal s2d3d_E27 = (costModel_D16 == 0) ? 0 : s2d3d_E26/costModel_D16;
						
		Decimal costModel_Y8 = 0.000173*costModel_D16+0.0036;
		 
	
		Decimal pgSavings_D10 = forecastPGSavingsMold(costModel_D7)*0.25;
		Decimal pgSavings_C10 = forecastPGSavingsEMC(costModel_D7)*0.45;	
		Decimal costModel_Y9 = (-8.00*Decimal.valueOf(Math.pow(10,-6))*Decimal.valueOf(Math.pow(Double.valueOf(costModel_D7),3))+0.0011*Decimal.valueOf(Math.pow(Double.valueOf(costModel_D7),2))-0.0272*costModel_D7+0.417691007811971)*(costModel_D9 == 'PGM' ? 1.00+pgSavings_D10 : 1.00);		
		Decimal costModel_Y10 = costModel_Y8+costModel_Y9;
		Decimal hsCalc_B22 = lookupHsCalcHSU(costModel_D7);	
		Decimal odmCalc_B27 = 0.0006*Decimal.valueOf(Math.pow(Double.valueOf(costModel_D7),Double.valueOf(1.5924))) * (costModel_D9 == 'PGM' ? 1+pgSavings_C10 : 1);
		Decimal auPCC_M11 = lookupPCCCostFt(costModel_D22);
		Decimal auPCC_M9 = lookupAuCostFt(costModel_D22, costModel_D17);
		Decimal auPCC_N9 = s2d3d_I27 * (costModel_D20 ? 1 : (s2d3d_E26 == 0 )? 0 : s2d3d_F19/s2d3d_E26);
		Decimal auPCC_N11 = auPCC_N9;
		Decimal auPCC_Q9 = auPCC_P9 == 0 ? 0 : auPCC_M9*auPCC_N9*auPCC_O9/auPCC_P9;
		Decimal auPCC_Q11 = auPCC_P11 == 0 ? 0 : auPCC_M11*auPCC_N11*auPCC_O11/auPCC_P11;
		Decimal labor_H24 = 0.0002*Decimal.valueof(Math.pow(Double.valueOf(costModel_D7),2))-0.0023*costModel_D7+0.1412;
		Decimal labor_H35 = costModel_Y8;
		Decimal labor_H36 = costModel_Y9;
		Decimal labor_H37 = costModel_Y10;
		Decimal labor_I32 = lookupLaborK4Multiplier(costModel_D10);
		Decimal labor_J30 = labor_H24;
		Decimal labor_I35 = labor_H37 == 0 ? 0: labor_H35/labor_H37*labor_J30;
		Decimal labor_I36 = labor_J30-labor_I35;
		Decimal labor_I37 = labor_I35+labor_I36;
		Decimal labor_J35 = labor_I35*labor_I32;
		Decimal labor_J36 = labor_I36*labor_I32;
		Decimal labor_J37 = labor_I37*labor_I32;
		Decimal labor_K35 = labor_H35-labor_I35+labor_J35;
		Decimal labor_K36 = labor_H36-labor_I36+labor_J36;						
		Decimal moldAdder_B1 = lookupMoldAdderGramsUnit(costModel_D7);
		Decimal moldAdder_C9 = ((costModel_D11 ? hsCalc_B22+odmCalc_B27 : odmCalc_B27)*1.04*1.02)*petsa;		
		Decimal moldAdder_C4 = moldAdder_B1/1000;
		Decimal moldAdder_E4 = moldAdder_C4*moldAdder_D4;
		Decimal moldAdder_F4 = moldAdder_E4;
		Decimal moldAdder_C10 = moldAdder_E4;
		Decimal moldAdder_C5 = moldAdder_C4;
		Decimal moldAdder_C6 = moldAdder_C5;
		Decimal moldAdder_E5 = moldAdder_C5*moldAdder_D5;
		Decimal moldAdder_F5 = moldAdder_E5*(1+costModel_D26);
		Decimal moldAdder_E6 = moldAdder_C6*moldAdder_D6;
		Decimal moldAdder_F6 = moldAdder_E6*(1+costModel_D26);
		Decimal moldAdder_C11 = moldAdder_C9-moldAdder_C10;		
		Decimal moldAdder_F7 = (costModel_D25 == 'Standard' ? moldAdder_F4 : 0 ) + (costModel_D25 == 'LowAlpha' ? moldAdder_F5 : 0 ) + (costModel_D25 == 'ThermalEMC' ? moldAdder_F6 : 0 );
		Decimal s2d3d_F30 = s2d3d_I27*lookupAuTroyOzKft(costModel_D22);
		Decimal costModel_I6 = s2d3d_E27*petsa;
		Decimal costModel_I7 = s2d3d_E26*petsa;
		Decimal costModel_I8 = (costModel_D15 == 'Au' ? s2d3d_F30 : 0) * petsa;
		Decimal costModel_I9 = (costModel_D17-costModel_D18)*costModel_I8/1000*petsa;
		Decimal costModel_I13 = (costModel_D15 == 'Au' ? auPCC_Q9 : auPCC_Q11+auPCC_Q12) *1.04*1.02*petsa;
		Decimal costModel_I14 = moldAdder_C11;
		Decimal costModel_I15 = moldAdder_F7;
		Decimal costModel_I16 = costModel_I12+costModel_I13+costModel_I14+costModel_I15;
		Decimal costModel_I18 = ( costModel_D14 == 0 ? 0 : labor_K35*(0.75/costModel_D14) ) * (costModel_D15 == 'Au' ? 1 : (1/0.95))*petsa;
		Decimal costModel_I19 = ( costModel_D14 == 0 ? 0 : labor_K36*(0.75/costModel_D14) )* (costModel_D11 ? 1 : 0.85) * (costModel_D23 > 1 ? (costModel_D23-1.00)*1.9 : 1.00) * (1+costModel_D24)*petsa;				
		Decimal costModel_I20 = costModel_I18+costModel_I19;
		Decimal costModel_I22 = costModel_I16+costModel_I20;

		//System.debug(LoggingLevel.ERROR, '###### wire Material: ' + costModel_D15 );
		//System.debug(LoggingLevel.ERROR, '###### Materials_Wire__c: ' + costModel_I13 );
		//System.debug(LoggingLevel.ERROR, '###### Materials_ODM_Other__c: ' + costModel_I14 );
		
		
		//---Write back variables
		wireConfig.Au_Factor__c = costModel_I8;
		sItem.Au_Factor__c = costModel_I8;				
		sItem.Materials_Wire__c = costModel_I13;
		sItem.Materials_ODM_Other__c = costModel_I14;		
		sItem.Materials_ODM_Mold__c = costModel_I15;
		sItem.Total_ODM__c = costModel_I13 + costModel_I14 + costModel_I15;
		sItem.CLAM_WB__c = costModel_I18;
		sItem.CLAM_Others__c = costModel_I19;
		sItem.CLAM_Total__c = costModel_I18 + costModel_I19;

		//put results into the costModel map
		if(costModelResults != null){
			costModelResults.put('costModel_I6', costModel_I6);
			costModelResults.put('costModel_I7', costModel_I7);
			costModelResults.put('costModel_I8', costModel_I8);
			costModelResults.put('costModel_I9', costModel_I9);
			costModelResults.put('costModel_I12', costModel_I12);
			costModelResults.put('costModel_I13', costModel_I13);
			costModelResults.put('costModel_I14', costModel_I14);
			costModelResults.put('costModel_I15', costModel_I15);			
			costModelResults.put('costModel_I18', costModel_I18);
			costModelResults.put('costModel_I19', costModel_I19);								
		}

		//update sItem;

	}

	protected override void calcResults(RFQItemWrapper itemWrapper, Boolean runCostModel){
		
		System.debug(LoggingLevel.ERROR, '##### runCostModel: ' + runCostModel);
		//check if it needs to run cost model or not
		
		if(sItem == null){		
		 	sItem = (RFQI_PBGA__c)itemWrapper.specificRfqItem;
		}

		//Check if there is any values for required fields
		//To Do: have more robust validation check

		Decimal petsa = 1.00;

		//Material
		Decimal materialSubstrate = getDecimal(itemWrapper.specificRfqItem, 'Materials_Substrate__c', 0.0);
		Decimal materialODM = getDecimal(itemWrapper.specificRfqItem, 'Total_ODM__c', 0.0);

		Decimal materialSubtotal = materialSubstrate + materialODM;

		//CLAM
		Decimal clamSubtotal = getDecimal(itemWrapper.specificRfqItem, 'CLAM_Total__c', 0.0);
		

		//Total Cost
		Decimal others = getDecimal(itemWrapper.specificRfqItem, 'Others_Cost__c', 0.0);
		Decimal totalCost = materialSubtotal + clamSubtotal + others;
		sItem.Total_Cost_with_Substrate_New__c = totalCost;
		
		Decimal	buPrice = getDecimal(itemWrapper.specificRfqItem, 'BU_Price__c', 0);
		Decimal customerPrice = (sItem.Price_To_Customer__c == null) ? 0 : (Decimal) sItem.Price_To_Customer__c;
		if(customerPrice < buPrice)
			sItem.Price_To_Customer__c = buPrice;
        else
        	sItem.Price_To_Customer__c = customerPrice;	

		Decimal totalGM = buPrice == 0 ? 0 : (buPrice - totalCost) / (buPrice);
		sItem.BU_Price_Perc_GM__c= totalGM * 100.0;

		Decimal percCM = buPrice == 0 ? 0 : (buPrice - ((1-0.75) * (clamSubtotal + others) + materialSubtotal ))/ buPrice * 100.0;		
		sItem.Perc_CM__c = percCM;

    	//------------------This part is for IRR ------------------------------------//
    	CMPBGAIRRCalc IRRCalc = new CMPBGAIRRCalc();	
    	calculateIRR(sItem, IRRCalc, materialSubtotal, clamSubtotal, others, buPrice);

		//-----------------End IRR------------------------------------//

    	itemWrapper.clearPriceToCustomerIfRequired();
	
		//put results into the costModel map
		if(costModelResults != null){
			
			costModelResults.put('costModel_I16', materialSubtotal);
			costModelResults.put('costModel_I20', clamSubtotal);
			costModelResults.put('costModel_I22', totalCost);
			costModelResults.put('costModel_I26', totalGM);
			costModelResults.put('costModel_I29', percCM);
			costModelResults.put('costModel_I27', sItem.Perc_IRR_New__c);
			costModelResults.put('costModel_I28', sItem.Operating_Cash_u__c );
		}
	}

	private Decimal calculateIRR(RFQI_PBGA__c sItem, CMPBGAIRRCalc IRRCalc, Decimal materialSubtotal, Decimal clamSubtotal, Decimal othersCost, Decimal buPrice){

		Decimal costModel_D14 = getDecimal(sItem, 'Capacity_UE_Rate__c', 0);//sItem.Capacity_UE_Rate__c;	
    	Decimal costModel_D7 = getDecimal(sItem, 'Body_Size__c', 0); 		
    	Decimal labor_H24 = 0.0002*Decimal.valueof(Math.pow(Double.valueOf(costModel_D7),2))-0.0023*costModel_D7+0.1412;
    	Decimal labor_J30 = labor_H24;
    	Decimal pgSavings_D10 = forecastPGSavingsMold(costModel_D7)*0.25;
    	Decimal costModel_D16 = getDecimal(wireConfig, 'Number_Of_Wires__c', 0);//wireConfig.Number_Of_Wires__c;
    	Decimal costModel_Y8 = 0.000173*costModel_D16+0.0036;
    	String costModel_D9 =  sItem.Mold_Process_Type__c;		
    	Decimal costModel_Y9 = (-8.00*Decimal.valueOf(Math.pow(10,-6))*Decimal.valueOf(Math.pow(Double.valueOf(costModel_D7),3))+0.0011*Decimal.valueOf(Math.pow(Double.valueOf(costModel_D7),2))-0.0272*costModel_D7+0.417691007811971)*(costModel_D9 == 'PGM' ? 1.00+pgSavings_D10 : 1.00);		
    	Decimal costModel_Y10 = costModel_Y8+costModel_Y9;
    	Decimal labor_H37 = costModel_Y10;
    	Decimal labor_H35 = costModel_Y8;
    	Decimal labor_I35 = labor_H37 == 0 ? 0: labor_H35/labor_H37*labor_J30;        
    	Decimal labor_I36 = labor_J30-labor_I35;
    	Decimal labor_I37 = labor_I35+labor_I36;
    	Factory__c factory = [Select id, Name From Factory__c where id=:sItem.Factory__c];
    	Decimal labor_I32 = lookupLaborK4Multiplier(factory.Name);
    	Decimal labor_J37 = labor_I37*labor_I32;
    	//Project year is 7 here, IRR must be calcualte with cost model because it needs labor_J37
    	Decimal costModel_I27 = 0;
    	Decimal costModel_I28 = 0;
    	if (buPrice != 0) costModel_I27 = IRRCalc.calculate(7, factory.Name, costModel_D14/0.75*2100, materialSubtotal, clamSubtotal + othersCost, buPrice , labor_J37, 1.75 * (costModel_D14/0.75*2100) * 13 * -1)*100.0;
    	if (buPrice != 0) costModel_I28 = (buPrice-(materialSubtotal + clamSubtotal + othersCost)) + IRRCalc.IRR_E18;
    	
    	sItem.Perc_IRR_New__c = costModel_I27;
		sItem.Operating_Cash_u__c = costModel_I28;
		return costModel_I27;
	}

	public Map<String, Decimal> getCostModelResults(){
		return costModelResults;
	}
	
	private void logResult(String name, Decimal resultVal)
	{
		debugList.add( new CMDebug(name + ' = ' + resultVal));
	}
	
	private Decimal forecastPGSavingsMold(Decimal bodySize)
	{
		return 0.00260899181062211*bodySize -0.0734486330711606;
		//return 0.002608992*bodySize -0.7234486;
	}
	
	private Decimal forecastPGSavingsEMC(Decimal bodySize)
	{
		return 0.00151140754918023*bodySize -0.039141101507398;
		//return 0.001511408*bodySize -0.039141102;
	}
	
	//To Do: Check LookupHsCalcHSU
	private Decimal lookupHsCalcHSU(Decimal bodySize)
	{
		Map<String, Decimal> valueMap = new Map<String, Decimal>();
		valueMap.put('17.0', 0.147811554703645);
		valueMap.put('23.0', 0.155010607351216);
		valueMap.put('27.0', 0.145780152339762);
		valueMap.put('31.0', 0.178249205979321);
		valueMap.put('35.0', 0.183451495326438);
		valueMap.put('37.5', 0.300983282480551);
		valueMap.put('40.0', 0.310902493411717);
		Decimal a14 = 17.00;
		Decimal defaultVal = 3*Decimal.valueOf(Math.pow(10,-5))*Decimal.valueOf(Math.pow(Double.valueOf(a14),3))-0.0018*Decimal.valueOf(Math.pow(Double.valueOf(a14),2))+0.0389*a14-0.199775032534109;
		
		Decimal lookupVal = valueMap.get(getKeyFromDecimal(bodySize));
		return lookupVal == null ? defaultVal : lookupVal;
	}
	
	private Decimal lookupPCCCostFt(Decimal wireDiameter)
	{
		Map<String, Decimal> valueMap = new Map<String, Decimal>();
		valueMap.put('0.5', 0.0);
		valueMap.put('0.6', 0.0);
		valueMap.put('0.7', 0.02134);
		valueMap.put('0.8', 0.01829);
		valueMap.put('0.9', 0.01829);
		valueMap.put('1.0', 0.01829);
		valueMap.put('1.1', 0.01829);
		valueMap.put('1.2', 0.01829);
		valueMap.put('1.3', 0.02134);
		valueMap.put('1.5', 0.02134);
		valueMap.put('2.0', 0.02743);
		
		Decimal lookupVal = valueMap.get(getKeyFromDecimal(wireDiameter));
		return lookupVal == null ? 0 : lookupVal;
	}
	
	private Decimal lookupAuCostFt(Decimal wireDiameter, Decimal auMarketPrice)
	{
		Map<String, Decimal> valueMap = new Map<String, Decimal>();
		valueMap.put('0.5', 0.023985);
		valueMap.put('0.6', 0.0345399054397398);
		valueMap.put('0.7', 0.0470126490707569);
		valueMap.put('0.8', 0.0614042763373152);
		valueMap.put('0.9', 0.0777147872394145);
		valueMap.put('1.0', 0.095944181777055);
		valueMap.put('1.1', 0.116092459950237);
		valueMap.put('1.2', 0.138159621758959);
		valueMap.put('1.3', 0.162145667203223);
		valueMap.put('1.5', 0.215874408998374);
		valueMap.put('2.0', 0.38377672710822);
		
		String key = getKeyFromDecimal(wireDiameter);
		
		Decimal lookupVal = valueMap.get(key);
		lookupVal = lookupVal == null ? 0 : lookupVal;
		
		
		Decimal mfCost = 2.8;
		if (key == '0.5' || key == '0.6')
		{
			mfCost = 4.8;
		}
		else if (key == '0.7')
		{
			mfCost = 3.0;
		}
		
		return (auMarketPrice * lookupVal + mfCost)/1000;
	}
	
	private Decimal lookupLaborK4Multiplier(String factory)
	{
		Map<String, Decimal> valueMap = new Map<String, Decimal>();
		valueMap.put('C3', 0.287731790680409);
		valueMap.put('K4', 1);
		valueMap.put('P3', 0.513319360680824);
	
		Decimal lookupVal = valueMap.get(factory);
		return lookupVal == null ? 0 : lookupVal;
	}
	
	private Decimal lookupMoldAdderGramsUnit(Decimal bodySize)
	{
		Map<String, Decimal> valueMap = new Map<String, Decimal>();
		valueMap.put('17.0', 0.8295);
		valueMap.put('19.0', 1.39);
		valueMap.put('23.0', 1.64);
		valueMap.put('27.0', 3.05);
		valueMap.put('29.0', 3.1965);
		valueMap.put('31.0', 3.55);
		valueMap.put('35.0', 4.38);
		valueMap.put('37.5', 4.873125);
		valueMap.put('40.0', 5.36625);

		Decimal lookupVal = valueMap.get(getKeyFromDecimal(bodySize));
		
		if (lookupVal != null && lookupVal > 0) return lookupVal;
		
		return 0.19725*bodySize -2.52375;
	}
	
	private String getKeyFromDouble(Double doubleVal)
	{
		Decimal tempVal = (doubleVal == null) ? 0 : Decimal.valueOf(doubleVal);
		return tempVal.setScale(1).toPlainString();
	}
	
	private String getKeyFromDecimal(Decimal decimalValue)
	{
		//Decimal tempVal = (doubleVal == null) ? 0 : Decimal.valueOf(doubleVal);
		return decimalValue.setScale(1).toPlainString();
	}
	
	private Decimal lookupAuTroyOzKft(Decimal wireDiameter)
	{
		Map<String, Decimal> valueMap = new Map<String, Decimal>();
		valueMap.put('0.5', 0.023985);
		valueMap.put('0.6', 0.0345399054397398);
		valueMap.put('0.7', 0.0470126490707569);
		valueMap.put('0.8', 0.0614042763373152);
		valueMap.put('0.9', 0.0777147872394145);
		valueMap.put('1.0', 0.095944181777055);
		valueMap.put('1.1', 0.116092459950237);
		valueMap.put('1.2', 0.138159621758959);
		valueMap.put('1.3', 0.162145667203223);
		valueMap.put('1.5', 0.215874408998374);
		valueMap.put('2.0', 0.38377672710822);

		Decimal lookupVal = valueMap.get(getKeyFromDecimal(wireDiameter));
		return lookupVal == null ? 0 : lookupVal;
	}

	public override void onAttributeChange(RFQItemWrapper itemWrapper, String attributeName)
	{
		//---AMK-2263 removed the assembly gm, so bu price is the only thing that can trigger math

		Decimal buPrice = getDecimal(itemWrapper.specificRfqItem,'BU_Price__c',0);
		Decimal materialSubstrate = getDecimal(itemWrapper.specificRfqItem, 'Materials_Substrate__c', 0.0);
		Decimal totalODM = getDecimal(itemWrapper.specificRfqItem, 'Total_ODM__c', 0.0);

		Decimal materialSubtotal = materialSubstrate + totalODM;
		Decimal clamSubtotal = getDecimal(itemWrapper.specificRfqItem, 'CLAM_Total__c', 0.0);

		Decimal others = getDecimal(itemWrapper.specificRfqItem, 'Others_Cost__c', 0.0);
        Decimal totalCost = materialSubtotal + clamSubtotal + others;


		if(buPrice > 0) 
		{
		    Decimal totalGM = (buPrice - totalCost) / (buPrice);
		    itemWrapper.specificRfqItem.put('BU_Price_Perc_GM__c',totalGM * 100.0);
		}

		Decimal percCM = buPrice == 0 ? 0 : (buPrice - ((1-0.75) * (clamSubtotal + others) + materialSubtotal ))/ buPrice * 100.0;		
		itemWrapper.specificRfqItem.put('Perc_CM__c', percCM);
		itemWrapper.specificRfqItem.put('Total_Cost_with_Substrate_New__c', totalCost);
		
		CMPBGAIRRCalc IRRCalc = new CMPBGAIRRCalc();	
    	calculateIRR((RFQI_PBGA__c)itemWrapper.specificRfqItem, IRRCalc, materialSubtotal, clamSubtotal, others, buPrice);
	}
	

	public override void setEditabilityforNoCostModel(RFQILayout layout){

		layout.changeEditability('Total_Cost_with_Substrate_New__c',false);
		layout.changeEditability('BU_Price_Perc_GM__c',false);
		layout.changeEditability('Perc_IRR_New__c',false);
		layout.changeEditability('Perc_CM__c',false);
		layout.changeEditability('Operating_Cash_u__c',false);
		layout.changeEditability('Customer_Target_Price__c',false);
		layout.changeEditability('Sales_Target_Price__c',false);
		
	}

    public override Map<String, String> getFieldMap()
    {
    	Map<String, String> fieldMap = new Map<String, String>();

    	fieldMap.put('price', 'BU_Price__c');
    	fieldMap.put('margin', 'BU_Price_Perc_GM__c');
    	//fieldMap.put('subsMarkup', 'Substrate_Perc_Markup__c');
    	//fieldMap.put('marginNoSubstrate', 'Assembly__c');
    	fieldMap.put('totalCost', 'Total_Cost_with_Substrate_New__c');
    	fieldMap.put('subsCost', 'Materials_Substrate__c');
    	fieldMap.put('othersCost', 'Others_Cost__c');


		return fieldMap;
    }

}