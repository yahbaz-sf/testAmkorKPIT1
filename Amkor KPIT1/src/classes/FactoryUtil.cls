/*************************************************************************
* 
* PURPOSE:  Utility class for determining factory
*         
* CLASS: FactoryUtil
* CREATED: 12/20/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Raghuveer Mandali
* 
**************************************************************************/
global class FactoryUtil {

    global static void getFactoryOptionsForQuad(List<Factory__c> allowedFactories, String bodySize, String leadCount, String pacakgeFamilyName) {
        String factoryNamesToBeRemoved = '';
        Boolean removeAll = false;

        if(pacakgeFamilyName == 'LQFP') {
            //Lalit - 01-Feb-2017 : Salesforce-182 : Factory is missing for LQFP pkg
            //Commenting the Lines in which P1 values are removing.
            if(bodySize == '7x7') {
                if(leadCount == '32') {
                    factoryNamesToBeRemoved += 'T1,';
                    factoryNamesToBeRemoved += 'J1';
                }
                else if(leadCount == '64') {
                    //factoryNamesToBeRemoved += 'P1,';
                    factoryNamesToBeRemoved += 'J1';
                }
            }
            else if(bodySize == '10x10') {
                if(leadCount == '44') {
                    factoryNamesToBeRemoved += 'T1';
                }
                else if(leadCount == '52') {
                    //factoryNamesToBeRemoved += 'P1,';
                    factoryNamesToBeRemoved += 'T1';
                }
                else if(leadCount == '80') {
                    //factoryNamesToBeRemoved += 'P1,';
                    factoryNamesToBeRemoved += 'J1';
                }
            }
            else if(bodySize == '12x12') {
                if(leadCount == '80') {
                    factoryNamesToBeRemoved += 'T1';
                }
                else if(leadCount == '100') {
                    factoryNamesToBeRemoved += 'K1,';
                    factoryNamesToBeRemoved += 'J1,';
                    factoryNamesToBeRemoved += 'T1';
                }
            }
            else if(bodySize == '14x14') {
                if(leadCount == '44') {
                    removeAll = true;
                }
                else if(leadCount == '52') {
                    //factoryNamesToBeRemoved += 'P1,';
                    factoryNamesToBeRemoved += 'J1,';
                    factoryNamesToBeRemoved += 'T1';
                }
                else if(leadCount == '64' || leadCount == '120') {
                    factoryNamesToBeRemoved += 'J1,';
                    factoryNamesToBeRemoved += 'T1';
                }
                else if(leadCount == '80') {
                    factoryNamesToBeRemoved += 'J1';

                }
            }
            else if(bodySize == '16x16') {
                if(leadCount == '144') {
                    factoryNamesToBeRemoved += 'K1,';
                    //factoryNamesToBeRemoved += 'P1,';
                    factoryNamesToBeRemoved += 'T1';
                }
            }
            else if(bodySize == '14x20') {
                if(leadCount == '100' || leadCount == '128') {
                    factoryNamesToBeRemoved += 'K1,';
                    factoryNamesToBeRemoved += 'J1';
                    
                }
            }
            else if(bodySize == '20x20') {
                if(leadCount == '128') {
                    factoryNamesToBeRemoved += 'J1,';
                    factoryNamesToBeRemoved += 'T1';
                }
            }
            else if(bodySize == '24x24') {
                if(leadCount== '160') {
                    //factoryNamesToBeRemoved += 'P1,';
                    factoryNamesToBeRemoved += 'J1,';
                    factoryNamesToBeRemoved += 'T1';
                }
                /*else if(leadCount == '176') {
                    factoryNamesToBeRemoved += 'P1';
                }*/
                else if(leadCount == '216') {
                    //factoryNamesToBeRemoved += 'P1,';
                    factoryNamesToBeRemoved += 'J1';
                }
            }
            else if(bodySize == '28x28') {
                if(leadCount == '208' || leadCount == '256') {
                    //factoryNamesToBeRemoved += 'P1,';
                    factoryNamesToBeRemoved += 'J1';
                }
            }
        }
        else if(pacakgeFamilyName == 'TQFP') {
            //Lalit - 01-Feb-2017 : Salesforce-182 : Factory is missing for TQFP pkg
            //Commenting the Lines in which P1 values are removing
            if(bodySize == '5x5') {
                if(leadCount == '32' || leadCount == '40') {
                    factoryNamesToBeRemoved += 'K1,';
                    factoryNamesToBeRemoved += 'J1,';
                    factoryNamesToBeRemoved += 'T1';
                    
                }
            }
            else if(bodySize == '7x7') {
                if(leadCount == '32') {
                    factoryNamesToBeRemoved += 'J1,';
                    factoryNamesToBeRemoved += 'T1';
                }
                else if(leadCount == '48') {
                    factoryNamesToBeRemoved += 'T1';
                }
                else if(leadCount == '64') {
                    //factoryNamesToBeRemoved += 'P1,';
                    factoryNamesToBeRemoved += 'T1';
                }
            }
            else if(bodySize == '10x10') {
                if(leadCount == '44') {
                    factoryNamesToBeRemoved += 'J1,';
                    factoryNamesToBeRemoved += 'T1';
                }
                else if(leadCount == '52' || leadCount == '80') {
                    //factoryNamesToBeRemoved += 'P1,';
                    factoryNamesToBeRemoved += 'J1,';
                    factoryNamesToBeRemoved += 'T1';
                }
                else if(leadCount == '64') {
                    factoryNamesToBeRemoved += 'T1';
                }
            }
            else if(bodySize == '12x12') {
                if(leadCount == '80') {
                    //factoryNamesToBeRemoved += 'P1,';
                    factoryNamesToBeRemoved += 'T1';
                }
                else if(leadCount == '100') {
                    factoryNamesToBeRemoved += 'K1,';
                    factoryNamesToBeRemoved += 'J1,';
                    factoryNamesToBeRemoved += 'T1';
                }
            }
            else if(bodySize == '14x14') {
                if(leadCount == '44') {
                    removeAll = true;
                }
                else if(leadCount == '52') {
                    //factoryNamesToBeRemoved += 'P1,';
                    factoryNamesToBeRemoved += 'J1,';
                    factoryNamesToBeRemoved += 'T1';
                }
                else if(leadCount == '64' || leadCount == '80' || leadCount == '120') {
                    factoryNamesToBeRemoved += 'J1,';
                    factoryNamesToBeRemoved += 'T1';
                }
            }
            else if(bodySize == '16x16') {
                //if(leadCount == '144') {
                    factoryNamesToBeRemoved += 'K1,';
                    factoryNamesToBeRemoved += 'J1,';
                    factoryNamesToBeRemoved += 'T1';
                    
                //}
            }
            else if(bodySize == '20x20') {
                if(leadCount == '128') {
                    //factoryNamesToBeRemoved += 'P1,';
                    factoryNamesToBeRemoved += 'J1,';
                    factoryNamesToBeRemoved += 'T1';
                }
                else if(leadCount == '144' || leadCount == '176') {
                    //factoryNamesToBeRemoved += 'P1,';
                    factoryNamesToBeRemoved += 'J1,';
                }
            }

        }
        else if(pacakgeFamilyName == 'MQFP' || pacakgeFamilyName == 'MQFP W/ FCIR') {
            if(bodySize == '14x14') {
                if(leadCount == '52' || leadCount == '64' || leadCount == '80' || leadCount== '100') {
                    factoryNamesToBeRemoved += 'K1,';
                    factoryNamesToBeRemoved += 'J1,';
                    factoryNamesToBeRemoved += 'T1';
                }
            }
            else if(bodySize == '14x20') {
                if(leadCount == '64') {
                    factoryNamesToBeRemoved += 'K1,';
                    factoryNamesToBeRemoved += 'P1,';
                    factoryNamesToBeRemoved += 'T1';
                }
                else if(leadCount == '80') {
                    factoryNamesToBeRemoved += 'K1,';
                    factoryNamesToBeRemoved += 'T1';
                }
                else if(leadCount == '100') {
                    factoryNamesToBeRemoved += 'K1,';
                }
                else if(leadCount == '128') {
                    factoryNamesToBeRemoved += 'K1,';
                    factoryNamesToBeRemoved += 'J1';
                }
            }
            else if(bodySize == '28x28') {
                if(leadCount == '120' || leadCount== '128' || leadCount == '144') {
                    factoryNamesToBeRemoved += 'K1,';
                    factoryNamesToBeRemoved += 'J1,';
                    factoryNamesToBeRemoved += 'T1';
                }
                else if(leadCount == '160' || leadCount == '208') {
                    factoryNamesToBeRemoved += 'K1,';
                    factoryNamesToBeRemoved += 'J1';
                }
                else if(leadCount == '256') {
                    removeAll = true;
                }
            }
            else if(bodySize == '10x10') {
                if(leadCount == '44' || leadCount == '52' || leadCount == '64' || leadCount == '240') {
                    factoryNamesToBeRemoved += 'K1,';
                    factoryNamesToBeRemoved += 'J1,';
                    factoryNamesToBeRemoved += 'T1';
                }
            }
            else if(bodySize == '32x32') {
                if(leadCount == '240') {
                    factoryNamesToBeRemoved += 'K1,';
                    factoryNamesToBeRemoved += 'J1,';
                    factoryNamesToBeRemoved += 'T1';
                }
            }
        }
        else if(pacakgeFamilyName == 'MQFP W/ Heat Spreader') {
            if(bodySize == '14x14') {
                if(leadCount == '52' || leadCount == '64' || leadCount == '80') {
                    factoryNamesToBeRemoved += 'K1,';
                    factoryNamesToBeRemoved += 'J1,';
                    factoryNamesToBeRemoved += 'T1';
                }
            }
            else if(bodySize == '14x20') {
                if(leadCount == '100') {
                    factoryNamesToBeRemoved += 'K1,';
                    factoryNamesToBeRemoved += 'J1,';
                    factoryNamesToBeRemoved += 'T1';
                }
                else if(leadCount == '128') {
                    removeAll = true;
                }
            }
            else if(bodySize == '28x28') {
                if(leadCount == '120') {
                    factoryNamesToBeRemoved += 'K1,';
                    factoryNamesToBeRemoved += 'J1,';
                    factoryNamesToBeRemoved += 'T1';
                }
                else if(leadCount == '128') {
                    factoryNamesToBeRemoved += 'K1,';
                    factoryNamesToBeRemoved += 'J1';
                }
                else if(leadCount == '144') {
                    removeAll = true;
                }
                else if(leadCount == '160') {
                    factoryNamesToBeRemoved += 'K1,';
                    factoryNamesToBeRemoved += 'J1';
                }
                else if(leadCount == '208') {
                    factoryNamesToBeRemoved += 'K1,';
                    factoryNamesToBeRemoved += 'J1';
                }
                else if(leadCount == '256') {
                    factoryNamesToBeRemoved += 'K1,';
                    factoryNamesToBeRemoved += 'J1,';
                    factoryNamesToBeRemoved += 'T1';
                }
            }
            else if(bodySize == '32x32') {
                if(leadCount == '240') {
                    factoryNamesToBeRemoved += 'K1,';
                    factoryNamesToBeRemoved += 'J1,';
                    factoryNamesToBeRemoved += 'T1';
                }
            }
        }
        else if(pacakgeFamilyName == 'PowerQuad 4') {
            if(bodySize == '28x28') {
                if(leadCount == '128') {
                    removeAll = true;
                }
                else if(leadCount == '144') {
                    removeAll = true;
                }
            }
        }

        system.debug('Factory Names: ' + factoryNamesToBeRemoved);
        if(removeAll) {
            allowedFactories.clear();
        }
        else {
            for(Integer i = allowedFactories.size() - 1; i >= 0; i--) {
                if(factoryNamesToBeRemoved.contains(allowedFactories[i].Name)) {
                    allowedFactories.remove(i);
                }
            }
        }
        
    }

}