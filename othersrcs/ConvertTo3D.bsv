package ConvertTo3D;

import Vector ::*;

typedef enum {IDLE, ACTIVE, COMPLETED} StateConversion deriving(Eq, Bits);

interface State0_interface;
	method Action init0(Vector#(1600, Bit#(1)) in);
	method ActionValue#(Vector#(5,Vector#(5,Bit#(64)))) out0();
endinterface : State0_interface



module conversion(State0_interface);
Bit#(1) y = 0;
Reg#(Bit#(1)) en <- mkReg(0);
Reg#(Bit#(1)) en2 <- mkReg(0);
Bit#(64) ab = '0;
//Vector#(64, Bit#(1)) v1y = replicate(y);
Vector#(5,Bit#(64)) v2y = replicate(ab);
Vector#(5,Vector#(5,Bit#(64))) aby = replicate(v2y);
Reg#(Vector#(5,Vector#(5, Bit#(64)))) a <- mkReg(aby);

Vector#(1600, Bit#(1)) s1 = replicate(y);
Reg#(Vector#(1600, Bit#(1))) s <- mkReg(s1);

Reg#(StateConversion) state <- mkReg(IDLE);


rule processing(state == ACTIVE);
	Vector#(5,Vector#(5,Bit#(64))) temp = a;
	int i = 0;
	int j = 0;
	int k =0;
	for( i = 0;i<5;i = i+1)
		for( j = 0; j<5;j=j+1)
			for( k = 0; k<64; k=k+1)
				temp[i][j][k] = s[64*(5*i +j) + k];
	a <= temp;
	state <= COMPLETED;
endrule 

method Action init0(in)if(state == IDLE);
	Vector#(1600, Bit#(1)) temp = s;
	state <= ACTIVE;
	for(int i =0;i<1600;i = i+1)	
		temp[i] = in[i];
	s <= temp;
endmethod

method ActionValue#(Vector#(5, Vector#(5, Bit#(64)))) out0()if(state == COMPLETED);
	en2 <= 0;
	en <= 0;
	state <= IDLE;
 	return a;
endmethod

endmodule : conversion
endpackage : ConvertTo3D
