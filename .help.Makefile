# Snippet with top-level help for make, so you can ‘make help’ rather than open
# all Makefiles in editor or use noisy autocompletion.

# Not portable!
export LESS := FRXS
help:
	@echo 'Please read the Makefile(s) or make -n your_command to see comments.'
	@echo 'Autocompletion is full of false positives.'
	@{ git grep --no-index -l -E '^[^#[:space:]]+:' \
	     -- ':!:.utils.Makefile' ':!:.help.Makefile' \
	        '**/Makefile' '.*.Makefile' \
	     | while read makefile; do \
	         tput bold; \
	         tput setaf 9; \
	         printf '%s:\n' "$$makefile"; \
	         tput sgr0; \
	         git grep --no-index -E '^[^[:space:]]+:' -- "$$makefile" \
	           | grep -vE -e ':(.[A-Z]+:)' \
	                      -e ':(\.[[:alnum:]]+){2}:' \
	                      -e ':#' \
	           | cut -d : -f 2 \
	           | column -c 80; \
	       done } | less
	@echo 'You may have to make -f the makefiles above,'
	@echo 'if they are not included by the current Makefile.'

.PHONY: help
