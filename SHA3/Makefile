BSCFLAGS=+RTS -K200M -RTS -steps-warn-interval 4000000 \
-steps-max-intervals 3000000

SHA3_tb: myKeccak.bo mySHA3.bo sha3tb.bsv
	@echo "SHA3-test: Compiling and running TestBench for SHA3 Modules..."
	bsc -verilog sha3tb.bsv
	bsc -e mkSHA3tb mkSHA3tb.v
	./a.out

SHA3_main mySHA3.bo: myKeccak.bo mySHA3.bsv
	@echo "SHA3-main: Compiling mySHA3.bsv"
	bsc -verilog mySHA3.bsv

Keccak_tb: myKeccak.bo Tb.bsv
	@echo "Keccak-test: Compiling and running only TestBench for Keccak Modules..."
	bsc -verilog Tb.bsv
	bsc -e mkTb mkTb.v
	./a.out

Keccak_main myKeccak.bo: myKeccak.bsv
	@echo "Keccak-main: Compiling myKeccak.bsv..."
	bsc -verilog $(BSCFLAGS) myKeccak.bsv

all: prereq Keccak_main SHA3_main SHA3_tb 
	@echo "all: Running all files..."

prereq: Wirefunctions.bsv KeccakConstants.bsv
	@echo "prereq: Compiling prerequisite files..."
	bsc -verilog KeccakConstants.bsv
	bsc -verilog Wirefunctions.bsv

clean:
	@echo "Cleaning up..."
	rm -f *.bo *.v a.out
