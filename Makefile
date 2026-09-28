# Casper developer shortcuts. Run `make help` to list targets.
# Every target is a thin wrapper, so you can always run the underlying command yourself.

.DEFAULT_GOAL := help
.PHONY: help setup lint format test up down logs psql check-env eval

# Load .env (if present) so targets like `psql` can use POSTGRES_USER / POSTGRES_DB.
ifneq (,$(wildcard .env))
include .env
export
endif

help: ## List available targets
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

setup: ## Install dependencies, create .env from the example, install git hooks
	uv sync
	@test -f .env || (cp .env.example .env && echo "Created .env from .env.example; edit it before running 'make up'.")
	uv run pre-commit install

lint: ## Check lint and formatting (same as CI)
	uv run ruff check .
	uv run ruff format --check .

format: ## Auto-fix lint issues and format code
	uv run ruff check --fix .
	uv run ruff format .

test: ## Run the test suite
	uv run pytest

up: ## Start the Docker Compose services in the background
	docker compose up -d

down: ## Stop the Docker Compose services (data volumes are kept)
	docker compose down

logs: ## Follow logs from the Docker Compose services
	docker compose logs -f

psql: ## Open a psql shell inside the database container
	docker compose exec db psql -U $(POSTGRES_USER) -d $(POSTGRES_DB)

check-env: ## Print versions of the tools this project needs (no side effects)
	@bash scripts/check_env.sh

eval: ## Run the evaluation suite
	@echo "not implemented yet: week 4"
