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
NAME = matcha-

LIST_CON = frontend backend nginx postgres redis socket

define VALIDATE_ARG
valid=0; \
for s in $(LIST_CON); do \
	if [ "$$s" = "$(ARG)" ]; then \
		valid=1; \
		break; \
	fi; \
done; \
if [ $$valid -eq 0 ]; then \
	echo "$(ERROR) Invalid service: '$(ARG)'. Valid services: $(LIST_CON)$(END)"; \
	exit 1; \
fi
endef

define VALIDATE_SERVICE
valid=0; \
for s in $(LIST_CON); do \
	if [ "$$s" = "$(SERVICE)" ]; then \
		valid=1; \
		break; \
	fi; \
done; \
if [ $$valid -eq 0 ]; then \
	echo "$(ERROR) Invalid service: '$(SERVICE)'. Valid services: $(LIST_CON)$(END)"; \
	exit 1; \
fi
endef

################################################################################
#                                  TARGETS                                     #
################################################################################

all: build up ## Build all images and start services
	@echo "$(SUCCESS) All services are up and running$(END)"

help: ## Show this help
	@echo "$(INFO) Available targets:$(END)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(LIGTH)%-20s$(END) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# ── Global container control ──────────────────────────────────────────────

LIST_CON = frontend backend nginx postgres redis socket

build: ## Build all images (accepts ARG for service)
	@if [ -n "$(ARG)" ]; then \
		$(VALIDATE_ARG); \
		echo "$(INFO) Would run: $(DC) $@ $(ARG)$(END)"; \
		$(DC) $@ --no-cache $(ARG); \
	else \
		echo "$(INFO) Would run: $(DC) build$(END)"; \
		$(DC) $@ --no-cache; \
	fi

up: ## Start all services (detached)
	@if [ -n "$(ARG)" ]; then \
		$(VALIDATE_ARG); \
		echo "$(INFO) Would run: $(DC) $@ $(ARG)$(END)"; \
		$(DC) $@ --detach $(ARG); \
	else \
		echo "$(INFO) Would run: $(DC) build$(END)"; \
		$(DC) $@ --detach; \
	fi

down: ## Stop and remove all services
	@if [ -n "$(ARG)" ]; then \
		$(VALIDATE_ARG); \
		echo "$(INFO) Would run: $(DC) $@ $(ARG)$(END)"; \
		$(DC) $@ $(ARG); \
	else \
		echo "$(INFO) Would run: $(DC) build$(END)"; \
		$(DC) $@; \
	fi

restart: ## Restart all or a specific service (ARG)
	@if [ -n "$(ARG)" ]; then \
		$(VALIDATE_ARG); \
		echo "$(INFO) Would run: $(DC) $@ $(ARG)$(END)"; \
		$(DC) $@ $(ARG); \
	else \
		echo "$(INFO) Would run: $(DC) build$(END)"; \
		$(DC) $@; \
	fi

start: ## Start a specific stopped container (usage: make start ARG=<name>)
	@ARG='$(ARG)'; \
	if [ -z "$$ARG" ]; then \
		echo "$(ERROR) ARG is required. Usage: make start ARG=<container_name>$(END)"; \
		exit 1; \
	fi;
	$(VALIDATE_ARG)
	echo "$(INFO) Would run: $(DC) $@ $$ARG$(END)"
	$(DC) $@ $(ARG)

stop: ## Stop a specific running container (usage: make stop ARG=<name>)
	@ARG='$(ARG)'; \
	if [ -z "$$ARG" ]; then \
		echo "$(ERROR) ARG is required. Usage: make stop ARG=<container_name>$(END)"; \
		exit 1; \
	fi; \
	$(VALIDATE_ARG)
	echo "$(INFO) Would run: $(DC) $@ $$ARG$(END)"
	$(DC) $@ $(ARG)

