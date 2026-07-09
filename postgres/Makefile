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
NAME = postgres
IMAGE = img_$(NAME)
CONTAINER = $(NAME)
VOLUME = matcha_pgdata

################################################################################
#                                  TARGETS                                     #
################################################################################

all: build up

help: ## Show this help
	@echo "$(INFO) Available targets:$(END)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(LIGTH)%-20s$(END) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build image (default: dev, use ARG=prod for production)
	$(DC) build --no-cache -t $(IMAGE) .
	@echo "$(SUCCESS) Image $(IMAGE) built$(END)"

# ── Container lifecycle ────────────────────────────────────────────────────

up: ## Run container in background (default: dev, use ARG=prod for production)
	@if [ -n "$$($(DC) ps -a --filter name=^/$(CONTAINER)$$ --format '{{.ID}}')" ]; then \
		echo "$(WARNING) Container $(CONTAINER) already exists. Use 'make start' or 'make down' first.$(END)"; \
		exit 1; \
	fi
	$(DC) run -d --name $(CONTAINER) \
		-p 5432:5432 \
		-v $(VOLUME):/var/lib/postgresql/data \
		--env-file .env \
		$(IMAGE)
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

shell: ## Open psql console inside the container
	@TARGET=$${ARG:-$(CONTAINER)}; \
	if $(DC) ps --filter "name=^/$$TARGET$$" --format '{{.ID}}' | grep -q .; then \
		$(DC) exec -it $$TARGET psql -U $${POSTGRES_USER:-postgres} -d $${POSTGRES_DB:-matcha}; \
	else \
		echo "$(ERROR) Container $$TARGET is not running$(END)"; \
		exit 1; \
	fi

# ── Cleanup ─────────────────────────────────────────────────────────────────

clean: ## Remove container (but keep image and volume)
	@if $(DC) ps -a --filter "name=^/$(CONTAINER)$$" --format '{{.ID}}' | grep -q .; then \
		$(DC) stop $(CONTAINER) >/dev/null 2>&1; \
		$(DC) rm $(CONTAINER) >/dev/null; \
		echo "$(SUCCESS) Container $(CONTAINER) removed$(END)"; \
	else \
		echo "$(INFO) No container to clean$(END)"; \
	fi

fclean: clean ## Remove container, images and volume
	@# Remove images
	@if $(DC) image inspect $(IMAGE) >/dev/null 2>&1; then \
		$(DC) rmi $(IMAGE) >/dev/null; \
		echo "$(SUCCESS) Image $(IMAGE) removed$(END)"; \
	fi
	@if $(DC) image inspect $(IMAGE) >/dev/null 2>&1; then \
		$(DC) rmi $(IMAGE) >/dev/null; \
		echo "$(SUCCESS) Image $(IMAGE) removed$(END)"; \
	fi
	@# Remove volume (the one matching current MODE)
	@if docker volume inspect $(VOLUME) >/dev/null 2>&1; then \
		docker volume rm $(VOLUME) >/dev/null; \
		echo "$(SUCCESS) Volume $(VOLUME) removed$(END)"; \
	else \
		echo "$(INFO) Volume $(VOLUME) does not exist$(END)"; \
	fi

re: fclean all ## Rebuild everything from scratch (fclean + all)
	@echo "$(SUCCESS) Full rebuild completed$(END)"

.PHONY: all help build up down start stop restart info shell clean fclean re
.SILENT: