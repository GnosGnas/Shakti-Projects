BSCFLAGS=+RTS -K200M -RTS -steps-warn-interval 4000000 \
-steps-max-intervals 3000000

test: myKeccak2.v Tb.bsv
	@echo "test: Compiling and running only TestBench..."
	bsc -verilog Tb.bsv
	bsc -e mkTb mkTb.v
	./a.out

main myKeccak2.v: myKeccak2.bsv
	@echo "main: Compiling myKeccak2.bsv..."
	bsc -verilog $(BSCFLAGS) myKeccak2.bsv

all: prereq main test
	@echo "all: Running all files..."

prereq: Wirefunctions.bsv KeccakConstants.bsv
	@echo "prereq: Compiling prerequisite files..."
	bsc -verilog KeccakConstants.bsv
	bsc -verilog Wirefunctions.bsv

clean:
	@echo "Cleaning up..."
	rm -f *.bo *.v
