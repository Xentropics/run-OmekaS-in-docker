#!/bin/bash
read -p "This will destroy all data... Are you sure? " -n 1 -r
echo   
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi
docker-compose down
docker-compose rm -f
docker system prune -f -a --volumes

