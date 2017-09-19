MAKEFLAGS += -r --warn-undefined-variables
SHELL := /bin/bash
.SHELLFLAGS := -o pipefail -euc
.DEFAULT_GOAL := help

include Makefile.variables
include Makefile.local

.PHONY: help clean veryclean tag-build{% if cookiecutter.use_image == "y" %} build-image{% endif %} check test todo adhoc next-dev start-release finish-release{% if cookiecutter.use_image == "y" %} pub-image{% endif %}

## display this help message
help:
	@echo 'Management commands for {{cookiecutter.prj_name}}:'
	@echo
	@echo 'Usage:'
	@echo '  ## Build Commands'
	@echo '    tag-build       Add git tag for latest build.'{% if cookiecutter.use_image == "y" %}
	@echo '    build-image     Build deployable docker image.'{% endif %}
	@echo
	@echo '  ## Develop / Test Commands'
	@echo '    check           Run static code analysis (lint).'
	@echo '    test            Run tests on project.'
	@echo '    todo            Generate a TODO list for project.'
	@echo '    clean           Clean the directory tree of produced artifacts.'
	@echo '    veryclean       Same as clean but also removes cached dependencies.'
	@echo
	@echo '  ## Release Commands'{% if cookiecutter.use_image == "y" %}
	@echo '    pub-image       Push tagged docker images to registry.'{% endif %}
	@echo '    next-dev        Prepare project for development of next version.'
	@echo '    start-release   Start release of version of project.'
	@echo '    finish-release  Finish release of version of project.'
	@echo
	@echo '  ## Local Commands'
	@echo '    setup           Configures Minishfit/Docker directory mounts.'
	@echo '    drma            Removes all stopped containers.'
	@echo '    drmia           Removes all unlabelled images.'
	@echo '    drmvu           Removes all unused container volumes.'
	@echo

## Clean the directory tree of produced artifacts.
clean:
	@:

## Same as clean but also removes cached dependencies.
veryclean: clean
	@rm -rf tmp

## builds the dev container
prepare: tmp/dev_image_id
tmp/dev_image_id: Dockerfile.dev
	@mkdir -p tmp
	@docker rmi -f ${DEV_IMAGE} > /dev/null 2>&1 || true
	@echo "## Building dev container"
	@docker build --quiet -t ${DEV_IMAGE} --build-arg DEVELOPER=$(shell whoami) -f Dockerfile.dev .
	@docker inspect -f "{{ "{{" }} .ID {{ "}}" }}" ${DEV_IMAGE} > tmp/dev_image_id

# ----------------------------------------------
# build

## Add git tag for latest build.
tag-build: prepare
	${DOCKERRUN} bash ./scripts/version.sh build

# ----------------------------------------------
# develop and test

## print environment info about this dev environment
debug:
	@echo ROOT="$(ROOT)"
	@echo VERSION="$(VERSION)"
	@echo PRERELEASE="$(PRERELEASE)"
	@echo RELEASE_TYPE="$(RELEASE_TYPE)"
	@echo TAG_TYPE="$(TAG_TYPE)"{% if cookiecutter.use_image == "y" %}
	@echo IMAGE_NAME="$(IMAGE_NAME)"{% endif %}
	@echo
	@echo docker commands run as:
	@echo "$(DOCKERRUN)"

## Run static code analysis (lint).
check: prepare
	${DOCKERRUN} bash ./scripts/check.sh

## Run tests on project.
test: format
	${DOCKERRUN} bash ./scripts/test.sh{% if cookiecutter.use_image == "y" %}

## Build deployable docker image.
build-image:
	@bash ./scripts/dist.sh

## Push tagged docker images to registry.
pub-image:
	@bash ./scripts/dist.sh --publish{% endif %}

# generate a TODO.md file with a list of TODO and FIXME items sorted by file
# the string is case insensitive and is removed from the output. So the final output
# should provide the file, line number, username that added it, and message about what
# needs to be done.
# Excludes the Makefile from consideration. Only files that are being tracked in git are
# included by default, therefore external dependencies or anything that is part of gitignore
# is automatically excluded.
## Generate a TODO list for project.
todo: prepare
	${DOCKERRUN} bash ./scripts/todo.sh -e Makefile -e scripts/todo.sh -t '(FIXME|TODO)'

# usage: make adhoc RUNTHIS='command to run inside of dev container'
# example: make adhoc RUNTHIS='which glide'
adhoc: prepare
	@${DOCKERRUN} ${RUNTHIS}

# ----------------------------------------------
# release

## Prepare project for development of next version.
next-dev: prepare
	@echo "## Incrementing version: ${VERSION}"
	${DOCKERRUN} bash ./scripts/version.sh dev

## Start release of version of project.
start-release: .pre-rel prepare
	@echo "## Starting release for version: ${VERSION}"
	@git flow release start ${VERSION}
	${DOCKERRUN} bash ./scripts/version.sh rel

## Finish release of version of project.
finish-release: .pre-rel
	@echo "## Releasing version: ${VERSION}"
	@git flow release finish -p -m "Release ${VERSION}" ${VERSION}

.pre-rel:
ifndef HAS_GITFLOW
	$(error "You must install git-flow")
endif
