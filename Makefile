ACCESSIBILITY_UTILS = ./lib/accessibility-developer-tools/src
AUDIT_RULES = $(shell find $(ACCESSIBILITY_UTILS)/audits -name "*.js" | sed -e "s/^/--js /g")
NUM_AUDIT_RULES = $(shell echo `find ./lib/accessibility-developer-tools/src/audits -name "*.js" | wc -l`)
NUM_AUDIT_RULE_SOURCES = `expr $(NUM_AUDIT_RULES) + 4`
EXTERNS = ./src/js/externs.js
LIB_EXTERNS = $(ACCESSIBILITY_UTILS)/js/externs/externs.js

GENERATED_JS_FILES_DIR = ./extension/generated
TEMPLATES_LIB_FILE = ./extension/Handlebar.js
TEST_DIR = ./test
TEST_DEPENDENCIES_FILE = generated_dependencies.js
TEST_DEPENDENCIES_REL_DIR = generated

CLOSURE_JAR = ~/src/closure/compiler.jar
EXTENSION_CLOSURE_COMMAND = java -jar $(CLOSURE_JAR) \
--formatting PRETTY_PRINT --summary_detail_level 3 --compilation_level SIMPLE_OPTIMIZATIONS \
--warning_level VERBOSE --externs $(EXTERNS) --externs $(LIB_EXTERNS) \
--module axs:2 \
  --js ./lib/accessibility-developer-tools/lib/closure-library/closure/goog/base.js \
  --js $(ACCESSIBILITY_UTILS)/js/axs.js \
--module constants:1:axs \
  --js $(ACCESSIBILITY_UTILS)/js/Constants.js \
--module utils:2:constants \
  --js $(ACCESSIBILITY_UTILS)/js/AccessibilityUtils.js \
  --js $(ACCESSIBILITY_UTILS)/js/BrowserUtils.js \
--module properties:1:utils,constants \
  --js $(ACCESSIBILITY_UTILS)/js/Properties.js \
--module audits:$(NUM_AUDIT_RULE_SOURCES):constants,utils \
  --js $(ACCESSIBILITY_UTILS)/js/AuditResults.js \
  --js $(ACCESSIBILITY_UTILS)/js/Audit.js \
  --js $(ACCESSIBILITY_UTILS)/js/AuditRule.js \
  --js $(ACCESSIBILITY_UTILS)/js/AuditRules.js \
  $(AUDIT_RULES) \
--module extension_properties:2:properties \
  --js ./src/extension/ContentScriptFramework.js \
  --js ./src/extension/ExtensionProperties.js \
--module extension_audits:2:audits,extension_properties \
  --js ./src/extension/ExtensionAuditRule.js \
  --js ./src/extension/ExtensionAuditRules.js

MODULES = axs closure constants utils content properties audits

.PHONY: clean js

js: clean
	@echo "\nStand back! I'm rebuilding!\n---------------------------"
	@/bin/echo -n "* Rebuilding generated JS modules: "
	@/bin/echo -n "$(EXTENSION_CLOSURE_COMMAND) --module_output_path_prefix $(GENERATED_JS_FILES_DIR)/"
	@/bin/echo
	@$(EXTENSION_CLOSURE_COMMAND) --module_output_path_prefix $(GENERATED_JS_FILES_DIR)/ && \
    echo "SUCCESS"
	@/bin/echo -n "* Copying Handlebar.js to $(TEMPLATES_LIB_FILE): "
	@/bin/cp ./lib/templates/js/HandlebarBrowser.js $(TEMPLATES_LIB_FILE) && \
    echo "SUCCESS"

clean:
	@rm -rf $(GENERATED_JS_FILES_DIR) $(TEMPLATES_LIB_FILE) $(TEST_DIR)/$(TEST_DEPENDENCIES_REL_DIR)
