/*************************************************************************
*
* PURPOSE: Unit Tests for FactoryUtil
*
* CLASS: FactoryUtilTest
* CREATED: 12/23/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Raghuveer Mandali
***************************************************************************/
@isTest
private class FactoryUtilTest {
    
    private static List<Factory__c> setupTest(String packageFamily) {
        List<Factory__c> baseFactories = RFQAdminInstaller.installFactories();
        List<Factory__c> factoriesForLQFP = new List<Factory__c>();
        List<Factory__c> factoriesForTQFP = new List<Factory__c>();
        List<Factory__c> factoriesForMQFP = new List<Factory__c>();
        List<Factory__c> factoriesForMQFPHS = new List<Factory__c>();
        List<Factory__c> factoriesForPowerQuad = new List<Factory__c>();


        //setup factories for each package family
        for(Factory__c factory : baseFactories) {
            if(factory.name == 'K1') {
                factoriesForLQFP.add(factory);
                factoriesForTQFP.add(factory);
            }
            if(factory.name == 'P1') {
                factoriesForLQFP.add(factory);
                factoriesForTQFP.add(factory);
                factoriesForMQFP.add(factory);
                factoriesForMQFPHS.add(factory);
                factoriesForPowerQuad.add(factory);
            }
            if(factory.name == 'T1') {
                factoriesForLQFP.add(factory);
                factoriesForTQFP.add(factory);
                factoriesForMQFP.add(factory);
                factoriesForMQFPHS.add(factory);
            }
            if(factory.name == 'J1') {
                factoriesForLQFP.add(factory);
                factoriesForTQFP.add(factory);
                factoriesForMQFP.add(factory);
            }
        }

        if(packageFamily == 'LQFP') {return factoriesForLQFP;}
        if(packageFamily == 'TQFP') {return factoriesForTQFP;}
        if(packageFamily == 'MQFP') {return factoriesForMQFP;}
        if(packageFamily == 'MQFPHS') {return factoriesForMQFPHS;}
        if(packageFamily == 'PowerQuad') {return factoriesForPowerQuad;}

        return null;
    }

