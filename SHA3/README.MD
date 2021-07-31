# Hardware Accelerator for SHA3 encryption

To run the test bench for SHA3 Module, run the following command in terminal:
*make*

To run all the files, run the following command in terminal:
*make all*

To test only the Keccak Module, run the following command in terminal:
*make Keccak_test*

## Overview of SHA3 implementation:

![lol](https://user-images.githubusercontent.com/69968227/127729416-893a3fb1-3473-419a-b638-3f4a70ff9866.png)



## Keccak Algorithm:
SHA3 Algorithm is based on sponge construction. Sponge construction is based on a wide random function or random permutation, and allows inputting ("absorbing" in sponge terminology) any amount of data, and outputting ("squeezing") any amount of data, while acting as a pseudorandom function with regard to all previous inputs. This leads to great flexibility. SHA3 uses Keccak algorithm whose specifications are as follows.

There are two parameters in KECCAK-p permutations, which are the number of iterations of step mapping functions, known as a round and the fixed length of strings that undergo the permutation, known as the permutation width. The number of rounds is indicated by Nr, whereas the width is indicated by b. The b range is in (25, 50, 100, 200, 400, 800, 1600) and Nr is any positive integer. One round of KECCAK-p permutation, which indicated by Rnd,comprises of a group of five transformations known as step mapping functions. An array of values for b bits, known as the state, is repeatedly updated in the permutation. The 
input data of the permutation is used to initialize the initial value of the state array.

### Algorithm to calculate KECCAK-p[b, Nr] (S):
1. Convert S into a state array, A
2. For ir from 12 + 2l - Nr to 12 + 2l – 1, let A′ = Rnd(A, ir)
3. Convert A′ into a string S’ of length b
4. Return S’ 

### Round function:
A complete Round Function (Rnd) consists of five step mapping functions, which are Theta (θ), Rho (ρ), Pi (π), Chi (χ), and Iota (ι).   
    Rnd(A, ir) = ι( χ(π(ρ(θ(A)))), ir)
________________
    Algorithm to calculate θ(A):
    Input: State Matrix A  
    Output: State Matrix A′  
    1. For 0≤x<5 and 0≤z<w, let
        C[x,z] = A[x,0,z] ⊕ A[x,1,z] ⊕ A[x,2,z] ⊕ A[x,3,z] ⊕ A[x,4,z]
    2. For 0≤x<5 and 0≤z<w let
        D[x,z] = C[(x-1) mod 5,z] ⊕ C[(x+1) mod 5, (z-1) mod w
    3. For 0≤x<5, 0≤y<5, and 0≤z<w, let
        A'[x,y,z] = A[x,y,z] ⊕ D[x,z]
  _______________________
    Algorithm to calculate ρ(A):
    Input: State Matrix A  
    Output: State Matrix A′  
    1. For 0≤z<w, let A′[0,0,z] = A[0,0,z]
    2. Let x = 1 and y = 0
    3. For t from 0 to 23, for 0≤z<w, let
        A'[x,y,z] = A[x,y,(z-(t+1)(t+2)/2 mod w]
        (x,y) = (y, (2x+3y) mod 5)
    4. Output A′
  _________________
    Algorithm to calculate π(A):
    Input: State Matrix A  
    Output: State Matrix A'  
    1. For 0≤x<5, 0≤y<5, and 0≤z<w, let
        A'[x,y,z] = A[(x+3y) mod 5,x,z]
    2. Output A′
 ____________
    Algorithm to calculate χ(A):
    Input: State Matrix A  
    Output: State Matrix A'  
    1. For 0≤x<5, 0≤y<5, and 0≤z<w, let
        A'[x,y,z] = A[x,y,z] ⊕ ((A[(x+1) mod 5,y,z] ⊕ 1) ⋅ A[(x+2) mod 5,y,z]
    2. Output A′
  _________________
Specification of ι(A,ir):
There is a parameter in specification of ι called round constant RC, which is dependent on the 
algorithm rc(t).  
  
    Algorithm to calculate Round Constant, rc(t):
    Input: Integer t
    Output: Round Constant rc(t)
    1. If t mod 255 = 0, return 1
    2. Let C = 10000000
    3. For i from 1 to t mod 255, let
        C = 0||C
        C[0] = C[0] ⊕ C[8]
        C[4] = C[4] ⊕ C[8]
        C[5] = C[5] ⊕ C[8]
        C[6] = C[6] ⊕ C[8]
        C = Trunc8[C]
    4. Output C[0]
___________________________
    Algorithm to calculate ι(A,ir):
    Input: State Matrix A, Round Constant rc(t), Round Index ir
    Output: State Matrix A′
    1. For 0≤x<5, 0≤y<5, and 0≤z<w, let A′[x,y,z] = A[x,y,z]
    2. Let RC = 0
    3. For 0≤j<l, let
        RC[2**j-1] = rc(j+7ir)
    4. For 0≤z<w, let 
        A'[0,0,z] = A'[0,0,z] ⊕ RC[z]
    5. Output A′
_______________________

