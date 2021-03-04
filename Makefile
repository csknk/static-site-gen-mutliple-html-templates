ASSETS_SOURCE_DIR := assets
IMAGES_SOURCE_DIR := images
CONFIG := data/config.yaml
NAV := data/nav.yaml

# Directories built by make
SITE := site
ASSETS := $(SITE)/$(ASSETS_SOURCE_DIR)
IMAGES := $(SITE)/$(IMAGES_SOURCE_DIR)
PARTIALS := partials
PARTIALS_CONTENT := $(PARTIALS)/content

# Convert all markdown files in src to HTML partials in partials/content
CONTENT_MD_FILES := $(notdir $(wildcard src/*.md))
CONTENT_PARTIALS := $(CONTENT_MD_FILES:%.md=partials/content/%.html)
SIDEBAR := partials/sidebar.html
SIDEBAR_CONTENT := src/fixed-elements/sidebar.md
PAGES := $(CONTENT_MD_FILES:%.md=$(SITE)/%/index.html)

SRC_ASSET_FILES := $(notdir $(wildcard $(ASSETS_SOURCE_DIR)/*))
ASSET_FILES := $(SRC_ASSET_FILES:%=$(ASSETS)/%)

# Directories to be built
BUILD_DIRS := $(SITE) $(ASSETS) $(IMAGES) $(PARTIALS) $(PARTIALS_CONTENT)

# The hash is needed in a Make variable to build the link to the file created in the $(ASSETS) recipe.
CSS_HASH := $(shell sha256sum $(ASSETS_SOURCE_DIR)/styles.css | head -c 10)
CSS_FILENAME := ../assets/styles-$(CSS_HASH).css
JS_HASH := $(shell sha256sum $(ASSETS_SOURCE_DIR)/index.js | head -c 10)
JS_FILENAME := ../assets/index-$(JS_HASH).js
CONFIG := data/config.yml
BASE_HTML := templates/base.html
PRE_BASE_HTML := templates/pre-base.html

$(info $(CSS_FILENAME))

.PHONY: clean

all: $(PAGES) $(ASSET_FILES) $(SIDEBAR) $(BASE_HTML)

$(BUILD_DIRS):; @ mkdir -p $@

$(CONTENT_PARTIALS): partials/content/%.html: src/%.md | $(BUILD_DIRS)
	@echo "Building template $@..."
	@pandoc -s --metadata-file $(CONFIG) -o $@ $<

$(BASE_HTML): templates/empty.md $(CONFIG)
	@ echo "building base.html template"
	@pandoc --metadata-file $(CONFIG) --template $(PRE_BASE_HTML) -o $@ $<

$(SIDEBAR): $(SIDEBAR_CONTENT)
	@echo "Building $@..."
	@pandoc -s --metadata-file $(CONFIG) -o $@ $<

# Build all pages
$(PAGES): $(SITE)/%/index.html: $(PARTIALS_CONTENT)/%.html | $(SIDEBAR) $(BASE_HTML)
	@ echo "making $@ from $< and $(SIDEBAR)..."
	@# If the source file has no date set, set it
#	@scripts/set_date.py $<
#	@echo $(basename $<)
#	scripts/build.py templates/base.html $@ $< $(SIDEBAR) $(CSS_FILENAME)
	@if [ $(basename $<) = partials/content/README ]; then \
		scripts/build.py $(BASE_HTML) $(SITE)/index.html $< $(SIDEBAR) $(CSS_FILENAME) ; \
		else mkdir -p $(dir $@); scripts/build.py $(BASE_HTML) $@ $< $(SIDEBAR) $(CSS_FILENAME) ; fi

# Make sidebar an additional prerquisite for all pages - if the sidebar changes,
# a rebuild of $(PAGES) will be triggered.
$(PAGES): $(SIDEBAR)
$(PAGES): $(ASSET_FILES)

$(PAGES): templates/base.html

$(ASSET_FILES): $(ASSETS)/%: $(ASSETS_SOURCE_DIR)/% | $(BUILD_DIRS)
	$(eval FILE_HASH := $(shell sha256sum $^ | head -c 10))
	$(eval FILE_NAME := $(basename $@)-$(FILE_HASH)$(suffix $@))
	@echo "Copying $^ to $(FILE_NAME)"
	@cp $^ $(FILE_NAME)

clean:
	@- rm -rf partials
	@- rm -rf site
