#!/bin/bash
docker build . --tag=xentropics/omeka-s:0.1
docker container prune -f
docker-compose up -d