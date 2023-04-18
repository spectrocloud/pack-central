#!/bin/bash

#set -x;
#A PR may contain multiple files. From these, figure out the pack directories for running validations
#contain the directories corresponding to packs modified.

declare -a pack_dirs
#Global array holding the top level pack directories for different packs modified in this PR
pack_dirs=()


PACK_JSON_SCHEMA_FILE="${GITHUB_WORKSPACE}/validator/pack-schema.json"
#The list of modified files in PR will be entered into this file by workflow and will be available to script for processing
MODIFIED_FILES_FILE="/tmp/modified_files"
#All packs in pax repo reside within "stable" folder
PACKS_CONTAINER_DIRECTORY_NAME="packs"
#complete path of stable folder
GIT_PACKS_DIRECTORY="${GITHUB_WORKSPACE}/${PACKS_CONTAINER_DIRECTORY_NAME}"
PACK_LAYER_OS="os"
PACK_LAYER_K8S="k8s"

#Color codes for printing error messages
RED='\033[0;31m' 
GREEN='\033[0;32m'
COLOR_RESET='\033[0m'

log_error(){
 local msg=$1
 echo -e "${RED}ERROR: $msg ${COLOR_RESET}"
}

log_info(){
 local msg=$1
 echo "INFO: $msg"
}

log_success() {
 local msg=$1
 echo -e "${GREEN}SUCCESS: $msg ${COLOR_RESET}"
}

#Check if a pack is already added in the list 
check_pack_directory() {
 check_dir=$1
 exists=0
 for dir in ${pack_dirs[@]}
 do
  if [ "$check_dir" == "$dir" ]; then
    exists=1
    break
  fi
 done
 return $exists
}

