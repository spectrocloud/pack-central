# Kubedoom

Kubedoom is a containerized version of the 1993 video game Doom developed by id Software. The application runs in a container that simulates a virtual desktop and needs to be accessed with a Virtual Network Computing (VNC) viewer. 

This pack was created for Edge deployments. If you want to deploy the application to a non-Edge environment, you need to set up port forwarding to the pod running the workload. 

## Prerequisites

- A Palette account.

- A cluster profile where the Kubedoom pack can be integrated.

- A Palette cluster with port `:30059` available. If port 8080 is not available, you can set a different port in the **values.yaml** file.

- A VNC viewer to access the application. 

## Parameters

The following parameters are applied to the **kubedoom.yaml** manifest through the **values.yaml** file. Users do not need to take any additional actions regarding these parameters.

| **Parameter**                     | **Description**                                                                | **Default Value**                           | **Required** |
| --------------------------------- | ------------------------------------------------------------------------------ | ------------------------------------------- | ------------ |
| `manifests.namespace`             | The namespace in which the application will be deployed.                       | `kubedoom`                            | No           |
| `manifests.images.kubedoom` | The application image that will be utilized to create the containers.          | `ghcr.io/spectrocloud/kubedoom:1.0.0` | No           |
| `manifests.port`                  | The cluster port number on which the service will listen for incoming traffic. | `30059`                                      | No           |


## Usage

### Use VNC Viewer to Connect to the Game

1. To connect to the game, use a VNC viewer of your choice. 

2. Open the port 30059,  or the port you specified in the **values.yaml** file, on the IP of any node in your cluster with your VNC viewer,

3. You will be prompted to enter a password. Type in the password `idbehold` to start the game. 