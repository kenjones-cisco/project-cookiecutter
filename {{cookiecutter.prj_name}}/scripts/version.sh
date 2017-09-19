#!/bin/bash

set -eu

##
# Depends on the following dependencies:
#
#   envsubst        package gettext
#   git             package git
#   jq binary       https://stedolan.github.io/jq/download/
#   yaml binary     https://github.com/mikefarah/yaml/releases/latest
#
##

MODE="$1"
RELTYPE="${RELEASE_TYPE:-minor}"
TAGTYPE="${TAG_TYPE:-dev}"
PROJECT_FILE="${PROJECT_FILE:-project.yml}"

# export the variables for use by envsubst
export VERSION="${VERSION:?missing required input \'VERSION\'}"
export NEXT_VERSION

# Regex source:
# https://github.com/fsaintjacques/semver-tool
SEMVER_REGEX="^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(\-[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?(\+[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?$"


# Check dependencies
if     [[ -z $(which envsubst 2> /dev/null) ]] \
    || [[ -z $(which git 2> /dev/null) ]] \
    || [[ -z $(which jq 2> /dev/null) ]] \
    || [[ -z $(which yaml 2> /dev/null) ]]; then

    echo "You must install required dependencies [envsubst, git, jq, yaml]."
    exit 1
fi


die() { echo -e "$@" >&2; exit 1; }

bump() {

    [[ "${VERSION}" =~ $SEMVER_REGEX ]] || die "Wrong version format: '${VERSION}'"

    # by comparing the incoming version against the regular expression
    # the '()' indicate capture value. Each value is placed into the
    # bash array 'BASE_REMATCH'. Prerelease and build components are ignored.
    local major=${BASH_REMATCH[1]}
    local minor=${BASH_REMATCH[2]}
    local patch=${BASH_REMATCH[3]}

    case "${RELTYPE}" in
        patch|--patch)
            echo "${major}.${minor}.$((patch + 1))"
            ;;
        minor|--minor)
            echo "${major}.$((minor + 1)).0"
            ;;
        major|--major)
            echo "$((major + 1)).0.0"
            ;;
        *)
            die "Available version increments [--patch, --minor, --major]"
    esac
}

replace() {
    local afile=$1
    local before
    before=$(echo "$2" | envsubst)
    local after
    after=$(echo "$3" | envsubst)
    local tmpfile
    tmpfile="${afile}.tmp"

    # reference http://www.grymoire.com/Unix/Sed.html#uh-22
    # Using inplace results in the ownership and file permissions being lost.
    # By using this approach, if the sed fails then the source file is never touched
    # and by simply coping the content from temp file to source file the ownership and
    # permissions remain intact.
    sed -e 's|'"$before"'|'"$after"'|' "${afile}" > "${tmpfile}" && cp "${tmpfile}" "${afile}" && rm -f "${tmpfile}"
}

get_versioned() {
    local data

    data=$(yaml -j read "${PROJECT_FILE}" metadata.versioned[*] | jq -r '[ .[] | [ .["filename"], .["search"], .["replace"] ] | join("|") ] | join("~")')
    echo "$data"
}

get_filelist() {
    local data

    data=$(yaml -j read "${PROJECT_FILE}" metadata.versioned[*] | jq -r '[ .[] | .["filename"] ] | join("|")')
    echo "$data"
}

process_data() {
    [[ -z "$1" ]] && return 0

    IFS="~" read -r -a data <<< "$1"

    for d in "${data[@]}"; do
        IFS="|" read -r -a args <<< "$d"
        replace "${args[@]}"
    done
}

