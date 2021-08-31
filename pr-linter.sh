#!/bin/bash

source $ROOT_PATH/cmds.sh

login_to_github_cli
lint_pr_title "$BASE_BRANCH_LINT_MESSAGE"
lint_pr_destination_branch "$TITLE_LINT_MESSAGE"