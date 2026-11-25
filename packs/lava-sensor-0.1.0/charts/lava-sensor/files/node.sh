#!/bin/sh
# Runs in the DaemonSet pod (busybox). Everything that reads or changes the node
# runs through nsenter into ALL of PID 1's namespaces, i.e. as root on the node.
#   node.sh            mode from LAVA_MODE: "install" (the default) or "uninstall"
#   node.sh ready      the readiness probe
#   node.sh idle       sleep until the pod is stopped
set -u

log() { echo "[lava-node] $*"; }
fail() { echo "[lava-node] ERROR: $*" >&2; }

HOST_PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
SCRIPTS=$(dirname "$0")

# The mount namespace alone is not enough: the node's resolv.conf can name a
# resolver (systemd-resolved on 127.0.0.53) that only its network namespace
# reaches. The key never crosses here; on_host_keyed is the one way it does.
on_host() { PATH="$HOST_PATH" env -u LAVA_ENROLLMENT_KEY nsenter -t 1 -m -u -i -n -p -- "$@"; }

# Like on_host, but with the enrollment key in the environment of what runs on
# the node, and nothing else from the pod but PATH and HOME. The key travels in
# the environment, never on a command line: with hostPID every argv here shows
# in the node's ps.
on_host_keyed() (
  for var in $(env | sed -n 's/^\([A-Za-z_][A-Za-z0-9_]*\)=.*/\1/p'); do
    [ "$var" = LAVA_ENROLLMENT_KEY ] || unset "$var" 2>/dev/null
  done
  export PATH="$HOST_PATH" HOME=/root
  exec nsenter -t 1 -m -u -i -n -p -- "$@"
)

idle() {
  # SIGTERM only ends the pod. A pod restart, a rolling update and a node drain
  # send it too, so it must never touch the node: removal happens only in
  # uninstall mode.
  trap 'log "pod stopping; the sensor on the node is left as it is"; exit 0' TERM INT
  while :; do sleep 3600 & wait $!; done
}

# The sensor is a systemd service on the node, so a node without systemd cannot
# run it. Checked from inside the pod before anything runs on the node: such a
# node (Talos) may not even have a shell to nsenter into.
host_has_systemd() {
  pid1=$(cat /proc/1/comm 2>/dev/null) || pid1=unknown
  [ "$pid1" = systemd ] && [ -d /proc/1/root/run/systemd/system ]
}

host_tools() {
  missing=""
  for tool in bash curl; do
    on_host /bin/sh -c "command -v $tool" >/dev/null 2>&1 || missing="$missing $tool"
  done
  [ -z "$missing" ] && return 0
  fail "node ${NODE_NAME:-?} is missing:$missing. The Lava installer needs them on the node itself. Nothing was written to the node."
  return 1
}

# host.sh keep-id: save the node's machine-id outside /etc, or put it back.
keep_id() {
  on_host /bin/sh -s -- keep-id "${NODE_NAME:-}" <"$SCRIPTS/host.sh" && return 0
  fail "could not keep the machine-id of node ${NODE_NAME:-?} (output above); the pod restarts and retries"
  return 1
}

install() {
  if ! host_has_systemd; then
    fail "node ${NODE_NAME:-?} does not run systemd (its PID 1 is '$pid1')."
    fail "The Lava sensor runs as a systemd service on the node, so this Helm install cannot be used on this node. Nothing was written to the node."
    fail "Leave this node out with the chart's nodeSelector or affinity values, or ask Lava for another way to install it."
    exit 1
  fi
  host_tools || exit 1
  # A Secret written from a file often ends in a newline; the key never does.
  LAVA_ENROLLMENT_KEY=$(printf '%s' "${LAVA_ENROLLMENT_KEY:-}" | tr -d '\r\n')
  export LAVA_ENROLLMENT_KEY
  [ -n "$LAVA_ENROLLMENT_KEY" ] || { fail "the enrollment key is empty: check the chart's enrollment-key Secret"; exit 1; }
  api=${LAVA_SENSOR_API_URL%/}

  # First, so that on a node whose /etc was reset install.sh finds the machine-id
  # put back and keeps it: the node then enrolls as the same machine.
  keep_id || exit 1

  # A node that already runs this release's install only needs its sensors
  # started. install.sh runs only when something is missing or different (a
  # first install, an immutable OS that reset the node's files, a new key or
  # URL), so a sensor-api outage cannot crash-loop the pods of healthy nodes,
  # and the wrapper is not rewritten while it runs.
  if on_host_keyed /bin/sh -s -- current "$api" <"$SCRIPTS/host.sh"; then
    log "node ${NODE_NAME:-?}: the sensor is installed and enrolled; starting its units, without re-running install.sh"
    if ! on_host /bin/sh -s -- start <"$SCRIPTS/host.sh"; then
      fail "could not start the sensor on node ${NODE_NAME:-?} (output above); the pod restarts and retries"
      exit 1
    fi
  else
    log "node ${NODE_NAME:-?}: running $api/v1/enroll/install.sh on the node"
    # install.sh reads the key from LAVA_ENROLLMENT_KEY in its environment.
    # --connect-timeout: a route that drops packets would hang the pod for good.
    # No --max-time: bash runs install.sh as it arrives, so a transfer cut short
    # would run half a line of it.
    if ! on_host_keyed /bin/bash -c 'set -o pipefail; curl -fsSL --connect-timeout 30 "$1/v1/enroll/install.sh" | bash' lava-install "$api"; then
      fail "install.sh failed on node ${NODE_NAME:-?} (its output is above); the pod restarts and retries"
      exit 1
    fi
    log "install.sh finished"
    # Saves the id install.sh generated, before a reset of /etc can lose it.
    keep_id || exit 1
  fi
  touch /tmp/lava-installed
  log "the pod is Ready once every sensor on the node has enrolled (/etc/lava/<sensor>/credentials) and none has failed"
  # Re-exec without the key, so the long-lived idle process does not carry it.
  exec env -u LAVA_ENROLLMENT_KEY /bin/sh "$0" idle
}

uninstall() {
  if ! host_has_systemd; then
    log "node ${NODE_NAME:-?} does not run systemd, so nothing was installed here; nothing to remove"
  else
    log "node ${NODE_NAME:-?}: removing the Lava sensor from the node"
    if ! on_host /bin/sh -s -- remove <"$SCRIPTS/host.sh"; then
      fail "removal failed on node ${NODE_NAME:-?} (output above); the pod restarts and retries"
      exit 1
    fi
  fi
  touch /tmp/lava-uninstalled
  log "removed; waiting for helm uninstall to delete this pod"
  exec env -u LAVA_ENROLLMENT_KEY /bin/sh "$0" idle
}

ready() {
  if [ "${LAVA_MODE:-install}" = uninstall ]; then
    [ -f /tmp/lava-uninstalled ] || { echo "the sensor has not been removed from the node yet"; exit 1; }
    exit 0
  fi
  [ -f /tmp/lava-installed ] || { echo "the install has not finished in this pod"; exit 1; }
  on_host /bin/sh -s -- ready <"$SCRIPTS/host.sh"
}

case "${1:-${LAVA_MODE:-install}}" in
  install)   install ;;
  uninstall) uninstall ;;
  ready)     ready ;;
  idle)      idle ;;
  *)         fail "unknown mode: ${1:-${LAVA_MODE:-}}"; exit 1 ;;
esac
