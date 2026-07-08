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
DC = docker
NAME = backend
MODE = $(or $(ARG),dev)
IMAGE_DEV = img_$(NAME)_dev
IMAGE_PROD = img_$(NAME)_prod
IMAGE = $(if $(filter dev,$(MODE)),$(IMAGE_DEV),$(IMAGE_PROD))
CONTAINER = $(NAME)


################################################################################
#                                  TARGETS                                     #
################################################################################

all: build up

help: ## Show this help
	@echo "$(INFO) Available targets:$(END)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(LIGTH)%-20s$(END) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build image (default: dev, use ARG=prod for production)
	$(DC) build --no-cache --target $(MODE) -t $(IMAGE) .
	@echo "$(SUCCESS) Image $(IMAGE) built ($(MODE) stage)$(END)"

# ── Container lifecycle ────────────────────────────────────────────────────

up: ## Run container in background (default: dev, use ARG=prod for production)
	@if [ -n "$$($(DC) ps -a --filter name=^/$(CONTAINER)$$ --format '{{.ID}}')" ]; then \
		echo "$(WARNING) Container $(CONTAINER) already exists. Use 'make start' or 'make down' first.$(END)"; \
		exit 1; \
	fi
	$(DC) run -d --name $(CONTAINER) -p 5000:5000 -v "$$(pwd):/app" --env-file .env $(IMAGE)
	@echo "$(SUCCESS) Container $(CONTAINER) started with $(IMAGE)$(END)"

down: ## Stop and remove container
	@if $(DC) ps -a --filter "name=^/$(CONTAINER)$$" --format '{{.ID}}' | grep -q .; then \
		$(DC) stop $(CONTAINER) >/dev/null; \
		$(DC) rm $(CONTAINER) >/dev/null; \
		echo "$(SUCCESS) Container $(CONTAINER) removed$(END)"; \
	else \
		echo "$(WARNING) Container $(CONTAINER) does not exist$(END)"; \
	fi

start: ## Start existing stopped container
	@if $(DC) ps -a --filter "name=^/$(CONTAINER)$$" --format '{{.ID}}' | grep -q .; then \
		$(DC) start $(CONTAINER) >/dev/null; \
		echo "$(SUCCESS) Container $(CONTAINER) started$(END)"; \
	else \
		echo "$(ERROR) Container $(CONTAINER) not found. Run 'make up' first.$(END)"; \
		exit 1; \
	fi

stop: ## Stop running container
	@if $(DC) ps --filter "name=^/$(CONTAINER)$$" --format '{{.ID}}' | grep -q .; then \
		$(DC) stop $(CONTAINER) >/dev/null; \
		echo "$(SUCCESS) Container $(CONTAINER) stopped$(END)"; \
	else \
		echo "$(WARNING) Container $(CONTAINER) is not running$(END)"; \
	fi

restart: ## Restart container
	@if $(DC) ps -a --filter "name=^/$(CONTAINER)$$" --format '{{.ID}}' | grep -q .; then \
		$(DC) restart $(CONTAINER) >/dev/null; \
		echo "$(SUCCESS) Container $(CONTAINER) restarted$(END)"; \
	else \
		echo "$(ERROR) Container $(CONTAINER) not found. Run 'make up' first.$(END)"; \
		exit 1; \
	fi


# ── Inspection ──────────────────────────────────────────────────────────────

