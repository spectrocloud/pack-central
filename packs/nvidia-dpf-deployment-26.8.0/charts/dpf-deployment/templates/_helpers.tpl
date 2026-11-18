{{/*
Enable automatic lookup of k8sEndpoint from the cluster-info ConfigMap
When `auto`, it defaults to lookup for a `cluster-info` configmap on the `kube-public` namespace (kubeadm-based)
To override the namespace and configMap when using `auto`:
`.Values.k8sServiceLookupNamespace` and `.Values.k8sServiceLookupConfigMapName`
*/}}
{{- define "k8sEndpoint" }}
  {{- $configmapName := "cluster-info" }}
  {{- $configmapNamespace := "kube-public" }}
  {{- if and (eq . "auto") (lookup "v1" "ConfigMap" $configmapNamespace $configmapName) }}
    {{- $configmap := (lookup "v1" "ConfigMap" $configmapNamespace $configmapName) }}
    {{- $kubeconfig := get $configmap.data "kubeconfig" }}
    {{- $k8sServer := get ($kubeconfig | fromYaml) "clusters" | mustFirst | dig "cluster" "server" "" }}
    {{- $k8sServer }}
  {{- else }}
    {{- . }}
  {{- end }}
{{- end }}