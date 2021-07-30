
package sha3tb;
import mySHA32::*;

(*synthesize*)
module mkSHA3tb (Empty);
    SHA3_ifc mod_main <- mkSHA32;

    Reg#(Bit#(Addr_size)) addr <- mkReg(0);
    Reg#(Bit#(Addr_size)) dest_addr <- mkReg(0);
    Reg#(int) i <- mkReg(0);

    rule pass_init (i==0);
        $display("Passing address time:",$time);
        mod_main.put_addr(addr, 2);
        mod_main.put_dest_addr(dest_addr);
        i <= i+1;
    endrule

    rule getter (i==1);
        let z = mod_main.done;

        if(z)
        begin
            $display("Completion time:",$time);
            $finish;
        end
    endrule
endmodule
endpackage
