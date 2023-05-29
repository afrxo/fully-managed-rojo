#!/bin/bash

# Fetch place file from cloud
fetch_assets(){
    if [[ ! $ROBLOSECURITY ]]
    then
        # Assume local build runtime
        lune retrieve-assets places.json temp/assets.rbxl
    else
        ROBLOSECURITY=$ROBLOSECURITY lune retrieve-assets places.json temp/assets.rbxl
    fi
    if [ $? -eq 1 ]
    then
        echo "Failed to retrieve assets!"
        exit 1
    else
        echo "Retrieved assets successfully."
    fi
}

# Build a project file based on release
build_file() {
    local name="${1%%.*}"
    local output="temp/$name.rbxl"

    # Compile the codebase
    rojo build $1 -o $output

    # Recompile codebase with assets
    lune sync-assets $name $output temp/assets.rbxl

    # Assign identificators later used by the publish script
    lune set-identity $PLACES_JSON $output $name $BRANCH

    echo "Built $name for release: $BRANCH"
}

# Scrpit requires release to work with
if [[ ! $BRANCH ]]
then
    echo "BRANCH is not assigned!"
    exit 1
fi

# Create the temp folder if it doesn't exist yet
if [ ! -d temp ]
then
    mkdir "temp"
fi

if [ ! -f places.json ];
then
    echo "The index places.json is missing!"
    exit 1
fi
PLACES_JSON=places.json

# Fetch our asset place from the cloud if it hasn't been yet
if [ ! -f temp/assets.rbxl ];
then
    fetch_assets
fi

# Build all project files if none are specified
if [ $# -eq 0 ]
then
    for i in *.project.json; do
        [ -f "$i" ] || break
        build_file $i
    done
else
    for i in "$@"; do
        build_file $i
    done
fi

# Cleanup asset file, it is not needed anymore
rm temp/assets.rbxl