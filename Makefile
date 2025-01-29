.PHONY: up down clean clean-volumes clean-all help

# Colors for terminal output
GREEN := \033[0;32m
NC := \033[0m # No Color
YELLOW := \033[0;33m

help: ## Show this help message
	@echo 'Usage:'
	@echo '  ${YELLOW}make${NC} ${GREEN}<target>${NC}'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  ${YELLOW}%-15s${NC} %s\n", $$1, $$2}' $(MAKEFILE_LIST)

up: ## Start all services
	@echo "Starting services..."
	docker compose up -d
	@echo "Services are up!"

down: ## Stop all services
	@echo "Stopping services..."
	docker compose down
	@echo "Services are down!"

clean-volumes: ## Remove all data volumes (PostgreSQL, Redis, RabbitMQ, Evolution API)
	@echo "Cleaning data volumes..."
	rm -rf evolution/instances evolution/store
	rm -rf postgres/data
	rm -rf rabbitmq/data
	@echo "Data volumes cleaned!"

clean: down clean-volumes ## Stop services and clean volumes

clean-all: clean ## Stop services, clean volumes, and remove all docker resources
	@echo "Removing all docker resources..."
	docker system prune -af --volumes
	@echo "All docker resources removed!"

logs: ## View logs from all services
	docker compose logs -f

ps: ## List running services
	docker compose ps
