
package mySHA3;
    import myKeccak::*;
    import BRAMCore::*;
    import KeccakConstants::*;
    import BRAMFIFO::*;
    import FIFOF::*;
    import Vector::*;

    typedef 8 Addr_size;
    typedef 8 Data_size; //Only factors of 1088 will work
    typedef 256 Mem_size;
    typedef 2 K_factor;
    typedef TDiv#(R_param, Data_size) N_packet_input;
    typedef TDiv#(Out_length, Data_size) N_packet_output;
    typedef TMul#(K_factor, N_packet_input) BFIFO_size;

    Integer addr_size = valueof(Addr_size);
    Integer data_size = valueof(Data_size);
    Integer mem_size = valueof(Mem_size);
    Integer n_packet_input = valueof(N_packet_input);
    Integer n_packet_output = valueof(N_packet_output);
    Integer bfifo_size = valueof(BFIFO_size);

    Bit#(R_param) temp = 1088'h00000000066362610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000000000000000;

    module mkMem(BRAM_PORT#(Bit#(Addr_size), Bit#(Data_size)));
        BRAM_PORT#(Bit#(Addr_size), Bit#(Data_size)) myMem <- mkBRAMCore1(mem_size, False); //If BRAM is PIPELINED or not?
        
        Reg#(Bool) read_enable <- mkReg(False);
        Reg#(Bool) initialiser <- mkReg(True);
        PulseWire blocker <- mkPulseWire;

        ///////Initialisers
        Reg#(Bit#(Addr_size)) test_ad <- mkReg(0);
        Reg#(int) pos <- mkReg(0);

        rule init (initialiser);
            myMem.put(True, test_ad, temp[pos+fromInteger(data_size)-1:pos]);
            pos <= pos + fromInteger(data_size);
            test_ad <= test_ad+1;

            if (pos == 1080)
                initialiser <= False;
        endrule
        ////////

        rule disabler (read_enable && !blocker); ////To prevent reading beyond one cycle
            read_enable <= False;
        endrule

        method Action put(Bool write, Bit#(Addr_size) address, Bit#(Data_size) datain) if (!initialiser);
            myMem.put(write, address, datain);

            if(!write)
            begin
                blocker.send();
                read_enable <= True;
            end
        endmethod

        method Bit#(Data_size) read if ((!initialiser) && (read_enable));
            return myMem.read();
        endmethod
    endmodule


    interface SHA3_ifc;
        method Action put_addr (Bit#(Addr_size) address_inp, int num);
        method Action put_dest_addr (Bit#(Addr_size) dest_address_inp);
        method Bool done;
    endinterface

    (*synthesize*)
    module mkSHA3 (SHA3_ifc);
        Reg#(Bit#(Addr_size)) addr <- mkReg(defaultValue);
        Reg#(Maybe#(Bit#(Addr_size))) dest_addr <- mkReg(tagged Invalid);
        Reg#(Bool) pass_addr_flag <- mkReg(False);
        Reg#(int) n <- mkReg(0);

        Reg#(int) counter1 <- mkReg(-1); //Initial values given as needed
        Reg#(int) counter2 <- mkReg(0);
        Reg#(int) counter3 <- mkReg(0);

        Reg#(Vector#(N_packet_input, Bit#(Data_size))) input_array <- mkReg(replicate(0));
        Reg#(Vector#(N_packet_output, Bit#(Data_size))) output_array <- mkReg(replicate(0));
        Reg#(Bool) fetch_digest <- mkReg(False);
        Reg#(Bool) mem_flag <- mkReg(False);
        Reg#(Bool) done_flag <- mkReg(True);

        PulseWire disable_pass_addr <- mkPulseWire;

        BRAM_PORT#(Bit#(Addr_size), Bit#(Data_size)) myMem <- mkMem; 
        Keccak_ifc core_mod <- mkKeccak;
        FIFOF#(Bit#(Data_size)) bram_fifo <- mkSizedBRAMFIFOF(bfifo_size); 

        rule pass_addr ((pass_addr_flag) && (!done_flag) && (counter1 < fromInteger(n_packet_input) && (counter1 >= 0)) && (!disable_pass_addr));  //last conds only cos of warning
            myMem.put(False, addr, ?);

            if(counter1 == fromInteger(n_packet_input-1))
                pass_addr_flag <= False;

            counter1 <= counter1+1;            
            addr <= addr+1;
        endrule

        rule get_values ((counter1 >= 0) && (!done_flag));
            let z = myMem.read();
            bram_fifo.enq(z);
        endrule

        rule counter_changer ((counter1 == fromInteger(n_packet_input)) && (!done_flag));
            counter1 <= -1;
        endrule

        rule changer ((counter1 == -1) && (!done_flag));
            if((bram_fifo.notFull) && (n > 1))
                pass_addr_flag <= True;

            counter1 <= 0;
        endrule

        rule reg_value (counter2 < fromInteger(n_packet_input)); //Executed only when fifo has values
            input_array[counter2] <= bram_fifo.first();
            bram_fifo.deq();

            counter2 <= counter2+1;
        endrule

        //Check if this rule is executed if input to core fails
        rule pass_value ((counter2 == fromInteger(n_packet_input)) && (!mem_flag) && (!done_flag));
            $display($time, " - Passing input to Keccak core: %h", pack(input_array));
            core_mod.state_input(pack(input_array));
            counter2 <= 0;
            
            if (n == 1)
                fetch_digest <= True;
            else
                n <= n-1;
        endrule

        rule get_digest (fetch_digest && (!mem_flag));
            let z <- core_mod.state_output();
            $display($time, " - Digest %h", z);

            Bit#(Out_length) templ = ?;
            Vector#(N_packet_output, Bit#(Data_size)) tempa = ?;
            templ = z;

            for(Integer i = 0; i <= n_packet_output - data_size; i=i+data_size)
                tempa[i] = templ[i+data_size-1:i];

            output_array <= tempa;
            core_mod.reset_module();
            fetch_digest <= False;
            mem_flag <= True;
        endrule

        rule pass_digest ((mem_flag) && (isValid(dest_addr)) && (!done_flag));
            myMem.put(True, dest_addr.Valid, output_array[counter3]);
            disable_pass_addr.send();

            if(counter3 == fromInteger(n_packet_output - 1))
            begin
                counter3 <= 0;
                mem_flag <= False;
                dest_addr <= tagged Invalid;
                done_flag <= True;
            end
            else
            begin
                counter3 <= counter3 + 1;
                dest_addr <= tagged Valid(dest_addr.Valid + 1);
            end
        endrule

        method Action put_addr (Bit#(Addr_size) address_inp, int num) if (done_flag);
            if(num > 0)
            begin
                addr <= address_inp;
                n <= num;
                pass_addr_flag <= True;
                counter1 <= 0;
                done_flag <= False;
            end
        endmethod

        method Action put_dest_addr (Bit#(Addr_size) dest_address_inp) if (!isValid(dest_addr));
            dest_addr <= tagged Valid(dest_address_inp);
        endmethod

        method Bool done;
            return done_flag;
        endmethod
    endmodule
endpackage
