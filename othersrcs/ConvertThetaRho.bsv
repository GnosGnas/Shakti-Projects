package ConvertThetaRho;

import Vector :: *;

typedef enum {IDLE, ACTIVE, THETA, RHO, PI, CHI, IOTA, DONE} States deriving(Eq, Bits);

import ConvertTo3D :: *;
import ThetaTrial ::*;
import RhoTrial ::*;
import PiTrial ::*;
import ChiTrial ::*;
import IotaTrial1 ::*; 

module testbench01(Empty);

Bit#(1) y = 1;
Bit#(1) x = 0;
Vector#(1600,Bit#(1)) c = replicate(y);
c[67] = 0;
//c[64:1599] = replicate(x);
Reg#(Vector#(1600,Bit#(1))) s <- mkReg(c);

Bit#(64) ab = 'h0000000000000000;
Vector#(5, Bit#(64)) ab1= replicate(ab);
Vector#(5,Vector#(5, Bit#(64))) ab2 = replicate(ab1);
Reg#(Vector#(5,Vector#(5, Bit#(64)))) a <- mkReg(ab2);
 
State0_interface io <- conversion();
State_interface io1 <- thetaTrial();
State2_interface io2 <- rhotrial();
State3_interface io3 <- pitrial();
State4_interface io4 <- chitrial();
State5_interface io5 <- iotatrial1();

Reg#(States) state <- mkReg(ACTIVE);

rule go(state == ACTIVE);
	io.init0(s);
	state <= THETA;
endrule

rule printAresult(state == THETA);
	state<= RHO;
	let a1 <- io.out0();
	io1.initialize(a1);
	for(int i = 0; i<5;i=i+1)
		for(int j =0;j<5;j=j+1)
			for(int k =0;k<64;k = k+1)
				$write(a1[i][j][k]);
	
	a <= a1;
	$display("");
	//$finish();
endrule

rule printThetaOutput(state == RHO);
	//let a2 = a;
	state <= PI;
	let a2 <- io1.out();
	io2.initialize2(a2);
	//int j = 0;
	a <= a2;
	//$display(state);
endrule

rule printRhoresult(state == PI);
	state<= CHI;
	let a3 <- io2.out2();
	io3.initialize3(a3);

	a <= a3;
	//$display(state);
	//$finish();
endrule

rule printPiresult(state == CHI);
	state<= IOTA;
	let a4 <- io3.out3();
	io4.initialize4(a4);

	a <= a4;
	//$display(state);
	//$finish();
endrule

rule printChiresult(state == IOTA);
	state<= DONE;
	let a5 <- io4.out4();
	io5.initialize5(a5,1);
	for(int i = 0; i<5;i=i+1)
		for(int j =0;j<5;j=j+1)
			for(int k =63;k>-1;k = k-1)
				$write(a5[i][j][k]);
	a <= a5;
	$display("");
	//$finish();
endrule

rule printIotaresult(state == DONE);
	state<= IDLE;
	let a6 <- io5.out5();
	//io1.initialize(a1);
	for(int i = 0; i<5;i=i+1)
		for(int j =0;j<5;j=j+1)
			for(int k =63;k>-1;k = k-1)
				$write(a6[i][j][k]);
	
	a <= a6;
	//$display(state);
	$finish();
endrule




endmodule : testbench01
endpackage : ConvertThetaRho
