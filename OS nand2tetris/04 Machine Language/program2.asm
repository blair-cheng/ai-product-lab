
// Program 2 to convert to machine language
// Symbol-less version of the Max.asm program. 

@0 //Set the value of register A = 0.
//0000 0000 0000 0000
//Register A is used, so the binary begins with 0, and the rest binaries shows the binary value of A, which is 0 here.

//D=M // Put the value in RAM[0] in D.
1111 1100 0001 0000

//@1 // Set the value of register A = 1.
0000 0000 0000 0001
//D=D-M // Calculate D - RAM[1], and put the result in D.
1111 0100 1101 0000

//@10 // Set the value of register A = 10.
0000 0000 0000 1010
//D; JGT // If the value in D is greater than 0, jump to RAM[10].
1110 0011 0000 0001

//@1 //  Set the value of register A = 1.
0000 0000 0000 0001
//D=M // Put the value in RAM[1] in D.
1111 1100 0001 0000

//@12 // Set the value of register A = 12.
0000 0000 0000 1100
//0;JMP // Unconditially jump to RAM[12] and loop there.
1110 1010 1000 0111

//@0 //Set the value of register A = 0.
0000 0000 0000 0000
//D=M // Put the value in RAM[0] into D.
1111 1100 0001 0000

//@2 //Set the value of register A = 2.
0000 0000 0000 0010
//M=D // Put the value in D into RAM[2]
1110 0011 0000 1000

//@14 //Set the value of register A = 14.
0000 0000 0000 1110
//0;JMP // Unconditially jump to RAM[14] and loop there.
1110 1010 1000 0111


