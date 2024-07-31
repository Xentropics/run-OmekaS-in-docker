#!/bin/bash

# Function to display usage message
usage() {
  echo "Usage: $0 -c <conf> -o <outputfile>"
  exit 1
}

# Check for correct number of arguments
if [ "$#" -ne 4 ]; then
  usage
fi

# Parse command line arguments
while getopts "c:o:" opt; do
  case $opt in
    c) CONF="$OPTARG"
    ;;
    o) OUTPUTFILE="$OPTARG"
    ;;
    \?) usage
    ;;
  esac
done

# Verify that the profile.json exists in the specified conf directory
PROFILE_PATH="./profiles/$CONF/profile.json"
if [ ! -f "$PROFILE_PATH" ]; then
  echo "Error: profile.json not found in ./profiles/$CONF"
  exit 1
fi

# Use jq to extract the necessary information and write to the output file
jq -r '.modules[] | select(.install == true) | .version as $ver | [.name, .version, (.zipUrl | gsub("\\$\\{version\\}"; $ver))] | @tsv' "$PROFILE_PATH" > "$OUTPUTFILE"

echo "Output written to $OUTPUTFILE"