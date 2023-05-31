#!/bin/bash
docker build . --tag=xentropics/omeka-s:0.2.1
docker container prune -f
docker-compose up