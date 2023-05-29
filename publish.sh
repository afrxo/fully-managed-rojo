#!/bin/bash

# Publish a built rbxl file
publish_file() {
    RBX_API_KEY=$RBX_API_KEY lune publish $1
    if [ $? -eq 1 ]
    then
        echo "Failed to publish $1!"
        exit 1
    else
        echo "Published $1 successfully."
    fi
}

# Script requires an api key to work
if [[ ! $RBX_API_KEY ]]
then
    echo "Environment variable RBX_API_KEY is missing."
    exit 1
fi

# Publish all built rbxl files if none are specified
if [ $# -eq 0 ]
then

    # Script reads from temp folder, cannot access if ti does not exist
    if [ ! -d temp ]
    then
        echo "Temp folder does not exist!"
        exit 1
    fi

    # Files should exist if temp folder does
    if [ $(ls temp | wc -l) -eq 0 ]
    then
        echo "No files found to publish!"
        exit 1
    fi

    for i in $(ls temp);do
        if [[ $i =~ .*\.rbxl$ ]];then
            publish_file temp/$i
        fi
    done
else
    for i in "$@"; do
        if [ -f $i ]
        then
            publish_file $i
        else
            echo "Cannot access '$i': No such file or directory"
        fi
    done
fi