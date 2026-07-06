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

help:
	echo help
build:
	echo build
up:
	echo up
down:
	echo down
restart:
	echo lol
logs:
	echo logs

ps:
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

clean:
	echo clean
fclean:
	echo fclean
fe:
	echo fe
be:
	echo be
socket:
	echo socket
nginx:
	echo nginx
postgres:
	echo postgres
redis:
	echo redis
lint:
	echo lint
format:
	echo format
typecheck:
	echo typecheck
test:
	echo test

.PHONY: help build up down restart logs ps clean fclean fe be socket nginx postgres redis lint format typecheck test
.SILENT: