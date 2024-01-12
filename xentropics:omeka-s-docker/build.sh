#!/bin/bash
source ./includes/defaults.sh
source ./includes/getopts.sh
docker build . --tag=xentropics/omeka-s:$par_image_tag $par_omeka_s_version $par_config_profile
./run.sh "$@"


