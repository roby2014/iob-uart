UART_DIR:=../..

incdir:=-I
defmacro:=-D

include $(UART_DIR)/hardware/hardware.mk

ifeq ($(VCD),1)
DEFINE+=$(defmacro)VCD
endif

TB_SRC=$(UART_HW_DIR)/simulation/testbench/uart_tb.v
VSRC+=$(TB_SRC)

VLOG:=iverilog -Wall -g2012 #icarus verilog simulator flags
ECP5_SRC=/usr/share/yosys/ecp5
SIM_PROC=a.out
GENERATED_VERILOG=SYNTH.v

run: $(SIM_PROC)
	./$< $(TEST_LOG)
ifeq ($(VCD),1)
	if [ "`pgrep -u $(USER) gtkwave`" ]; then killall -q -9 gtkwave; fi
	gtkwave -a ../waves.gtkw uut.vcd &
endif

$(SIM_PROC): $(VSRC) $(VHDR)
ifndef YOSYS_VERILOG
	$(VLOG) $(INCLUDE) $(DEFINE) $(VSRC)
else 
	tclsh generate_yosys_verilog.tcl "$(INCLUDE)" "$(DEFINE)" "$(VSRC)" "$(GENERATED_VERILOG)" "$(GENERIC_OUTPUT)"
ifndef GENERIC_OUTPUT
	$(VLOG) $(TB_SRC) $(GENERATED_VERILOG) $(ECP5_SRC)/cells_bb.v -o $(SIM_PROC) -I $(ECP5_SRC) -l$(ECP5_SRC)/cells_sim.v
else
	$(VLOG) $(TB_SRC) $(GENERATED_VERILOG) $(DEFINE) -o $(SIM_PROC)
endif
endif

test: clean-testlog test1
	diff -q test.log test.expected

test1: clean
	make run VCD=0 TEST_LOG=">> test.log"

debug:
	@echo $(UART_DIR)
	@echo $(MODULES)
	@echo $(SUBMODULES_DIR)
	@echo $(MKREGS)
	@echo $(VSRC)

#clean test log only when tests begin
clean-testlog:
	@rm -f test.log

clean: uart-hw-clean
	@rm -f $(SIM_PROC) $(GENERATED_VERILOG) *.vcd *.log *.ys *.json

clean-all: clean-testlog clean

.PHONY: run \
	test test1 \
	debug
	clean-testlog clean clean-all