# Runs ON THE NODE, as root: node.sh feeds it to the node's own /bin/sh on stdin
# through nsenter. It covers the default install only (no --profile), which is
# the one install.sh does when node.sh runs it.
#   host.sh current <api-url>  exit 0 when everything install.sh puts on the node
#                              is there and matches this release (the key in
#                              LAVA_ENROLLMENT_KEY, the URL), and every sensor
#                              has enrolled; otherwise say what is missing
#   host.sh keep-id <node>     save the node's machine-id where a reset of /etc
#                              does not reach, or put it back from there when
#                              /etc/lava has lost it (see keep_id)
#   host.sh start              reset-failed and start every pinned sensor's unit
#   host.sh ready              every pinned sensor has enrolled and its unit has
#                              not failed
#   host.sh remove             remove everything install.sh put on the node
set -u

LAVA_DIR=/etc/lava
OPT_DIR=/opt/lava
UNIT_DIR=/etc/systemd/system
HARDWARE_UUID=/sys/class/dmi/id/product_uuid

# The sensors install.sh pinned: one directory with a pin file each.
sensors() {
  for pin in "$LAVA_DIR"/*/pin; do
    [ -f "$pin" ] || continue
    dir=${pin%/pin}
    echo "${dir##*/}"
  done
}

current() {
  api=$1
  if [ ! -e "$LAVA_DIR" ] && [ ! -e "$OPT_DIR" ]; then
    echo "[lava-node] the sensor is not installed on this node yet"
    return 1
  fi
  missing=""
  for file in "$OPT_DIR/bin/lava-wrapper" "$OPT_DIR/bin/lava-rollback"; do
    [ -x "$file" ] || missing="$missing $file"
  done
  for file in "$UNIT_DIR/lava@.service" "$UNIT_DIR/lava-rollback@.service"; do
    [ -f "$file" ] || missing="$missing $file"
  done
  for file in "$LAVA_DIR/machine-id" "$LAVA_DIR/arch"; do
    [ -s "$file" ] || missing="$missing $file"
  done
  # $(...) drops trailing newlines on both sides: install.sh writes each value
  # with echo, and node.sh has already stripped them from the key.
  [ "$(cat "$LAVA_DIR/api-url" 2>/dev/null)" = "$api" ] || missing="$missing $LAVA_DIR/api-url (for $api)"
  [ "$(cat "$LAVA_DIR/enrollment-key" 2>/dev/null)" = "${LAVA_ENROLLMENT_KEY:-}" ] ||
    missing="$missing $LAVA_DIR/enrollment-key (this release's key)"
  names=$(sensors)
  [ -n "$names" ] || missing="$missing a sensor pinned under $LAVA_DIR"
  for name in $names; do
    [ -s "$LAVA_DIR/$name/credentials" ] || missing="$missing $LAVA_DIR/$name/credentials"
    systemctl is-enabled --quiet "lava@$name.service" 2>/dev/null || missing="$missing lava@$name.service (not enabled)"
  done
  [ -z "$missing" ] && return 0
  echo "[lava-node] not installed, or not as this release installs it; missing or different:$missing"
  return 1
}

# Every enrollment from the node is the same machine in Lava because install.sh
# keeps one id in /etc/lava/machine-id. An immutable OS can reset /etc on every
# boot while /opt persists (Kairos does), so a copy is kept in /opt/lava with
# what saved it: the node's name and its hardware UUID. Only that same pair gets
# it back. Neither alone tells machines apart: a replacement node can reuse a
# name, and a machine with no hardware UUID, or a placeholder many boards share,
# is never matched at all. Two machines sharing an id would knock each other
# offline, so any doubt means a new id.
SAVED_ID=$OPT_DIR/node-identity

# The hardware UUID, when it can tell this machine from others.
hardware_uuid() {
  uuid=$(cat "$HARDWARE_UUID" 2>/dev/null | tr 'A-F' 'a-f')
  case $uuid in
    03000200-0400-0500-0006-000700080009 | 00020003-0004-0005-0006-000700080009) ;;
    00000000-0000-0000-0000-000000000000 | ffffffff-ffff-ffff-ffff-ffffffffffff) ;;
    ????????-????-????-????-????????????) echo "$uuid" ;;
  esac
}

oneline() { printf '%s' "$1" | tr '\n' ' '; }

