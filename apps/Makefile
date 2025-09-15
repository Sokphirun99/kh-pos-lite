SHELL := /bin/bash

.PHONY: gen watch l10n repair

gen:
	sh tools/codegen.sh

watch:
	sh tools/codegen.sh --watch

l10n:
	flutter gen-l10n

repair:
	sh tools/codegen.sh --repair

