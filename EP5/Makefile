GHDL := ghdl
WORKDIR := work
VERSION := 93

TARGETS  := polilegsc.vhd

# TARGETS += $(wildcard testbenches/*.vhd)

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

# Components

all_components: polilegsc

polilegsc: analyse | $(WORKDIR)
	$(GHDL) -r $(GHDLFLAGS) polilegsc

# Testbenches

all_tests: polilegsc_test

polilegsc_test: | $(WORKDIR)
	$(GHDL) -e $(GHDLFLAGS) polilegsc_tb
	$(GHDL) -r $(GHDLFLAGS) polilegsc_tb --vcd=$(WORKDIR)/$@.vcd --stop-time=1000ns
ifeq ($(VISUAL), 1)
	gtkwave $(WORKDIR)/$@.vcd
endif

.PHONY: all analyse check_syntax clean
