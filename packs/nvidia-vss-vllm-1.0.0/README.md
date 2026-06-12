# NVIDIA VSS LLM (vLLM)

The bounded raw vLLM LLM backend for NVIDIA VSS on platforms where the TensorRT-LLM NIM is unsupported (DGX Spark / GB10 sm_121). Serves the OpenAI API as `llm-nim-svc:8000` for the CA-RAG pipeline. Part of the upstream **VSS 2.4.1** blueprint.

## Prerequisites

- An NGC API key (the vLLM image is `nvcr.io/nvidia/vllm`).
- A GPU node (validated on NVIDIA GB10 / DGX Spark).

## Parameters

| **Parameter** | **Description** | **Type** | **Default** | **Required** |
|---|---|---|---|---|
| `spectro.var.VSS_PLATFORM` | Hardware platform preset | String | `DGX-SPARK` | No |

## Usage

Add to vLLM-backed VSS profiles at install-priority 12 (after `nvidia-vss-core-nims`). Omit on trtllm profiles (H100/L40S) which use the NIM-LLM subchart instead.

---
**Upstream:** NVIDIA VSS Blueprint 2.4.1 (`vllm:25.12.post1-py3`). **Pack version:** 1.0.x.

> **CVE bumps (public images):** vLLM `nvcr.io/nvidia/vllm` `25.12.post1-py3` → `26.05.post1-py3` and the nginx health-proxy sidecar `1.27-alpine` → `1.30.2-alpine`. Both verified on the DGX Spark (GB10): vLLM loads `meta/llama-3.1-8b-instruct` and serves the OpenAI API, nginx `/v1/health/live` → 200, vss-engine ready. The Jetson-Thor `ghcr.io/nvidia-ai-iot/vllm` tag is left floating (Tegra-only, verify before use).
