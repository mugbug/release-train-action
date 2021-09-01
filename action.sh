#!/bin/bash

if [ "$COMMAND" = "release-train" ]; then
    $ROOT_PATH/release-train.sh

    if [ "$RELEASE_TYPE" = "ios" ]; then
        $ROOT_PATH/ios_testflight.sh
        $ROOT_PATH/ios_appstore.sh
    fi

    exit $?
fi

if [ "$COMMAND" = "tag" ]; then
    $ROOT_PATH/tag.sh
    exit $?
fi

if [ "$COMMAND" = "pr-linter" ]; then
    $ROOT_PATH/pr-linter.sh
    exit $?
fi

if [ "$COMMAND" = "hotfix" ]; then
    $ROOT_PATH/hotfix.sh
    exit $?
fi