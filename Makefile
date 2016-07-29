# this is entirely for people with muscle memory
# from using Makefile build systems.

# this basically translates `make X` to `./main.lua X`

# get command line arguments
ifndef MAKECMDGOALS
RUN_ARGS := default
else
RUN_ARGS := $(wordlist 1,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
endif

# run the corresponding lua script
DIR=LEOS
CMD=@luajit $(DIR)/main.lua $(RUN_ARGS)
$(eval $(word 1, $(RUN_ARGS)):;$(CMD))
