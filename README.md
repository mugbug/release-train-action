# release-train-action

## PR title linter

```yaml
name: 🔍 Lint PR

on:
  pull_request:
    types:
      - opened
      - edited
      - synchronize
jobs:
  lint-pr:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: 🔍 Lint PR
        continue-on-error: false
        uses: mugbug/release-train-action@v1-beta
        with:
          command: pr-linter
          token: ${{ secrets.github_token }}
          destination-branch: ${{ github.event.pull_request.base.ref }}
          current-branch: ${{ github.event.pull_request.head.ref }}
          pr-title: ${{ github.event.pull_request.title }}
          title-lint-message: |
            Hello, @${{ github.actor }}!

            The PR title message does not match our conventions. Try renaming it to follow this pattern:
            
                type(JIRA-123)!: description

            > for more info, check [our docs on conventional commits](http://google.com)

          base-branch-lint-message: |
            Hello, @${{ github.actor }}!

            Only our automated release train can merge into masterV3 now. Try switching the base branch to developV3

            > for more info, check [our docs on git flow](http://google.com)
```

## Scheduled release train

```yaml
name: 🚞 Scheduled Release Train
on:
  workflow_dispatch:
  schedule:
    - cron: '0 16 * * 4' # trigger a release every thursday at 16h UTC (1pm BRT)

jobs:
  release-train:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: 🚞 Scheduled Release Train
        continue-on-error: false
        uses: mugbug/release-train-action@v1-beta
        with:
          command: release-train
          token: ${{ secrets.github_token }}
          destination-branch: ${{ github.event.pull_request.base.ref }}
          current-branch: ${{ github.event.pull_request.head.ref }}
          development-branch: develop
          stable-branch: master
          release-branch: release-train
          release-owner: mugbug
```

## Create tag and release

```yaml
name: 🔖 Create tag and release
on:
  push:
    branches:
      - master

jobs:
  tag-and-release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: 🔖 Create tag and release
        continue-on-error: false
        uses: mugbug/release-train-action@v1-beta
        with:
          command: tag
          token: ${{ secrets.github_token }}
          stable-branch: master
```