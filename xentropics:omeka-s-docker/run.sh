#!/bin/bash
source ./includes/defaults.sh
source ./includes/getopts.sh
docker container prune -f
#source ./includes/debug.sh
docker-compose --project-name=$config_profile --env-file=profiles/$config_profile/.env up -d
docker container prune -f