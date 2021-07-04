package Tb;
    import KeccakConstants::*;
    import myKeccak2::*;
    import Wire_functions::*;

    (*synthesize*)
    module mkTb(Empty);
        Bit#(R_param) temp = 1088'h00000000066362610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000000000000000;
  
        Keccak_ifc myMod <- mkKeccak2;
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




/*
        //Bit#(26) abc = 26'b01100001011000100110001101; 

		rule mine( i < fromInteger(valueof(T_Size)) );
        let xd = rc_func(i);
			$display("moron %d %d %d", i, xd, fromInteger(valueof(T_Size)));
			i <= i+1;
            if(i== fromInteger(valueof(T_Size)))
            $finish;
		endrule
            Bit#(26) abci=0;
            $display("abc %b", abc);
            abci = abc;
            for(Integer ik=25; ik > 7; ik = ik-8)/////
                abci[ik:ik-7] = flipper(abc[ik:ik-7]);
            //processing+01


            $display("inverted %b", abci);
            Bit#(1088) temp1;
            temp1 = {abci, 1'b1, 1060'b0, 1'b1};
            $display("padded %h", temp1);

            for(Integer ij=0; ij < 1088; ij = ij+8)
                temp1[ij+7:ij] = flipper(temp1[ij+7:ij]);

            $display("pad %h no pad %h", temp1, temp);
            
            /*
            ////Not working!!!
            Bit#(1088) temp2 = 0;
           // Integer k=0;
            for(Integer p=0; p < 1088; p=p+8)
                Integer k = 1080 - p;
                temp2[p+7:p] = temp1[k+7:k];//(1087-p):(1080-p)];
            */
