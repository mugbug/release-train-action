#!/bin/bash

source $ROOT_PATH/cmds.sh

login_to_github_cli
lint_pr_title $TITLE_LINT_MESSAGE
EXIT_CODE=$?
lint_pr_destination_branch $BASE_BRANCH_LINT_MESSAGE

if [[ $? != 0 || $EXIT_CODE != 0 ]]; then 
    exit $?
fi