lint: yamllint
yamllint:
	@yamllint . -f parsable
.PHONY: lint yamllint
