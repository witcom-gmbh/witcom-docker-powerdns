TOPDIR=$(dir $(lastword $(MAKEFILE_LIST)))

DOCKERDIRS=docker-powerdns docker-powerdns-init
DOCKER_TARGETS=docker_build docker_push docker_tag

all: $(DOCKERDIRS)
$(DOCKER_TARGETS): $(DOCKERDIRS)

$(DOCKERDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: all $(DOCKERDIRS) $(DOCKER_TARGETS)