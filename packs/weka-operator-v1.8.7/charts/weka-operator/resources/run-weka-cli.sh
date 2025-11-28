#!/bin/bash

set -o pipefail
set -e

if [[ -f /var/run/secrets/weka-operator/operator-user/username ]]; then
  export WEKA_USERNAME=`cat /var/run/secrets/weka-operator/operator-user/username`
  export WEKA_PASSWORD=`cat /var/run/secrets/weka-operator/operator-user/password`
  export WEKA_ORG=`cat /var/run/secrets/weka-operator/operator-user/org`
fi

# comes either out of pod spec on repeat run or from resources.json on first run
if [[ "$PORT" == "0" ]]; then
  if [[ -f /opt/weka/k8s-runtime/vars/port ]]; then
    export PORT=`cat /opt/weka/k8s-runtime/vars/port`
    export WEKA_PORT=`cat /opt/weka/k8s-runtime/vars/port`
  fi
fi

if [[ -f /opt/weka/data/$NAME/container/resources.json ]]; then
  export WEKA_HOST=$(jq .ips[0] -r < /opt/weka/data/$NAME/container/resources.json || echo "")
fi

if [[ "$AGENT_PORT" == "0" ]]; then
  if [[ -f /opt/weka/k8s-runtime/vars/agent_port ]]; then
    export AGENT_PORT=`cat /opt/weka/k8s-runtime/vars/agent_port`
  fi
fi


/usr/bin/weka "$@"
