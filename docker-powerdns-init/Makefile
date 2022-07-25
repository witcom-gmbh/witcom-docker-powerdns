PROJECT_NAME=pdns-gmysql-init

include ../Makefile.docker
DOCKER_TAG         = $(PDNS_AUTH_RELEASE)

docker_build: docker_build_default
	# Do build

docker_push: docker_push_default

.PHONY: docker_build docker_push