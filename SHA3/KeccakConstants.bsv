import Vector::*;

typedef 5 Sidelength;
typedef TMul#(Sidelength, Sidelength) Blocks;

typedef 256 Out_length;
typedef 6 L_param;

typedef TMul#(Out_length, 2) C_param;             // 2*output
typedef TExp#(L_param) W_param;
typedef TMul#(Blocks, W_param) B_param;     //b=25*2^l 
typedef TSub#(B_param, C_param) R_param;
typedef TAdd#(12, TMul#(2, L_param)) Nr_param;

typedef Bit#(B_param) KState;
typedef Vector#(Sidelength, Vector#(Sidelength, Bit#(W_param))) KArray;

KArray zero_array = replicate(replicate(0));
KState zero_state = 0;

Integer sidelength = valueof(Sidelength);
Integer blocks = valueof(Blocks);
Integer out_length = valueof(Out_length);
Integer l_param = valueof(L_param);
Integer c_param = valueof(C_param);
Integer w_param = valueof(W_param);
Integer b_param = valueof(B_param);
Integer r_param = valueof(R_param);
Integer nr_param = valueof(Nr_param);
