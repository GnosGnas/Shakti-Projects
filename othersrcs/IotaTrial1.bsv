package IotaTrial1;

import Vector :: *;


typedef enum {IDLE, ACTIVE_INPUT, ACTIVE, COMPUTE_RC, COMPLETED} States deriving(Eq,Bits);
//typedef enum {IDLE, ACTIVE, DONE} RCStates deriving(Eq, Bits);


interface State5_interface;
	method Action initialize5(Vector#(5,Vector#(5,Bit#(64))) in, int ir);
	method ActionValue#(Vector#(5,Vector#(5,Bit#(64)))) out5();
	
endinterface:State5_interface








(*synthesize*)
module iotatrial1(State5_interface);

Bit#(64) y = 'b0000000000000000000000000000000000000000000000000000000000000000;

Vector#(5,Bit#(64)) v2y = replicate(y);
Vector#(5,Vector#(5,Bit#(64))) aby = replicate(v2y);
Reg#(Vector#(5,Vector#(5,Bit#(64)))) a <- mkReg(aby);
Reg#(Vector#(5,Vector#(5,Bit#(64)))) ap <- mkReg(aby);


Vector#(7,Bit#(1)) a1 = replicate('b0);
Vector#(24,Vector#(7,Bit#(1))) ab1 = replicate(a1); 


Reg#(States) state <- mkReg(IDLE);

Reg#(int) roundIndex <- mkReg(0);
Bit#(64) tempr = 'h0000000000000000;
Reg#(Bit#(64)) rc <- mkReg(tempr);

ab1[0][0] = 'b1;
ab1[0][1] = 'b0;
ab1[0][2] = 'b0;
ab1[0][3] = 'b0;
ab1[0][4] = 'b0;
ab1[0][5] = 'b0;
ab1[0][6] = 'b0;
ab1[1][0] = 'b0;
ab1[1][1] = 'b1;
ab1[1][2] = 'b0;
ab1[1][3] = 'b1;
ab1[1][4] = 'b1;
ab1[1][5] = 'b0;
ab1[1][6] = 'b0;
ab1[2][0] = 'b0;
ab1[2][1] = 'b1;
ab1[2][2] = 'b1;
ab1[2][3] = 'b1;
ab1[2][4] = 'b1;
ab1[2][5] = 'b0;
ab1[2][6] = 'b1;
ab1[3][0] = 'b0;
ab1[3][1] = 'b0;
ab1[3][2] = 'b0;
ab1[3][3] = 'b0;
ab1[3][4] = 'b1;
ab1[3][5] = 'b1;
ab1[3][6] = 'b1;
ab1[4][0] = 'b1;
ab1[4][1] = 'b1;
ab1[4][2] = 'b1;
ab1[4][3] = 'b1;
ab1[4][4] = 'b1;
ab1[4][5] = 'b0;
ab1[4][6] = 'b0;
ab1[5][0] = 'b1;
ab1[5][1] = 'b0;
ab1[5][2] = 'b0;
ab1[5][3] = 'b0;
ab1[5][4] = 'b0;
ab1[5][5] = 'b1;
ab1[5][6] = 'b0;
ab1[6][0] = 'b1;
ab1[6][1] = 'b0;
ab1[6][2] = 'b0;
ab1[6][3] = 'b1;
ab1[6][4] = 'b1;
ab1[6][5] = 'b1;
ab1[6][6] = 'b1;
ab1[7][0] = 'b1;
ab1[7][1] = 'b0;
ab1[7][2] = 'b1;
ab1[7][3] = 'b0;
ab1[7][4] = 'b1;
ab1[7][5] = 'b0;
ab1[7][6] = 'b1;
ab1[8][0] = 'b0;
ab1[8][1] = 'b1;
ab1[8][2] = 'b1;
ab1[8][3] = 'b1;
ab1[8][4] = 'b0;
ab1[8][5] = 'b0;
ab1[8][6] = 'b0;
ab1[9][0] = 'b0;
ab1[9][1] = 'b0;
ab1[9][2] = 'b1;
ab1[9][3] = 'b1;
ab1[9][4] = 'b0;
ab1[9][5] = 'b0;
ab1[9][6] = 'b0;
ab1[10][0] = 'b1;
ab1[10][1] = 'b0;
ab1[10][2] = 'b1;
ab1[10][3] = 'b0;
ab1[10][4] = 'b1;
ab1[10][5] = 'b1;
ab1[10][6] = 'b0;
ab1[11][0] = 'b0;
ab1[11][1] = 'b1;
ab1[11][2] = 'b1;
ab1[11][3] = 'b0;
ab1[11][4] = 'b0;
ab1[11][5] = 'b1;
ab1[11][6] = 'b0;
ab1[12][0] = 'b1;
ab1[12][1] = 'b1;
ab1[12][2] = 'b1;
ab1[12][3] = 'b1;
ab1[12][4] = 'b1;
ab1[12][5] = 'b1;
ab1[12][6] = 'b0;
ab1[13][0] = 'b1;
ab1[13][1] = 'b1;
ab1[13][2] = 'b1;
ab1[13][3] = 'b1;
ab1[13][4] = 'b0;
ab1[13][5] = 'b0;
ab1[13][6] = 'b1;
ab1[14][0] = 'b1;
ab1[14][1] = 'b0;
ab1[14][2] = 'b1;
ab1[14][3] = 'b1;
ab1[14][4] = 'b1;
ab1[14][5] = 'b0;
ab1[14][6] = 'b1;
ab1[15][0] = 'b1;
ab1[15][1] = 'b1;
ab1[15][2] = 'b0;
ab1[15][3] = 'b0;
ab1[15][4] = 'b1;
ab1[15][5] = 'b0;
ab1[15][6] = 'b1;
ab1[16][0] = 'b0;
ab1[16][1] = 'b1;
ab1[16][2] = 'b0;
ab1[16][3] = 'b0;
ab1[16][4] = 'b1;
ab1[16][5] = 'b0;
ab1[16][6] = 'b1;
ab1[17][0] = 'b0;
ab1[17][1] = 'b0;
ab1[17][2] = 'b0;
ab1[17][3] = 'b1;
ab1[17][4] = 'b0;
ab1[17][5] = 'b0;
ab1[17][6] = 'b1;
ab1[18][0] = 'b0;
ab1[18][1] = 'b1;
ab1[18][2] = 'b1;
ab1[18][3] = 'b0;
ab1[18][4] = 'b1;
ab1[18][5] = 'b0;
ab1[18][6] = 'b0;
ab1[19][0] = 'b0;
ab1[19][1] = 'b1;
ab1[19][2] = 'b1;
ab1[19][3] = 'b0;
ab1[19][4] = 'b0;
ab1[19][5] = 'b1;
ab1[19][6] = 'b1;
ab1[20][0] = 'b1;
ab1[20][1] = 'b0;
ab1[20][2] = 'b0;
ab1[20][3] = 'b1;
ab1[20][4] = 'b1;
ab1[20][5] = 'b1;
ab1[20][6] = 'b1;
ab1[21][0] = 'b0;
ab1[21][1] = 'b0;
ab1[21][2] = 'b0;
ab1[21][3] = 'b1;
ab1[21][4] = 'b1;
ab1[21][5] = 'b0;
ab1[21][6] = 'b1;
ab1[22][0] = 'b1;
ab1[22][1] = 'b0;
ab1[22][2] = 'b0;
ab1[22][3] = 'b0;
ab1[22][4] = 'b0;
ab1[22][5] = 'b1;
ab1[22][6] = 'b0;
ab1[23][0] = 'b0;
ab1[23][1] = 'b0;
ab1[23][2] = 'b1;
ab1[23][3] = 'b0;
ab1[23][4] = 'b1;
ab1[23][5] = 'b1;
ab1[23][6] = 'b1;

//Reg#(Vector#(24,Vector#(7,Bit#(1)))) values <- mkReg(ab1);

/*rule go2(state == ACTIVE);
state <= ACTIVE_INPUT;
Vector#(24,Vector#(7,Bit#(1))) ab = values;
int i = 0;

while(i<24)begin
	int j= 0;
	while(j<7)begin
		int x = j + 7*i;
		Bit#(9) r = 'b010000000;
		Bit#(9) r2 = 'b010000000;
		
		if (x!=1) begin
			int i1 = 1;
			while(i1 < x+1)begin
				//r[8] = 0;
				r2[8] = r[8]^r[0];
				r2[4] = r[4]^r[0];
				r2[3] = r[3]^r[0];
 				r2[2] = r[2]^r[0];
				//for (int j1 =0;j1<8;j1=j1+1)
				//	r[j1] = r2[j1+1];
				r= r2/2;
				i1 = i1+1;
 				$write($time);
				$display(r);
			end
			ab[i][j] = r[7];
			$display(ab[i][j]);
		end	
		else 
			ab[i][j] ='b1;		


	j=j+1;	
	end


i = i+1;
end
endrule
*/

//Reg#(Bit#(1)) rho_Flag <- mkReg(0);
//Reg#(Bit#(1)) rho_Flag1 <- mkReg(0);
//RC_interface iorc <- rcCalculation();
rule go(state == ACTIVE_INPUT);
	//Integer index = fromInteger(roundIndex);
	//int index = roundIndex;	
	
	
	state <= COMPUTE_RC;
	//for(Integer j = 0; j<7; j=j+1)
		//rc[exp(2,j)-1] <= frc(fromInteger(j) + 7*index);
	//Integer j = 0;
	//RC_interface iorc <- rcCalculation();
	//while(j<7)begin
		//iorc.initializeRC(fromInteger(j),index);
		//Bit#(1) x <- iorc.frc();
	Bit#(64) rc2 = rc;
	for(Integer j=0;j<7;j=j+1)
		rc2[(2**j)-1] = ab1[roundIndex][fromInteger(j)];
	rc<=rc2;
	$display(2**3);
	for(int j = 0;j<64;j=j+1)
		$write(rc2[j]);
	$display(2**3);
		//j = j+1;
	//end
						
endrule

rule computeA(state ==COMPUTE_RC);
	state <= COMPLETED;
	Vector#(5,Vector#(5,Bit#(64))) tempA = a;
	Vector#(5,Vector#(5,Bit#(64))) tempAP = ap;
	let rc1 = rc;
	for(int ij = 0; ij<64; ij = ij+1)
		$write(rc1[ij]);
	$display("");
	for(int i =1;i<5;i=i+1)
		for(int j = 0;j<5;j=j+1)
			for(int k = 0;k<64;k=k+1)
				tempAP[i][j][k] = tempA[i][j][k];
	for(int j = 1;j<5;j=j+1)
		for(int k = 0;k<64;k=k+1)
			tempAP[0][j][k] = tempA[0][j][k];
	for(int k = 0;k<64;k=k+1)
			tempAP[0][0][k] = tempA[0][0][k]^rc1[k];
	a <= tempA;
	ap <= tempAP;	


endrule


method Action initialize5(in, ir)if(state == IDLE);
	state <= ACTIVE_INPUT;
	Vector#(5,Vector#(5,Bit#(64))) tempA = a;
	for(int i = 0; i<5;i = i+1)
		for(int j = 0; j<5;j = j+1)
			//for(int k = 0; k<64;k=k+1)
				tempA[i][j] = in[i][j];
	a <= tempA;
	roundIndex <= ir;
	
endmethod

method ActionValue#(Vector#(5,Vector#(5,Bit#(64)))) out5()if(state == COMPLETED);
state <= IDLE;
return ap;
endmethod



endmodule : iotatrial1
endpackage : IotaTrial1
