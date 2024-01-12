#!/bin/bash
source ./includes/defaults.sh
source ./includes/getopts.sh
#source ./includes/debug.sh
docker build . --tag=xentropics/omeka-s:$OMEKA_IMAGE_TAG $par_omeka_s_version
./run.sh "$@"


