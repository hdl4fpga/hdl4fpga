OS    := $(shell echo $(OS))

ifeq ($(OS), Windows_NT)
	include Makefile.windows
else
	UNAME := $(shell unam)
	include Makefile.posix
endif
