package RhoTrial;

import Vector :: *;

interface State2_interface;
	method Action initialize2(Vector#(5,Vector#(5,Bit#(64))) in);
	method ActionValue#(Vector#(5,Vector#(5,Bit#(64)))) out2();
	
endinterface:State2_interface

(*synthesize*)
module rhotrial(State2_interface);

Bit#(64) y = 'b0000000000000000000000000000000000000000000000000000000000000000;
//Vector#(64, Bit#(1)) v1y = replicate(y);
Vector#(5,Bit#(64)) v2y = replicate(y);
Vector#(5,Vector#(5,Bit#(64))) aby = replicate(v2y);
Reg#(Vector#(5,Vector#(5,Bit#(64)))) a <- mkReg(aby);
Reg#(Vector#(5,Vector#(5,Bit#(64)))) ap <- mkReg(aby);


Reg#(Bit#(1)) rho_Flag <- mkReg(0);
Reg#(Bit#(1)) rho_Flag1 <- mkReg(0);


int x = 0;
Vector#(64, int) v1x = replicate(x);
Vector#(24,Vector#(64, int)) shift = replicate(v1x);

Vector#(24, int) it;
it[0] = 1;
it[1] = 0;
it[2] = 2;
it[3] = 1;
it[4] = 2;
it[5] = 3;
it[6] = 3;
it[7] = 0;
it[8] = 1;
it[9] = 3;
it[10] = 1;
it[11] = 4;
it[12] = 4;
it[13] = 0;
it[14] = 3;
it[15] = 4;
it[16] = 3;
it[17] = 2;
it[18] = 2;
it[19] = 0;
it[20] = 4;
it[21] = 2;
it[22] = 4;
it[23] = 1;

Vector#(24, int) jt;

jt[0] = 0;
jt[1] = 2;
jt[2] = 1;
jt[3] = 2;
jt[4] = 3;
jt[5] = 3;
jt[6] = 0;
jt[7] = 1;
jt[8] = 3;
jt[9] = 1;
jt[10] = 4;
jt[11] = 4;
jt[12] = 0;
jt[13] = 3;
jt[14] = 4;
jt[15] = 3;
jt[16] = 2;
jt[17] = 2;
jt[18] = 0;
jt[19] = 4;
jt[20] = 2;
jt[21] = 4;
jt[22] = 1;
jt[23] = 1;

rule go((rho_Flag == 1)&&(rho_Flag1 == 0));
	rho_Flag1 <= 1;
	Vector#(5,Vector#(5,Bit#(64))) tempA = a;
	Vector#(5,Vector#(5,Bit#(64))) tempAP = ap;
	for (int k1 = 0; k1<64; k1=k1+1)
		tempAP[0][0][k1] = tempA[0][0][k1];
	Integer t = 0;
	//int x = 0;
	int i = 1;
 	int j = 0;
	//int j1 = 0;
	Integer s = 0;
	//Bit#(64) a = 0000000000000000000000000000000000000000000000000000000000000000;
	
	while(t<24) begin
	//for(int t =0;t<24; t = t+1)
		i = it[t];
		j = jt[t];
		s = (t+1)*(t+2)/2;
		for(Integer k = 0;k<64;k=k+1)		
			tempAP[i][j][k] = tempA[i][j][mod((k-s),64)];
				t = t+1;
	end
	//if(t == 23)
	//	rho_Flag1 <= 1;
	ap <= tempAP;
	a <= tempA;
endrule


method Action initialize2(in)if(rho_Flag == 0);
	rho_Flag <= 1;
	Vector#(5,Vector#(5,Bit#(64))) tempA = a;
	for(int i = 0; i<5;i = i+1)
		for(int j = 0; j<5;j = j+1)
			//for(int k = 0; k<64;k=k+1)
				tempA[i][j] = in[i][j];
	a <= tempA;
	
endmethod

method ActionValue#(Vector#(5,Vector#(5,Bit#(64)))) out2()if((rho_Flag==1)&&(rho_Flag1==1));
rho_Flag <= 0;
rho_Flag1 <= 0;

return ap;
endmethod



endmodule : rhotrial
endpackage : RhoTrial

