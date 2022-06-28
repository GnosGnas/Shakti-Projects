## Makefile for SHA3 modules
## Author: Surya Prasad S (EE19B121)

# Variables for details related to the files
SHA3-TB_MODULE	:= mkSHA3tb
SHA3-TB_FILE	:= SHA3_TB
SHA3-TOP_FILE	:= SHA3
KECCAK_MODULE	:= Keccak
VERILOG_FILES	:= verilog
BSV_BUILD		:= bsv_build
EXE				:= a.out

# The steps-warn-interval can be increased or decreased to adjust the display of "Prelude" warning
BSCFLAGS := +RTS -K200M -RTS -steps-warn-interval 4000000 \
-steps-max-intervals 3000000

BSC_CMD          := bsc -vdir $(VERILOG_FILES) -bdir $(BSV_BUILD) $(BSCFLAGS) -verilog
BSC_SIM          := bsc -e 

SHA3_test: $(BSV_BUILD)/$(SHA3-TOP_FILE).bo $(SHA3-TB_FILE).bsv
	@echo "SHA3-test: Compiling and running TestBench for SHA3 Modules..."
	@$(BSC_CMD) $(SHA3-TB_FILE).bsv
	@cd $(VERILOG_FILES) && $(BSC_SIM) $(SHA3-TB_MODULE) $(SHA3-TB_MODULE).v
	@mv $(VERILOG_FILES)/$(EXE) .
	@./a.out

SHA3-main $(BSV_BUILD)/$(SHA3-TOP_FILE).bo: $(SHA3-TOP_FILE).bsv $(BSV_BUILD)/$(KECCAK_MODULE).bo
	@echo "SHA3-main: Compiling" $< "..."
	@$(BSC_CMD) $(SHA3-TOP_FILE).bsv

Keccak-main $(BSV_BUILD)/$(KECCAK_MODULE).bo: $(KECCAK_MODULE).bsv $(BSV_BUILD)/Wire_functions.bo $(BSV_BUILD)/KeccakConstants.bo
	@echo "Keccak-main: Compiling" $< "..."
	@$(BSC_CMD) $(KECCAK_MODULE).bsv

all: prereq Keccak_main SHA3_main SHA3_test
	@echo "all: Running all files..."

prereq $(BSV_BUILD)/Wire_functions.bo $(BSV_BUILD)/KeccakConstants.bo: Wire_functions.bsv KeccakConstants.bsv
	@echo "prereq: Compiling prerequisite files..."
	@$(BSC_CMD) KeccakConstants.bsv
	@$(BSC_CMD) Wire_functions.bsv

clean:
	@echo "Cleaning up..."
	rm $(BSV_BUILD)/*.bo $(VERILOG_FILES)/*.v a.out
