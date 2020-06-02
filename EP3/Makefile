GHDL := ghdl
WORKDIR := work
VERSION := 93

TARGETS  := alu1bit.vhd alu.vhd

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

all_tests: alu1bit_test alu_test

alu1bit_test: | $(WORKDIR)
	$(GHDL) -r $(GHDLFLAGS) alu1bit_tb --vcd=$(WORKDIR)/$@.vcd
ifeq ($(VISUAL), 1)
	gtkwave $(WORKDIR)/$@.vcd
endif

alu_test: | $(WORKDIR)
	$(GHDL) -r $(GHDLFLAGS) alu_tb --vcd=$(WORKDIR)/$@.vcd
ifeq ($(VISUAL), 1)
	gtkwave $(WORKDIR)/$@.vcd
endif

.PHONY: all analyse check_syntax clean
