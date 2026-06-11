# NVIDIA VSS Data Infrastructure

The data layer for NVIDIA VSS: Neo4j (graph), ArangoDB, MinIO (object), Milvus (+ etcd, milvus-minio) vector store, and Elasticsearch. Also owns the shared `hf-token-secret` and the `vss-platform` ConfigMap. Part of the upstream **VSS 2.4.1** blueprint.

## Prerequisites

- A HuggingFace token (`HF_TOKEN`) for the shared secret consumed by the VLM.
- A default StorageClass for the data-store PVCs (validated with Longhorn).

## Parameters

| **Parameter** | **Description** | **Type** | **Default** | **Required** |
|---|---|---|---|---|
| `spectro.var.HF_TOKEN` | HuggingFace token (shared `hf-token-secret`) | String (masked) | — | No |
| `spectro.var.GRAPH_DB_USERNAME` / `GRAPH_DB_PASSWORD` | Neo4j credentials | String | `neo4j` / — | No |
| `spectro.var.MINIO_ACCESS_KEY` / `MINIO_SECRET_KEY` | MinIO credentials | String | — | No |
| `spectro.var.ARANGO_DB_USERNAME` / `ARANGO_DB_PASSWORD` | ArangoDB credentials | String | `root` / — | No |
| `spectro.var.VSS_PLATFORM` | Hardware platform preset | String | `DGX-SPARK` | No |

## Usage

Add first in the VSS add-on profile (install-priority 5) so the data stores, `hf-token-secret`, and `vss-platform` ConfigMap exist before the NIM/LLM/engine packs.

---
**Upstream:** NVIDIA VSS Blueprint 2.4.1. **Pack version:** 1.0.x.

## Container Images

Data-store images are bumped to the latest patched tag within each VSS-compatible minor: neo4j `5.26.27`, arangodb `3.12.9.1`, minio `RELEASE.2025-09-07T16-13-09Z`, milvusdb/etcd `3.5.25-r1` (with `podSecurityContext.fsGroup: 0` — the image runs as `uid=1001` and the etcd command writes `--data-dir /etcd`, so the data PVC must be group-writable; verified `1/1 Running` on the DGX Spark)

> `milvusdb/milvus:v2.6.5` is deployed by this pack but is **not** listed in `pack.content.images`: every official Milvus image ships default sample TLS keys under `/milvus/configs/cert/*.key`, which the secret scan flags. It is documented here instead; CVEs/secrets in upstream data-store images are the image vendors' to remediate.

> **Note on image overrides:** the generic-workload subcharts read each container image from `applicationSpecs.<workload>.containers.<container>.image` — the top-level `<subchart>.image` is an unused fallback. All data-store CVE bumps are set at the `applicationSpecs` path (verified with `helm template`). elasticsearch is pinned to `8.17.9` (the VSS-2.4.1-compatible 8.x line; the chart default `9.2.1` is a major drift).
