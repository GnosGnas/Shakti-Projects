package xd;

import RoundFunction::*;
import Vector::*;


typedef 6 L_param;
typedef 1600 B_param;			// b=25 * 2^l
typedef 1088 R_param;
typedef 512 C_param;
typedef 24 Nr_param;			// nr=12+2*l
typedef 64 W_param;				// w= 2^l

typedef Bit#(B_param) KState;
typedef Vector#(L_param, Vector#(5, Bit#(5))) KArray;

int init_ir = 12 + 2*L_param - Nr_param;
int fin_ir = 12+2*L_param-1;


interface Keccak_ifc;
	method Action state_input(KState inp);
	method ActionValue#(Bit#(C_param)) squeeze;
endinterface

(*synthesize*)
module mkXD(Keccak_ifc);
	KArray zero_state = replicate(replicate(0));
	Reg#(KArray) reg_data <- mkReg(zero_state);
	Reg#(int) ir <- mkReg(init_ir);
	Reg#(Bool) go <- mkReg(False);
	Reg#(Maybe#(Bit#(C_param))) outp <- mkReg(tagged Invalid);

	// Round function
	rule Rounding( go && (ir < fin_ir) );
		let storer = reg_data;
		storer = RoundFunction(storer, ir);
		reg_data <= storer;
		ir <= ir+1;
	endrule


	rule convert_to_State( go && (ir == fin_ir) );

	ir <= init_ir;
	endrule


	method Action state_input(KState inp) if(ir==init_ir);
	// State to Array conversion
	for(Integer i=0; i<...)
		reg_data <= inp;
		
		go <= True;
	endmethod

	method ActionValue#(Bit#(C_param)) state_output;
		go <= False;
		return outp;
	endmethod
endmodule
endpackage