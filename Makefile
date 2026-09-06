# VendorHub monorepo task runner
.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'

.PHONY: setup
setup: ## Install backend deps + copy env
	cd backend && cp -n .env.example .env || true
	cd backend && composer install

.PHONY: migrate
migrate: ## Run backend migrations + seeders
	cd backend && php artisan migrate --seed

.PHONY: serve
serve: ## Serve backend API
	cd backend && php artisan serve

.PHONY: queue
queue: ## Run queue worker
	cd backend && php artisan queue:work

.PHONY: test
test: ## Run backend tests
	cd backend && php artisan test

.PHONY: cs
cs: ## Run Laravel Pint
	cd backend && ./vendor/bin/pint

.cs-format:
	cd backend && ./vendor/bin/pint --test
