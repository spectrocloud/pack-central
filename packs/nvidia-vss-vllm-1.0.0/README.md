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

> **CVE bump:** nginx health-proxy sidecar `1.27-alpine` → `1.30.2-alpine` (verified on GB10, `/v1/health/live` → 200; pack-central pax-cve confirms **0 Critical**, down from `1.27`'s 3 / 137 total). The vLLM image stays at `nvcr.io/nvidia/vllm:25.12.post1-py3` — a bump to `26.05.post1-py3` was tested on the GB10 (serves fine) but **reverted**: that image ships a JWT in its pip HTTP-cache (`/root/.cache/pip/...`, an upstream NVIDIA build-hygiene leak flagged by the secret scan) and gives **no CVE benefit** (the runtime image scans clean at both versions). The Jetson-Thor `ghcr.io/nvidia-ai-iot/vllm` tag is left floating (Tegra-only, verify before use).