info: ## Show project info. Usage: make info [ARG=img|ps|logs]
	@case "$(ARG)" in \
		img) \
			if docker image inspect $(IMAGE) >/dev/null 2>&1; then \
				echo "$(SUCCESS) Image $(IMAGE) exists$(END)"; \
				docker image ls --filter "reference=$(IMAGE)" \
					--format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"; \
			else \
				echo "$(ERROR) Image $(IMAGE) not found$(END)"; \
				exit 1; \
			fi ;; \
		ps) \
			CID=$$(docker ps -a --filter "name=^/$(CONTAINER)$$" --format '{{.ID}}' 2>/dev/null); \
			if [ -z "$$CID" ]; then \
				echo "$(ERROR) Container $(CONTAINER) not found$(END)"; \
				exit 1; \
			fi; \
			STATE=$$(docker inspect -f '{{.State.Status}}' $$CID); \
			case "$$STATE" in \
				running) COLOR="$(GREEN)";; \
				exited)  COLOR="$(YELLOW)";; \
				*)       COLOR="$(RED)";; \
			esac; \
			echo "$(INFO) Container $(CONTAINER) status: $${COLOR}$$STATE$(END)"; \
			docker ps -a --filter "id=$$CID" \
				--format "table {{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.Image}}";; \
		logs) \
			CID=$$(docker ps -a --filter "name=^/$(CONTAINER)$$" --format '{{.ID}}' 2>/dev/null); \
			if [ -z "$$CID" ]; then \
				echo "$(ERROR) Container $(CONTAINER) not found$(END)"; \
				exit 1; \
			fi; \
			echo "$(INFO) Showing logs for $(CONTAINER) (ID: $$CID)$(END)"; \
			docker logs $$CID $(FLAGS) ;; \
		"") \
			echo "$(INFO) Project overview:$(END)"; \
			echo ""; \
			echo "Image:"; \
			if docker image inspect $(IMAGE) >/dev/null 2>&1; then \
				echo "$(SUCCESS) Exists$(END)"; \
				docker image ls --filter "reference=$(IMAGE)" \
					--format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"; \
			else \
				echo "$(ERROR) Not found$(END)"; \
			fi; \
			echo ""; \
			echo "Container:"; \
			CID=$$(docker ps -a --filter "name=^/$(CONTAINER)$$" --format '{{.ID}}' 2>/dev/null); \
			if [ -z "$$CID" ]; then \
				echo "$(ERROR) No container named $(CONTAINER)$(END)"; \
			else \
				STATE=$$(docker inspect -f '{{.State.Status}}' $$CID); \
				case "$$STATE" in \
					running) COLOR="$(GREEN)";; \
					exited)  COLOR="$(YELLOW)";; \
					*)       COLOR="$(RED)";; \
				esac; \
				echo "Status: $${COLOR}$$STATE$(END)"; \
				docker ps -a --filter "id=$$CID" \
					--format "table {{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.Image}}"; \
			fi ;; \
		*) \
			echo "$(ERROR) Invalid ARG value: '$(ARG)'. Use 'img', 'ps', 'logs' or leave empty.$(END)"; \
			exit 1;; \
	esac

shell: ## Open a shell inside the container (ARG overrides default)
	@TARGET=$${ARG:-$(CONTAINER)}; \
	if $(DC) ps --filter "name=^/$$TARGET$$" --format '{{.ID}}' | grep -q .; then \
		$(DC) exec -it $$TARGET sh; \
	else \
		echo "$(ERROR) Container $$TARGET is not running$(END)"; \
		exit 1; \
	fi

lint: ## Lint code (via check)
	@$(MAKE) check ARG=lint FLAGS="$(ARGS)"

format: ## Check code formatting (via check)
	@$(MAKE) check ARG=format FLAGS="$(ARGS)"

typecheck: ## Static type checking (via check)
	@$(MAKE) check ARG=typecheck FLAGS="$(ARGS)"

security: ## Security analysis (via check)
	@$(MAKE) check ARG=security FLAGS="$(ARGS)"

audit: ## Audit dependencies for vulnerabilities (via check)
	@$(MAKE) check ARG=audit FLAGS="$(ARGS)"

test: ## Run tests (via check)
	@$(MAKE) check ARG=test FLAGS="$(ARGS)"

test-cov: ## Run tests with coverage (via check)
	@$(MAKE) check ARG=test-cov FLAGS="$(ARGS)"