tag_build() {

    # VERSION exists based on required check above but make sure the value is a Semantic Version formatted value
    [[ "${VERSION}" =~ $SEMVER_REGEX ]] || die "Wrong version format: '${VERSION}'"

    # Check all required inputs are available; value validation happens later
    if [ -z ${PRERELEASE+x} ]; then
        die "Missing required input(s): [PRERELEASE]"
    fi
    case "${PRERELEASE}" in
        alpha|beta|dev|rc)
            # do nothing as these are valid prerelease tags
            ;;
        *)
            echo "PreRelease '${PRERELEASE}' is not a buildable tag; no tag applied"
            exit 0
            ;;
    esac

    if [[ $(git rev-parse --abbrev-ref HEAD) != "develop" ]]; then
        die "Not on 'develop' branch; no tag applied"
    fi

    local git_dirty=$(test -n "$(git -c core.fileMode=false status --porcelain)" && echo "+CHANGES" || true)
    if [[ ${git_dirty} != "" ]]; then
        die "Branch is dirty; no tag applied"
    fi

    local git_describe=$(git describe --tags --always --match "${VERSION}*")
    local build=0
    local prebuild=0

    if [[ ${git_describe} == *"${VERSION}"* ]]; then
        local prerel=${git_describe#*-}
        # check if the pre-release tag is formatted with a build
        #   ex. dev.1
        # Otherwise it will just default the build to 0
        if [[ ${prerel} == *"${PRERELEASE}."* ]]; then
            # If pre-release tag can be in either of the following formats:
            #   dev.4
            #   dev.4-8-gab74315
            # The latter format means the previous tag was dev.4 which was
            # 8 commits ago and the current hash is from git and hash is ab74315.

            # Remove the pre-release name. 'dev.', 'rc.', 'beta.', etc.
            local prebuild_tmp=${prerel#*.}
            # Remove the git applied change information to get the actual build number
            prebuild=${prebuild_tmp%-*-*}
            # increment the build
            build=$((prebuild+1))
        fi
    fi

    # handles scenario where a rebuild happens but the tag was already applied previously.
    # Skip trying to add tag again.
    local git_commit=$(git rev-parse --short HEAD)
    if [[ $(git describe --tags --exact-match "${git_commit}" 2>/dev/null) == "${VERSION}-${PRERELEASE}.${prebuild}" ]]; then
        echo "Commit already tagged; no tag applied"
        exit 0
    fi

    echo "Adding tag: ${VERSION}-${PRERELEASE}.${build}"
    git tag "${VERSION}-${PRERELEASE}.${build}"
}

dev_version() {
    case "${TAGTYPE}" in
        alpha|beta|dev|rc)
            # do nothing as these are valid prerelease tags
            ;;
        *)
            echo "Unexpected TAG_TYPE '${TAGTYPE}'; Valid values: [alpha, beta, dev, rc]"
            exit 1
            ;;
    esac

    # use -B to allow re-running the same command multiple times in case of previous failure
    git checkout -B feature/prepare-"${NEXT_VERSION}" develop

    # update versioned file(s)
    process_data "$(get_versioned)"
    yaml write -i "${PROJECT_FILE}" metadata.version "${NEXT_VERSION}"

    # set prerelease tag
    yaml write -i "${PROJECT_FILE}" metadata.pretag "${TAGTYPE}"
}

release_version() {
    # unset prerelease tag
    yaml write -i "${PROJECT_FILE}" metadata.pretag ''
}

dev_message() {

read -r -d '' msg << EOM
Task: Prepare develop for next version ${NEXT_VERSION}
EOM

    echo "$msg"
}

release_message() {

read -r -d '' msg << EOM
Release: version ${VERSION}

Prepare project for release of version \`${VERSION}\`
EOM

    echo "$msg"
}

commit() {
    local msg=$1
    local vfiles="$(get_filelist)"

    if [[ -z "${vfiles}" ]]; then
        git commit "${PROJECT_FILE}" -m "$msg"
    else
        IFS="|" read -r -a files <<< "${vfiles}"

        # strip out any duplicates
        read -r -a files <<< "$(tr ' ' '\n' <<< "${files[@]}" | sort -u | tr '\n' ' ')"

        git commit "${PROJECT_FILE}" "${files[@]}" -m "$msg"
    fi

}


case "$MODE" in
    build)
        tag_build
        ;;
    dev)
        NEXT_VERSION=$(bump "${VERSION}")
        echo "NEXT_VERSION = ${NEXT_VERSION}"
        dev_version
        commit "$(dev_message)"
        ;;
    rel)
        release_version
        commit "$(release_message)"
        ;;
    *)
      die "Available execution modes: [build, dev, rel]"
esac
