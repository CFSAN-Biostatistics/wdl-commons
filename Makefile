.PHONY: help


help: ## Show this help.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

new: ## Create a new WDL library with a simple template.
	@echo "Creating a new WDL library..."
	@echo "Enter the name of the library:"
	@read name; \
	
	

test: ## Test WDL library tasks using Pytest and MiniWDL.
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