#Add the pack directory to the list. 
add_pack_directory() {
 local pack_dir=$1
 local present=1
 check_pack_directory ${pack_dir}
 present=$?
 if [ "$present" -eq "0" ]; then
  log_info "Adding ${pack_dir} to packs to be validated..." 
  local length=${#pack_dirs[@]}
  pack_dirs[$length]=$pack_dir
 fi 

}

#From file modified in the PR, find its parent directory till you find one with pack.json. This is the top level directory for a pack.
get_pack_directory() {
  local file_path=$1
  local myDir=""
  local return_code=1

 #initialize to parent directory for a 'file' else consider the directory
  if [ -f "$file_path" ]; then
    myDir=$(readlink -f "$(dirname "$file_path")")
  else
    myDir=$file_path
  fi
#Try to find parent directory till we reach the top level directory for all packs
  while [ "${GIT_PACKS_DIRECTORY}" != "$myDir" ]
  do
   if [ -f "$myDir/pack.json" ]; then
     echo $myDir
     return_code=0 
     break	 
   else
     myDir=$(readlink -f "$(dirname "$myDir")")
   fi
 done   
 return $return_code
}

validate_pack_schema(){
  local pack_dir=$1
  local pack_json_file="$pack_dir/pack.json"
  log_info "Validating $pack_json_file..."
  validate-json $pack_json_file $PACK_JSON_SCHEMA_FILE
#  check-jsonschema --schemafile $PACK_JSON_SCHEMA_FILE $pack_json_file
  local rc=$?
  if [ $rc -ne 0 ]; then
   log_error "Schema validation failed for $pack_json_file" 
  else
   log_success "Schema validation passed for $pack_json_file"
  fi
  return $rc
}

validate_logo() {

  local pack_dir=$1
  local logo_file="$pack_dir/logo.png"

  log_info "Checking if logo is present in $pack_dir..."
  if [ -f $logo_file ]; then
    log_success "Logo file is present in pack $pack_dir"
    return 0 
  else
    log_error "Logo file is missing in pack $pack_dir. Please add it..."
    return 1
  fi
}

validate_readme(){
 
  local pack_dir=$1
  local readme_file="$pack_dir/README.md"

  log_info "Checking if README is present in $pack_dir..."
  if [ -f $readme_file ]; then
    log_success "README.md file is present in pack $pack_dir"
    return 0 
  else
    log_error "README.md file is missing in pack $pack_dir. Please add it..."
    return 1
  fi
} 

#validates if pack.content.images exists in values.yaml

validate_content(){

  local pack_dir=$1
  
  local values_yaml_file="$pack_dir/values.yaml"
  #check if there are non-zero images defined
  local fail=0
  local size=`yq '.pack.content.images|length' $values_yaml_file`
  if [ $size -gt 0 ]; 
  then
   i=0
   while [ $i -lt $size ]
   do

    #check if -image: <image> entry exists within images:
    img=`yq ".pack.content.images.[$i].image" $values_yaml_file`

    if [ "$img" != "" ]; 
    then
      log_info "Valid entry $img found for image in $values_yaml_file" 
    else
      log_error "Invalid entry $img found for images. images should have a -image entry in $values_yaml_file"
      fail =1
    fi
    i=$(expr $i + 1)
   done
  else
   log_error "Image sources size is 0. Include the images used in the pack in $values_yaml_file ..."
   fail=1 
  fi
  if [ $fail -eq 0 ];
  then
    log_success "Successfully verified Image  content section for $pack_dir"
  else
    log_error "Image content verfiication failed for $pack_dir. Make sure you have image: array defined under images: section of values.yaml"
  fi
  return $fail
}

get_pack_layer() {
  local pack_dir=$1
  local layer="$(jq -r '.layer' $pack_dir/pack.json)"
  echo "$layer" 
}
run_validations() {
 local pack_dir
 local final_ret_code=0
 local rc
 for pack_dir in ${pack_dirs[@]}
 do
  log_info "Validating pack $pack_dir..."
  if [ ! -d $pack_dir ];
  then
   log_info "$pack_dir does not exists. Seems to be deleted file. Skip validation for $pack_dir"
   continue
  fi
  validate_pack_schema $pack_dir
  rc=$?
  if [ $rc -ne 0 ]; then
   final_ret_code=$rc
  fi

  validate_logo $pack_dir
  rc=$?
  if [ $rc -ne 0 ]; then
   final_ret_code=$rc
  fi
 
  validate_readme $pack_dir
  rc=$?
  if [ $rc -ne 0 ]; then
   final_ret_code=$rc
  fi
  
  local pack_layer="$(get_pack_layer $pack_dir)"
  if [ "$pack_layer" == "" ];
  then
   log_error "Could not find pack layer for $pack_dir. pack.json is not valid"
  elif [ \( "$pack_layer" == "$PACK_LAYER_OS" \) -o \( "$pack_layer" == "$PACK_LAYER_K8S" \) ];
  then
    log_info "Skipping image content verification for pack belonging to layer $pack_layer"
  else
   validate_content $pack_dir
   rc=$?
   if [ $rc -ne 0 ]; then
    final_ret_code=$rc
   fi
  fi

 done
 return $final_ret_code
}




#Main section starts here
#Go through the modified files and find the top level directory (ies) for pack(s). Build the list of pack directories
for a_file in `cat $MODIFIED_FILES_FILE` 
do
  #check if this modified file is in the container directory for packs.
  top_level_modified_dir="$(cut -d / -f 1 <<< "$a_file")"
  #skip this iteration if the modified file is not within the container directory for packs
  if [ "$top_level_modified_dir" != "$PACKS_CONTAINER_DIRECTORY_NAME" ];
  then
    log_info "$a_file is not belonging to packs. Skipping..."
    continue
  fi 
  
  full_path="${GITHUB_WORKSPACE}/$a_file"
  pack_dir=`get_pack_directory $full_path`
  if [ $? == 0 ]; then
   add_pack_directory $pack_dir
 fi
done 

log_info "Following pack directories were found and will be validated: ${pack_dirs[*]}"

#Now that we have list of pack directories, start validating them
run_validations
ret_code=$?
if [ $ret_code -ne 0 ]; then
 log_error "Packs validation failed..."
else
 log_success "Packs validation successful..."
fi
exit $ret_code
