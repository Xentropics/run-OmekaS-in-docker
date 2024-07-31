#!/bin/bash
source includes/prime.sh
docker build . --platform linux/amd64 --tag=xentropics/omeka-s:$OMEKA_IMAGE_TAG $par_omeka_s_version


