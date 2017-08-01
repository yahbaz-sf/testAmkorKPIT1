/*************************************************************************
* 
* PURPOSE:  Pricing class for Engineering Service Product Group
*          
*         
* CLASS: ElectricalServicesPricing
* CREATED: 12/20/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Raghuveer Mandali
* 
**************************************************************************/

public class ElectricalServicesPricing {
    
	public static Decimal electricalServicesPricing(RFQItemWrapper wrapper) {
        String electricalService = (String)wrapper.specificRfqItem.get('Electrical_Services__c');
        Decimal pricing = null;

        if(electricalService == '3D RLC Extraction') {
            String substrate = (String)wrapper.specificRfqItem.get('Substrate__c');
            String numOfDie = (String)wrapper.specificRfqItem.get('Number_of_Die__c');
            String numOfBalls = (String)wrapper.specificRfqItem.get('Number_of_Balls__c');
            String numOfWirebonds = (String)wrapper.specificRfqItem.get('Number_of_Wirebonds__c');
            String numOfBumps = (String)wrapper.specificRfqItem.get('Number_of_Bumps_PK__c');

            if(substrate == 'Laminate Wirebond' || substrate == 'Laminate FC') {

                if(numOfBalls == '<100') {
                    if(numOfDie == '1') {
                        pricing = 2000;
                    }
                    else if(numOfDie == '2' || numOfDie == '3') {
                        pricing = 3000;
                    }
                    else if(numOfDie == '4' || numOfDie == '5') {
                        pricing = 4000;
                    }
                }
                else if(numOfBalls == '100-200') {
                    if(numOfDie == '1') {
                        if(substrate == 'Laminate Wirebond') {pricing = 3000;}
                        else {pricing = 2500;}
                    }
                    else if(numOfDie == '2' || numOfDie == '3') {
                        if(substrate == 'Laminate Wirebond') {pricing = 4000;}
                        else {pricing = 3500;}
                    }
                    else if(numOfDie == '4' || numOfDie == '5') {
                        if(substrate == 'Laminate Wirebond') {pricing = 5000;}
                        else {pricing = 4500;}
                    }
                }
                else if(numOfBalls == '201-300') {
                    if(numOfDie == '1') {
                        if(substrate == 'Laminate Wirebond') {pricing = 3500;}
                        else {pricing = 3000;}
                    }
                    else if(numOfDie == '2' || numOfDie == '3') {
                        if(substrate == 'Laminate Wirebond') {pricing = 4500;}
                        else {pricing = 4000;}
                    }
                    else if(numOfDie == '4' || numOfDie == '5') {
                        if(substrate == 'Laminate Wirebond') {pricing = 5500;}
                        else {pricing = 5000;}
                    }
                }
                else if(numOfBalls == '301-400') {
                    if(numOfDie == '1') {
                        if(substrate == 'Laminate Wirebond') {pricing = 4000;}
                        else {pricing = 3500;}
                    }
                    else if(numOfDie == '2' || numOfDie == '3') {
                        if(substrate == 'Laminate Wirebond') {pricing = 5000;}
                        else {pricing = 4500;}
                    }
                    else if(numOfDie == '4' || numOfDie == '5') {
                        if(substrate == 'Laminate Wirebond') {pricing = 6000;}
                        else {pricing = 5500;}
                    }
                }
                else if(numOfBalls == '401-500') {
                    if(numOfDie == '1') {
                        if(substrate == 'Laminate Wirebond') {pricing = 4500;}
                        else {pricing = 4000;}
                    }
                    else if(numOfDie == '2' || numOfDie == '3') {
                        if(substrate == 'Laminate Wirebond') {pricing = 5500;}
                        else {pricing = 5000;}
                    }
                    else if(numOfDie == '4' || numOfDie == '5') {
                        if(substrate == 'Laminate Wirebond') {pricing = 6500;}
                        else {pricing = 6000;}
                    }
                }
                else if(numOfBalls == '501- 600') {
                    if(numOfDie == '1') {
                        if(substrate == 'Laminate Wirebond') {pricing = 5000;}
                        else {pricing = 6000;}
                    }
                    else if(numOfDie == '2' || numOfDie == '3') {
                        if(substrate == 'Laminate Wirebond') {pricing = 6000;}
                        else {pricing = 7000;}
                    }
                    else if(numOfDie == '4' || numOfDie == '5') {
                        if(substrate == 'Laminate Wirebond') {pricing = 7000;}
                        else {pricing = 8000;}
                    }
                }
                else if(numOfBalls == '>600') {
                    if(numOfDie == '1') {
                        if(substrate == 'Laminate Wirebond') {pricing = 5500;}
                        else {pricing = 8000;}
                    }
                    else if(numOfDie == '2' || numOfDie == '3') {
                        if(substrate == 'Laminate Wirebond') {pricing = 6500;}
                        else {pricing = 9000;}
                    }
                    else if(numOfDie == '4' || numOfDie == '5') {
                        if(substrate == 'Laminate Wirebond') {pricing = 7500;}
                        else {pricing = 10000;}
                    }
                }
            }
            else if(substrate == 'Leadframe FC' || substrate == 'Wafer Level') {
                if(numOfBumps == '<25') {
                    if(numOfDie == '1') {
                        pricing = 2000;
                    }
                    else if(numOfDie == '2' || numOfDie == '3') {
                        pricing = 3000;
                    }
                    else if(numOfDie == '4' || numOfDie == '5') {
                        pricing = 4000;
                    }
                }
                else if(numOfBumps == '25-50') {
                    if(numOfDie == '1') {
                        pricing = 3000;
                    }
                    else if(numOfDie == '2' || numOfDie == '3') {
                        pricing = 4000;
                    }
                    else if(numOfDie == '4' || numOfDie == '5') {
                        pricing = 5000;
                    }
                }
                else if(numOfBumps == '51-75') {
                    if(numOfDie == '1') {
                        pricing = 4000;
                    }
                    else if(numOfDie == '2' || numOfDie == '3') {
                        pricing = 5000;
                    }
                    else if(numOfDie == '4' || numOfDie == '5') {
                        pricing = 6000;
                    }
                }
                else if(numOfBumps == '76-100') {
                    if(numOfDie == '1') {
                        pricing = 5000;
                    }
                    else if(numOfDie == '2' || numOfDie == '3') {
                        pricing = 6000;
                    }
                    else if(numOfDie == '4' || numOfDie == '5') {
                        pricing = 7000;
                    }
                }
            }
            else if(substrate == 'Leadframe Wirebond') {
                if(numOfWirebonds == '<25') {
                    if(numOfDie == '1') {
                        pricing = 2000;
                    }
                    else if(numOfDie == '2' || numOfDie == '3') {
                        pricing = 3000;
                    }
                    else if(numOfDie == '4' || numOfDie == '5') {
                        pricing = 4000;
                    }
                }
                else if(numOfWirebonds == '25-50') {
                    if(numOfDie == '1') {
                        pricing = 3000;
                    }
                    else if(numOfDie == '2' || numOfDie == '3') {
                        pricing = 4000;
                    }
                    else if(numOfDie == '4' || numOfDie == '5') {
                        pricing = 5000;
                    }
                }
                else if(numOfWirebonds == '51-75') {
                    if(numOfDie == '1') {
                        pricing = 4000;
                    }
                    else if(numOfDie == '2' || numOfDie == '3') {
                        pricing = 5000;
                    }
                    else if(numOfDie == '4' || numOfDie == '5') {
                        pricing = 6000;
                    }
                }
                else if(numOfWirebonds == '76-100') {
                    if(numOfDie == '1') {
                        pricing = 5000;
                    }
                    else if(numOfDie == '2' || numOfDie == '3') {
                        pricing = 6000;
                    }
                    else if(numOfDie == '4' || numOfDie == '5') {
                        pricing = 7000;
                    }
                }
            }

        }
        else if(electricalService == 'S-Parameter Extraction') {
            String substrate = (String)wrapper.specificRfqItem.get('Substrate__c');
            String numOfLayers = (String)wrapper.specificRfqItem.get('Number_of_Layers__c');
            String numOfSignalWire = (String)wrapper.specificRfqItem.get('Number_of_Signal_Wirebonds__c');
            String numOfSignalBump = (String)wrapper.specificRfqItem.get('Number_of_Signal_Bumps__c');

            if(substrate == 'Laminate Wirebond') {
                if(numOfSignalWire == '2-4') {
                    if(numOfLayers == '<=4') {
                        pricing = 2000;
                    }
                    else if(numOfLayers == '6') {
                        pricing = 3000;
                    }
                    else if(numOfLayers == '>=8') {
                        pricing = 4000;
                    }
                }
                else if(numOfSignalWire == '5-8') {
                    if(numOfLayers == '<=4') {
                        pricing = 3000;
                    }
                    else if(numOfLayers == '6') {
                        pricing = 4000;
                    }
                    else if(numOfLayers == '>=8') {
                        pricing = 5000;
                    }
                }
                else if(numOfSignalWire == '9-12') {
                    if(numOfLayers == '<=4') {
                        pricing = 4000;
                    }
                    else if(numOfLayers == '6') {
                        pricing = 5000;
                    }
                    else if(numOfLayers == '>=8') {
                        pricing = 6000;
                    }
                }
                else if(numOfSignalWire == '13-16') {
                    if(numOfLayers == '<=4') {
                        pricing = 6000;
                    }
                    else if(numOfLayers == '6') {
                        pricing = 7000;
                    }
                    else if(numOfLayers == '>=8') {
                        pricing = 8000;
                    }
                }
            }
            else if(substrate == 'Laminate FC') {
                if(numOfSignalBump == '2-4') {
                    if(numOfLayers == '<=4') {
                        pricing = 2000;
                    }
                    else if(numOfLayers == '6') {
                        pricing = 3000;
                    }
                    else if(numOfLayers == '>=8') {
                        pricing = 4000;
                    }
                }
                else if(numOfSignalBump == '5-8') {
                    if(numOfLayers == '<=4') {
                        pricing = 3000;
                    }
                    else if(numOfLayers == '6') {
                        pricing = 4000;
                    }
                    else if(numOfLayers == '>=8') {
                        pricing = 5000;
                    }
                }
                else if(numOfSignalBump == '9-12') {
                    if(numOfLayers == '<=4') {
                        pricing = 4000;
                    }
                    else if(numOfLayers == '6') {
                        pricing = 5000;
                    }
                    else if(numOfLayers == '>=8') {
                        pricing = 6000;
                    }
                }
                else if(numOfSignalBump == '13-16') {
                    if(numOfLayers == '<=4') {
                        pricing = 6000;
                    }
                    else if(numOfLayers == '6') {
                        pricing = 7000;
                    }
                    else if(numOfLayers == '>=8') {
                        pricing = 8000;
                    }
                }
             }
            else if(substrate == 'Leadframe Wirebond') {
                if(numOfSignalWire == '2-4') {
                    pricing = 3000;
                }
                else if(numOfSignalWire == '5-8') {
                    pricing = 4000;
                }
                else if(numOfSignalWire == '9-12') {
                    pricing = 5000;
                }
                else if(numOfSignalWire == '13-16') {
                    pricing = 7000;
                }
            }
            else if(substrate == 'Leadframe FC' || substrate == 'Wafer Level') {
                if(numOfSignalBump == '2-4') {
                    pricing = 3000;
                }
                else if(numOfSignalBump == '5-8') {
                    pricing = 4000;
                }
                else if(numOfSignalBump == '9-12') {
                    pricing = 5000;
                }
                else if(numOfSignalBump == '13-16') {
                    pricing = 7000;
                }
            }
        }
        else if(electricalService == 'IR Drop Analysis') {
            String substrate = (String)wrapper.specificRfqItem.get('Substrate__c');
            String numOfPowerDomains = (String)wrapper.specificRfqItem.get('Number_of_Power_Domains__c');

            if(substrate == 'Laminate FC') {
                if(numOfPowerDomains == '1') {
                    pricing = 1500;
                }
                else if(numOfPowerDomains == '2-4') {
                    pricing = 2000;
                }
                else if(numOfPowerDomains == '5-7') {
                    pricing = 2500;
                }
                else if(numOfPowerDomains == '>=8') {
                    pricing = 3000;
                }
            }
            else if(substrate == 'Laminate Wirebond') {
                if(numOfPowerDomains == '1') {
                    pricing = 2000;
                }
                else if(numOfPowerDomains == '2-4') {
                    pricing = 2500;
                }
                else if(numOfPowerDomains == '5-7') {
                    pricing = 3000;
                }
                else if(numOfPowerDomains == '>=8') {
                    pricing = 3500;
                }
            }
        }
        else if(electricalService == 'Parallel Bus Analysis (SSN, IO Supply Collapse)') {
            String substrate = (String)wrapper.specificRfqItem.get('Substrate__c');
            String buswidth = (String)wrapper.specificRfqItem.get('Bus_Width__c');
            String simulationDirection = (String)wrapper.specificRfqItem.get('Simulation_Direction__c');
            String processCorner = (String)wrapper.specificRfqItem.get('Process_Corner__c');

            if(substrate == 'Laminate Wirebond' || substrate == 'Laminate FC') {
                if(buswidth == '8') {
                    if(simulationDirection == 'Read' || simulationDirection == 'Write') {
                        if(processCorner == 'Fast' || processCorner == 'Slow' || processCorner == 'Typical') {
                            pricing = 5000;
                        }
                        else if(processCorner == 'Fast and Typical and Slow') {
                            pricing = 7500;
                        }
                    }
                    else if(simulationDirection == 'Read and Write') {
                        if(processCorner == 'Fast' || processCorner == 'Slow' || processCorner == 'Typical') {
                            pricing = 8000;
                        }
                        else if(processCorner == 'Fast and Typical and Slow') {
                            pricing = 10500;
                        }
                    }
                }
                else if(buswidth == '16') {
                    if(simulationDirection == 'Read' || simulationDirection == 'Write') {
                        if(processCorner == 'Fast' || processCorner == 'Slow' || processCorner == 'Typical') {
                            pricing = 7500;
                        }
                        else if(processCorner == 'Fast and Typical and Slow') {
                            pricing = 10000;
                        }
                    }
                    else if(simulationDirection == 'Read and Write') {
                        if(processCorner == 'Fast' || processCorner == 'Slow' || processCorner == 'Typical') {
                            pricing = 10500;
                        }
                        else if(processCorner == 'Fast and Typical and Slow') {
                            pricing = 13000;
                        }
                    }
                }
                else if(buswidth == '32') {
                    if(simulationDirection == 'Read' || simulationDirection == 'Write') {
                        if(processCorner == 'Fast' || processCorner == 'Slow' || processCorner == 'Typical') {
                            pricing = 10000;
                        }
                        else if(processCorner == 'Fast and Typical and Slow') {
                            pricing = 12500;
                        }
                    }
                    else if(simulationDirection == 'Read and Write') {
                        if(processCorner == 'Fast' || processCorner == 'Slow' || processCorner == 'Typical') {
                            pricing = 13000;
                        }
                        else if(processCorner == 'Fast and Typical and Slow') {
                            pricing = 15500;
                        }
                    }
                }
                else if(buswidth == '64') {
                    if(simulationDirection == 'Read' || simulationDirection == 'Write') {
                        if(processCorner == 'Fast' || processCorner == 'Slow' || processCorner == 'Typical') {
                            pricing = 12500;
                        }
                        else if(processCorner == 'Fast and Typical and Slow') {
                            pricing = 15000;
                        }
                    }
                    else if(simulationDirection == 'Read and Write') {
                        if(processCorner == 'Fast' || processCorner == 'Slow' || processCorner == 'Typical') {
                            pricing = 15500;
                        }
                        else if(processCorner == 'Fast and Typical and Slow') {
                            pricing = 18000;
                        }
                    }
                }
                else if(buswidth == '72') {
                    if(simulationDirection == 'Read' || simulationDirection == 'Write') {
                        if(processCorner == 'Fast' || processCorner == 'Slow' || processCorner == 'Typical') {
                            pricing = 15000;
                        }
                        else if(processCorner == 'Fast and Typical and Slow') {
                            pricing = 17500;
                        }
                    }
                    else if(simulationDirection == 'Read and Write') {
                        if(processCorner == 'Fast' || processCorner == 'Slow' || processCorner == 'Typical') {
                            pricing = 18000;
                        }
                        else if(processCorner == 'Fast and Typical and Slow') {
                            pricing = 20500;
                        }
                    }
                }
            }
        }
        else if(electricalService == 'Power Integrity Analysis (F, T Domain)') {
            String substrate = (String)wrapper.specificRfqItem.get('Substrate__c');
            String numOfPowerDomains = (String)wrapper.specificRfqItem.get('Number_of_Power_Domains__c');
            String timeOrFrequencyDomain = (String)wrapper.specificRfqItem.get('Time_or_Frequency_Domain__c');

            if(substrate == 'Laminate Wirebond' || substrate == 'Laminate FC') {
                if(numOfPowerDomains == '1') {
                    if(timeOrFrequencyDomain == 'Frequency Domain') {
                        pricing = 2500;
                    }
                    else if(timeOrFrequencyDomain == 'Time Domain') {
                        pricing = 3500;
                    }
                    else if(timeOrFrequencyDomain == 'Both Frequency and Time Domain') {
                        pricing = 4500;
                    }
                }
                else if(numOfPowerDomains == '2-4') {
                    if(timeOrFrequencyDomain == 'Frequency Domain') {
                        pricing = 3000;
                    }
                    else if(timeOrFrequencyDomain == 'Time Domain') {
                        pricing = 4000;
                    }
                    else if(timeOrFrequencyDomain == 'Both Frequency and Time Domain') {
                        pricing = 5500;
                    }
                }
                else if(numOfPowerDomains == '5-7') {
                    if(timeOrFrequencyDomain == 'Frequency Domain') {
                        pricing = 4000;
                    }
                    else if(timeOrFrequencyDomain == 'Time Domain') {
                        pricing = 5000;
                    }
                    else if(timeOrFrequencyDomain == 'Both Frequency and Time Domain') {
                        pricing = 7500;
                    }
                }
                else if(numOfPowerDomains == '>=8') {
                    if(timeOrFrequencyDomain == 'Frequency Domain') {
                        pricing = 5000;
                    }
                    else if(timeOrFrequencyDomain == 'Time Domain') {
                        pricing = 6000;
                    }
                    else if(timeOrFrequencyDomain == 'Both Frequency and Time Domain') {
                        pricing = 9500;
                    }
                }
            }
        }
        else if(electricalService == 'Serial Link (Channel) Analysis') {
            String substrate = (String)wrapper.specificRfqItem.get('Substrate__c');
            String numOfLanes = (String)wrapper.specificRfqItem.get('Number_of_Lanes__c');
            String simulationDirection = (String)wrapper.specificRfqItem.get('Simulation_Direction_SLA__c');
            String bufferModelType = (String)wrapper.specificRfqItem.get('Buffer_Model_Type__c');

            if(substrate == 'Laminate Wirebond' || substrate == 'Laminate FC') {
                if(numOfLanes == '1') {
                    if(simulationDirection == 'RX' || simulationDirection == 'TX') {
                        if(bufferModelType == 'IBIS AMI') {
                            pricing = 4000;
                        }
                        else if(bufferModelType == 'Spice') {
                            pricing = 8000;
                        }
                    }
                    else if(simulationDirection == 'RX and TX') {
                        if(bufferModelType == 'IBIS AMI') {
                            pricing = 5000;
                        }
                        else if(bufferModelType == 'Spice') {
                           pricing = 9000; 
                        }
                    }
                }
                else if(numOfLanes == '4') {
                    if(simulationDirection == 'RX' || simulationDirection == 'TX') {
                        if(bufferModelType == 'IBIS AMI') {
                            pricing = 5000;
                        }
                        else if(bufferModelType == 'Spice') {
                            pricing = 9000;
                        }
                    }
                    else if(simulationDirection == 'RX and TX') {
                        if(bufferModelType == 'IBIS AMI') {
                            pricing = 6000;
                        }
                        else if(bufferModelType == 'Spice') {
                           pricing = 10000; 
                        }
                    }
                }
                else if(numOfLanes == '8') {
                    if(simulationDirection == 'RX' || simulationDirection == 'TX') {
                        if(bufferModelType == 'IBIS AMI') {
                            pricing = 6000;
                        }
                        else if(bufferModelType == 'Spice') {
                            pricing = 10000;
                        }
                    }
                    else if(simulationDirection == 'RX and TX') {
                        if(bufferModelType == 'IBIS AMI') {
                            pricing = 8000;
                        }
                        else if(bufferModelType == 'Spice') {
                           pricing = 12000; 
                        }
                    }
                }
                else if(numOfLanes == '16') {
                    if(simulationDirection == 'RX' || simulationDirection == 'TX') {
                        if(bufferModelType == 'IBIS AMI') {
                            pricing = 8000;
                        }
                        else if(bufferModelType == 'Spice') {
                            pricing = 12000;
                        }
                    }
                    else if(simulationDirection == 'RX and TX') {
                        if(bufferModelType == 'IBIS AMI') {
                            pricing = 10000;
                        }
                        else if(bufferModelType == 'Spice') {
                           pricing = 15000; 
                        }
                    }
                }
            }
        }
        return pricing;
    }
}