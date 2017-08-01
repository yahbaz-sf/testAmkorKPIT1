public with sharing class FactoryHelper {
    private static Map<String, String> allowedFactories;


    // May need a better structure eventually
    public static Map<String, Map<String, Set<String>>> factoryFieldMaps = new Map<String, Map<String, Set<String>>>
    {
        // 'RFQI_PBGA__c.Layer_Configuration__c' => 
        //  new Map<String, Set<String>>
        //  {
        //      'HDI' => new Set<String> {'P1'},
        //      'PTH' => new Set<String> {'K3'}
        //  }
        // ,
        // 'RFQI_PBGA__c.Ball_Pitch__c' =>
        //  new Map<String, Set<String>>
        //  {
        //      '0.8' => new Set<String> {'P1', 'K3', 'K4'},
        //      '1.27' => new Set<String> {'P1', 'T1', 'P3'},
        //      '1' => new Set<String> {'P1', 'P1', 'K4'}
        //  }
            'RFQI_PBGA__c.Mold_Process_Type__c' =>
            new Map<String, Set<String>>
            {
                'CGM' => new Set<String> {'P3', 'K4'},
                'PGM' => new Set<String> {'K4','C3'}

            },
            'RFQI_Bump__c.Wafer_Size_PK__c' =>
            new Map<String, Set<String>>
            {
                '150' => new Set<String> {'K4'},
                '200' => new Set<String> {'C3', 'K4', 'T5'},
                '300' => new Set<String> {'K4', 'T1', 'T5'}
            }
            ,
            'RFQI_DieProcessing__c.Wafer_Size_PK__c' =>//'K1,K4,T3,P3,C3'
            new Map<String, Set<String>>
            {
                '150' => new Set<String> {'P1', 'K1', 'K4'},
                '200' => new Set<String> {'T5', 'K4', 'C3', 'T3', 'P1'},
                '300' => new Set<String> {'T3', 'K4', 'P1'}
            }
            ,
            'RFQI_DieProcessing__c.Backside_Coat__c' =>
            new Map<String, Set<String>>
            {
                'Yes' => new Set<String> {'T3', 'K1', 'K4', 'C3', 'P1'}
            }
            ,
            'RFQI_DieProcessing__c.Inspect__c' =>
            new Map<String, Set<String>>
            {
                'AOI' => new Set<String> {'T3', 'K1', 'K4', 'C3', 'P1'},
                'Commercial' => new Set<String> {'P1'},
                'Military' => new Set<String> {'P1'},
                'Sample Only' => new Set<String> {'P1'}
            }
            ,
            'RFQI_DieProcessing__c.Inspect_2__c' =>
            new Map<String, Set<String>>
            {
                'AOI' => new Set<String> {'T3', 'K1', 'K4', 'C3', 'P1'},
                'Commercial' => new Set<String> {'P1'},
                'Military' => new Set<String> {'P1'},
                'Sample Only' => new Set<String> {'P1'}
            }
            ,
            'RFQI_DieProcessing__c.Packing__c' =>
            new Map<String, Set<String>>
            {
                'Waffle Pack' => new Set<String> {'P1'},
                'Gel Pack' => new Set<String> {'P1'},
                'Film Frame' => new Set<String> {'P1', 'T3'}
            }
            ,
            'RFQI_Die_Sales__c.Wafer_Size_PK__c' =>//'K1,K4,T3,P3,C3'
            new Map<String, Set<String>>
            {
                '150' => new Set<String> {'P1', 'K1', 'K4'},
                '200' => new Set<String> {'T5', 'K4', 'C3', 'P1'},
                '300' => new Set<String> {'T3', 'K4', 'P1'}
            }
            ,
            'RFQI_Die_Sales__c.Backside_Coat__c' =>
            new Map<String, Set<String>>
            {
                'Yes' => new Set<String> {'T3', 'K1', 'K4', 'C3', 'P1'}
            }
            ,
            'RFQI_Die_Sales__c.Inspect__c' =>
            new Map<String, Set<String>>
            {
                'AOI' => new Set<String> {'T3', 'K1', 'K4', 'C3', 'P1'},
                'Commercial' => new Set<String> {'P1'},
                'Military' => new Set<String> {'P1'},
                'Sample Only' => new Set<String> {'P1'}
            }
            ,
            'RFQI_Die_Sales__c.Inspect_2__c' =>
            new Map<String, Set<String>>
            {
                'AOI' => new Set<String> {'T3', 'K1', 'K4', 'C3', 'P1'},
                'Commercial' => new Set<String> {'P1'},
                'Military' => new Set<String> {'P1'},
                'Sample Only' => new Set<String> {'P1'}
            }
            ,
            'RFQI_Die_Sales__c.Packing__c' =>
            new Map<String, Set<String>>
            {
                'Waffle Pack' => new Set<String> {'P1'},
                'Gel Pack' => new Set<String> {'P1'},
                'Film Frame' => new Set<String> {'P1', 'T3'}
            }
    };

    private FactoryHelper() {}

    public static String getFactoryMapStringForField(String packageFamily, String fieldName) {
        String fullFieldName = packageFamily + '.' + fieldName;

        if (factoryFieldMaps.containsKey(fullFieldName)) {
            Map<String, Set<String>> factoryValues = factoryFieldMaps.get(fullFieldName);
            String jsonVal = System.JSON.serialize(factoryValues);

            System.debug('### Found factory values: ' + jsonVal); 

            return jsonVal;
        }

        return null;
    }

    // This method is used by the installers, to get the default of which factories are allowed for which package families
    public static String getAllowedFactories(String rfqiName) {
        if (allowedFactories == null) {
            allowedFactories = new Map<String, String>();
            allowedFactories.put('RFQI_WLFO__C','K4'); 
            allowedFactories.put('RFQI_PDIP__C','P1');
            allowedFactories.put('RFQI_PSOP3__C','P1'); 
            allowedFactories.put('RFQI_SC_70__C','P1'); 
            allowedFactories.put('RFQI_SOIC_208MIL_BODY__C','P1');
            allowedFactories.put('RFQI_SOIC_300MIL_BODY__C','P1');
            allowedFactories.put('RFQI_SOT_223__C','P1');
            allowedFactories.put('RFQI_SOT_23__C','P1');
            allowedFactories.put('RFQI_SSOP_150MIL_BODY__C','P1');
            allowedFactories.put('RFQI_SSOP_300MIL_BODY__C','P1');
            allowedFactories.put('RFQI_SSOP_METRIC_53MM__C','P1');
            allowedFactories.put('RFQI_TO_92__C','P1');
            allowedFactories.put('RFQI_TSOT__C','P1');
            allowedFactories.put('RFQI_TSSOP_30MM_BODY_MSOP__C','P1');
            allowedFactories.put('RFQI_TSSOP_44MM_BODY__C','P1');
            allowedFactories.put('RFQI_TSSOP_61MM_BODY__C','P1');
            allowedFactories.put('RFQI_VSSOP__C','P1');
            allowedFactories.put('RFQI_EPAD_TSSOP_44_BODY__C','P1');
            allowedFactories.put('RFQI_EPAD_TSSOP_61_BODY__C','P1');
            allowedFactories.put('RFQI_PUNCH_SINGLE_ROW_DFN__C','C3');
            allowedFactories.put('RFQI_PUNCH_DUAL_ROW_MLF__C','C3');
            allowedFactories.put('RFQI_PUNCH_SINGLE_ROW_MLF__C','C3');
            allowedFactories.put('RFQI_SAW_SINGLE_ROW_DFN__C','P3');
            allowedFactories.put('RFQI_SAW_DUAL_ROW_MLF__C','P3');
            allowedFactories.put('RFQI_SAW_SINGLE_ROW_MLF__C','P3');
            allowedFactories.put('RFQI_FCBGA__C','K4,P3,T3');
            allowedFactories.put('RFQI_FCCSP__C','K1,K4,T3,P3,C3');
            allowedFactories.put('RFQI_BUMP__C','K4,T1,T5,C3');
            allowedFactories.put('RFQI_SCSP__C','J1,C3,K4,P3');
            allowedFactories.put('RFQI_FCSCSP__C','K1,K4,T3,P3,C3');
            allowedFactories.put('RFQI_SOIC_150MIL_BODY__C','P1');

            //allowedFactories.put('RFQI_TQFP__C', 'K1,P1,T1,J1');
            allowedFactories.put('RFQI_TQFP__C', 'P1');
            allowedFactories.put('RFQI_LQFP__C', 'K1,P1,T1,J1');
            allowedFactories.put('RFQI_MQFP__C', 'P1,T1,J1');
            allowedFactories.put('RFQI_PLCC__C', 'P1');
            allowedFactories.put('RFQI_POWERQUAD_4__C', 'P1');
            allowedFactories.put('RFQI_TSCSP__C', 'K1,P1,T1');
            allowedFactories.put('RFQI_MQFP_HEAT_SPREADER__C', 'P1,T1');
            allowedFactories.put('RFQI_FUSION_QUAD__C', 'K1');
            allowedFactories.put('RFQI_MQFP_FCIR__C', 'K1,P1,T1');
            allowedFactories.put('RFQI_PBGA__C', 'K4,P3');
            allowedFactories.put('RFQI_DieProcessing__C','K1,K4,T3,P1,C3,T5');
            allowedFactories.put('RFQI_Die_Sales__C','K1,K4,T3,P1,C3,T5');
            allowedFactories.put('RFQI_CABGA__C','J1,K4,C3,P3');


        }

        if (allowedFactories.containsKey(rfqiName.toUpperCase())) {
            return allowedFactories.get(rfqiName.toUpperCase());
        }

        return null;
    }


    public Static List<Factory__c> getAllowedFactoryList(RFQItemWrapper wrapper, RFQILayout layout) {
        List<Factory__c> factories = FactoryDao.getInstance().getAllFactories();
        
        system.debug('factories   : '+factories);
        if (!StringUtils.isBlank(wrapper.packageFamily.Allowed_factories__c)) {
            for (Integer i = factories.size() - 1; i >= 0; i--) {
                System.debug('factories[i].Name   : '+factories[i].Name);
                system.debug('wrapper.packageFamily.Allowed_factories__c   : '+wrapper.packageFamily.Allowed_factories__c);
                if (!wrapper.packageFamily.Allowed_factories__c.contains(factories[i].Name)) {
                    factories.remove(i);
                    system.debug('factories   : '+factories);
                }
            }
        }
        //Abhay - 18-April-17 : Salesforce-100 : Factory update changes Die Sales
        if(wrapper.packageFamily.Default_Factory__c != null && wrapper.packageFamily.Allowed_factories__c != null){
            
            //List<Factory__c> lstFactory =[Select id,name from Factory__c where name IN :factories];
            //System.debug('lstFactory.get(0) '+ lstFactory.get(0));
        
            String defaultValue = wrapper.packageFamily.Default_Factory__c;
            Map<String,Factory__c> mapFactoryName = new Map<String,Factory__c>();
        
            //List<Factory__c> lstFactoryNew = new List<Factory__c>();
                
            For(Factory__c fac: factories){
                mapFactoryName.put(fac.name,fac);
            }
            factories.clear();
            for(String str:mapFactoryName.keyset()){
                if(str!=defaultValue){
                    factories.add(mapFactoryName.get(str));
                }
            }
            //System.debug('lstFactoryNew '+lstFactoryNew);
        
            factories.add(0,mapFactoryName.get(defaultValue));
            //System.debug('lstFactoryNew.get(0) '+ lstFactoryNew.get(0));
            //System.debug('lstFactoryNew.get(1) '+ lstFactoryNew.get(1));
        }
        
        List<RFQISectionAttribute> factoryAttributes = layout.getFactoryAttributes();
        system.debug('factoryAttributes   : '+factoryAttributes);
        if (factoryAttributes.size() > 0) {
             for (RFQISectionAttribute attribute : factoryAttributes) {
                 system.debug('attribute   : '+attribute);
                Object itemVal = wrapper.specificRfqItem.get(attribute.fieldAPIName);
                system.debug('itemVal   : '+itemVal);
                if(attribute.factoryValuesMap != null) {
                    if (itemVal != null && attribute.factoryValuesMap.containsKey(String.valueOf(itemVal))) {
                        Set<String> valFactories = attribute.factoryValuesMap.get(String.valueOf(itemVal));
                        system.debug('valFactories   : '+valFactories);
                        for (Integer i = factories.size() - 1; i >= 0; i--) {
                            if (!valFactories.contains(factories[i].Name)) {
                                factories.remove(i);
                                system.debug('factories   : '+factories);
                            }
                        }                    
                    }
                    else {
                        System.debug('### Could not get factory values for field because value of null or not found in map -- ' + attribute.fieldAPIName);
                    }
                }
            }
        }
        system.debug('factories #236  : '+factories);
        return factories;
    }

    public static void amk1400() {
                List<RFQI_PF_Field_Def__c> pfFields = [select Id, Package_Family__r.Specific_RFQ_Item_Object__c, RFQI_Field_Def__r.Name from RFQI_PF_Field_Def__c];

        for (RFQI_PF_Field_Def__c field : pfFields ) {
            string factoryFields = getFactoryMapStringForField(field.Package_Family__r.Specific_RFQ_Item_Object__c, field.RFQI_Field_Def__r.Name);
            field.Factory_Values__c = factoryFields;
        }
        update pfFields;
    }

}