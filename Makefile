# look in LUA_MAKE/targets.lua for actual build scripts

# get command line arguments
ifndef MAKECMDGOALS
RUN_ARGS := default
else
RUN_ARGS := $(wordlist 1,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
endif

# run the corresponding lua script
DIR=LEOS
CMD=@luajit $(DIR)/main.lua $(DIR) $(RUN_ARGS)
$(eval $(RUN_ARGS):;$(CMD))
