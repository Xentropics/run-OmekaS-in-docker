#!/bin/bash

while getopts "v:c:t:mu" flag
do
    case "${flag}" in
        v) par_omeka_s_version="--build-arg=omeka_version=${OPTARG}";;
        c) config_profile="${OPTARG}";;
        t) par_image_tag="${OPTARG}";;
        m) skip_modules="no";;
        u|\?) echo "Usage: $0 [-v omeka_version] [-c config_profile] [-t image_tag] [-m] [-u]"; exit 1;;
    esac
done

export OMEKA_IMAGE_TAG=$par_image_tag
export OMEKA_SKIP_MODULES=$skip_modules
export OMEKA_PROFILE=$config_profile