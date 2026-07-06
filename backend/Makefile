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
IMAGE = img_$(NAME)
CONTAINER = $(NAME)


################################################################################
#                                  TARGETS                                     #
################################################################################

help: ## Show this help
	@echo "$(INFO) Available targets:$(END)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(LIGTH)%-20s$(END) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build image
	$(DC) build --no-cache -t img_$(NAME) .

info: ## Show project info. Usage: make info [ARG=img|ps]
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
			echo "$(ERROR) Invalid ARG value: '$(ARG)'. Use 'img', 'ps' or leave empty.$(END)"; \
			exit 1;; \
	esac

.PHONY: help build up down restart start stop logs ps clean fclean
.SILENT: