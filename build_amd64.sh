#!/bin/bash
source ./includes/defaults.sh
source ./includes/profiles.sh
source ./includes/getopts.sh
#source ./includes/debug.sh
docker build . --platform linux/amd64 --tag=xentropics/omeka-s:$OMEKA_IMAGE_TAG $par_omeka_s_version


