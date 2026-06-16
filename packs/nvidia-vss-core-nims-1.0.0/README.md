# NVIDIA VSS Core NIMs

The embedding NIM for NVIDIA VSS (`llama-3.2-nv-embedqa-1b-v2`), used by the CA-RAG pipeline. Part of the upstream **VSS 2.4.1** blueprint. Also creates the shared `ngc-pull-secret` used by other VSS components.

## Prerequisites

- An NGC API key with access to the NIM images (`nvcr.io/nim/*`).
- A GPU node (validated on NVIDIA GB10 / DGX Spark).

## Parameters

| **Parameter** | **Description** | **Type** | **Default** | **Required** |
|---|---|---|---|---|
| `spectro.var.NGC_API_KEY` | NGC key for nvcr.io image pulls | String (masked) | — | Yes |

## Usage

Add to the VSS add-on profile at install-priority 10 (after `nvidia-vss-data-infrastructure`). Exposes the embedding service consumed by `nvidia-vss-application`.

---
**Upstream:** NVIDIA VSS Blueprint 2.4.1. **Pack version:** 1.0.x.

## Container Images

This pack deploys NVIDIA NIM microservices (all **gated** — require an NGC account/API key):
- `nvcr.io/nim/nvidia/llama-3.2-nv-embedqa-1b-v2:1.9.0` (embedding, used on DGX-Spark)
- `nvcr.io/nim/nvidia/llama-3.2-nv-rerankqa-1b-v2:1.9.0`, `nvcr.io/nim/meta/llama-3.1-8b-instruct:1.10.1`, `nvcr.io/nim/meta/llama-3.1-70b-instruct:1.10.1`, `nvcr.io/nim/nvidia/parakeet-0-6b-ctc-en-us:2.0.0` (other platform presets)
- `curlimages/curl:8.17.0` — public (health helper)

> `values.yaml` `pack.content.images` lists only the publicly-pullable images: pack-central's validator/security scans pull anonymously and cannot access gated `nvcr.io/nim` images. NIM images are pulled at deploy time with the user-supplied `NGC_API_KEY`.
