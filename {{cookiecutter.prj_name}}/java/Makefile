MAKEFLAGS += -r --warn-undefined-variables
SHELL := /bin/bash
.SHELLFLAGS := -o pipefail -euc
.DEFAULT_GOAL := build

include Makefile.variables
include Makefile.local

.PHONY: help clean veryclean tag-build build{% if cookiecutter.use_codegen == "y" %} build-image{% endif %} format check test cover{% if cookiecutter.use_codegen == "y" %} generate docs{% endif %} todo adhoc next-dev start-release finish-release{% if cookiecutter.use_image == "y" %} pub-image{% endif %}

## display this help message
help:
	@echo 'Management commands for {{cookiecutter.prj_name}}:'
	@echo
	@echo 'Usage:'
	@echo '  ## Build Commands'
	@echo '    build           Compile the project.'
	@echo '    tag-build       Add git tag for latest build.'{% if cookiecutter.use_image == "y" %}
	@echo '    build-image     Build deployable docker image.'{% endif %}
	@echo
	@echo '  ## Develop / Test Commands'
	@echo '    format          Run code formatter.'
	@echo '    check           Run static code analysis (lint).'
	@echo '    test            Run tests on project.'
	@echo '    cover           Run tests and capture code coverage metrics on project.'{% if cookiecutter.use_codegen == "y" %}
	@echo '    generate        Run code generator for project.'
	@echo '    docs            Generate static html documentation for project.'{% endif %}
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
	@rm -rf target/* docs/gen/*

## Same as clean but also removes cached dependencies.
veryclean: clean
	@rm -rf tmp mvn-repo

## builds the dev container
prepare: tmp/dev_image_id
tmp/dev_image_id: Dockerfile.dev
	@chmod 777 target mvn-repo docs/gen/
	@mkdir -p tmp
	@docker rmi -f ${DEV_IMAGE} > /dev/null 2>&1 || true
	@echo "## Building dev container"
	@docker build --quiet -t ${DEV_IMAGE} --build-arg DEVELOPER=$(shell whoami) -f Dockerfile.dev .
	@docker inspect -f "{{ "{{" }} .ID {{ "}}" }}" ${DEV_IMAGE} > tmp/dev_image_id

# ----------------------------------------------
# build

## Compile the project.
build: build/dev

build/dev: format
	${DOCKERRUN} bash ./scripts/build.sh

## Add git tag for latest build.
tag-build: prepare
	${DOCKERNOVENDOR} bash ./scripts/version.sh build

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

## Run code formatter.
format: prepare
	${DOCKERRUN} bash ./scripts/format.sh
ifeq ($(CI_ENABLED),1)
	@if ! git diff-index --quiet HEAD; then echo "java-formater modified code; requires attention!"; exit 1; fi
else
	@if ! git diff-index --quiet HEAD; then echo "java-formater modified code; requires attention!"; fi
endif

## Run static code analysis (lint).
check: format
	${DOCKERRUN} bash ./scripts/check.sh

## Run tests on project.
test: format
	${DOCKERRUN} bash ./scripts/test.sh

## Run tests and capture code coverage metrics on project.
cover: format
ifeq ($(CI_ENABLED),1)
	${DOCKERRUN} bash ./scripts/cover.sh --jenkins
else
	${DOCKERRUN} bash ./scripts/cover.sh
endif{% if cookiecutter.use_image == "y" %}

## Build deployable docker image.
build-image:
	@bash ./scripts/dist.sh

## Push tagged docker images to registry.
pub-image:
	@bash ./scripts/dist.sh --publish{% endif %}{% if cookiecutter.use_codegen == "y" %}

## Run code generator for project.
generate: prepare
	${DOCKERNOVENDOR} bash ./scripts/generate.sh
	@find src \( -path ./mvn-repo -o -path ./.git \) -prune -o -type d -exec chmod 755 {} \; || :
	@find src \( -path ./mvn-repo -o -path ./.git \) -prune -o -name "*.java" -exec chmod 644 {} \; || :

## Generate static html documentation for project.
docs: prepare
	${DOCKERRUN} bash ./scripts/docs.sh{% endif %}

# generate a TODO.md file with a list of TODO and FIXME items sorted by file
# the string is case insensitive and is removed from the output. So the final output
# should provide the file, line number, username that added it, and message about what
# needs to be done.
# Excludes the Makefile from consideration. Only files that are being tracked in git are
# included by default, therefore external dependencies or anything that is part of gitignore
# is automatically excluded.
## Generate a TODO list for project.
todo: prepare
	${DOCKERNOVENDOR} bash ./scripts/todo.sh -e Makefile -e scripts/todo.sh -t '(FIXME|TODO)'

# usage: make adhoc RUNTHIS='command to run inside of dev container'
# example: make adhoc RUNTHIS='which glide'
adhoc: prepare
	@${DOCKERRUN} ${RUNTHIS}

# ----------------------------------------------
# release

## Prepare project for development of next version.
next-dev: prepare
	@echo "## Incrementing version: ${VERSION}"
	${DOCKERNOVENDOR} bash ./scripts/version.sh dev

## Start release of version of project.
start-release: .pre-rel prepare
	@echo "## Starting release for version: ${VERSION}"
	@git flow release start ${VERSION}
	${DOCKERNOVENDOR} bash ./scripts/version.sh rel

## Finish release of version of project.
finish-release: .pre-rel
	@echo "## Releasing version: ${VERSION}"
	@git flow release finish -p -m "Release ${VERSION}" ${VERSION}

.pre-rel:
ifndef HAS_GITFLOW
	$(error "You must install git-flow")
endif