    private static testMethod void testLQFP() { 
        List<Factory__c> factoriesForLQFP = setupTest('LQFP');
        List<Factory__c> factoriesToTest = factoriesForLQFP.clone();

        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '7x7', '48', 'LQFP');
        system.assert(factoriesForLQFP.equals(factoriesToTest));
        //Bhanu S 26 July 2016
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '7x7', '32', 'LQFP');
        //system.assert(factoriesForLQFP.equals(factoriesToTest));
        
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '7x7', '64', 'LQFP');
        //system.assert(factoriesForLQFP.equals(factoriesToTest));
        
        factoriesToTest = factoriesForLQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '10x10', '44', 'LQFP');
        factoriesToTest.sort();
        
        factoriesToTest = factoriesForLQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '10x10', '80', 'LQFP');
        factoriesToTest.sort();
        //till here
        factoriesToTest = factoriesForLQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '10x10', '52', 'LQFP');
        factoriesToTest.sort();
        system.assert(factoriesToTest.size() == 2);
        system.assert(factoriesToTest[0].Name == 'J1');
        system.assert(factoriesToTest[1].Name == 'K1');
        
        factoriesToTest = factoriesForLQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '12x12', '100', 'LQFP');
        factoriesToTest.sort();
        system.assert(factoriesToTest.size() == 1);
        system.assertEquals('P1',factoriesToTest[0].Name, 'Should be the same');

        //Bhanu S 26 July 2016
        factoriesToTest = factoriesForLQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '12x12', '80', 'LQFP');
        factoriesToTest.sort();
        
        factoriesToTest = factoriesForLQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '14x14', '52', 'LQFP');
        factoriesToTest.sort();
        system.assert(factoriesToTest.size() == 1);
        system.assertEquals('K1',factoriesToTest[0].Name, 'Should be the same');
        
        factoriesToTest = factoriesForLQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '14x14', '64', 'LQFP');
        factoriesToTest.sort();
        system.assert(factoriesToTest.size() == 2);
        
        factoriesToTest = factoriesForLQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '14x14', '80', 'LQFP');
        factoriesToTest.sort();
        
        //till here
        
        factoriesToTest = factoriesForLQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '14x14', '44', 'LQFP');
        system.assert(factoriesToTest.isEmpty());

        factoriesToTest = factoriesForLQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '16x16', '144', 'LQFP');
        factoriesToTest.sort();
        system.assert(factoriesToTest.size() == 1);
        system.assert(factoriesToTest[0].Name == 'J1');

        factoriesToTest = factoriesForLQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '14x20', '100', 'LQFP');
        factoriesToTest.sort();
        system.assert(factoriesToTest.size() == 2);
        system.assert(factoriesToTest[0].Name == 'P1');
        system.assert(factoriesToTest[1].Name == 'T1');

        factoriesToTest = factoriesForLQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '20x20', '144', 'LQFP');
        system.assert(factoriesForLQFP.equals(factoriesToTest));
        
        //Bhanu S 26 July 2016
        factoriesToTest = factoriesForLQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '20x20', '128', 'LQFP');
        system.assert(!(factoriesForLQFP.equals(factoriesToTest)));
        
        factoriesToTest = factoriesForLQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '24x24', '160', 'LQFP');
        factoriesToTest.sort();
        system.assert(factoriesToTest.size() == 1);
    
        factoriesToTest = factoriesForLQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '24x24', '216', 'LQFP');
        factoriesToTest.sort();
        system.assert(factoriesToTest.size() == 2);
        
        //till here

        factoriesToTest = factoriesForLQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '24x24', '176', 'LQFP');
        factoriesToTest.sort();
        system.assert(factoriesToTest.size() == 3);
        system.assert(factoriesToTest[0].Name == 'J1');
        system.assert(factoriesToTest[1].Name == 'K1');
        system.assert(factoriesToTest[2].Name == 'T1');

        factoriesToTest = factoriesForLQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '28x28', '208', 'LQFP');
        factoriesToTest.sort();
        system.assert(factoriesToTest.size() == 2);
        system.assert(factoriesToTest[0].Name == 'K1');
        system.assert(factoriesToTest[1].Name == 'T1');
    }

    private static testMethod void testTQFP() {
        List<Factory__c> factoriesForTQFP = setupTest('TQFP');
        List<Factory__c> factoriesToTest = factoriesForTQFP.clone();

        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '5x5', '40', 'TQFP');
        factoriesToTest.sort();
        system.assert(factoriesToTest.size() == 1);
        system.assert(factoriesToTest[0].Name == 'P1');

        factoriesToTest = factoriesForTQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '7x7', '64', 'TQFP');
        factoriesToTest.sort();
        system.assert(factoriesToTest.size() == 2);
        system.assert(factoriesToTest[0].Name == 'J1');
        system.assert(factoriesToTest[1].Name == 'K1');
        
        //Bhanu S 26-July-2016
        factoriesToTest = factoriesForTQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '7x7', '32', 'TQFP');
        factoriesToTest.sort();
        system.assert(factoriesToTest.size() == 2);
                
        factoriesToTest = factoriesForTQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '7x7', '48', 'TQFP');
        factoriesToTest.sort();
        
        factoriesToTest = factoriesForTQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '10x10', '44', 'TQFP');
        factoriesToTest.sort();
        
        factoriesToTest = factoriesForTQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '10x10', '52', 'TQFP');
        factoriesToTest.sort();
        

        // till here
        
        factoriesToTest = factoriesForTQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '10x10', '64', 'TQFP');
        factoriesToTest.sort();
        system.assert(factoriesToTest.size() == 3);
        system.assert(factoriesToTest[0].Name == 'J1');
        system.assert(factoriesToTest[1].Name == 'K1');
        system.assert(factoriesToTest[2].Name == 'P1');

        factoriesToTest = factoriesForTQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '12x12', '80', 'TQFP');
        factoriesToTest.sort();
        system.assert(factoriesToTest.size() == 2);
        system.assert(factoriesToTest[0].Name == 'J1');
        system.assert(factoriesToTest[1].Name == 'K1');
        
        //Bhanu S 26 July 2016
        factoriesToTest = factoriesForTQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '12x12', '100', 'TQFP');
        factoriesToTest.sort();
        
        factoriesToTest = factoriesForTQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '14x14', '52', 'TQFP');
        
        
        factoriesToTest = factoriesForTQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '14x14', '64', 'TQFP');
        
        //till here

        factoriesToTest = factoriesForTQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '14x14', '100', 'TQFP');
        system.assert(factoriesForTQFP.equals(factoriesToTest));

        factoriesToTest = factoriesForTQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '16x16', '144', 'TQFP');
        factoriesToTest.sort();
        system.assert(factoriesToTest.size() == 1);
        system.assert(factoriesToTest[0].Name == 'P1');

        factoriesToTest = factoriesForTQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '20x20', '176', 'TQFP');
        factoriesToTest.sort();
        system.assert(factoriesToTest.size() == 2);
        system.assert(factoriesToTest[0].Name == 'K1');
        system.assert(factoriesToTest[1].Name == 'T1');
        
        factoriesToTest = factoriesForTQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '20x20', '128', 'TQFP');
        factoriesToTest.sort();
        
    }

    private static testMethod void testMQFP() {
        List<Factory__c> factoriesForMQFP = setupTest('MQFP');
        List<Factory__c> factoriesToTest = factoriesForMQFP.clone();

        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '14x14', '80', 'MQFP');
        factoriesToTest.sort();
        system.assert(factoriesToTest.size() == 1);
        system.assert(factoriesToTest[0].Name == 'P1');
        
        //Bhanu S 26 July 2016
        factoriesToTest = factoriesForMQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '14x20', '64', 'MQFP');
        factoriesToTest.sort();
        
        factoriesToTest = factoriesForMQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '14x20', '80', 'MQFP');
        factoriesToTest.sort();
        
        factoriesToTest = factoriesForMQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '14x20', '128', 'MQFP');
        factoriesToTest.sort();
        
        factoriesToTest = factoriesForMQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '28x28', '120', 'MQFP');
        factoriesToTest.sort();
        
        factoriesToTest = factoriesForMQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '28x28', '160', 'MQFP');
        factoriesToTest.sort();
        //till here
        
        factoriesToTest = factoriesForMQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '14x20', '100', 'MQFP');
        factoriesToTest.sort();
        system.assert(factoriesToTest.size() == 3);
        system.assert(factoriesToTest[0].Name == 'J1');
        system.assert(factoriesToTest[1].Name == 'P1');
        system.assert(factoriesToTest[2].Name == 'T1');

        factoriesToTest = factoriesForMQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '28x28', '256', 'MQFP');
        factoriesToTest.sort();
        system.assert(factoriesToTest.isEmpty());

        factoriesToTest = factoriesForMQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '10x10', '52', 'MQFP');
        factoriesToTest.sort();
        system.assert(factoriesToTest.size() == 1);
        system.assert(factoriesToTest[0].Name == 'P1');

        factoriesToTest = factoriesForMQFP.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '32x32', '240', 'MQFP');
        factoriesToTest.sort();
        system.assert(factoriesToTest.size() == 1);
        system.assert(factoriesToTest[0].Name == 'P1');
    }

    private static testMethod void testMQFPHS() {
        List<Factory__c> factoriesForMQFPHS = setupTest('MQFPHS');
        List<Factory__c> factoriesToTest = factoriesForMQFPHS.clone();

        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '14x14', '64', 'MQFP W/ Heat Spreader');
        factoriesToTest.sort();
        system.assert(factoriesToTest.size() == 1);
        system.assert(factoriesToTest[0].Name == 'P1');
        
        //Bhanu S 26 July 2016
        factoriesToTest = factoriesForMQFPHS.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '14x20', '100', 'MQFP W/ Heat Spreader');
        factoriesToTest.sort();
        
        factoriesToTest = factoriesForMQFPHS.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '28x28', '120', 'MQFP W/ Heat Spreader');
        factoriesToTest.sort();
        
        factoriesToTest = factoriesForMQFPHS.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '28x28', '128', 'MQFP W/ Heat Spreader');
        factoriesToTest.sort();
        
        factoriesToTest = factoriesForMQFPHS.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '28x28', '160', 'MQFP W/ Heat Spreader');
        factoriesToTest.sort();
        
        factoriesToTest = factoriesForMQFPHS.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '28x28', '256', 'MQFP W/ Heat Spreader');
        factoriesToTest.sort();
        
        //till here
        factoriesToTest = factoriesForMQFPHS.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '14x20', '128', 'MQFP W/ Heat Spreader');
        factoriesToTest.sort();
        system.assert(factoriesToTest.isEmpty());

        factoriesToTest = factoriesForMQFPHS.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '28x28', '208', 'MQFP W/ Heat Spreader');
        factoriesToTest.sort();
        system.assert(factoriesToTest.size() == 2);
        system.assert(factoriesToTest[0].Name == 'P1');
        system.assert(factoriesToTest[1].Name == 'T1');

        factoriesToTest = factoriesForMQFPHS.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '32x32', '240', 'MQFP W/ Heat Spreader');
        factoriesToTest.sort();
        system.assert(factoriesToTest.size() == 1);
        system.assert(factoriesToTest[0].Name == 'P1');
    }

    private static testMethod void testPowerQuad() {
        List<Factory__c> factoriesForPowerQuad = setupTest('PowerQuad');
        List<Factory__c> factoriesToTest = factoriesForPowerQuad.clone();

        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '28x28', '144', 'PowerQuad 4');
        system.assert(factoriesToTest.isEmpty());

        factoriesToTest = factoriesForPowerQuad.clone();
        FactoryUtil.getFactoryOptionsForQuad(factoriesToTest, '32x32', '230', 'PowerQuad 4');
        factoriesToTest.sort();
        system.assert(factoriesToTest.size() == 1);
        system.assert(factoriesToTest[0].Name == 'P1');

    }
}