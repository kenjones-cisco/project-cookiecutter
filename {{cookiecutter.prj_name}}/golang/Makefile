MAKEFLAGS += -r --warn-undefined-variables
SHELL := /bin/bash
.SHELLFLAGS := -o pipefail -euc
.DEFAULT_GOAL := help

include Makefile.variables
include Makefile.local

.PHONY: help clean veryclean tag-build{% if cookiecutter.use_builder == "y" %} build{% endif %}{% if cookiecutter.use_image == "y" %} build-image{% endif %} vendor dep-* format check test cover{% if cookiecutter.use_codegen == "y" %} generate{% endif %}{% if cookiecutter.use_docgen == "y" %} docs{% endif %} todo adhoc next-dev start-release finish-release{% if cookiecutter.use_image == "y" %} pub-image{% endif %}{% if cookiecutter.use_builder == "y" %} xcompile{% endif %}

## display this help message
help:
	@echo 'Management commands for {{cookiecutter.prj_name}}:'
	@echo
	@echo 'Usage:'
	@echo '  ## Build Commands'{% if cookiecutter.use_builder == "y" %}
	@echo '    build           Compile the project.'
	@echo '    xcompile        Compile the project for multiple OS and Architectures.'{% endif %}
	@echo '    tag-build       Add git tag for latest build.'{% if cookiecutter.use_image == "y" %}
	@echo '    build-image     Build deployable docker image.'{% endif %}
	@echo
	@echo '  ## Develop / Test Commands'
	@echo '    vendor          Install dependencies using glide if glide.yaml changed.'
	@echo '    dep-install     Install all dependencies using glide.'
	@echo '    dep-update      Update dependencies using glide.'
	@echo '    dep-add         Add new dependencies to glide and install.'
	@echo '    format          Run code formatter.'
	@echo '    check           Run static code analysis (lint).'
	@echo '    test            Run tests on project.'
	@echo '    cover           Run tests and capture code coverage metrics on project.'{% if cookiecutter.use_codegen == "y" %}
	@echo '    generate        Run code generator for project.'{% endif %}{% if cookiecutter.use_docgen == "y" %}
	@echo '    docs            Generate docs (markdown) for client.'{% endif %}
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
	@rm -rf{% if cookiecutter.use_builder == "y" %} bin build release{% endif %} cover *.out *.xml

## Same as clean but also removes cached dependencies.
veryclean: clean
	@rm -rf tmp .glide vendor

## builds the dev container
prepare: tmp/dev_image_id
tmp/dev_image_id: Dockerfile.dev
	@mkdir -p tmp
	@docker rmi -f ${DEV_IMAGE} > /dev/null 2>&1 || true
	@echo "## Building dev container"
	@docker build --quiet -t ${DEV_IMAGE} --build-arg DEVELOPER=$(shell whoami) -f Dockerfile.dev .
	@docker inspect -f "{{ "{{" }} .ID {{ "}}" }}" ${DEV_IMAGE} > tmp/dev_image_id

# ----------------------------------------------
# build{% if cookiecutter.use_builder == "y" %}

## Compile the project.
build: build/dev

build/dev: check */*.go
	@rm -rf bin/
	@mkdir -p bin
	${DOCKERRUN} bash ./scripts/build.sh
	@chmod 755 bin/* || :

## Compile the project for multiple OS and Architectures.
xcompile: check
	@rm -rf build/
	@mkdir -p build
	${DOCKERRUN} bash ./scripts/xcompile.sh
	@find build -type d -exec chmod 755 {} \; || :
	@find build -type f -exec chmod 755 {} \; || :{% endif %}

## Add git tag for latest build.
tag-build: prepare
	${DOCKERNOVENDOR} bash ./scripts/version.sh build

# ----------------------------------------------
# dependencies
# NOTE: glide will be replaced with `dep` when its production-ready
# ref https://github.com/golang/dep

## Install dependencies using glide if glide.yaml changed.
vendor: tmp/glide-installed
tmp/glide-installed: tmp/dev_image_id glide.yaml
	@mkdir -p vendor
	${DOCKERRUN} glide install --skip-test
	@date > tmp/glide-installed

## Install all dependencies using glide.
dep-install: prepare
	@mkdir -p vendor
	${DOCKERRUN} glide install --skip-test
	@date > tmp/glide-installed

## Update dependencies using glide.
dep-update: prepare
	${DOCKERRUN} glide up --skip-test

# usage DEP=github.com/owner/package make dep-add
## Add new dependencies to glide and install.
dep-add: prepare
ifeq ($(strip $(DEP)),)
	$(error "No dependency provided. Expected: DEP=<go import path>")
endif
	${DOCKERNOVENDOR} glide get --skip-test ${DEP}

# ----------------------------------------------
# develop and test

## print environment info about this dev environment
debug:
	@echo IMPORT_PATH="$(IMPORT_PATH)"
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
format: tmp/glide-installed
	${DOCKERNOVENDOR} bash ./scripts/format.sh
ifeq ($(CI_ENABLED),1)
	@if ! git diff-index --quiet HEAD; then echo "goimports modified code; requires attention!"; exit 1; fi
else
	@if ! git diff-index --quiet HEAD; then echo "goimports modified code; requires attention!"; fi
endif

## Run static code analysis (lint).
check: format
ifeq ($(CI_ENABLED),1)
	${DOCKERNOVENDOR} bash ./scripts/check.sh --jenkins
else
	${DOCKERNOVENDOR} bash ./scripts/check.sh
endif

## Run tests on project.
test: check
	${DOCKERRUN} bash ./scripts/test.sh

## Run tests and capture code coverage metrics on project.
cover: check
	@rm -rf cover/
	@mkdir -p cover
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
	@find . \( -path ./vendor -o -path ./.glide -o -path ./.git \) -prune -o -type d -exec chmod 755 {} \; || :
	@find . \( -path ./vendor -o -path ./.glide -o -path ./.git \) -prune -o -name "*.go" -exec chmod 644 {} \; || :{% endif %}{% if cookiecutter.use_docgen == "y" %}

## Generate docs (markdown) for client.
docs: prepare
	@rm -rf docs/
	@mkdir -p docs/
	${DOCKERNOVENDOR} bash ./scripts/docs.sh
	@find docs -type d -exec chmod 755 {} \; || :
	@find docs -type f -exec chmod 644 {} \; || :{% endif %}

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
