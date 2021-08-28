#!/bin/bash

echo "🔨 Setup environment"
npm install
git fetch --prune --unshallow
git fetch --tags origin $STABLE_BRANCH
git config --global user.name "github-actions"
git config --global user.email "41898282+github-actions[bot]@users.noreply.github.com"

echo "👤 Login to GH CLI"
echo "$GH_CLI_TOKEN" > token.txt
gh auth login --with-token < token.txt
rm token.txt

echo "🔖 Create tag"
PACKAGE_VERSION=v$(grep version package.json | cut -c 15- | rev | cut -c 3- | rev)
git tag $PACKAGE_VERSION
git push origin $PACKAGE_VERSION

echo "🚀 Create release"
PACKAGE_VERSION=v$(grep version package.json | cut -c 15- | rev | cut -c 3- | rev)
gh release create \
--target $STABLE_BRANCH \
--title $PACKAGE_VERSION \
$PACKAGE_VERSION \
--notes-file RELEASE_NOTES.md