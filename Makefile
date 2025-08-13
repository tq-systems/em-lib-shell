tests:
	./test/copy.sh
	./test/version.sh

docs:
	./scripts/docs.sh

.PHONY: tests docs
