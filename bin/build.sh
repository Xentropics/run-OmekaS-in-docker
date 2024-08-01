#!/bin/bash
source ./includes/prime.sh
docker build . --tag=xentropics/omeka-s:$OMEKA_IMAGE_TAG $par_omeka_s_version


