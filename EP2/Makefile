GHDL := ghdl
WORKDIR := work
VERSION := 08

TARGETS  := reg.vhd regfile.vhd

TARGETS += $(wildcard testbenches/*.vhd)

DEBUG := 1
VISUAL := 0

GHDLFLAGS := --std=$(VERSION) --workdir=$(WORKDIR)

ifeq ($(DEBUG), 1)
GHDLFLAGS += -v
endif

analyse: | $(WORKDIR)
	$(GHDL) -a $(GHDLFLAGS) $(TARGETS)

all_components: reg regfile

reg: analyse | $(WORKDIR)
	$(GHDL) -r $(GHDLFLAGS) reg

regfile: analyse | $(WORKDIR)
	$(GHDL) -r $(GHDLFLAGS) regfile

all_tests: reg_test regfile_test

reg_test: | $(WORKDIR)
	$(GHDL) -r $(GHDLFLAGS) reg_tb --vcd=$(WORKDIR)/$@.vcd
ifeq ($(VISUAL), 1)
	gtkwave $(WORKDIR)/$@.vcd
endif

regfile_test: | $(WORKDIR)
	$(GHDL) -r $(GHDLFLAGS) regfile_tb --vcd=$(WORKDIR)/$@.vcd
ifeq ($(VISUAL), 1)
	gtkwave $(WORKDIR)/$@.vcd
endif

check_syntax: | $(WORKDIR)
	$(GHDL) -s $(GHDLFLAGS) $(TARGETS)

clean:
	rm -rf $(WORKDIR)

$(WORKDIR):
	mkdir -p $(WORKDIR)

.PHONY: all analyse check_syntax clean
