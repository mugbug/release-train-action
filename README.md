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
  lint-pr-title:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: 🔍 Lint PR title
        uses: mugbug/release-train-action@v2
        with:
          pr_title: ${{ github.event.pull_request.title }}
          github_token: ${{ secrets.github_token }}
          error_message: |
            Hello, @${{ github.actor }}!
            The PR title message does not match our conventions. Try renaming it to follow this pattern:
            ```
            type(JIRA-123)!: description
            ```
            > for more info, check [our docs on conventional commits](https://www.notion.so/productquintoandar/Conventional-Commits-a8303a22989043b99366cd127c693182)
```