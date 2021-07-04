// Rho function not fully generalised (t range)

import KeccakConstants::*;
import Vector::*;

// Theta(2)
function m modfunc_l(m a, m b) provisos(Arith#(m), Ord#(m)); //not generalised - b is positive - a<b
    if(a < 0)
        return b + a;
    else
        return a;
endfunction

// Theta, Chi(2)
function m modfunc_g(m a, m b) provisos(Arith#(m), Ord#(m)); //not generalised - b is positive - a>b
    if(a >= b)
        return a - b;
    else
        return a;
endfunction

//Verified
function KArray theta(KArray inp);
    Vector#(Sidelength, Bit#(W_param)) temp1 = replicate(0); //5x64
    Vector#(Sidelength, Bit#(W_param)) temp2 = replicate(0); //5x64
    KArray out = defaultValue;

    for(Integer i = 0; i < sidelength; i = i+1) //5
        for(Integer k = 0; k < w_param; k = k+1) //64
        begin
            //C[x,z]
            temp1[i][k] = inp[i][0][k];

            for(Integer j = 1; j < sidelength; j = j+1) //5
            begin
                temp1[i][k] = temp1[i][k] ^ inp[i][j][k];
            end
            //
        end

    for(Integer i = 0; i < sidelength; i = i+1) //5
        for(Integer k = 0; k < w_param; k = k+1) //64
        begin
            //D[x,z]
            temp2[i][k] = temp1[modfunc_l((i-1), sidelength)][k] ^ temp1[modfunc_g((i+1), sidelength)][modfunc_l((k-1), w_param)];
            //

            for(Integer j = 0; j < sidelength; j = j+1) //5
                out[i][j][k] = inp[i][j][k] ^ temp2[i][k];
        end
    return out;
endfunction

//Verified
function KArray rho(KArray inp); ////Not generalised
    KArray out = defaultValue;
    Integer i=1;
    Integer j=0;
    Integer tempi=1;
    Integer tempj=0;

    for(Integer k = 0; k < w_param; k = k+1) //64
        out[0][0][k] = inp[0][0][k];
    
    for(Integer t = 0; t < 24; t = t+1)
    begin
        for(Integer k = 0; k < w_param; k = k+1) //64
        begin
            Integer val = k - (((t+1)*(t+2))/2);
            //out[i][j][k] = inp[i][j][modfunc_tl((k - ((t+1)*(t+2))/2), w_param)];

            if( (val < -256) )
                out[i][j][k] = inp[i][j][val + 320];
            else if( (val >= -256) && (val < -192) )
                out[i][j][k] = inp[i][j][val + 256];
            else if( (val >= -192) && (val < -128) )
                out[i][j][k] = inp[i][j][val + 192];
            else if( (val >= -128) && (val < -64) )
                out[i][j][k] = inp[i][j][val + 128];
            else if( (val >= -64) && (val < 0) )
                out[i][j][k] = inp[i][j][val + 64];
            else
                out[i][j][k] = inp[i][j][val];
        end
        i = tempj;
        //j = modfunc_tg((2*tempi + 3*tempj), 5);

        if( ((2*tempi + 3*tempj) >= 20) )
            j = (2*tempi + 3*tempj) - 20;
        else if( ((2*tempi + 3*tempj) < 20) && ((2*tempi + 3*tempj) >= 15) )
            j = (2*tempi + 3*tempj) - 15;
        else if( ((2*tempi + 3*tempj) < 15) && ((2*tempi + 3*tempj) >= 10) )
            j = (2*tempi + 3*tempj) - 10;
        else if( ((2*tempi + 3*tempj) < 10) && ((2*tempi + 3*tempj) >= 5) )
            j = (2*tempi + 3*tempj) - 5;
        else 
            j = 2*tempi + 3*tempj;
        
        tempi = i;
        tempj = j;
    end
    return out;
endfunction

//verified
function KArray pi(KArray inp);
    KArray out = defaultValue;

    for(Integer i = 0; i < sidelength; i = i+1) //5
        for(Integer j = 0; j < sidelength; j = j+1) //5
            for(Integer k = 0; k < w_param; k = k+1) //64
            begin
               //out[i][j][k] = inp[modfunc_tg((i + 3*j), sidelength)][i][k];
               if( (i + 3*j) >= 15 )
                    out[i][j][k] = inp[i + 3*j - 15][i][k];
                else if( ((i + 3*j) < 15) && ((i + 3*j) >= 10) )
                    out[i][j][k] = inp[i + 3*j - 10][i][k];
                else if( ((i + 3*j) < 10) && ((i + 3*j) >= 5) )
                    out[i][j][k] = inp[i + 3*j - 5][i][k];
                else
                    out[i][j][k] = inp[i + 3*j][i][k];
            end
    return out;
endfunction

//verified
function KArray chi(KArray inp);
    KArray out = defaultValue;

    for(Integer i = 0; i < sidelength; i = i+1) //5
        for(Integer j = 0; j < sidelength; j = j+1) //5
            for(Integer k = 0; k < w_param; k = k+1) //64
                out[i][j][k] = inp[i][j][k] ^ ( (inp[modfunc_g((i+1), sidelength)][j][k] ^ 1) & inp[modfunc_g((i+2), sidelength)][j][k] );
    return out;
endfunction

//Verified
function Bit#(1) rc_func(int t);  //t ranges from 0 to l_param + 7*(nr-1) //////Optimisation needed?
    Bit#(8) c = 0;          
    Bit#(9) ctemp = 0;
    Bit#(T_Size) t_values = 0; //l + 7*(nr-1) + 1
    
    c[0] = 1'b1;
    t_values[0] = 1'b1;

    for(Integer i = 1; i < valueof(T_Size); i = i+1) //167
    begin
            ctemp = {c, 1'b0};

            ctemp[0] = ctemp[0] ^ ctemp[8];
            ctemp[4] = ctemp[4] ^ ctemp[8];
            ctemp[5] = ctemp[5] ^ ctemp[8];
            ctemp[6] = ctemp[6] ^ ctemp[8];

            c = ctemp[7:0];  //truncate(ctemp)     
            t_values[i] = c[0];
    end

    return t_values[t];
endfunction



//////NOT USED
//Verified
//Reduce ir size
function KArray iota(KArray inp, int ir);
    KArray out = defaultValue;
    Bit#(W_param) rc = 0; //64

    for(Integer i = 0; i < sidelength; i = i+1) //5
        for(Integer j = 0; j < sidelength; j = j+1) //5
            for(Integer k = 0; k < w_param; k = k+1) //64
                out[i][j][k] = inp[i][j][k];
    
    for(Integer j = 0; j <= l_param; j = j+1) //6
        rc[2**j - 1] = rc_func(fromInteger(j) + 7*ir);

    for(Integer k = 0; k < w_param; k = k+1) //64
        out[0][0][k] = out[0][0][k] ^ rc[k];
        
    return out;
endfunction


function KArray roundfunction(KArray inp, int ir);
    return iota(chi(pi(rho(theta(inp)))), ir);    
endfunction



function Bit#(8) flipper(Bit#(8) inp);///////
    Bit#(8) outp = defaultValue;

    for(Integer i=0; i < 8; i=i+1)
        outp[i] = inp[8 - 1 - i];
    
    return outp;
endfunction

