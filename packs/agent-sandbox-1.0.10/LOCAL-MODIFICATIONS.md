# Local chart modifications

The shipped chart differs from upstream in exactly one respect: the Helm chart
version metadata was restamped. No template, value, or CRD file was edited.

## Chart.yaml: version and appVersion

| Field | Upstream (`helm/Chart.yaml` at tag v1.0.10) | Shipped (`charts/agent-sandbox-1.0.10.tgz`) |
|---|---|---|
| `version` | `0.1.4` | `1.0.10` |
| `appVersion` | absent | `v1.0.10` |

**Why:** the upstream repository tags releases (v1.0.10) independently of the
chart's own version (0.1.4), so the chart version alone gives no way to tell
which controller release a pack contains. The pack version, directory name, chart
filename, and packaged chart version are therefore all aligned to the repository
release tag, for consistency with the rest of this pack repo.

**How it was applied:**

```bash
helm package charts/agent-sandbox --destination charts/ \
  --version 1.0.10 --app-version v1.0.10
```

**How to re-verify after the next version bump:**

1. Read `helm/Chart.yaml` at the new tag and note its `version`/`appVersion`.
2. Confirm the matching controller image exists, e.g.
   `oras manifest fetch --descriptor registry.k8s.io/agent-sandbox/agent-sandbox-controller:v<new>`.
3. Repackage with `--version <new-release>` and `--app-version v<new-release>`.
4. Confirm `helm show chart charts/agent-sandbox-<new>.tgz` reports the stamped
   values, and update `pack.json` `charts[]` / `version`.

## Not chart edits: pack-level value overrides

Two keys in the pack's `values.yaml` differ from the chart's own defaults. The
chart tree's `values.yaml` is untouched.

- `image.tag: "v1.0.10"` — upstream leaves it empty and calls
  `required "image.tag is required"`, so the chart cannot render with its own
  defaults. When bumping, update this pin and the `pack.content.images` entry
  together.
- `namespace.create: false` — Palette creates `pack.namespace` before installing
  the release. With the upstream default (`true`), the chart renders a
  `Namespace` object for the same name, which Helm rejects as an existing
  resource without matching release ownership metadata.
