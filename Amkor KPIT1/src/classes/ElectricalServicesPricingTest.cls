/*************************************************************************
* 
* PURPOSE:  Unit Tests for ElectricalServicesPricing
*         
* CLASS: ForecastUtil
* CREATED: 12/20/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Raghuveer Mandali
* 
**************************************************************************/
@isTest
private class ElectricalServicesPricingTest {
	
	private static RFQItemWrapper setup() {
		RFQAdminInstaller.install();
		RFQAdminInstaller.AMK1563();
		EngineeringServiceInstaller.installServiceSection();
		EngineeringServiceInstaller.install();
		EngineeringServiceInstaller.AMK1726();

		return SharedUnitTestUtils.createLineItem('Electrical Services');
	}
	
	private static testMethod void test3DRLCExtractionPricing() {
		RFQItemWrapper wrapper = setup();

		wrapper.specificRfqItem.put('Electrical_Services__c', '3D RLC Extraction');
		wrapper.specificRfqItem.put('Substrate__c', 'Laminate FC');
		wrapper.specificRfqItem.put('Number_of_Balls__c', '<100');
		wrapper.specificRfqItem.put('Number_of_Die__c', '4');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 4000);

		wrapper.specificRfqItem.put('Number_of_Balls__c', '100-200');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 4500);

		wrapper.specificRfqItem.put('Number_of_Balls__c', '201-300');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 5000);

		wrapper.specificRfqItem.put('Number_of_Balls__c', '301-400');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 5500);

		wrapper.specificRfqItem.put('Number_of_Balls__c', '401-500');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 6000);

		wrapper.specificRfqItem.put('Number_of_Balls__c', '501- 600');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 8000);

		wrapper.specificRfqItem.put('Number_of_Balls__c', '>600');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 10000);

		wrapper.specificRfqItem.put('Substrate__c', 'Leadframe Wirebond');
		wrapper.specificRfqItem.put('Number_of_Wirebonds__c', '<25');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 4000);

		wrapper.specificRfqItem.put('Number_of_Wirebonds__c', '25-50');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 5000);

		wrapper.specificRfqItem.put('Number_of_Wirebonds__c', '51-75');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 6000);

		wrapper.specificRfqItem.put('Number_of_Wirebonds__c', '76-100');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 7000);

		wrapper.specificRfqItem.put('Substrate__c', 'Leadframe FC');
		wrapper.specificRfqItem.put('Number_of_Bumps_PK__c', '<25');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 4000);

		wrapper.specificRfqItem.put('Number_of_Bumps_PK__c', '25-50');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 5000);

		wrapper.specificRfqItem.put('Number_of_Bumps_PK__c', '51-75');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 6000);

		wrapper.specificRfqItem.put('Number_of_Bumps_PK__c', '76-100');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 7000);
	}

	private static testMethod void testSParameterExtractionPricing() {
		RFQItemWrapper wrapper = setup();

		wrapper.specificRfqItem.put('Electrical_Services__c', 'S-Parameter Extraction');
		wrapper.specificRfqItem.put('Substrate__c', 'Laminate Wirebond');
		wrapper.specificRfqItem.put('Number_of_Signal_Wirebonds__c', '2-4');
		wrapper.specificRfqItem.put('Number_of_Layers__c', '>=8');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 4000);

		wrapper.specificRfqItem.put('Number_of_Signal_Wirebonds__c', '5-8');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 5000);

		wrapper.specificRfqItem.put('Number_of_Signal_Wirebonds__c', '9-12');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 6000);

		wrapper.specificRfqItem.put('Number_of_Signal_Wirebonds__c', '13-16');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 8000);

		wrapper.specificRfqItem.put('Substrate__c', 'Laminate FC');
		wrapper.specificRfqItem.put('Number_of_Signal_Bumps__c', '2-4');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 4000);

		wrapper.specificRfqItem.put('Number_of_Signal_Bumps__c', '5-8');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 5000);

		wrapper.specificRfqItem.put('Number_of_Signal_Bumps__c', '9-12');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 6000);

		wrapper.specificRfqItem.put('Number_of_Signal_Bumps__c', '13-16');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 8000);

		wrapper.specificRfqItem.put('Substrate__c', 'Leadframe Wirebond');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 7000);

		wrapper.specificRfqItem.put('Substrate__c', 'Leadframe FC');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 7000);
	}

	private static testMethod void testIRDropAnalysisPricing() {
		RFQItemWrapper wrapper = setup();

		wrapper.specificRfqItem.put('Electrical_Services__c', 'IR Drop Analysis');
		wrapper.specificRfqItem.put('Substrate__c', 'Laminate FC');
		wrapper.specificRfqItem.put('Number_of_Power_Domains__c', '>=8');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 3000);

		wrapper.specificRfqItem.put('Substrate__c', 'Laminate Wirebond');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 3500);
	}

	private static testMethod void testParallelBusAnalysisPricing() {
		RFQItemWrapper wrapper = setup();

		wrapper.specificRfqItem.put('Electrical_Services__c', 'Parallel Bus Analysis (SSN, IO Supply Collapse)');
		wrapper.specificRfqItem.put('Substrate__c', 'Laminate Wirebond');
		wrapper.specificRfqItem.put('Bus_Width__c', '8');
		wrapper.specificRfqItem.put('Simulation_Direction__c', 'Read');
		wrapper.specificRfqItem.put('Process_Corner__c', 'Fast');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 5000);

		wrapper.specificRfqItem.put('Process_Corner__c', 'Fast and Typical and Slow');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 7500);

		wrapper.specificRfqItem.put('Simulation_Direction__c', 'Read and Write');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 10500);

		wrapper.specificRfqItem.put('Process_Corner__c', 'Fast');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 8000);

		wrapper.specificRfqItem.put('Bus_Width__c', '16');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 10500);

		wrapper.specificRfqItem.put('Process_Corner__c', 'Fast and Typical and Slow');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 13000);

		wrapper.specificRfqItem.put('Simulation_Direction__c', 'Read');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 10000);

		wrapper.specificRfqItem.put('Process_Corner__c', 'Fast');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 7500);

		wrapper.specificRfqItem.put('Bus_Width__c', '32');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 10000);

		wrapper.specificRfqItem.put('Process_Corner__c', 'Fast and Typical and Slow');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 12500);

		wrapper.specificRfqItem.put('Simulation_Direction__c', 'Read and Write');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 15500);

		wrapper.specificRfqItem.put('Process_Corner__c', 'Fast');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 13000);

		wrapper.specificRfqItem.put('Bus_Width__c', '64');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 15500);

		wrapper.specificRfqItem.put('Process_Corner__c', 'Fast and Typical and Slow');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 18000);

		wrapper.specificRfqItem.put('Simulation_Direction__c', 'Read');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 15000);

		wrapper.specificRfqItem.put('Process_Corner__c', 'Fast');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 12500);

		wrapper.specificRfqItem.put('Bus_Width__c', '72');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 15000);

		wrapper.specificRfqItem.put('Process_Corner__c', 'Fast and Typical and Slow');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 17500);

		wrapper.specificRfqItem.put('Simulation_Direction__c', 'Read and Write');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 20500);

		wrapper.specificRfqItem.put('Process_Corner__c', 'Fast');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 18000);
	}

	private static testMethod void testPowerIntegrityAnalysisPricing() {
		RFQItemWrapper wrapper = setup();

		wrapper.specificRfqItem.put('Electrical_Services__c', 'Power Integrity Analysis (F, T Domain)');
		wrapper.specificRfqItem.put('Substrate__c', 'Laminate Wirebond');
		wrapper.specificRfqItem.put('Number_of_Power_Domains__c', '1');
		wrapper.specificRfqItem.put('Time_or_Frequency_Domain__c', 'Frequency Domain');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 2500);

		wrapper.specificRfqItem.put('Time_or_Frequency_Domain__c', 'Time Domain');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 3500);

		wrapper.specificRfqItem.put('Time_or_Frequency_Domain__c', 'Both Frequency and Time Domain');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 4500);

		wrapper.specificRfqItem.put('Number_of_Power_Domains__c', '2-4');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 5500);

		wrapper.specificRfqItem.put('Time_or_Frequency_Domain__c', 'Time Domain');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 4000);

		wrapper.specificRfqItem.put('Time_or_Frequency_Domain__c', 'Frequency Domain');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 3000);

		wrapper.specificRfqItem.put('Number_of_Power_Domains__c', '5-7');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 4000);

		wrapper.specificRfqItem.put('Time_or_Frequency_Domain__c', 'Time Domain');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 5000);

		wrapper.specificRfqItem.put('Time_or_Frequency_Domain__c', 'Both Frequency and Time Domain');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 7500);

		wrapper.specificRfqItem.put('Number_of_Power_Domains__c', '>=8');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 9500);

		wrapper.specificRfqItem.put('Time_or_Frequency_Domain__c', 'Time Domain');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 6000);

		wrapper.specificRfqItem.put('Time_or_Frequency_Domain__c', 'Frequency Domain');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 5000);
	}

	private static testMethod void testSerialLinkPricing() {
		RFQItemWrapper wrapper = setup();

		wrapper.specificRfqItem.put('Electrical_Services__c', 'Serial Link (Channel) Analysis');
		wrapper.specificRfqItem.put('Substrate__c', 'Laminate Wirebond');
		wrapper.specificRfqItem.put('Number_of_Lanes__c', '1');
		wrapper.specificRfqItem.put('Simulation_Direction_SLA__c', 'RX');
		wrapper.specificRfqItem.put('Buffer_Model_Type__c', 'IBIS AMI');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 4000);

		wrapper.specificRfqItem.put('Buffer_Model_Type__c', 'Spice');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 8000);

		wrapper.specificRfqItem.put('Simulation_Direction_SLA__c', 'RX and TX');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 9000);

		wrapper.specificRfqItem.put('Buffer_Model_Type__c', 'IBIS AMI');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 5000);

		wrapper.specificRfqItem.put('Number_of_Lanes__c', '4');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 6000);

		wrapper.specificRfqItem.put('Buffer_Model_Type__c', 'Spice');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 10000);

		wrapper.specificRfqItem.put('Simulation_Direction_SLA__c', 'RX');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 9000);

		wrapper.specificRfqItem.put('Buffer_Model_Type__c', 'IBIS AMI');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 5000);

		wrapper.specificRfqItem.put('Number_of_Lanes__c', '8');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 6000);

		wrapper.specificRfqItem.put('Buffer_Model_Type__c', 'Spice');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 10000);

		wrapper.specificRfqItem.put('Simulation_Direction_SLA__c', 'RX and TX');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 12000);

		wrapper.specificRfqItem.put('Buffer_Model_Type__c', 'IBIS AMI');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 8000);

		wrapper.specificRfqItem.put('Number_of_Lanes__c', '16');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 10000);

		wrapper.specificRfqItem.put('Buffer_Model_Type__c', 'Spice');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 15000);

		wrapper.specificRfqItem.put('Simulation_Direction_SLA__c', 'RX');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 12000);

		wrapper.specificRfqItem.put('Buffer_Model_Type__c', 'IBIS AMI');

		system.assert(ElectricalServicesPricing.electricalServicesPricing(wrapper) == 8000);

	}
}