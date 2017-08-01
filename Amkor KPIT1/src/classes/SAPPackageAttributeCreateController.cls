public with sharing class SAPPackageAttributeCreateController extends BaseController {
    
    public SAP_Pricing_Attribute__c attribute {get; set;} 
    public String itemProductGroup {get; set;}
    public String itemPackageFamily {get; set;}
    public String itemField {get; set;}
    
    public SAPPackageAttributeCreateController() {
        String attributeId = getParam('id');
        attribute = [select Id,Attribute_Name__c,Attribute_Value__c from SAP_Pricing_Attribute__c where Id =: attributeId];
        
    }
    
    public List<SelectOption> getProductGroups() {
        
        ProductGroupDao prodDao = ProductGroupDao.getInstance();
        RFQDao rfDao = RFQDao.getInstance();
                
        List<Product_Group__c> productGroups
         = prodDao.getAllProductGroups();
        
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- None Selected --'));
        for(Product_Group__c productGroup : productGroups) {
            options.add(new SelectOption(productGroup.Id,productGroup.Name));
        } 
        return options;
    }
    
    /**
    * Gets the list package families in the system as SelectOptions
    * that correspond to the selected product group
    *
    * @returns List<SelectOption> of Package_Family__c
    */
    public List<SelectOption> getPackageFamilies() {
        
        List<Package_Family__c> packageFamilies 
            = PackageFamilyDao.getInstance().getFamiliesByProductGroup(itemProductGroup);
            
        List<SelectOption> options = new List<SelectOption>();
        for(Package_Family__c packageFamily : packageFamilies) {
            
            if(itemPackageFamily == '' || itemPackageFamily == null){
                itemPackageFamily = packageFamily.Id;
                getFields();
            }
            
            options.add(new SelectOption(packageFamily.Id,packageFamily.Name));
        }
        return options;
    }
    
    public List<SelectOption> getFields() {
        
        List<RFQI_PF_Field_Def__c> fieldDefs = PFFieldDefDao.getInstance().getFieldsForPackageFamily(itemPackageFamily);
            
        List<SelectOption> options = new List<SelectOption>();
        for(RFQI_PF_Field_Def__c field : fieldDefs) {
            if(!field.RFQI_Field_Def__r.Name.contains('__r')) {
                             
                options.add(new SelectOption(field.RFQI_Field_Def__c,field.RFQI_Field_Def__r.Name));
            }
        }
        return options;
    }
    
    public PageReference createPackageAttribute() {
        
        SAP_Package_Attribute__c packAtt = new SAP_Package_Attribute__c
            (
                Package_Family__c = itemPackageFamily,
                RFQI_Field_Def__c = itemField,
                SAP_Pricing_Attribute__c = attribute.Id
            );
        
        insert packAtt;
        
        // Delete all related tasks
        
        List<Task> relatedTasks = [Select Id from Task where WhatId =: attribute.Id];
        delete relatedTasks;
        
        return new PageReference('/' + itemPackageFamily);
    }
    
    public PageReference cancel() {
        
        return new PageReference('/' + attribute.Id);
    }

}