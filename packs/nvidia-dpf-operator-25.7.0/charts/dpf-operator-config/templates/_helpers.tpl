{{/*
Enable automatic lookup of k8sServiceHost from the cluster-info ConfigMap
When `auto`, it defaults to lookup for a `cluster-info` configmap on the `kube-public` namespace (kubeadm-based)
To override the namespace and configMap when using `auto`:
`.Values.k8sServiceLookupNamespace` and `.Values.k8sServiceLookupConfigMapName`
*/}}
{{- define "k8sServiceHost" }}
  {{- $configmapName := default "cluster-info" .Values.k8sServiceLookupConfigMapName }}
  {{- $configmapNamespace := default "kube-public" .Values.k8sServiceLookupNamespace }}
  {{- if (lookup "v1" "ConfigMap" $configmapNamespace $configmapName) }}
    {{- $configmap := (lookup "v1" "ConfigMap" $configmapNamespace $configmapName) }}
    {{- $kubeconfig := get $configmap.data "kubeconfig" }}
    {{- $k8sServer := get ($kubeconfig | fromYaml) "clusters" | mustFirst | dig "cluster" "server" "" }}
    {{- $uri := (split "https://" $k8sServer)._1 | trim }}
    {{- (split ":" $uri)._0 | quote }}
  {{- end }}
{{- end }}