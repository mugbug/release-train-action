#!/bin/bash

if [ "$COMMAND" = "release-train" ]; then
    $ROOT_PATH/release-train.sh
fi

if [ "$COMMAND" = "tag" ]; then
    $ROOT_PATH/tag.sh
fi

if [ "$COMMAND" = "pr-linter" ]; then
    $ROOT_PATH/pr-linter.sh
fi

if [ "$COMMAND" = "hotfix" ]; then
    $ROOT_PATH/hotfix.sh
fi