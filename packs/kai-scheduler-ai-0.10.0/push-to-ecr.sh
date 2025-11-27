#!/bin/bash

# Color variables
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'

# Clear the color after that
clear='\033[0m'

set -e

export REGISTRY_NAME=custeng-sa-oci
export AWS_DEFAULT_REGION=eu-west-2
export ACCOUNT_ID=$(aws sts get-caller-identity|jq -r ".Account")


#Get the name and version from pack.json
export NAME=$(cat pack.json | jq -r ".name")
export VERSION=$(cat pack.json | jq -r ".version")

#Login to ECR with ORAS
aws ecr get-login-password --region $AWS_DEFAULT_REGION | oras login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com

#Prep the pack to be pushed to ECR
#Check if an old/previous tar file already exists, if so delete it
#Create the pack tar file and keep it in the pack directory  
if [ -f $NAME-$VERSION.tar.gz ]; then
    rm $NAME-$VERSION.tar.gz
fi
cd ../
tar -czvf $NAME-$VERSION.tar.gz $NAME-$VERSION
mv $NAME-$VERSION.tar.gz $NAME-$VERSION/
cd $NAME-$VERSION/

#Check if the base path repository to store your pack repositories already exists, 
#Create one ONLY if it doesn't

aws ecr describe-repositories --repository-name $REGISTRY_NAME/spectro-packs/archive --region $AWS_DEFAULT_REGION > /dev/null || aws ecr create-repository --repository-name $REGISTRY_NAME/spectro-packs/archive --region $AWS_DEFAULT_REGION > /dev/null

#Check if the pack repository, within the base path, already exists
#Create it if it doesn't

aws ecr describe-repositories --repository-name $REGISTRY_NAME/spectro-packs/archive/$NAME --region $AWS_DEFAULT_REGION > /dev/null || aws ecr create-repository --repository-name $REGISTRY_NAME/spectro-packs/archive/$NAME --region $AWS_DEFAULT_REGION > /dev/null


#Push the pack to the ECR OCI Pack Repository using ORAS
oras push $ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$REGISTRY_NAME/spectro-packs/archive/$NAME:$VERSION $NAME-$VERSION.tar.gz


echo -e "\nThe pack ${yellow}$NAME v$VERSION${clear} has been ${green}successully pushed${clear} to your ${yellow}$REGISTRY_NAME${clear} ECR registry "

