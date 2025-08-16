// Problem 1
// for loop
//set j = 5
@5
D=A
@j
M=D

//set i = 1
@1
D=A
@i
M=D

//if i < 5
(LOOP)
@i
D=M
@5
D=D-A
@END
D;JLT

//j--, i++
@j
M=M-1
@i
M=M+1
@LOOP
0;JMP

(END)
@END
0;JMP




// Problem 2
// if - then  - else

//set i = 4
@4
D=A
@i
M=D

// put 5 in D
@5
D=A

//calculate 5-4, save in R0
@i
D=M
@5
D=D-A

//if i < 5, jump to @three
@THREE
D;JLT

//else, jump to @two
@TWO
0;JMP

(THREE)
//set three
@3
D=A
@j
M=D
0;JMP

(TWO)
//set two
@2
D=A
@j
M=D

// Problem 3
//while loop
//set i = 0
@0
D=A
@i
M=D

//set j = 0
@0
D=A
@j
M=D

@LOOP
//while i == 0, j++
@i
D=M
@0
D;JEQ
@j
M=M+1

//if j = 5, then i = j
@j
D=M
@5
D=D-A
@END
D;JEQ
@i
M=D
@LOOP

(END)
0;JMP


// Problem 4
// load and traverse an array
//set A[0] = 5
@5
D=A
@A0
M=D

//set A[1] = 4
@4
D=A
@A1
M=D

//set A[2] = 3
@3
D=A
@A2
M=D

//set A[3] = 2
@2
D=A
@A3
M=D

//set A[4] = 1
@1
D=A
@A4
M=D

//set A[5] = 5
@0
D=A
@A5
M=D

//set i = 0
@0
D=A
@i
M=D

(LOOP)
//if i>5, jump to END
@i
D=M
@6
D=D-A
@END
D;JLT

//read A[i] into D
@i
D=M
@A0
A=D+A
D=M

//if A[i] == 0, jump to check and set to 5
@CHECK_SET
D;JEQ

//else, i++
@CONTINUE
0;JMP

(CHECK_SET5)
@5
D=A
@i
A=M
@A0
A=D+A
M=D
@LOOP

(CONTINUE)
@i
M=M+1
@LOOP

(END)
0;JMP




