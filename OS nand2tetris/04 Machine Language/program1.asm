//Program 1 to convert to machine language
// Computes R0 = 2 + 3
//Program 1 to convert to machine language
// Computes R0 = 2 + 3

//@2 //  Set the value of register A = 2
0000 0000 0000 0010
//D=A // Put 2 in D
1110 1100 0001 0000 

//@3 // Set the value of register A = 3
0000 0000 0000 0011
//D=D+A // Calculate 2 + 3 and put the output in D
1110 0000 1001 0000

//@0 // Set the value of register A = 0
0000 0000 0000 0000
//M=D // Put 5 into the address RAM[0] that register A pointed to.
1110 0011 0000 1000