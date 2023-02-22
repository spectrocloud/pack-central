# pack-central
Repository for Spectrocloud Community Packs

## packs
Parent folder for all packs

Naming convention: Every pack directory will have the name in the format: "pack name-version".
  '-' must be used as the separator in the pack directory name.
  
## Structure
```
| - pack name
		 | - pack.json			==> mandatory : pack config
		 | - values.yaml		==> mandatory : pack params + values.yaml from charts + templated params from ansible-roles + templated params from manifests
		 | - logo.png			==> mandatory: logo file for the pack in portable network graphics format
		 | - README.md                  ==> mandatory: readme file for the pack in markup format
		 | - manifests 			==> optional : manifest files for the pack
		 | - ansible-roles		==> optional : ansible-roles used to install the pack
		 | - charts			==> optional : charts to be deployed for the pack
```
