MAKEFLAGS += -r --warn-undefined-variables
SHELL := /bin/bash
.SHELLFLAGS := -o pipefail -euc
.DEFAULT_GOAL := test

export PROJECT = project-cookiecutter
export IMAGE_NAME = kenjones/cookiecutter

# Windows environment?
CYG_CHECK := $(shell hash cygpath 2>/dev/null && echo 1)
ifeq ($(CYG_CHECK),1)
	VBOX_CHECK := $(shell hash VBoxManage 2>/dev/null && echo 1)

	# Docker Toolbox (pre-Windows 10)
	ifeq ($(VBOX_CHECK),1)
		export ROOT := /${PROJECT}
	else
		# Docker Windows
		export ROOT := $(shell cygpath -m -a "$(shell pwd)")
	endif
else
	# all non-windows environments
	export ROOT := $(shell pwd)
endif


clean:
	@rm -rf _test_local _test_remote _tryme

build:
	docker build -t ${IMAGE_NAME} .

publish:
	docker push ${IMAGE_NAME}

test: clean
	@bash ./scripts/test.sh

tryme: clean
ifeq ($(strip $(CONFIG)),)
	$(error "No context configuration file provided. Expected: CONFIG=<path to context config file>")
endif
	@echo "Generating specified app"
	@docker run --rm -i -v ${ROOT}:/mnt ${IMAGE_NAME} --config-file /mnt/${CONFIG} --no-input --output-dir /mnt/_tryme /mnt

setup:
	@bash ./scripts/setup.sh

# ------ Docker Helpers
drma:
	docker rm $(shell docker ps -a -q)

drmia:
	docker rmi $(shell docker images -q --filter "dangling=true")

drmvu:
	docker volume rm $(shell docker volume ls -qf dangling=true)
