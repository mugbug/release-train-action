#!/bin/bash

source ./cmds.sh

lint_pr_title "$BASE_BRANCH_LINT_MESSAGE"
lint_pr_destination_branch "$TITLE_LINT_MESSAGE"