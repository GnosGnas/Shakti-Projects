package myKeccak;
	import KeccakConstants::*;
	import Wire_functions1::*;
	import Vector::*;
	import ConfigReg::*;

	Integer init_ir = 12 + 2*l_param - nr_param;
	Integer fin_ir = 12+2*l_param-1;

	interface Keccak_ifc;
		method Action state_input(Bit#(R_param) inp);
		method Action reset_module;
		method ActionValue#(Bit#(Out_length)) state_output;
	endinterface

	(*synthesize*)
	module mkKeccak(Keccak_ifc);
		Reg#(KArray) reg_data <- mkReg(zero_array);
		Reg#(int) ir <- mkReg(fromInteger(init_ir));
		Reg#(Bool) go <- mkConfigReg(False);
		Reg#(Bool) out_ready <- mkReg(False);

		rule rounding( go && (ir < fromInteger(fin_ir)) );
			let storer = reg_data;
			storer = roundfunction(storer, ir); //testing purpose
			reg_data <= storer;
			ir <= ir+1;
		endrule

		rule stopgo( (ir == fromInteger(fin_ir)) && (go) );
			go <= False;
			out_ready <= True;
		endrule

		//(*execution_order="reset_module,state_input"*) //preempts??
		//pos = (5*i+j)*w_param + k
		method Action state_input(Bit#(R_param) inp) if(!go);
			KArray lv_data = defaultValue;

			for(Integer i = 0; i < sidelength; i = i+1)
			begin
				for(Integer j = 0; j < sidelength ; j = j+1)
				begin
					for(Integer k = 0; k < w_param ; k = k+1)
					begin
						if((5*i + j)*w_param + k < r_param)
						begin
							lv_data[i][j][k] = reg_data[i][j][k] ^ inp[(5*i + j)*w_param + k];
						end
					end
				end
			end

			reg_data <= lv_data;
			go <= True;
			ir <= fromInteger(init_ir);
			out_ready <= False;
		endmethod

		method Action reset_module if(!go);
			reg_data <= zero_array;
		endmethod

		method ActionValue#(Bit#(Out_length)) state_output if(out_ready);
			Bit#(Out_length) outp = 0;

			for(Integer i=0; i < sidelength; i=i+1)
			begin
				for(Integer j=0; j < sidelength ; j=j+1)
				begin
					for(Integer k=0; k < w_param ; k=k+1)
					begin
						if((5*i+j)*w_param + k < out_length)
							outp[(5*i+j)*w_param + k] = reg_data[i][j][k];
					end
				end
			end

			return outp;
		endmethod
	endmodule

endpackage