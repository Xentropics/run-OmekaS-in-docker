#!/bin/bash
docker-compose down
docker-compose rm -f
docker system prune -f

