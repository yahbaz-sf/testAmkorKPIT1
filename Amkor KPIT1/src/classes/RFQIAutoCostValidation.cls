/*************************************************************************
*
* PURPOSE: Holds rules for if an item can be auto-priced
*
* CLASS: RFQIAutoCostValidation
* CREATED: 3/31/2014 Ethos Solutions - www.ethos.com  
* AUTHOR: Austin Delorme
***************************************************************************/ 
public with sharing class RFQIAutoCostValidation
{
	public transient Boolean cannotAutoPrice = false;
	public transient RFQIValidation validator;

	private transient RFQILayout layout; 
	public transient Package_Family__c packageFamily;
	public transient Product_Group__c productGroup;
    public transient RFQ_Item__c rfqItem;
	public transient sObject specificRfqItem;
	public transient List<String> autoCostErrors;

	public static final Map<Integer, String> numberMap = new Map<Integer, String>
	{
		0 => 'zero',
		1 => 'one',
		2 => 'two',
		3 => 'three',
		4 => 'four',
		5 => 'five',
		6 => 'six',
		7 => 'seven',
		8 => 'eight',
		9 => 'nine',
		10 => 'ten',
		11 => 'eleven',
		12 => 'twelve',
		13 => 'thirteen',
		14 => 'fourteen',
		15 => 'fifteen',
		16 => 'sixteen'
	};

	public RFQIAutoCostValidation(RFQIValidation valid, List<String> errors)
	{
		validator = valid;
		layout = validator.layout;
		packageFamily = validator.packageFamily;
		productGroup = validator.productGroup;
		rfqItem = validator.rfqItem;
		specificRfqItem = validator.specificRfqItem;

		autoCostErrors = errors;


		if (validator.packageFamily.Name == 'PBGA') validatePBGA();
		else if (validator.productGroup.Name == 'MLF') validateMLF();
		else if (validator.productGroup.Name == 'Quad Leadframe') validateQuad();
		else if (validator.productGroup.Name == 'Dual Leadframe') validateDual();

		if (cannotAutoPrice) {
			DebugUtils.write('cannotAutoPrice', cannotAutoPrice);
			rfqItem.Do_Not_Auto_Price__c = true;
		}
	}

	public Boolean getCannotAutoPrice()
	{
		return cannotAutoPrice;
	}

	private void validatePBGA()
	{
		//---spreadsheet does not have any adders
		if (!validateAdders()) 							cannotAutoPrice = true;

		//---spreadsheet has only one wire config
		if (!validateWireObjects(1)) 					cannotAutoPrice = true;

		//---spreadsheet has no die configs
		if (!validateDieObjects(1)) 					cannotAutoPrice = true;

		//---spreadsheet has no passive information
		if (!validatePassiveConfigurations()) 			cannotAutoPrice = true;
	}

	private void validateMLF()
	{
		//---AMK-2064
		if (!validateMLFDieObjects()) {
			DebugUtils.write('Failed Validate MLF Die Objects');
			cannotAutoPrice = true;
		}

		//---spreadsheet does not have any adders
		if (!validateAdders()) {
			DebugUtils.write('Failed Validate MLF Adders Objects');
			cannotAutoPrice = true;
		}

		//---AMK-2242
		if (!validateMLFWireObjects())  {
			DebugUtils.write('Failed Validate MLF Wire Objects');
			cannotAutoPrice = true;
		}

		//---AMK-2636
		if(!validateMLFForecast()) {
			DebugUtils.write('Failed Validate MLF Forecast Objects');
			cannotAutoPrice = true;
		}
	}

	private void validateQuad()
	{
		//---spreadsheet has only two die configs
		if (!validateDieObjects(2)) 					cannotAutoPrice = true;

		//---spreadsheet does not have any adders
		if (!validateAdders()) 							cannotAutoPrice = true;

		//---spreadsheet has no passive information
		if (!validatePassiveConfigurations()) 			cannotAutoPrice = true;
	}

	private void validateDual()
	{
		//---spreadsheet does not have any adders
		if (!validateAdders()) 							cannotAutoPrice = true;
	}


	private Boolean validateAdders()
	{
		Boolean isValid = true;
		if (layout.sectionMap.get('Adders') != null)
		{
			for (RFQISectionAttribute attribute : layout.sectionMap.get('Adders').attributes)
			{
				//sometimes values in adders section are entry - only valid if the field is empty or the field is null
				if (specificRfqItem.get(attribute.fieldAPIName) != null && specificRfqItem.get(attribute.fieldAPIName) != false)
				{
					isValid = false;
					autoCostErrors.add('Cannot auto-price with selected adder: ' + FieldLabelHelper.getInstance().getLabel(packageFamily.Specific_RFQ_Item_Object__c, attribute.fieldAPIName));
				}
			}
		}

		return isValid;
	}

	private Boolean validateMLFDieObjects()
	{
		Boolean isValid = true;


		if (validator.dieConfigurations.size() == 2)
		{
			Decimal die1X = DataUtils.getDecimal(validator.dieConfigurations[0], 'Die_Size_X__c', 0);
	        Decimal die1Y = DataUtils.getDecimal(validator.dieConfigurations[0], 'Die_Size_Y__c', 0);
	        Decimal die2X = DataUtils.getDecimal(validator.dieConfigurations[1], 'Die_Size_X__c', 0);
	        Decimal die2Y = DataUtils.getDecimal(validator.dieConfigurations[1], 'Die_Size_Y__c', 0);

	        String dieXLabel = FieldLabelHelper.getInstance().getLabel(packageFamily.Specific_Die_Configuration_Object__c, 'Die_Size_X__c');
	        String dieYLabel = FieldLabelHelper.getInstance().getLabel(packageFamily.Specific_Die_Configuration_Object__c, 'Die_Size_Y__c');
	        
			if (die2X - die1X > .5)
            {
                isValid = false;
                autoCostErrors.add(dieXLabel + ' for die 2 cannot be more than 500 microns greater than ' + dieXLabel + ' for die 1' + '<br />');
            } 
            if (die2Y - die1Y > .5) 
            {
                isValid = false;
                autoCostErrors.add(dieYLabel + ' for die 2 cannot be more than 500 microns greater than ' + dieYLabel + ' for die 1' + '<br />');
            }
		}
		else if (validator.dieConfigurations.size() > 2)
        {
            isValid = false;
            autoCostErrors.add('Cannot auto price if there are more than two die configurations' + '<br />');
        }

        //AMK-2363, small body sizes are allowed to be submitted but not priced for Saw
        if (DataUtils.getString(specificRfqItem, 'PF_Sub_Class_1__c', '') == 'SMLF')
        {
	        for (sObject dieConfig : validator.dieConfigurations)
	        {
	        	if (DataUtils.getString(dieConfig, 'Max_Die_Size__c', '') == 'INVALID')
	        	{
					autoCostErrors.add('Cannot auto price due to invalid body sizes for this package family');
					isValid = false;
					break;
	        	}
	        }
        }

        return isValid;
	}

	private Boolean validateMLFForecast() {
		String forecast = (String)specificRfqItem.get('Forecast__c');
		return !(forecast == '0 - 9' || forecast == '10 - 49' || forecast == '50 - 99' || forecast == '100 - 199');
	}

	private Boolean validateMLFWireObjects()
	{
		Boolean isValid = true;
		Integer count = 1;
		for (sObject wire : validator.wireConfigurations)
		{	
			if (wire.get('Wire_Material__c') == 'Ag')
			{
				isValid = false;
				autoCostErrors.add('Cannot auto price if a wire configuration has Ag selected for Wire Material - configuration # ' + count + '<br />');
			}
			count++;
		}
		return isValid;
	}

	private Boolean validateDieObjects(Integer maxDie)
	{
		Boolean isValid = true;

		
		if (validator.dieConfigurations.size() > maxDie)
        {
            isValid = false;
            autoCostErrors.add('Cannot auto price if there are more than ' + numberMap.get(maxDie) + ' die configurations' + '<br />');
        }

        return isValid;
	}

	private Boolean validateWireObjects(Integer maxWire)
	{
		Boolean isValid = true;

		
		if (validator.wireConfigurations.size() > maxWire)
        {
            isValid = false;
            autoCostErrors.add('Cannot auto price if there are more than ' + numberMap.get(maxWire) + ' wire configurations' + '<br />');
        }

        return isValid;
	}

	private Boolean validatePassiveConfigurations()
	{
		if(validator.passiveConfigurations.size() != 0)
		{
            autoCostErrors.add('Cannot auto price if there are any passive configurations' + '<br />');
			return false;
		}
		return true;
	}

	

}