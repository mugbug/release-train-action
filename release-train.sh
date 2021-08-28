echo "🔨 Setup environment"
npm install
git fetch --prune --unshallow
git fetch --tags origin $CURRENT_BRANCH
git config --global user.name "github-actions"
git config --global user.email "41898282+github-actions[bot]@users.noreply.github.com"

echo "👤 Login to GH CLI"
echo "${{ secrets.GITHUB_TOKEN }}" > token.txt
gh auth login --with-token < token.txt
rm token.txt

echo "🔀 Switch to release branch"
git checkout -b release-train

echo "📝 Save current release notes"
npx standard-version --dry-run --silent > RELEASE_NOTES.md
cat RELEASE_NOTES.md
git add .
git commit -m 'release: update release notes'

echo "🚉 Update CHANGELOG and bump version"
npx standard-version

echo "📥 Update current branch with master"
git merge --no-edit --strategy-option ours origin/$STABLE_BRANCH
git push origin release-train

echo "🔁 Open PRs with changes"
PACKAGE_VERSION=$(grep version package.json | cut -c 15- | rev | cut -c 3- | rev)
gh pr create --fill \
    --reviewer mugbug \
    --assignee mugbug \
    --label release-train \
    --base $STABLE_BRANCH \
    --title "release: $PACKAGE_VERSION" \
    --body "$(cat RELEASE_NOTES.md)"
gh pr create --fill \
    --reviewer mugbug \
    --assignee mugbug \
    --label release-train \
    --base $CURRENT_BRANCH \
    --title "release: $PACKAGE_VERSION (update develop)" \
    --body "$(cat RELEASE_NOTES.md)"

echo "🔖 Create tag for release candidate on master"
PACKAGE_VERSION=$(grep version package.json | cut -c 15- | rev | cut -c 3- | rev)
RELEASE_CANDIDATE_VERSION=v$PACKAGE_VERSION-rc
git checkout $CURRENT_BRANCH
git tag $RELEASE_CANDIDATE_VERSION
git push origin $RELEASE_CANDIDATE_VERSION