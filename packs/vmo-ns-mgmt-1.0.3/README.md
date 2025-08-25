# VMO Namespace Management

## Overview
The VMO Namespace Management pack enables centralized administration of VMO namespaces, including quotas and RBAC permissions.

With this pack you can centrally manage the namespaces used for running virtual machines on all your VMO clusters:
* Define a list of namespaces that should be able to run VMs and deploy VMs from golden images
* Set quotas for CPU, Memory, Storage and custom resources on namespaces
* Set VMO-specific or custom RBAC permissions on namespaces
* Filter quotas or RBAC permissions to only apply to specific Palette clusters

## Kubernetes compatibility
Kubernetes versions supported by VMO (1.28+).

## CloudTypes supported:
Supported on all cloud types, but only relevant to cloud types supported by VMO.

## Parameters

The table lists commonly used parameters you can configure when adding this pack.

| Parameter                   | Description | Required | Default |
|-----------------------------|-------------|----------|---------|
| `goldenImagesNamespace`     | Namespace that contains your VMO golden images. Should match the setting by the same name in the VMO pack. | Yes | `vmo-golden-images` |
| `vmEnabledNamespaces`       | A list of namespaces that you want to enable for VMO. If the namespace does not exist, it will be created. If you remove a namespace from the list, it will not be removed from the cluster; you will need to manually clean it up when necessary. | Yes | |
| `quotas`                    | A list of quota definitions that limit the amount of resources that can be consumed in a each namespace. | Yes | Empty list |
| `quotas.[].namespace`       | The name of the namespace to define the quota for. | Yes | |
| `quotas.[].clusters`        | A list of clusters that the quota should apply to. | No | |
| `quotas.[].limits`          | The resource limits quota you want to apply. We recommend using this to set CPU quota: ensure to leave some headroom for CPU overhead (15 millicore per VM) and live migration (at least twice the CPU of the biggest VM). | No | |
| `quotas.[].requests`        | The resource requests quota you want to apply. We recommend using this to set Memory and Storage quota: ensure to leave some headroom for overhead (~315MB per VM) and live migration (at least twice the memory of the biggest VM). | No | |
| `rbac`                      | A list of RBAC definitions that control what users can do in each namespace. | Yes | Empty list |
| `rbac.[].namespace`         | The name of the namespace to define the RBAC permissions for. | Yes | |
| `rbac.[].clusters`          | A list of clusters that the RBAC permissions should apply to. | No | |
| `rbac.[].admins`            | Define this block if you want to give users/teams the `spectro-vm-admin` permission for the namespace. | No | |
| `rbac.[].admins.groups`     | A list of Palette Teams (case sensitive!) that should receive the `spectro-vm-admin` permission for the namespace. | No | |
| `rbac.[].admins.users`      | A list of Palette Users, by email address (case sensitive!), that should receive the `spectro-vm-admin` permission for the namespace. | No | |
| `rbac.[].powerusers`        | Define this block if you want to give users/teams the `spectro-vm-poweruser` permission for the namespace. | No | |
| `rbac.[].powerusers.groups` | A list of Palette Teams (case sensitive!) that should receive the `spectro-vm-poweruser` permission for the namespace. | No | |
| `rbac.[].powerusers.users`  | A list of Palette Users, by email address (case sensitive!), that should receive the `spectro-vm-poweruser` permission for the namespace. | No | |
| `rbac.[].users`             | Define this block if you want to give users/teams the `spectro-vm-user` permission for the namespace. | No | |
| `rbac.[].users.groups`      | A list of Palette Teams (case sensitive!) that should receive the `spectro-vm-user` permission for the namespace. | No | |
| `rbac.[].users.users`       | A list of Palette Users, by email address (case sensitive!), that should receive the `spectro-vm-user` permission for the namespace. | No | |
| `rbac.[].viewers`           | Define this block if you want to give users/teams the `spectro-vm-viewer` permission for the namespace. | No | |
| `rbac.[].viewers.groups`    | A list of Palette Teams (case sensitive!) that should receive the `spectro-vm-viewer` permission for the namespace. | No | |
| `rbac.[].viewers.users`     | A list of Palette Users, by email address (case sensitive!), that should receive the `spectro-vm-viewer` permission for the namespace. | No | |
| `rbac.[].custom`            | Define this list if you want to give users/teams a custom permission (of type ClusterRole) for the namespace. | No | |
| `rbac.[].custom.[].role`    | The name of the custom ClusterRole that want assign to users/teams for the namespace. | No | |
| `rbac.[].custom.[].groups`  | A list of Palette Teams (case sensitive!) that should receive the custom ClusterRole for the namespace. | No | |
| `rbac.[].custom.[].users`   | A list of Palette Users, by email address (case sensitive!), that should receive the custom ClusterRole for the namespace. | No | |


## Presets
None


## References:
* [VMO Roles and Permissions](https://docs.spectrocloud.com/vm-management/rbac/vm-roles-permissions/)