SHELL = /bin/sh

# This GNUmakefile searches the `sources/` directory for files with an extension of `.xml` and applies `transform.xslt` to them, outputting the result in one of two locations :—
#
# • For files with a location of `sources/index.xml` or `sources/index-*.xml`, the transformed file will be written to `public/%.html` (where `%` is the filename).
#
# • For all other files with a location of `sources/*.xml` or `sources/*/*.xml`, the transformed file will be written to `public/%/index.html` (where `%` is the filename and subdirectory if applicable).
# Other files in the corresponding directory (i·e without the `.xml`) are copied over verbatim.
# Only one level of subdirectory is supported.
#
# By default, running `make` will do this for all applicable source files.
#
# ___
#
# © 2022 Margaret KIBI
#
# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

XSLT = xsltproc
XSLTOPTS =

headers := $(wildcard *-header.xml)
footers := $(wildcard *-footer.xml)
override prerequisites := transform.xslt $(headers) $(footers)

override indexsources := $(wildcard sources/index.xml sources/index-*.xml)
override indices := $(patsubst sources/%.xml,public/%.html,$(indexsources))

override pagesources := $(filter-out $(indexsources),$(wildcard sources/*.xml sources/*/*.xml))
override pages := $(patsubst sources/%.xml,public/%/index.html,$(pagesources))

override resourcesources := $(wildcard $(addsuffix /*,$(basename $(pagesources))))
override resources := $(patsubst sources/%,public/%,$(resourcesources))

override content := $(indices) $(pages)

override makexslt = $(XSLT) --nonet --novalid $(XSLTOPTS) -o $(2) transform.xslt $(1)

all: $(content) $(resources);

$(indices): public/%.html: sources/%.xml $(prerequisites)
	@echo "Generating $@…"
	@$(call makexslt,$<,$@)

$(pages): public/%/index.html: sources/%.xml $(prerequisites)
	@echo "Generating $@…"
	@$(call makexslt,$<,$@)

$(resources): public/%: sources/%
	@echo "Copying over $@…"
	@mkdir -p $(dir $<)
	@cp $< $@

.PHONY: all ;
