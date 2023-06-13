#!/bin/sh
set -x;
WD=$(dirname $0)
WD=$(cd $WD; pwd)

#Color codes for printing error messages
RED='\033[0;31m'
GREEN='\033[0;32m'
COLOR_RESET='\033[0m'

SPECTRO_CLI_URL="https://software.spectrocloud.com/spectro-registry/v3.3.0/cli/linux/spectro"
spectro_server_string=$1
spectro_server_creds=$2

comment="Generic Pack Change"
comment_string=""

SPECTRO_HOME="$HOME/spectroCLI"
CLI_CONFIG="$HOME/.spectro"
CONFIG_JSON_FILE="config.json"
PACKS_TOPLEVEL_DIRECTORY="packs"
GIT_PACKS_DIRECTORY="${GITHUB_WORKSPACE}/${PACKS_TOPLEVEL_DIRECTORY}"

if [ ! $spectro_server_string ]; then
        echo "Usage: push_packs.sh <registry_server>"
        exit 1
fi

mkdir ${SPECTRO_HOME}
cd ${SPECTRO_HOME}

log_error(){
 local msg=$1
 echo -e "${RED}ERROR: $msg ${COLOR_RESET}"
}

log_info(){
 local msg=$1
 echo "INFO: $msg"
}

setup_spectrocli(){
  wget $SPECTRO_CLI_URL
  local rc=$?
  if [ $rc -ne 0 ]; then
    log_error "Error occurred while downloading spectro CLI"
    exit $rc     
  fi	  
  if [ -f spectro ]; then
   chmod +x spectro
  else
    log_error "spectro binary not found in the downloaded" 	
    exit 127 
  fi  
}
setup_spectrocli

create_config_json_template(){
 mkdir ${CLI_CONFIG}
 cd ${CLI_CONFIG}
 cat > ${CONFIG_JSON_FILE} << EOF
 {
        "auths": {
                "$spectro_server": {
                        "auth": "$spectro_server_creds",
                        "insecure": true
                }
        },
        "defaultRegistry": "$spectro_server"
 }
EOF
}

push_packs() {
  # Add Stable Packs
  # shellcheck disable=SC2011
  comment="Generic Pack Change"
  cd ${GITHUB_WORKSPACE}
  pack_list=$(ls -1d ${PACKS_TOPLEVEL_DIRECTORY}/*)
  for each_pack in ${pack_list}; do
     grep  '"commit_msg":' ${each_pack}/pack.json
     if [ $? -eq 0 ]; then
       commit_msg=$(grep  '"commit_msg":' ${each_pack}/pack.json | cut -d : -f 2-)
       final_comment=${commit_msg}
     else
       final_comment=${comment}
     fi
     echo "$SPECTRO_HOME//spectro" pack push -m "${final_comment}" --registry-server "$spectro_server" --force ${each_pack}
     $SPECTRO_HOME/spectro pack push -m "${final_comment}" --registry-server "$spectro_server" --force ${each_pack} 
     if [ $? -ne 0 ]; then
       exit 2
     fi
  done   
  cd ${SPECTRO_HOME}
}


spectro_server_list=$(echo ${spectro_server_string} | tr "," " ")
for each_server in $spectro_server_list; do
  spectro_server=${each_server}
  create_config_json_template 
  push_packs
done

exit 0