check: ## Run quality checks (ARG: lint, format, typecheck, security, audit, test, test-cov)
	@if ! $(DC) ps --filter "name=^/$(CONTAINER)$$" --format '{{.ID}}' | grep -q .; then \
		echo "$(ERROR) Container $(CONTAINER) is not running. Start it with 'make up'.$(END)"; \
		exit 1; \
	fi
	@case "$(ARG)" in \
		lint) \
			echo "$(INFO) Running linter (ruff)...$(END)"; \
			$(DC) exec -e PYTHONPATH=/app $(CONTAINER) ruff check . ;; \
		format) \
			echo "$(INFO) Checking formatting (ruff format --check)...$(END)"; \
			$(DC) exec -e PYTHONPATH=/app $(CONTAINER) ruff format --check . ;; \
		typecheck) \
			echo "$(INFO) Running type checker (mypy)...$(END)"; \
			$(DC) exec -e PYTHONPATH=/app $(CONTAINER) mypy app/ tests/ ;; \
		security) \
			echo "$(INFO) Running security analysis (bandit)...$(END)"; \
			$(DC) exec -e PYTHONPATH=/app $(CONTAINER) bandit -r app/ ;; \
		audit) \
			echo "$(INFO) Auditing dependencies (pip-audit)...$(END)"; \
			$(DC) exec -e PYTHONPATH=/app $(CONTAINER) pip-audit ;; \
		test) \
			echo "$(INFO) Running tests...$(END)"; \
			$(DC) exec -e PYTHONPATH=/app $(CONTAINER) pytest tests/ --import-mode=importlib $(FLAGS) ;; \
		test-cov) \
			echo "$(INFO) Running tests with coverage...$(END)"; \
			$(DC) exec -e PYTHONPATH=/app $(CONTAINER) pytest --cov=app --cov-report=term-missing tests/ --import-mode=importlib $(FLAGS) ;; \
		*) \
			echo "$(ERROR) Invalid check type. Use: lint, format, typecheck, security, audit, test, test-cov$(END)"; \
			exit 1 ;; \
	esac
	@echo "$(SUCCESS) Check '$(ARG)' completed$(END)"

# ── Cleanup ─────────────────────────────────────────────────────────────────

clean: ## Remove container (but keep image)
	@if $(DC) ps -a --filter "name=^/$(CONTAINER)$$" --format '{{.ID}}' | grep -q .; then \
		$(DC) stop $(CONTAINER) >/dev/null 2>&1; \
		$(DC) rm $(CONTAINER) >/dev/null; \
		echo "$(SUCCESS) Container $(CONTAINER) removed$(END)"; \
	else \
		echo "$(INFO) No container to clean$(END)"; \
	fi

fclean: ## Remove container and images (both dev and prod)
	@# Remove container if exists
	@if $(DC) ps -a --filter "name=^/$(CONTAINER)$$" --format '{{.ID}}' | grep -q .; then \
		$(DC) stop $(CONTAINER) >/dev/null 2>&1; \
		$(DC) rm $(CONTAINER) >/dev/null; \
		echo "$(SUCCESS) Container $(CONTAINER) removed$(END)"; \
	fi
	@# Remove dev image if exists
	@if $(DC) image inspect $(IMAGE_DEV) >/dev/null 2>&1; then \
		$(DC) rmi $(IMAGE_DEV) >/dev/null; \
		echo "$(SUCCESS) Image $(IMAGE_DEV) removed$(END)"; \
	fi
	@# Remove prod image if exists
	@if $(DC) image inspect $(IMAGE_PROD) >/dev/null 2>&1; then \
		$(DC) rmi $(IMAGE_PROD) >/dev/null; \
		echo "$(SUCCESS) Image $(IMAGE_PROD) removed$(END)"; \
	fi

py: ## Display command to activate virtual environment
	@echo "$(INFO) Run this command manually to activate the virtual environment:$(END)"
	@echo "    . .venv/bin/activate"

re: fclean all ## Rebuild everything from scratch (fclean + all)
	@echo "$(SUCCESS) Full rebuild completed$(END)"

.PHONY: all help build up down start stop restart info clean fclean re
.SILENT: