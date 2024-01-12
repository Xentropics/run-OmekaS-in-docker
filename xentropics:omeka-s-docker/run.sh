#!/bin/bash
source ./includes/defaults.sh
source ./includes/getopts.sh
docker container prune -f
docker-compose --project-name=$config_profile --env-file=./files/etc/profiles/$config_profile/.env up 
docker container prune -f