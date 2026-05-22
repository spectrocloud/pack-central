# Gridlight AI Platform

On-premises AI platform with LLM inference, semantic search, knowledge graphs, and specialist agents (STT, image generation, voice synthesis) — all running inside your Kubernetes cluster. No data leaves your infrastructure.

## Prerequisites

- Kubernetes **1.26+**
- Helm **3.10+**
- A node with at least **16 GB RAM** and **100 GB** available storage for entry-tier models; flagship LLM models require 500 GB+
- GPU node recommended for inference performance (CPU-only is supported)
- A private container registry reachable from the cluster with the Gridlight images pushed (see [image-build-and-test.md](https://github.com/GRIDLIGHT-INC/gridlight/blob/main/docs/image-build-and-test.md))
- An `imagePullSecret` or `auth.registryCredentials` (Docker config JSON) if the registry requires authentication

## Parameters

| **Parameter** | **Description** | **Type** | **Default** | **Required** |
|---|---|---|---|---|
| `auth.postgresPassword` | Password for the Gridlight PostgreSQL user | String | — | Yes |
| `auth.neo4jPassword` | Password for the Neo4j database user | String | — | Yes |
| `auth.gatewayToken` | Bearer token clients include in the `Authorization` header | String | `dev-token` | No |
| `auth.agentToken` | Shared token agents use to register with the gateway | String | `dev-token` | No |
| `auth.registryCredentials` | Docker config JSON for the image registry (base64-encoded). Chart creates the `regcred` secret automatically when set. | String | `""` | No |
| `global.imageRegistry` | Container registry prefix for all Gridlight images | String | ECR path | No |
| `global.imageTag` | Image tag for all Gridlight services | String | `1.1.1` | No |
| `global.imagePullPolicy` | Kubernetes image pull policy | String | `IfNotPresent` | No |
| `models.llm.category` | LLM category: `general` (RAG/chat) or `coding` (code generation) | String | `general` | No |
| `models.llm.preset` | LLM model preset key. General: `mistral-7b`, `qwen-7b`, `qwen-32b`, `mixtral-8x7b`, `mixtral-8x22b`, `deepseek-r1`. Coding: `qwen-coder-7b`, `granite-8b`, `qwen-coder-14b`, `qwen-coder-32b`, `mixtral-8x22b`, `deepseek-r1` | String | `qwen-7b` | No |
| `models.image.preset` | Image generation model: `cogview3-plus`, `auraflow`, `cogview4`, `hidream-i1` | String | `cogview3-plus` | No |
| `models.video.preset` | Video generation model: `cogvideox-2b`, `wan-1-3b`, `mochi-1`, `wan-14b` | String | `cogvideox-2b` | No |
| `bootstrap.enabled` | Auto-download LLM and embedding models on first install via init containers. Set `false` for air-gapped deployments — pre-stage models on the PVC. | Bool | `true` | No |
| `pvc.size` | Shared PVC size for models and data | String | `100Gi` | No |
| `pvc.storageClassName` | Kubernetes StorageClass for the PVC. Blank = cluster default. | String | `""` | No |
| `ingress.enabled` | Expose the gateway via an Ingress resource | Bool | `false` | No |
| `ingress.host` | Public hostname for the gateway | String | `""` | No |
| `llmAgent.resources` | CPU/memory requests and limits for the LLM agent pod | Object | see values.yaml | No |
| `llmAgent.nodeSelector` | Node selector for GPU scheduling | Object | `{}` | No |
| `llmAgent.tolerations` | Tolerations for GPU node taints | Array | `[]` | No |

## Upgrade

- When upgrading from a version prior to 1.1.1, delete and recreate the `gridlight-credentials` secret before upgrading — the secret key names changed.
- The `bootstrap.llmModelUrl` field was removed in 1.1.1 and replaced by the full `models.llm.catalog` system. If you had a custom model URL, set `llmAgent.modelPath` to the absolute path of the GGUF file on your PVC instead.
- PVC data (downloaded models, ingested documents) is preserved across upgrades. The chart uses `strategy: Recreate` on all agent deployments, so pods terminate cleanly before the new version starts.

## Usage

### Minimal install

```yaml
auth:
  postgresPassword: "changeme"
  neo4jPassword:    "changeme"
```

```bash
helm install gridlight oci://registry.spectrocloud.com/community/gridlight \
  --version 1.1.1 \
  --values my-values.yaml \
  --namespace gridlight --create-namespace
```

### Selecting a model

Use the Palette UI dropdowns (driven by `values.schema.json`) or set via values:

```yaml
models:
  llm:
    category: "general"
    preset:   "qwen-32b"   # ~19.9 GB — requires 100Gi+ PVC
```

All catalog models are **Apache 2.0 or MIT licensed**.

### Air-gapped deployment

1. Set `bootstrap.enabled: false`
2. Pre-stage the GGUF file on the PVC at the path shown by `helm template` for your chosen preset
3. Set `global.imagePullPolicy: Never` and load images manually

### Accessing the gateway

```bash
kubectl port-forward svc/gridlight-gateway 8080:8080 -n gridlight
curl http://localhost:8080/healthz -H "Authorization: Bearer dev-token"
```

Primary endpoints:

| Endpoint | Purpose |
|----------|---------|
| `POST /neon` | RAG query (streaming SSE). Include `"domain"` matching the domain used at ingest time. |
| `POST /chat/intelligent` | Stateful multi-turn conversation |
| `POST /upload-structured` | File ingestion (multipart: `file` + `metadata` JSON with `domain`, `access_tier`, `pii`) |
| `POST /train` | Raw text ingestion |
| `POST /image` | Image generation |
| `POST /voice` | Text-to-speech synthesis |
| `GET  /healthz` | Health check |
| `GET  /metrics` | Prometheus metrics |

All requests require `Authorization: Bearer <gatewayToken>`.

### Enabling Ingress

```yaml
ingress:
  enabled: true
  host: "gridlight.example.com"
```

## References

- [Gridlight documentation](https://gridlight.ai)
- [Helm chart source](https://github.com/GRIDLIGHT-INC/gridlight/tree/main/helm/gridlight-palette)
- [Image build and kind test guide](https://github.com/GRIDLIGHT-INC/gridlight/blob/main/docs/image-build-and-test.md)
- [Spectrocloud Palette add-on packs](https://docs.spectrocloud.com/integrations/)
- [pack-central community packs](https://github.com/spectrocloud/pack-central)
