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
| `auth.licenseId` | Gridlight license UUID. Required for compute metering. Obtain from [license.gridlight.ai](https://license.gridlight.ai) | String | — | Yes |
| `auth.signingSecret` | License signing secret for heartbeat auth. Leave blank — auto-acquired from the license server at first startup. Only set when migrating a pre-existing deployment. | String | `""` | No |
| `auth.huggingFaceToken` | HuggingFace read token for gated models (e.g. Juggernaut XI). Only required if image or video agents need gated models. | String | `""` | No |
| `auth.gatewayToken` | Bearer token clients include in the `Authorization` header | String | `dev-token` | No |
| `auth.agentToken` | Shared token agents use to register with the gateway | String | `dev-token` | No |
| `auth.registryCredentials` | Docker config JSON for the image registry (base64-encoded). Chart creates the `regcred` secret automatically when set. | String | `""` | No |
| `gateway.tflopRequested` | TFLOPs claimed from the license pool. Set to `0` to use the full licensed allowance. | Integer | `0` | No |
| `gateway.licenseServerUrl` | License server URL. Override only for air-gapped installs pointing at an on-prem license server. | String | `https://license.gridlight.ai` | No |
| `gateway.corsOrigins` | Comma-separated allowed CORS origins for browser clients. Leave blank to allow all origins (permissive). | String | `""` | No |
| `global.imageRegistry` | Container registry prefix for all Gridlight images | String | ECR path | No |
| `global.imageTag` | Image tag for all Gridlight services | String | `1.1.3` | No |
| `global.imagePullPolicy` | Kubernetes image pull policy | String | `IfNotPresent` | No |
| `models.llm.category` | LLM category: `general` (RAG/chat) or `coding` (code generation) | String | `general` | No |
| `models.llm.preset` | LLM model preset key. General: `mistral-7b`, `qwen-7b`, `qwen-32b`, `mixtral-8x7b`, `mixtral-8x22b`, `deepseek-r1`. Coding: `qwen-coder-7b`, `granite-8b`, `qwen-coder-14b`, `qwen-coder-32b`, `mixtral-8x22b`, `deepseek-r1` | String | `qwen-7b` | No |
| `models.image.preset` | Image generation model: `cogview3-plus`, `auraflow`, `cogview4`, `hidream-i1` | String | `cogview3-plus` | No |
| `models.video.preset` | Video generation model: `wan-2.1` (14B, **default** — needs ~48GB GPU / L40S/A100; runs on 16–24GB via CPU offload), `wan-2.2` (A14B), `cogvideox-5b`, `ltx-video`, `wan-2.1-1.3b` (fits 8–24GB), `auto` (pick by VRAM) | String | `wan-2.1` | No |
| `videoAgent.offloadMode` | Large-model CPU offload: `auto`, `none`, `model`, `sequential`. `model` keeps the 14B default within VRAM on 16–24GB GPUs. | String | `model` | No |
| `bootstrap.enabled` | Auto-download LLM and embedding models on first install via init containers. Set `false` for air-gapped deployments — pre-stage models on the PVC. | Bool | `true` | No |
| `pvc.size` | Shared PVC size for models and data | String | `100Gi` | No |
| `pvc.storageClassName` | Kubernetes StorageClass for the PVC. Blank = cluster default. | String | `""` | No |
| `ingress.enabled` | Expose the gateway via an Ingress resource | Bool | `false` | No |
| `ingress.host` | Public hostname for the gateway | String | `""` | No |
| `llmAgent.resources` | CPU/memory requests and limits for the LLM agent pod | Object | see values.yaml | No |
| `llmAgent.nodeSelector` | Node selector for GPU scheduling | Object | `{}` | No |
| `llmAgent.tolerations` | Tolerations for GPU node taints | Array | `[]` | No |

## Agent fleets

Each agent type can be declared as a **list of instances** — run several LLMs (different
models), multiple image agents, etc., all behind the one gateway, which load-balances across
them. The list keys are `llmAgents`, `embedAgents`, `imageAgents`, `videoAgents`, `sttAgents`,
`voiceAgents`. When a list is non-empty it **replaces** the matching singular block
(`llmAgent`, …), which remains for backward compatibility: existing values files keep working
unchanged (the singular block is treated as a one-instance fleet named `agent`).

Per-instance fields: `name` (required, DNS-safe), `deploy`, `replicas`, `model`
(`{category,preset}` or `modelPath`), `storage` (`{mode,size,accessMode,storageClassName}`),
`nodeSelector`, `tolerations`, `affinity`, `resources`, `env`, `port`, and type-specific
`device` (LLM), `fsGroup`/`offloadMode` (image/video), `modelSize`/`computeType` (STT),
`defaultVoice` (voice).

**Storage modes** (`storage.mode`): `shared` (the single shared PVC — default, backward
compatible), `ownPvc` (a dedicated PVC per instance so it can run on its own node pool), or
`emptyDir` (per-pod ephemeral, small models only). With `ownPvc` + `replicas > 1` the chart
emits a StatefulSet with `volumeClaimTemplates`; otherwise a Deployment. Switching an agent's
`mode` on an existing release is a reinstall, not an in-place upgrade (the workload selector
and kind are immutable).

A complete worked example is in [`examples/fleet-heterogeneous.yaml`](examples/fleet-heterogeneous.yaml)
(three LLMs across GPU pools, two image agents, and the embed agent isolated onto a CPU pool).

### Multiple LLM models on SpectroCloud Palette

To run several LLMs (each a different model) behind one gateway, add an `llmAgents` list to the
**pack values** (the cluster-profile layer for the `gridlight-palette` pack). It is edited as
**raw YAML** — only the `auth.*` fields render as masked inputs in the Palette form; the fleet
lists do not, so type them directly into the pack values editor.

```yaml
llmAgents:
  - name: qwen                       # required, DNS-safe ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$
    model: { preset: qwen-7b }
    storage: { mode: ownPvc, size: 20Gi }
    resources: { limits: { nvidia.com/gpu: "1" } }
    nodeSelector: { gridlight.ai/pool: gpu-a10g }
  - name: big
    model: { preset: qwen-32b }
    storage: { mode: ownPvc, size: 40Gi }
    resources: { limits: { nvidia.com/gpu: "1" } }
    nodeSelector: { gridlight.ai/pool: gpu-a100 }
```

LLM `preset` values: `mistral-7b`, `qwen-7b`, `qwen-32b`, `mixtral-8x7b`, `mixtral-8x22b`,
`deepseek-r1` (general) and `qwen-coder-7b/14b/32b`, `granite-8b` (coding); or a custom
`model: { modelPath: /data/models/<file>.gguf }`. Use `storage.mode: ownPvc` for a fleet so
each model gets its own volume and can land on its own node pool.

**Cluster prerequisites — the chart targets node pools, it does not create them:**
1. **Label the node pools** the `nodeSelector`s reference, e.g.
   `kubectl label node <node> gridlight.ai/pool=gpu-a10g`.
2. Install the **NVIDIA GPU Operator** so GPU nodes advertise `nvidia.com/gpu`.
3. For `ownPvc` across nodes, have a **StorageClass** that provisions per-node volumes
   (EBS `gp3` on EKS). Set `storage.storageClassName` if it is not the cluster default.

The gateway load-balances across all registered LLM instances automatically. To target a
specific model per request instead, see **Query routing** below.

## Query routing

Added in 1.1.3 (gateway image; no chart templates required).

- **Explicit override (always on):** a request may name a `model` and/or pin an `agent_id` to
  route deterministically — e.g. `POST /neon {"question":"…","model":"qwen-32b"}` hits the
  `big` agent above. `model_required:true` makes an unavailable target return 404/503 instead
  of falling back. Works on `/neon`, `/chat/intelligent`, `/image`, `/video`. No config needed.
- **Intent auto-routing (opt-in, ships dark):** the gateway can infer modality
  (text/image/video) from a query and dispatch automatically. Enable per-install with the
  gateway env escape hatch:

  ```yaml
  gateway:
    env:
      GATEWAY_ROUTING_MODE: "auto"   # default: explicit (off). Fails safe to text.
  ```

  Optional tuning (also via `gateway.env`): `MODALITY_LLM_TIMEOUT_SECS` (3),
  `AUTO_ROUTE_MEDIA_TIMEOUT_SECS` (180), `AUTO_ROUTE_MAX_CONCURRENT` (4).

## Upgrade

- **1.1.2 → 1.1.3:** gateway query routing (above). Pure gateway-image change — bump the pack to
  1.1.3 (or `--set global.imageTag=1.1.3`) and existing values keep working; explicit override is
  immediately available, auto-routing stays off until you set `gateway.env.GATEWAY_ROUTING_MODE=auto`.
  The agent images are byte-identical to 1.1.2. To roll back, pin `global.imageTag=1.1.2`.

- If upgrading from a pre-1.1.2 release, the new `auth.licenseId` field is now required. Provide it via `--set auth.licenseId=<your-uuid>` or a values override file. The `auth.signingSecret` is acquired automatically at startup — you do not need to set it manually.
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
  --version 1.1.3 \
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

### Video generation

Video is **off by default** (`videoAgent.deploy: false`) and needs its own GPU. Set
expectations before enabling it — video is far heavier than image/LLM, and the default
model is the production-quality 14B.

**Model vs. GPU vs. speed** (measured; warm = model already loaded):

| `models.video.preset` | Fits | Warm gen (5 s @ 480p) | Quality | Download |
|-----------------------|------|-----------------------|---------|----------|
| `wan-2.1-1.3b` | 8–24 GB | ~1–2 min | Low (warps on motion) | ~17 GB |
| `ltx-video` | 12–24 GB | ~30–60 s | Decent, fast | ~20 GB |
| `cogvideox-5b` | 16 GB+ (offload) | ~3–5 min | Good | ~22 GB |
| `wan-2.1` (14B, **default**) | **48 GB** ideal / 16–24 GB offload | ~3–5 min @ 48 GB · **~30 min** with offload | High | ~40–76 GB |
| `wan-2.2` (A14B) | 48 GB+ | ~5–8 min | Highest | ~55 GB |

**Latency expectations — read this first:**

- **First generation is a cold start:** model download (17–76 GB) **+** load into the GPU
  (1.3B ≈ 1 min, 14B ≈ 8 min). This is a one-time-per-pod cost but it is *minutes*, not
  seconds. Pre-stage the model (below) to avoid it.
- **Warm generations** skip download+load — only the per-clip time in the table applies.
- **Single-concurrency:** the agent generates **one clip at a time**; concurrent requests
  get `429 "busy"`. A client timeout/disconnect does **NOT** cancel the in-flight job — it
  keeps running and the file lands in `videos/`.

**Performance knob (important on big GPUs):** on a ≥48 GB GPU the 14B model fits entirely,
so set `videoAgent.offloadMode: none` — the default `model` needlessly swaps weights and is
~6× slower. Use `model` only on 16–24 GB GPUs.

**Customizing output quality** without code changes:

```yaml
models:
  video:
    preset: "wan-2.1"        # model (quality tier) — see table above
    defaultQuality: "720p"   # default resolution/fps when a request omits it:
                             # proxy 512x320 | draft 640x480 | preview/sd/hd 768x512 |
                             # 720p 1280x720 | 1080p 1920x1080 | 2k | 4k
videoAgent:
  offloadMode: "none"        # auto | none | model | sequential
  replicas: 1                # raise for parallel generation (see Concurrency below)
```

Clients can always override per request with `quality_preset` or explicit
`width`/`height`/`fps`/`duration_seconds`/`steps`.

**Concurrency (parallel generation):** because the agent is single-concurrency, run
multiple pods to serve clips in parallel:

```yaml
videoAgent:
  replicas: 3
pvc:
  enabled: false   # REQUIRED for replicas>1: each pod gets its own emptyDir and
                   # downloads the model itself. The default ReadWriteOnce PVC can
                   # only attach to one pod — use emptyDir or a ReadWriteMany class.
```

**Pre-staging the model (skip the cold start / air-gapped):** download the model into the
shared PVC once, before agents start, so the first request doesn't pay the download:

```bash
# into the path the agent reads (MODEL_CACHE_DIR / HF_HOME on the dataDir PVC)
huggingface-cli download Wan-AI/Wan2.1-T2V-14B-Diffusers \
  --local-dir /gridlight-data/models/video/Wan-AI__Wan2.1-T2V-14B-Diffusers
```

Run it from a pod that mounts the PVC, or bake the files into a pre-staged volume. With the
model present, the first generation only pays the load time (no download).

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

## Troubleshooting

### LLM/agent never registers — "would exceed TFLOPS ceiling"
Symptom: pods are `Running` but `/agents/list` is empty and the gateway logs
`Agent ... registration rejected: would exceed TFLOPS ceiling. Requested: 125.00, Ceiling: 100.00`.

Cause: the gateway self-allocates a **default TFLOPS budget (~100)** from the license pool. On a
large GPU (e.g. an A10G reports ~125 TFLOPS) a single agent exceeds that budget and is rejected —
**even when the license has more available** (e.g. 182). In heartbeat-licensing mode the gateway
cannot auto-discover the license ceiling, so it does not raise its own allocation.

Fix: set the gateway's requested allocation to your license ceiling (from license.gridlight.ai):
```yaml
gateway:
  env:
    GATEWAY_TFLOPS_REQUESTED: "182"   # your license TFLOPS ceiling
```
Sizing: the budget must cover the **sum** of all GPU agents' reported TFLOPS. Two A10Gs (~250)
need a ceiling ≥ 250; one A10G (~125) needs ≥ 125.

### Pods stuck `Pending` — PVCs won't bind (raw EKS)
On EKS 1.30+ the in-tree EBS provisioner is gone and `eksctl` clusters have **no default
StorageClass**. Install the EBS CSI driver addon (with an IRSA role) and create a default
`gp3` StorageClass, then reinstall. See the AWS GPU test runbook for the exact commands.

## References

- [Gridlight documentation](https://gridlight.ai)
- [Helm chart source](https://github.com/GRIDLIGHT-INC/gridlight/tree/main/helm/gridlight-palette)
- [Image build and kind test guide](https://github.com/GRIDLIGHT-INC/gridlight/blob/main/docs/image-build-and-test.md)
- [Spectrocloud Palette add-on packs](https://docs.spectrocloud.com/integrations/)
- [pack-central community packs](https://github.com/spectrocloud/pack-central)
