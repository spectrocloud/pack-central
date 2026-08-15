# Apache Airflow

## Overview

Apache Airflow is an open source platform for developing, scheduling, and monitoring workflows. It allows you to define workflows as code, organize tasks into dependencies, execute them on a schedule, and monitor their execution through a web interface.

Airflow workflows are defined using Python and are represented as Directed Acyclic Graphs (DAGs). A DAG defines the tasks that need to be executed and the order in which they should run.

This pack installs Apache Airflow using the official Apache Airflow Helm chart.

## Prerequisites

Before installing this pack, ensure the following requirements are met:

- Kubernetes 1.29 or later.
- A running Kubernetes cluster.
- Sufficient cluster resources to deploy Apache Airflow.
- Network connectivity between the Airflow components.
- Access to the required container images.

## Pack Contents

This pack deploys the following components:

- Apache Airflow API Server
- Apache Airflow Scheduler
- Apache Airflow DAG Processor
- Apache Airflow Triggerer
- Apache Airflow Workers
- Apache Airflow Webserver
- PostgreSQL
- Redis
- StatsD
- Kubernetes Services
- Service Accounts
- RBAC resources
- ConfigMaps
- Secrets

## Configuration

The pack installs Apache Airflow into the `airflow` namespace by default.

The pack uses Apache Airflow version `3.2.2` with Helm chart version `1.22.0`.

The following table describes the primary configuration parameters.

| Parameter | Description | Default |
|----------|-------------|---------|
| `pack.namespace` | Namespace where Apache Airflow is installed. | `airflow` |
| `executor` | Executor used by Apache Airflow to execute tasks. | `CeleryExecutor` |
| `defaultAirflowRepository` | Default Apache Airflow container image repository. | `apache/airflow` |
| `defaultAirflowTag` | Default Apache Airflow container image tag. | `3.2.2` |
| `airflowVersion` | Apache Airflow version used by the chart. | `3.2.2` |
| `postgresql.enabled` | Enables the PostgreSQL dependency. | `true` |
| `redis` | Configuration for the Redis dependency used by Celery. | Enabled |
| `flower.enabled` | Enables the Flower web interface for Celery. | `false` |
| `pgbouncer.enabled` | Enables PgBouncer for PostgreSQL connection pooling. | `false` |

Additional configuration options can be customized through the Helm chart values.

## Installation

Deploy the Apache Airflow pack from Palette.

Wait until the pack reaches the **Healthy** state before proceeding with validation.

## Validation

Verify that the Apache Airflow components are running successfully.

```bash
kubectl get all -n airflow
```

Verify the status of the Airflow pods.

```bash
kubectl get pods -n airflow
```

Review the logs of an Airflow component if necessary.

```bash
kubectl logs deployment/airflow-api-server -n airflow
```

## Accessing the Airflow UI

If an Ingress is not configured, forward the Airflow API Server service locally.

```bash
kubectl port-forward svc/airflow-api-server 8080:8080 -n airflow
```

Open the Airflow web interface using a web browser.

```text
http://localhost:8080
```

## Workflow Validation

After accessing the Airflow interface, create or deploy a DAG to validate workflow execution.

A DAG can be defined using Python and should contain one or more tasks with defined dependencies.

Verify that:

- The DAG is detected by Airflow.
- The DAG can be triggered successfully.
- The tasks are scheduled and executed.
- The task status changes to **Success**.
- Task logs can be viewed from the Airflow UI.

## Uninstall

Remove the Helm release.

```bash
helm uninstall airflow -n airflow
```

Optionally delete the namespace.

```bash
kubectl delete namespace airflow
```

## References

- https://airflow.apache.org/
- https://github.com/apache/airflow
- https://airflow.apache.org/docs/apache-airflow/3.2.2/

