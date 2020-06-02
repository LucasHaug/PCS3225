GHDL := ghdl
WORKDIR := work
VERSION := 93

TARGETS  := signExtend.vhd alu.vhd alucontrol.vhd controlunit.vhd

TARGETS += $(wildcard testbenches/*.vhd)

DEBUG ?= 1
VISUAL ?= 0
VERBOSE ?= 1

GHDLFLAGS := --std=$(VERSION) --workdir=$(WORKDIR)

ifeq ($(DEBUG), 1)
GHDLFLAGS += -v
endif

# Verbosity
ifeq ($(VERBOSE),0)
AT := @
else
AT :=
endif

COMPONENT_TO_TEST ?= signExtend

# General

analyse: | $(WORKDIR)
	$(AT)$(GHDL) -a $(GHDLFLAGS) $(TARGETS)

check_syntax: | $(WORKDIR)
	$(AT)$(GHDL) -s $(GHDLFLAGS) $(TARGETS)

clean:
	$(AT)rm -rf $(WORKDIR)

$(WORKDIR):
	$(AT)mkdir -p $(WORKDIR)

# Tests

test: | $(WORKDIR)
	$(AT)$(GHDL) -r $(GHDLFLAGS) $(COMPONENT_TO_TEST)_tb --vcd=$(WORKDIR)/$@.vcd
ifeq ($(VISUAL), 1)
	$(AT)gtkwave $(WORKDIR)/$@.vcd
endif

.PHONY: all analyse check_syntax clean test
