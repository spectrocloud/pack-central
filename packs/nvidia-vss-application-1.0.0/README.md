# NVIDIA VSS Application

The orchestration engine for NVIDIA's Video Search & Summarization (VSS) blueprint: the `vss-engine` (Cosmos-Reason2 VLM + CA-RAG pipeline) plus its API. Deploys the upstream **VSS 2.4.1** `vss-engine` image and wires it to the VSS data stores, embedding NIM and LLM backend.

## Prerequisites

- An NGC account/API key with access to `nvcr.io/nvidia/blueprint/*` (the `vss-engine` image is gated).
- A HuggingFace token with access to the gated `nvidia/Cosmos-Reason2-8B` VLM weights.
- The companion packs in the same add-on profile: `nvidia-vss-data-infrastructure`, `nvidia-vss-core-nims`, and an LLM backend (`nvidia-vss-vllm`).
- A GPU node (validated on NVIDIA GB10 / DGX Spark, arm64 SBSA). On a single GPU, enable device-plugin time-slicing.

## Parameters

| **Parameter** | **Description** | **Type** | **Default** | **Required** |
|---|---|---|---|---|
| `spectro.var.NGC_API_KEY` | NGC key for nvcr.io image pulls | String (masked) | — | Yes |
| `spectro.var.HF_TOKEN` | HuggingFace token for the gated VLM weights | String (masked) | — | Yes |
| `spectro.var.VSS_PLATFORM` | Hardware platform preset | String | `DGX-SPARK` | No |

## Usage

Add this pack to an add-on cluster profile **after** `nvidia-vss-data-infrastructure` (priority 5), `nvidia-vss-core-nims` (10), and `nvidia-vss-vllm` (12); this pack installs at priority 15. Supply `NGC_API_KEY` and `HF_TOKEN` as profile variables. The engine exposes its API on port 8000 (`/health/ready`).

---
**Upstream:** NVIDIA VSS Blueprint 2.4.1 (`vss-engine:2.4.1`). **Pack version:** 1.0.x (our packaging; tracks our changes independent of upstream).

## Container Images

This pack deploys:
- `nvcr.io/nvidia/blueprint/vss-engine:2.4.1` — **gated** (requires an NGC account and accepted NVIDIA VSS EULA)
- `busybox:1.37`, `curlimages/curl:8.17.0` — public (init/health helpers)

> `values.yaml` `pack.content.images` lists only the publicly-pullable images: pack-central's validator and security scans pull images **anonymously** and cannot access gated `nvcr.io` images. The gated `vss-engine` image is pulled at deploy time with the user-supplied `NGC_API_KEY`.
