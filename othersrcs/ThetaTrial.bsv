package Theta;

import Vector :: *;
typedef enum {IDLE, ACTIVE, COMPUTE_C, COMPUTE_D, COMPLETED} StatesTheta deriving(Eq,Bits);
interface Ifc_Theta;
	method Action initialize(Vector#(5,Vector#(5,Bit#(64))) in);
	method ActionValue#(Vector#(5,Vector#(5,Bit#(64)))) out();
	
endinterface:Ifc_Theta

(*synthesize*)
module mk_Theta(Ifc_Theta);

//Reg#(Bit#(1)) x <- mkReg(0);

Bit#(64) y = 'h00000000;
Vector#(5, Bit#(64)) v_v1y = replicate(y);
Vector#(5,Vector#(5, Bit#(64))) v_aby = replicate(v_v1y);
//Vector#(5,Vector#(5,Vector#(64, Bit#(1)))) v_aby = replicate(v2y);



			
/*Vector#(64, Reg#(Bit#(1))) v1 = replicate(x);
Vector#(5,Vector#(64, Reg#(Bit#(1)))) v2 = replicate(v1);
Vector#(5,Vector#(64, Reg#(Bit#(1)))) c = replicate(v1);
Vector#(5,Vector#(64, Reg#(Bit#(1)))) d = replicate(v1);

Vector#(5,Vector#(5,Vector#(64, Reg#(Bit#(1))))) a = replicate(v2);
Vector#(5,Vector#(5,Vector#(64, Reg#(Bit#(1))))) ap = replicate(v2);
*/

Reg#(Vector#(5,Bit#(64))) rg_c <- mkReg(v_v1y);
Reg#(Vector#(5,Bit#(64))) rg_d <- mkReg(v_v1y);
Reg#(Vector#(5,Vector#(5,Bit#(64)))) rg_a <- mkReg(v_aby);
Reg#(Vector#(5,Vector#(5,Bit#(64)))) rg_ap <- mkReg(v_aby);



//Vector#(5,Vector#(5,Vector#(64, Reg#(Bit#(1))))) in = replicate(v2);
/*for(int i = 0; i<5;i = i+1)
	for(int j = 0; j<5;j = j+1)
		for(int k = 0; k<64;k=k+1)
			a[i][j][k] <-mkReg(0);

for(int i = 0; i<5;i = i+1)
	for(int j = 0; j<5;j = j+1)
		for(int k = 0; k<64;k=k+1)
			ap[i][j][k] <-mkReg(0);
*/



Reg#(StatesTheta) rg_state <- mkReg(IDLE);


/*for(int i = 0; i<5;i = i+1)
	for(int k = 0; k<64;k=k+1)
		c[i][k] <- mkReg(0);
for(int i = 0; i<5;i = i+1)
	for(int k = 0; k<64;k=k+1)
		d[i][k] <- mkReg(0);
*/	
		
rule computeC(rg_state == ACTIVE);
	rg_state <= COMPUTE_C;
	Vector#(5,Bit#(64)) tempC = rg_c;
	let tempA = rg_a;
	for(int i = 0; i<5; i=i+1)
		for(int k = 0; k<64; k=k+1)
			tempC[i][k] = tempA[i][0][k]^tempA[i][1][k]^tempA[i][2][k]^tempA[i][3][k]^tempA[i][4][k];
	rg_c <= tempC;
	rg_a <= tempA;
		 
endrule 

rule computeD(rg_state == COMPUTE_C);
	
	Vector#(5,Bit#(64)) tempD = rg_d;
	let tempC = rg_c;

	/*for(int i = 1; i<4;i = i+1)
		for(int k = 1; k<64;k=k+1)
			tempD[i][63-k] = tempC[i-1][63-k]^tempC[i+1][64-k];
	for(int k1 = 1; k1<64; k1= k1+1)
		tempD[0][63-k1] = tempC[4][63-k1]^tempC[1][63-k1+1];
	for(int k1 = 1; k1<64; k1= k1+1)
		tempD[4][63-k1] = tempC[3][63-k1]^tempC[0][63-k1+1];
	for(int i1 = 1; i1<4; i1= i1+1)
		tempD[i1][63] = tempC[i1-1][63]^tempC[i1+1][0];
	tempD[0][63] = tempC[4][63]^tempC[1][0];
	tempD[4][63] = tempC[3][63]^tempC[0][0];
	*/
	for(Integer i = 0;i<5;i=i+1)
		for(Integer j = 0;j<5;j=j+1)
			for(Integer k =0;k<64;k=k+1)
				tempD[i][k] = tempC[mod((i-1),5)][k]^tempC[mod((i+1),5)][mod((k-1),64)];

	rg_d <= tempD;
	rg_c <= tempC;
	rg_state <= COMPUTE_D;		 
endrule 

rule computeA(rg_state == COMPUTE_D);
	rg_state <= COMPLETED;
	Vector#(5,Vector#(5,Bit#(64))) tempAP = rg_ap;
	let tempA = rg_a;
	let tempD = rg_d;

	for(int i = 0; i<5;i = i+1)
		for(int k = 0; k<64;k = k+1)
			for(int j = 0; j<5;j=j+1)
				tempAP[i][j][k] = tempA[i][j][k]^tempD[i][k];
	rg_ap <= tempAP;
	rg_a <= tempA;
	rg_d <= tempD;
	
endrule 



method Action initialize(in)if(rg_state == IDLE);
	rg_state <= ACTIVE;
	Vector#(5,Vector#(5,Bit#(64))) tempA = rg_a;
	for(int i = 0; i<5;i = i+1)
		for(int j = 0; j<5;j = j+1)
			for(int k = 0; k<64;k=k+1)
				tempA[i][j][k] = in[i][j][k];
	rg_a <= tempA;
	
endmethod

method ActionValue#(Vector#(5,Vector#(5,Bit#(64)))) out()if(rg_state == COMPLETED);
rg_state <= IDLE;
return rg_ap;
endmethod

endmodule : mk_Theta
endpackage : Theta
