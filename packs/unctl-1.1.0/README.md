# unCtl

The **unCtl** kubernetes operator to run various checks on the cluster's resources. It is based on [unCtl cli tool](https://docs.unskript.com/unctl) and provides API and web interface wrapper for you reports.


## Prerequisites

1. Kubernetes cluster version 1.19 or higher with `linux/amd64` architecture.

2. Support of `LoadBalancer` service type in your cluster. This service type is typically available natively in cloud environments. However, in on-premises and edge computing environments, additional steps may be required to support it. If `LoadBalancer` support is not available, set `service.loadbalancer` to `false` in your values file and consider alternative methods to expose the web interface.


## Parameters

To deploy the unctl operator, you need to set, at minimum, the following parameters in the pack's YAML.

| Name | Description | Type | Default Value | Required |
| --- | --- | --- | --- | --- |
| `frontend.enabled` | Defines whether it should create web interface container. | Boolean  | true | Yes |
| `schedule` | Schedule to scan cluster resources. Default is 12 AM every day. | String  | 0 0 * * * | Yes |
| `namespaces` | List of namespaces to conduct checks on. | Array  | [] | Yes |
| `service.enabled` | Defines whether it should create service. | Boolean  | true | Yes |
| `service.loadbalancer` | Defines whether it service should be a `LoadBalancer` type. | Boolean  | true | Yes |
| `service.port` | Port exposed by service. | Integer  | 8000 | Yes |


Look at the [values file](./values.yaml) for more information.

## Usage

- **Which checks were carried out**

    In current version all checks are performed. Look at [K8S unctl checks](https://docs.unskript.com/unctl/overview/health-checks/kubernetes) for individual checks information.

- **When the checks are being executed**

    Once operator installed in your cluster it will automatically initiate checks execution.
    Additionaly based on `schedule` value it will run checks on regular basis.

- **How to view report**

    Open `unctl` service in the Pallete or find exposed address in your `LoadBalancer` service. 
    
    You can view last available report.


## References

- [unCtl Documentation](https://docs.unskript.com/unctl)
- [Public unCtl Health Checks github](https://github.com/unctl-sh/unctl)
- [Official website](https://unskript.com/)