/*************************************************************************
* 
* PURPOSE: IRR calculation for PBGA product group. 
*          
* CLASS: CMPBGAIRRCalc
* CREATED: 07/03/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Chia Yuan Chuang
* 
**************************************************************************/

public with sharing class CMPBGAIRRCalc {
	
	

	//In order to calcualte IRR, we need to have cash flow. Based on the spreadsheet, we have 
	// total seven years of cash flow
	double LOW_RATE = 0.0;
	double HIGH_RATE = 1.0;
	Integer MAX_ITERATION = 1000;
	double PRECISION_REQ = 0.00001;
	Integer DEFAULT_PROJ_YEAR = 7;
	public Decimal IRR_E18{get; set;}
	
	public Decimal calculate(Integer proj_year, String factory, Decimal costModel_D14, Decimal costModel_I16, Decimal costModel_I20, Decimal costModel_I24 , Decimal labor_J37, Decimal D_6) {
		if(proj_year <= 0 || proj_year == null)
			proj_year = DEFAULT_PROJ_YEAR;
		DebugUtils debug = DebugUtils.getInstance();

		//DebugUtils.write('factory', factory, false);
		//DebugUtils.write('costModel_D14', costModel_D14, false);
		//DebugUtils.write('costModel_I16', costModel_I16, false);
		//DebugUtils.write('costModel_I20', costModel_I20, false);
		//DebugUtils.write('costModel_I24', costModel_I24, false);
		//DebugUtils.write('labor_J37', labor_J37, false);
		//DebugUtils.write('D_6', D_6, false);

		Decimal[] cashFlow = calcCashFlow(proj_year, factory, costModel_D14, costModel_I16, costModel_I20, costModel_I24 , labor_J37, D_6);

		//Integer testYear = 0;
		//for(Decimal cash : cashFlow){			
		//	debug.log('cash flow year ' + testYear, cash, false);
		//	testYear++;
		//}

		Decimal result = calculateIRR(cashFlow);
		return result;
		
		
	}


	Decimal[] calcCashFlow(Integer proj_year, String factory, Decimal costModel_D14, Decimal costModel_I16, Decimal costModel_I20, Decimal costModel_I24 , Decimal labor_J37, Decimal D_6){
		
		DebugUtils debug = DebugUtils.getInstance();
		// constant
		Decimal A_39 = 0.08;
		Decimal L_46 = 0.1;
		Decimal L_47 = 0.2;
		Decimal J_45 = 0.0; //ASP_red 
		Decimal J_46 = 0.0; //Cost_red 
		Decimal J_47;
		Decimal H_45 = 0.06; //Factory_SGA_Perc
		Decimal H_46 = 0.1; //Corporate_SGA_Perc
		//Integer Proj_year = proj_year;
		Integer AssemblyEquipmentLife = proj_year;

		 D_6 = (D_6 == null) ? 0 : D_6;
		

		//Initate annul cash flow
		Decimal[] E_41 = new Decimal[Proj_year + 1];		//E41  AnnualCashFlow
		
		//year 0				
		Decimal temp_E_9 = 	costModel_D14; 	//IncrementalVol		 
		Decimal D_14 =  costModel_I16;					//Material_UC
		Decimal D_15 =	labor_J37;						//Labor_UC 
		Decimal temp_E_18 = (temp_E_9 == 0) ? 0 : -1.0 * D_6 / (Decimal.valueOf(proj_year) * temp_E_9 * 52.0); //new depreciation		
		Decimal D_16 = 	costModel_I20 - D_15 - temp_E_18; // OCOGS_UC

		//write year 0
		E_41[0] = D_6;		


		//values in loop
		Decimal E_8 ;
		Decimal E_9 ;
		Decimal E_10;
		Decimal E_11_Prev;
		Decimal E_11;
		Decimal E_14;		
		Decimal E_15;
		Decimal E_16;	
		Decimal E_17;	
		Decimal E_18;
		Decimal E_19;
		Decimal E_21;
		Decimal E_22;
		Decimal E_23;
		Decimal E_26;
		Decimal E_27;
		Decimal E_28 = 0.0 ;  //Corp/ fact R&D Expense (Optional) *************
		Decimal E_30;
		Decimal E_33;
		Decimal E_35;
		Decimal E_37;
		Decimal E_38;
		
		Decimal[] E_39 = new Decimal[Proj_year + 1];
		for(Integer i = 0; i < proj_year + 1; i++)
			E_39[i] = 0.0;
		
		for(Integer i = 1; i < proj_year + 1; i++){

			//start year 1
            if( i == 1){
				E_8 = 	costModel_I24; //ASP			
				if(E_8 == 0.0)
					return null;
				E_9  = 	temp_E_9; 	//IncrementalVol	
				E_10 = E_9 * 1; 
				
								
				E_14 = D_14;				
				E_15 = D_15; // change in the loop				
				E_16 = D_16;
				//---------------------------------------------------------------------------------------------------------------------
				//In the spreadsheet, it says the currelint line volume must tie to current month P&L shipped volume.
				//It is 0 in default
				E_17 = 0.0;	// Current line Depr U/C. 
			//----------------------------------------------------------------------------------------------------------------------
			}
			else{
				E_8 *= (1-J_45);
				//E_9  all the same				
				//E_10 all the same
				E_11_Prev = E_11;				
				E_14 *= (1-J_46);				
				E_15 *= (1-J_46);				
				E_16 *= (1-J_46);				
				E_17 *= (1-J_46);				
			}

			E_11 = E_10 * 52.0 * E_8; // E11  TotalAnnualRevenue
			E_18 = (E_9 == 0) ? 0 : -1.0 * D_6 / (Decimal.valueOf(proj_year) * E_9 * 52.0); //new depreciation					
			IRR_E18 = E_18;		
			E_19 = E_14 + E_15 + E_16 + E_17 + E_18;				
			E_21 = (E_15 + E_16) > 0 ? (E_14+(E_15*L_46)+(E_16 *L_47))*(-1.0 )*E_10*52.0 : (E_14 + (E_19-E_14-E_18)*L_46*L_47/2 )*(-1.0)*E_10*52.0;					 
			E_22 = (E_15 + E_16 + E_17) > 0 ? (E_15*(1-L_46) + E_16*(1-L_47) + E_17+(E_18))*(-1.0)*E_9*52.0 : ((E_19-E_14-E_17-E_18)*(1-(L_46*L_47/2))+ (E_17+E_18))*(-1.0)*E_9*52.0;						
			E_23 = E_11 + E_21 + E_22;		//Gross_Margin
			E_26 = (E_11 == 0) ? 0 : -1.0 * (E_11 - (E_14 * E_9 * 52.0)) * H_45; 
			E_27 = (E_11 == 0) ? 0 : -1.0 * (E_11 - (E_14 * E_9 * 52.0)) * H_46;  //E26 Corporate_GA_Expense
			E_30 = (E_11 == 0) ? 0 : E_23 + E_26 + E_27 + E_28; // OperatingIncome	
			E_33 = getTaxRate(getCountryCode(factory), i, proj_year)* (-1.0)* E_30; 
			E_35 = (E_11 == 0) ? 0 : E_30 + E_33; //IncomeAfterTaxes
			E_37 = E_18 * E_9 * 52.0;
			
			if(i == 1){
				E_39[i] = (-1.0) * E_11 * A_39; 	
			}
			else if(i == proj_year){
				for(Integer j = 1; j < proj_year; j++)
						E_39[i] += E_39[j];
					E_39[i] *= -1.0;  
			}
			else
				E_39[i] = (-1.0) * (E_11 - E_11_Prev) * A_39; 					

			E_38 = E_9 * E_17 * 52.0; //Exisiting line deprecition addback				
			E_41[i] = E_35 + E_37 + E_38 + E_39[i];//E41  AnnualCashFlow

		}				
		return E_41;
	}
	

	// Using numeric method to solve IRR (No IRR calculator in salesforce therefore I wrote it by my own)
	// Reference: http://en.wikipedia.org/wiki/Internal_rate_of_return
	// Formula: suppose  S = Sum(Xi : Xn), where Xi = Ci/(1+r)^n,    find r make S = 0.
	// Using numerical method to find the nearest "r".

	Decimal calculateIRR(Decimal[] cashFlow){
		
		if(cashFlow == null) return 0.0;
		double oldValue = 0.0;
		double newValue = 0.0;						
		double lowGuessRate = LOW_RATE;
		double highGuessRate = HIGH_RATE;
		double guessRate = (lowGuessRate + highGuessRate) / 2.0;
		double npv = 0.0;
		double denom = 0.0;
		Integer numberOfFlows = cashFlow.size();

		for(Integer i = 0; i < MAX_ITERATION; i++){
			npv = 0.0;
			//calculate npv
			for(Integer j = 0; j < numberOfFlows; j++){
				denom = Math.pow((1+guessRate), (double)j);				
				npv = npv + (cashFlow[j]/denom);
			}
			//check if you achive the taget
			if(Math.abs(npv) < PRECISION_REQ)
				break;
			
			//update npv value
			if(i == 0)
				oldValue = npv;
			else
				oldValue = newValue;
			newValue = npv;

			//adjust guess rate							
			if(newValue < 0)
				highGuessRate = guessRate;
			else
				lowGuessRate = guessRate;						
			guessRate = (lowGuessRate + highGuessRate) / 2.0;			
		}
		return guessRate;
	}
	
	//To Do : Check if all factory covered
	String getCountryCode(String factory){
		if      (factory == 'K4') return 'ATK';
		else if (factory == 'P3') return 'ATP';
		else if (factory == 'C3') return 'ATC';
		else if (factory == 'T3') return 'ATT';
		else return null;
	}

	//To Do : check if we need to install tax table in installer
	Decimal getTaxRate(String country, Integer year, Integer proj_year){
		
		if(country != null &&  (year > 0 && year <= proj_year))
		{

			if      (country == 'AIC' && year == 1) return 0.26;
			else if (country == 'AIC' && year == 2) return 0.42;
			else if (country == 'AIC' && year == 3) return 0.42;
			else if (country == 'AIC' && year == 4) return 0.42;
			else if (country == 'AIC' && year == 5) return 0.42;
			else if (country == 'AIC' && year == 6) return 0.42;
			else if (country == 'AIC' && year == 7) return 0.42;
	
			else if (country == 'ATC' && year == 1) return 0.1;
			else if (country == 'ATC' && year == 2) return 0.12;
			else if (country == 'ATC' && year == 3) return 0.125;
			else if (country == 'ATC' && year == 4) return 0.25;
			else if (country == 'ATC' && year == 5) return 0.25;
			else if (country == 'ATC' && year == 6) return 0.25;
			else if (country == 'ATC' && year == 7) return 0.25;
	
			else if (country == 'ATI' && year == 1) return 0.1;
			else if (country == 'ATI' && year == 2) return 0.1;
			else if (country == 'ATI' && year == 3) return 0.1;
			else if (country == 'ATI' && year == 4) return 0.25;
			else if (country == 'ATI' && year == 5) return 0.35;
			else if (country == 'ATI' && year == 6) return 0.35;
			else if (country == 'ATI' && year == 7) return 0.35;
	
			else if (country == 'ATK' && year == 1) return 0.0;
			else if (country == 'ATK' && year == 2) return 0.0;
			else if (country == 'ATK' && year == 3) return 0.1;
			else if (country == 'ATK' && year == 4) return 0.1;
			else if (country == 'ATK' && year == 5) return 0.154;
			else if (country == 'ATK' && year == 6) return 0.22;
			else if (country == 'ATK' && year == 7) return 0.22;
	
			else if (country == 'ATP' && year == 1) return 0.05;
			else if (country == 'ATP' && year == 2) return 0.05;
			else if (country == 'ATP' && year == 3) return 0.05;
			else if (country == 'ATP' && year == 4) return 0.05;
			else if (country == 'ATP' && year == 5) return 0.05;
			else if (country == 'ATP' && year == 6) return 0.05;
			else if (country == 'ATP' && year == 7) return 0.05;
	
			else if (country == 'ATT' && year == 1) return 0.22;
			else if (country == 'ATT' && year == 2) return 0.26;
			else if (country == 'ATT' && year == 3) return 0.26;
			else if (country == 'ATT' && year == 4) return 0.26;
			else if (country == 'ATT' && year == 5) return 0.26;
			else if (country == 'ATT' && year == 6) return 0.26;
			else if (country == 'ATT' && year == 7) return 0.26;
	
			else if (country == 'UST' && year == 1) return 0.0;
			else if (country == 'UST' && year == 2) return 0.0;
			else if (country == 'UST' && year == 3) return 0.24;
			else if (country == 'UST' && year == 4) return 0.28;
			else if (country == 'UST' && year == 5) return 0.28;
			else if (country == 'UST' && year == 6) return 0.28;
			else if (country == 'UST' && year == 7) return 0.28;
	
			else
				return 0.0;
		}
		else
			return 0.0;		
	}

}