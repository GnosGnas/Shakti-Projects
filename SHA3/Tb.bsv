package Tb;

import xd::*;

(*synthesize*)
module mkTb(Empty);
    Keccak_ifc myMod <- mkXD;
    Reg#(int) i <- mkReg(0);
    Reg#(KState) in_data <- mkReg(0);

    rule passState(i<10);
        $display("Passing %d", in_data);
        myMod.state_input(in_data);

        in_data <= in_data+10;
        i <= i+1;
    endrule

    rule getDigest( i<20 );
        $display("Squeeze value %d", myMod.squeeze);
        i <= i+1;
    endrule
endmodule
endpackage