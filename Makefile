################################################################################
#                               COLOR DEFINITIONS                              #
################################################################################
END = \033[m
RED = \033[31m
GREEN = \033[32m
YELLOW = \033[33m
BLUE = \033[34m
LIGTH = \033[1m
DARK = \033[2m
ITALIC = \033[3m

SUCCESS = $(LIGTH)$(GREEN)[SUCCESS]$(END)
WARNING = $(LIGTH)$(YELLOW)[WARNING]$(END)
INFO = $(LIGTH)$(BLUE)[INFO]$(END)
ERROR = $(LIGTH)$(RED)[ERROR]$(END)

################################################################################
#                               BUILD VARIABLES                                #
################################################################################
RMV = rm -rf
DC = docker compose

################################################################################
#                                  TARGETS                                     #
################################################################################

help: ## Show this help
	@echo "$(INFO) Available targets:$(END)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(LIGTH)%-20s$(END) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# ── Global container control ──────────────────────────────────────────────

build: ## Build all images (accepts ARG for service)
	@if [ -n "$(ARG)" ]; then \
		echo "$(INFO) Would run: $(DC) build $(ARG)$(END)"; \
	else \
		echo "$(INFO) Would run: $(DC) build$(END)"; \
	fi

up: ## Start all services (detached)
	@echo "$(INFO) Would run: $(DC) up -d$(END)"

down: ## Stop and remove all services
	@echo "$(INFO) Would run: $(DC) down$(END)"

restart: ## Restart all or a specific service (ARG)
	@if [ -n "$(ARG)" ]; then \
		echo "$(INFO) Would run: $(DC) restart $(ARG)$(END)"; \
	else \
		echo "$(INFO) Would run: $(DC) restart$(END)"; \
	fi

start: ## Start a specific stopped container (usage: make start ARG=<name>)
	@ARG='$(ARG)'; \
	if [ -z "$$ARG" ]; then \
		echo "$(ERROR) ARG is required. Usage: make start ARG=<container_name>$(END)"; \
		exit 1; \
	fi; \
	echo "$(INFO) Would run: $(DC) start $$ARG$(END)"

stop: ## Stop a specific running container (usage: make stop ARG=<name>)
	@ARG='$(ARG)'; \
	if [ -z "$$ARG" ]; then \
		echo "$(ERROR) ARG is required. Usage: make stop ARG=<container_name>$(END)"; \
		exit 1; \
	fi; \
	echo "$(INFO) Would run: $(DC) stop $$ARG$(END)"

logs: ## View logs. Usage: make logs ARG=<name> [FLAGS="-f"]
	@ARG='$(ARG)'; \
	if [ -z "$$ARG" ]; then \
		echo "$(ERROR) ARG is required. Usage: make logs ARG=<container_name>$(END)"; \
		exit 1; \
	fi; \
	NAMES=$$(docker ps -a --filter "name=$$ARG" --format '{{.Names}}' 2>/dev/null); \
	if [ -z "$$NAMES" ]; then \
		echo "$(ERROR) No container found matching '$$ARG'$(END)"; \
		exit 1; \
	fi; \
	COUNT=$$(echo "$$NAMES" | wc -l); \
	if [ $$COUNT -gt 1 ]; then \
		echo "$(ERROR) Multiple containers found:$(END)"; \
		echo "$$NAMES"; \
		echo "$(WARNING) Please specify a more precise name.$(END)"; \
		exit 1; \
	fi; \
	echo "$(INFO) Showing logs for container: $$NAMES$(END)"; \
	docker logs $$NAMES $(FLAGS)

ps: ## List containers. Usage: make ps [ARG=<name>]
	@ARG='$(ARG)'; \
	if [ -n "$$ARG" ]; then \
		OUTPUT=$$(docker ps -a --filter "name=$$ARG" 2>&1); \
		EXIT_CODE=$$?; \
		if [ $$EXIT_CODE -ne 0 ]; then \
			echo "$(ERROR) Docker command failed: $$OUTPUT $(END)"; \
			exit $$EXIT_CODE; \
		fi; \
		CONTAINER_COUNT=$$(echo "$$OUTPUT" | sed 1d | wc -l); \
		if [ $$CONTAINER_COUNT -eq 0 ]; then \
			echo "$(ERROR) No container found with name matching '$$ARG' $(END)"; \
			exit 1; \
		else \
			echo "$$OUTPUT"; \
		fi; \
	else \
		docker ps -a; \
	fi

# ── Cleanup ───────────────────────────────────────────────────────────────

clean: ## Remove containers and volumes (simulation)
	@echo "$(INFO) Would run: $(DC) down -v$(END)"

fclean: ## Full clean: remove images, volumes, orphans (simulation)
	@echo "$(WARNING) Would run: $(DC) down -v --rmi all --remove-orphans && docker system prune -f$(END)"

# ── Shell access shortcuts (now accept ARG to override service) ─────────

fe: ## Open shell in frontend container (ARG overrides service)
	@if [ -n "$(ARG)" ]; then \
		echo "$(INFO) Would run: $(DC) exec $(ARG) sh$(END)"; \
	else \
		echo "$(INFO) Would run: $(DC) exec frontend sh$(END)"; \
	fi

be: ## Open shell in backend container (ARG overrides service)
	@if [ -n "$(ARG)" ]; then \
		echo "$(INFO) Would run: $(DC) exec $(ARG) sh$(END)"; \
	else \
		echo "$(INFO) Would run: $(DC) exec backend sh$(END)"; \
	fi

socket: ## Open shell in socket container (ARG overrides service)
	@if [ -n "$(ARG)" ]; then \
		echo "$(INFO) Would run: $(DC) exec $(ARG) sh$(END)"; \
	else \
		echo "$(INFO) Would run: $(DC) exec socket sh$(END)"; \
	fi

nginx: ## Open shell in nginx container (ARG overrides service)
	@if [ -n "$(ARG)" ]; then \
		echo "$(INFO) Would run: $(DC) exec $(ARG) sh$(END)"; \
	else \
		echo "$(INFO) Would run: $(DC) exec nginx sh$(END)"; \
	fi

postgres: ## Open psql in postgres container (ARG overrides service)
	@if [ -n "$(ARG)" ]; then \
		echo "$(INFO) Would run: $(DC) exec $(ARG) psql -U postgres$(END)"; \
	else \
		echo "$(INFO) Would run: $(DC) exec postgres psql -U postgres$(END)"; \
	fi

redis: ## Open redis-cli in redis container (ARG overrides service)
	@if [ -n "$(ARG)" ]; then \
		echo "$(INFO) Would run: $(DC) exec $(ARG) redis-cli$(END)"; \
	else \
		echo "$(INFO) Would run: $(DC) exec redis redis-cli$(END)"; \
	fi

# ── Code quality & tests (ARG selects service) ──────────────────────────

lint: ## Run linter (ARG overrides service, otherwise both)
	@if [ -n "$(ARG)" ]; then \
		echo "$(INFO) Would run: $(DC) exec $(ARG) npm run lint$(END)"; \
	else \
		echo "$(INFO) Would run: $(DC) exec frontend npm run lint$(END)"; \
		echo "$(INFO) Would run: $(DC) exec backend npm run lint$(END)"; \
	fi

format: ## Run formatter (ARG overrides service, otherwise both)
	@if [ -n "$(ARG)" ]; then \
		echo "$(INFO) Would run: $(DC) exec $(ARG) npm run format$(END)"; \
	else \
		echo "$(INFO) Would run: $(DC) exec frontend npm run format$(END)"; \
		echo "$(INFO) Would run: $(DC) exec backend npm run format$(END)"; \
	fi

typecheck: ## Run type check (ARG overrides service, otherwise both)
	@if [ -n "$(ARG)" ]; then \
		echo "$(INFO) Would run: $(DC) exec $(ARG) npm run typecheck$(END)"; \
	else \
		echo "$(INFO) Would run: $(DC) exec frontend npm run typecheck$(END)"; \
		echo "$(INFO) Would run: $(DC) exec backend npm run typecheck$(END)"; \
	fi

test: ## Run tests (ARG overrides service, otherwise both)
	@if [ -n "$(ARG)" ]; then \
		echo "$(INFO) Would run: $(DC) exec $(ARG) npm test$(END)"; \
	else \
		echo "$(INFO) Would run: $(DC) exec backend npm test$(END)"; \
		echo "$(INFO) Would run: $(DC) exec frontend npm test -- --watchAll=false$(END)"; \
	fi

.PHONY: help build up down restart start stop logs ps clean fclean \
		fe be socket nginx postgres redis lint format typecheck test
.SILENT: