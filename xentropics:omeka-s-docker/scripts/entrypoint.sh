#!/bin/bash
# 2022 by Jeroen Seeverens, Xentropics (CC BY)

# exit on error so docker image will terminate
set -e

main () {
   # run apache in the foreground: crash will be detected by docker host
   echo "entrypoint.sh : starting Apache"
   apache2-foreground
}

if [[ ! -f "bootstrapped.flag" ]] 
then
   echo "entrypoint.sh : first boot, running bootstrap.sh"
   source /opt/imageboot/bootstrap.sh
   touch bootstrapped.flag
fi 
main