info: ## Project overview / inspect (ARG=img|ps|logs, optional SERVICE=<name>)
	@case "$(ARG)" in \
		img) \
			if [ -n "$(SERVICE)" ]; then \
				$(VALIDATE_SERVICE); \
				IMG=$$($(DC) images -q $(SERVICE) 2>/dev/null); \
				if [ -n "$$IMG" ]; then \
					echo "$(SUCCESS) Image for $(SERVICE):$(END) $$IMG"; \
					$(DC) images $(SERVICE); \
				else \
					echo "$(ERROR) No image found for service $(SERVICE)$(END)"; \
					exit 1; \
				fi; \
			else \
				echo "$(INFO) Project images:$(END)"; \
				$(DC) images; \
			fi ;; \
		ps) \
			if [ -n "$(SERVICE)" ]; then \
				$(VALIDATE_SERVICE); \
				echo "$(INFO) Status of $(SERVICE):$(END)"; \
				$(DC) ps $(SERVICE); \
			else \
				echo "$(INFO) All containers:$(END)"; \
				$(DC) ps --all --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"; \
			fi ;; \
		logs) \
			if [ -n "$(SERVICE)" ]; then \
				$(VALIDATE_SERVICE); \
				echo "$(INFO) Showing logs for $(SERVICE)...$(END)"; \
				$(DC) logs $(FLAGS) $(SERVICE); \
			else \
				echo "$(INFO) Showing logs for all services...$(END)"; \
				$(DC) logs $(FLAGS); \
			fi ;; \
		"") \
			if [ -n "$(SERVICE)" ]; then \
				$(VALIDATE_SERVICE); \
				echo "$(INFO) Info for service $(SERVICE):$(END)"; \
				echo "Image:"; \
				IMG=$$($(DC) images -q $(NAME)$(SERVICE) 2>/dev/null); \
				if [ -n "$$IMG" ]; then \
					echo "$(SUCCESS) Image for $(SERVICE):$(END)"; \
					docker image ls --filter "reference=$$($(DC) images --format '{{.Repository}}:{{.Tag}}' $(SERVICE) 2>/dev/null)"; \
				else \
					echo "$(ERROR) No image found$(END)"; \
				fi; \
				echo ""; \
				echo "Container status:"; \
				$(DC) ps $(SERVICE) 2>/dev/null || echo "$(ERROR) Container not found$(END)"; \
			else \
				echo "$(INFO) Project overview:$(END)"; \
				echo ""; \
				echo "Images:"; \
				$(DC) images; \
				echo ""; \
				echo "Containers:"; \
				$(DC) ps --all --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"; \
			fi ;; \
		*) \
			echo "$(ERROR) Invalid ARG value: '$(ARG)'. Use 'img', 'ps', 'logs' or leave empty.$(END)"; \
			exit 1;; \
	esac

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

logs-split: ## View frontend and backend logs side by side in tmux
	@if ! command -v tmux >/dev/null 2>&1; then \
		echo "$(ERROR) tmux is not installed. Install it first.$(END)"; \
		exit 1; \
	fi
	@-tmux kill-session -t matcha-logs 2>/dev/null || true
	@tmux new-session -d -s matcha-logs
	@tmux send-keys -t matcha-logs:0.0 '$(DC) logs -f frontend' C-m
	@tmux split-window -h -t matcha-logs:0.0
	@tmux send-keys -t matcha-logs:0.1 '$(DC) logs -f backend' C-m
	@tmux select-layout -t matcha-logs:0 even-horizontal
	@tmux attach -t matcha-logs

# ── Cleanup ───────────────────────────────────────────────────────────────

clean: ## Remove containers and volumes
	@echo "$(INFO) Removing containers and volumes...$(END)"
	@$(DC) down -v

fclean: ## Full clean: remove images, volumes, orphans
	@echo "$(WARNING) Removing everything (images, volumes, orphans)...$(END)"
	@$(DC) down -v --rmi all --remove-orphans
	@docker system prune -f
	@echo "$(SUCCESS) Full clean done$(END)"

# ── Shell access shortcuts (now accept ARG to override service) ─────────

fe: ## Open shell in frontend container (ARG overrides service)
	@echo "$(INFO) Would run: $(DC) exec frontend sh$(END)"
	$(DC) exec frontend sh

be: ## Open shell in backend container (ARG overrides service)
	echo "$(INFO) Would run: $(DC) exec backend sh$(END)"
	$(DC) exec backend sh

socket: ## Open shell in socket container (ARG overrides service)
	echo "$(INFO) Would run: $(DC) exec socket sh$(END)"
	$(DC) exec socket sh

nginx: ## Open shell in nginx container (ARG overrides service)
	echo "$(INFO) Would run: $(DC) exec nginx sh$(END)"
	$(DC) exec nginx sh

postgres: ## Open psql in postgres container (ARG overrides service)
	echo "$(INFO) Would run: $(DC) exec postgres psql -U postgres$(END)"; \
	$(DC) exec postgres psql -U postgres;

redis: ## Open redis-cli in redis container (ARG overrides service)
	echo "$(INFO) Would run: $(DC) exec redis redis-cli$(END)"
	$(DC) exec redis redis-cli

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

.PHONY: all help build up down restart start stop logs ps logs-split clean fclean \
		fe be socket nginx postgres redis lint format typecheck test
.SILENT: