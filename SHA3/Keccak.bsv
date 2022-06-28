/*
Package name: Keccak
Author name: Surya Prasad S (EE19B121)

Description: Main package for Keccak function
*/

package Keccak;
	// Importing required packages
	import KeccakConstants::*;
	import Wire_functions::*;
	import Vector::*;
	import ConfigReg::*;

	Int#(6) init_ir = fromInteger(12 + 2*l_param - nr_param); //0
	Int#(6) fin_ir = fromInteger(12 + 2*l_param - 1);

    typedef enum {THETA, RHO, PI, CHI, IOTA} Round_enum deriving(Bits, Eq);

	interface Keccak_ifc;
		method Action state_input(Bit#(R_param) inp); //1088
		method Action reset_module;
		method ActionValue#(Bit#(Out_length)) state_output; //256
	endinterface

	//(*synthesize*)
	module mkKeccak(Keccak_ifc);
		Reg#(KArray) reg_data <- mkReg(zero_array); //5x5x64
		Reg#(Int#(6)) ir <- mkReg(init_ir); 
		Reg#(Bool) go <- mkConfigReg(False);
		Reg#(Bool) out_ready <- mkReg(False);
		Wire#(Bool) reset_flag <- mkDWire(False);
        Reg#(Round_enum) status <- mkReg(THETA);
		
        rule func1( go && (status == THETA) );
            let temp1 = reg_data;
            let temp2 = theta(temp1);
            reg_data <= temp2;
            status <= RHO;
		/*
			for(Integer i=0; i<sidelength; i=i+1)
				for(Integer j=0; j<sidelength; j=j+1)
					$display("Theta:%h round:%d", temp2[j][i], i+j);
		*/
        endrule

        rule func2( go && (status == RHO) );
            let temp1 = reg_data;
            let temp2 = rho(temp1);
            reg_data <= temp2;
            status <= PI;
		/*
			for(Integer i=0; i<sidelength; i=i+1)
				for(Integer j=0; j<sidelength; j=j+1)
					$display("Rho:%h round:%d", temp2[j][i], i+j);
		*/
        endrule        

        rule func3( go && (status == PI) );
            let temp1 = reg_data;
            let temp2 = pi(temp1);
            reg_data <= temp2;
            status <= CHI;
		/*
			for(Integer i=0; i<sidelength; i=i+1)
				for(Integer j=0; j<sidelength; j=j+1)
					$display("Pi:%h round:%d", temp2[j][i], i+j);
		*/
        endrule

        rule func4( go && (status == CHI) );
            let temp1 = reg_data;
            let temp2 = chi(temp1);
            reg_data <= temp2;
            status <= IOTA;
		/*
			for(Integer i=0; i<sidelength; i=i+1)
				for(Integer j=0; j<sidelength; j=j+1)
					$display("Chi:%h round:%d", temp2[j][i], i+j);
		*/
        endrule            

        rule func5( go && (status == IOTA) );
            KArray temp1 = defaultValue;
			temp1 = reg_data;
			Bit#(W_param) rc = 0; //64

			for(Integer j = 0; j <= l_param; j = j+1) //6
				rc[2**j - 1] = rc_func(fromInteger(j) + 7*unpack({0,pack(ir)})); 
				
			for(Integer k = 0; k < w_param; k = k+1) //64
				temp1[0][0][k] = temp1[0][0][k] ^ rc[k];

			reg_data <= temp1;
            status <= THETA;
            ir <= ir + 1;
			/*
			for(Integer i=0; i<sidelength; i=i+1)
				for(Integer j=0; j<sidelength; j=j+1)
					$display("Iota:%h round:%d", temp1[j][i], i+j);
			*/
        endrule

        rule stopgo( (ir == fin_ir) && (status == IOTA) && (go) );
            go <= False;
            out_ready <= True;
        endrule


		method Action state_input(Bit#(R_param) inp) if(!go && !(reset_flag)); //1088
			KArray lv_data = zero_array;
			KState temp_data = zero_state;
			temp_data = {inp, 512'b0};

			for(Integer j = 0; j < sidelength; j = j+1) //5
				for(Integer i = 0; i < sidelength; i = i+1) //5
					for(Integer k = 0; k < w_param ; k = k+1)
						if( ((i + 5*j)*w_param + k) >= 512 )
							lv_data[sidelength - 1 - i][sidelength - 1 - j][k] = reg_data[sidelength - 1 - i][sidelength - 1 - j][k] ^ temp_data[(i + 5*j)*w_param + k];

			reg_data <= lv_data;
			go <= True;
			ir <= init_ir;
			out_ready <= False;
            status <= THETA;
		endmethod
		
		method Action reset_module if(!go);
			reg_data <= zero_array;
			reset_flag <= True;
		endmethod

//create_clock -period 10.000 -name CLK -waveform {0.000 5.000} -add [get_nets CLK] //or get_ports
		method ActionValue#(Bit#(Out_length)) state_output if(out_ready);
			Bit#(Out_length) outp = 0;
			Bit#(Out_length) outp2 = 0;

			/*
			for(Integer i=0; i<sidelength; i=i+1)
				for(Integer j=0; j<sidelength; j=j+1)
					$display("Keccak output:%h", reg_data[j][i]);
			*/
			for(Integer i=0; i < sidelength; i=i+1) //5
				for(Integer k=0; k < w_param ; k=k+1) //64
					if((i*w_param + k) < out_length)
						outp[i*w_param + k] = reg_data[i][0][k];

			outp2[255:248] = outp[7:0];
			outp2[247:240] = outp[15:8];
			outp2[239:232] = outp[23:16];
			outp2[231:224] = outp[31:24];
			outp2[223:216] = outp[39:32];
			outp2[215:208] = outp[47:40];
			outp2[207:200] = outp[55:48];
			outp2[199:192] = outp[63:56];

			outp2[191:184] = outp[71:64];
			outp2[183:176] = outp[79:72];
			outp2[175:168] = outp[87:80];
			outp2[167:160] = outp[95:88];
			outp2[159:152] = outp[103:96];
			outp2[151:144] = outp[111:104];
			outp2[143:136] = outp[119:112];
			outp2[135:128] = outp[127:120];

			outp2[127:120] = outp[135:128];
			outp2[119:112] = outp[143:136];
			outp2[111:104] = outp[151:144];
			outp2[103:96] = outp[159:152];
			outp2[95:88] = outp[167:160];
			outp2[87:80] = outp[175:168];
			outp2[79:72] = outp[183:176];
			outp2[71:64] = outp[191:184];

			outp2[63:56] = outp[199:192];
			outp2[55:48] = outp[207:200];
			outp2[47:40] = outp[215:208];
			outp2[39:32] = outp[223:216];
			outp2[31:24] = outp[231:224];
			outp2[23:16] = outp[239:232];
			outp2[15:8] = outp[247:240];
			outp2[7:0] = outp[255:248];	

			return outp2;
		endmethod
	endmodule
endpackage
