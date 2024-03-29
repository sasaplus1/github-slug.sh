#!/bin/bash

__github-slug() {
  (
    set -euo pipefail

    local count=100
    local is_archived=
    local is_disabled=
    local is_fork=
    local is_locked=
    local is_mirror=
    local is_private=
    local is_template=
    local order=last
    local user=

    help() {
      # NOTE: don't replace Tab indentations
      printf -- '%s\n' "$(
        cat <<-EOB
				usage: ${_GITHUB_SLUG_COMMAND:-github-slug} [-acdflmoptu <value>] [-h]
				
				options:
				    -a (true | false)             filter archived repository
				    -c <int>                      max output count [100]
				    -d (true | false)             filter disabled repository
				    -f (true | false)             filter forked repository
				    -h                            output this message
				    -l (true | false)             filter locked repository
				    -m (true | false)             filter mirrored repository
				    -o (asc | desc)               output order [desc]
				    -p (true | false)             filter private repository
				    -t (true | false)             filter template repository
				    -u <user or organization>     user name or organization name
				EOB
      )"
    }

    while getopts a:c:d:f:hl:m:o:p:t:u: OPT
    do
      case "$OPT" in
        a)
          is_archived="$OPTARG"
          ;;
        c)
          count="$OPTARG"
          ;;
        d)
          is_disabled="$OPTARG"
          ;;
        f)
          is_fork="$OPTARG"
          ;;
        h)
          help
          exit 1
          ;;
        l)
          is_locked="$OPTARG"
          ;;
        m)
          is_mirror="$OPTARG"
          ;;
        o)
          order="$OPTARG"
          ;;
        p)
          is_private="$OPTARG"
          ;;
        t)
          is_template="$OPTARG"
          ;;
        u)
          user="$OPTARG"
          ;;
        *)
          ;;
      esac
    done

    local -r gh=$(bash -c 'type gh >/dev/null 2>&1; echo $?')

    if [ "$gh" -ne 0 ]
    then
      echo 'gh command not found' >&2
      exit 2
    fi

    shopt -s nocasematch

    [[ "$order" =~ ^a ]] && order=first
    [[ "$order" =~ ^d ]] && order=last

    shopt -u nocasematch

    # NOTE: don't replace Tab indentations
    local -r template=$(
      cat <<-'EOB'
			query {
			  search(type: REPOSITORY, query: "user:%s", %s: %d) {
			    edges {
			      node {
			        ... on Repository {
			          isArchived
			          isDisabled
			          isFork
			          isLocked
			          isMirror
			          isPrivate
			          isTemplate
			          nameWithOwner
			        }
			      }
			    }
			  }
			}
			EOB
    )

    # shellcheck disable=SC2059
    local -r query="$(printf -- "$template" "$user" "$order" "$count")"

    local select=true

    shopt -s nocasematch

    [[ "$is_archived" =~ true|false ]] && select="$select and .isArchived == $is_archived"
    [[ "$is_disabled" =~ true|false ]] && select="$select and .isDisabled == $is_disabled"
    [[ "$is_fork"     =~ true|false ]] && select="$select and .isFork     == $is_fork"
    [[ "$is_locked"   =~ true|false ]] && select="$select and .isLocked   == $is_locked"
    [[ "$is_mirror"   =~ true|false ]] && select="$select and .isMirror   == $is_mirror"
    [[ "$is_private"  =~ true|false ]] && select="$select and .isPrivate  == $is_private"
    [[ "$is_template" =~ true|false ]] && select="$select and .isTemplate == $is_template"

    shopt -u nocasematch

    local -r filter=".data.search.edges[].node | select($select) | .nameWithOwner"

    command gh api graphql --field query="$query" --jq "$filter"
  )
}

eval "$(printf -- '%s() { __github-slug "$@"; }' "${_GITHUB_SLUG_COMMAND:-github-slug}")"

# vim:list:ts=2
