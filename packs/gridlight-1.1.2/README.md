# Gridlight AI Platform

Gridlight is an on-premises AI platform that runs entirely inside your cluster — no
data leaves it. A single **gateway** (Rust/Axum, port 8080) is the only endpoint your
applications talk to; it orchestrates **agents** that self-register with it: LLM
inference and embeddings, plus optional specialists for image generation
(diffusers/SDXL), text-to-speech (Piper), and speech-to-text (faster-whisper). It
serves retrieval-augmented generation (RAG) over your own documents using a bundled
PostgreSQL, Qdrant vector store, and Neo4j knowledge graph. Deployed as a Palette
add-on, it gives you private chat, document Q&A, image, and voice from one URL.

## Prerequisites

- A **Gridlight license ID** (UUID) — obtain from <https://license.gridlight.ai>.
- Kubernetes **>= 1.26** with a default **StorageClass** that provisions
  `ReadWriteOnce` volumes (e.g. AWS EBS `gp3`).
- At least one **GPU node** with the **NVIDIA device plugin** for LLM and image
  inference. On a single-GPU node, enable NVIDIA **GPU time-slicing** if you want the
  LLM and image agents to share it; otherwise put them on separate GPU nodes (the
  image agent's output is served back through the gateway, so it does not need to
  share a node with the gateway).
- Outbound egress to HuggingFace for first-use model downloads (or pre-stage models on
  the data volume for air-gapped installs). Container images come from the public
  registry `public.ecr.aws/q1c5c5i2/gridlight` — no pull credentials required.

## Parameters

Set under `charts.gridlight-palette.*` in the pack values. Minimum to deploy:

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| `auth.licenseId` | Gridlight license UUID | String | - | Yes |
| `auth.postgresPassword` | PostgreSQL password | String | - | Yes |
| `auth.neo4jPassword` | Neo4j password | String | - | Yes |
| `auth.gatewayToken` | Bearer token clients send (change from `dev-token`) | String | `dev-token` | No |
| `models.llm.preset` | LLM model: `qwen-7b`, `mistral-7b`, `qwen-32b`, `mixtral-8x7b`, … | String | `qwen-7b` | No |
| `models.image.preset` | Image model: `juggernautxl`, `cogview3-plus`, `auraflow`, `cogview4` | String | `juggernautxl` | No |
| `models.video.preset` | Video model: `wan-2.1` (14B, **default** — needs ~48GB GPU / L40S/A100; runs on 16–24GB via CPU offload), `wan-2.2`, `cogvideox-5b`, `ltx-video`, `wan-2.1-1.3b` (fits 8–24GB), `auto` | String | `wan-2.1` | No |
| `gateway.service.type` | `ClusterIP` / `LoadBalancer` / `NodePort` | String | `ClusterIP` | No |
| `pvc.size` | Shared volume for models + data (raise for large LLMs) | String | `100Gi` | No |
| `imageAgent.deploy`, `sttAgent.deploy`, `voiceAgent.deploy`, `videoAgent.deploy` | Toggle each specialist agent on/off | Bool | `true` (video: `false`) | No |

Every component (`llmAgent`, `embedAgent`, each specialist, `postgres`, `qdrant`,
`neo4j`) has a `deploy` flag, so you can run any subset — e.g. gateway + LLM + image
only. See `values.yaml` for the full reference.

## Usage

### 1. Add the pack to a cluster profile

Create an [add-on cluster profile](https://docs.spectrocloud.com/profiles/cluster-profiles/create-cluster-profiles/create-addon-profile/),
search for the **Gridlight AI Platform** pack, and overwrite the default configuration
with your values. Minimal example:

```yaml
charts:
  gridlight-palette:
    auth:
      licenseId: "00000000-0000-0000-0000-000000000000"   # your license UUID
      postgresPassword: "<choose-a-strong-password>"
      neo4jPassword: "<choose-a-strong-password>"
      gatewayToken: "<bearer-token-for-your-clients>"      # change from dev-token
    models:
      llm:
        preset: "qwen-7b"
      image:
        preset: "juggernautxl"
    gateway:
      service:
        type: LoadBalancer        # expose the gateway; ClusterIP for in-cluster only
    pvc:
      size: "150Gi"
```

To run only a subset of capabilities, set the per-agent toggles, e.g. image off:

```yaml
charts:
  gridlight-palette:
    imageAgent:
      deploy: false
```

Deploy the profile to your cluster. The agents self-register with the gateway and
download their models on first use (the image agent preloads its model at startup).

### 2. Use the platform

Everything goes through the **gateway** with `Authorization: Bearer <gatewayToken>`.
Get the gateway address from the `gridlight-...-gateway` Service (the external
hostname when `gateway.service.type: LoadBalancer`).

```bash
GW="http://<gateway-address>:8080"
TOKEN="<gatewayToken>"

# Chat / RAG answer
curl -s "$GW/neon" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"question": "Summarize our onboarding policy"}'

# Ingest a document, then ask about it via /neon
curl -s "$GW/upload-structured" -H "Authorization: Bearer $TOKEN" -F file=@handbook.pdf

# Generate an image (no model field uses models.image.preset)
curl -s "$GW/image" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"prompt": "a red fox in a snowy forest, photorealistic"}'

# Text-to-speech (returns WAV audio inline as base64)
curl -s "$GW/voice" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"text": "Hello from Gridlight", "voice": "en_US-amy-medium"}'
```

The `image_url` returned by `/image` is served back **through the gateway**, so it
works even when the image agent runs on a different node — no shared filesystem or
external object store is required.

> [!CAUTION]
> Image generation is a long synchronous request (a cold model load + generation can
> take 60–90s). When exposing the gateway via a cloud load balancer, the pack sets a
> 600s idle timeout (`gateway.service.idleTimeoutSeconds`); keep it high enough that
> the LB does not cut generation requests.

> [!CAUTION]
> The specialist Python agents run as non-root and write to the shared data volume;
> the pack sets an `fsGroup` so they can. If you override pod security contexts, retain
> a group that can write the volume.

## Upgrade

- Initial community release (1.1.2). Keep the pack **name** and **display name** across
  future versions so they upgrade in place rather than appearing as a new pack.
- Retain the shared data volume across upgrades so models are not re-downloaded.
- `videoAgent` is **experimental** and `deploy: false` by default; do not rely on it in
  production in this release.

## Security / CVE posture

All six container images are built on the latest Debian `bookworm` base with security
updates applied at build time (`apt-get upgrade`), which clears every base-OS CVE that
has a released fix.

The CVEs that remain are predominantly **upstream Debian packages with no available
fix** (marked `will_not_fix` or `affected`/awaiting-patch by Debian) and are present in
essentially every Debian-based image — for example `CVE-2023-45853` (zlib1g,
`will_not_fix`), `CVE-2025-7458` (libsqlite3-0), `CVE-2026-42496` / `CVE-2026-8376`
(perl-base), and `CVE-2019-1010022` (glibc, disputed by Debian/not rated critical). They
are accepted and tracked pending upstream fixes. The image- and video-generation agents
carry a larger dependency surface (PyTorch/CUDA/diffusers), which is inherent to ML
workloads. The speech-to-text and video agents install ffmpeg with
`--no-install-recommends` to exclude the Mesa GL/VA/Vulkan hardware-decode drivers
(unused for headless audio decoding / CUDA generation), removing their `will_not_fix`
CVEs.

## References

- Gridlight: <https://gridlight.ai>
- Gridlight license server: <https://license.gridlight.ai>
- Create an add-on cluster profile: <https://docs.spectrocloud.com/profiles/cluster-profiles/create-cluster-profiles/create-addon-profile/>
