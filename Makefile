.POSIX:
.SUFFIXES:

IMAGE_NAME = imrsv-schema-linter:prod

include .help.Makefile
include .anchore.Makefile
include .lint.Makefile
