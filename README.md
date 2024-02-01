# Git Log Markdown Formatter

Git Log Markdown Formater is a command line tool to convert a git log one line output to markdown syntax by reformating and adding content like commit and issue links.

- [Git Log Markdown Formatter](#git-log-markdown-formatter)
  - [How to use it](#how-to-use-it)
    - [Example](#example)
    - [Parameters](#parameters)
    - [The template](#the-template)
    - [Pipeline example](#pipeline-example)
      - [.gitlab-ci.yml](#gitlab-ciyml)
  - [Executable binary](#executable-binary)

## How to use it

### Example

```bash
./glmf format -o release_notes.md --header "# Release 1.0.0" 
--footer "Autogenerated by pipeline 56748" --iBaseUrl "https://github.com/Ephenodrom/Git-Log-Markdown-Formatter/issues" 
--cBaseUrl "https://github.com/Ephenodrom/Git-Log-Markdown-Formatter/commit/" 
--form "1.0.0" --to "1.0.1"
```

### Parameters

| Option | Description | Allowed values | Required |
| ------------- | ------------- | ------------- | ------------- |
| --from  | The tag from which the git log should be generated |  | |
| --to  | The tag until the git log should be generated |  | |
| --outputfile, -o  | The file to write the markdown to. If left, the markdown will be printed to standard out.  |  |  |
| --template, -t  | The template to use for each line. | See [The template](#the-template) (default= "- %s %H by %an") |  |
| --issueType | The issue management software you use. | JIRA (default), GITHUB, GITLAB |  |
| --iBaseUrl | The base url to display the issue. |  | Required if addIssueLink != NONE |
| --cBaseUrl | The base url to display the commit. |  | Required if addCommitLink != NONE |
| --addIssueLink  | Whether to add a issue link within the subject (%s) if one is found. | NONE, REPLACE (default), PREPEND, APPEND |  |
| --addCommitLink | Whether to add a commit link to the hash (%H) or replace it. | NONE, REPLACE (default), PREPEND, APPEND |  |
| --header | String to append at the beginning of the markdown. |  |  |
| --footer| String to append at the end of the markdown. |  |  |

### The template

You can define a custom template to order the values in a certain order or to create a readable markdown. The default template is set to **"- %s %H by %an"** and with all other default settings, this will result in something similar to this:

```txt
- [JIRA-2](https://jira.com/JIRA-2) [aa1114f4d27a049ac4e01fa78402eee965a1528a](https://github.com/Foo/Bar/commit/aa1114f4d27a049ac4e01fa78402eee965a1528a) by Ephenodrom
- Update README.md [c491eb38b129b85a21e6482c8e7e7a8cdd02e03a](https://github.com/Foo/Bar/commit/aa1114f4d27a049ac4e01fa78402eee965a1528a) by Ephenodrom
```

The allowed values:

- **%H**: Commit hash (full).
- **%h**: Abbreviated commit hash.
- **%T**: Tree hash.
- **%t**: Abbreviated tree hash.
- **%P**: Parent hashes.
- **%p**: Abbreviated parent hashes.
- **%an**: Author name.
- **%ae**: Author email.
- **%ad**: Author date (default format).
- **%ar**: Author date, relative.
- **%cn**: Committer name.
- **%ce**: Committer email.
- **%cd**: Committer date (default format).
- **%cr**: Committer date, relative.
- **%s**: Subject (commit message).
- **%b**: Body (commit message).

>>>
The allowed values are basically the same as you can use in **git log** except the new line %N.
>>>

### Pipeline example

#### .gitlab-ci.yml

```yaml

generate_changelog:
  stage: release
  image: ${IMAGE_THAT_INCLUDES_GIT_AND_CURL}
  only:
    - tags
  script:
    - ISSUE_BASEURL=
    - COMMIT_BASEURL=
    - # Get the latest release information using the GitHub API
    - RELEASE_INFO=$(curl -s "https://api.github.com/repos/Ephenodrom/Git-Log-Markdown-Formatter/releases/latest")
    - # Extract the download URL for the artifact
    - DOWNLOAD_URL=$(echo "$RELEASE_INFO" | jq -r ".assets[] | select(.name == \"glmf\") | .browser_download_url")
    - # Download the artifact using curl
    - curl -LJO "$DOWNLOAD_URL"
    - chmod
    - FROM=$(git describe --tags --abbrev=0 $(git rev-list --tags --skip=1 --max-count=1))
    - ./glmf format -from "$FROM" -to "$CI_COMMIT_TAG" -o release_notes.md --header "# Release $CI_COMMIT_TAG" --footer "Autogenerated by pipeline $CI_PIPELINE_ID" --iBaseUrl "$ISSUE_BASEURL" --cBaseUrl "https://github.com/Ephenodrom/Git-Log-Markdown-Formatter/commit/"
  artifacts:
    paths:
    - release_notes.md
```

>>>
The CI CD job assumes that the tag for the current release was created before this job is running and $CI_COMMIT_TAG contains the current tag you want to release.
>>>

## Executable binary

The binary can be fetched from the latest release on Github or you can compile it yourself.

```bash
cd /git/repo
dart pub get
dart compile exe bin/git_log_markdown_formatter.dart -o glmf
```
