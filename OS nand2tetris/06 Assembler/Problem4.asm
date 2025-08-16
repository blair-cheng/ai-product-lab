
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

//set A[5] = 0
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
D;JGT

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

(CHECK_SET)
@5
D=A
@i
A=M
@A0
A=D+A
M=D


(CONTINUE)
@i
M=M+1
@LOOP

(END)
0;JMP




