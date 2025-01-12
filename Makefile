ifeq ($(origin STDOUT), undefined)
	BUILDCMD := zig build -Dno-stdout
else
	BUILDCMD := zig build
endif

ZIGFLAGS = --summary all

all: clean build-all

.PHONY: build-all
build-all: check clean
	$(BUILDCMD) all $(ZIGFLAGS)

docs: check
	$(BUILDCMD) docs $(ZIGFLAGS)

.PHONY: clean
clean:
	$(BUILDCMD) clean $(ZIGFLAGS)

install:
	$(BUILDCMD) install $(ZIGFLAGS)

.PHONY: check
check:
	$(BUILDCMD) check $(ZIGFLAGS)

fmt: check
	$(BUILDCMD) fmt $(ZIGFLAGS)

test: check
	$(BUILDCMD) test $(ZIGFLAGS)

run:
	$(BUILDCMD) run $(ZIGFLAGS)

.PHONY: list
list:
	$(BUILDCMD) -l
