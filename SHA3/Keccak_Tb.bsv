package Keccak_Tb;
    import KeccakConstants::*;
    import myKeccak::*;
    import Wire_functions::*;

    (*synthesize*)
    module mkTb(Empty);
    	//Input corresponding to ascii string "abc"
        Bit#(R_param) temp = 1088'h00000000066362610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000000000000000;
  
        Keccak_ifc myMod <- mkKeccak;
        Reg#(int) i <- mkReg(0);
        Reg#(Bit#(R_param)) in_data <- mkReg(0);
        Reg#(Bit#(Out_length)) outp <- mkReg(0);

        rule passState(i==0);
            $display("Starting time:", $time);
            $display("Passing %h", temp);
            myMod.state_input(temp);
            i <= 1;
        endrule

        rule getDigest(i==1);
            let z <- myMod.state_output;
            outp <= z;
            $display("Ending time:", $time);
            $display("Squeeze value %h", z);
            i <= i+1;
            $finish;
        endrule
    endmodule
endpackage
