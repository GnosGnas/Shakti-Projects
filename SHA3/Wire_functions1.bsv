import KeccakConstants::*;
import Vector::*;
// Rho function not fully generalised (t range)

function KArray theta(KArray inp);
    Vector#(Sidelength, Bit#(W_param)) temp1 = replicate(0);
    Vector#(Sidelength, Bit#(W_param)) temp2 = replicate(0);
    KArray out = defaultValue;

    for(Integer i = 0; i < sidelength; i = i+1)
    begin
        for(Integer k = 0; k < w_param; k = k+1)
        begin
            temp1[i][k] = inp[i][0][k];

            for(Integer j = 1; j < sidelength; j = j+1)
                temp1[i][k] = temp1[i][k] ^ inp[i][j][k];
                
            if( (i==0) && (k==0) )
                temp2[i][k] = temp1[sidelength-1][k] ^ temp1[1][w_param-1];
            else if( (i==0) && (k>0) )
                temp2[i][k] = temp1[sidelength-1][k] ^ temp1[1][k-1];
            else if( (i==sidelength-1) && (k==0) )
                temp2[i][k] = temp1[i-1][k] ^ temp1[0][w_param-1];
            else if( (i==sidelength-1) && (k>0) )
                temp2[i][k] = temp1[i-1][k] ^ temp1[0][k-1];
            else if( (i>0) && (k>0) )
                temp2[i][k] = temp1[i-1][k] ^ temp1[i+1][k-1];

            for(Integer j = 0; j < sidelength; j = j+1)
                out[i][j][k] = inp[i][j][k] ^ temp2[i][k];
        end
    end
    return out;
endfunction

function KArray rho(KArray inp);
    KArray out = defaultValue;
    Integer i=1;
    Integer j=0;
    Integer tempi=1;
    Integer tempj=0;

    for(Integer k = 0; k < w_param; k = k+1)
    begin
        out[0][0][k] = inp[0][0][k];
    end

    
    for(Integer t = 0; t < 24; t = t+1) ////////////////
    begin
        for(Integer k = 0; k < w_param; k = k+1)
        begin
            UInt#(L_param) inp_pos = 0;

            if( k - (((t+1)*(t+2))/2) >= 0 )
            begin
                inp_pos = fromInteger(k - (((t+1)*(t+2))/2));
            end
            else if( k - (((t+1)*(t+2))/2) < 0 )
            begin
                inp_pos = unpack(fromInteger(w_param)) - fromInteger((((t+1)*(t+2))/2) - k);
            end


            out[i][j][k] = inp[i][j][inp_pos];
            //out[i][j][k] = inp[i][j][(k - ((t+1)*(t+2))/2)%w_param];
            i = tempj;
            j = (2*tempi + 3*tempj)%5;
            tempi = i;
            tempj = j;
        end
    end

    return out;
endfunction


function KArray pi(KArray inp);
    KArray out = defaultValue;

    for(Integer i = 0; i < sidelength; i = i+1)
        for(Integer j = 0; j < sidelength; j = j+1)
            for(Integer k = 0; k < w_param; k = k+1)
                out[i][j][k] = inp[(i + 3*j)%sidelength][i][k];
    
    return out;
endfunction


function KArray chi(KArray inp);
    KArray out = defaultValue;

    for(Integer i = 0; i < sidelength; i = i+1)
    begin
        for(Integer j = 0; j < sidelength; j = j+1)
        begin
            for(Integer k = 0; k < w_param; k = k+1)
            begin
                out[i][j][k] = inp[i][j][k] ^ ( (inp[(i+1)%sidelength][j][k] ^ 1) & inp[(i+2)%sidelength][j][k] );
            end
        end
    end

    return out;
endfunction


function Bit#(1) rc_func(int t);
    Bit#(9) c = 0;          
    Bit#(8) ctemp = 0;
    c[7] = 1;

    if(t%255 == 0)
        ctemp[0] = 1; ///to return 1
    else
        for(int i = 1; i <= t%255; i = i+1)
        begin
            c[0] = c[0] ^ c[8];
            c[4] = c[4] ^ c[8];
            c[5] = c[5] ^ c[8];
            c[6] = c[6] ^ c[8];

            ctemp = truncate(c);
            c = zeroExtend(ctemp);
        end

    return ctemp[0];
endfunction


function KArray iota(KArray inp, int ir);
    KArray out = defaultValue;
    Bit#(W_param) rc = 0;

    for(Integer i = 0; i < sidelength; i = i+1)
        for(Integer j = 0; j < sidelength; j = j+1)
            for(Integer k = 0; k < w_param; k = k+1)
                out[i][j][k] = inp[i][j][k];
    
    for(Integer j = 1; j < w_param; j = j*2)
        rc[j-1] = rc_func(fromInteger(j) + 7*ir);

    for(Integer k = 0; k < w_param; k = k+1)
        out[0][0][k] = inp[0][0][k] ^ rc[k];

    return out;
endfunction


function KArray roundfunction(KArray inp, int ir); /////To be confirmed
    return iota(chi(pi(rho(theta(inp)))), ir);    
endfunction
