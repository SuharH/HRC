workspace "Hospital Room Control (HRC) workspace" "This workspace documents the status of the rooms of the hospital." {

    model {
        //ARCHITECTURE OBJECTS DEFINITION
        hrc = softwareSystem "Hospital Room Control (HRC)" "Stores and manages the status of each and every room in the hospital."    {
            webFrontend = container "HRC Web Front-end" "Allows the viewing of the real time status of the rooms as well as changing the displayed values." "TypeScript" "Web Front-End"

            server = container "HRC Server" "Implements all business functionality for browsing and viewing data records and provides it via API." "Node.js"   {
                group "Infrastructure"  {
                    detailAPI = component "Record Detail API" "Provides API for getting a detail of a given data record via API." "" "Infrastructure"
                    recordDetailGateway = component "data Detail Gateway" "Provides access to a data records store." "" "Infrastructure"
					modificationDetailGateway = component "modification Detail Gateway" "Provides access to a data records modifications." "" "Infrastructure"
                }
                group "Business Logic"  {
                    detailController = component "Record Detail Controller" "Implements and provides business functionality related to viewing details of data records." "" "Logic"
					modificationController = component "Record Modification Controller" "Implements and provides business functionality related to updating details of data records." "" "Logic"
				}
                group "Domain Model"    {
                    datasetModel = component "Dataset" "Internal domain model of dataset data." "" "Model"
                }
            }			

            recordStorage = container "data Storage" "Storage of data records." "Apache CouchDB database"
			recordModification = container "data Modification" "Sets data modifications." "Apache CouchDB database"
            exchanger = container "data exchanger" "Harvests data records." "LinkedPipes ETL pipeline"
			
            !docs docs
        }
        
        rrs = softwareSystem "Registry of Room Status" "Registries of current status of Hospital Room materials." {
			dataGetter = container "HRC Data Getter" "Provides register reading capability." "Apache CouchDB database"
			dataSetter = container "HRC Data Setter" "Provides register writing capability." "Apache CouchDB database"
            database = container "RC database" "Storage of room information registers data." "Apache CouchDB database"
			dataCollector = container "data collector" "Harvests data from the data base and sensors." "LinkedPipes ETL pipeline"	{
				group "Infrastructure"  {
                    dataExchangeAPI = component "data Exchange API" "API for exchanging information between systems." "" "Infrastructure"
					sensorInformationAPI = component "sensor Information API" "API for obtaining information from sensors." "" "Infrastructure"
                    dataGettingGateway = component "data Getter Gateway" "Provides access to a data records store." "" "Infrastructure"
					dataSettingGateway = component "data Setter Gateway" "Provides access to a data records modifications." "" "Infrastructure"
                }
                group "Business Logic"  {
                    recordGettingController = component "Record Getter Controller" "Business functionality related to viewing details of data." "" "Logic"
					recordSettingController = component "Record Setter Controller" "Business functionality related to updating details of data" "" "Logic"
				}
                group "Domain Model"    {
                    datasetModelRRS = component "RRS Dataset" "Internal model of dataset data." "" "Model"
                }
			}
						
            !docs docs
		}
		
		//LEVEL 1
        viewer = person "Viewer" "A person from the control room who supervises the status of the rooms." "Supervisor"
        admin = person "Admin" "A person from the administration who can change the values in the Database." "Administration"

        viewer -> hrc "Searchers for data records in" "HTTPS"
        admin -> hrc "Searchers and editors of data records in" "HTTPS"

        hrc -> rrs "Harvests metada records from" "HTTPS"
        
        //LEVEL 2		
		viewer -> webFrontend "Searches for the current status of a room" "HTTPS"
        admin -> webFrontend "See and-or modifies the current status of a room" "HTTPS"
        deliveryToFrontend = webFrontend -> server "Uses to deliver functionality" "HTTPS"
        server -> recordStorage "Uses for fast retrieval of data" "HTTPS"
		server -> recordModification "Uses for transfer of data modifications" "HTTPS"
        exchanger -> recordStorage "Uses to persists exchanged data" "HTTPS"
        //exchanger -> rrs "Updates records from" "HTTPS"
		exchanger -> recordModification "Uses to modify data" "HTTPS"
		
		exchanger -> dataCollector "Exchanges registered data" "HTTPS"
		
		//LEVEL 2 - REGISTRY SYSTEM
		//viewer -> hrc "Searches for the current status of a room" "HTTPS"
        //admin -> hrc "See and-or modifies the current status of a room" "HTTPS"	
		dataCollector -> dataSetter "Sends data to" "HTTPS"
        dataCollector -> dataGetter "Exchanges data with" "HTTPS"        
		dataSetter -> database "Writes register to" "HTTPS"
		database -> dataGetter "Reads register from" "HTTPS"
		
		//LEVEL 3
        webFrontend -> detailAPI "Makes API calls to" "JSON/HTTPS"

		detailAPI -> detailController "Uses to access detail business functionality"
		detailAPI -> modificationController "Uses to access modification business functionality"

        detailController -> datasetModel "Uses to access data about datasets"
		modificationController -> datasetModel "Uses to access data about datasets"

        datasetModel -> recordDetailGateway "Uses to retrieve detailed data"
		datasetModel -> modificationDetailGateway "Uses to update detailed data"
		
		recordDetailGateway -> recordStorage "Provides access to"
		modificationDetailGateway -> recordModification "Provides access to"
		
		//LEVEL 3 - REGISTRY SYSTEM 
		exchanger -> dataExchangeAPI "makes API calls to" "JSON/HTTPS"
		
		dataExchangeAPI -> recordGettingController "Uses to access detail business functionality"
		dataExchangeAPI -> recordSettingController "Uses to access modification business functionality"
		
		recordGettingController -> datasetModelRRS "Uses to access data"
		
		recordSettingController -> datasetModelRRS "Uses to access data"
		recordSettingController -> sensorInformationAPI "Updates record information from"
		
		datasetModelRRS -> dataGettingGateway "Uses to retrieve detailed data"
		datasetModelRRS -> dataSettingGateway "Uses to update detailed data"
		
		dataGettingGateway -> dataGetter "Provides access to"
		
		dataSettingGateway -> dataSetter "Provides access to"
        
        deploymentEnvironment "Development"   {
            deploymentNode "Admin PC" "" "Microsoft Windows 10 or Ubuntu 20.04 LTS"  {
                deploymentNode "Web Browser" "" "Chrome, Firefox or Edge"   {
                    containerInstance webFrontend
                }
                deploymentNode "HRC-server" "" "Node.js 14.*"  {
                    containerInstance server
                }
            }
            
            deploymentNode "HRC-dev-data" "" "Ubuntu 20.04 LTS"  {
                deploymentNode "HRC-dev-storage" "" "Ubuntu 20.04 LTS"  {
                    deploymentNode "Apache CouchDB" "" "Apache CouchDB 3.*"   {
                        containerInstance recordStorage
                    }
                }
                deploymentNode "HRC-dev-mod" "" "Ubuntu 20.04 LTS"  {
                    deploymentNode "Apache CouchDB" "" "Apache CouchDB 3.*"   {
                        containerInstance recordModification
                    }
                }
            }
            
            deploymentNode "RRS-dev-data" "" "Ubuntu 20.04 LTS"  {
                deploymentNode "RRS-collector" "" "Node.js 14.*"  {
                    containerInstance dataCollector
                }
                
                deploymentNode "RRS-dev-database" "" "Ubuntu 20.04 LTS"  {
                    deploymentNode "Apache CouchDB" "" "Apache CouchDB 3.*"   {
                        containerInstance database
                    }
                }
                
                deploymentNode "RRS-dev-data-harvested" "" "Ubuntu 20.04 LTS"  {
                    deploymentNode "Apache CouchDB" "" "Apache CouchDB 3.*"   {
                        containerInstance dataGetter
                    }
                }
                
                deploymentNode "RRS-dev-data-toupdate" "" "Ubuntu 20.04 LTS"  {
                    deploymentNode "Apache CouchDB" "" "Apache CouchDB 3.*"   {
                        containerInstance dataSetter
                    }
                }
            }
        }
        
        deploymentEnvironment "Live"   {
            deploymentNode "Admin User's device" "" "Microsoft Windows or Android"  {
                deploymentNode "Web Browser" "" "Chrome, Firefox or Edge"   {
                    adminClientInstance = containerInstance webFrontend
                }
            }
            
            deploymentNode "Supervisor User's device" "" "Microsoft Windows or Android"  {
                deploymentNode "Web Browser" "" "Chrome, Firefox or Edge"   {
                    pubClientInstance = containerInstance webFrontend
                }
            }
            
            deploymentNode "HRC-live-data" "" "Ubuntu 20.04 LTS"  {
                deploymentNode "HRC-live-server" "" "Node.js 14.*"  {
                    containerInstance server
                }
                
                deploymentNode "HRC-live-show-info" "" "Ubuntu 20.04 LTS"  {
                    deploymentNode "Apache CouchDB" "" "Apache CouchDB 3.*"   {
                        containerInstance recordStorage
                    }
                }
                
                deploymentNode "HRC-live-modify-info" "" "Ubuntu 20.04 LTS"  {
                    deploymentNode "Apache CouchDB" "" "Apache CouchDB 3.*"   {
                        containerInstance recordModification
                    }
                }
            }
            
            deploymentNode "RRS-live" "" "Ubuntu 20.04 LTS"  {
                deploymentNode "RRS-live-collector" "" "Node.js 14.*"  {
                    containerInstance dataCollector
                }
                 
                deploymentNode "RRS-live-database" "" "Ubuntu 20.04 LTS"  {
                    deploymentNode "Apache CouchDB" "" "Apache CouchDB 3.*"   {
                        containerInstance database
                    }
                }
                
                deploymentNode "RRS-live-data-harvested" "" "Ubuntu 20.04 LTS"  {
                    deploymentNode "Apache CouchDB" "" "Apache CouchDB 3.*"   {
                        containerInstance dataGetter
                    }
                }
                
                deploymentNode "RRS-live-data-toupdate" "" "Ubuntu 20.04 LTS"  {
                    deploymentNode "Apache CouchDB" "" "Apache CouchDB 3.*"   {
                        containerInstance dataSetter
                    }
                }
            }
        }
    }

    views   {
		//HRC views
        systemContext hrc "HRC_SystemContext_View" {
            include *
        }		
		
		container hrc "HRC_Container_View" {
            include *
        }
        
        component server "Server_Component_View" {
            include *
        }
		
		deployment hrc "Development" "HRC_Development_Deployment" {
            include *
        }
		
		deployment hrc "Live" "HRC_Live_Deployment" {
            include *
            exclude adminClientInstance -> pubClientInstance
            exclude pubClientInstance -> adminClientInstance
        }
		
		dynamic * "HRC_Dynamic_View" "HRC Software System Dynamics"  {
            hrc -> rrs
        }
		
		dynamic hrc "HRC_Container_Dynamic_View" "HRC Container Dynamics"  {
			exchanger -> recordStorage
			exchanger -> recordModification 
			exchanger -> hrc
			exchanger -> rrs
        }
		
		//RRS views	
		systemContext rrs "RRS_SystemContext_View" {
            include *
        }
		
		container rrs "RRS_Container_View" {
            include *
        }
		
		deployment rrs "Live" "RRS_Live_Deployment" {
            include *
        }
		
		dynamic * "RRS_Dynamic_View" "RRS Software System Dynamics"  {
            rrs -> hrc
        }
		
		dynamic rrs "RRS_Container_Dynamic_View" "RRS Container Dynamics"  {
			dataCollector -> dataSetter
			dataCollector -> dataGetter 
			exchanger -> hrc
        }
	}
}