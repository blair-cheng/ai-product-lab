@2
M=0
@1
D=M
@14
D;JEQ // if RAM[1]= 0, mutiplication finished.
@0
D=M
@2
M=D+M
@1
MD=M-1
@2
D;JGT
@14
0;JMP


// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Mult.asm

// Multiplies R0 and R1 and stores the result in R2.
// (R0, R1, R2 refer to RAM[0], RAM[1], and RAM[2], respectively.)

// Put your code here.

//R0*R1, store in R2
//check if R1 = 0
//    R1 = 0, stop multiplication.jump to 15 and repeat
//    R1 > 0, R2 =  R0 + R2  , R1-1




