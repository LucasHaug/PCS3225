GHDL := ghdl
WORKDIR := work
VERSION := 08

TARGETS  := ram.vhd rom.vhd

TARGETS += $(wildcard testbenches/*.vhd)

DEBUG := 1
VISUAL := 0

GHDLFLAGS := --std=$(VERSION) --workdir=$(WORKDIR)

ifeq ($(DEBUG), 1)
GHDLFLAGS += -v
endif

# General

analyse: | $(WORKDIR)
	$(GHDL) -a $(GHDLFLAGS) $(TARGETS)

check_syntax: | $(WORKDIR)
	$(GHDL) -s $(GHDLFLAGS) $(TARGETS)

clean:
	rm -rf $(WORKDIR)

$(WORKDIR):
	mkdir -p $(WORKDIR)

# Tests

all_tests: ram_test rom_test

ram_test: | $(WORKDIR)
	$(GHDL) -r $(GHDLFLAGS) ram_tb --vcd=$(WORKDIR)/$@.vcd
ifeq ($(VISUAL), 1)
	gtkwave $(WORKDIR)/$@.vcd
endif

rom_test: | $(WORKDIR)
	$(GHDL) -r $(GHDLFLAGS) rom_tb --vcd=$(WORKDIR)/$@.vcd
ifeq ($(VISUAL), 1)
	gtkwave $(WORKDIR)/$@.vcd
endif

.PHONY: all analyse check_syntax clean
