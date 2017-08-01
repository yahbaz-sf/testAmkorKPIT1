/*************************************************************************
* 
* PURPOSE: This class does the main work of creating new 
*          SAP_Pricing_Attribute__c records for SAPInterface
*                   
* CLASS: SAPAttributeController
* CREATED: 05/16/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Jason Swenski
* 
**************************************************************************/
public with sharing class SAPAttributeController {
	//Bhanu 12-Apr-2016
	//public static void updatePricingAttribute(SD26DTPricingAttribute attribute)
	public static SAPInterfaceResult updatePricingAttribute(SD26DTPricingAttribute attribute){
		
		//Bhanu 12-Apr-2016 
		SAPInterfaceResult resultInstance = new SAPInterfaceResult();
		
		try{
			if (attribute != null) {
				
				List<SAP_Pricing_Attribute__c> newAttributeValues = new List<SAP_Pricing_Attribute__c>();
				for (ITEM i : attribute.item){
					String attributeName = i.obj_name;
					String attributeValue = i.obj_value;
					
					if(!StringUtils.isBlank(attributeName) && !StringUtils.isBlank(attributeValue)){
						newAttributeValues.add(new SAP_Pricing_Attribute__c
						    (
						        Attribute_Name__c = attributeName,
						        Attribute_Value__c = attributeValue
						    )
						);
					}
				}
				
				if (newAttributeValues.size() > 0) {
					
					resultInstance.process = 'Inserting SAP Pricing Attribute records';
					insert newAttributeValues;
					resultInstance = assignTasksForAttributes(newAttributeValues, resultInstance);
					resultInstance.process = '';
				}
			}
		} catch(Exception e){
            resultInstance.addError('Error while ' + resultInstance.process + ' : ' + e.getMessage() + ', Location : ' + e.getStackTraceString());
        }
		
		
		//Bhanu 12-Apr-2016
		system.debug('---->SAPAttributeController.updatePricingAttribute(), returning resultInstance : ' + resultInstance);
		return resultInstance;
	}
	
	private static SAPInterfaceResult assignTasksForAttributes(List<SAP_Pricing_Attribute__c> attributes, SAPInterfaceResult resultInstance) {
		
		try{
			List<User> buUsers = UserDao.getInstance().getBuUsers();
			
			if (buUsers != null && buUsers.size() > 0) {
				List<Task> taskList = new List<Task>();
				
				// Assign a seperate task for each user, since assign to queue not implemented yet
				// See https://success.salesforce.com/ideaView?id=087300000007HC0AAM
				for (SAP_Pricing_Attribute__c attrib : attributes) {
					for (User user : buUsers) {
						Task task = new Task();
						task.OwnerId = user.Id;
						task.WhatId = attrib.Id;
						task.Subject = 'New SAP Pricing Attribute';
						task.Description = 'Name: ' + attrib.Attribute_Name__c + ' -- Value: ' + attrib.Attribute_Value__c;
						taskList.add(task);
					}
				}
				
				System.debug(LoggingLevel.Info, '### Assigned out tasks: ' + taskList.size());
				resultInstance.process = 'Assigning Task to Users';		
				insert taskList;
			}
			else {
				System.debug(LoggingLevel.Warn, 'Did not assign tasks because no BU users found');
			}
		} catch(Exception e){
            resultInstance.addError('Error while ' + resultInstance.process + ' : ' + e.getMessage() + ', Location : ' + e.getStackTraceString());
        }
				
		//Bhanu 14-Apr-2016
		return resultInstance;
	}

}