package ThetaTrial1;

import Vector::*;

interface State_interface;
	method Action initialize(Vector#(5,Vector#(5,Bit#(64))) in);
	method ActionValue#(Vector#(5,Vector#(5,Bit#(64)))) out();
	
endinterface:State_interface

//typedef Reg#(Vector#(5,Vector#(5,Bit#(64)))) Wire#(Vector#(5,Vector#(5,Bit#(64))));
//typedef Reg#(Vector#(5,Bit#(64))) Wire#(Vector#(5,Bit#(64)));

(*synthesize*)
module thetaTrial1(State_interface);

//Reg#(Bit#(1)) x <- mkReg(0);

Bit#(64) y = 'h00000000;
Vector#(5, Bit#(64)) v1y = replicate(y);
Vector#(5,Vector#(5, Bit#(64))) aby = replicate(v1y);
//Vector#(5,Vector#(5,Vector#(64, Bit#(1)))) aby = replicate(v2y);



			
/*Vector#(64, Reg#(Bit#(1))) v1 = replicate(x);
Vector#(5,Vector#(64, Reg#(Bit#(1)))) v2 = replicate(v1);
Vector#(5,Vector#(64, Reg#(Bit#(1)))) c = replicate(v1);
Vector#(5,Vector#(64, Reg#(Bit#(1)))) d = replicate(v1);

Vector#(5,Vector#(5,Vector#(64, Reg#(Bit#(1))))) a = replicate(v2);
Vector#(5,Vector#(5,Vector#(64, Reg#(Bit#(1))))) ap = replicate(v2);
*/

Wire#(Vector#(5,Bit#(64))) c <- mkWire();
Wire#(Vector#(5,Bit#(64))) d <- mkWire();
//c.wset(0);
//d.wset(0);
Reg#(Vector#(5,Vector#(5,Bit#(64)))) a <- mkReg(aby);
Reg#(Vector#(5,Vector#(5,Bit#(64)))) ap <- mkReg(aby);



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



Reg#(Bit#(1)) theta_Flag <- mkReg(0);
Reg#(Bit#(1)) theta_Flag1 <- mkReg(0);
Reg#(Bit#(1)) theta_Flag2 <- mkReg(0);
Reg#(Bit#(1)) theta_Flag3 <- mkReg(0);

/*for(int i = 0; i<5;i = i+1)
	for(int k = 0; k<64;k=k+1)
		c[i][k] <- mkReg(0);
for(int i = 0; i<5;i = i+1)
	for(int k = 0; k<64;k=k+1)
		d[i][k] <- mkReg(0);
*/	
		
rule computeC((theta_Flag == 1)&&(theta_Flag1 == 0));
	theta_Flag1 <= 1;
	//Vector#(5,Bit#(64)) tempC = c;
	let tempA = a;
	for(int i = 0; i<5; i=i+1)
		for(int k = 0; k<64; k=k+1)
			c[i][k] <= tempA[i][0][k]^tempA[i][1][k]^tempA[i][2][k]^tempA[i][3][k]^tempA[i][4][k];
	//c <= tempC;
	a <= tempA;
		 
endrule 

rule computeD((theta_Flag1 == 1)&&(theta_Flag2 == 0));
	
	//Vector#(5,Bit#(64)) tempD = d;
	//let tempC = c;

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
				d[i][k] <= c[mod((i-1),5)][k]^c[mod((i+1),5)][mod((k-1),64)];

	//d <= tempD;
	//c <= tempC;
	theta_Flag2 <= 1;		 
endrule 

rule computeA((theta_Flag2 == 1)&&(theta_Flag3 == 0));
	theta_Flag3 <= 1;
	Vector#(5,Vector#(5,Bit#(64))) tempAP = ap;
	let tempA = a;
	//let tempD = d;

	for(int i = 0; i<5;i = i+1)
		for(int k = 0; k<64;k = k+1)
			for(int j = 0; j<5;j=j+1)
				tempAP[i][j][k] = tempA[i][j][k]^d[i][k];
	ap <= tempAP;
	a <= tempA;
	//d <= tempD;
	
endrule 



method Action initialize(in)if(theta_Flag == 0);
	theta_Flag <= 1;
	Vector#(5,Vector#(5,Bit#(64))) tempA = a;
	for(int i = 0; i<5;i = i+1)
		for(int j = 0; j<5;j = j+1)
			for(int k = 0; k<64;k=k+1)
				tempA[i][j][k] = in[i][j][k];
	a <= tempA;
	
endmethod

method ActionValue#(Vector#(5,Vector#(5,Bit#(64)))) out()if((theta_Flag==1)&&(theta_Flag3==1));
theta_Flag <= 0;
theta_Flag1 <= 0;
theta_Flag2 <= 0;
theta_Flag3 <= 0;

return ap;
endmethod

endmodule : thetaTrial1
endpackage : ThetaTrial1
