
// Problem 2
// set i（R0） = 4
@4
D=A
@R0
M=D

// put 5 R0n D
@5
D=A

// calculate 5-4, save in R0
@R0
D=M
@5
D=D-A

// if i < 5, jump to @THREE
@THREE
D;JLT

// else, jump to @TWO
@TWO
0;JMP

(THREE)
// set R1 = 3
@3
D=A
@R1
M=D
0;JMP

(TWO)
// set R1 = 2
@2
D=A
@R1
M=D
