# Local modifications to upstream charts

This pack ships modified copies of the upstream chart(s). The edits recorded here
are made by hand and are **not** part of the upstream release. They will not
survive a straight chart swap, so **re-apply them whenever the chart is updated to
a new version**.

This file is deliberately separate from `README.md`, which is derived from
upstream and may be regenerated.

---

## `charts/nvsentinel/values.yaml` — added top-level `mongodb-store` block

**What.** A `mongodb-store:` key declaring image overrides for the vendored
Bitnami MongoDB subchart — `externalAccess.autoDiscovery`, `externalAccess.dnsCheck`,
and `volumePermissions`.

**Why.** The vendored Bitnami chart pins those init containers to the free
`bitnami/` namespace. Bitnami removed the immutable tags from that namespace, so
those references 404 at pull time. The reachable equivalents live under
`bitnamilegacy/`, which is what `pack.content.images` mirrors. The overrides
repoint the render at them; the features themselves stay disabled by default.

**Also required for submission.** The pack-submission validator compares the pack's
`values.yaml` against the chart's, and every subchart block the pack defines must
also be declared in the chart's `values.yaml`. The pack's
`charts.nvsentinel.mongodb-store` block therefore has to exist here too, or
validation fails — reconciling the image list alone is not enough.

**Mirror the edit into `charts/nvsentinel-v1.25.0.tgz`.** That tarball is what
`pack.json` ships, so editing only the extracted directory has no effect on
deploys. Confirm the two agree before submitting:

```bash
diff <(tar -xzOf charts/nvsentinel-v1.25.0.tgz nvsentinel/values.yaml | yq -o=json '.' | jq -S .) \
     <(yq -o=json '.' charts/nvsentinel/values.yaml | jq -S .) && echo "in sync"
```

**Keep the tags aligned with `pack.content.images`:**

| Image | Tag |
|---|---|
| `bitnamilegacy/kubectl` | `1.31.2-debian-12-r3` |
| `bitnamilegacy/os-shell` | `12-debian-12-r32` |

**Confirm the overrides still take effect** after re-applying — this should print
the `bitnamilegacy` ref, not `bitnami`:

```bash
helm template nvsentinel charts/nvsentinel \
  --set global.mongodbStore.enabled=true \
  --set mongodb-store.mongodb.volumePermissions.enabled=true 2>/dev/null \
  | yq eval -o=json '.' - 2>/dev/null \
  | jq -r 'select(.kind != "CustomResourceDefinition") | .. | objects | .image? // empty' \
  | grep -i "os-shell" | sort -u
```
