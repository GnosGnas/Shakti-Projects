package ChiTrial;

import Vector :: *;


typedef enum {IDLE, ACTIVE_INPUT, COMPLETED} States deriving(Eq,Bits);



interface State4_interface;
	method Action initialize4(Vector#(5,Vector#(5,Bit#(64))) in);
	method ActionValue#(Vector#(5,Vector#(5,Bit#(64)))) out4();
	
endinterface:State4_interface

(*synthesize*)
module chitrial(State4_interface);

Bit#(64) y = 'b0000000000000000000000000000000000000000000000000000000000000000;

Vector#(5,Bit#(64)) v2y = replicate(y);
Vector#(5,Vector#(5,Bit#(64))) aby = replicate(v2y);
Reg#(Vector#(5,Vector#(5,Bit#(64)))) a <- mkReg(aby);
Reg#(Vector#(5,Vector#(5,Bit#(64)))) ap <- mkReg(aby);


//Reg#(Bit#(1)) rho_Flag <- mkReg(0);
//Reg#(Bit#(1)) rho_Flag1 <- mkReg(0);
Reg#(States) state <- mkReg(IDLE);

int x = 0;
Vector#(64, int) v1x = replicate(x);
Vector#(24,Vector#(64, int)) shift = replicate(v1x);



rule go(state == ACTIVE_INPUT);
	state <= COMPLETED;
	Vector#(5,Vector#(5,Bit#(64))) tempA = a;
	Vector#(5,Vector#(5,Bit#(64))) tempAP = ap;
	
	for(Integer i = 0; i<5; i = i+1) 
		for(Integer j = 0;j<5;j=j+1)
			for(Integer k = 0;k<64;k=k+1)		
				tempAP[i][j][k] = tempA[i][j][k]^(~tempA[mod((i + 1),5)][j][k]&tempA[mod((i + 2),5)][j][k]);
				
	

	ap <= tempAP;
	a <= tempA;
endrule


method Action initialize4(in)if(state == IDLE);
	state <= ACTIVE_INPUT;
	Vector#(5,Vector#(5,Bit#(64))) tempA = a;
	for(int i = 0; i<5;i = i+1)
		for(int j = 0; j<5;j = j+1)
			//for(int k = 0; k<64;k=k+1)
				tempA[i][j] = in[i][j];
	a <= tempA;
	
endmethod

method ActionValue#(Vector#(5,Vector#(5,Bit#(64)))) out4()if(state == COMPLETED);
state <= IDLE;
return ap;
endmethod



endmodule : chitrial
endpackage : ChiTrial

