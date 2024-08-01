#!/bin/bash
source ./includes/prime.sh
docker-compose --project-name=$config_profile --env-file=profiles/$config_profile/.env -f docker-compose.yml -f profiles/$config_profile/docker-compose.yml up -d