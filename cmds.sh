#!/bin/bash

# -------------
# pr linter
# -------------

CONVENTIONAL_COMMIT_REGEX="^(feat|fix|chore|refactor|docs|ci)(\(([a-zA-Z]+\-[0-9]+)\))!?:(.*)|release:(.*)$"

function lint_pr_title() {
  echo "🔍 Lint PR title"

  echo "PR TITLE: $PR_TITLE"

  if [[ "$PR_TITLE" =~ $CONVENTIONAL_COMMIT_REGEX ]]; then
    echo "matches"
  else 
    echo "failure title lint"
    send_comment_to_pr $1
    exit 1
  fi
}

function lint_pr_destination_branch() {
  echo "🔍 Check PR destination branch"
  if [[ "$DESTINATION_BRANCH" == "$STABLE_BRANCH" && "$CURRENT_BRANCH" != "$RELEASE_BRANCH" ]]; then
    echo "failure"
    send_comment_to_pr $1
    exit 1
  else
    echo "ok!"
  fi
}

function send_comment_to_pr() {
  echo "💬 Posting comment..."
  gh pr review --comment -b $1
}

# -------------
# release train
# -------------

function setup_git() {
  echo "🔨 Setup environment"
  npm install
  git fetch --prune --unshallow
  fetch_tags
  git config --global user.name "github-actions"
  git config --global user.email "41898282+github-actions[bot]@users.noreply.github.com"
}

function fetch_tags() {
  if [ -z "$CURRENT_BRANCH" ]; then
    git fetch --tags origin $CURRENT_BRANCH
  else
    git fetch --tags origin $DEVELOPMENT_BRANCH
  fi
}

function check_for_new_changes_available() {
    echo "🆕 Ensure new changes for next release"
    # get commits from last tag, filtering release commits
    NEW_COMMITS=$(git log $(git describe --tags --abbrev=0)..HEAD \
        --invert-grep --grep="release" \
        --pretty=oneline)

    if [[ $? != 0 ]]; then
        echo "Error checking for new changes"
        exit 1
    elif [[ $NEW_COMMITS ]]; then
        echo "New commits found"
        exit 0
    else
        echo "No new changes."
        exit 1
    fi
}

function login_to_github_cli() {
  echo "👤 Login to GH CLI"
  echo "$GH_CLI_TOKEN" > token.txt
  gh auth login --with-token < token.txt
  rm token.txt
}

function switch_to_release_branch() {
  echo "🔀 Switch to $RELEASE_BRANCH branch"
  git checkout -b $RELEASE_BRANCH
}

function save_current_release_notes() {
  echo "📝 Save current release notes"
  npx standard-version --dry-run --silent > RELEASE_NOTES.md
  cat RELEASE_NOTES.md
  git add .
  git commit -m 'release: update release notes'
}

function run_standard_version() {
  echo "🚉 Update CHANGELOG and bump version"
  npx standard-version
}

function update_with_base_branch() {
  echo "📥 Update current branch with $STABLE_BRANCH"
  git merge --no-edit --strategy-option ours origin/$STABLE_BRANCH
  git push origin $RELEASE_BRANCH
}

function push_changes_to_current_branch() {
  echo "Push changes to $CURRENT_BRANCH"
  git push origin $CURRENT_BRANCH
}

function open_pull_request_to_development_branch() {
  echo "🔁 Open PRs to $DEVELOPMENT_BRANCH"
  PACKAGE_VERSION=$(grep version package.json | cut -c 15- | rev | cut -c 3- | rev)
  gh pr create --fill \
      --reviewer $RELEASE_OWNER \
      --assignee $RELEASE_OWNER \
      --label release-train \
      --base $STABLE_BRANCH \
      --title "release: $PACKAGE_VERSION" \
      --body "$(cat RELEASE_NOTES.md)"
  gh pr create --fill \
      --reviewer $RELEASE_OWNER \
      --assignee $RELEASE_OWNER \
      --label release-train \
      --base $DEVELOPMENT_BRANCH \
      --title "release: $PACKAGE_VERSION (update develop)" \
      --body "$(cat RELEASE_NOTES.md)"
}

function open_pull_requests() {
  echo "🔁 Open PRs with changes"
  PACKAGE_VERSION=$(grep version package.json | cut -c 15- | rev | cut -c 3- | rev)
  gh pr create --fill \
      --reviewer $RELEASE_OWNER \
      --assignee $RELEASE_OWNER \
      --label release-train \
      --base $STABLE_BRANCH \
      --title "release: $PACKAGE_VERSION" \
      --body "$(cat RELEASE_NOTES.md)"
  gh pr create --fill \
      --reviewer $RELEASE_OWNER \
      --assignee $RELEASE_OWNER \
      --label release-train \
      --base $CURRENT_BRANCH \
      --title "release: $PACKAGE_VERSION (update develop)" \
      --body "$(cat RELEASE_NOTES.md)"
}

function create_tag_for_release_candidate() {
  echo "🔖 Create tag for release candidate on master"
  PACKAGE_VERSION=$(grep version package.json | cut -c 15- | rev | cut -c 3- | rev)
  RELEASE_CANDIDATE_VERSION=v$PACKAGE_VERSION-rc
  git checkout $CURRENT_BRANCH
  git tag $RELEASE_CANDIDATE_VERSION
  git push origin $RELEASE_CANDIDATE_VERSION
}

# ------------
# tagging 
# ------------


function create_tag() {
  echo "🔖 Create tag"
  PACKAGE_VERSION=v$(grep version package.json | cut -c 15- | rev | cut -c 3- | rev)
  git tag $PACKAGE_VERSION
  git push origin $PACKAGE_VERSION
}

function create_release() {
  echo "🚀 Create release"
  PACKAGE_VERSION=v$(grep version package.json | cut -c 15- | rev | cut -c 3- | rev)
  gh release create \
  --target $STABLE_BRANCH \
  --title $PACKAGE_VERSION \
  $PACKAGE_VERSION \
  --notes-file RELEASE_NOTES.md
}

# ------------
# ios specific
# ------------

function increment_xcodeproj_version() {
    version=$(grep version package.json | cut -c 15- | rev | cut -c 3- | rev)
    cd ios
    xcrun agvtool new-marketing-version $version
    xcrun agvtool new-version -all $version.1
    cd ..
    git add .
    git commit -m 'release: bump xcodeproj versions'
}