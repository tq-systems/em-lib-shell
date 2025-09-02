install:
	./scripts/install.sh

tests:
	./test/copy.sh
	./test/device.sh
	./test/version.sh

docs:
	./scripts/docs.sh

.PHONY: tests docs
