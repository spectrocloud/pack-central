# lava-sensor

Installs the Lava sensor on every targeted node of a Kubernetes cluster with one
`helm install`. Lava serves the chart itself, with its own address filled in, so
no chart repository is needed:

```bash
printf '%s' '<YOUR_TOKEN>' | helm install lava-sensor https://api.lavalabs.io/sensor/v1/enroll/lava-sensor.tgz \
  --namespace lava-system --create-namespace \
  --set-file enrollmentKey=/dev/stdin
```

Run it wherever you manage the cluster. Nodes added later get the sensor too.
The key reaches helm on stdin, so it never shows in the machine's process
list (`printf` is a shell builtin); a file works too:
`--set-file enrollmentKey=key.txt`.

## How it works

The sensor is not a container. A DaemonSet pod on each node runs Lava's
`install.sh` on the node itself (the pod is privileged and uses the node's PID
namespace to enter it with `nsenter`), and the sensor then runs as a systemd
service on the node, `lava@<sensor>.service`, exactly as a `curl | bash`
install on a server would. Each node enrolls as its own machine. The sensor's
version, updates and rollback are managed from Lava, as on any server.

When a pod starts on a node that already has this release's install
(`/opt/lava`, `/etc/lava`, the unit files, this key and address, every sensor
enrolled), it only starts the sensor's units. It runs `install.sh` again only
when something is missing or different, for example after an immutable OS
reset the node's files.

Each node stays the same machine in Lava across reboots, even on an OS that
resets `/etc` at every boot (Kairos, for example). The node's machine id lives
in `/etc/lava/machine-id`, and the pod keeps a copy in `/opt/lava/node-identity`
with the node's name and hardware UUID. When a reboot has removed `/etc/lava`,
the pod puts the machine id back before `install.sh` runs, so the node enrolls
again as the same machine. Only the machine that saved the copy gets it back,
by the same node name and the same hardware UUID: a cloned disk, or a new node
that takes an old node's name, enrolls as a new machine, because two machines
with one id would knock each other offline. For the same reason a machine with
no hardware UUID, or a placeholder that many boards share, keeps no copy and
comes back as a new machine after such a reboot. A machine id already on the
node is never replaced, and one removed on purpose (`install.sh --seal`, before
cloning a machine) is not put back.

A pod is Ready when every sensor on its node has enrolled
(`/etc/lava/<sensor>/credentials`) and none of their units has failed. A pod
being stopped (a restart, an upgrade, a node drain) never touches the node.

## Requirements

- Each node runs systemd, with `bash` and `curl`. On a node without systemd
  (Talos, for example) the pod stops with an error in `kubectl logs` and
  writes nothing to the node; leave such nodes out with `nodeSelector` or
  `affinity`.
- `/opt` survives a reboot, as it does on Kairos and other immutable OSes by
  default; `/etc` need not. A node that keeps nothing across a reboot (a
  diskless node booted from the network), or that has no hardware UUID of its
  own, enrolls as a new machine every time `/etc` is reset.
- The pods are privileged. On a cluster that enforces Pod Security Admission,
  allow it in the namespace:
  `kubectl label namespace lava-system pod-security.kubernetes.io/enforce=privileged`.
- Only sensors that run once per machine, such as the compute sensor, fit this
  install. A sensor that runs once per site would run on every node.

## Values

| Value | Default | What it does |
| --- | --- | --- |
| `enrollmentKey` | `""` | The enrollment key from the Lava console. The chart keeps it in a Secret. |
| `existingSecret` | `""` | A Secret you created that holds the key instead; keeps it out of Helm's release history. |
| `existingSecretKey` | `enrollment-key` | The key inside `existingSecret`. |
| `sensorApiUrl` | filled in by Lava | The Lava address the nodes install from. |
| `nodeSelector`, `affinity` | none | Which nodes get the sensor. |
| `tolerations` | `nvidia.com/gpu` | Taints the pods tolerate. GPU nodes are included by default. |
| `image.*` | busybox, pinned by digest | The pod's image: any image with `sh`, `nsenter` and `tr`. |
| `uninstall.image.*` | kubectl, pinned by digest | The uninstall hook's image. |
| `imagePullSecrets` | none | For pulling either image from a private registry. |
| `maxUnavailable` | `100%` | How many pods an upgrade replaces at once. |
| `uninstall.enabled`, `uninstall.timeout` | `true`, `300s` | Remove the sensor from the nodes on `helm uninstall`, and how long to wait. |

With `--set`, give a `nodeSelector` value as a string
(`--set-string nodeSelector.lava=true`), or a later upgrade fails.

Using `existingSecret`:

```bash
kubectl -n lava-system create secret generic lava-enrollment-key --from-file=enrollment-key=./key.txt
helm install lava-sensor <url> -n lava-system --set existingSecret=lava-enrollment-key
```

After rotating the key in that Secret, run
`kubectl -n lava-system rollout restart daemonset/lava-sensor`. A key set
through `enrollmentKey` restarts the pods by itself on `helm upgrade`.

## Uninstall

`helm uninstall lava-sensor -n lava-system` first switches every pod to
uninstall mode, waits until each one has removed the sensor from its node
(units, `/etc/lava`, `/opt/lava`, the unit files), and only then deletes the
release. Know these gaps:

- **A node that is down during uninstall** makes the wait time out
  (`uninstall.timeout`): `helm uninstall` fails and the release stays, in
  `uninstalling`. Every node it reached is already clean. Run `helm uninstall`
  again once the node is back. `--no-hooks` skips the removal altogether and
  leaves the sensor on every node.
- **Reinstalling creates new machines.** Uninstall deletes each node's machine
  id and its copy in `/opt/lava`, so a later install enrolls the nodes as new
  machines in Lava, and the old ones stay there, offline.
- **A node the release stops targeting** (a `nodeSelector` change, a new taint)
  keeps its sensor.
- **A sensor installed by hand** on a node with the default install is removed
  too.
