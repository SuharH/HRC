## Views

### How are the views documented?

The software architecture of HRC is further documented according to the [C4 model](https://c4model.com/) using its 2 levels - [container](https://c4model.com/#ContainerDiagram) level and [component](https://c4model.com/#ComponentDiagram) level.
The documentation also uses supplementary diagrams - [deployment diagrams](https://c4model.com/#DeploymentDiagram) and [dynamic diagrams](https://c4model.com/#DynamicDiagram).

### Decomposition Views

HRC business functionality is implemented by the HRC Server container.
Human users such as viewer and admin, interact with a web application provided by HRC Web Front-end container.

![](embed:HRC_Container_View)

The server container is able to use the database to read and write the status of the room and its elements.
RRS is where all this information is managed.
Data is monitored in real time and any changes made in the database by the admin has an inmediate impact in the desired room or rooms.

![](embed:RRS_Container_View)

### Server Decomposition Views

HRC Server implements the business functionality of HRC.
Its internal architecture comprises 3 layers:
* Domain Model represents the business domain of HRC which is data sets and their distributions. Its components represent the domain as a basic object model with simple get/set operations.
* Business Logic implements all the business logic on top of the domain model.
* Infrastructure implements the interaction with the other containers through APIs and gateways.

![](embed:HRC_Server_Component_View)

### HRC Dynamic Views

Everything that happens in the HRC is recorded in the RRS.

![](embed:HRC_Dynamic_View)

Furthermore, HRC has its own way to operate.

![](embed:HRC_Container_Dynamic_View)

### RRS Dynamic Views

As said previously, every change is recorded in the RRS. Therefore, the dynamic view is the same as HRC.

![](embed:RRS_Dynamic_View)

RRS also has its internal way of operation.

![](embed:RRS_Container_Dynamic_View)

### HRC Deployments

There exist various HRC deployment environments.

#### HRC Server Development Deployment

This deployment is mandatory for all HRC Server developers and their unit tests.

![](embed:HRC_Development_Deployment)

#### HRC Live Deployment

This deployment is the current production environment of HRC.

![](embed:HRC_Live_Deployment)
