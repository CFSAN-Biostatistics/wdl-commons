.PHONY: help

clean:
	@rm -rf .pytest_cache
	@rm -rf tests/__pycache__
	@rm -rf tests/.cache

help: ## Show this help.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

new: ## Create a new WDL library with a simple template.
	@echo "Creating a new WDL library..."
	@echo "Enter the name of the library:"
	@read name; \
	echo "Your full name"; \
	read author; \
	echo "Your email address"; \
	read email; \
	echo "Creating new library $$name..."; \
	jinja2 templates/wdl.jinja -D author="$$author" -D name="$$name" -D email="$$email" > $$name.wdl; \
	jinja2 templates/python.jinja -D name=$$name > tests/test_$$name.py

test: clean ## Test WDL library tasks using Pytest and MiniWDL.
	@echo "Running tests..."
	@python3 -m pytest

coverage: ## Scan the tasks in each library and determine if a test exists.
	@echo "Scanning for test coverage..."
	@for file in *.wdl; do \
		task=$$(basename $$file .wdl); \
		if [ ! -f test_$$task.py ]; then \
			echo "No test found for $$task"; \
		fi; \
	done

check: ## Alias for 'miniwdl check *.wdl'.
	@echo "Checking WDL files..."
	for file in *.wdl; do \
		miniwdl check $$file; \
	done