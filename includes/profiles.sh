#!/bin/bash

# Ensure $profile_dir is set
if [ -z "$profile_dir" ]; then
    echo "Error: profile_dir is not set."
    exit 1
fi

# Use rsync to copy $profile_dir excluding .git directories
rsync -a --exclude=".git" "$profile_dir" .
