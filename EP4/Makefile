GHDL := ghdl
WORKDIR := work
VERSION := 93

TARGETS  := signExtend.vhd alu.vhd alucontrol.vhd controlunit.vhd

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

# Components

all_components: signExtend alucontrol controlunit alu1bit alu

signExtend: analyse | $(WORKDIR)
	$(GHDL) -r $(GHDLFLAGS) signExtend

alucontrol: analyse | $(WORKDIR)
	$(GHDL) -r $(GHDLFLAGS) alucontrol

controlunit: analyse | $(WORKDIR)
	$(GHDL) -r $(GHDLFLAGS) controlunit

alu1bit: analyse | $(WORKDIR)
	$(GHDL) -r $(GHDLFLAGS) alu1bit

alu: analyse | $(WORKDIR)
	$(GHDL) -r $(GHDLFLAGS) alu

# Testbenches

all_tests: signExtend_test alucontrol_test controlunit_test alu1bit_test alu_test

signExtend_test: | $(WORKDIR)
	$(GHDL) -r $(GHDLFLAGS) signExtend_tb --vcd=$(WORKDIR)/$@.vcd
ifeq ($(VISUAL), 1)
	gtkwave $(WORKDIR)/$@.vcd
endif

alucontrol_test: | $(WORKDIR)
	$(GHDL) -r $(GHDLFLAGS) alucontrol_tb --vcd=$(WORKDIR)/$@.vcd
ifeq ($(VISUAL), 1)
	gtkwave $(WORKDIR)/$@.vcd
endif

controlunit_test: | $(WORKDIR)
	$(GHDL) -r $(GHDLFLAGS) controlunit_tb --vcd=$(WORKDIR)/$@.vcd
ifeq ($(VISUAL), 1)
	gtkwave $(WORKDIR)/$@.vcd
endif

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
