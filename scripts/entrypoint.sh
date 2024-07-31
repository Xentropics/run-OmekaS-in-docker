#!/bin/bash
# 2022-2024 by Jeroen Seeverens, Xentropics (CC BY)

# exit on error so container will terminate
set -e

main () {
   # run apache in the foreground: crash will be detected by container host
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

