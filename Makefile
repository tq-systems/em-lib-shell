TQEM_PROJECT_ROOT := $(shell pwd)
export TQEM_SHELL_BIN_DIR := $(TQEM_PROJECT_ROOT)/bin
export TQEM_SHELL_LIB_DIR := $(TQEM_PROJECT_ROOT)/lib

install:
	./scripts/install.sh

tests:
	./test/copy.sh
	./test/device.sh
	./test/version.sh

docs:
	./scripts/docs.sh

.PHONY: tests docs