keep_id() {
  [ -n "$1" ] || { echo "[lava-node] ERROR: keep-id needs the node's name" >&2; return 2; }
  hw=$(hardware_uuid)
  here=$(printf 'node=%s\nhardware-uuid=%s' "$1" "$hw")
  id=$(cat "$LAVA_DIR/machine-id" 2>/dev/null)
  saved=$(sed -n 's/^machine-id=//p' "$SAVED_ID" 2>/dev/null)
  by=$(sed '/^machine-id=/d' "$SAVED_ID" 2>/dev/null)
  no_uuid="this machine has no hardware UUID that tells it from others (none, or a placeholder many boards share)"
  # The node's own id is never replaced, only saved.
  if [ -n "$id" ]; then
    if [ -z "$hw" ]; then
      echo "[lava-node] not saving machine-id $id: $no_uuid, so after a reset of /etc it enrolls as a new machine"
      return 0
    fi
    [ "$saved" = "$id" ] && [ "$by" = "$here" ] && return 0
    if [ "$saved" = "$id" ]; then
      echo "[lava-node] WARNING: machine-id $id was saved by another machine ($(oneline "$by")), not this one ($(oneline "$here")). If this disk was cloned from it, both enroll as one machine: remove $LAVA_DIR/machine-id here and restart this pod to give it its own id."
      return 0
    fi
    if mkdir -p "$OPT_DIR" && printf 'machine-id=%s\n%s\n' "$id" "$here" >"$SAVED_ID.new" && chmod 0600 "$SAVED_ID.new" && mv -f "$SAVED_ID.new" "$SAVED_ID"; then
      echo "[lava-node] saved machine-id $id in $SAVED_ID"
      return 0
    fi
    echo "[lava-node] ERROR: could not save the machine-id in $SAVED_ID" >&2
    return 1
  fi
  # A reset of /etc takes all of /etc/lava. An /etc/lava left without its id
  # had it removed on purpose (install.sh --seal, before cloning a machine).
  if [ -e "$LAVA_DIR" ]; then
    echo "[lava-node] $LAVA_DIR has no machine-id (removed on purpose, as install.sh --seal does): install.sh generates a new one"
    return 0
  fi
  if [ -z "$saved$by" ]; then
    echo "[lava-node] no machine-id on the node or saved in $SAVED_ID: install.sh generates a new one"
    return 0
  fi
  if [ -z "$hw" ]; then
    echo "[lava-node] not restoring the machine-id in $SAVED_ID: $no_uuid. This node enrolls as a new machine."
    return 0
  fi
  if [ "$by" != "$here" ]; then
    echo "[lava-node] not restoring the machine-id in $SAVED_ID: another machine saved it ($(oneline "$by")), this is $(oneline "$here"). This node enrolls as a new machine."
    return 0
  fi
  case $saved in
    "" | *[!0-9A-Za-z-]*)
      echo "[lava-node] not restoring $SAVED_ID: it holds no valid machine-id. This node enrolls as a new machine."
      return 0
      ;;
  esac
  # ln never replaces an id that something else wrote meanwhile.
  tmp=$LAVA_DIR/machine-id.restore
  mkdir -p "$LAVA_DIR" && printf '%s\n' "$saved" >"$tmp" && chmod 0644 "$tmp" &&
    { ln "$tmp" "$LAVA_DIR/machine-id" 2>/dev/null || [ -s "$LAVA_DIR/machine-id" ]; }
  rc=$?
  rm -f "$tmp"
  if [ "$rc" != 0 ]; then
    echo "[lava-node] ERROR: could not restore $LAVA_DIR/machine-id" >&2
    return 1
  fi
  id=$(cat "$LAVA_DIR/machine-id")
  if [ "$id" = "$saved" ]; then
    echo "[lava-node] restored machine-id $id from $SAVED_ID: this node enrolls as the same machine"
  else
    echo "[lava-node] kept machine-id $id, written meanwhile, over the saved $saved"
  fi
}

start() {
  rc=0
  for name in $(sensors); do
    systemctl reset-failed "lava@$name.service" >/dev/null 2>&1 || true
    if systemctl start "lava@$name.service"; then
      echo "[lava-node]   lava@$name.service started"
    else
      echo "[lava-node] ERROR: could not start lava@$name.service: journalctl -u lava@$name.service" >&2
      rc=1
    fi
  done
  return $rc
}

# The credentials file proves the sensor enrolled once, since lava-wrapper
# writes it only after a successful enroll; a failed unit is a sensor that has
# stopped since. `systemctl is-active` is no signal on its own: it reports
# active while the wrapper keeps failing to enroll and being restarted.
ready() {
  names=$(sensors)
  [ -n "$names" ] || { echo "no sensor is pinned under $LAVA_DIR"; return 1; }
  for name in $names; do
    [ -s "$LAVA_DIR/$name/credentials" ] || { echo "not enrolled yet: no $LAVA_DIR/$name/credentials on the node"; return 1; }
    if systemctl is-failed --quiet "lava@$name.service"; then
      echo "lava@$name.service has failed on the node: journalctl -u lava@$name.service"
      return 1
    fi
  done
  return 0
}

remove() {
  units=$(
    {
      systemctl list-units --all --plain --no-legend 'lava@*' 'lava-rollback@*' 2>/dev/null | awk '{print $1}'
      for link in "$UNIT_DIR"/multi-user.target.wants/lava@*; do
        if [ -L "$link" ] || [ -e "$link" ]; then echo "${link##*/}"; fi
      done
    } | sort -u
  )
  for unit in $units; do
    echo "[lava-node]   stopping and disabling $unit"
    systemctl disable --now "$unit" >/dev/null 2>&1 || systemctl stop "$unit" || true
  done
  rm -f "$UNIT_DIR/lava@.service" "$UNIT_DIR/lava-rollback@.service"
  systemctl daemon-reload
  systemctl reset-failed 'lava@*' 'lava-rollback@*' >/dev/null 2>&1 || true
  rm -rf "$LAVA_DIR" "$OPT_DIR"
  left=$(systemctl list-units --all --plain --no-legend 'lava@*' 2>/dev/null)
  if [ -n "$left" ] || [ -e "$LAVA_DIR" ] || [ -e "$OPT_DIR" ] || [ -e "$UNIT_DIR/lava@.service" ]; then
    echo "[lava-node] ERROR: something is left after removal: ${left:-files}" >&2
    return 1
  fi
  echo "[lava-node]   removed: units ${units:-none}, $LAVA_DIR, $OPT_DIR, the unit files"
}

case "${1:-}" in
  current) current "${2:-}" ;;
  keep-id) keep_id "${2:-}" ;;
  start)   start ;;
  ready)   ready ;;
  remove)  remove ;;
  *)       echo "[lava-node] ERROR: host.sh: unknown mode '${1:-}'" >&2; exit 2 ;;
esac
