#!/bin/bash
source ./includes/defaults.sh
source ./includes/profiles.sh
source ./includes/getopts.sh
if [ "$debug" = "yes" ]; then
    source ./includes/debug.sh
fi
cp $profile_dir/$OMEKA_PROFILE/.env .
source ./.env