#!/bin/bash
par_image_tag="0.4.0"
while getopts v:c:t: flag
do
    case "${flag}" in
        v) par_omeka_s_version="--build-arg=omeka_version=${OPTARG}";;
        c) par_config_profile="--build-arg=config_profile=${OPTARG}";;
        t) par_image_tag="${OPTARG}";;
        u) echo "Usage: $0 [-v omeka_version] [-t image_tag] [-c config_profile]"; exit 1;;
    esac
done
docker build . --tag=xentropics/omeka-s:$par_image_tag $par_omeka_s_version $par_config_profile
docker container prune -f
export tag=$par_image_tag
docker-compose up
