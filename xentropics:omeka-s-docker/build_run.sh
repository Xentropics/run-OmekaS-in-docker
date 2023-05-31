#!/bin/bash
docker build . --tag=xentropics/omeka-s:0.3.0
docker container prune -f
docker-compose up