# Git Log Markdown Formatter

Git Log Markdown Formater is a command line tool to convert a given git log one line output to markdown syntax by reformating and adding content like commit and issue links.


## How to use it

Create a git log for your desired git repository by calling

```bash
git log --format="s=%s;H=%H;an=%an"
```

You can modify the git log command as you like but you will always have to use ```--format="s=%s;H=%H;an=%an"``` to output the correct format.

### Parameters

### The template




### Pipeline example



## Executable binary

The binary can be fetched from the latest release on Github or you can compile it yourself.

```bash
cd /git/repo
dart pub get
dart compile exe bin/git_log_markdown_formatter.dart -o glmf
```
