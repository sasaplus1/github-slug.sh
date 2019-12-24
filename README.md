# github-slug.sh

[![test](https://github.com/sasaplus1/github-slug.sh/workflows/test/badge.svg)](https://github.com/sasaplus1/github-slug.sh/actions?query=workflow%3Atest)

get slugs from GitHub

## Installation

add to `.bashrc` or `.bash_profile` the following:

```console
. /path/to/github-slug.sh
```

## Requirements

- [hub](https://hub.github.com/)
- [jq](https://stedolan.github.io/jq/)

## Usage

output repository slugs:

```console
$ github-slug -u sasaplus1
```

output only private repository slugs:

```console
$ github-slug -u sasaplus1 -p true
```

output repository slugs without private repositories:

```console
$ github-slug -u sasaplus1 -p false
```

for GitHub Enterprise:

```console
$ GITHUB_HOST=example.com github-slug -u sasaplus1
```

more info:

```console
$ github-slug -h
```

## Change command name

```console
$ export _GITHUB_SLUG_COMMAND=slug
$ . /path/to/github-slug.sh
$ slug -h
```

## License

The MIT license.
