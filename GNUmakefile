SHELL = /bin/sh

# This GNUmakefile searches the `sources/` directory for files with an extension of `.atom` or `.xml` and applies `transform.xslt` to them, outputting the result in one of the following locations :—
#
# • For files with a location of `sources/index.xml` or `sources/index-*.xml`, the transformed file will be written to `public/%.html` (where `%` is the filename).
#
# • For all other files with a location of `sources/*.xml` or `sources/*/*.xml`, the transformed file will be written to `public/%/index.html` (where `%` is the filename and subdirectory if applicable).
# Any files in a corresponding sibling directory (i·e without the `.xml`) are copied over verbatim.
# Only one level of subdirectory is supported.
#
# • For files with a location of `sources/*.atom` or `sources/*/*.atom`, the transformed file will be written to `public/%.atom` (where `%` is the filename and subdirectory if applicable).
#
# By default, running `make` will do this for all applicable source files.
#
# ___
#
# © 2022 Margaret KIBI
#
# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

BASEIRI = http://example.com
DATETIME = $(shell date -Iseconds)
TRANSFORM = transform.xslt
XSLT = xsltproc
XSLTOPTS =

headers := $(wildcard *-header.xml)
footers := $(wildcard *-footer.xml)
override prerequisites := $(TRANSFORM) $(headers) $(footers)

override indexsources := $(wildcard sources/index.xml sources/index-*.xml)
override indices := $(patsubst sources/%.xml,public/%.html,$(indexsources))

override pagesources := $(filter-out $(indexsources),$(wildcard sources/*.xml sources/*/*.xml))
override pages := $(patsubst sources/%.xml,public/%/index.html,$(pagesources))

override resourcesources := $(wildcard $(addsuffix /*,$(basename $(pagesources))))
override resources := $(patsubst sources/%,public/%,$(resourcesources))

override feedsources := $(filter-out $(resourcesources),$(wildcard sources/*.atom sources/*/*.atom))
override feeds := $(patsubst sources/%.atom,public/%.atom,$(feedsources))

override content := $(indices) $(pages)

# This function does the following :—
#
# • Calls `transform.xslt` with the `$(1)`, providing `$(BASEIRI)` and `$(DATETIME) as params and providing `$(2)` (minus the initial `public/`) as the param `OUTPUTPATH`.
#
# • Removes any `xmlns` prefix declarations from output to `.html` files (with `sed`).
#
# • Removes any doctype for root elements other than `html` (with `grep -v`).
#
# • Saves the output to `$(2)`.
override makexslt = $(XSLT) --nonet --novalid $(XSLTOPTS) --stringparam BASEIRI "$(BASEIRI)" --stringparam DATETIME "$(DATETIME)" --stringparam OUTPUTPATH "$(patsubst public/%,/%,$(2))" transform.xslt $(1)\
	$(if $(filter %.html,$(2)),| sed 's/ xmlns:[0-9A-Za-z_-]*="[^"]*"//g',)\
	| grep -v '^<!DOCTYPE \([^h]\|.[^t]\|..[^m]\|...[^l]\|....[^ >]\)'\
	> $(2)

all: $(content) $(resources) $(feeds);

$(indices): public/%.html: sources/%.xml $(prerequisites)
	@echo "Generating $@…"
	@mkdir -p $(dir $@)
	@$(call makexslt,$<,$@)

$(pages): public/%/index.html: sources/%.xml $(prerequisites)
	@echo "Generating $@…"
	@mkdir -p $(dir $@)
	@$(call makexslt,$<,$@)

$(resources): public/%: sources/%
	@echo "Copying over $@…"
	@mkdir -p $(dir $@)
	@cp $< $@

$(feeds): public/%.atom: sources/%.atom $(TRANSFORM)
	@echo "Generating $@…"
	@mkdir -p $(dir $@)
	@$(call makexslt,$<,$@)

.PHONY: all ;
