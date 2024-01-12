#!/bin/bash
par_image_tag="0.4.0"
skip_modules="yes"
while getopts "v:c:t:mu" flag
do
    case "${flag}" in
        v) par_omeka_s_version="--build-arg=omeka_version=${OPTARG}";;
        c) par_config_profile="--build-arg=config_profile=${OPTARG}";;
        t) par_image_tag="${OPTARG}";;
        m) skip_modules="no";;
        u|\?) echo "Usage: $0 [-v omeka_version] [-c config_profile] [-t image_tag] [-m] [-u]"; exit 1;;
    esac
done
docker build . --tag=xentropics/omeka-s:$par_image_tag $par_omeka_s_version $par_config_profile
docker container prune -f
export tag=$par_image_tag
export OMEKA_SKIP_MODULES=$skip_modules
docker-compose --project-name=$par_config_profile up
