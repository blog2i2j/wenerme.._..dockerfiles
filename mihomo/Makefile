REPO_ROOT ?= $(shell git rev-parse --show-toplevel)
-include $(REPO_ROOT)/build.mk

# https://github.com/MetaCubeX/mihomo/releases
export VERSION:=1.19.1

print:
	docker buildx bake --print

push:
	docker buildx bake --push --progress=plain
