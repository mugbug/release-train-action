#!/bin/bash

source $ROOT_PATH/cmds.sh

login_to_github_cli
cat TITLE_LINT_MESSAGE | lint_pr_title
EXIT_CODE=$?
cat BASE_BRANCH_LINT_MESSAGE | lint_pr_destination_branch

if [[ $? != 0 || $EXIT_CODE != 0 ]]; then 
    exit $?
fi