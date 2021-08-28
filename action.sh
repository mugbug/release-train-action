#!/bin/bash

if [ $COMMAND = 'release-train']; then
    $ROOT_PATH/release-train.sh
fi

if [ $COMMAND = 'tag']; then
    $ROOT_PATH/tag.sh
fi