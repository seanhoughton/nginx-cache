ifeq ($(OS),Windows_NT)
	detected_OS := Windows
	export PWD?=$(shell echo %CD%)
	export SHELL=cmd
	export VERSION=unknown
else
	detected_OS := $(shell uname -s)
	export VERSION=$(shell git describe --tags --dirty 2>/dev/null || echo unknown)
endif

export IMAGENAME=seanhoughton/nginx-cache
DOCKER_LABEL?=test
export TAG=$(DOCKER_LABEL)
VERBOSE?=1
LISTENPORT?=3335
UPSTREAM?=https://nginx.org
CACHE_SIZE?=64M
WORKERS?=8
MAX_EVENTS?=1024
BUILDOPTS?=
USE_PERFLOG?=0
SSL?=off
VTX_MODULE=https://github.com/vozlt/nginx-module-vts.git:v0.1.17

.PHONY: image run clean

image:
	docker build --build-arg VERSION=$(VERSION) $(BUILDOPTS) -t $(IMAGENAME):$(TAG) .
	docker images $(IMAGENAME):$(TAG)

up:
	docker-compose up -d

down:
	docker-compose down

clean:
	docker-compose down -v
