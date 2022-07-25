PROJECT_NAME=pdns

include ../Makefile.docker

DOCKER_TAG         = $(PDNS_AUTH_RELEASE)
DOCKER_BUILD_ARGS  ?= --build-arg PDNS_AUTH_RELEASE=$(PDNS_AUTH_RELEASE)

docker_build: docker_build_default
	# Do build

docker_push: docker_push_default
	# Do push

.PHONY: docker_build docker_push